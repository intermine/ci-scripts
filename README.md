# testmine-ci

Common intermine testmine install scripts used in multiple repos.

To run as part of CI from another repo:

```
git clone git@github.com:intermine/testmine-ci.git
bash testmine-ci/init-testmine.sh
```

As part of a travis pipeline:

```yml
before_install:
    - git clone git@github.com:intermine/testmine-ci.git
    - bash testmine-ci/init-testmine.sh
```
