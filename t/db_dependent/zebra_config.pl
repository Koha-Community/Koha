#!/usr/bin/perl

use Modern::Perl;
use File::Copy;
use File::Path qw(make_path);
use File::Find;
use File::Basename;
use File::Spec;

my $source = File::Spec->rel2abs('.');
my $destination = File::Spec->rel2abs('.') . "/t/db_dependent/data";

make_path("$destination/var/lock/zebradb");
make_path("$destination/var/lib/zebradb");
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
