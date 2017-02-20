#!/usr/bin/perl

use Modern::Perl;

use File::Copy;
use File::Path qw(make_path);
use File::Find;
use File::Basename;
use File::Spec;

use C4::Context;

my $source = File::Spec->rel2abs('.');
my $destination = $ARGV[0];
my $marc_type = $ARGV[1] || 'marc21';
my $indexing_mode = $ARGV[2] || 'dom';

$ENV{__ZEBRA_MARC_FORMAT__} = $marc_type;
$ENV{__ZEBRA_BIB_CFG__} = 'zebra-biblios-dom.cfg';
$ENV{__BIB_RETRIEVAL_CFG__} = 'retrieval-info-bib-dom.xml';
$ENV{__ZEBRA_AUTH_CFG__} = 'zebra-authorities-dom.cfg';
$ENV{__AUTH_RETRIEVAL_CFG__} = 'retrieval-info-auth-dom.xml';

make_path("$destination/var/lock/zebradb");
make_path("$destination/var/lock/zebradb/biblios");
make_path("$destination/var/lock/zebradb/authorities");
make_path("$destination/var/lock/zebradb/rebuild");
make_path("$destination/var/lib/zebradb");
make_path("$destination/var/lib/zebradb/biblios");
make_path("$destination/var/lib/zebradb/biblios/key");
make_path("$destination/var/lib/zebradb/biblios/register");
make_path("$destination/var/lib/zebradb/biblios/shadow");
make_path("$destination/var/lib/zebradb/biblios/tmp");
make_path("$destination/var/lib/zebradb/authorities");
make_path("$destination/var/lib/zebradb/authorities/key");
make_path("$destination/var/lib/zebradb/authorities/register");
make_path("$destination/var/lib/zebradb/authorities/shadow");
make_path("$destination/var/lib/zebradb/authorities/tmp");
make_path("$destination/var/run/zebradb");

$ENV{'INSTALL_BASE'} = $destination;
$ENV{'__INSTALL_BASE__'} = $destination;

$ENV{'__DB_TYPE__'} = C4::Context->config('db_scheme') // 'mysql';
$ENV{'__DB_NAME__'} = C4::Context->config('database')  // 'koha';
$ENV{'__DB_HOST__'} = C4::Context->config('hostname')  // 'localhost';
$ENV{'__DB_PORT__'} = C4::Context->config('port')      // '3306';
$ENV{'__DB_USER__'} = C4::Context->config('user')      // 'kohaadmin';
$ENV{'__DB_PASS__'} = C4::Context->config('pass')      // 'katikoan';

my @files = ( "$source/etc/koha-conf.xml",
              "$source/etc/searchengine/queryparser.yaml",
            );

find(sub { push @files, $File::Find::name if ( -f $File::Find::name ); }, "$source/etc/zebradb");

foreach my $file (@files) {
    my $target = "$file";
    $target =~ s#$source#$destination#;
    $target =~ s#etc/zebradb#etc/koha/zebradb#;
    unlink($target);
    make_path(dirname($target));
    copy("$file", "$target");
    system("perl $source/rewrite-config.PL $target");
    if ($file =~ m/xml/) {
        replace("$target", "$destination/intranet/templates", "$source/koha-tmpl/intranet-tmpl");
    }
}


sub replace {
    my ($file, $pattern, $replacement) = @_;
    system("sed -i -e 's#$pattern#$replacement#' $file");
}
