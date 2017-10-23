package App::Model::Statistic;

use base App::Model::Base;

use strict;
use warnings;
use Time::Moment;

use Data::Dumper;

sub new {
    my ($class, %args) = @_;

    my $self = {
        app   => $args{app},
        table => 'stats',
        _available_stats => {
            'visits'       => 1,
            'visits.new'   => 1,
            'visits.admin' => 1,
            'logins'       => 1,
            'regs'         => 1,
        }
    };

    bless $self, $class;
    return $self;
}

sub inc_stats {
    my ($s, $name, $value) = @_;

    return 0 unless $s->_check_name($name);

    $value //= 1;

    my $sql = <<'EOF';
INSERT INTO stats (name,value,dt) VALUES (?,?,?)
ON DUPLICATE KEY UPDATE value=value+?
EOF

    return $s->_upsert_stats($sql, $name, $value);
}

sub dec_stats {
    my ($s, $name, $value) = @_;
    
    return 0 unless $s->_check_name($name);
    
    $value //= 1;
    
    my $sql = <<'EOF';
INSERT INTO stats (name,value,dt) VALUES (?,?,?)
ON DUPLICATE KEY UPDATE value=value-?
EOF

    return $s->_upsert_stats($sql, $name, $value);
}

sub set_stats {
    my ($s, $name, $value) = @_;

    return 0 unless $s->_check_name($name);
    return 0 unless $value;

    my $sql = <<'EOF';
INSERT INTO stats (name,value,dt) VALUES (?,?,?)
ON DUPLICATE KEY UPDATE value=?
EOF

    return $s->_upsert_stats($sql, $name, $value);
}

sub _upsert_stats {
    my ($s, $sql, $name, $value) = @_;

    my $dt = Time::Moment
        ->now_utc()
        ->with_minute(0)
        ->with_second(0)
        ->with_millisecond(0)
        ->strftime("%Y-%m-%dT%H:%M:%S");

    return $s->raw_execute($sql, {async => 1}, [$name, $value, $dt, $value]);
}

sub _check_name {
    my ($s, $name) = @_;
    return exists $s->{_available_stats}->{$name};
}

1;
