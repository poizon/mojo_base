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

## DEPRECATED: появился универсальный метод в базовой модели: get_by()
# sub get_by_uid {
#     my ($s, $uid) = @_;

#     return 0 unless $uid;

#     my $result =
#         eval { $s->app->db->selectrow_hashref('SELECT * FROM ' . $s->table . ' WHERE uid=?', undef, $uid); };

#     return $result;
# }

# sub get_by_email {
#     my ($s, $email) = @_;

#     return 0 unless $email;

#     my $result = eval {
#         $s->app->db->selectrow_hashref('SELECT * FROM ' . $s->table . ' WHERE email=?', undef, $email);
#     };

#     return $result;
# }

# sub get_by_username {
#     my ($s, $username) = @_;

#     return 0 unless $username;

#     my $result = eval {
#         $s->{app}->db->selectrow_hashref('SELECT * FROM ' . $s->table . ' WHERE username=? LIMIT 1',
#             undef, $username);
#     } or do {
#         croak("$@");
#     };

#     return $result;
# }

1;
