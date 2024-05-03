FROM continuumio/miniconda3 AS build

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH "$HOME/opt/miniconda3/bin:$PATH"
ARG PATH="$HOME/opt/miniconda3/bin:$PATH"

RUN apt-get update --fix-missing && \
    apt-get install -yqq --no-install-recommends wget ca-certificates curl git tree nano htop && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /opt/conda && \
    wget https://repo.continuum.io/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh -O /opt/conda/miniconda.sh && \
    bash /opt/conda/miniconda.sh -b -p /opt/miniconda

COPY ./dockerfiles/ /home/
RUN chmod -R +x /home/

RUN conda init bash && \
    . /root/.bashrc && \
    conda install -c conda-forge -c bioconda mamba snakemake -y && \
    mamba env create --file /home/scripts/environment.yml && \
    conda activate miND

CMD ./home/scripts/run.sh;
