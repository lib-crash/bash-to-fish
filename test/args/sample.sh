#!/bin/bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ]
then
    echo "this is a help page"
    exit 0
fi


echo "$1"
