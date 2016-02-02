#!/bin/bash

date_str="01-29-16"

# Clean up predictions directory
mv predictions/*.txt predictions/backup/

# Clean up positions directory
rm positions/*.csv

# Clean and prepare games directory
mv games/fd.json games/fd_${date_str}.json
mv games/dk.json games/dk_${date_str}.json
rm games/players_backup.p
mv games/*.* games/backup/
touch games/fd.json
touch games/dk.json
