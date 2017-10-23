package App::Model;

use Mojo::Loader qw(find_modules load_class);
use Mojo::Base -base;

use strict;
use warnings;
use Carp 'croak';

has modules => sub { {} };

sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);

    my $model_packages = [ find_modules 'App::Model' ];

    for my $pm (@$model_packages) {
        my $e = load_class $pm;
        croak("Loading '$pm' failed: $e") if ref $e;
        my ($basename) = $pm =~ /App::Model::(.*)/x;
        $self->modules->{$basename} = $pm->new(%args);
    }

    return $self;
}

sub get_model {
    my ($self, $model) = @_;
    return $self->modules->{$model} || croak("Unknown model '$model'");
}

1;
