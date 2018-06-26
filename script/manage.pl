#!/bin/perl

=encoding UTF-8

=head1 NAME

manage.pl: Скрипт для управления приложением

=cut

use utf8;
use strict;
use warnings;

use File::Spec;
use Data::Dumper;
use Getopt::Long;
use Carp qw(croak);
use Term::ANSIColor qw(:constants);

use lib 'lib';
use App;

my $app = App->new();

Getopt::Long::Configure('no_ignore_case');

GetOptions(
    # users
    'create-user=i' => \&create_user,

    # migrations
    'initdb'             => \&initdb,
    'show-migrations'    => \&show_migrations,
    'migrate'            => \&migrate,
    'revert-migration=i' => \&revert_migration,
);

use constant COLORS  => {
    red     => RED,
    green   => GREEN,
    blue    => BLUE,
    yellow  => YELLOW,
    magenta => MAGENTA,
    cyan    => CYAN,
    white   => WHITE,
    brown   => BLUE
};

sub initdb {
    my ($opt) = @_;

    _clrprint(undef, ">> Initiation database...\n\n", 'green');
    
    my $sql = <<'EOF';
    CREATE TABLE IF NOT EXISTS `migrations` (
       `id` INTEGER NOT NULL,
       `name` VARCHAR(10) NOT NULL UNIQUE,
       `apply_script` TEXT NOT NULL,
       `revert_script` TEXT NOT NULL,
       `applied_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
       `comment` VARCHAR(250),
       PRIMARY KEY (`id`)
    );
EOF

    unless ($app->model('Base')->raw_do($sql)) {
        croak 'Error in migrations creation!';
    }

    _clrprint(undef, ">> OK\n\n", 'white');

    exit;
}

sub show_migrations {
    my ($opt) = @_;

    _clrprint(undef, ">> Show all applied migrations...\n\n", 'green');

    my $migrations = $app->model('Base')->find_by(
        'SELECT name,applied_at,comment FROM migrations'
    );

    if (@$migrations) {
        _clrprint(undef, ('-' x 80)."\n", 'white');
        
        _clrprint(
            undef,
            "+++ $_->{name}\t$_->{applied_at}\t$_->{comment}\n", 'white'
        ) for (@$migrations);
        
        _clrprint(undef, ('-' x 80)."\n", 'white');
    } else {
        _clrprint(undef, "--- empty ---\n", 'white');
    }

    exit;
}

sub migrate {
    my ($opt) = @_;

    _clrprint(undef, ">> Aplly all new migrations...\n\n", 'green');

    my $migrations_path = File::Spec->catfile('script', 'migrations');

    opendir(my $dh, $migrations_path) or croak "Can not open directory $migrations_path: $@";

    my $files = [ grep {
        -f File::Spec->catfile($migrations_path, $_)
        && $_ =~ /^.+\.sql$/mix
    } readdir($dh) ];

    closedir($dh);

    unless (@$files) {
        _clrprint(undef, "--- Migrations diretory is empty ---\n", 'white');
        exit;
    }

    # Если имеются ранее примененные миграйии - искючаем их из списка
    my $new_migrations = [];

    if (
        my $applied_migration = $app->db->selectall_arrayref(
            'SELECT name FROM migrations', {Slice=>{}}
        )
    ) {
        my %applied_migration = map {$_->{name} => 1} @$applied_migration;
        for (@$files) {
            push @$new_migrations, $_ unless exists $applied_migration{$_};
        }
    }

    unless (@$new_migrations) {
        _clrprint(undef, "--- No new migrations found ---\n", 'white');
        exit;
    }

    # Применяем новые миграции
    for my $migration (sort {$a cmp $b } @$new_migrations) {
        _clrprint('applying', "$migration... ", 'white');

        open(my $fh, '<:encoding(UTF-8)', File::Spec->catfile($migrations_path, $migration));
        $/ = undef;
        my $data = <$fh>;
        close $fh;

        my ($comment) = $data =~ /!Comment:\s+(.+)$/gmx;

        unless ($comment) {
            _clrprint(undef, "FAILED\n\n", 'red');
            _clrprint(undef, "Comment is required attribute!\n", 'white');
            exit 1;
        }
            
        my ($apply_script) = $data =~ /\!Apply:\s?(.+)\--\s?!Revert:/sx;
        $apply_script =~ s/^\s*\n//mg;

        unless ($apply_script) {
            _clrprint(undef, "FAILED\n\n", 'red');
            _clrprint(undef, "Apply sql-script is required!\n", 'white');
            exit 1;
        }

        my ($revert_script) = $data =~ /\!Revert:\s?(.+)/sx;
        $revert_script =~ s/^\s*\n//mg;

        unless ($revert_script) {
            _clrprint(undef, "FAILED\n\n", 'red');
            _clrprint(undef, "Revert sql-script is required!\n", 'white');
            exit 1;
        }
            
        my $is_inserted = $app->model('Base')->insert(
            'INSERT INTO migrations (name,apply_script,revert_script,comment) VALUES (?,?,?,?)',
            [$migration, $apply_script, $revert_script, $comment]
        );

        if ($is_inserted) {
            _clrprint(undef, "OK\n", 'green');
        } else {
            _clrprint(undef, "FAILED\n", 'red');
        }
    }

    exit;
}

sub create_user {
    my ($opt, $value) = @_;

    my $is_admin = $value && $value == 1;

    _clrprint(undef, ">> Creating ".($is_admin ? 'admin user' : 'regular user')."...\n\n", 'green');

    my $username = _input('Enter username: ');
    my $email    = _input('Enter email: ');
    my $passwd   = _input('Enter password: ');

    croak 'Password to short: '.length $passwd.' (min 8)' if length $passwd < 8;
    croak 'Password to long: '.length $passwd.' (max 32)' if length $passwd > 32;

    my $passwd_confirm = _input('Confirm password: ');
    croak 'Error! Password missmatch!' if $passwd ne $passwd_confirm;

    my $result = $app->model('User')->create({
        email        => $email,
        username     => $username,
        password     => $passwd,
        is_admin     => $is_admin,
        is_activated => 1
    });

    croak 'Failed user creation' unless $result;

    _clrprint(undef, "\n>> User '$username' created successful\n\n", 'white');
    
    exit;
}

sub _input {
    my $msg = shift || 'Enter value: ';
    print $msg;
    my $str = <>;
    chomp($str);
    return $str;
}

sub _clrprint {
    my ($event, $msg, $color) = @_;

    return 0 unless $msg;

    my $clr = (defined $color && defined COLORS->{$color})
        ? COLORS->{$color}
        : COLORS->{white};

    print '[', COLORS->{yellow}, uc($event), RESET, '] ' if (defined $event);
    print BOLD, $clr, $msg, RESET;

    return 1;
}

1;

__END__

=head1 USAGE

  carton exec script/manage.pl --create-user=i (1 - supersuer, 0 - regular user)

=head1 AUTHOR

Peter Brovchenko <peter.brovchenko@gmail.ru>

=head1 METHODS

=over

=item B<initdb>

Создание базы данных и создание в ней таблицы миграций

=item B<show_migrations>

Вывод списка примененных миграций

=item B<migrate>

Применить все новые миграции

=item B<create_user>

Создание пользователя

=back

=cut
