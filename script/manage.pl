#!/bin/perl

=encoding UTF-8

=head1 NAME

manage.pl: Скрипт для управления приложением

=cut

use utf8;
use strict;
use warnings;

use lib 'scripts/lib';

use Getopt::Long;
use Carp qw(carp croak);
use Term::ANSIColor qw(:constants);

Getopt::Long::Configure('no_ignore_case');

GetOptions(
    # users
    'create-user=i'       => \&create_user,
    'set-user-password=s' => \&set_user_password,

    # migrations
    'show-migrations'  => \&show_migrations,
    'migrate-up'       => \&migrate_up,
    'migrate-down=i'   => \&migrate_down,
) or croak('Invalid command');

use constant COLORS  => {
    red     => RED,
    green   => GREEN,
    blue    => BLUE,
    yellow  => YELLOW,
    magenta => MAGENTA,
    cyan    => CYAN,
    white   => WHITE,
    brown   => BLUE
};

sub create_user {
    my ($opt, $value) = @_;

    my $is_superuser = $value && $value == 1;

    _clrprint(undef, ">> Creating ".($is_superuser ? 'superuser' : 'user')."...\n\n", 'green');

    my $username = _input('Enter username: ');
    my $email    = _input('Enter email: ');
    my $passwd   = _input('Enter password: ');
    
    croak('Password to long: '.length $passwd.' (max 32)') if length $passwd > 32;

    my $passwd_confirm = input('Confirm password: ');
    croak("\nError! Password missmatch!\n") if $passwd ne $passwd_confirm;

    # my $result = add_user({
    #     username     => substr($username, 0, 50),
    #     email        => substr($email, 0, 50),
    #     uid          => md5_hex($username.$email.time.$UID_SALT),
    #     password     => md5_hex($passwd.$PAS_SALT),
    #     is_activated => 1,
    #     is_admin     => $value == 1 ? 1 : 0
    # });

    # croak("Failed user creation\n") unless ($result);

    _clrprint(undef, "\n>> User '$username' created successful\n\n", 'green');
    
    exit;
}

sub _input {
    my $msg = shift || 'Enter value: ';
    print $msg;
    my $str = <>;
    chomp($str);
    return $str;
}

sub _clrprint {
    my ($event, $msg, $color) = @_;

    return 0 unless $msg;

    my $clr = (defined $color && defined COLORS->{$color})
        ? COLORS->{$color}
        : COLORS->{white};

    print '[', COLORS->{yellow}, uc($event), RESET, '] ' if (defined $event);
    print BOLD, $clr, $msg, RESET;

    return 1;
}

__END__

=head1 USAGE

  carton exec script/manage.pl --create-user=i (1 - supersuer, 0 - refular user)

=head1 AUTHOR

Peter Brovchenko <peter.brovchenko@gmail.ru>

=cut
