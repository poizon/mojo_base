package App;

use Mojo::Base 'Mojolicious';

use strict;
use warnings;

use DBI;
use JSON::XS;
use Mojo::Log;
use Carp 'croak';
use POSIX 'strftime';
use App::Util 'extend';
use Mojo::Util 'monkey_patch';

our $VERSION = '0.0.16';

has json   => sub { return JSON::XS->new->utf8; };
has conf   => sub { return extend(do './conf/app.conf', do './conf/app-dev.conf'); };
has logger => sub { return Mojo::Log->new(level => 'debug', path => 'logs/dev.log'); };
has db     => sub {
    my $s   = shift;
    my $cfg = $s->conf->{db};
    
    my $dbh = eval {
        DBI->connect(
            "dbi:SQLite:dbname=$cfg->{default}->{db_name}",
            '', # no user
            '', # no passwd
            { RaiseError => 1, PrintError => 1, AutoCommit => 1, sqlite_unicode => 1 }
        );
    } or croak("$DBI::errstr");

    return $dbh;
};

sub startup {
    my $app = shift;

    $app->mode($app->conf->{mode});
    $app->config(hypnotoad => $app->conf->{hypnotoad});
    $app->max_request_size($app->conf->{max_request_size});

    $app->log(Mojo::Log->new({'level' => 'info', 'path' => 'logs/app.log'}));
    $SIG{__WARN__} = sub { unshift @_, $app->log; goto &Mojo::Log::warn; };
    
    $app->static->paths(['static']);
    $app->renderer->paths(['tmpl']);

    $app->secrets([ $app->conf->{session}->{secret_key} ]);
    $app->sessions->cookie_name($app->conf->{session}->{session_name});
    $app->sessions->default_expiration($app->conf->{session}->{default_expiration});

    $app->plugin('App::Helpers');

    # Replace default JSON parser with JSON::XS
    monkey_patch "Mojo::JSON", encode => sub { return $app->json->encode( $_[1] ); };
    monkey_patch "Mojo::JSON", decode => sub { return $app->json->decode( $_[1] ); };
    monkey_patch "Mojo::JSON", j      => sub {
        if(ref $_[0]) { return $app->json->encode( $_[0] ); }
        else          { return $app->json->decode( $_[0] ); }
    };

    my $r = $app->routes;

    # TODO: подумать над обновлением данных
    my $auth = $r->under(
        sub {
            my $s = shift;

            if ($s->session('user_id') && $app->model('User')->check_by_id($s->session('user_id'))) {
                return 1;
            }

            return $s->redirect_to('login');
        }
    );

    $auth->get('/')->to('index#show_index')->name('index');
    $r->get('/login')->to('user#login')->name('login');
    $auth->get('/logout')->to('user#logout')->name('logout');
    $r->post('/auth')->to('user#authenticate')->name('auth');

    my $admin = $r->under('/admin');
    $app->admin_routes($admin);

    return;
}

sub admin_routes {
    my ($app, $r) = @_;

    $r->any('/login')->to('admin#login')->name('admin_login');

    my $auth = $r->under->to('admin#check_auth');

    # Users
    my $users = $auth->under('/users');
    $auth->get('/')->to('admin#admin_index')->name('admin');
    $auth->get('/logout')->to('admin#logout')->name('admin_logout');
    
    $users->get('/'                        )->to('admin-user#list'  )->name('admin_user_list');
    $users->get('/:id', [id => qr/\d+/x]   )->to('admin-user#detail')->name('admin_user_detail');
    $users->post('/:id', [id => qr/\d+/x]  )->to('admin-user#update')->name('admin_user_update');
    $users->any(['GET', 'POST'] => '/new'  )->to('admin-user#create')->name('admin_user_create');
    $users->delete('/:id', [id => qr/\d+/x])->to('admin-user#remove')->name('admin_user_delete');

    # Pages
    $auth->get('/pages')->to('admin-pages#list')->name('admin_pages_list');
    $auth->any('/pages/new')->to('admin-pages#create')->name('admin_pages_create');

    return;
}

1;
