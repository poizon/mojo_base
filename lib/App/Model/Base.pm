=encoding UTF-8

=head1 NAME

App::Model::Base - Базовая модель, которую наследуют все остальные модели

=cut

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

sub insert {
    my ($s, $query, $values) = @_;

    my $sth = $s->db->prepare($query);

    return $sth->execute(@$values);
}

sub remove_by_id {
    my ($s, $id) = @_;

    return 0 unless $id;
    
    my $sth = $s->db->prepare('DELETE FROM '.$s->table.' WHERE id=?');

    return $sth->execute($id);
}

sub remove_by {
    my ($s, $query, $data) = @_;

    my $sql = 'DELETE FROM '.$s->table.' WHERE '.join(' AND ', map {"$_=?"} keys %$data);
    my $sth = $s->db->prepare($sql);

    return $sth->execute(values %$data);;
}

sub check_by_id {
    my ($s, $id) = @_;

    my $result = $s->db->selectrow_arrayref(
        'SELECT 1 FROM '.$s->table.' WHERE id=?', undef, $id
    );

    return ($result && @$result && $result->[0] == 1);
}

sub get_by_id {
    my ($s, $id, $fields) = @_;

    return 0 unless $id;

    $fields = (($fields && @$fields) ? join ',', @$fields : '*');

    return $s->db->selectrow_hashref(qq[SELECT $fields FROM ${\$s->table} WHERE id=?], undef, $id);
}

sub get_by {
    my ($s, $fields, $data) = @_;

    $fields = (($fields && @$fields) ? join ',', @$fields : '*');

    my $sql = "SELECT $fields FROM ".$s->table." WHERE ".join(' AND ', map {"$_=?"} keys %$data);

    return $s->db->selectrow_hashref($sql, undef, values %$data);
}

sub update_by_id {
    my ($s, $id, $data) = @_;

    return 0 unless ($id || $data || %$data);

    my $sql = 'UPDATE '.$s->table.' SET '.join(',', map {"$_=?"} keys %$data).' WHERE id=?';

    my $sth = $s->db->prepare($sql);
    $sth->execute(values %$data, $id);

    return $sth->rows();
}

sub raw_do {
    my ($s, $query) = @_;
    return $s->db->do($query)
}

sub raw_execute {
    my ($s, $query, $params, $bind_values) = @_;

    $params //= {};
        
    my $sth = $s->db->prepare($query, $params);
    
    return $sth->execute((ref $bind_values eq 'ARRAY') ? @$bind_values : $bind_values);
}

sub selectall {
    my ($s, $query, $params, $bind_values) = @_;

    $params //= {Slice=>{}};

    return $s->db->selectall_hashref(
        $query,
        $params,
        (ref $bind_values eq 'ARRAY') ? @$bind_values : $bind_values
    );
}

sub find_by {
    my ($s, $fields, $params, $bind_values) = @_;

    $fields = (($fields && @$fields) ? join ',', @$fields : '*');

    my $sql = "SELECT $fields FROM ".$s->table;

    if ($params->{where}) {
        $sql .= " WHERE ".$params->{where};
    }

    if ($params->{order_by} && @{$params->{order_by}}) {
        $sql .= ' ORDER BY ';
        my $orders = [];
        push @$orders, join(' ', @$_) for ( @{$params->{order_by}} );
        $sql .= join(', ', @$orders);
    }

    if ($params->{limit}) {
        $sql .= ' LIMIT '.$params->{limit};
    }

    if (defined $bind_values && @$bind_values) {
        return $s->db->selectall_arrayref($sql, {Slice=>{}}, @$bind_values);
    } else {
        return $s->db->selectall_arrayref($sql, {Slice=>{}});
    }
}

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

1;

__END__

=head1 USAGE

=head1 AUTHOR

Peter Brovchenko <peter.brovchenko@gmail.ru>

=head1 METHODS

=over

=item B<initdb>

Создание базы данных и создание в ней таблицы миграций

=back

=cut
