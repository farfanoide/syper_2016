#!/usr/bin/env bash


DEST_DIR=/home/core/syper
[ -d $DEST_DIR ] && rm -rf $DEST_DIR
mkdir -p $DEST_DIR
cp -r ./{keys,certs} $DEST_DIR
