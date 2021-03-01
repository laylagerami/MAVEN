#!/bin/bash
source activate pidgin3_env
python /scratch/software/PIDGINv4/predict.py -f /tmp/Rtmpb2nTk5/40742b742c83548735b05696/0.txt -d '	' --organism 'Homo' -b 0.1 --ad 75 -n 30 -o ./output/PIDGIN_0.1_75_30_2021-02-26_10:03:01.txt
