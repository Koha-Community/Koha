#!/usr/bin/perl

use Modern::Perl;

use File::Slurp;
use File::Temp qw(tempdir);
use FindBin    qw($Bin);
use Locale::PO;
use Test::NoWarnings;
use Test::More tests => 17;

my $tempdir = tempdir( CLEANUP => 1 );

write_file( "$tempdir/files", "$Bin/sample.pref" );

my $xgettext_cmd = "$Bin/../../../../misc/translator/xgettext-pref " . "-o $tempdir/Koha.pot -f $tempdir/files";

system($xgettext_cmd);
my $pot = Locale::PO->load_file_asarray("$tempdir/Koha.pot");

my @expected = (
    {
        msgid => '"sample.pref"',
    },
    {
        msgid => '"sample.pref Subsection"',
    },
    {
        msgid => '"sample.pref#MultiplePref# Bar"',
    },
    {
        msgid => '"sample.pref#MultiplePref# Baz"',
    },
    {
        msgid => '"sample.pref#MultiplePref# Foo ツ"',
    },
    {
        msgid => '"sample.pref#SamplePref# Do"',
    },
    {
        msgid => '"sample.pref#SamplePref# Do not do"',
    },
    {
        msgid => '"sample.pref#SamplePref# that thing"',
    },
);

for ( my $i = 0 ; $i < @expected ; $i++ ) {
    for my $key (qw(msgid msgctxt)) {
        my $expected     = $expected[$i]->{$key};
        my $expected_str = defined $expected ? $expected : 'not defined';
        is( $pot->[ $i + 1 ]->$key, $expected, "$i: $key is $expected_str" );
    }
}
