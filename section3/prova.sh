#!/bin/bash 

`cat text.txt | sed 's/ \{1,\}/,/g' > text.txt`
