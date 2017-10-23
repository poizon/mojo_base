package App::Controller::User;

use Mojo::Base 'Mojolicious::Controller';

use Digest::MD5 qw(md5_hex);


sub authenticate {
    my $s = shift;

    # TODO: провалидировать данные
    my $username = $s->param('username');
    my $password = $s->param('password');

    if (my $u = $s->model('User')->get_by_username($username)) {
        if (md5_hex("$password" . $s->app->conf->{salt}) eq $u->{password}) {

            my $user_data = {
                id           => $u->{id},
                username     => $u->{username},
                email        => $u->{username},
                is_auth      => 1,
                is_admin     => $u->{is_admin},
                is_activated => $u->{is_activated},
                created      => $u->{created},
                last_visited => $u->{last_visited}
            };

            $s->session($user_data);

            return $s->redirect_to('/');
        } else {
            return $s->redirect_to('login');
        }
    } else {
        return $s->redirect_to('login');
    }

}

sub login {
    my $s = shift;

    unless ($s->session('is_auth')) {
        return $s->render(template => 'user/login');
    }

    return $s->redirect_to('index');
}

sub logout {
    my $s = shift;
    $s->session(expires => 1);
    return $s->redirect_to($s->param('next') ? $s->param('next') : 'index');
}

1;
