package App::Model::Session;

use base App::Model::Base;

use strict;
use warnings;
use Time::Moment;
use Digest::MD5 qw(md5_hex);


sub new {
    my ($class, %args) = @_;

    my $self = {
        app   => $args{app},
        table => 'sessions'
    };

    bless $self, $class;
    return $self;
}

sub create {
    my $s = shift;

    my $sql             = qq[INSERT INTO ${\$s->table} (session_key,expired) VALUES (?,?)];
    my $new_session_key = md5_hex($s->get_random_string(10) . time . $s->conf->{salt});
    my $session_expired = Time::Moment->now()->plus_seconds($s->conf->{default_expiration});

    if ($s->insert($sql, [ $new_session_key, $session_expired ])) {
        return $new_session_key;
    } else {
        return 0;
    }
}

sub get_by_session_key {
    my ($s, $session_key) = @_;

    return 0 unless $session_key;

    my $result = eval {
        $s->app->db->selectrow_hashref("SELECT * FROM ${\$s->table} WHERE session_key=?", undef,
            $session_key);
    };

    return $result;
}

sub update_by_skey {
    my ($s, $skey, $data) = @_;

    return 0 unless ($skey || $data || %$data);

    my $sth = $s->app->db->prepare("UPDATE ${\$s->table} SET session_data=?,expired=? WHERE session_key=?");

    my $result = eval {
        $sth->execute($data, Time::Moment->now()->plus_seconds($s->conf->{default_expiration}), $skey);
    };

    return $result;
}

1;
