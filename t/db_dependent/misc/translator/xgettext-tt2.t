#!/usr/bin/perl

use Modern::Perl;

use File::Slurp;
use File::Temp qw(tempdir);
use FindBin    qw($Bin);
use Locale::PO;
use Test::NoWarnings;
use Test::More tests => 37;

my $tempdir = tempdir( CLEANUP => 1 );

write_file( "$tempdir/files", "$Bin/sample.tt" );

my $xgettext_cmd =
    "$Bin/../../../../misc/translator/xgettext-tt2 --from-code=UTF-8 " . "-o $tempdir/Koha.pot -f $tempdir/files";

system($xgettext_cmd);
my $pot = Locale::PO->load_file_asarray("$tempdir/Koha.pot");

my @expected = (
    {
        msgid => '"hello ツ"',
    },
    {
        msgid => '"hello {name}"',
    },
    {
        msgid        => '"item"',
        msgid_plural => '"items"',
    },
    {
        msgid        => '"{count} item"',
        msgid_plural => '"{count} items"',
    },
    {
        msgid   => '"hello"',
        msgctxt => '"context"',
    },
    {
        msgid   => '"hello {name}"',
        msgctxt => '"context"',
    },
    {
        msgid        => '"item"',
        msgid_plural => '"items"',
        msgctxt      => '"context"',
    },
    {
        msgid        => '"{count} item"',
        msgid_plural => '"{count} items"',
        msgctxt      => '"context"',
    },
    {
        msgid => '"status is {status}"',
    },
    {
        msgid => '"active"',
    },
    {
        msgid => '"inactive"',
    },
    {
        msgid => '"Inside block"',
    },
);

for ( my $i = 0 ; $i < @expected ; $i++ ) {
    for my $key (qw(msgid msgid_plural msgctxt)) {
        my $expected     = $expected[$i]->{$key};
        my $expected_str = defined $expected ? $expected : 'not defined';
        is( $pot->[ $i + 1 ]->$key, $expected, "$i: $key is $expected_str" );
    }
}
