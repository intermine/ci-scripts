#!/bin/bash

set -e

# Install Perl module dependencies for setup.sh
# cpan has an ugly non-automated first run prompt, so we use cpanm.
curl -L http://cpanmin.us | perl - --sudo App::cpanminus
cpanm --sudo XML::Parser::PerlSAX
cpanm --sudo Text::Glob
