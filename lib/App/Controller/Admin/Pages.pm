package App::Controller::Admin::Pages;

use Mojo::Base 'Mojolicious::Controller';

use utf8;
use strict;
use warnings;

sub list {
    my $s = shift;
    return $s->render(template => 'admin/pages/list');
}

sub create {
    my $s = shift;
    return $s->render(template => 'admin/pages/create', page => undef);
}


1;
