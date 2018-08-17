package App::Model::Migration;

use base App::Model::Base;

use strict;
use warnings;


sub new {
    my ($class, %args) = @_;

    my $self = {
        app   => $args{app},
        table => 'migrations'
    };

    bless $self, $class;

    return $self;
}

1;
