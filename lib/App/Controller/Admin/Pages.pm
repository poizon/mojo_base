package App::Controller::Admin::Pages;

use Mojo::Base 'Mojolicious::Controller';

use utf8;
use strict;
use warnings;

sub list {
    my $s = shift;
    my $pages = $s->model('Page')->get_all() || [];
    return $s->render(template => 'admin/pages/list', pages => $pages);
}

sub create {
    my $s = shift;

    if ($s->req->method eq 'POST') {
        my $params = $s->req->body_params->to_hash();

        my $result = $s->model('Page')->create({
                title     => $params->{title},
                body      => $params->{body},
                user_id   => $s->session('user_id'),
                is_public => $params->{body} eq 'on' ? 1 : 0
            }
        );

        if ($result) {
            return $s->redirect_to('admin_pages_list');
        } else {
            return $s->render(template => 'admin/pages/create', errors => {}, page => undef);
        }
    } else {
        return $s->render(template => 'admin/pages/create', page => undef);
    }
}

1;
