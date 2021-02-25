#!/bin/bash
source activate pidgin3_env
python 0/predict.py -f /var/folders/tx/syw_nk2n7fd0yk15gx73fsdm0000gp/T//Rtmp2eveyW/07d42c5cc904d7ced5e85ba5/0.txt -d '	' --organism 'Homo' -b 10 --ad 75 -n 10 -o ./output/PIDGIN_10_75_10_2021-02-25_14:41:00.txt
