import pandas as pd
import numpy as np

import spacy
from spacy.tokens import Doc

import re
import regex
from pathlib import Path

from compound_split import char_split
from germalemma import GermaLemma

import logging

__all__ = ["search_pairs_in_jobads"]

MODULE_DIR = Path(__file__).resolve().parent


def _get_vo_dictionary_df():
    """Load the verb-object dictionary as a dataframe.

    Returns:
        pandas.DataFrame: Dataframe containing object-verb pairs and task dimensions.
    """
    dictionary_df = pd.read_excel(MODULE_DIR.parent / 'data' / 'job_task_dictionary.xlsx', sheet_name='pairs')
    logging.info(f"number of pairs: {len(dictionary_df)}")
    dictionary_df['pair_string'] = dictionary_df.apply(
        lambda row: f"{row['Object']} {row['Verb']}", axis=1)

    return dictionary_df


def _add_uppercase_verb(deriv_list, verb):
    """Append an uppercase variant of a verb to a derivation list.

    Args:
        deriv_list (list): Existing list of derivation forms.
        verb (str): Base verb form.

    Returns:
        list: The updated derivation list.
    """
    uppercase = "".join([verb[0].upper(), verb[1:]])
    deriv_list.append(uppercase)
    return deriv_list


def _get_compounds():
    """Load compound mappings from the compounds Excel file.

    Returns:
        pandas.DataFrame: Dataframe containing compound-related mappings.
    """

    compound_df = pd.read_excel(MODULE_DIR.parent / 'data' / 'compounds.xlsx', 
                                sheet_name='compound', 
                                index_col=0)
    
    return compound_df


def _get_derivates():
    """Load verb derivations and convert them into a lookup dictionary.

    Returns:
        dict: Mapping of derivation forms to their base verb.
    """

    derivate_df = pd.read_excel(MODULE_DIR.parent / 'data' / 'verb_derivates.xlsx', sheet_name='verbs')
    logging.info(f"{len(derivate_df)} Verben")
    derivate_df['Derivate'] = derivate_df[derivate_df['Derivate'].notnull()]['Derivate'].apply(lambda x: x.split(', '))
    derivate_df['Derivate'] = derivate_df['Derivate'].fillna('').apply(list)

    # Für jedes Verb wird die uppercase-Variante ergänzt (beraten --> das Beraten)
    derivate_df['Derivate'] = derivate_df.apply(lambda row: _add_uppercase_verb(row['Derivate'], row['Verb']), axis=1)

    derivate_df = derivate_df.explode('Derivate')
    logging.info(f"{len(derivate_df)} Derivate")
    derivate_dict = dict(zip(derivate_df['Derivate'], derivate_df['Verb']))
    logging.info(f"{len(derivate_dict)} Derivate unique")

    return derivate_dict


def _split_compound(possible_compound):
    """Resolve a compound candidate into a verb-object pair if possible.

    Args:
        possible_compound (str): Compound candidate to analyze.

    Returns:
        pandas.Series | None: Resolved compound pair when available, otherwise None.
    """
    if possible_compound in compound_df.index:
        return compound_df.loc[possible_compound]
    possible_split = char_split.split_compound(possible_compound)[0]
    
    # lemmatisieren
    deriv = lemmatizer.find_lemma(possible_split[2], 'N')
    obj = lemmatizer.find_lemma(possible_split[1], 'N')
    if deriv in derivate_dict:
        if obj in vo_dict[derivate_dict[deriv]]:
            compound_df.loc[possible_compound] = {'Object': obj, 'Verb': derivate_dict[deriv]}
            return compound_df.loc[possible_compound]
    return None


def search_verb_objects(doc, use_derivates=True, split_compounds=True):
    """Extract verb-object candidate pairs from a spaCy document.

    Args:
        doc (spacy.tokens.Doc): The processed document containing sentence and token data.
        use_derivates (bool): Whether to resolve verb derivations.
        split_compounds (bool): Whether to try compound splitting for noun-like tokens.

    Returns:
        list: A list of pandas Series objects representing extracted pairs.
    """
    # returns list of series with verb object pairs
    pair_list = list()
    
    for token in doc:
        
        # prüfen, ob token ein Compound mit Verb-Objekt ist
        if split_compounds & (token.pos_ in ['NOUN', 'PROPN', 'X']):
            possible_split = _split_compound(token.lemma_)
        else:
            possible_split = None
        
        if possible_split is not None:
            verb = possible_split['Verb']
            obj = possible_split['Object']

            match_s = pd.Series({'id': doc._.id,
                                         'spacydoc': doc,
                                        'sentence': token.sent.text,
                                         'spacysent': token.sent,
                                        'verb': verb,
                                         'verb_pos': token.pos_,
                                 'compound': token.lemma_,
                                        'object': obj,
                                        'distance': 0})
            pair_list.append(match_s.to_frame().T) 
            
        else:        
            # prüfen, ob Lemma in Valid-List enthalten ist
            derivate = None
            if use_derivates & (token.lemma_ in derivate_dict): #transformiert Derivate in Verb
                derivate = token.lemma_
                verb = derivate_dict[token.lemma_]
                poss_obj_list = vo_dict[verb]
            elif token.lemma_ in vo_dict:
                verb = token.lemma_
                poss_obj_list = vo_dict[verb]
            else: #kein relevantes Wort
                continue

            # potenzielles Objekt innerhalb des Satzes suchen
            sent = token.sent
            for t2 in sent:
                if t2.lemma_ in poss_obj_list:
                    match_s = pd.Series({'id': doc._.id,
                                         'spacydoc': doc,
                                        'sentence': sent.text,
                                         'spacysent': sent,
                                        'verb': verb,
                                         'verb_pos': token.pos_,
                                         'derivate': derivate,
                                        'object': t2.lemma_,
                                        'distance': abs(token.i - t2.i)})
                    pair_list.append(match_s.to_frame().T)
                    
    return pair_list


def _get_sentence_list(jobad):
    """Split a job ad text into sentence-like segments.

    Args:
        jobad (str): Raw text content of a job advertisement.

    Returns:
        list: List of sentence segments.
    """
    jobad = re.sub('\n +', '\n', jobad)
    sentences = regex.split('\n(?=\n*[\*\-\+·o]?)', jobad)
    
    final_sentences = list()
    for sent in sentences:
        # längere Sätze noch mal zusätzlich zerteilen
        if len(sent) > 500:
            subsentences = regex.split('[\n\s](?=[\-\*\+][\n\s])', sent)
            if len(subsentences) > 3:
                for s in subsentences:
                    if len(s) > 0:
                        final_sentences.append(s)
            else:
                final_sentences.append(sent)
        else:
            final_sentences.append(sent)
    return final_sentences


def _get_spacy_doc(jobad, id):
    """Create a spaCy document from a job ad text and attach an identifier.

    Args:
        jobad (str): Raw job advertisement text.
        id (str | int): Identifier for the job ad.

    Returns:
        spacy.tokens.Doc: Processed spaCy document.
    """
    # paragraphen vorab in Sätze splitten
    sentences = _get_sentence_list(jobad)
     
    # Sätze jeweils in Spacydocs umbauen und anschließend zu einem Doc zusammenfügen
    doc_list = list(nlp.pipe(sentences))    
    doc = Doc.from_docs(doc_list)
    doc._.id = id    
    return doc    


def search_pairs_in_jobads(jobad_df:pd.DataFrame, text_column:str):
    """searches all valid verb-object-pairs within jobad texts (text_column)

    Args:
        jobad_df (pd.DataFrame): dataframe, including texts in text_column
        text_column (str): column to use for dependency parsing 
        (e.g. job ad text or job description)

    Returns:
        pd.Dataframe: dataframe with one row per identified pair
    """
    logging.info(f"search verb object pairs in {len(jobad_df)} jobads (column: {text_column})")

    jobad_df['spacydoc'] = jobad_df.apply(
        lambda row: _get_spacy_doc(row[text_column], row['id']), axis=1)   
    logging.info("preprocessed jobads with spacy")
    
    all_pairs = list()
    for doc in jobad_df['spacydoc']:
        pairs = search_verb_objects(doc, use_derivates=True, split_compounds=True)
        all_pairs.extend(pairs)

    match_df = pd.concat(all_pairs, ignore_index=True)


    match_df = match_df.sort_values(['id', 
                                        'distance']).drop_duplicates(subset=['id',
                                                                            'sentence', 
                                                                            'verb', 'object'])

    logging.info(f"found {len(match_df)} new pairs")

    # map task type
    match_df['pair_string'] = match_df.apply(
        lambda row: f"{row['object']} {row['verb']}", axis=1
    )

    match_df['Task_Dimension'] = match_df['pair_string'].map(dictionary_df.set_index('pair_string')['Task_Dimension'])

    # prepare return
    match_df = match_df[['id', 'sentence', 'Task_Dimension', 'verb', 'object', 
                         'derivate', 'compound', 'distance']].copy()
    for col in ['compound', 'derivate']:
        match_df[col] = match_df[col].replace({np.nan: None})

    

    return match_df

lemmatizer = GermaLemma()

compound_df = _get_compounds()
derivate_dict = _get_derivates()
dictionary_df = _get_vo_dictionary_df()

vo_grouped = dictionary_df.groupby('Verb', as_index=False).agg({'Object': set})
vo_dict = dict(zip(vo_grouped['Verb'], vo_grouped['Object']))
logging.info(f"number of verbs: {len(vo_dict)}")

nlp = spacy.load('de_core_news_lg')
Doc.set_extension("id", default=[])