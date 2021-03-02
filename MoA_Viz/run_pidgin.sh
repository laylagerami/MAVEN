#!/bin/bash
source activate pidgin3_env
python /scratch/software/PIDGINv4/predict.py -f /tmp/RtmppUiGdx/aa202cb84c8db3e23f838cf1/0.txt -d '	' --organism 'Homo' -b 10 --ad 75 -n 40 -o output/PIDGIN_10_75_40_2021-03-02_15:09:46 --target_class GPCR
