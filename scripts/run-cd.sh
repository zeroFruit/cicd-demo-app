#!/bin/bash


# show diff filenames
for FILE in $(git diff --name-only HEAD HEAD~1); do
    echo $FILE
done