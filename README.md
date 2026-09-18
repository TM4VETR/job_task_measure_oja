
# OJA Job Task Measure

**Making Job Tasks Measurable in Online Job Advertisements (OJA)**

This repository contains the code accompanying the paper:

> Schulz, Wiebke, Johanna Binnewitt, Timo Wiesner, and Stefan Winnige (forthcoming). *Making Job Tasks Measurable in Job Advertisements: An Iterative Qualitative-Computational Workflow Based on Natural Language Processing*. In Nikolitsa Grigoropoulou, Betina Hollstein, and Mario L. Small (eds.), *The Role of Qualitative Methods in the Data Revolution*.

The repository contains the Python and Stata code used in the research. The Python code implements the extraction of job tasks from online job advertisements, while the Stata code is used for the subsequent quantitative analysis.

## Repository structure

The repository contains two main components, corresponding to the two stages of the research workflow:

```text
.
├── verb_object_extraction_code/
│   └── Python code for job task extraction
├── analysis_code/
│   └── Stata code for quantitative analysis
├── requirements.txt
└── README.md
```

### `verb_object_extraction_code/` — Python code

This folder contains the Python code used to extract job tasks from online job advertisements. The approach identifies verb-object structures in job advertisement texts as a basis for measuring job tasks.

The folder also contains a small sample of **50 anonymized job advertisement texts** that can be used to demonstrate the application of the extraction procedure. The sample was drawn from the [GOJA dataset](https://github.com/KruegerETRF/GOJA).

The sample is intended solely to demonstrate the application and workflow of the Python code. It does not constitute the complete dataset used in the research.

### `analysis_code/` — Stata code

This folder contains the Stata code used for the subsequent quantitative analysis of the extracted job tasks and for producing the results reported in the paper.

The Stata code relies on the research data and analysis files associated with the study. These data are not included in this repository.


## Python requirements

The Python code was developed using the packages listed in `requirements.txt`.

The main dependencies include:

* `spaCy`
* `pandas`
* `numpy`
* `regex`
* `germalemma`
* `compound_split`

The versions used for the analysis are specified in `requirements.txt`.

## Installation

Clone the repository:

```bash
git clone https://github.com/TM4VETR/job_task_measure_oja.git
cd job_task_measure_oja
```

Create a Python environment and install the required packages:

```bash
pip install -r requirements.txt
```

For reproducibility, we recommend using the package versions specified in `requirements.txt`.

## Usage

The repository contains code for two main stages of the research workflow: (1) the extraction of job tasks from online job advertisements using Python and (2) the subsequent quantitative analysis using Stata.

### Python: Job task extraction

The Python code is located in:

```text
verb_object_extraction_code/
```

It implements the procedure for extracting job tasks from online job advertisements based on verb-object structures.

The included sample of 50 anonymized job advertisement texts can be used to run and demonstrate the extraction procedure.

The general workflow is:

```text
Online job advertisements
          │
          ▼
Text preprocessing
          │
          ▼
Verb-object extraction
```

The scripts in `verb_object_extraction_code/` should be run according to the workflow described in the individual scripts and their comments. The required Python packages and versions are listed in `requirements.txt`.

### Stata: Quantitative analysis

The Stata code is located in:

```text
analysis_code/
```

It contains the code used for the quantitative analysis of the extracted job tasks and for producing the results reported in the paper.

The Stata scripts require the corresponding .dta-files which are not included in this repository.

## Reproducibility

The repository documents the computational procedures underlying the research presented in the paper.

The Python code can be run using the sample of 50 anonymized job advertisements included for demonstration purposes.

The Stata code documents the quantitative analyses conducted using the research data. Because the underlying research data are not included in this repository, the complete analysis cannot necessarily be reproduced from the repository alone.

## Citation

If you use this code in your research, please cite the associated paper and, once available, the archived software release.

**Paper:**

> Schulz, Wiebke, Johanna Binnewitt, Timo Wiesner, and Stefan Winnige (forthcoming). *Making Job Tasks Measurable in Job Advertisements: An Iterative Qualitative-Computational Workflow Based on Natural Language Processing*. In Nikolitsa Grigoropoulou, Betina Hollstein, and Mario L. Small (eds.), *The Role of Qualitative Methods in the Data Revolution*.

**Code:**

The persistent DOI for the version of the code accompanying the paper will be provided here.

## License

The code is released under the MIT Licence.

## Contact

For questions regarding the code or the research, please contact the authors of the associated paper.
