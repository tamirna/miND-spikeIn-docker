#!/usr/bin/env bash

source ~/.bashrc

if [[ -f "~/miniconda3/etc/profile.d/conda.sh" ]]; then
    source ~/miniconda3/etc/profile.d/conda.sh
fi

# run snakemake and archive the workflow
if [[ $(type -P "conda") ]]; then
  printf "Conda path is set\n"
else
  printf "Conda path no set, adding to PATH variable\n"
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh
  bash ~/miniconda.sh -u -b
  export PATH="$HOME/miniconda3/bin:$PATH"
  ~/miniconda3/bin/conda init
fi

source ~/miniconda3/etc/profile.d/conda.sh

ENVNAME="miND"

if [[ -f "~/repository/hairpin.fa" && -f "~/repository/mature.fa" ]]; then
  printf "mirBase reference already existing!\n"
else
  printf "downloading new reference from mirbase and processing it..."
  # download latest mature and hairpin sequences
  wget --no-check-certificate -O - https://www.mirbase.org/download/mature.fa | seqtk seq -l0 - > mature.fa
  wget --no-check-certificate -O - https://www.mirbase.org/download/hairpin.fa | seqtk seq -l0 - > hairpin.fa
  ##Separate lines, newline instead of breaks, remove html tag paragraph, filter for "hsa", introduce bigger sign with newline
  awk -v RS=';' '1' mature.fa | sed 's/<br>&gt/\n/g' | sed 's/<br>/\n/g' | sed 's/<\/p>//g' | grep -A 1 --no-group-separator 'hsa' | sed 's/^hsa/>hsa/' > mature.filtered.fa
  awk -v RS=';' '1' hairpin.fa | sed 's/<br>&gt/\n/g' | sed 's/<br>/\n/g' | sed 's/<\/p>//g' | grep -A 1 --no-group-separator 'hsa' | sed 's/^hsa/>hsa/' > hairpin.filtered.fa
  ##Replace "U" with "T"
  awk 'BEGIN{RS=">";FS="\n"}NR>1{printf ">%s\n",$1; for (i=2;i<=NF;i++) {gsub(/U/,"T",$i); printf "%s\n",$i}}' mature.filtered.fa | seqtk seq -l0 > mature.filtered.dna.fa
  awk 'BEGIN{RS=">";FS="\n"}NR>1{printf ">%s\n",$1; for (i=2;i<=NF;i++) {gsub(/U/,"T",$i); printf "%s\n",$i}}' hairpin.filtered.fa | seqtk seq -l0 > hairpin.filtered.dna.fa
fi
