#!/usr/bin/perl -w

use strict;
use warnings;

use lib 'lib';
use Carp 'croak';
use App;

use Data::Dumper;

my $app     = App->new();
my $SQL_DIR = 'script/migrations/sql/';

warn Dumper $app->db;

# Получить список файлов в каталоге с sql

# Поочередно проверять, накачена ли такая миграция или нет. Если нет - накатить.

opendir my $dh, $SQL_DIR or croak("Could not open $SQL_DIR: $!");
my $files = [ grep { $_ ne '.' && $_ ne '..' } readdir $dh ];
closedir($dh);

for (@$files) {
    my ($number, $name) = split /_/, $_;

    my $result = $app->db->selectrow_array("SELECT id FROM migrations WHERE name = ?", undef, $name);
}

