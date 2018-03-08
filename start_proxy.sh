#!/bin/bash
/opt/goagent/detect_network.sh 2>&1 >/dev/null
python3.3 /opt/goagent/proxy.py
