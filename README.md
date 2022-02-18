# **PacBioRunQC**

**Institut Curie - Nextflow PacBio Run_QC analysis pipeline**


[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.32.0-brightgreen.svg)](https://www.nextflow.io/)
[![Generic badge](https://img.shields.io/badge/SMRTLink->7.0.0-red.svg)](https://github.com/PacificBiosciences/pbreports/)
[![MultiQC](https://img.shields.io/badge/MultiQC->1.7-blue.svg)](https://multiqc.info/)


### **Introduction**
   
The main goal of the `PacBioRunQC` pipeline is to perform quality controls on long reads sequencing reads (PacBio), regardless the sequencing application.
It was designed to help sequencing facilities to validate the quality of the generated data.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. 

### **Pipline summary**

1. Use SMRT Link’s Run QC module to monitor performance trends and perform run QC remotely ([`pbreports`](https://github.com/PacificBiosciences/pbreports))
2. Present all QC results in a final report ([`MultiQC`](http://multiqc.info/))


### **Quick help**

```bash
N E X T F L O W  ~  version 19.04.0
Launching `main.nf` [cheesy_fermi] - revision: 8038a4770c
PacBioRunQC v1.0dev
=======================================================
Usage:
nextflow run main.nf --dataSet dataSet
nextflow run main.nf --samplePlan sample_plan

Mandatory arguments:
   --dataSet 'SUBREADSET'        Path to input data set
   --samplePlan 'SAMPLEPLAN'     Path to sample plan input file (cannot be used with --reads)
   -profile PROFILE              Configuration profile to use. test

Other options:
   --outdir 'PATH'               The output directory where the results will be saved
   -name 'NAME'                  Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic
   --metadata 'FILE'             Add metadata file for multiQC report

Skip options:
   --skip_oiccs      		 Skip automatic HiFi reads generation with Sequel IIe 
   --skip_multiqc                Skip MultiQC step
   
==========================================================
Available Profiles
   -profile test                Set up the test dataset

```

</br>

### **Quick run**

The pipeline can be run on any infrastructure from a list of input files or from a sample plan as follow


#### Run the pipeline on the test dataset
See the conf/test.conf to set your test dataset.

```
nextflow run main.nf -profile singularity,test --singularityImagePath SANGULARITYIMAGE_PATH

```

Run the pipeline from a sample plan:

```
nextflow run main.nf --samplePlan MY_SAMPLE_PLAN --outdir MY_OUTPUT_DIR

```


Run the pipeline on a cluster:

```
echo "nextflow run main.nf --dataSet MY_DATASET --outdir MY_OUTPUT_DIR" | qsub -N RunQC

```


### **Documentation**

1. [Running the pipeline](docs/usage.md)
2. [Output and how to interpret the results](docs/output.md)
3. [Troubleshooting](docs/troubleshooting.md)


### **Credits**

This pipeline has been set up and written by the sequencing facility and the bioinformatics platform of the Institut Curie \
(T. Alaeitabar, S. Baulande, S. Lameiras, N. Servant)


### **Contacts**

For any question, bug or suggestion, please, contact the bioinformatics core facility.

