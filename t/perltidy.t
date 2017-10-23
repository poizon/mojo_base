#!/usr/bin/env perl

use strict;

use Test::More;
use Test::PerlTidy;

run_tests(
	path       => 'lib/App',
	perltidyrc => 't/.perltidyrc',
	exclude    => [],
);
