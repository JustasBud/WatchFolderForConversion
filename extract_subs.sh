#!/bin/bash

file_path=$1
file_dir=$2
size_threshold=$((1024 * 1024 * 1024))



if [ -e "$file_path" ]; then
        previous_size=$(stat -c %s "$file_path")
        sleep 120
        current_size=$(stat -c %s "$file_path")

        attempt=0
        while (( attempt < 17280 )); do #where 17280 = 24 hours / 5 seconds


        
                if [[ "$current_size" -eq "$previous_size" && "$current_size" -ge $size_threshold ]]; then


                        filename="${file_path%.*}"

                        mappings=`docker run -u $(id -u):$(id -g) --rm  --entrypoint='' -v "$file_dir:/$file_dir"  linuxserver/ffmpeg ffprobe -loglevel error -select_streams s -show_entries stream=index:stream_tags=language -of csv=p=0 "${file_path}" | grep -E ',(eng|und)$'`
                        
                        
                        

                        # mappings=`ffprobe -loglevel error -select_streams s -show_entries stream=index:stream_tags=language -of csv=p=0 "${movie}" | grep -E ',(chi|eng)$'`
                        is_first_iteration=true
                        OLDIFS=$IFS
                        IFS=,
                        ( while read idx lang
                        do
                                if [ "$is_first_iteration" = true ]; then

                                echo "Extracting default ${lang} subtitle #${idx} from ${file_path}"
                                # echo "${file_dir}"
                                # echo "${filename}"
                                # ffmpeg -nostdin -hide_banner -loglevel quiet -i "${movie}" -map 0:"$idx" "${filename}.default.${lang}.srt"
                                docker run -u $(id -u):$(id -g) --rm  --entrypoint='' -v "$file_dir:/$file_dir"  linuxserver/ffmpeg ffmpeg -nostdin -hide_banner -loglevel quiet -i "${file_path}" -map 0:"$idx" "${filename}.srt"
                                is_first_iteration=false
                                else
                                echo "Extracting other ${lang} subtitle #${idx} from ${file_path}"
                                docker run -u $(id -u):$(id -g) --rm  --entrypoint='' -v "$file_dir:/$file_dir"  linuxserver/ffmpeg ffmpeg -nostdin -hide_banner -loglevel quiet -i "${file_path}" -map 0:"$idx" "${filename}.${lang}.${idx}.srt"
                        fi

                        done <<< "${mappings}" )
                        IFS=$OLDIFS

                        echo 'Extract complete'
                        break
                        
                else
                        echo "NOT same file size of $file_path, sleeping"
                        sleep 5  # Adjust the sleep duration as needed
                        (( attempt++ ))
                fi
                sleep 60                
        if (( attempt == 17280 )); then
        echo "File: $file_path did not meet the size criteria after 17280 attempts."
        fi
        done
        
        exit 0
else
        echo "File not found or inaccessible."
        exit 0
        break
fi
