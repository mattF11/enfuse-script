#!/bin/bash
# AUTHOR: mattF11
# VERSION: 1.0
# DESCRIPTION: enfuse script for focus stacking
#adding dcraw support because i need to convert the files to png or tiff,i use tiff.

echo "
___________________________
|  __      __     __   _  |
| |__ |_  |__ | | |_  |_| | 
| |__ | | |   |_| __| |__ |
|_________________________|

"
####################################################################################
# DIRECTORY LIST
a="$HOME"
b="/usr/bin/enblend"
c="/usr/bin/dcraw"
d="Converted_Images"
e="$HOME/enfuse-script"
###################################################################################

# log 
#LOG_FILE="enfuse-script/logfile.log"
#LOG_LEVEL="INFO"

# Check for debug flag
#if [[ "$1" == "-d" || "$1" == "--debug" ]]; then
#    LOG_LEVEL="DEBUG"
#fi

# Initialise the logging module
#init_logger --log $LOGFILE --level $LOG_LEVEL
# Log some messages
#log_info "This is an informational message"
#log_warn "This is a warning message"
#log_error "This is an error message"
#log_debug "This is a debug message"  # Only prints to console and/or log file if debug logging is enabled
#Now you can run your script with the -d or --debug argument to enable debug logging. For example:
# Debug use
#./script.sh --debug

# Normal use
#./script.sh
#That’s it! It’s as simple as that! You can now include debug logging in your script and enable or disable it at runtime. Obviously you can have a more complex argument setup for your script with getopts or similar depending on your needs, but this is a simple example to get you started.

#################################################################################

# SELECTION
echo "$USER, select the action (1/2/3)
1. Focus Stacking
2. Blending
3. Exit : "
read selection
#check if string is inserted
if [[ -z "$selection" ]]
then
    echo "ERROR:wrong insertion type,interger needed"
else
    echo "CORRECT:insertion type correct"
fi

###################################################################################
####################################################################################

#FUNCTIONS
#funtion for .tiff conversion using dcraw
function tiff_function {
    echo ".tiff conversion"
    if [[ -e "$c" ]]
    then
        echo "dcraw installed"
    else
        echo "dcraw not installed,install it from your package manager"
        exit 1
    fi

    cd "$a" || { echo "ERROR: cannot cd into $a"; exit 1; }
    echo "Search folder/directory:"
    read folder
    find . -type d -name "*${folder}*" > finder.txt  #write results on file
    i=0
    while read line
    do
        echo "[$i] $line"
        ris[$i]="$line"
        ((i++))
    done < finder.txt  #read result file
    
    if [[ "$i" -eq "0" ]]
    then
        echo "Directory not found"
        exit 1
    else
        echo "Directory found"
        echo "Select a directory/folder(n):"
        read dir
        selection="${ris[$dir]}"
        echo "$dir: $selection"
        echo "Convert the entire directory or a single file (1=directory / 2=file)?"
        read f1

        if [[ "$f1" != "1" ]]
        then
            #########################################################################
            #single file
            if [[ "$f1" = "2" ]]
            then
                echo "no:single file selection"
                echo "list of all the files available, choose the one you want to convert"
                find "$selection" -maxdepth 1 -type f > finder.txt
                j=0
                while read line
                do
                    echo "[$j] $line"
                    ris[$j]="$line"
                    ((j++))
                done < finder.txt

                if [[ "$j" -eq "0" ]]
                then
                    echo "File not available"
                    exit 1
                else
                    echo "File available"
                    echo "Select a file(n):"
                    read dir
                    selection1="${ris[$dir]}"
                    echo "$dir: $selection1"
                    echo "Convert the file(1=yes / 2=no)?"
                    read ff

                    out_file="${selection1%.*}.tiff"
                    if [[ "$ff" == "1" ]]
                    then
                        dcraw -T -6 -w -O "$out_file" "$selection1"
			#wait for adding to the folder "$d"
			mv "$out_file" "$d"
                    else
                        echo "ERROR:wrong input"
                        exit 1
                    fi
                    echo "File converted."
                fi
            else
                echo "ERROR:wrong input number"
            fi
	fi
    fi

            exit 0
            #########################################################################
        else
            #########################################################################
            #directory conversion
            echo "yes:directory conversion selected"
            echo "Do you really want to convert to TIFF(1=yes / 2=no)?"
            read f1_1
            shopt -s nullglob

            for file in "$selection"/*
            do
                if [[ "$f1_1" == "1" ]]
                then
                    out_file="${file%.*}.tiff"
                    dcraw -T -6 -w -O "$out_file" "$file"
		    #wait for adding to the folder "$d"
		    mv "$out_file" "$d"
                else
                    echo "ERROR:wrong input"
                    exit 1
                fi
            done

            shopt -u nullglob
            echo "Directory converted."
            #########################################################################
        fi
    fi
}


##################################################################################
##################################################################################

#is enfuse installed on your system?
if [[ -e "$b" ]]
then
    echo "Enfuse is installed"
else
    echo "Enfuse not installed"
    exit 1
fi
cd "$a"

##################################################################################
##################################################################################

#1.handling case selection:focus stacking
case $selection in
    1|1.|Focus Stacking|focus stacking)
	echo "Selected: Focus Stacking"
	#verify if enblend-enfuse exists in the right directory
	if [[ -e "$b" ]]
	then
	    echo "Enfuse is installed"
	else
	    echo "Enfuse not installed"
	    exit 1
	fi
	cd "$a"
	
	if [[ -e "$e" ]]
	then
	    echo "directory for converted images already exists"
	else
	    echo "directory doesn't exist,creating the working directory.."
	    cd "$e" | mkdir -p "$d" | cd "$d"
	fi

	DIR="$(pwd)"
	echo "You need to have files converted to .tiff"
	echo "Do you want to use the built-in converter or an external program (1=built-in / 2=external) ?"
	read selection3
	
	if [[ "$selection3" == "1" ]]
	then
            echo "1:starting .tiff conversion"
	#recall tiff_function
	tiff_function
	#conversion finished
	#need to use the same directory just converted   
	else
	    echo "2:convert the images and then start the script"
	    exit 1
	fi

        #use enfuse on the same folder you just converted
	#selection option added to complete the script
                cd "$a" || { echo "ERROR: cannot cd into $a"; exit 1; }
                echo "Search folder/directory:"
                read folder
                # Case-insensitive search
                find . -type d -name "*${folder}*" > finder.txt
                i=0
        
                while read line
		do
                    echo "[$i] $line"
                    ris[$i]="$line"	
                    ((i++))
                done < finder.txt

		#see if it's valuable to implement a removal of the older original files,as a request to the user
                if [[ "$i" -eq "0" ]]
		then    
                    echo "Directory not found"
                    exit 1		    
                else
                    echo "Directory found"
                    echo "Select a directory/folder(n):"
                    read dir
                    selection="${ris[$dir]}"
                    echo "$dir: "$selection""
                    echo "Stack the entire directory or single file (1=directory / 2=file)?"
                    read f1


		    shopt -s nullglob #if file not found, empty string
			#repeat conversion process to convert all files in a folder
                        for file in "$selection"/*
			do
                            if [[ "$f1" == "1" ]]
			    then
                     #command used to convert images
		    #1.allign images,bad idea to stack them without allign
		    #commands will:allign,then stack and remove halo focus
				align_image_stack -m -a OUT "$file" "${file[i]}.tiff"
				enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 \
				--hard-mask --gray-projector=l-star --output=baseOpt2.tiff OUT*.tiff
			    fi	    
                        done
                        shopt -u nullglob

                        echo "Directory converted."
			
			#single image selected
		        if [[ "$f1" == "2" ]]
			    then
				echo "enter file name:" ;read filename
				echo ""$filename" conversion started.."
				align_image_stack -m -a OUT "$file" "${file[i]}.tiff"
				enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 \
				       --hard-mask --gray-projector=l-star --output=baseOpt2.tiff OUT*.tif
		                echo "done"
			    fi
                    fi  
		;;
				       

####################################################################################
####################################################################################
#2.Handling of selection:Blending

	2|2.|Blending)
	echo "Selected: Blending"
	#verify if enblend-enfuse exists in the right directory
	if [[ -e "$b" ]]
	then
	    echo "Enfuse is installed"
	else
	    echo "Enfuse not installed"
	    exit 1
	fi

	#echo "You need to have files converted to .tiff"
	tiff_function	
	#selection option added to complete the script
                cd "$a" || { echo "ERROR: cannot cd into $a"; exit 1; }
                echo "Search folder/directory:"
                read folder
                # Case-insensitive search
                find . -type d -name "*${folder}*" > dnglab.txt
                i=0
        
                while read line
		do
                    echo "[$i] $line"
                    ris[$i]="$line"	
                    ((i++))
                done < dnglab.txt

		#see if it's valuable to implement a removal of the older original files,as a request to the user
                if [[ "$i" -eq "0" ]]
		then    
                    echo "Directory not found"
                    exit 1		    
                else
                    echo "Directory found"
                    echo "Select a directory/folder(n):"
                    read dir
                    selection="${ris[$dir]}"
                    echo "$dir: "$selection""
                    echo "Blend the entire directory or exit (1=directory / 2=exit)?"
                    read f1

		    for file in "$selection"/*
			do
                            if [[ "$f1" == "1" ]]
			    then          
		    #allign and then blend all the images
				align_image_stack -m -a OUT "$file" "${file[i]}.tiff"
				enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 \
				--hard-mask --gray-projector=l-star --output=baseOpt2.tiff OUT*.tiff
			    fi
                    done  
                        shopt -u nullglob
                        echo "Process completed."
                        exit 0
			#exit selected
		        if [[ "$f1" == "2" ]]
			then
		            echo "exit"
			fi
                fi    
		;;

##################################################################################		    
#3.Handling of selection:Exit
	3|3.|EXIT|Exit)
	echo "Selected: Exit"    
        ;;
	*)
	    echo "ERROR:invalid selection"
	    ;;
   
 esac
				       
	       
