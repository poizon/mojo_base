package App::Model::User;

use base App::Model::Base;

use strict;
use warnings;

use Carp 'croak';
use Digest::MD5 qw(md5_hex);
use Digest::SHA qw(sha256_hex);


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

    $data->{uid}      = $s->_generate_uid($data->{email}.$data->{username});
    $data->{password} = md5_hex('' . $data->{password} . $s->app->conf->{salt});

    my @values;
    my $fields = [keys %$data];

    my $sql = 'INSERT INTO '
        . $s->table . ' ('
        . (join ',', @$fields) . ')'
        . ' VALUES ('
        . (join ',', ('?') x @$fields) . ')';

    push @values, $data->{$_} for (@$fields);

    return $s->insert($sql, @values);
}

sub _generate_uid {
    my ($s, $value) = @_;
    return unless $value;
    return md5_hex($value . time . $s->app->conf->{salt})
}

1;
