#!/bin/bash


##################
## Create "Overviw config" for multicq ==> !!! TODO: should add to mqc_header
##################

## cat all "*.overview.txt" and then take onle one line ( all lignes are the same)
 
string_overview=""
for i in $(ls -1 makeReport/*_overview.txt); do string_overview=$string_overview" "${i%%/}; done
IFS=', ' read -r -a array <<< $(cat $string_overview | grep -v "Run_Name"|sort|uniq)


printf '%s\n  %s%s\n  %s%s\n  %s%s\n  %s%s\n  %s%s\n' 'report_header_info:' '- Run Name: ' ${array[0]} '- Run Id: ' ${array[1]} '- Instrument: Sequel ' ${array[4]} '- Run Date: ' ${array[2]} '- CreatedBy: ' ${array[3]} > multiqc_config_overview.yaml

##########
## Create commend line for multiqc
##########

## Put plots in alphabetical order to show them in order
string_img=""
for i in $(ls -1 subreads_reports/ | sort -t'_' -n -k2); do string_img=$string_img" ""subreads_reports/"${i%%/}; done

multiqc makeReport/* $string_img -f -c multiqc_config_overview.yaml -c multiqc_config_image.yaml

