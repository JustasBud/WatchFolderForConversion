#!/bin/bash
cd "/volume1/SharedMedia/"
while true
do
        touch  ./lastwatch
        sleep 10
        #Logic to remove looking in hidden folders (e.g. @eaDir in Synology)
        # Logic added not to cut off file paths with spaces
        find "/volume1/SharedMedia/movies" "/volume1/SharedMedia/tv" -not -path '*/[@.]*' -cnewer ./lastwatch -type f -print0 | while IFS= read -r -d '' file_path; do
        # echo "$file_path"
        file_dir=$(dirname "$file_path")
        # echo $file_dir


        shopt -s nocasematch #checks both lower/upper case
        if [[ "$file_path" == *'.mkv'* && ( "$file_path" == *'DV'* || "$file_path" == *'DolbyVision'* || "$file_path" == *'Dolby Vision'* || "$file_path" == *'DoVi'* ) ]]; then
        shopt -u nocasematch

            echo "executing dvmkv2mp4.sh for ${file_path}"
            
            ./dvmkv2mp4.sh "$file_path" "$file_dir" &


        shopt -s nocasematch #checks both lower/upper case
        elif [[ "$file_path" == *'.mkv'* ]]; then #if not contains dolby vision, but is mkv - extract subtitles only
        shopt -u nocasematch

            echo "executing extract_subs.sh for ${file_path}"

            ./extract_subs.sh "$file_path" "$file_dir" &

        else
                :
        
        fi









    done
# echo $file_path




done


