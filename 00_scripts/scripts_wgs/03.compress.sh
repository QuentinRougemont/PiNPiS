#!/bin/bash                                  

find . -type f -name '*.vcf' | parallel bgzip --best
