package t::lib::Bootstrap;

use Modern::Perl;

use DBI;
use File::Temp qw( tempfile );
use XML::LibXML;

our $database;
sub import {
    my ($self, %args) = @_;

    require C4::Context;
    C4::Context->import;

    my $host = C4::Context->config('hostname');
    my $port = C4::Context->config('port');
    $database = C4::Context->config("database_test") || C4::Context->config('database');
    my $user = C4::Context->config('user');
    my $pass = C4::Context->config('pass');

    my $dbh = DBI->connect("dbi:mysql:;host=$host;port=$port", $user, $pass, {
        RaiseError => 1,
        PrintError => 0,
    });

    $dbh->do("DROP DATABASE IF EXISTS $database");
    $dbh->do("CREATE DATABASE $database");

}

END {
    my $dbh = C4::Context->dbh;
    $dbh->do("DROP DATABASE IF EXISTS $database") if $database;
    Koha::Caches->get_instance()->flush_all;
    Koha::Caches->get_instance('config')->flush_all;
};

1;
