#!/bin/bash

set -e

SCRIPT_DIR=`pwd`/scripts

if [ -z $(which wget) ]; then
    # use curl
    GET='curl'
else
    GET='wget -O -'
fi

cd $HOME

# Pull in the server code.
git clone --single-branch --branch 'dev' --depth 1 https://github.com/intermine/intermine.git testmodel

export PSQL_USER=postgres

# Set up properties
PROPDIR=$HOME/.intermine
TESTMODEL_PROPS=$PROPDIR/testmodel.properties
SED_SCRIPT='s/PSQL_USER/postgres/'

mkdir -p $PROPDIR

echo "#--- creating $TESTMODEL_PROPS"
cp testmodel/config/testmodel.properties $TESTMODEL_PROPS
sed -i -e $SED_SCRIPT $TESTMODEL_PROPS

# Initialise solr
echo '#---> Setting up solr search'
$SCRIPT_DIR/init-solr.sh

# We will need a fully operational web-application
echo '#---> Building and releasing web application to test against'
cd testmodel/testmine
./setup.sh &
sleep 60 # let webapp startup
./gradlew --stop
./gradlew tomcatStartWar &
sleep 60

# Warm up the keyword search by requesting results, but ignoring the results
$GET "http://localhost:8080/intermine-demo/service/search" > /dev/null
# Start any list upgrades
$GET "http://localhost:8080/intermine-demo/service/lists?token=test-user-token" > /dev/null
