#!/bin/bash

date_str="01-30-16"
n_per_position=8
n_games=5
n_save=15

python main.py $date_str double $n_per_position $n_games
./optimize $n_save predictions/${date_str}_doubles_fd.txt double fd
# ./optimize $n_save predictions/${date_str}_doubles_dk.txt double dk
