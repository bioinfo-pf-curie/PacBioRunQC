#!/usr/bin/env nextflow

/*
Copyright Institut Curie 2019
This software is a computer program whose purpose is to analyze high-throughput sequencing data (PacBio).
You can use, modify and/ or redistribute the software under the terms of license (see the LICENSE file for more details).
The software is distributed in the hope that it will be useful, but "AS IS" WITHOUT ANY WARRANTY OF ANY KIND.
Users are therefore encouraged to test the software's suitability as regards their requirements in conditions enabling the security of their systems and/or data.
The fact that you are presently reading this means that you have had knowledge of the license and that you accept its terms.
*/


/*
========================================================================================
                         PacBioRunQC
========================================================================================
 PacBioRunQC Pipeline.
 #### Homepage / Documentation
 https://https://gitlab.curie.fr/ngs-research/pacbio-smrtlink
----------------------------------------------------------------------------------------
*/


def helpMessage() {
    if ("${workflow.manifest.version}" =~ /dev/ ){
       dev_mess = file("$baseDir/assets/dev_message.txt")
       log.info dev_mess.text
    }

    log.info"""
    PacBioRunQC v${workflow.manifest.version}
    ==========================================================

    Usage:
    nextflow run main.nf --dataSet '*.subreadset.xml'
    nextflow run main.nf --samplePlan sample_plan

    Mandatory arguments:
      --dataSet 'SUBREADSET'        Path to input data set (must be surrounded with quotes)
      --samplePlan 'SAMPLEPLAN'     Path to sample plan input file (cannot be used with --reads)
      -profile PROFILE              Configuration profile to use. test

    Other options:
      --outdir 'PATH'               The output directory where the results will be saved
      -name 'NAME'                  Name for the pipeline run. If not specified, Nextflow will automatically generate a random mnemonic
      --metadata 'FILE'             Add metadata file for multiQC report

    Skip options:
      --skip_OICCS                  Skip Automatic HiFi reads generation with Sequel IIe
      --skip_multiqc                Skip MultiQC step

    =======================================================
    Available Profiles

      -profile test                Set up the test dataset
    """.stripIndent()
}

println "Project : $workflow.workDir"
// Show help emssage
if (params.help){
    helpMessage()
    exit 0
}

// Has the run name been specified by the user?
//  this has the bonus effect of catching both -name and --name
custom_runName = params.name
if( !(workflow.runName ==~ /[a-z]+_[a-z]+/) ){
  custom_runName = workflow.runName
}


// Stage config files
ch_multiqc_config = Channel.fromPath(params.multiqc_config)
ch_output_docs = Channel.fromPath("$baseDir/docs/output.md")

/*
 * CHANNELS
*/
if ((params.dataSet && params.samplePlan) || (params.dataSet && params.samplePlan)){
   exit 1, "Input reads must be defined using either '--dataSet' or '--samplePlan' parameter. Please choose one way"
}


if(params.samplePlan && params.skip_OICCS){
      Channel
         .from(file("${params.samplePlan}"))
         .splitCsv(header: false)
         .map{row -> [
              def name = row[0],
              def dataset = file(row[1] + '.subreadset.xml'),
              def sts = file(row[1] +  '.sts.xml'),
              def reads = file(row[1] +  '.subreads.bam'),
              def reads_pbi = file(row[1] + '.subreads.bam.pbi'),
              def ccs_log = "Sequel2 doesn't generate ccs.",
              def ccs_rep_j = "Sequel2 doesn't generate ccs.",
              def ccs_rep_t = "Sequel2 doesn't generate ccs.",
              def zmw_metrics = "Sequel2 doesn't generate zmw_metrics.",
              def adapters = file(row[1] +  '.adapters.fasta'),
              def scraps = file(row[1] +  '.scraps.bam'),
              def scraps_pbi = file(row[1] +  '.scraps.bam.pbi'),
              ]}
         .set{dataset_files}

         Channel
         .from(file("${params.samplePlan}"))
         .splitCsv(header: false)
         .map{row -> [
              def name = row[0],
              def dataset = file(row[1] + '.subreadset.xml')
              ]}
         .set{read_files_reports}
}
else if(params.dataSet && params.skip_OICCS){
        Channel
            .from(params.dataSet)
            .ifEmpty { exit 1, "params.dataSet was empty - no input files supplied" }
            .map{row -> [
              def name = file(params.dataSet).name.toString().tokenize('.').get(0),
              def dataset = file(params.dataSet + '.subreadset.xml'),
              def sts = file(params.dataSet +  '.sts.xml'),
              def reads = file(params.dataSet +  '.subreads.bam'),
              def reads_pbi = file(params.dataSet + '.subreads.bam.pbi'),
              def ccs_log = "Sequel2 doesn't generate ccs.",
              def ccs_rep_j = "Sequel2 doesn't generate ccs.",
              def ccs_rep_t = "Sequel2 doesn't generate ccs.",
              def zmw_metrics = "Sequel2 doesn't generate zmw_metrics.",
              def adapters = file(params.dataSet +  '.adapters.fasta'),
              def scraps = file(params.dataSet +  '.scraps.bam'),
              def scraps_pbi = file(params.dataSet +  '.scraps.bam.pbi'),
              ]}
         .set{dataset_files}

        Channel
            .from(params.dataSet)
            .map{row -> [
              def name = file(params.dataSet).name.toString().tokenize('.').get(0), 
              def dataset = file(params.dataSet + '.subreadset.xml')
              ]}
         .groupTuple()
         .set{read_files_reports}
}

// For Sequel2e

if(params.samplePlan && !params.skip_OICCS){
      Channel
         .from(file("${params.samplePlan}"))
         .splitCsv(header: false)
         .map{row -> [
              def name = row[0],
              def dataset = file(row[1] + '.consensusreadset.xml'),
              def sts = file(row[1] +  '.sts.xml'),
              def reads = file(row[1] +  '.reads.bam'),
              def reads_pbi = file(row[1] +  '.reads.bam.pbi'),
              def ccs_log = file(row[1] +  '.ccs.log'),
              def ccs_rep_j = file(row[1] +  '.ccs_reports.json'),
              def ccs_rep_t = file(row[1] +  '.ccs_reports.txt'),
              def zmw_metrics = file(row[1] +  '.zmw_metrics.json.gz'),
              def adapters ="Sequel2e doesn't generate adapters.",
              def scraps = "Sequel2e doesn't generate scraps.",
              def scraps_pbi = "Sequel2e doesn't generate scraps_pbi.",              
              ]}
         .set{dataset_files}

         Channel
         .from(file("${params.samplePlan}"))
         .splitCsv(header: false)
         .map{row -> [
              def name = row[0],
              def dataset = file(row[1] + '.consensusreadset.xml')
              ]}
         .set{read_files_reports}
}
else if(params.dataSet && !params.skip_OICCS){
        Channel
            .from(params.dataSet)
            .ifEmpty { exit 1, "params.dataSet was empty - no input files supplied" }
            .map{row -> [
              def name = file(params.dataSet).name.toString().tokenize('.').get(0),
              def dataset = file(params.dataSet + '.consensusreadset.xml'), 
              def sts = file(params.dataSet +  '.sts.xml'),
              def reads = file(params.dataSet +  '.reads.bam'),
              def raeds_pbi = file(params.dataSet + '.reads.bam.pbi'),
              def ccs_log = file(params.dataSet +  '.ccs.log'),
              def ccs_rep_j = file(params.dataSet +  '.ccs_reports.json'),
              def ccs_rep_t = file(params.dataSet +  '.ccs_reports.txt'),
              def zmw_metrics = file(params.dataSet +  '.zmw_metrics.json.gz'),
              def adapters ="Sequel2e doesn't generate adapters.",
              def scraps = "Sequel2e doesn't generate scraps.",
              def scraps_pbi = "Sequel2e doesn't generate scraps_pbi.",
              ]}
         .set{dataset_files}

        Channel
            .from(params.dataSet)
            .map{row -> [
              def name = file(params.dataSet).name.toString().tokenize('.').get(0),
              def dataset = file(params.dataSet + '.consensusreadset.xml')
              ]}
         .groupTuple()
         .set{read_files_reports}
}

//

if ( params.metadata ){
   Channel
       .fromPath( params.metadata )
       .ifEmpty { exit 1, "Metadata file not found: ${params.metadata}" }
       .set { ch_metadata }
}


 
// Header log info
if ("${workflow.manifest.version}" =~ /dev/ ){
   dev_mess = file("$baseDir/assets/dev_message.txt")
   log.info dev_mess.text
}

log.info """=======================================================

PacBioRunQC v${workflow.manifest.version}"
======================================================="""
def summary = [:]
summary['Pipeline Name']  = 'PacBioRunQC'
summary['Pipeline Version'] = workflow.manifest.version
summary['Run Name']     = custom_runName ?: workflow.runName
summary['Metadata']     = params.metadata
if (params.samplePlan) {
   summary['SamplePlan']   = params.samplePlan
}else{
   summary['DataSet']        = params.dataSet
}
summary['On Instrument CCS']   = params.skip_OICCS ? 'No' : 'Yes'
summary['Max Memory']   = params.max_memory
summary['Max CPUs']     = params.max_cpus
summary['Max Time']     = params.max_time
summary['Container Engine'] = workflow.containerEngine
summary['Current home']   = "$HOME"
summary['Current user']   = "$USER"
summary['Current path']   = "$PWD"
summary['Working dir']    = workflow.workDir
summary['Output dir']     = params.outdir
summary['Config Profile'] = workflow.profile

//if(params.email) summary['E-mail Address'] = params.email
log.info summary.collect { k,v -> "${k.padRight(15)}: $v" }.join("\n")
log.info "========================================="

/* Creates a file at the end of workflow execution */
workflow.onComplete {
  File woc = new File("${params.outdir}/PacBioRunQC.workflow.oncomplete.txt")
  Map endSummary = [:]
  endSummary['Completed on'] = workflow.complete
  endSummary['Duration']     = workflow.duration
  endSummary['Success']      = workflow.success
  endSummary['exit status']  = workflow.exitStatus
  endSummary['Error report'] = workflow.errorReport ?: '-'
  String endWfSummary = endSummary.collect { k,v -> "${k.padRight(30, '.')}: $v" }.join("\n")
  println endWfSummary
  String execInfo = "Summary\n${endWfSummary}\n"
  woc.write(execInfo)
}


/*
 * STEP 1 - RUN_QC
*/
process subreads_reports {
    label 'pacbiosmrtlink_sequel2'
    tag "$name (raw)"
    publishDir "${params.outdir}/subreads_reports", mode: 'copy'

    input:
    set val(name), file(dataset), file (sts), file(reads), file(reads_pbi), \
        file(ccs_log), file(ccs_rep_j), file(ccs_rep_t), file(zmw_metrics),  \
        file(adapters), file (scraps), file(scraps_pbi) \
        from dataset_files

    output:
    set val(name), file ("${name}") into reports, image

    script:
    if (!params.skip_OICCS) {
    prefix = dataset.toString() - ~/(\.consensusreadset.xml)?$/
    """
    subreads_report.sh $dataset $name 1
    create_images.sh $name 1
    """
    } else {
    prefix = dataset.toString() - ~/(\.subreadset.xml)?$/
    """
    subreads_report.sh $dataset $name 0
    create_images.sh $name 0
    """
    }
}

/*
 * STEP 2 - Make Report for MultiQC
*/
process makeReport {
   label 'python'
    //tag "$name (raw)"
    publishDir "${params.outdir}/makeReport", mode: 'copy'

    input:
    set val(name), file(dataset), file ("${name}") from read_files_reports.join(reports)

    output:
    file "*.txt" into makereport_results

    script:
    if (!params.skip_OICCS) {
    prefix = dataset.toString() - ~/(\.consensusreadset.xml)?$/
    """
    smrtlink_report.py --s $dataset --m $name/*.txt \\
                                --o $prefix --n $name
    """
    } else {
    prefix = dataset.toString() - ~/(\.subreadset.xml)?$/
    """
    smrtlink_report.py --s $dataset --p $name/loading_xml/loading_xml.json \\
                                --l $name/filter_stats_xml/filter_stats_xml.json  \\
                                --a $name/adapter_xml/adapter_xml.json            \\
                                --c $name/control/control.json --o $prefix --n $name
    """
    }
}


/*
 *  MultiQC
*/
process multiqc {
  label 'multiqc'
  publishDir "${params.outdir}/multiqc", mode: 'copy'

  input:
  file samplePlan from Channel.of( params.samplePlan ? file("$params.samplePlan") : "")
  file metadata from ch_metadata.ifEmpty([])
  file multiqc_config from ch_multiqc_config
  file ('subreads_reports/*') from image.collect().ifEmpty([])
  file ('makeReport/*') from makereport_results.collect().ifEmpty([])

  when:
  !params.skip_multiqc

  output:
  file "PacBioRunQC_report.html" into multiqc_report
  file "*_data"


  script:
  rtitle = custom_runName ? "--title \"$custom_runName\"" : ''
  rfilename = custom_runName ? "--filename " + custom_runName + "_PacBioRunQC_report" : '--filename PacBioRunQC_report'
  metadata_opts = params.metadata ? "--metadata ${metadata}" : ""
  splan_opts = params.samplePlan ? "--splan ${samplePlan}" : ""

  """
  mqc_header.py --name "PacBioRunQC" --version ${workflow.manifest.version} ${metadata_opts} ${splan_opts} > multiqc-config-header.yaml
  multiqc.sh ${rtitle} ${rfilename} multiqc-config-header.yaml ${multiqc_config}
  
  """
}
