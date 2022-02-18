#!/bin/bash

name=$1

if [ $2 = 1 ] #### if ccs is done on instrument is true
then
convert $name/readlength_plot.png $name/concordance_plot.png $name/readLenDist0.png +append mqc_1_bis.png
convert $name/base_yield_plot.png $name/ccs_npasses_hist.png $name/ccs_accuracy_hist.png +append mqc_2_bis.png
convert $name/ccs_readlength_hist.png $name/raw_read_length_plot.png $name/all_readlength_hist.png +append mqc_3_bis.png
convert $name/hexbin_length_plot.png $name/readlength_qv_hist2d.hexbin.png +append mqc_4_bis.png
convert mqc_1_bis.png -resize 1600x1600 mqc_1.png
convert mqc_2_bis.png -resize 1600x1600 mqc_2.png
convert mqc_3_bis.png -resize 1600x1600 mqc_3.png
convert mqc_4_bis.png -resize 1300x1300 mqc_4.png
convert mqc_1.png mqc_2.png mqc_3.png mqc_4.png -append $name/"$name"_mqc.png
rm *.png

else
### filter_stat

convert $name/filter_stats_xml/insertLenDist0.png -gravity North -pointsize 80 -draw "text 0,100 'Estimated Insert Length'" insertLenDist0.png
convert $name/filter_stats_xml/readLenDist0.png -gravity North -pointsize 80 -draw "text 0,100 'Polymerase Read Length'" readLenDist0.png
convert $name/filter_stats_xml/subread_lengths.png -gravity North -pointsize 80 -draw "text 0,100 'Subread Length'" subread_lengths.png
convert $name/filter_stats_xml/base_yield_plot.png -gravity North -pointsize 80 -draw "text 0,100 'Base Yield Density'" base_yield_plot.png
convert $name/filter_stats_xml/hexbin_length_plot.png -gravity North -pointsize 80 -draw "text 0,100 'Insert Length Versus Read Length'" hexbin_length_plot.png

###### Loading

convert $name/loading_xml/raw_read_length_plot.png -gravity North -pointsize 80 -draw "text 0,100 'Loading Evaluation'" raw_read_length_plot.png

###### control

convert $name/control/concordance_plot.png -gravity North -pointsize 80 -draw "text 0,100 'Control Concordance'" concordance_plot.png
convert $name/control/readlength_plot.png -gravity North -pointsize 80 -draw "text 0,100 'Control Polymerase RL'" readlength_plot.png

###### final image

convert raw_read_length_plot.png readLenDist0.png subread_lengths.png -append mqc_1_bis.png
convert insertLenDist0.png hexbin_length_plot.png -append mqc_2_bis.png
convert base_yield_plot.png readlength_plot.png  concordance_plot.png -append mqc_3_bis.png
convert mqc_1_bis.png mqc_2_bis.png mqc_3_bis.png +append $name/"$name"_mqc.png
rm insertLenDist0.png readLenDist0.png subread_lengths.png base_yield_plot.png hexbin_length_plot.png concordance_plot.png readlength_plot.png raw_read_length_plot.png 
rm  mqc_1_bis.png mqc_2_bis.png mqc_3_bis.png

fi
