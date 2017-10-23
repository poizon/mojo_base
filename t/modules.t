use lib 'lib';
use Test::More tests => 7;

use_ok('Mojolicious');
use_ok('JSON::XS');
use_ok('Time::Moment');
use_ok('DBI');
use_ok('DBD::mysql');
use_ok('Test::PerlTidy');
use_ok('Test::Perl::Critic');

done_testing(7);