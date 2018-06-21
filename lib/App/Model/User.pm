package App::Model::User;

use base App::Model::Base;

use strict;
use warnings;

use Carp 'croak';
use Digest::MD5 qw(md5_hex);


sub new {
    my ($class, %args) = @_;

    my $self = {
        app   => $args{app},
        table => 'users'
    };

    bless $self, $class;
    return $self;
}

sub create {
    my ($s, $data) = @_;

    $data->{password} = md5_hex('' . $data->{password} . $s->app->conf->{salt});
    $data->{uid}      = md5_hex('' . $data->{email} . $data->{username} . time . $s->app->conf->{salt});

    my $values = [];
    my $fields = [ keys %$data ];

    my $sql =
          'INSERT INTO '
        . $s->table . ' ('
        . (join ',', @$fields) . ')'
        . ' VALUES ('
        . (join ',', ('?') x @$fields) . ')';

    push @$values, $data->{$_} for (@$fields);

    return $s->insert($sql, $values);
}

sub get_by_username {
    my ($s, $username) = @_;

    return $s->get_by(undef, {username => $username});
}

1;
