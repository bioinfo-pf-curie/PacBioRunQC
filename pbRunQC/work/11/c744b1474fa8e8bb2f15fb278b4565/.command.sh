#!/bin/bash -euo pipefail
smrtlink_report.py --s m54063_181212_112538.subreadset.xml --p 2_B01/loading_xml/loading_xml.json \
                   --l 2_B01/filter_stats_xml/filter_stats_xml.json  \
                   --a 2_B01/adapter_xml/adapter_xml.json            \
                   --c 2_B01/control/control.json --o m54063_181212_112538 --n 2_B01
