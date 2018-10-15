#!/usr/bin/perl

use Modern::Perl;
use Test::More;
use Test::Warn;
use Test::MockModule;

use C4::Record;
use C4::Biblio;
use Koha::Caches;

my $cache = Koha::Caches->get_instance();

my $marcxml = '<?xml version="1.0" encoding="UTF-8"?>
<record
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    xmlns="http://www.loc.gov/MARC21/slim">

  <leader>00439cam a22001934a 4500</leader>
  <controlfield tag="003">JOENS</controlfield>
  <controlfield tag="008">       1953    xx |||||||||| ||||1|eng|c</controlfield>
  <datafield tag="590" ind1=" " ind2=" ">
    <subfield code="b">BB</subfield>
    <subfield code="b">EE</subfield>
  </datafield>
  <datafield tag="590" ind1=" " ind2=" ">
    <subfield code="a">AA</subfield>
    <subfield code="b">DD</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">KI</subfield>
  </datafield>
</record>';

my $fwcode_rules;

my $return_undef = 0;
my $module_context = new Test::MockModule('C4::Context');

my $prefname = 'MarcToFrameworkcodeAutoconvert';
my $cachepref = "parsed-pref-$prefname";

$module_context->mock(
    preference => sub {
        my ($self, $pref) = @_;
        return undef if ($return_undef);
        return $fwcode_rules if ($pref eq $prefname);
        return 'XXX';
    },
    );

my ($error, $record) = marcxml2marc($marcxml);

subtest "_matchRecordFieldspec tests", \&_test_matchRecordFieldspec;
sub _test_matchRecordFieldspec {
    my $fn = '_matchRecordFieldspec';
    is(C4::Biblio::_matchRecordFieldspec($record, '003 '), 'JOENS', "$fn: single field");
    is(C4::Biblio::_matchRecordFieldspec($record, ' 000/06'), 'a', "$fn: field part");
    is(C4::Biblio::_matchRecordFieldspec($record, ' 008/35-37 '), 'eng', "$fn: field part range");
    is(C4::Biblio::_matchRecordFieldspec($record, '942$c'), 'KI', "$fn: subfield");
    is(C4::Biblio::_matchRecordFieldspec($record, '590$a'), 'AA', "$fn: subfield, first instance only");
    is(C4::Biblio::_matchRecordFieldspec($record, '590$b'), 'BB', "$fn: subfield, first instance only");
    is(C4::Biblio::_matchRecordFieldspec($record, '942$c+003'), 'KI+JOENS', "$fn: concat two fields");
    is(C4::Biblio::_matchRecordFieldspec($record, ' 942$c + 003'), 'KI+JOENS', "$fn: concat two fields plus spaces");
    is(C4::Biblio::_matchRecordFieldspec($record, '942$c+003 +  000/06 '), 'KI+JOENS+a', "$fn: concat three fields");

    my %warnings = ('NOTEXIST' => '',
                    '00' => '',
                    '942$' => '',
                    '+' => '',
                    '' => '');

    foreach my $tmp (keys(%warnings)) {
        warning_is {
            is(C4::Biblio::_matchRecordFieldspec($record, $tmp),
               $warnings{$tmp}, "$fn: nonexistent field"); }
    "$fn: unknown fieldspec '".$tmp."'", "$fn: raises a warning";
    }
}

$cache->clear_from_cache($cachepref);
$fwcode_rules = '';
is(GetAutoFrameworkCode($record), '', "empty rules");

$cache->clear_from_cache($cachepref);
$fwcode_rules = '  ';
is(GetAutoFrameworkCode($record), '', "empty rules");

$cache->clear_from_cache($cachepref);
$fwcode_rules = '

';
is(GetAutoFrameworkCode($record), '', "empty rules");


$cache->clear_from_cache($cachepref);
$fwcode_rules = '
foo: bar';
warning_is {
    is(GetAutoFrameworkCode($record), '', "empty rules");
} "MarcToFrameworkcodeAutoconvert YAML root element is not array",
    "raises a warning";



$cache->clear_from_cache($cachepref);
$fwcode_rules = '
- foo';
warning_is {
    is(GetAutoFrameworkCode($record), '', "empty rules");
} "MarcToFrameworkcodeAutoconvert 2nd level YAML element not a hash",
    "raises a warning";


$cache->clear_from_cache($cachepref);
$fwcode_rules = '
- 000:
   - foo';
warning_is {
    is(GetAutoFrameworkCode($record), '', "empty rules");
} "MarcToFrameworkcodeAutoconvert 3rd level YAML element not a hash",
    "raises a warning";


$fwcode_rules = '
- 003:
   JOENS: BKS';
is(GetAutoFrameworkCode($record), 'BKS', "correct value");

$cache->clear_from_cache($cachepref);
$fwcode_rules = '
- 003:
   FOO: BAR
- 003:
   JOENS: KIR';
is(GetAutoFrameworkCode($record), 'KIR', "later matching rule");

$cache->clear_from_cache($cachepref);
$fwcode_rules = '
- 003:
   JOENS: JNS
- 003:
   FOO: BAR
';
is(GetAutoFrameworkCode($record), 'JNS', "first matching rule");

$cache->clear_from_cache($cachepref);
$fwcode_rules = '
- 000/06:
   a: QUX
   b: KIR
- 003:
   JOENS: JNS
';
is(GetAutoFrameworkCode($record), 'QUX', "first matching rule, pt 2");

$cache->clear_from_cache($cachepref);
$fwcode_rules = '
- 000/06:
   b: KIR
   c: BKS
- 003:
   JOENS: JOE
';
is(GetAutoFrameworkCode($record), 'JOE', "first matching rule, pt 3");

$cache->clear_from_cache($cachepref);
$fwcode_rules = '
- 000/06:
   b: KIR
   c: BKS
- 003:
   JNS: JOENS
';
is(GetAutoFrameworkCode($record), '', "no matching rule");

$cache->clear_from_cache($cachepref);
$return_undef = 1;
is(GetAutoFrameworkCode($record), '', "no return value if no syspref");

done_testing();
