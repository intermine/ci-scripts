#!/bin/bash

set -e

## Using export will cause the envvars to be passed to `./setup.sh` and other scripts.
export MINE=biotestmine
export LITE=true        # Use the biotestmine lite dataset instead of the full.

MINENAME=biotestmine
PROD_DB=$MINENAME
ITEMS_DB=items-$MINENAME
USERPROFILE_DB=userprofile-$MINENAME

if test -z $DB_ENCODING; then
    DB_ENCODING=SQL_ASCII
fi

SCRIPT_DIR=`pwd`/scripts
CONFIG_DIR=`pwd`/config/biotestmine
DUMP_DIR=`pwd`/dumps

if [ -z $(which wget) ]; then
    # use curl
    GET='curl'
else
    GET='wget -O -'
fi

if test -z $NO_CONFIG_OVERRIDE; then
  NO_CONFIG_OVERRIDE=false
fi

if test -z $BUILD_DATASET; then
  BUILD_DATASET=false
fi

cd $HOME

# Pull in the server code.
git clone --single-branch --branch 'master' --depth 1 https://github.com/intermine/biotestmine.git biotestmine

export PSQL_USER=postgres

# Set up properties
PROPDIR=$HOME/.intermine
TESTMODEL_PROPS=$PROPDIR/biotestmine.properties
SED_SCRIPT='s/PSQL_USER/postgres/'

mkdir -p $PROPDIR

echo "#--- creating $TESTMODEL_PROPS"
cp biotestmine/data/biotestmine.properties $TESTMODEL_PROPS
sed -i -e $SED_SCRIPT $TESTMODEL_PROPS

# Initialise solr
echo '#---> Setting up solr search'
$SCRIPT_DIR/init-solr.sh

echo '#---> Setting up perl dependencies'
$SCRIPT_DIR/init-perl.sh

# Copy CI-specific config
if ! $NO_CONFIG_OVERRIDE; then
  cp $CONFIG_DIR/* biotestmine/
fi

# We will need a fully operational web-application
if $BUILD_DATASET; then
  echo '#---> Building and releasing web application to test against'
  cd biotestmine
  ./setup.sh &
  # Gradle doesn't actually finish executing, so we daemonize it, wait and pray
  # that it finishes in time.
  sleep 600
  ./gradlew --stop
  ./gradlew tomcatStartWar &
  sleep 60
else
  echo '#---> Restoring and releasing web application to test against'
  echo '#---> Checking databases...'
  for db in $USERPROFILE_DB $PROD_DB $ITEMS_DB; do
      if psql --list | egrep -q '\s'$db'\s'; then
          echo "#--- $db exists."
      else
          echo "#---> Creating $db with encoding $DB_ENCODING ..."
          createdb --template template0 \
                   --username $PSQL_USER \
                   --encoding $DB_ENCODING \
                   $db
          echo "#---> Restoring $db from dump ..."
          psql --username $PSQL_USER \
               $db < $DUMP_DIR/$db.dump
      fi
  done
  cd biotestmine
  ./gradlew postprocess -Pprocess=create-autocomplete-index
  ./gradlew postprocess -Pprocess=create-search-index
  ./gradlew tomcatStartWar &
  sleep 60
  ./gradlew --stop
  ./gradlew tomcatStartWar &
  sleep 60
fi

# Warm up the keyword search by requesting results, but ignoring the results
$GET "http://localhost:8080/biotestmine/service/search" > /dev/null
# Start any list upgrades
$GET "http://localhost:8080/biotestmine/service/lists" > /dev/null
