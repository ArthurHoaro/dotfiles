#!/bin/bash

cd /home/arthur/projects/writing/gemini
git reset HEAD
git add tinylog.gmi
git commit -m "Tinylog: $(date)"
git push origin master
