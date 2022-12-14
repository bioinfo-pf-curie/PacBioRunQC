### **Output**

This document describes the outputs produced by the pipeline. All the plots are taken from the MultiQC report, which summarises results at the end of the pipeline.

### **Pipeline overview**

The pipeline is built using [Nextflow](https://www.nextflow.io/)
and processes data using the following steps:

* [RUN_QC](#SMART Link RUN QC ) - monitor performance trends and perform Run QC
* [MultiQC](#multiqc) - aggregate report, describing results of the whole pipeline

### RUN QC

The goal of curie/RUN QC pipeline is to assess the overall quality of the long reads sequencing (PacBio).

The run directory output by the Sequel IIe System includes a subdirectory for each collection (SMRT Cell) associated with a sample well. The option for generate automatically HiFi Reads is one of the main advantages of Sequel IIe System. Sequel IIe System on_instrument CCS (OICCS) outputs a reads.bam file containing one read per productive ZMW and the subreads.bam, scraps.bam and scraps.bam.pbi files are no longer generated or available. In the The collection subdirectory includes the following output files:


   |    output | skip_OICCS | OICCS|
| ------ | ------ | ------ |
| `<filename>`.subreadset.xml | &#x2611;       | |
| `<filename>`.adapters.fasta  | &#x2611;      | |
| `<filename>`.subreadset.bam | &#x2611;       | |
| `<filename>`.subreadset.bam.pbi  | &#x2611;  | |
| `<filename>`.metadata.xml | &#x2611;         | |
| `<filename>`.scraps.bam| &#x2611;            | |
| `<filename>`.scraps.bam.pbi | &#x2611;       | |
| `<filename>`.sts.xml  | &#x2611; | &#x2611;|
| `<filename>`.consensusreadset.xml | | &#x2611;|
| `<filename>`.reads.bam  |  | &#x2611;|
| `<filename>`.reads.bam.pbi | | &#x2611;|
| `<filename>`.zmw_metrics.json.gz |  | &#x2611;|
| `<filename>`.ccs.log |  | &#x2611;|
| `<filename>`.ccs.reports.json | | &#x2611;|
| `<filename>`.ccs.reports.txt |  | &#x2611;|

> **NB:** The reads.bam file contains HiFi reads and should not be used unfiltered as input for tools that expected >=Q20 sequencing data.



###  MultiQC

[MultiQC](http://multiqc.info) is a visualisation tool that generates a single HTML report summarising all samples in your project. Most of the pipeline QC results are visualised in the report and further statistics are available in within the report data directory.

The pipeline has special steps which allow the software versions used to be reported in the MultiQC output for future traceability.

**Output directory: `results/multiqc`**

* `PacBioRunQC_report.html`
    * MultiQC report - a standalone HTML file that can be viewed in your web browser
* `multiqc_data/`
    * Directory containing parsed statistics from the different tools used in the pipeline

> **NB:** The MultiQC plots displayed Only if `skip_multiqc` has not been specified. 

For more information about how to use MultiQC reports, see http://multiqc.info


### Short comprehension passage of plots
The output contains plots of an individual SMRT Cell. Clicking on an individual plot displays an expanded view. These plots include:
</br>

|  Description      |  plot  |
| ------ | ------ |
|<span style="color:blue; text-align:center; vertical-align: center">**Productivity graph** <span style="color:black; text-align:center; vertical-align: center"> compares 'typical' values for the different productivity levels. <ul><li>**P0:** &nbsp;  Empty ZMW; no signal detected.</li><li>**P1:** &nbsp; ZMW with a high quality read detected. </li><li>**P2:** &nbsp; Other, signal detected but no high quality read.</li></ul>| [<img src="plots/productivity.png" width="500"/>](plots/productivity.png)|
|<span style="color:blue; text-align:center; vertical-align: center">**Polymerase Read Length**<span style="color:black; text-align:center; vertical-align: center"> plots the number of reads against the polymerase read length. Polymerase read represents a sequence of nucleotides incorporated by the DNA polymerase while reading a template, such as a circular SMRTbell??? template.| [<img src="plots/readLenDist0.png" width="500"/>](plots/readLenDist0.png)|
|<span style="color:blue; text-align:center; vertical-align: center">**Subraed Length**<span style="color:black; text-align:center; vertical-align: center; "> plots the number of reads against the against the subread length, in base pairs. Subread contain a sequence from a single pass of a polymerase on a single strand of an insert within a SMRTbell??? template and no adapter sequences.| [<img src="plots/subread_lengths.png" width="500"/>](plots/subread_lengths.png)| 
|<span style="color:blue; text-align:center; vertical-align: center">**Estimated Insert Length**<span style="color:black; text-align:center; vertical-align: center; "> plots the number of reads against the estimated insert length. The Insert Size is the length of the double-stranded nucleic acid fragment in a SMRTbell template, excluding the hairpin adapters.| [<img src="plots/insertLenDist0.png" width="500"/>](plots/insertLenDist0.png)| 
|<span style="color:blue; text-align:center; vertical-align: center">**Control Polymerase RL**<span style="color:black; text-align:center; vertical-align: center; "> displays the Polymerase read length distribution of the control, if used| [<img src="plots/readlength_plot.png" width="500"/>](plots/readlength_plot.png)| 
|<span style="color:blue; text-align:center; vertical-align: center">**Control Concordance**<span style="color:black; text-align:center; vertical-align: center; "> maps control reads against the known control reference and reports the concordance | [<img src="plots/concordance_plot.png" width="500"/>](plots/concordance_plot.png)|
|<span style="color:blue; text-align:center; vertical-align: center">**Loading Evaluation**<span style="color:black; text-align:center; vertical-align: center; "> displays the length distribution of unfiltered and filtered (polymerase) reads.| [<img src="plots/raw_read_length_plot.png" width="500"/>](plots/raw_read_length_plot.png)| 
|<span style="color:blue; text-align:center; vertical-align: center">**Base ??ield Density**<span style="color:black; text-align:center; vertical-align: center; "> displays the number of bases sequenced in the collection, according to the length of the read in which they were observed. Regions of the graph corresponding to bases found in reads  longer than the N50 and N95 values are shaded in medium and dark blue, respectively.| [<img src="plots/base_yield_plot.png" width="500"/>](plots/base_yield_plot.png)|
|<span style="color:blue; text-align:center; vertical-align: center">**Insert Length Versus Read Length** <span style="color:black; text-align:center; vertical-align: center; "> displays a density plot of reads, hexagonally binned according to their HQ Read Length and median subread length. For very large insert libraries, most reads consist of a single subread and will fall along the diagonal. For shorter inserts, subreads will be shorter than the HQ read length, and will appear as horizontal features.| [<img src="plots/hexbin_length_plot.png" width="500"/>](plots/hexbin_length_plot.png)|
  

For more information see here https://www.pacb.com/support/documentation/
