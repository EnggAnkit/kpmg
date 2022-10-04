#!/bin/bash
FILE="/tmp/file"
if [ -e $FILE ]
    then
		echo "testfile exists"
        if [ -w $FILE ]
        then
			echo "You have permissions to write"
        else
            chmod u+w $FILE
			if [ "$/" -eq "0" ]
			then
				echo "Write permission given to you"
				else
				echo "There is an issue in assigning permission"
			fi
        fi
    else
        touch $FILE
		echo "This is test file" > $FILE
		chmod u+w $FILE
		echo "$FILE is created and write permission given"
fi