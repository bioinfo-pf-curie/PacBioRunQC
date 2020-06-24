# curie/RUN QC: Usage

## Table of contents

* [General Nextflow info](#general-nextflow-info)
* [Running the pipeline](#running-the-pipeline)
* [Main arguments](#main-arguments)
    * [`profile`](#profile)
    * [`dataSet`](#dataset)
* [Other command line parameters](#other-command-line-parameters)
    * [`skip_multiqc`](#other-command-line-parameters)
    * [`outdir`](#outdir)
    * [`name`](#name)
    * [`resume`](#resume)
    * [`c`](#c)
    * [`max_memory`](#max_memory)
    * [`max_time`](#max_time)
    * [`max_cpus`](#max_cpus)

## General Nextflow info
Nextflow handles job submissions on SLURM or other environments, and supervises running the jobs. Thus the Nextflow process must run until the pipeline is finished. We recommend that you put the process running in the background through `screen` / `tmux` or similar tool. Alternatively you can run nextflow within a cluster job submitted your job scheduler.

It is recommended to limit the Nextflow Java virtual machines memory. We recommend adding the following line to your environment (typically in `~/.bashrc` or `~./bash_profile`):

```bash
NXF_OPTS='-Xms1g -Xmx4g'
```
## Running the pipeline
The typical command for running the pipeline is as follows:

```bash
nextflow run main.nf -profile test
```


Note that the pipeline will create the following files in your working directory:

```bash
work            # Directory containing the nextflow working files
results         # Finished results (configurable, see below)
.nextflow_log   # Log file from Nextflow
# Other nextflow hidden files, eg. history of pipeline runs and old logs.
```

## Main arguments

### `-profile`
Use this parameter to choose a configuration profile. Profiles can give configuration presets for different compute environments. Note that multiple profiles can be loaded, for example: `-profile singularity` - the order of arguments is important!

If `-profile` is not specified at all the pipeline will be run locally and expects all software to be installed and available on the `PATH`.

* `test`
    * A profile with a complete configuration for automated testing
    * Includes links to test data so needs no other parameters


### `--dataSet`
Use this to specify the location of your input SubreadSet XML dataset, which contains one or more BAM files containing the raw unaligned subreads. For example:

```bash
--dataSet 'path/to/dataset'
```
where the following files exist:
<filename>.subreadset.xml
<filename>.adapters.fasta
<filename>.scraps.bam
<filename>.sts.xml
<filename>.subreads.bam.pbi
<filename>.metadata.xml
<filename>.scraps.bam.pbi
<filename>.subreads.bam


Please note that the path must be enclosed in quotes.

## Other command line parameters

The pipeline contains diffrent steps. Sometimes, it may not be desirable to run all of them if time and compute resources are limited.
The following options make this easy:

* `--skip_multiqc` -     Skip MultiQC step

## Job resources

### Automatic resubmission

Each step in the pipeline has a default set of requirements for number of CPUs, memory and time. For most of the steps in the pipeline, if the job exits with an error code of `143` (exceeded requested resources) it will automatically resubmit with higher requests (2 x original, then 3 x original). If it still fails after three times then the pipeline is stopped.

### Custom resource requests

Wherever process-specific requirements are set in the pipeline, the default value can be changed by creating a custom config file. See the files hosted at [`RUN QC/configs`](https://github.com/git/raw-qc/conf) for examples.

Please make sure to also set the `-w/--work-dir` and `--outdir` parameters to a S3 storage bucket of your choice - you'll get an error message notifying you if you didn't.

### `--outdir`

The output directory where the results will be saved.

### `--name`

Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic.

This is used in the MultiQC report (if not default).

**NB:** Single hyphen (core Nextflow option)

### `-resume`

Specify this when restarting a pipeline. Nextflow will used cached results from any pipeline steps where the inputs are the same, continuing from where it got to previously.

You can also supply a run name to resume a specific run: `-resume [run-name]`. Use the `nextflow log` command to show previous run names.

**NB:** Single hyphen (core Nextflow option)

### `-c`

Specify the path to a specific config file (this is a core NextFlow command).

Note - you can use this to override pipeline defaults.

### `--max_memory`

Use to set a top-limit for the default memory requirement for each process.
Should be a string in the format integer-unit. eg. `--max_memory '8.GB'`

### `--max_time`

Use to set a top-limit for the default time requirement for each process.
Should be a string in the format integer-unit. eg. `--max_time '2.h'`

### `--max_cpus`

Use to set a top-limit for the default CPU requirement for each process.
Should be a string in the format integer-unit. eg. `--max_cpus 1`



