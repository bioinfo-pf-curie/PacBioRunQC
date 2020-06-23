#!/bin/bash -euo pipefail
smrtlink_report.py --s m54063_181211_144629.subreadset.xml --p m54063_181211_144629/loading_xml/loading_xml.json \
                   --l m54063_181211_144629/filter_stats_xml/filter_stats_xml.json  \
                   --a m54063_181211_144629/adapter_xml/adapter_xml.json            \
                   --c m54063_181211_144629/control/control.json --o m54063_181211_144629 --n m54063_181211_144629
