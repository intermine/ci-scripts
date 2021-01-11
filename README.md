## Warning: Not in use

These scripts have been superseded by [intermine_boot](https://github.com/intermine/intermine_boot). This repository is no longer being maintained.

# ci-scripts

[![Build Status](https://travis-ci.org/intermine/ci-scripts.svg?branch=master)](https://travis-ci.org/intermine/ci-scripts)

Shell scripts for setting up InterMine instances as part of CI.

**Requirements**
- postgresql
- openjdk8 (9 and above won't work)

To run as part of CI from another repo:

```
git clone https://github.com/intermine/ci-scripts
(cd ci-scripts && bash init-biotestmine.sh)
```

As part of a Travis pipeline:

```yml
language: java
sudo: true
jdk:
  - openjdk8
services:
  - postgresql

before_install:
    - git clone https://github.com/intermine/ci-scripts
    - (cd ci-scripts && bash init-biotestmine.sh)
```

If you wish to use the lighter *testmodel*, replace `init-biotestmine.sh` with `init-testmine.sh`.

## Build biotestmine dataset from scratch

The `init-biotestmine.sh` script will by default restore the integrated data from a pre-built database dump. If you wish to build the dataset from scratch instead, you can specify `BUILD_DATASET=true` when invoking the script. Note that this will usually take upwards of 10 minutes.

## Full processing of biotestmine dataset

The `init-biotestmine.sh` script uses a stripped down `project.xml` for processing the dataset. If you miss any features, you can specify `NO_CONFIG_OVERRIDE=true` when invoking the script to use the complete (albeit heavier) `project.xml` in the [biotestmine repository](https://github.com/intermine/biotestmine/blob/master/data/project.xml).
