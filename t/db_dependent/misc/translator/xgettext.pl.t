#!/usr/bin/perl

use Modern::Perl;

use File::Slurp;
use File::Temp qw(tempdir);
use FindBin    qw($Bin);
use Locale::PO;
use Test::More tests => 20;

my $tempdir = tempdir( CLEANUP => 1 );

write_file( "$tempdir/files", "$Bin/sample.tt" );

my $xgettext_cmd = "$Bin/../../../../misc/translator/xgettext.pl -o $tempdir/Koha.pot -f $tempdir/files";

system($xgettext_cmd);
system("msgcat -o $tempdir/Koha.sorted.pot -s $tempdir/Koha.pot");
my $pot = Locale::PO->load_file_asarray("$tempdir/Koha.sorted.pot");

my @expected = (
    {
        msgid =>
            '"%s %s %s %s %s %s %s %s %s %s [%% # it also works on multiple lines tnpx ( \'context\', \'{count} item\', \'{count} items\', count, { count = count, } ) | $raw %%] [%% # and t* calls can be nested tx(\'status is {status}\', { status = active ? t(\'active\') : t(\'inactive\') }) | $raw %%] [%%# but a TT comment won\'t get picked t(\'not translatable\') %%] %s %s %s "',
    },
    {
        msgid => '"Foo"',
    },
    {
        msgid => '"This should be picked by xgettext.pl"',
    },
    {
        msgid => '"alt text"',
    },
    {
        msgid => '"but this is (thanks to space before attribute name)"',
    },
    {
        msgid => '"foo title"',
    },
);

for ( my $i = 0 ; $i < @expected ; $i++ ) {
    for my $key (qw(msgid msgid_plural msgctxt)) {
        my $expected     = $expected[$i]->{$key};
        my $expected_str = defined $expected ? $expected : 'not defined';
        my $msg          = $pot->[ $i + 1 ];
        if ($msg) {
            is( $msg->$key, $expected, "$i: $key is $expected_str" );
        } else {
            fail("$i: $key is $expected_str (no corresponding message in POT)");
        }
    }
}

is( scalar @$pot, 1 + scalar(@expected) );

write_file( "$tempdir/files", "$Bin/sample-not-working.tt" );

$xgettext_cmd = "$Bin/../../../../misc/translator/xgettext.pl -o $tempdir/Koha.pot -f $tempdir/files 2>/dev/null";

system($xgettext_cmd);
$pot = Locale::PO->load_file_asarray("$tempdir/Koha.pot");
is( scalar @$pot, 0, 'xgettext.pl failed to generate a POT file because of incorrect structure' );
