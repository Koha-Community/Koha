#!/usr/bin/perl

use Modern::Perl;

use File::Slurp;
use File::Temp qw(tempdir);
use FindBin    qw($Bin);
use Locale::PO;
use Test::NoWarnings;
use Test::More tests => 5;

my $tempdir = tempdir( CLEANUP => 1 );

write_file( "$tempdir/files", "$Bin/sample.yml" );

my $xgettext_cmd = "$Bin/../../../../misc/translator/xgettext-installer " . "-o $tempdir/Koha.pot -f $tempdir/files";

system($xgettext_cmd);
my $pot = Locale::PO->load_file_asarray("$tempdir/Koha.pot");

my @expected = (
    { msgid => '"Sample installer file"' },
    { msgid => '"bar"' },
    { msgid => '"baz"' },
    { msgid => '"foo ツ"' },
);

for ( my $i = 0 ; $i < @expected ; $i++ ) {
    my $expected     = $expected[$i]->{msgid};
    my $expected_str = defined $expected ? $expected : 'not defined';
    is( $pot->[ $i + 1 ]->msgid, $expected, "$i: msgid is $expected_str" );
}
