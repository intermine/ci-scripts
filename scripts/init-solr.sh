#!/bin/bash

if test -z $MINE; then
    MINE=intermine
fi

wget http://archive.apache.org/dist/lucene/solr/7.2.1/solr-7.2.1.tgz
tar xzf solr-7.2.1.tgz && ./solr-7.2.1/bin/solr start -force
./solr-7.2.1/bin/solr create -c $MINE-search
./solr-7.2.1/bin/solr create -c $MINE-autocomplete
