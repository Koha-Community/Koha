#!/usr/bin/perl

# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Context;
use Test::More tests => 148;
use Test::MockModule;
use Test::Warn;


BEGIN {
    use_ok('C4::OAI::Sets');
    use_ok('MARC::Record');
    use_ok('C4::Biblio');
}
can_ok(
    'C4::OAI::Sets', qw(
        GetOAISets
        GetOAISet
        GetOAISetBySpec
        ModOAISet
        DelOAISet
        AddOAISet
        GetOAISetsMappings
        GetOAISetMappings
        ModOAISetMappings
        GetOAISetsBiblio
        DelOAISetsBiblio
        CalcOAISetsBiblio
        ModOAISetsBiblios
        UpdateOAISetsBiblio
        AddOAISetsBiblios )
);


my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;
$dbh->do('DELETE FROM oai_sets');
$dbh->do('DELETE FROM oai_sets_descriptions');
$dbh->do('DELETE FROM oai_sets_mappings');
$dbh->do('DELETE FROM oai_sets_biblios');


# ---------- Testing AddOAISet ------------------
ok (!defined(AddOAISet), 'AddOAISet without argument is undef');

my $set_without_spec_and_name_and_desc =  {};
ok (!defined(AddOAISet($set_without_spec_and_name_and_desc)), 'AddOAISet without "field", "name" and "descriptions" fields is undef');

my $set_without_spec_and_name =  {
    'descriptions' => ['descNoSpecNoName'],
};
ok (!defined(AddOAISet($set_without_spec_and_name)), 'AddOAISet without "field" and "name" fields is undef');

my $set_without_spec =  {
    'name' => 'nameNoSpec',
    'descriptions' => ['descNoSpec'],
};
ok (!defined(AddOAISet($set_without_spec)), 'AddOAISet without "field" field is undef');

my $set_without_name =  {
    'spec' => 'specNoName',
    'descriptions' => ['descNoName'],
};
ok (!defined(AddOAISet($set_without_name)), 'AddOAISet without "name" field is undef');

#Test to enter in the 'else' case of 'AddOAISet' line 280
{
    my $dbi_st = Test::MockModule->new('DBI::st', no_auto => 1);  # ref($sth) == 'DBI::st'
    $dbi_st->mock('execute', sub { return 0; });

    my $setWrong = {
        'spec' => 'specWrong',
        'name' => 'nameWrong',
    };
    my $setWrong_id;
    warning_is { $setWrong_id = AddOAISet($setWrong) }
                'AddOAISet failed',
                'AddOAISet raises warning if there is a problem with SET spec or SET name';

    ok(!defined $setWrong_id, '$setWrong_id is not defined');
}

#Adding a Set without description
my $set1 = {
    'spec' => 'specSet1',
    'name' => 'nameSet1',
};
my $set1_id = AddOAISet($set1);
isa_ok(\$set1_id, 'SCALAR', '$set1_id is a SCALAR');

my $sth = $dbh->prepare("SELECT count(*) FROM oai_sets");
$sth->execute;
my $setsCount = $sth->fetchrow_array;
is ($setsCount, 1, 'There is 1 set');

$sth = $dbh->prepare("SELECT spec, name FROM oai_sets");
$sth->execute;
my ($spec, $name) = $sth->fetchrow_array;
is ($spec, 'specSet1', 'spec field is "specSet1"');
is ($name, 'nameSet1', 'name field is "nameSet1"');

$sth = $dbh->prepare("SELECT description FROM oai_sets_descriptions");
$sth->execute;
my $desc = $sth -> rows;
is ($desc, 0, 'There is NO set description');

#Adding a Set with a description
my $set2 = {
    'spec' => 'specSet2',
    'name' => 'nameSet2',
    'descriptions' => ['descSet2'],
};
my $set2_id = AddOAISet($set2);
isa_ok(\$set2_id, 'SCALAR', '$set2_id is a SCALAR');

$sth = $dbh->prepare("SELECT count(*) FROM oai_sets");
$sth->execute;
$setsCount = $sth->fetchrow_array;
is ($setsCount, 2, 'There is 2 sets');

$sth = $dbh->prepare("SELECT spec, name FROM oai_sets ORDER BY id DESC");
$sth->execute;
($spec, $name) = $sth->fetchrow_array;
is ($spec, 'specSet2', 'spec field is "specSet2"');
is ($name, 'nameSet2', 'name field is "nameSet2"');

$sth = $dbh->prepare("SELECT description FROM oai_sets_descriptions");
$sth->execute;
$desc = $sth->fetchrow_array;
is ($desc, 'descSet2', 'description field is "descSet2"');


# ---------- Testing GetOAISets -----------------
my $oai_sets = GetOAISets;
isa_ok($oai_sets, 'ARRAY', '$oai_sets is an array reference of hash reference describing the sets');

isa_ok($oai_sets->[0], 'HASH', '$set1 is defined as a hash');
is ($oai_sets->[0]->{spec}, 'specSet1', 'spec field is "specSet1"');
is ($oai_sets->[0]->{name}, 'nameSet1', 'name field is "nameSet1"');

isa_ok($oai_sets->[1], 'HASH', '$set2 is defined as a hash');
is ($oai_sets->[1]->{spec}, 'specSet2', 'spec field is "specSet2"');
is ($oai_sets->[1]->{name}, 'nameSet2', 'name field is "nameSet2"');
is_deeply ($oai_sets->[1]->{descriptions}, ['descSet2'], 'description field is "descSet2"');

ok(!defined($oai_sets->[2]), 'There are only 2 sets');


# ---------- Testing GetOAISet ------------------
ok (!defined(GetOAISet), 'GetOAISet without argument is undef');

my $set = GetOAISet($set1_id);
isa_ok($set, 'HASH', '$set is a hash reference describing the set with the given set_id');
is ($set->{spec}, 'specSet1', 'spec field is "specSet1"');
is ($set->{name}, 'nameSet1', 'name field is "nameSet1"');

$set = GetOAISet($set2_id);
isa_ok($set, 'HASH', '$set is a hash reference describing the set with the given set_id');
is ($set->{spec}, 'specSet2', 'spec field is "specSet2"');
is ($set->{name}, 'nameSet2', 'name field is "nameSet2"');
is_deeply ($set->{descriptions}, ['descSet2'], 'description field is "descSet2"');


# ---------- Testing GetOAISetBySpec ------------
ok (!defined(GetOAISetBySpec), 'GetOAISetBySpec without argument is undef');

$set = GetOAISetBySpec($set1->{spec});
isa_ok($set, 'HASH', '$set is a hash describing the set whose spec is $oai_sets->[0]->{spec}');
is ($set->{spec}, 'specSet1', 'spec field is "specSet1"');
is ($set->{name}, 'nameSet1', 'name field is "nameSet1"');

$set = GetOAISetBySpec($set2->{spec});
isa_ok($set, 'HASH', '$set is a hash describing the set whose spec is $oai_sets->[1]->{spec}');
is ($set->{spec}, 'specSet2', 'spec field is "specSet2"');
is ($set->{name}, 'nameSet2', 'name field is "nameSet2"');
#GetOAISetBySpec does't return the description field.


# ---------- Testing ModOAISet ------------------
ok (!defined(ModOAISet), 'ModOAISet without argument is undef');

my $new_set_without_id =  {
    'spec' => 'specNoName',
    'name' => 'nameNoSpec',
    'descriptions' => ['descNoSpecNoName'],
};
my $res;
warning_is { $res = ModOAISet($new_set_without_id) }
            'Set ID not defined, can\'t modify the set',
            'ModOAISet raises warning if Set ID is not defined';
ok(!defined($res), 'ModOAISet returns undef if Set ID is not defined');

my $new_set_without_spec_and_name =  {
    'id' => $set1_id,
    'descriptions' => ['descNoSpecNoName'],
};
ok (!defined(ModOAISet($new_set_without_spec_and_name)), 'ModOAISet without "field" and "name" fields is undef');

my $new_set_without_spec =  {
    'id' => $set1_id,
    'name' => 'nameNoSpec',
    'descriptions' => ['descNoSpec'],
};
ok (!defined(ModOAISet($new_set_without_spec)), 'ModOAISet without "field" field is undef');

my $new_set_without_name =  {
    'id' => $set1_id,
    'spec' => 'specNoName',
    'descriptions' => ['descNoName'],
};
ok (!defined(ModOAISet($new_set_without_name)), 'ModOAISet without "name" field is undef');

my $new_set1 =  {
    'id' => $set1_id,
    'spec' => 'new_specSet1',
    'name' => 'new_nameSet1',
    'descriptions' => ['new_descSet1'],
};
ModOAISet($new_set1);

my $new_set2 =  {
    'id' => $set2_id,
    'spec' => 'new_specSet2',
    'name' => 'new_nameSet2',
};
ModOAISet($new_set2);

$set1 = GetOAISet($set1_id);
isa_ok($set1, 'HASH', '$set1 is defined as a hash');
is ($set1->{spec}, 'new_specSet1', 'spec field is "new_specSet1"');
is ($set1->{name}, 'new_nameSet1', 'name field is "new_nameSet1"');
is_deeply ($set1->{descriptions}, ['new_descSet1'], 'description field is "new_descSet1"');

$set2 = GetOAISet($set2_id);
isa_ok($set2, 'HASH', '$new_set2 is defined as a hash');
is ($set2->{spec}, 'new_specSet2', 'spec field is "new_specSet2"');
is ($set2->{name}, 'new_nameSet2', 'name field is "new_nameSet2"');


# ---------- Testing ModOAISetMappings ----------
ok (!defined(ModOAISetMappings), 'ModOAISetMappings without argument is undef');
#Add 1st mapping for set1
my $mapping1 = [
    {
        marcfield => '206',
        marcsubfield => 'a',
        operator => 'equal',
        marcvalue => 'myMarcValue'
    },
];
ModOAISetMappings($set1_id, $mapping1);

$sth = $dbh->prepare("SELECT count(*) FROM oai_sets_mappings");
$sth->execute;
my $mappingsCount = $sth->fetchrow_array;
is ($mappingsCount, 1, 'There is 1 mapping');

$sth = $dbh->prepare("SELECT marcfield, marcsubfield, operator, marcvalue FROM oai_sets_mappings");
$sth->execute;
my ($marcfield, $marcsubfield, $operator, $marcvalue) = $sth->fetchrow_array;
is ($marcfield, '206', 'marcfield field is "206"');
is ($marcsubfield, 'a', 'marcsubfield field is "a"');
is ($operator, 'equal', 'operator field is "equal"');
is ($marcvalue, 'myMarcValue', 'marcvalue field is "myMarcValue"');

#Mod 1st mapping of set1
my $mapping1_bis = [
    {
        marcfield => '256',
        marcsubfield => 'b',
        operator => 'notequal',
        marcvalue => 'myMarcValueBis'
    },
];
ModOAISetMappings($set1_id, $mapping1_bis);

$sth = $dbh->prepare("SELECT count(*) FROM oai_sets_mappings");
$sth->execute;
$mappingsCount = $sth->fetchrow_array;
is ($mappingsCount, 1, 'There is 1 mapping');

$sth = $dbh->prepare("SELECT marcfield, marcsubfield, operator, marcvalue FROM oai_sets_mappings");
$sth->execute;
($marcfield, $marcsubfield, $operator, $marcvalue) = $sth->fetchrow_array;
is ($marcfield, '256', 'marcfield field is "256"');
is ($marcsubfield, 'b', 'marcsubfield field is "b"');
is ($operator, 'notequal', 'operator field is "notequal"');
is ($marcvalue, 'myMarcValueBis', 'marcvalue field is "myMarcValueBis"');

#Add 1st mapping of set2
my $mapping2 = [
    {
        marcfield => '306',
        marcsubfield => 'c',
        operator => 'equal',
        marcvalue => 'myOtherMarcValue'
    },
];
ModOAISetMappings($set2_id, $mapping2);

$sth = $dbh->prepare("SELECT count(*) FROM oai_sets_mappings");
$sth->execute;
$mappingsCount = $sth->fetchrow_array;
is ($mappingsCount, 2, 'There is 2 mappings');

$sth = $dbh->prepare("SELECT marcfield, marcsubfield, operator, marcvalue FROM oai_sets_mappings ORDER BY set_id DESC LIMIT 1");
$sth->execute;
($marcfield, $marcsubfield, $operator, $marcvalue) = $sth->fetchrow_array;
is ($marcfield, '306', 'marcfield field is "306"');
is ($marcsubfield, 'c', 'marcsubfield field is "c"');
is ($operator, 'equal', 'operator field is "equal"');
is ($marcvalue, 'myOtherMarcValue', 'marcvalue field is "myOtherMarcValue"');


# ---------- Testing GetOAISetsMappings ---------
my $mappings = GetOAISetsMappings;

isa_ok($mappings, 'HASH', '$mappings is a hashref of arrayrefs of hashrefs');
isa_ok($mappings->{$set1_id}, 'ARRAY', '$mappings->{$set1_id} is a arrayrefs of hashrefs');
isa_ok($mappings->{$set1_id}->[0], 'HASH', '$mappings->{$set1_id}->[0] is a hashrefs');
is ($mappings->{$set1_id}->[0]->{marcfield}, '256', 'marcfield field is "256"');
is ($mappings->{$set1_id}->[0]->{marcsubfield}, 'b', 'marcsubfield field is "b"');
is ($mappings->{$set1_id}->[0]->{operator}, 'notequal', 'operator field is "notequal"');
is ($mappings->{$set1_id}->[0]->{marcvalue}, 'myMarcValueBis', 'marcvalue field is "myMarcValueBis"');

isa_ok($mappings->{$set2_id}, 'ARRAY', '$mappings->{$set2_id} is a arrayrefs of hashrefs');
isa_ok($mappings->{$set2_id}, 'ARRAY', '$mappings->{$set2_id} is a arrayrefs of hashrefs');
isa_ok($mappings->{$set2_id}->[0], 'HASH', '$mappings->{$set2_id}->[0] is a hashrefs');
is ($mappings->{$set2_id}->[0]->{marcfield}, '306', 'marcfield field is "306"');
is ($mappings->{$set2_id}->[0]->{marcsubfield}, 'c', 'marcsubfield field is "c"');
is ($mappings->{$set2_id}->[0]->{operator}, 'equal', 'operator field is "equal"');
is ($mappings->{$set2_id}->[0]->{marcvalue}, 'myOtherMarcValue', 'marcvalue field is "myOtherMarcValue"');


# ---------- Testing GetOAISetMappings ----------
ok (!defined(GetOAISetMappings), 'GetOAISetMappings without argument is undef');

my $set_mappings1 = GetOAISetMappings($set1_id);
isa_ok($set_mappings1->[0], 'HASH', '$set_mappings1->[0] is a hashref');
is ($set_mappings1->[0]->{marcfield}, '256', 'marcfield field is "256"');
is ($set_mappings1->[0]->{marcsubfield}, 'b', 'marcsubfield field is "b"');
is ($set_mappings1->[0]->{operator}, 'notequal', 'operator field is "notequal"');
is ($set_mappings1->[0]->{marcvalue}, 'myMarcValueBis', 'marcvalue field is "myMarcValueBis"');

my $set_mappings2 = GetOAISetMappings($set2_id);
isa_ok($mappings->{$set2_id}->[0], 'HASH', '$mappings->{$set2_id}->[0] is a hashref');
is ($mappings->{$set2_id}->[0]->{marcfield}, '306', 'marcfield field is "306"');
is ($mappings->{$set2_id}->[0]->{marcsubfield}, 'c', 'marcsubfield field is "c"');
is ($mappings->{$set2_id}->[0]->{operator}, 'equal', 'operator field is "equal"');
is ($mappings->{$set2_id}->[0]->{marcvalue}, 'myOtherMarcValue', 'marcvalue field is "myOtherMarcValue"');


# ---------- Testing AddOAISetsBiblios ----------
ok (!defined(AddOAISetsBiblios), 'AddOAISetsBiblios without argument is undef');
ok (!defined(AddOAISetsBiblios(my $arg=[])), 'AddOAISetsBiblios with a no HASH argument is undef');
ok (defined(AddOAISetsBiblios($arg={})), 'AddOAISetsBiblios with a HASH argument is def');

# Create a biblio instance for testing
my $biblionumber1 = create_helper_biblio('Moffat, Steven');
isa_ok(\$biblionumber1, 'SCALAR', '$biblionumber1 is a SCALAR');
my $biblionumber2 = create_helper_biblio('Moffat, Steven');
isa_ok(\$biblionumber2, 'SCALAR', '$biblionumber2 is a SCALAR');

my $oai_sets_biblios = {
    $set1_id => [$biblionumber1, $biblionumber2],   # key is the set_id, and value is an array ref of biblionumbers
    $set2_id => [],
};
AddOAISetsBiblios($oai_sets_biblios);

$sth = $dbh->prepare("SELECT count(*) FROM oai_sets_biblios");
$sth->execute;
my $bibliosCount = $sth->fetchrow_array;
is ($bibliosCount, 2, 'There are 2 biblios in oai_sets_biblios');

#testing biblio for set1_id
$sth = $dbh->prepare("SELECT * FROM oai_sets_biblios WHERE set_id = ?");
$sth->execute($set1_id);
my $count = $sth->rows;
is ($count, '2', '$set_id1 has 2 biblio');

$sth->execute($set1_id);
my $line = ${ $sth->fetchall_arrayref( {} ) }[0];
is($line->{set_id}, $set1_id, "set_id is good");
is($line->{biblionumber}, $biblionumber1, "biblionumber is good");

$sth->execute($set1_id);
$line = ${ $sth->fetchall_arrayref( {} ) }[1];
is($line->{set_id}, $set1_id, "set_id is good");
is($line->{biblionumber}, $biblionumber2, "biblionumber is good");

#testing biblio for set2_id
$sth->execute($set2_id);
$count = $sth->rows;
is ($count, '0', '$set_id2 has 0 biblio');


# ---------- Testing GetOAISetsBiblio -----------
$oai_sets = GetOAISetsBiblio($biblionumber1);
isa_ok($oai_sets, 'ARRAY', '$oai_sets is an arrayref of hashref where each element of the array is a set');
isa_ok($oai_sets->[0], 'HASH', '$oai_sets->[0] is a hashrefs of $set1_id');
is($oai_sets->[0]->{id}, $set1_id, 'id is $set1_id');
is($oai_sets->[0]->{spec}, $set1->{spec}, 'spec is new_specset1');
is($oai_sets->[0]->{name}, $set1->{name}, 'name is new_specname1');

$oai_sets = GetOAISetsBiblio($biblionumber2);
isa_ok($oai_sets, 'ARRAY', '$oai_sets is an arrayref of hashref where each element of the array is a set');
isa_ok($oai_sets->[0], 'HASH', '$oai_sets->[0] is a hashrefs of $set2_id');
is($oai_sets->[0]->{id}, $set1_id, 'id is $set1_id');
is($oai_sets->[0]->{spec}, $set1->{spec}, 'spec is new_specset1');
is($oai_sets->[0]->{name}, $set1->{name}, 'name is new_specname1');


# ---------- Testing ModOAISetsBiblios ----------
ok (!defined(ModOAISetsBiblios), 'ModOAISetsBiblios without argument is undef');
ok (!defined(ModOAISetsBiblios($arg=[])), 'ModOAISetsBiblios with a no HASH argument is undef');
ok (defined(ModOAISetsBiblios($arg={})), 'ModOAISetsBiblios with a HASH argument is def');

$oai_sets_biblios = {
    $set1_id => [$biblionumber1],
    $set2_id => [$biblionumber2],
};
ModOAISetsBiblios($oai_sets_biblios);

$sth = $dbh->prepare("SELECT count(*) FROM oai_sets_biblios");
$sth->execute;
$bibliosCount = $sth->fetchrow_array;
is ($bibliosCount, 2, 'There are 2 biblios in oai_sets_biblios');

#testing biblio for set1_id
$sth = $dbh->prepare("SELECT * FROM oai_sets_biblios WHERE set_id = ?");
$sth->execute($set1_id);
$count = $sth->rows;
is ($count, '1', '$set_id1 has 2 biblio');

$sth->execute($set1_id);
$line = ${ $sth->fetchall_arrayref( {} ) }[0];
is($line->{set_id}, $set1_id, "set_id is good");
is($line->{biblionumber}, $biblionumber1, "biblionumber is good");

#testing biblio for set2_id
$sth->execute($set2_id);
$count = $sth->rows;
is ($count, '1', '$set_id2 has 1 biblio');

$sth->execute($set2_id);
$line = ${ $sth->fetchall_arrayref( {} ) }[0];
is($line->{set_id}, $set2_id, "set_id is good");
is($line->{biblionumber}, $biblionumber2, "biblionumber is good");


# ---------- Testing DelOAISetsBiblio -----------
ok (!defined(DelOAISetsBiblio), 'DelOAISetsBiblio without argument is undef');

DelOAISetsBiblio($biblionumber1);
is_deeply(GetOAISetsBiblio($biblionumber1), [], "no biblio1 appear in any OAI sets");

DelOAISetsBiblio($biblionumber2);
is_deeply(GetOAISetsBiblio($biblionumber2), [], "no biblio2 appear in any OAI sets");


# ---------- Testing DelOAISet ------------------
ok (!defined(DelOAISet), 'DelOAISet without argument is undef');

DelOAISet($set1_id);
$sth = $dbh->prepare("SELECT count(*) FROM oai_sets");
$sth->execute;
$setsCount = $sth->fetchrow_array;
is ($setsCount, 1, 'There is 1 set left');
$set1 = GetOAISet($set1_id);
is_deeply ($set1, {}, '$set1 is empty');

DelOAISet($set2_id);
$sth = $dbh->prepare("SELECT count(*) FROM oai_sets");
$sth->execute;
$setsCount = $sth->fetchrow_array;
is ($setsCount, 0, 'There is no set anymore');
$set2 = GetOAISet($set2_id);
is_deeply ($set2, {}, '$set2 is empty');

$oai_sets=GetOAISets;
is_deeply ($oai_sets, [], '$oai_sets is empty');


# ---------- Testing UpdateOAISetsBiblio --------
ok (!defined(UpdateOAISetsBiblio), 'UpdateOAISetsBiblio without argument is undef');
ok (!defined(UpdateOAISetsBiblio($arg)), 'UpdateOAISetsBiblio with only 1 argument is undef');

#Create a set
my $setVH = {
    'spec' => 'Set where Author is Victor Hugo',
    'name' => 'VH'
};
my $setVH_id = AddOAISet($setVH);

#Create mappings : 'author' should be 'Victor Hugo'
my $marcflavour = C4::Context->preference('marcflavour');
my $mappingsVH;

if ($marcflavour eq 'UNIMARC' ){
    $mappingsVH = [
        {
            marcfield => '200',
            marcsubfield => 'f',
            operator => 'equal',
            marcvalue => 'Victor Hugo'
        }
    ];
}
else {
    $mappingsVH = [
            {
                marcfield => '100',
                marcsubfield => 'a',
                operator => 'equal',
                marcvalue => 'Victor Hugo'
            }
    ];
}
ModOAISetMappings($setVH_id, $mappingsVH);


#Create a biblio notice corresponding at one of mappings
my $biblionumberVH = create_helper_biblio('Victor Hugo');

#Update
my $record = GetMarcBiblio($biblionumberVH);
UpdateOAISetsBiblio($biblionumberVH, $record);

#is biblio attached to setVH ?
my $oai_setsVH = GetOAISetsBiblio($biblionumberVH);
is($oai_setsVH->[0]->{id}, $setVH_id, 'id is ok');
is($oai_setsVH->[0]->{spec}, $setVH->{spec}, 'id is ok');
is($oai_setsVH->[0]->{name}, $setVH->{name}, 'id is ok');


# ---------- Testing CalcOAISetsBiblio ----------
ok (!defined(CalcOAISetsBiblio), 'CalcOAISetsBiblio without argument is undef');

my @setsEq = CalcOAISetsBiblio($record);
is_deeply(@setsEq, $setVH_id, 'The $record only belongs to $setVH');

#Testing CalcOAISetsBiblio for a mapping which operator is 'notequal'
#Create a set
my $setNotVH = {
    'spec' => 'Set where Author is NOT Victor Hugo',
    'name' => 'NOT VH'
};
my $setNotVH_id = AddOAISet($setNotVH);

#Create mappings : 'author' should NOT be 'Victor Hugo'
$marcflavour = C4::Context->preference('marcflavour');
my $mappingsNotVH;

if ($marcflavour eq 'UNIMARC' ){
    $mappingsNotVH = [
        {
            marcfield => '200',
            marcsubfield => 'f',
            operator => 'notequal',
            marcvalue => 'Victor Hugo'
        }
    ];
}
else {
    $mappingsNotVH = [
            {
                marcfield => '100',
                marcsubfield => 'a',
                operator => 'notequal',
                marcvalue => 'Victor Hugo'
            }
    ];
}
ModOAISetMappings($setNotVH_id, $mappingsNotVH);


#Create a biblio notice corresponding at one of mappings
my $biblionumberNotVH = create_helper_biblio('Sponge, Bob');

#Update
$record = GetMarcBiblio($biblionumberNotVH);
UpdateOAISetsBiblio($biblionumberNotVH, $record);

my @setsNotEq = CalcOAISetsBiblio($record);
is_deeply(@setsNotEq, $setNotVH_id, 'The $record only belongs to $setNotVH');



# ---------- Subs --------------------------------


# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $author = shift;

    return unless (defined($author));

    my $marcflavour = C4::Context->preference('marcflavour');
    my $bib = MARC::Record->new();
    my $title = 'Silence in the library';

    if ($marcflavour eq 'UNIMARC' ){
        $bib->append_fields(
            MARC::Field->new('200', ' ', ' ', f => $author),
            MARC::Field->new('200', ' ', ' ', a => $title),
        );
    }
    else{
        $bib->append_fields(
            MARC::Field->new('100', ' ', ' ', a => $author),
            MARC::Field->new('245', ' ', ' ', a => $title),
        );
    }
    my ($biblionumber)= AddBiblio($bib, '');
    return $biblionumber;
}

$dbh->rollback;