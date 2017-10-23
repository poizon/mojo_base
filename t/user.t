use lib 'lib';

use Test::More tests => 11;
use Test::Mojo;

use_ok('App');
use_ok('App::Controller::User');

my $t = Test::Mojo->new('App');
my $self = $t->app;

$t->get_ok('/login')
    ->status_is('200', 'Login form')
    ->element_exists('form input[name=username]', 'Input for username field')
    ->element_exists('form input[name=password]', 'Input for password field')
    ->element_exists('form button[type=submit]', 'Submit button');

$t->get_ok('/logout')
    ->status_is('302', 'Logout for non authorize user')
    ->get_ok('/login')->status_is('200', 'Redirect to login form');


done_testing(11);
