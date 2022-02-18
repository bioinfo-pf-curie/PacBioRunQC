#!/bin/bash

reads=$1
name=$2

if [ $3 = 1 ] ### if ccs is done on instrument is true
then
mkdir $name
#/bioinfo/local/build/pacbio-smrtlink/app_v4.0/smrtcmds/bin/runqc-reports $reads -o $name --log-level INFO --log-file "$name".log > $name/"$name".txt

runqc-reports $reads -o $name --log-level INFO --log-file "$name".log > $name/"$name".txt
rm $name/*_thumb.png
rm *.log ccs.report.json


else
########
mkdir adapter_xml
python3 -m pbreports.report.adapter_xml --log-level INFO --optional $reads adapter_xml.json
mv adapter_xml.json adapter_xml
mv interAdapterDist0.* adapter_xml

#########
mkdir control
python3 -m pbreports.report.control --log-level INFO --optional $reads control.json
mv control.json control
mv readlength_plot.* control
mv concordance_plot.* control

#########
mkdir loading_xml
python3 -m pbreports.report.loading_xml --log-level INFO --optional $reads loading_xml.json
mv loading_xml.json loading_xml
mv raw_read_length_plot.* loading_xml

#########
mkdir filter_stats_xml
python3 -m pbreports.report.filter_stats_xml --log-level INFO --optional $reads filter_stats_xml.json
mv filter_stats_xml.json filter_stats_xml
mv readLenDist0.* filter_stats_xml
mv subread_lengths.* filter_stats_xml
mv nsertLenDist0.* filter_stats_xml
mv hexbin_length_plot.* filter_stats_xml
mv base_yield_plot.* filter_stats_xml

########
mkdir $name
mv loading_xml/ $name
mv filter_stats_xml/ $name
mv adapter_xml/ $name
mv control/ $name

fi
