#!/bin/bash

twom_save_path=~/tmp/twom/
last_save=`find $twom_save_path -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "`
if [ -z $last_save ];then
	last_save=${twom_save_path}save.0.tar.gz
fi
last_save_filename=`basename $last_save`
day=`echo $last_save_filename | cut -d'.' -f2`
new_save_file=${twom_save_path}save.$((day+1)).tar.gz
echo "Last save found: #$day - $last_save"
echo "Making a new save: $new_save_file"

tar cvfz $new_save_file /home/arthur/.steam/steam/userdata/121952261/282070/remote/