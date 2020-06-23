#!/bin/bash -euo pipefail
smrtlink_report.py --s m54063_181212_112538.subreadset.xml --p 3_C01/loading_xml/loading_xml.json \
                   --l 3_C01/filter_stats_xml/filter_stats_xml.json  \
                   --a 3_C01/adapter_xml/adapter_xml.json            \
                   --c 3_C01/control/control.json --o m54063_181212_112538 --n 3_C01
