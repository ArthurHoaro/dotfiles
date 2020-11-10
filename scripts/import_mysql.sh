#!/bin/bash

shopt -s nullglob

if [[ $# -lt 5 ]]; then
    echo "Usage: $0 <dump directory> <host> <user> <password> <database> <port>"
    exit 1
fi

EXPORT_DIR=$1
HOST=$2
USER=$3
PASSWORD=$4
DATABASE=$5
if [[ $# -eq 6 ]]; then
    PORT=$6
else
    PORT=3306
fi

if [[ ! -d $EXPORT_DIR ]]; then
    echo "`date +"%T"` File not found: $EXPORT_DIR"
    exit 2
fi
for f in ${EXPORT_DIR}/*.sql
do
    echo "`date +"%T"` Import ${f}..."
    mysql -h${HOST} -u${USER} $DATABASE --port=${PORT} < $f
    echo "`date +"%T"` Done."
done

EXTRACT_DIR="/tmp/extractsql"
if [[ ! -d $EXTRACT_DIR ]]; then
    mkdir -p $EXTRACT_DIR
fi

for f in ${EXPORT_DIR}/*.tgz
do
    echo "`date +"%T"` Extract ${f}..."
    tar xfz ${f} -C $EXTRACT_DIR
    echo "`date +"%T"` Done."
    for f2 in ${EXTRACT_DIR}/*.sql
    do
        echo "`date +"%T"` Import ${f2}..."
        mysql -h${HOST} -u${USER} $DATABASE --port=${PORT} < $f2
        echo "`date +"%T"` Done."
    done
    rm -f $EXTRACT_DIR/*
done

for f in ${EXPORT_DIR}/*.gz
do
    echo "`date +"%T"` Extract ${f}..."
    gunzip -k -d -c ${f} > ${EXTRACT_DIR}/extract.sql
    echo "`date +"%T"` Done."
    for f2 in ${EXTRACT_DIR}/*.sql
    do
        echo "`date +"%T"` Import ${f2}..."
        mysql -h${HOST} -u${USER} $DATABASE --port=${PORT} < $f2
        echo "`date +"%T"` Done."
    done
    rm -f $EXTRACT_DIR/*
done
