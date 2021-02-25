#!/bin/bash
source activate pidgin3_env
python /scratch/software/PIDGINv4/predict.py -f /tmp/Rtmpnv3b5M/436ad22ce199d8ed078834f0/0.txt -d '	' --organism 'Homo' -b 10 --ad 75 -n 10 -o ./output/PIDGIN_10_75_10_2021-02-25_10:53:09.txt
