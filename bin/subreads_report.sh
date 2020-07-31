#!/bin/bash

prefix=$1
reads=$2
name=$3

##python_2.7.16 

subreads_reports.py $2 $1_subreads_reports.json

mkdir $3
mv loading_xml/ $3
mv filter_stats_xml/ $3
mv adapter_xml/ $3
mv control/ $3
