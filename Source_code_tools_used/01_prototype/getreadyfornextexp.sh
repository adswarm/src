#!/bin/bash

# move (copy) current files in output and seedpool folders to data_temp
foldername="data_$(date +%Y_%m_%d_%H_%M_%S)"
echo $foldername

mkdir -p $foldername/seedpool
mkdir -p $foldername/output

mv ./seedpool/* $foldername/seedpool
echo "seedpool stored"

mv ./output/* $foldername/output
echo "output stored"

cp -r ./conf/zzz_backup_start_kit/* ./seedpool
echo "next exp ready"
