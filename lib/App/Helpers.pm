package App::Helpers;

use Mojo::Base 'Mojolicious::Plugin';

use App::Model;
use Geo::IP2Location::Lite;

use strict;
use warnings;

sub register {
    my ($self, $app) = @_;

    $app->helper(
        model => sub {
            my ($self, $model_name) = @_;
            my $model = App::Model->new(app => $app);
            return $model->get_model($model_name);
        }
    );

    $app->helper(
        in => sub {
            my $self  = shift;
            my $value = shift;
            my $array = shift || return 0;
            return 0 unless defined $value;
            return any { $value eq $_ } @$array;
        }
    );

    $app->helper(
        get_random_string => sub {
            my ($self, $count) = @_;
            $count = 1   if $count < 1;
            $count = 256 if $count > 256;
            my @chars = ('0' .. '9', 'A' .. 'F');
            my $r = join '' => map { $chars[ rand @chars ] } 1 .. $count;
            return $r;
        }
    );

    $app->helper(
        l => sub {
            my ($self, $msg) = @_;
            $self->app->logger($msg);
        }
    );

    $app->helper(
        get_ip => sub {
            my $self = shift;
            my $ip   = $self->req->headers->header('X-Real-IP');
            return $ip || ($self->tx->remote_address || '0.0.0.0');
        }
    );

    $app->helper(
        get_ip_info => sub {
            my ($self, $ip) = @_;
            my $obj          = Geo::IP2Location::Lite->open('bin/IP2LOCATION.BIN');
            my $countryshort = $obj->get_country_short($ip);
            my $countrylong  = $obj->get_country_long($ip);
            my $region       = $obj->get_region($ip);
            my $city         = $obj->get_city($ip);
        }
    );

    return;
}

1;
