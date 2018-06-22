package App::Controller::Admin;

use utf8;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';

use Digest::MD5 qw(md5_hex);
use Data::Dumper;


sub admin_index {
    my $s = shift;
    # $s->get_ip_info('185.46.16.244');
    $s->model('Statistic')->inc_stats('visit');
    return $s->render(template => 'admin/index');
    # if ($s->session->{is_auth} && $s->session->{is_admin}) {
    #     return $s->render(template => 'index');
    # } else {
    #     return $s->redirect_to('admin_login');
    # }
}

sub login {
    my $s = shift;

    if ($s->session('user_id') && $s->session('user_is_activated') && $s->session('user_is_admin')) {
        return $s->redirect_to('admin');
    }
    
    if ($s->req->method eq 'POST') {
        my $username    = $s->param('username');
        my $password    = $s->param('password');
        my $is_rememder = $s->param('is_remember');

        if (my $u = $s->model('User')->get_by(undef, {username => $username})) {
            if (md5_hex("$password" . $s->app->conf->{salt}) eq $u->{password}) {
                $s->session({
                    user_id      => $u->{id},
                    username     => $u->{username},
                    email        => $u->{email},
                    is_auth      => 1,
                    is_admin     => $u->{is_admin},
                    is_activated => $u->{is_activated},
                    created      => $u->{created},
                    last_visited => time
                });

                return $s->redirect_to('admin');
            } else {
                return $s->render(
                    template => 'admin/login',
                    errors => {password => 'Некорректынй пароль'}
                );
            }
        } else {
            return $s->render(
                template => 'admin/login',
                errors => {username => 'Пользователь не найден'}
            );
        }
    } else {
        return $s->render(template => 'admin/login');
    }
}

sub logout {
    my $s = shift;
    $s->session(expires => 1);
    return $s->redirect_to('admin_login');
}

sub check_auth {
    my $s = shift;

    if ($s->session('user_id') && $s->session('is_activated') && $s->session('is_admin')) {
        return 1;
    }

    return $s->redirect_to('admin_login');
}

1;    
