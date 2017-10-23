#!/usr/bin/env perl -w

use utf8;
use strict;
use warnings;

use lib 'lib';
use App;

my $app = App->new();

my ($username,$email,$passwd,$passwd_confirm);

print ">> Creating superuser...\n\n";

print 'Enter username: ';
$username = <>;
chomp($username);

print 'Enter email: ';
$email = <>;
chomp($email);

print 'Enter password: ';
$passwd = <>;
chomp($passwd);

print 'Confirm password: ';
$passwd_confirm = <>;
chomp($passwd_confirm);

if ($passwd ne $passwd_confirm) {
	print "\nError! Password missmatch!\n";
	exit(1);
}

my $result = $app->model('User')->create({
    email    => $email,
    username => $username,
    password => $passwd
});

print($result ? "Successful\n\n" : "Fail\n\n");

exit(0);
