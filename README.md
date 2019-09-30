# ci-scripts

[![Build Status](https://travis-ci.org/intermine/ci-scripts.svg?branch=master)](https://travis-ci.org/intermine/ci-scripts)

Shell scripts for setting up InterMine instances as part of CI.

To run as part of CI from another repo:

```
git clone git@github.com:intermine/ci-scripts.git
bash ci-scripts/init-testmine.sh
```

As part of a Travis pipeline:

```yml
before_install:
    - git clone git@github.com:intermine/ci-scripts.git
    - bash ci-scripts/init-testmine.sh
```
