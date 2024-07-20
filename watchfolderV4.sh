#!/bin/bash
# FIX WHEN SPACE IN FILE!!!!!!!!!!!!!!!!!!
while true
do
        touch  ./lastwatch
        sleep 10
        #Logic to remove looking in hidden folders (e.g. @eaDir in Synology)
        find "/media/justas/ubuntustorage/TV/fleabag" -not -path '*/[@.]*' -cnewer ./lastwatch -type f -print0 | while IFS= read -r -d '' file_path; do
        echo "$file_path"
        file_dir=$(dirname "$file_path")
        # echo $file_dir


        shopt -s nocasematch #checks both lower/upper case
        if [[ "$file_path" == *'.mkv'* && ( "$file_path" == *'DV'* || "$file_path" == *'DolbyVision'* || "$file_path" == *'Dolby Vision'* || "$file_path" == *'DoVi'* ) ]]; then
        shopt -u nocasematch

            echo "executing dvmkv2mp4.sh for ${file_path}"
            
            param_file_path=$file_path param_file_dir=$file_dir ./dvmkv2mp4.sh "$param_file_path" "$param_file_dir"




        shopt -s nocasematch #checks both lower/upper case
        elif [[ "$file_path" == *'.mkv'* ]]; then #if not contains dolby vision, but is mkv - extract subtitles only
        shopt -u nocasematch

            echo "executing extract_subs.sh for ${file_path}"

            ./extract_subs.sh "$file_path" "$file_dir" &


            # param_file_path=$file_path param_file_dir=$file_dir ./extract_subs.sh $param_file_path $param_file_dir


        


        else
                :
        
        fi









    done
# echo $file_path




done


