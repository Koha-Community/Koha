#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 16;
use MARC::Record;
use MARC::Field;
use DateTime;
use DateTime::Duration;

use C4::Items;
use C4::Biblio;
use C4::Context;
use Koha::DateUtils;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

# create two branches
my $library = $builder->build( { source => 'Branch' })->{branchcode};
my $library2 = $builder->build( { source => 'Branch' })->{branchcode};

my $frameworkcode = ''; # Use Default for Koha to MARC mappings
$dbh->do(q|
    DELETE FROM marc_subfield_structure
    WHERE ( kohafield = 'items.new_status' OR kohafield = 'items.stocknumber' )
    AND frameworkcode = ?
|, undef, $frameworkcode);

my $new_tagfield = 'i';
$dbh->do(qq|
    INSERT INTO marc_subfield_structure(tagfield, tagsubfield, kohafield, frameworkcode)
    VALUES ( 952, ?, 'items.new_status', ? )
|, undef, $new_tagfield, $frameworkcode);

# Clear cache
my $cache = Koha::Caches->get_instance();
$cache->clear_from_cache("MarcStructure-0-$frameworkcode");
$cache->clear_from_cache("MarcStructure-1-$frameworkcode");
$cache->clear_from_cache("default_value_for_mod_marc-");
$cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");

my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
    MARC::Field->new('245', ' ', ' ', a => 'Silence in the library'),
    MARC::Field->new('942', ' ', ' ', c => 'ITEMTYPE_T'),
);
my ($biblionumber, undef) = C4::Biblio::AddBiblio($record, $frameworkcode);

my ($item_bibnum, $item_bibitemnum, $itemnumber) = C4::Items::AddItem(
    {
        homebranch => $library,
        holdingbranch => $library,
        new_status => 'new_value',
        ccode => 'FIC',
    },
    $biblionumber
);

my $item = C4::Items::GetItem( $itemnumber );
is ( $item->{new_status}, 'new_value', q|AddItem insert the 'new_status' field| );

my ( $tagfield, undef ) = GetMarcFromKohaField('items.itemnumber', $frameworkcode);
my $marc_item = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
is( $marc_item->subfield($tagfield, $new_tagfield), 'new_value', q|Koha mapping is correct|);

# Update the items.new_status field if items.ccode eq 'FIC' => should be updated
my @rules = (
    {
        conditions => [
            {
                field => 'items.ccode',
                value => 'FIC',
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => 'updated_value',
             },
        ],
        age => '0',
    },
);

C4::Items::ToggleNewStatus( { rules => \@rules } );

my $modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'updated_value', q|ToggleNewStatus: The new_status value is updated|);
$marc_item = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
is( $marc_item->subfield($tagfield, $new_tagfield), 'updated_value', q|ToggleNewStatus: The new_status value is updated| );

# Update the items.new_status field if items.ccode eq 'DONT_EXIST' => should not be updated
@rules = (
    {
        conditions => [
            {
                field => 'items.ccode',
                value => 'DONT_EXIST',
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => 'new_updated_value',
             },
        ],
        age => '0',
    },
);

C4::Items::ToggleNewStatus( { rules => \@rules } );

$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'updated_value', q|ToggleNewStatus: The new_status value is not updated|);
$marc_item = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
is( $marc_item->subfield($tagfield, $new_tagfield), 'updated_value', q|ToggleNewStatus: The new_status value is not updated| );

# Play with age
$item = C4::Items::GetItem( $itemnumber );
my $dt_today = dt_from_string;
my $days5ago = $dt_today->add_duration( DateTime::Duration->new( days => -5 ) );

C4::Items::ModItem( { dateaccessioned => $days5ago }, $biblionumber, $itemnumber );
$item = C4::Items::GetItem( $itemnumber );

@rules = (
    {
        conditions => [
            {
                field => 'items.ccode',
                value => 'FIC',
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => 'new_updated_value',
             },
        ],
        age => '10',
    },
);
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'updated_value', q|ToggleNewStatus: Age = 10 : The new_status value is not updated|);

$rules[0]->{age} = 5;
$rules[0]->{substitutions}[0]{value} = 'new_updated_value5';
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'new_updated_value5', q|ToggleNewStatus: Age = 5 : The new_status value is updated|);

$rules[0]->{age} = '';
$rules[0]->{substitutions}[0]{value} = 'new_updated_value_empty_string';
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'new_updated_value_empty_string', q|ToggleNewStatus: Age = '' : The new_status value is updated|);

$rules[0]->{age} = undef;
$rules[0]->{substitutions}[0]{value} = 'new_updated_value_undef';
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'new_updated_value_undef', q|ToggleNewStatus: Age = undef : The new_status value is updated|);

# Field deletion
@rules = (
    {
        conditions => [
            {
                field => 'items.ccode',
                value => 'FIC',
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => '',
             },
        ],
        age => '0',
    },
);

C4::Items::ToggleNewStatus( { rules => \@rules } );

$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, '', q|ToggleNewStatus: The new_status value is empty|);
$marc_item = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
is( $marc_item->subfield($tagfield, $new_tagfield), undef, q|ToggleNewStatus: The new_status field is removed from the item marc| );

# conditions multiple
@rules = (
    {
        conditions => [
            {
                field => 'items.ccode',
                value => 'FIC',
            },
            {
                field => 'items.homebranch',
                value => $library,
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => 'new_value',
             },
        ],
        age => '0',
    },
);

C4::Items::ToggleNewStatus( { rules => \@rules } );

$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'new_value', q|ToggleNewStatus: conditions multiple: all match, the new_status value is updated|);

@rules = (
    {
        conditions => [
            {
                field => 'items.ccode',
                value => 'FIC',
            },
            {
                field => 'items.homebranch',
                value => 'DONT_EXIST',
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => 'new_updated_value',
             },
        ],
        age => '0',
    },
);

C4::Items::ToggleNewStatus( { rules => \@rules } );

$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'new_value', q|ToggleNewStatus: conditions multiple: at least 1 condition does not match, the new_status value is not updated|);

@rules = (
    {
        conditions => [
            {
                field => 'items.ccode',
                value => 'FIC|NFIC',
            },
            {
                field => 'items.homebranch',
                value => "$library|$library2",
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => 'new_updated_value',
             },
        ],
        age => '0',
    },
);

C4::Items::ToggleNewStatus( { rules => \@rules } );

$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'new_updated_value', q|ToggleNewStatus: conditions multiple: the 2 conditions match, the new_status value is updated|);

@rules = (
    {
        conditions => [
            {
                field => 'biblioitems.itemtype',
                value => 'ITEMTYPE_T',
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => 'another_new_updated_value',
             },
        ],
        age => '0',
    },
);

C4::Items::ToggleNewStatus( { rules => \@rules } );

$modified_item = C4::Items::GetItem( $itemnumber );
is( $modified_item->{new_status}, 'another_new_updated_value', q|ToggleNewStatus: conditions on biblioitems|);

# Clear cache
$cache = Koha::Caches->get_instance();
$cache->clear_from_cache("MarcStructure-0-$frameworkcode");
$cache->clear_from_cache("MarcStructure-1-$frameworkcode");
$cache->clear_from_cache("default_value_for_mod_marc-");
$cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");
