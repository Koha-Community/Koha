package t::lib::Bootstrap;

use Modern::Perl;

use DBI;
use File::Temp qw( tempfile );
use XML::LibXML;

sub import {
    my ($self, %args) = @_;

    unless (defined $args{database}) {
        die "Test database is not defined";
    }

    $args{marcflavour} //= 'MARC21';

    my $xml = XML::LibXML->load_xml(location => $ENV{KOHA_CONF});
    my $root = $xml->documentElement();
    my ($databaseElement) = $root->findnodes('//config/database');
    my $currentDatabase = $databaseElement->textContent();

    if ($currentDatabase eq $args{database}) {
        die "Test database is the same as database in KOHA_CONF, abort!";
    }

    $databaseElement->firstChild()->setData($args{database});

    my ($fh, $filename) = tempfile('koha-conf.XXXXXX', TMPDIR => 1, UNLINK => 1);
    $xml->toFH($fh);
    close $fh;

    $ENV{KOHA_CONF} = $filename;

    require C4::Context;
    C4::Context->import;

    require C4::Installer;
    C4::Installer->import;

    require C4::Languages;

    my $host = C4::Context->config('hostname');
    my $port = C4::Context->config('port');
    my $database = C4::Context->config('database');
    my $user = C4::Context->config('user');
    my $pass = C4::Context->config('pass');

    say "Create test database $database...";

    my $dbh = DBI->connect("dbi:mysql:;host=$host;port=$port", $user, $pass, {
        RaiseError => 1,
        PrintError => 0,
    });

    $dbh->do("DROP DATABASE IF EXISTS $database");
    $dbh->do("CREATE DATABASE $database");

    my $installer = C4::Installer->new();
    $installer->load_db_schema();
    $installer->set_marcflavour_syspref($args{marcflavour});
    my (undef, $fwklist) = $installer->marc_framework_sql_list('en', $args{marcflavour});
    my @frameworks;
    foreach my $fwk (@$fwklist) {
        foreach my $framework (@{ $fwk->{frameworks} }) {
            push @frameworks, $framework->{fwkfile};
        }
    }
    my $all_languages = C4::Languages::getAllLanguages();
    $installer->load_sql_in_order($all_languages, @frameworks);
}

1;
