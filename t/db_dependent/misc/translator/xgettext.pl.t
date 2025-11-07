#!/usr/bin/perl

use Modern::Perl;

use File::Slurp qw(read_file write_file);
use File::Temp  qw(tempdir);
use FindBin     qw($Bin);
use Locale::PO;
use Test::More tests => 25;
use Test::NoWarnings;

my $tempdir = tempdir( CLEANUP => 1 );

write_file( "$tempdir/files", "$Bin/tt/en/sample.tt" );

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

write_file( "$tempdir/files", "$Bin/tt/en/sample-not-working.tt" );

$xgettext_cmd = "$Bin/../../../../misc/translator/xgettext.pl -o $tempdir/Koha.pot -f $tempdir/files 2>/dev/null";

system($xgettext_cmd);
$pot = Locale::PO->load_file_asarray("$tempdir/Koha.pot");
is( scalar @$pot, 0, 'xgettext.pl failed to generate a POT file because of incorrect structure' );

write_file( "$tempdir/files", "$Bin/tt/en/sample-not-working-2.tt" );

$xgettext_cmd = "$Bin/../../../../misc/translator/xgettext.pl -o $tempdir/Koha.pot -f $tempdir/files 2>/dev/null";

system($xgettext_cmd);
$pot = Locale::PO->load_file_asarray("$tempdir/Koha.pot");
is( scalar @$pot, 4, 'xgettext.pl generated a POT file' );

my $pot_content = read_file("$tempdir/Koha.pot");
$pot_content =~
    s|msgid "Don't use TT directives if another attribute is translatable"\nmsgstr ""|msgid "Don't use TT directives if another attribute is translatable"\nmsgstr "Ne pas utiliser TT si un autre attribut est traduisible"|gms;
$pot_content =~ s|msgid "Will be translated"\nmsgstr ""|msgid "Will be translated"\nmsgstr "Ceci sera traduit"|gms;
write_file( "$tempdir/Koha.pot", $pot_content );

my $tempdir_fr = tempdir( CLEANUP => 1 );
my $install_cmd =
    "$Bin/../../../../misc/translator/tmpl_process3.pl -q install -i $Bin -o $tempdir_fr  -s $tempdir/Koha.pot -r -n marc21 -n unimarc";
system($install_cmd);

my $content = read_file("$tempdir_fr/tt/en/sample-not-working-2.tt");
like( $content, qr{Ne pas utiliser TT si un autre attribut est traduisible} );
like( $content, qr{Ceci sera traduit} );

# So far so good, but #FIXME:
like( $content, qr{<span %\]="%\]" %\]required="required" \[%="\[%"} );
