package App::Controller::Admin::User;

use Mojo::Base 'Mojolicious::Controller';

use utf8;
use strict;
use warnings;

use Data::Dumper;

sub list {
    my $s = shift;
    my $users = $s->model('User')->find(
        ['id','username','email','first_name','last_name','created','is_activated','is_admin'],
        {limit => 100}
    );
    return $s->render(template => 'admin/users/list', users => $users);
}

sub create {
    my $s = shift;

    if ($s->req->method eq 'POST') {
        my $params = $s->req->body_params->to_hash();
        my $avatar = $s->param('avatar');

        # TODO: провалидировать данные
    
        my $result = $s->model('User')->create({
            username     => $params->{username},
            email        => $params->{email},
            first_name   => $params->{first_name},
            last_name    => $params->{last_name},
            password     => $params->{password},
            is_activated => $params->{is_active} eq 'on' ? 1 : 0,
            is_admin     => $params->{is_admin} eq 'on' ? 1 : 0
        });
        
        if ($result) {
            return $s->redirect_to('admin_user_list');
        } else {
            return $s->render(template => 'admin/users/create', errors => {}, user => undef);
        }
    } else {
        return $s->render(template => 'admin/users/create', user => undef);
    }
}

sub detail {
    my $s = shift;
    my $id = $s->stash('id');

    if (my $u = $s->model('User')->get(undef, id => $id)) {
        return $s->render(template => 'admin/users/create', user => $u);
    }

    return $s->render(text => 'error');
}

sub update {
    my $s = shift;

    my $params = $s->req->body_params->to_hash();
    my $id = $params->{id};

    # TODO: провалидировать данные
    if (my $u = $s->model('User')->get(undef, id => $id)) {
        my $result = $s->model('User')->update(
            {
                username     => $params->{username} || $u->{username},
                email        => $params->{email} || $u->{email},
                first_name   => $params->{first_name} || $u->{first_name},
                last_name    => $params->{last_name} || $u->{last_name},
                password     => $params->{password} || $u->{password},
                is_activated => $params->{is_active} eq 'on' ? 1 : 0,
                is_admin     => $params->{is_admin} eq 'on' ? 1 : 0
            },
            id => $id
        );

        if ($result) {
            if ($id == int($s->session('user_id'))) {
                $s->session(
                    username     => $u->{username},
                    email        => $u->{email},
                    is_admin     => $u->{is_admin},
                    is_activated => $u->{is_activated},
                    last_visited => time
                );
            }
            return $s->redirect_to('admin_user_list');
        } else {
            return $s->render(template => 'admin/users/create', errors => {}, user => $params);
        }
    }

    return $s->reply->not_found;
}

sub remove {
    my $s = shift;
    my $id = int($s->stash('id'));

    if (my $r = $s->model('User')->remove(id => $id)) {
        $s->session(expires => 1) if ($id == int($s->session('user_id')));
        return $s->render(json => {status => 'ok'});
    }
    
    return $s->render(json => {error => {message => ''}});
}

1;

__END__

=encoding UTF-8

=head1 NAME

App::Controller::Admin::User - 

=cut
