package App::Util;

use utf8;
use strict;
use warnings;

use Carp 'croak';
use Exporter;
use base 'Exporter';

our @EXPORT_OK = qw(extend parse_argv);

sub parse_argv {
    my $argv = shift;

    my $mode = $argv && $argv =~ /^(development|production)$/x ? $argv : undef;

    print
        qq{\033[1;31mWARN: App mode requires ('development', 'production'). Example: carton exec $0 development; Now used default: development!\033[0m\n}
        unless $mode;

    $mode ||= 'development';

    return $mode;
}

sub extend {
    my ($conf1, $conf2) = @_;

    foreach (keys %$conf2) {
        if (ref $conf2->{$_} eq 'HASH') {
            extend($conf1->{$_} ||= {}, $conf2->{$_});
        } else {
            $conf1->{$_} = $conf2->{$_};
        }
    }

    return $conf1;
}

1;
