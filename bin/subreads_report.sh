#!/bin/bash

prefix=$1
reads=$2
name=$3

##python_2.7.16 

#subreads_reports.py $2 $1_subreads_reports.json

#########
mkdir adapter_xml
/bioinfo/local/build/pacbio-smrtlink/app_v4.0/smrtcmds/bin/python3 -m pbreports.report.adapter_xml --log-level INFO --optional $2 adapter_xml.json
mv adapter_xml.json adapter_xml
mv interAdapterDist0.* adapter_xml

#########
mkdir control
/bioinfo/local/build/pacbio-smrtlink/app_v4.0/smrtcmds/bin/python3 -m pbreports.report.control --log-level INFO --optional $2 control.json
mv control.json control
mv readlength_plot.* control
mv concordance_plot.* control

#########
mkdir loading_xml/
/bioinfo/local/build/pacbio-smrtlink/app_v4.0/smrtcmds/bin/python3 -m pbreports.report.loading_xml --log-level INFO --optional $2 loading_xml.json
mv loading_xml.json loading_xml
mv raw_read_length_plot.* loading_xml

#########
mkdir filter_stats_xml
/bioinfo/local/build/pacbio-smrtlink/app_v4.0/smrtcmds/bin/python3 -m pbreports.report.filter_stats_xml --log-level INFO --optional $2 filter_stats_xml.json
mv filter_stats_xml.json filter_stats_xml
mv readLenDist0.* filter_stats_xml
mv subread_lengths.* filter_stats_xml
mv nsertLenDist0.* filter_stats_xml
mv hexbin_length_plot.* filter_stats_xml
mv base_yield_plot.* filter_stats_xml

########
mkdir $3
mv loading_xml/ $3
mv filter_stats_xml/ $3
mv adapter_xml/ $3
mv control/ $3
