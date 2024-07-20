#!/bin/bash

file_path=$1
file_dir=$2




if [ -e "$file_path" ]; then
        previous_size=$(stat -c %s "$file_path")
        sleep 10
        current_size=$(stat -c %s "$file_path")

        while true; do

        
                if [ "$current_size" -eq "$previous_size" ]; then


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
                        exit 0
                else
                        echo "NOT same file size of $file_path, sleeping"
                        sleep 5  # Adjust the sleep duration as needed
                fi
        done

else
        echo "File not found or inaccessible."
fi
