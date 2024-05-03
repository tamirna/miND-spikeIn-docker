# miND-spikeIn analysis container
This repository contains a dockerized Snakemake workflow designed for processing trimmed and quality filtered FASTQ files for the analysis of MIND® spike-ins. 
#
## Overview

This repository contains a dockized Snakemake workflow designed for processing trimmed and quality filtered FASTQ files. The workflow takes an input directory containing only uncompressed FASTQ files and produces results in a specified output directory. Output includes quantification files of miRNAs (based on miRDeep2) and MIND® spike-ins, which can be used for further analysis and absolute quantification of miRNAs. For more details, see [miRDeep2 on GitHub](https://github.com/rajewsky-lab/mirdeep2) and [MIND® spike-ins concentrations](https://github.com/tamirna/mind-spike-in-concentrations).

## Prerequisites
- Docker installed on your system. For more information visit the [docker website](www.docker.com).
- (for build) git installed on your system
- Hardware: We recommend at least 4 CPU-cores for a smooth experience with this pipeline. Ensure you have enough disk space for the results and your input files.
- A set of **trimmed, quality filtered, and uncompressed** FASTQ format files placed in a designated input directory.

## Reference
The Spike-In analysis inputs are fastq files and a human reference genome downloaded from [mirbase](https://www.mirbase.org/download/). Addtional references can be downloaded there. Current version: Release 22.1 - species: Homo sapiens
The latest version can be easily build by using the  **build.sh** script under ```dockerfiles/repository/```.

## Workflow
The workflow is designed to use configuration variables for the reference repository and adapter sequence. It starts by checking the input folder for any file that ends with **'.fastq.gz', '.fq.gz', '.fastq', '.fq'** and creates a list of inputs. These filenames will be used for the tables and the report.

The workflow consists of a Snakemake file which includes the configuration for a standard run.
Parameters like:
```yaml
'repoPath': "../repository/", # Path to the reference genome 
'adapter': 'AGATCGGAAGAG',  # Library Adapter sequence here (Illumina Universal Adapter)
```
Key steps in this workflow are:

Read preprocessing with miRDeepPrep: Prepares miRNA sequences by collapsing similar reads using [**mapper.pl**](https://github.com/rajewsky-lab/mirdeep2/blob/master/src/mapper.pl), optimizing data for downstream analysis.

Expression quantification miRNA with miRDeep2: Analyzes miRNA expression using [**quantifier.pl**](https://github.com/rajewsky-lab/mirdeep2/blob/master/src/quantifier.pl) on collapsed reads against specified miRNA and genome references to quantify expression levels.

Spike-in Control Analysis: Utilizing [**bbduk.sh**](https://github.com/BioInfoTools/BBMap/blob/master/sh/bbduk.sh) to handle control spike-ins, crucial for validating experimental integrity.

Spike-in Control Analysis: Utilizes bbduk.sh to filter and analyze spike-in controls, ensuring data integrity and experimental quality by adjusting for known quantities of artificially introduced sequences.

Data Sorting and Collapsing: R script for organizing the mapping results by specific criteria and collapse reads, optimizing data for further downstream analysis with [miND-spikein-report script](https://github.com/tamirna/miND-spikein-report).

## Getting Started

### 1.0 The Docker image (build)
Quick start if your are using the terminal:
```bash
git clone https://github.com/tamirna/mind-spikein-docker.git
cd mind-spikein-docker
docker build --tag=mind-spikein-public .
```
otherwise you can also download and unzip this repository.

### 1.1 Download the Docker image or build it yourself
The Docker image can be downloaded via GitHub and versioned in this repository. To load the image into your Docker environment, use:

```bash
docker load < mind-spikein-public.tar.gz
```
For more information, please refer to the official Docker [documentation](https://docs.docker.com/engine/reference/commandline/load/).

### 2. Prepare Your Input Data
Ensure that your trimmed and quality filtered FASTQ files are placed in a single directory. This directory will be used as the input for the workflow. Additionally, create a separate output directory for the results.

### 3. Running the Workflow
Executing the Workflow
To execute the [Snakemake](https://snakemake.readthedocs.io/en/stable/) workflow inside the Docker container, input and output directories are required. Use the following command to provide the correct parameters and view container logs:
```bash
docker run -d -it --name mind-spikein-public-container --mount type=bind,source="/path/to/input",target=/home/inputfiles --mount type=bind,source="/path/to/output",target=/home/output mind-spikein-public | xargs docker logs -f
```
Replace **/path/to/input** and **/path/to/output** with the paths to your input directory (containing the trimmed FASTQ files) and the desired output directory, respectively.

### 4. Output
The workflow's output will be stored in the specified output directory. This includes processed data files, logs, and any other results generated by the workflow. The structure should be as follows:

```bash
Project/
├── Input/
│   ├── sample1.fastq
│   └── sample2.fastq
└── Output/
    ├── logs/
    │   └── snakemake.log
    ├── samplename/
    │   ├── expression_default.html
    │   ├── expression_analyses/
    │   │   └── expression_analyses_default/
    │   │       └── mirdeep2_results/
    │   │           └── results.txt  # Placeholder for mirDeep2 results
    │   ├── sample.collapsed.fa  # Results from mirdeep2 mapper.pl
    │   ├── sample.mirnas.csv  # mirDeep2 mapped reads on miRBase
    │   ├── sample.spikeins.txt  # BBMap aligner results with spike-in sequences
    │   └── miRNAs_expressed_all_samples_default.csv  # quantifier.pl results from mirdeep2
    └── sample.csv  # Combined normalized mapping statistic per miRNA from all samples
```

5. Further Processing
The outputs can now be used for further spike-in quality control and concentration analysis. Check out [miND-spikein.R](https://github.com/tamirna/mind-spike-in-concentrations/blob/main/miND-spikein.R).

Troubleshooting
Ensure that the input directory contains only trimmed, filtered, and uncompressed FASTQ files.
Verify that Docker is correctly installed and configured on your system.
Check that the paths to the input and output directories are correctly specified.