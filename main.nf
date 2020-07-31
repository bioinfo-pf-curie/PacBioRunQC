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
                         pbRunQC
========================================================================================
 pbRunQC Pipeline.
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
    pbRunQC v${workflow.manifest.version}
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


if(params.samplePlan){
      Channel
         .from(file("${params.samplePlan}"))
         .splitCsv(header: false)
         .map{row -> [
              def name = row[0], 
              def reads = file(row[1] + '.subreadset.xml'),
              def adapters = file(row[1] +  '.adapters.fasta'),
              def scraps = file(row[1] +  '.scraps.bam'),
              def scraps_pbi = file(row[1] +  '.scraps.bam.pbi'),
              def sts = file(row[1] +  '.sts.xml'),
              def subreads = file(row[1] +  '.subreads.bam'),
              def subreads_pbi = file(row[1] + '.subreads.bam.pbi')
              ]}
         .set{dataset_files}

         Channel
         .from(file("${params.samplePlan}"))
         .splitCsv(header: false)
         .map{row -> [
              def name = row[0],
              def reads = file(row[1] + '.subreadset.xml')
              ]}
         .set{read_files_reports}
}
else if(params.dataSet){
        Channel
            .from(params.dataSet)
            .ifEmpty { exit 1, "params.dataSet was empty - no input files supplied" }
            .map{row -> [
              def name = file(params.dataSet).name.toString().tokenize('.').get(0),
              def reads = file(params.dataSet + '.subreadset.xml'),
              def adapters = file(params.dataSet +  '.adapters.fasta'),
              def scraps = file(params.dataSet + '.scraps.bam'),
              def scraps_pbi = file(params.dataSet +  '.scraps.bam.pbi'),
              def sts = file(params.dataSet +  '.sts.xml'),
              def subreads = file(params.dataSet +  '.subreads.bam'),
              def subreads_pbi = file(params.dataSet +  '.subreads.bam.pbi')
              ]}
         .set{dataset_files}

        Channel
            .from(params.dataSet)
            .map{row -> [
              def name = file(params.dataSet).name.toString().tokenize('.').get(0), 
              def reads = file(params.dataSet + '.subreadset.xml')
              ]}
         .groupTuple()
         .set{read_files_reports}

}


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

pbRunQC v${workflow.manifest.version}"
======================================================="""
def summary = [:]
summary['Pipeline Name']  = 'pbRunQC'
summary['Pipeline Version'] = workflow.manifest.version
summary['Run Name']     = custom_runName ?: workflow.runName
summary['Metadata']     = params.metadata
if (params.samplePlan) {
   summary['SamplePlan']   = params.samplePlan
}else{
   summary['DataSet']        = params.dataSet
}
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
  File woc = new File("${params.outdir}/pbRunQC.workflow.oncomplete.txt")
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
    label 'pacbioSmrtlink'
    tag "$name (raw)"
    publishDir "${params.outdir}/subreads_reports", mode: 'copy'

    input:
    set val(name), file(reads), file(adapters), file(scraps), file(scraps_pbi), file(sts), file(subreads), file(subreads_bpi) from dataset_files
     
    output:
    set val(name), file ("${name}") into reports
    file "${name}_mqc.png" into image

    script:
    prefix = reads.toString() - ~/(\.subreadset.xml)?$/
    """
    subreads_report.sh $prefix $reads $name
    create_images.sh $name
    """
}


/*
 * STEP 2 - Make Report for MultiQC
*/
process makeReport {
    //tag "$name (raw)"
    publishDir "${params.outdir}/makeReport", mode: 'copy'

    input:
    set val(name), file(reads), file ("${name}") from read_files_reports.join(reports)

    output:
    file "*.txt" into makereport_results

    script:
    prefix = reads.toString() - ~/(\.subreadset.xml)?$/
    """
    smrtlink_report.py --s $reads --p $name/loading_xml/loading_xml.json \\
                       --l $name/filter_stats_xml/filter_stats_xml.json  \\
                       --a $name/adapter_xml/adapter_xml.json            \\
                       --c $name/control/control.json --o $prefix --n $name
    """
}


/*
 *  MultiQC
*/
process multiqc {
  label 'multiqc'
  publishDir "${params.outdir}/MultiQC", mode: 'copy'

  input:
  file metadata from ch_metadata.ifEmpty([])
  file multiqc_config from ch_multiqc_config
  file ('subreads_reports/*') from image.collect().ifEmpty([])
  file ('makeReport/*') from makereport_results.collect().ifEmpty([])

  when:
  !params.skip_multiqc

  output:
  file "pbRunQC_report.html" into multiqc_report
  file "*_data"


  script:
  rtitle = custom_runName ? "--title \"$custom_runName\"" : ''
  rfilename = custom_runName ? "--filename " + custom_runName + "_pbRunQC_report" : '--filename pbRunQC_report'
  metadata_opts = params.metadata ? "--metadata ${metadata}" : ""
  splan_opts = params.samplePlan ? "--splan ${params.samplePlan}" : ""

  """
  mqc_header.py --name "pbRunQC" --version ${workflow.manifest.version} ${metadata_opts} ${splan_opts} > multiqc-config-header.yaml
  multiqc.sh ${rtitle} ${rfilename} multiqc-config-header.yaml ${multiqc_config} 
  """
}
