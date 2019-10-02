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
