#!/usr/bin/env python

import re
import os
import json
import xml.etree.ElementTree as ET
from optparse import OptionParser

class smrtlink_report(object):
    """python3.6 smrtlink_report.py --s m54063_181212_112538.subreadset.xml --p loading_xml.json --o myreport"""

    def get_options(self):
        usage = "usage: %prog [options] arg"
        parser = OptionParser(usage)
        parser.add_option("--s", "--subreads", dest="subreads", default="", help="subreadset format xml")
        parser.add_option("--p", "--productivity", dest="productivity", default="", help="loading_xml format json")
        parser.add_option("--l", "--lengthsfile", dest="lengthsfile", default="", help="filter_xml format json")   
        parser.add_option("--a", "--adapter", dest="adapter", default="", help="adapter_xml format json") 
        parser.add_option("--c", "--control", dest="control", default="", help="control format json")
        parser.add_option("--o", "--output", dest="output", default="")
        parser.add_option("--n", "--name", dest="name", default="", help="")
        (options, args) = parser.parse_args()
        args = []
        args = self.check_options(options.subreads, options.productivity, options.lengthsfile, options.adapter, options.control, options.output, options.name)
        return(args)

    def check_options(self, subreads, productivity, lengthsfile, adapter, control, output, name):
        """
          Check arguments in command lign.
        """
        if subreads != "":
           subreads = subreads
        else:
           print ('No subraeds. Exiting.')
           exit(0)

        if productivity != "":
           productivity = productivity

        if lengthsfile != "":
           lengthsfile = lengthsfile

        if adapter != "":
           adapter = adapter

        if control != "" :
           control = control

        if output != "":
            output = output
        else:
            base = os.path.basename(subreads)
            output = os.path.splitext(base)[0].split('.subreadset')[0]

        if name != "":
           name = name
        else:
           base = os.path.basename(subreads)
           name= os.path.splitext(base)[0].split('.subreadset')[0]
        args = []
        args = (subreads, productivity, lengthsfile, adapter, control, output, name)
        return(args)

    def parse_subreadset_file(self, subreads, name): 
        """
          parsing *.subreadset.xml to extract basic informatin.
        """
        try: 
           tree = ET.parse(subreads)
           root = tree.getroot()
           cellname= root.attrib['Name']

           #### extra information: 
           #for x in root.iter():
           #      print(x.tag, x.attrib, x.text)
          

           #extres = root.find("{http://pacificbiosciences.com/PacBioBaseDataModel.xsd}ExternalResources")
           #resourceID = []
           #for item in extres.iter():
           #     #print(item.tag, item.attrib)
           #     if item.tag == "{http://pacificbiosciences.com/PacBioBaseDataModel.xsd}ExternalResource":
           #        resourceID.append(item.attrib.get('ResourceId'))
           #print("resourceID ==> ", resourceID)
           ### end xtra information


           metadata= root.find("{http://pacificbiosciences.com/PacBioDatasets.xsd}DataSetMetadata")
           for item in metadata.iter():
              if item.tag == "{http://pacificbiosciences.com/PacBioCollectionMetadata.xsd}CollectionMetadata":
                  metadata_context_id = item.attrib.get("Context")
                  instrument_name = item.attrib.get("InstrumentName")

              if item.tag == "{http://pacificbiosciences.com/PacBioCollectionMetadata.xsd}ControlKit" :
                 #kit_name = item.attrib.get("Name").split("Control")[0]
                 kit_version = item.attrib.get("Version")

              if item.tag == "{http://pacificbiosciences.com/PacBioCollectionMetadata.xsd}RunDetails":
                 #print(item.tag, item.attrib, item[3].text)
                 run_stampname = item[0].text
                 run_name = item[1].text
                 createdby = item[2].text
                 whencreated = item[3].text.split('T')[0]
                 #print(run_stampname, run_name, createdby, whencreated)

              if item.tag == "{http://pacificbiosciences.com/PacBioCollectionMetadata.xsd}CollectionPathUri":
                 pathUri = item.text

              if item.tag == "{http://pacificbiosciences.com/PacBioCollectionMetadata.xsd}WellSample":
                # print(item.tag, item.attrib)
                 wellcell_name = item.attrib.get("Name")
                 wellcell_des = item.attrib.get("Description").split(';')[1]

              if item.tag == "{http://pacificbiosciences.com/PacBioBaseDataModel.xsd}AutomationParameter":
                 if item.attrib.get("Name") == "MovieLength": 
                    movie_time = int(item.attrib.get("SimpleValue"))/60

              if item.tag == "{http://pacificbiosciences.com/PacBioCollectionMetadata.xsd}VersionInfo":
                 if item.attrib.get("Name") == "smrtlink":
                    smrt_link_version = ".".join(item.attrib.get("Version").split('.')[0:2])


           subreads_dict = dict(
               Well = name,
               Wellcell_Name = wellcell_name,
               Data_Set = cellname,
               Movie_Time = movie_time,
               Organism = wellcell_des,
               Kit_Version = kit_version, 
               SMRT_Link_Version = smrt_link_version,
               Metadata_Context_Id = metadata_context_id,
           )
           overview_dict = dict(
               Run_Name = run_name,
               Run_Id = run_stampname,
               Run_Date = whencreated,
               CreatedBy = createdby,
               instrument_name = instrument_name
           )

	
           return (subreads_dict, overview_dict)

        except ValueError: return False

    def parse_productivity_file(self, productivity, name):
        """
          parsing loading.xml to extract productivity.
        """
        try:
           with open(productivity) as json_file:
              data = json.load(json_file)
              for i, value  in enumerate(data['tables']):
                   for i, item in enumerate(value["columns"]):

                       if 'loading_xml_report.loading_xml_table.productive_zmws' in item.get("id"):
                           productive_zmws = str(item.get("values")).strip('[]')

                       if 'loading_xml_report.loading_xml_table.productivity_0_pct' in item.get("id"):
                           p0 = str(item.get("values")).strip('[]')

                       if 'loading_xml_report.loading_xml_table.productivity_0_n' in item.get("id"):
                           productivity_0 = str(item.get("values")).strip('[]')

                       if 'loading_xml_report.loading_xml_table.productivity_1_pct' in item.get("id"):
                           p1 = str(item.get("values")).strip('[]')

                       if 'loading_xml_report.loading_xml_table.productivity_1_n' in item.get("id"):
                           productivity_1 = str(item.get("values")).strip('[]')

                       if 'loading_xml_report.loading_xml_table.productivity_2_pct' in item.get("id"):
                           p2 = str(item.get("values")).strip('[]')

                       if 'loading_xml_report.loading_xml_table.productivity_2_n' in item.get("id"):
                           productivity_2 = str(item.get("values")).strip('[]')

 

           productivity_dict = dict(
               Well = name, 
               P0 = p0,
               P1 = p1,
               P2 = p2
           )

           loading_dict = dict(
               Well = name,
               Productive_ZMWs = productive_zmws,
               Productivity_0 = productivity_0,
               P0 = p0,
               Productivity_1 = productivity_1,
               P1 = p1,
               Productivity_2 = productivity_2,
               P2 = p2
           )


           return (productivity_dict, loading_dict)

        except ValueError: return False


    def parse_lengths_file(self, lengthsfile, name):
        """
          parsing filter_stats.xml to extract lengths.
        """

        try:
           with open(lengthsfile) as json_file:
              data = json.load(json_file)
              #print(data)
              for i, value  in enumerate(data['attributes']):
                    #print(value)
                    if 'raw_data_report.nbases' in value.get("id"):
                           polymerase_read_bases =  value.get("value")

                    if 'raw_data_report.nreads' in value.get("id"):
                           polymerase_reads =  value.get("value")

                    if 'raw_data_report.read_length' in value.get("id"):
                           polymer_readlength = value.get("value")

                    if 'raw_data_report.read_n50' in value.get("id"):
                           polymer_N50 = value.get("value")
 
                    if 'raw_data_report.subread_length' in value.get("id"):
                           subread_Length = value.get("value")

                    if 'raw_data_report.subread_n50' in value.get("id"):
                           subread_N50 = value.get("value")

                    if 'raw_data_report.insert_length' in value.get("id"):
                           longest_subread_mean = value.get("value")

                    if 'raw_data_report.insert_n50' in value.get("id"):
                           longest_subread_N50 = value.get("value")

                    if 'raw_data_report.unique_molecular_yield' in value.get("id"):
                           unique_molecular_yield = value.get("value")/1000000000 ## convert to Gb

           lengths_dict = dict(
              Well = name,
              Polymerase_Read_Bases = polymerase_read_bases,
              Unique_Molecular_Yield = unique_molecular_yield,
              Polymerase_Reads = polymerase_reads,
              Polymerase_Read_Length = polymer_readlength,
              Polymerase_Read_N50 = polymer_N50,
              Subread_Length = subread_Length,
              Subread_N50 = subread_N50,
              Insert_Length_subread_mean = longest_subread_mean,  
              Insert_N50 = longest_subread_N50
            )

           return lengths_dict
         
        except ValueError: return False

    def parse_adapter_file(self, adapter, name):
        """
          parsing adapter_xml.json to extract adapter.
        """
        try:
           with open(adapter) as json_file:
              data = json.load(json_file)
              for i, value  in enumerate(data['attributes']):
                    if 'adapter_xml_report.adapter_dimers' in value.get("id"):
                           adapter_dimers =  value.get("value")

                    if 'adapter_xml_report.short_inserts' in value.get("id"):
                           short_inserts =  value.get("value")

                    if 'adapter_xml_report.local_base_rate_median' in value.get("id"):
                           local_base_rate = value.get("value")

           adapter_dict = dict(
              Well = name,
              Adapter_Dimers = adapter_dimers,
              Short_Inserts = short_inserts,
              Local_Base_Rate = local_base_rate
            )

           return adapter_dict

        except ValueError: return False

    def parse_control_file(self, control, name):
       """
          parsing control.json to extract adapter.
       """
       try:
           with open(control) as json_file:
              data = json.load(json_file)
              for i, value  in enumerate(data['attributes']):
                    if 'control.reads_n' in value.get("id"):
                           nb_control_reads =  value.get("value")

                    if 'control.readlength_mean' in value.get("id"):
                           readlength_mean =  value.get("value")

                    if 'control.concordance_mean' in value.get("id"):
                           concordance_mean = value.get("value")

                    if 'control.concordance_mode' in value.get("id"):
                           concordance_mode = value.get("value")

           control_dict = dict(
              Well = name,
              Number_of_of_Control_Reads = nb_control_reads,
              Control_Read_Length_Mean = readlength_mean,
              Control_Read_Concordance_Mean = concordance_mean, 
              Control_Read_Concordance_Mode = concordance_mode
            )

           return control_dict

       except ValueError: return False


    def write_result(self, dict, output):
       """ 
       This file is read by MultiQC.
       """
       with open(output , 'w') as out:
          out.write('\t'.join(str(key) for key in dict)+'\n')
          out.write('\t'.join(str(value) for value in dict.values()) +'\n')


if __name__ == '__main__':
    SR = smrtlink_report()
    args = SR.get_options()
    subreads =     args[0]
    productivity = args[1]
    lengthsfile =  args[2]
    adapter =      args[3]
    control =      args[4]
    output =       args[5]
    name =         args[6]
    
    (subreads_dict, overview_dict) = SR.parse_subreadset_file(subreads, name)
    SR.write_result(subreads_dict, output + "_subreads.txt") 
    SR.write_result(overview_dict, output + '_overview.txt')

    if productivity != "":
        (productivity_dict,loading_dict) = SR.parse_productivity_file(productivity, name) 
        SR.write_result(productivity_dict, output + "_productivity.txt")
        SR.write_result(loading_dict, output + "_loading.txt")

    if lengthsfile != "":
        lengths_dict = SR.parse_lengths_file(lengthsfile, name)
        SR.write_result(lengths_dict, output + "_lengths.txt")

    if adapter != "":
        adapter_dict = SR.parse_adapter_file(adapter, name)
        SR.write_result(adapter_dict, output + "_adapter.txt")

    if control !="":
       control_dict = SR.parse_control_file(control, name)
       SR.write_result(control_dict, output + "_control.txt")
