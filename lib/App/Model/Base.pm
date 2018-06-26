package App::Model::Base;

use strict;
use warnings;
use DBI;
use Data::Dumper;

use Carp 'croak';

sub new {
    my ($class, %args) = @_;

    my $self = {
        app   => $args{app},
        table => ''
    };

    bless $self, $class;
    return $self;
}

sub app   { return shift->{app};   }
sub db    { return shift->app->db; }
sub table { return shift->{table}; }

sub transaction_begin {
    my $s = shift;
    $s->db->{AutoCommit} = 0;
    return;
}

sub commit {
    my $s = shift;
    $s->db->commit();
    $s->db->{AutoCommit} = 1;
    return;
}

sub rollback {
    my $s = shift;
    $s->db->rollback();
    $s->db->{AutoCommit} = 1;
    return;
}

sub insert {
    my ($s, $query, $values) = @_;

    my $sth = $s->db->prepare($query);
    my $result = eval { $sth->execute(@$values) } or croak($@);

    return $result;
}

sub remove_by_id {
    my ($s, $id) = @_;

    return 0 unless $id;
    
    my $result = eval {
        my $sth = $s->db->prepare('DELETE FROM '.$s->table.' WHERE id=?');
        $sth->execute($id);
    } or croak("$@");

    return $result;
}

sub remove_by {
    my ($s, $query, $data) = @_;

    my $sql = 'DELETE FROM '.$s->table.' WHERE '.join(' AND ', map {"$_=?"} keys %$data);
    my $sth = $s->db->prepare($sql);
    my $result = eval { $sth->execute(values %$data); } or croak("$@");

    return $result;
}

sub check_by_id {
    my ($s, $id) = @_;

    my $result = eval {
        $s->db->selectrow_arrayref('SELECT 1 FROM '.$s->table.' WHERE id=?', undef, $id);
    } or croak("$@");

    return (@$result && $result->[0] == 1);
}

sub get_by_id {
    my ($s, $id, $fields) = @_;

    return 0 unless $id;

    $fields = (($fields && @$fields) ? join ',', @$fields : '*');

    my $result = eval {
        $s->db->selectrow_hashref(qq[SELECT $fields FROM ${\$s->table} WHERE id=?], undef, $id);
    } or croak("$@");

    return $result;
}

sub get_by {
    my ($s, $fields, $data) = @_;

    $fields = (($fields && @$fields) ? join ',', @$fields : '*');

    my $sql = "SELECT $fields FROM ".$s->table." WHERE ".join(' AND ', map {"$_=?"} keys %$data);

    my $result = eval {
        $s->db->selectrow_hashref($sql, undef, values %$data);
    };

    croak("$DBI::errstr") if $DBI::err;
    
    return $result;
}

sub update_by_id {
    my ($s, $id, $data) = @_;

    return 0 unless ($id || $data || %$data);

    my $sql = 'UPDATE '.$s->table.' SET '.join(',', map {"$_=?"} keys %$data).' WHERE id=?';

    my $result = eval {
        my $sth = $s->db->prepare($sql);
        $sth->execute(values %$data, $id);
        $sth->rows();
    } or croak("$@");
    
    return $result;
}

sub raw_do {
    my ($s, $query) = @_;
    my $result = eval { $s->db->do($query) } or croak("$@");
    return $result;
}

sub raw_execute {
    my ($s, $query, $params, $bind_values) = @_;

    $params //= {};
        
    my $result = eval {
        my $sth = $s->db->prepare($query, $params);
        $sth->execute((ref $bind_values eq 'ARRAY') ? @$bind_values : $bind_values);
    } or croak("$@");

    return $result;
}

sub find_by {
    my ($s, $query, $params, $bind_values) = @_;

    return 0 unless $query;

    $params //= {Slice=>{}};

    my $res;
    
    if (defined $bind_values && @$bind_values) {
        $res = eval {
            $s->db->selectall_arrayref($query, $params, @$bind_values);
        } or croak("$@");
    } else {
        $res = eval {
            $s->db->selectall_arrayref($query, $params);
        } or croak("$@");
    }

    return $res;
}

1;

__END__

=encoding UTF-8

=head1 NAME

App::Model::Base - Базовая модель, которую наследуют все остальные модели

=cut
