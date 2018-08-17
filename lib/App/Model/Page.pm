package App::Model::Page;

use base App::Model::Base;

use strict;
use warnings;

use Carp 'croak';
use Digest::MD5 qw(md5_hex);


sub new {
    my ($class, %args) = @_;

    my $self = {
        app   => $args{app},
        table => 'pages'
    };

    bless $self, $class;

    return $self;
}

sub all_with_user {
    my $s = shift;

    my $sql = <<'EOF';
SELECT p.id, p.title, p.body, p.dt_created, p.dt_modified, u.id AS user_id, u.username, u.email
  FROM pages AS p
       LEFT JOIN users AS u
       ON p.user_id = u.id
 LIMIT 100
EOF

    return $s->db->selectall_arrayref($sql, {Slice=>{}});
}

sub create {
    my ($s, $data) = @_;

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

1;
