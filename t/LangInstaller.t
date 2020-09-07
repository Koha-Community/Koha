use Modern::Perl;

use FindBin '$Bin';
use lib "$Bin/../misc/translator";

use Test::More tests => 39;
use File::Temp qw(tempdir);
use File::Slurp;
use Locale::PO;

use t::lib::Mocks;

use_ok('LangInstaller');

my $installer = LangInstaller->new();

my $tempdir = tempdir(CLEANUP => 0);
t::lib::Mocks::mock_config('intrahtdocs', "$Bin/LangInstaller/templates");
my @files = ('simple.tt');
$installer->extract_messages_from_templates($tempdir, 'intranet', @files);

my $tempfile = "$tempdir/koha-tmpl/intranet-tmpl/simple.tt";
ok(-e $tempfile, 'it has created a temporary file simple.tt');
SKIP: {
    skip "simple.tt does not exist", 37 unless -e $tempfile;

    my $output = read_file($tempfile);
    my $expected_output = <<'EOF';
__('hello');
__x('hello {name}');
__n('item', 'items');
__nx('{count} item', '{count} items');
__p('context', 'hello');
__px('context', 'hello {name}');
__np('context', 'item', 'items');
__npx('context', '{count} item', '{count} items');
__npx('context', '{count} item', '{count} items');
__x('status is {status}');
__('active');
__('inactive');
__('Inside block');
EOF

    is($output, $expected_output, "Output of extract_messages_from_templates is as expected");

    my $xgettext_cmd = "xgettext -L Perl --from-code=UTF-8 "
        . "--package-name=Koha --package-version='' "
        . "-k -k__ -k__x -k__n:1,2 -k__nx:1,2 -k__xn:1,2 -k__p:1c,2 "
        . "-k__px:1c,2 -k__np:1c,2,3 -k__npx:1c,2,3 "
        . "-o $tempdir/Koha.pot -D $tempdir koha-tmpl/intranet-tmpl/simple.tt";

    system($xgettext_cmd);
    my $pot = Locale::PO->load_file_asarray("$tempdir/Koha.pot");

    my @expected = (
        {
            msgid => '"hello"',
        },
        {
            msgid => '"hello {name}"',
        },
        {
            msgid => '"item"',
            msgid_plural => '"items"',
        },
        {
            msgid => '"{count} item"',
            msgid_plural => '"{count} items"',
        },
        {
            msgid => '"hello"',
            msgctxt => '"context"',
        },
        {
            msgid => '"hello {name}"',
            msgctxt => '"context"',
        },
        {
            msgid => '"item"',
            msgid_plural => '"items"',
            msgctxt => '"context"',
        },
        {
            msgid => '"{count} item"',
            msgid_plural => '"{count} items"',
            msgctxt => '"context"',
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

    for (my $i = 0; $i < @expected; $i++) {
        for my $key (qw(msgid msgid_plural msgctxt)) {
            my $expected = $expected[$i]->{$key};
            my $expected_str = defined $expected ? $expected : 'not defined';
            is($pot->[$i + 1]->$key, $expected, "$i: $key is $expected_str");
        }
    }
}
