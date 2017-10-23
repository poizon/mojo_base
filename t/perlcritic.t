#!/usr/bin/env perl

use strict;

use Test::More 'no_plan';
use Test::Perl::Critic;
use File::Spec;

my $rcfile = File::Spec->catfile('t', '.perlcriticrc');

Test::Perl::Critic->import(-profile => $rcfile);
all_critic_ok('lib/App');
