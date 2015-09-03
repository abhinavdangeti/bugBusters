#!/bin/bash

#This script detects mismatches in the number of items in memory
#and disk for a couchbase bucket.
#Do set BIN_DIR, DATA_DIR and BUCKET correctly for correct results.

BIN_DIR="/Users/abhinavdangeti/Documents/couchbaseS/install/bin"
DATA_DIR="/Users/abhinavdangeti/Documents/couchbaseS/ns_server/data/n_0/data"
BUCKET="default"

NUM_VBUCKETS=1024

IP='127.0.0.1'
PORT='12000'

writeOutputToFile=false

inMemCountFile="./temp_inMem.txt"
diskCountFile="./temp_inDisk.txt"

if [ "$writeOutputToFile" = true ] ; then
    rm $inMemCountFile
    rm $diskCountFile
fi

count=0
for (( i=0; i<$NUM_VBUCKETS; i++ ))
do
    x=`$BIN_DIR/cbstats $IP:$PORT vbucket-details $i | grep 'num_items'`
    if [ "$writeOutputToFile" = true ] ; then
        printf '%s ' $x >> $inMemCountFile
        printf '\n' >> $inMemCountFile
    fi
    mem_count=${x##* }
    y=`$BIN_DIR/couch_dbinfo $DATA_DIR/$BUCKET/$i.couch.* | grep '  doc count'`
    if [ "$writeOutputToFile" = true ] ; then
        z='vb: '$i' '$y
        printf '%s ' $z  >> $diskCountFile
        printf '\n' >> $diskCountFile
    fi
    disk_count=${y##* }

    if [ -n "$mem_count" ] && [ -n "$disk_count" ] ; then
        if [ "$mem_count" != "$disk_count" ] ; then
            echo 'Mismatch:: vb: '$i' => in-memory: '$mem_count'; in-disk: '$disk_count
            let "count++"
        fi
    fi
done

echo '====================================='
echo 'Mismatches detected in: '$count' vbuckets!'
echo '====================================='
