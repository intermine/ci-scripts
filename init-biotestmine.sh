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
git clone --single-branch --branch 'master' --depth 1 https://github.com/intermine/biotestmine.git server

export PSQL_USER=postgres

# Set up properties
PROPDIR=$HOME/.intermine
TESTMODEL_PROPS=$PROPDIR/biotestmine.properties
SED_SCRIPT='s/PSQL_USER/postgres/'

mkdir -p $PROPDIR

echo "#--- creating $TESTMODEL_PROPS"
cp server/data/biotestmine.properties $TESTMODEL_PROPS
sed -i -e $SED_SCRIPT $TESTMODEL_PROPS

# Initialise solr
echo '#---> Setting up solr search'
$SCRIPT_DIR/init-solr.sh

# Install Perl module dependencies for setup.sh
$GET http://cpanmin.us | perl - --self-upgrade
cpanm XML::Parser::PerlSAX
cpanm Text::Glob

# We will need a fully operational web-application
echo '#---> Building and releasing web application to test against'
(cd server && ./setup.sh)
sleep 60 # let webapp startup

# Warm up the keyword search by requesting results, but ignoring the results
$GET "$TESTMODEL_URL/service/search" > /dev/null
# Start any list upgrades
$GET "$TESTMODEL_URL/service/lists?token=test-user-token" > /dev/null
