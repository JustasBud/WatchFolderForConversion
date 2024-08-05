#!/bin/bash

file_path=$1
file_dir=$2
size_threshold=$((1024 * 1024 * 1024))

attempt=0
while (( attempt < 17280 )); do #where 17280 = 24 hours / 5 seconds
        
        if [ -e "$file_path" ]; then
                previous_size=$(stat -c %s "$file_path")
                sleep 10
                current_size=$(stat -c %s "$file_path")
                echo $current_size
                echo $previous_size
                
                if [ "$current_size" -eq "$previous_size" ]; then

                        echo $file_path
                        echo $file_dir
                        # docker run -it -u $(id -u):$(id -g) --rm -v "$file_dir:/convert" dvmkv2mp4 -l und,eng -r # REMOVE -it for synology - no TTY
                        docker run -u $(id -u):$(id -g) --rm -v "$file_dir:/convert" dvmkv2mp4 -l und,eng -r # REMOVE -it for synology - no TTY
                        break
                        
                        
                else
                        echo "NOT same file size of $file_path, sleeping"
                        sleep 5  # Adjust the sleep duration as needed
                        (( attempt++ ))
                fi


        else
                echo "File not found or inaccessible."
                exit 0
                break
        fi
        sleep 60
if (( attempt == 17280 )); then
        echo "File: $file_path did not meet the size criteria after 17280 attempts."
        exit 0
fi

done
exit 0