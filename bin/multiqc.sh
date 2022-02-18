#!/bin/bash

rtitle=$1
rfilename=$2
mqc_config_header=$3
multiqc_config=$4

export PATH=$PATH:/bioinfo/local/build/Centos/miniconda/miniconda3-4.7.10/bin
#source  activate /data/kdi_prod/project_result/789/07.00/env_conda/rawqc-3.0/
source activate /data/kdi_prod/project_result/789/07.00/env_conda/isoseq-sequel2e-test1/

## Put plots in alphabetical order to show them in order
string_img=""
for i in $(ls -1 subreads_reports/ | sort -t'_' -n -k2); do string_img=$string_img" ""subreads_reports/"${i%%/}; done

multiqc makeReport/* $string_img -f ${rtitle} ${rfilename} -c ${mqc_config_header} -c ${multiqc_config}

