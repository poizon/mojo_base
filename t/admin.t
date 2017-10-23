use lib 'lib';

use Test::More tests => 7;
use Test::Mojo;

use_ok('App');
use_ok('App::Controller::Admin');

my $t = Test::Mojo->new('App');
my $self = $t->app;

$t->get_ok('/admin')
    ->status_is('200', 'Admin login form')
    ->element_exists('form input[name=username]', 'Input for username field')
    ->element_exists('form input[name=password]', 'Input for password field')
    ->element_exists('form button[type=submit]', 'Submit button');

done_testing(7);
