#!/usr/bin/env python
import os
device="wlan0"
scan_cmd='iwlist '+device+' scan'
i=os.system(scan_cmd)
print(i)
