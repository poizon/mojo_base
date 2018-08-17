=encoding UTF-8

=head1 NAME

App::Model::Base - Базовая модель, для наследования остальными моделями

=cut

package App::Model::Base;

use utf8;
use strict;
use warnings;

use DBI;
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
    my ($s, $sql, @bind_values) = @_;

    my $sth = $s->db->prepare($sql);

    return $sth->execute(@bind_values);
}

sub remove {
    my ($s, %where) = @_;

    my $sth = $s->db->prepare(
        'DELETE FROM '.$s->table.' WHERE '.join(' AND ', map {"$_=?"} keys %where)
    );

    return $sth->execute(values %where);
}

sub is_exists {
    my ($s, %where) = @_;

    my $result = $s->db->selectrow_arrayref(
        'SELECT 1 FROM '.$s->table.' WHERE '.join(' AND ', map {"$_=?"} keys %where),
        undef,
        values %where
    );

    return @$result && $result->[0];
}

sub get {
    my ($s, $fields, %where) = @_;

    $fields = (($fields && @$fields) ? join ',', @$fields : '*');

    return $s->db->selectrow_hashref(
        "SELECT $fields FROM $s->table WHERE ".join(' AND ', map {"$_=?"} keys %where),
        undef,
        values %where
    );
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
    my ($s, $sql) = @_;
    return $s->db->do($sql)
}

sub raw_execute {
    my ($s, $sql, $params, @bind_values) = @_;
    my $sth = $s->db->prepare($sql, $params);
    return $sth->execute(@bind_values);
}

sub find {
    my ($s, $fields, $params) = @_;

    return unless $params && $params->{where} && %{$params->{where}};

    my @bind_values = values %{$params->{where}};
    
    $fields = (($fields && @$fields) ? join ',', @$fields : '*');

    my $sql = "SELECT $fields FROM $s->table WHERE " . join(' AND ', map {"$_=?"} keys %{$params->{where}});

    if ($params->{order_by} && %{$params->{order_by}}) {
        $sql .= ' ORDER BY ';
        $sql .= join ',', map {"$_ $params->{order_by}->{$_}"} keys %{$params->{order_by}};
    }

    if ($params->{limit}) {
        $sql .= ' LIMIT ?';
        push @bind_values, $params->{limit};
    }

    if ($params->{offset}) {
        $sql .= ' OFFSET ?';
        push @bind_values, $params->{offset};
    }
    
    return $s->db->selectall_arrayref($sql, {Slice=>{}}, @bind_values);
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

=head1 AUTHOR

Peter Brovchenko <peter.brovchenko@gmail.ru>

=head1 METHODS

=cut

=head2 B<new>($class, %args)

Создать новый инстанс базовой модели.

  %args - набор произвольных аргументов

=cut

=head2 B<insert>($s, $sql, @bind_values)

Сделать новую запись в базу.

  $sql         - SQL-запрос
  @bind_values - значения для использования в placeholder's

=cut

=head2 B<remove>($s, %where)

Удалить запись из базы.

  %where - условия выборки

=cut

=head2 B<is_exists>($s, %where)

Проверить существование записи.

  %where - условия выборки

=cut

=head2 B<get>($s, $fields, %where)

Выбрадь одну запись из базы.

  $fields - список полей для выборки
  %where  - условия выборки

=cut

=head2 B<raw_do>($s, $sql)

Выполнить произвольный запрос к базе.

  $sql - SQL-запрос

=cut

=head2 B<raw_execute>($s, $sql, $params, @bind_values)

Выполнить произвольный запрос к базе и получить результат его выполнения

  $sql         - SQL-запрос
  $params      - параметры для execute
  @bind_values - значения для использования в placeholder's

=cut

=head2 B<find>($s, $fields, $params)

Сделать выборку записей из базы.

  $fields - список полей для выборки
  $params - параметры для запроса
    $params->{where}    - условия выборки
    $params->{order_by} - параметры сортировки
    $params->{limit}    - LIMIT
    $params->{offset}   - OFFSET

  @bind_values - значения для использования в placeholder's

=cut

=head2 B<transaction_begin>

Начать транзакцию.

=cut

=head2 B<commit>

Завершить транзакцию.

=cut

=head2 B<rollback>

Откатить транзакцию.

=cut
