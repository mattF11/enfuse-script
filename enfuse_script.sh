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
d="$HOME/Converted_Images"
#e="$HOME/enfuse-script"
###################################################################################
#################################################################################

# SELECTION
echo "$USER, select the action (1/2/3)
1. Focus_Stacking
2. Blending
3. Exit
: "
read selection
#check if string is inserted
if [[ -z "$selection" ]]
then
    echo "ERROR:wrong insertion type,interger needed"
else
    echo "CORRECT:insertion type correct"
fi

mkdir -p "$d"
 
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
    find . -type d -name "*${folder}*" > finder.txt
    i=0
    while read line
    do
        echo "[$i] $line"
        ris[$i]="$line"
        ((i++))
    done < finder.txt
    
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
            # single file
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
                        dcraw -T -6 -w -o "$out_file" "$selection1"
                        mv "$out_file" "$selection"
                        echo "wait until the end of the process.."
                    else
                        echo "ERROR:wrong input"
                        exit 1
                    fi
                    echo "File converted."
                fi
            else
                echo "ERROR:wrong input number"
            fi

        else
            #########################################################################
            # directory conversion
            echo "yes:directory conversion selected"
            echo "Do you really want to convert to TIFF(1=yes / 2=no)?"
            read f1_1
            shopt -s nullglob

            for file in "$selection"/*
            do
                if [[ "$f1_1" == "1" ]]
                then
                    out_file="${file%.*}.tiff"
                    dcraw -T -6 -w -o "$out_file" "$file"
                    #mv "$out_file" "$selection"
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
    
    1|1.|Focus_Stacking|Stacking)
	echo "Selected: Focus Stacking"
	cd "$a"
	
	if [[ -e "$e" ]]
	then
	    echo "directory for converted images already exists"
	else
	    echo "directory doesn't exist,creating the working directory.."
	    # cd "$e" | mkdir -p "$d"
	    #mkdir -p "$d"
	fi

	DIR="$(pwd)"
	echo "You need to have files converted to .tiff"
	echo "Do you want to use the built-in converter or an external program (1=built-in / 2=external / 3=skip) ?"
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
	echo "focus stacking section"
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
                    echo "Stack the entire directory or exit (1=directory / 2=exit)?"
                    read f1

		    #shopt -s nullglob #if file not found, empty string
			#repeat conversion process to convert all files in a folder
                        #for file in "$selection"/*
		    #	do

                    if [[ "$f1" == "1" ]]
		    then
			echo "Directory stacking selected"
			cd "$selection" || { echo "ERROR: cannot enter $selection"; exit 1; }
			files=(*.tiff)

			if [[ ${#files[@]} -lt 2 ]]
			then
			    echo "ERROR:you need at least 2 .tiff files"
			    exit 1
			fi

			echo "Align.."
			align_image_stack -m -a OUT "${files[@]}"
			pwd
			echo "Stacking.."
			enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 \
			       --hard-mask --gray-projector=l-star \
			       --contrast-edge-scale=0.3 \
			       --output final.tiff OUT*
			
			echo "Stacking completed."
				#command used to convert images
				#1.allign images,bad idea to stack them without allign
				#commands will:allign,then stack and remove halo focus
#only stack .tiff images,single array
				#N:B--> ${files[@]} use of @,applied to every single file			  # ${files[*]} use of *,can be applied only to a single,viewd as a string: "f1 f2 f3"
				# done
			#single image selected
		        if [[ "$f1" == "2" ]]
			then
		            echo "exit"
			fi
			    fi
		fi
		;;
				       

####################################################################################
####################################################################################
#2.Handling of selection:Blending

    2|2.|Blending)
	echo "Selected: Blending"
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
		    align_image_stack -m -a OUT "${file}"
		fi
            done
	    enfuse --exposure-weight=0 --saturation-weight=0 --contrast-weight=1 \
		   --hard-mask --gray-projector=l-star \
		   --contrast-edge-scale=0.3 \
		   --output=final.tiff OUT*
	    
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
				       
