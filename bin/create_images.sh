#!/bin/bash

name=$1


### filter_stat

convert $1/filter_stats_xml/insertLenDist0.png -gravity North -pointsize 80 -draw "text -30,10 'Estimated Insert Length'" insertLenDist0.png
convert $1/filter_stats_xml/readLenDist0.png -gravity North -pointsize 80 -draw "text -30,10 'Polymerase Read Length'" readLenDist0.png
convert $1/filter_stats_xml/subread_lengths.png -gravity North -pointsize 80 -draw "text -30,10 'Subread Length'" subread_lengths.png
convert $1/filter_stats_xml/base_yield_plot.png -gravity North -pointsize 80 -draw "text -30,10 'Base Yield Density'" base_yield_plot.png
convert $1/filter_stats_xml/hexbin_length_plot.png -gravity North -pointsize 80 -draw "text -30,10 'Insert Length Versus Read Length'" hexbin_length_plot.png

###### Loading

convert $1/loading_xml/raw_read_length_plot.png -gravity North -pointsize 80 -draw "text -30,10 'Loading Evaluation'" raw_read_length_plot.png

###### control

convert $1/control/concordance_plot.png -gravity North -pointsize 80 -draw "text -30,10 'Control Concordance'" concordance_plot.png
convert $1/control/readlength_plot.png -gravity North -pointsize 80 -draw "text -30,10 'Control Polymerase RL'" readlength_plot.png

###### final image

convert raw_read_length_plot.png readLenDist0.png subread_lengths.png -append mqc_1_bis.png
convert insertLenDist0.png hexbin_length_plot.png -append mqc_2_bis.png
convert base_yield_plot.png readlength_plot.png  concordance_plot.png -append mqc_3_bis.png
convert mqc_1_bis.png mqc_2_bis.png mqc_3_bis.png +append $1_mqc.png

rm insertLenDist0.png readLenDist0.png subread_lengths.png base_yield_plot.png hexbin_length_plot.png concordance_plot.png readlength_plot.png raw_read_length_plot.png 
rm  mqc_1_bis.png mqc_2_bis.png mqc_3_bis.png

