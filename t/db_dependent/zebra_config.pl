#!/usr/bin/perl

use Modern::Perl;
use File::Copy;
use File::Path qw(make_path);
use File::Find;
use File::Basename;
use File::Spec;

my $source = File::Spec->rel2abs('.');
my $destination = $ARGV[0];
my $marc_type = $ARGV[1] || 'marc21';
my $indexing_mode = $ARGV[2] || 'grs1';

$ENV{__ZEBRA_MARC_FORMAT__} = $marc_type;
if ($indexing_mode eq 'dom') {
    $ENV{__ZEBRA_BIB_CFG__} = 'zebra-biblios-dom.cfg';
    $ENV{__BIB_RETRIEVAL_CFG__} = 'retrieval-info-bib-dom.xml';
    $ENV{__ZEBRA_AUTH_CFG__} = 'zebra-authorities-dom.cfg';
    $ENV{__AUTH_RETRIEVAL_CFG__} = 'retrieval-info-auth-dom.xml';
} else {
    $ENV{__ZEBRA_BIB_CFG__} = 'zebra-biblios.cfg';
    $ENV{__BIB_RETRIEVAL_CFG__} = 'retrieval-info-bib-grs1.xml';
    $ENV{__ZEBRA_AUTH_CFG__} = 'zebra-authorities.cfg';
    $ENV{__AUTH_RETRIEVAL_CFG__} = 'retrieval-info-auth-grs1.xml';
}

make_path("$destination/var/lock/zebradb");
make_path("$destination/var/lock/zebradb/biblios");
make_path("$destination/var/lock/zebradb/authorities");
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

my @files = ( "$source/etc/koha-conf.xml" );

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
