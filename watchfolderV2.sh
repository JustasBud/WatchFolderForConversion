#!/bin/bash
cd "/volume1/SharedMedia/"


while true
do
        touch  ./lastwatch
        sleep 10
        #Logic to remove looking in hidden folders (e.g. @eaDir in Synology)
        file_path=$(find "/volume1/SharedMedia/movies" "/volume1/SharedMedia/tv" -not -path '*/[@.]*' -cnewer ./lastwatch -type f)
        file_dir=$(find "/volume1/SharedMedia/movies" "/volume1/SharedMedia/tv" -not -path '*/[@.]*' -cnewer ./lastwatch -type f -exec dirname {} \;)
        # var=$(find "/movies"  -cnewer ./lastwatch -type f)

        shopt -s nocasematch #checks both lower/upper case
        if [[ "$file_path" == *'.mkv'* && ( "$file_path" == *'DV'* || "$file_path" == *'DolbyVision'* || "$file_path" == *'Dolby Vision'* || "$file_path" == *'DoVi'* ) ]]; then
        shopt -u nocasematch


                while true; do
                        if [ -e "$file_path" ]; then
                                previous_size=$(stat -c %s "$file_path")
                                sleep 10
                                current_size=$(stat -c %s "$file_path")
                                echo $current_size
                                echo $previous_size
                                
                                if [ "$current_size" -eq "$previous_size" ]; then

                                        echo $file_path
                                        echo $file_dir
                                        docker run -u $(id -u):$(id -g) --rm -v "$file_dir:/convert" dvmkv2mp4 -l und,eng -r
                                        echo 'RUN DOCKER here'
                                        break
                                else
                                        echo "NOT same file size of $file_path, sleeping"
                                        sleep 5  # Adjust the sleep duration as needed
                                fi


                        else
                                echo "File not found or inaccessible."
                        fi

                done

        shopt -s nocasematch #checks both lower/upper case
        elif [[ "$file_path" == *'.mkv'* ]]; then #if not contains dolby vision, but is mkv - extract subtitles only
        shopt -u nocasematch

                while true; do
                        if [ -e "$file_path" ]; then
                                previous_size=$(stat -c %s "$file_path")
                                sleep 10
                                current_size=$(stat -c %s "$file_path")
                                echo $current_size
                                echo $previous_size
                                
                                if [ "$current_size" -eq "$previous_size" ]; then


                                        filename="${file_path%.*}"

                                        mappings=`docker run --rm --entrypoint='' -v $file_dir:/$file_dir  linuxserver/ffmpeg ffprobe -loglevel error -select_streams s -show_entries stream=index:stream_tags=language -of csv=p=0 "${file_path}" | grep -E ',(eng|und)$'`
                                        echo $mappings
                                        # mappings=`ffprobe -loglevel error -select_streams s -show_entries stream=index:stream_tags=language -of csv=p=0 "${movie}" | grep -E ',(chi|eng)$'`
                                        is_first_iteration=true
                                        OLDIFS=$IFS
                                        IFS=,
                                        ( while read idx lang
                                        do
                                                if [ "$is_first_iteration" = true ]; then
                                                echo "First sub found, naming as default"
                                                echo "Extracting default ${lang} subtitle #${idx} from ${file_path}"
                                                # ffmpeg -nostdin -hide_banner -loglevel quiet -i "${movie}" -map 0:"$idx" "${filename}.default.${lang}.srt"
                                                docker run --rm  --entrypoint='' -v $file_dir:/$file_dir  linuxserver/ffmpeg ffmpeg -nostdin -hide_banner -loglevel quiet -i "${file_path}" -map 0:"$idx" "${filename}.srt"
                                                is_first_iteration=false
                                                else
                                                echo "Extracting other ${lang} subtitle #${idx} from ${file_path}"
                                                docker run --rm --entrypoint='' -v $file_dir:/$file_dir  linuxserver/ffmpeg ffmpeg -nostdin -hide_banner -loglevel quiet -i "${file_path}" -map 0:"$idx" "${filename}.${lang}.${idx}.srt"
                                        fi
                                        done <<< "${mappings}" )
                                        IFS=$OLDIFS

                                        echo 'Extract complete'
                                        break
                                else
                                        echo "NOT same file size of $file_path, sleeping"
                                        sleep 5  # Adjust the sleep duration as needed
                                fi


                        else
                                echo "File not found or inaccessible."
                        fi

                done



        


        else
                :
        
        fi

done


