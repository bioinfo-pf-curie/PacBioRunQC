#!/bin/bash -euo pipefail
smrtlink_report.py --s m54063_181211_144629.subreadset.xml --p 1_A01/loading_xml/loading_xml.json \
                   --l 1_A01/filter_stats_xml/filter_stats_xml.json  \
                   --a 1_A01/adapter_xml/adapter_xml.json            \
                   --c 1_A01/control/control.json --o m54063_181211_144629 --n 1_A01
