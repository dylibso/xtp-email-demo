#!/bin/bash
export PERLBREW_ROOT=/home/gavin/perl5/perlbrew
export PERLBREW_HOME=/home/gavin/.perlbrew
source ${PERLBREW_ROOT}/etc/bashrc
perlbrew use perl-5.40.0
set -o allexport
source /home/gavin/dev/xtp-email-demo/.env
set +o allexport
exec perl /home/gavin/dev/xtp-email-demo/autoresponder.pl "$@"
