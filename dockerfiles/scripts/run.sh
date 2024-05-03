#!/bin/bash
cd /home/scripts
# Initialize Conda environment
eval "$(conda shell.bash hook)"

# Activate the miND Conda environment
conda activate miND
export INPUTPATH="$1"
export OUTPUTPATH="$2"
export sample
# Run Snakemake
snakemake --use-conda \
          --conda-prefix=$CONDA_PREFIX \
          --conda-frontend=mamba \
          --rerun-incomplete \
          --restart-times=1 \
          --cores all