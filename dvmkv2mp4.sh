#!/bin/bash

file_path=$1
file_dir=$2

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
                        # docker run -it -u $(id -u):$(id -g) --rm -v "$file_dir:/convert" dvmkv2mp4 -l und,eng -r # REMOVE -it for synology - no TTY
                        docker run -u $(id -u):$(id -g) --rm -v "$file_dir:/convert" dvmkv2mp4 -l und,eng # REMOVE -it for synology - no TTY
                        exit
                        
                else
                        echo "NOT same file size of $file_path, sleeping"
                        sleep 5  # Adjust the sleep duration as needed
                fi


        else
                echo "File not found or inaccessible."
        fi

done