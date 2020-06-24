#!/bin/bash

prefix=$1
reads=$2
name=$3

##python_2.7.16 

/bioinfo/local/build/pacbio-smrtlink/app_v4.0/smrtcmds/bin/python /bioinfo/local/build/pacbio-smrtlink/app_v4.0/install/smrtlink-release_7.0.1.66975/bundles/smrttools/install/smrttools-release_7.0.1.66768/private/pacbio/pythonpkgs/pbreports/lib/python2.7/site-packages/pbreports/report/subreads_reports.py $2 $1_subreads_reports.json

mkdir $3
mv loading_xml/ $3
mv filter_stats_xml/ $3
mv adapter_xml/ $3
mv control/ $3
