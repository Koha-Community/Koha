#!/usr/bin/perl

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 23;
use MARC::Record;
use MARC::Field;
use DateTime;
use DateTime::Duration;

use C4::Items  qw( GetMarcItem ToggleNewStatus );
use C4::Biblio qw( AddBiblio GetMarcFromKohaField );
use C4::Context;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

my $builder = t::lib::TestBuilder->new;

# create two branches
my $library  = $builder->build( { source => 'Branch' } )->{branchcode};
my $library2 = $builder->build( { source => 'Branch' } )->{branchcode};

my $frameworkcode = '';    # Use Default for Koha to MARC mappings
$dbh->do(
    q|
    DELETE FROM marc_subfield_structure
    WHERE ( kohafield = 'items.new_status' OR kohafield = 'items.stocknumber' )
    AND frameworkcode = ?
|, undef, $frameworkcode
);

my $new_tagfield = 'i';
$dbh->do(
    qq|
    INSERT INTO marc_subfield_structure(tagfield, tagsubfield, kohafield, frameworkcode)
    VALUES ( 952, ?, 'items.new_status', ? )
|, undef, $new_tagfield, $frameworkcode
);

# Clear cache
my $cache = Koha::Caches->get_instance();
$cache->clear_from_cache("MarcStructure-0-$frameworkcode");
$cache->clear_from_cache("MarcStructure-1-$frameworkcode");
$cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");

my $record = MARC::Record->new();
$record->append_fields(
    MARC::Field->new( '100', ' ', ' ', a => 'Moffat, Steven' ),
    MARC::Field->new( '245', ' ', ' ', a => 'Silence in the library' ),
    MARC::Field->new( '260', ' ', ' ', c => '1999' ),
    MARC::Field->new( '942', ' ', ' ', c => 'ITEMTYPE_T' ),
);
my ( $biblionumber, undef ) = C4::Biblio::AddBiblio( $record, $frameworkcode );

my $item = $builder->build_sample_item(
    {
        biblionumber => $biblionumber,
        library      => $library,
        new_status   => 'new_value',
        ccode        => 'FIC',
    }
);
my $itemnumber = $item->itemnumber;
is( $item->new_status, 'new_value', q|AddItem insert the 'new_status' field| );

my ( $tagfield, undef ) = GetMarcFromKohaField('items.itemnumber');
my $marc_item = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
is( $marc_item->subfield( $tagfield, $new_tagfield ), 'new_value', q|Koha mapping is correct| );

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

my $modified_item = Koha::Items->find($itemnumber);
is( $modified_item->new_status, 'updated_value', q|ToggleNewStatus: The new_status value is updated| );
$marc_item = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
is(
    $marc_item->subfield( $tagfield, $new_tagfield ), 'updated_value',
    q|ToggleNewStatus: The new_status value is updated|
);

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

$modified_item = Koha::Items->find($itemnumber);
is( $modified_item->new_status, 'updated_value', q|ToggleNewStatus: The new_status value is not updated| );
$marc_item = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
is(
    $marc_item->subfield( $tagfield, $new_tagfield ), 'updated_value',
    q|ToggleNewStatus: The new_status value is not updated|
);

# Play with age
my $dt_today = dt_from_string;
my $days5ago = $dt_today->add_duration( DateTime::Duration->new( days => -5 ) );

$modified_item->dateaccessioned($days5ago)->store;

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
        age => '10',    # Confirm not defining agefield, will default to using items.dateaccessioned
    },
);
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = Koha::Items->find($itemnumber);
is( $modified_item->new_status, 'updated_value', q|ToggleNewStatus: Age = 10 : The new_status value is not updated| );

$rules[0]->{age} = 5;
$rules[0]->{substitutions}[0]{value} = 'new_updated_value5';
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = Koha::Items->find($itemnumber);
is( $modified_item->new_status, 'new_updated_value5', q|ToggleNewStatus: Age = 5 : The new_status value is updated| );

$rules[0]->{age} = '';
$rules[0]->{substitutions}[0]{value} = 'new_updated_value_empty_string';
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = Koha::Items->find($itemnumber);
is(
    $modified_item->new_status, 'new_updated_value_empty_string',
    q|ToggleNewStatus: Age = '' : The new_status value is updated|
);

$rules[0]->{age} = undef;
$rules[0]->{substitutions}[0]{value} = 'new_updated_value_undef';
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = Koha::Items->find($itemnumber);
is(
    $modified_item->new_status, 'new_updated_value_undef',
    q|ToggleNewStatus: Age = undef : The new_status value is updated|
);

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

$modified_item = Koha::Items->find($itemnumber);
is( $modified_item->new_status, '', q|ToggleNewStatus: The new_status value is empty| );
$marc_item = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
is(
    $marc_item->subfield( $tagfield, $new_tagfield ), undef,
    q|ToggleNewStatus: The new_status field is removed from the item marc|
);

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

$modified_item = Koha::Items->find($itemnumber);
is(
    $modified_item->new_status, 'new_value',
    q|ToggleNewStatus: conditions multiple: all match, the new_status value is updated|
);

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

$modified_item = Koha::Items->find($itemnumber);
is(
    $modified_item->new_status, 'new_value',
    q|ToggleNewStatus: conditions multiple: at least 1 condition does not match, the new_status value is not updated|
);

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

$modified_item = Koha::Items->find($itemnumber);
is(
    $modified_item->new_status, 'new_updated_value',
    q|ToggleNewStatus: conditions multiple: the 2 conditions match, the new_status value is updated|
);

@rules = (
    {
        # does not exist
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

$modified_item = Koha::Items->find($itemnumber);
is( $modified_item->new_status, 'another_new_updated_value', q|ToggleNewStatus: conditions on biblioitems| );

# Play with the 'Age field'
my $days2ago  = $dt_today->add_duration( DateTime::Duration->new( days => -10 ) );
my $days20ago = $dt_today->add_duration( DateTime::Duration->new( days => -20 ) );
$modified_item->datelastseen($days2ago)->store;
$modified_item->dateaccessioned($days20ago)->store;

# When agefield='items.datelastseen'
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
                value => 'agefield_new_value',
            },
        ],
        age      => '5',
        agefield => 'items.datelastseen' # Confirm defining agefield => 'items.datelastseen' will use items.datelastseen
    },
);
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = Koha::Items->find($itemnumber);
is(
    $modified_item->new_status, 'agefield_new_value',
    q|ToggleNewStatus: Age = 5, agefield = 'items.datelastseen' : The new_status value is not updated|
);

$rules[0]->{age} = 2;
C4::Items::ToggleNewStatus( { rules => \@rules } );
$modified_item = Koha::Items->find($itemnumber);
is(
    $modified_item->new_status, 'agefield_new_value',
    q|ToggleNewStatus: Age = 2, agefield = 'items.datelastseen' : The new_status value is updated|
);

# Condition on biblio column
@rules = (
    {
        # does not exist
        conditions => [
            {
                field => 'biblio.copyrightdate',
                value => '1999',
            },
        ],
        substitutions => [
            {
                field => 'items.new_status',
                value => 'new_updated_value_biblio',
            },
        ],
        age => '0',
    },
);

C4::Items::ToggleNewStatus( { rules => \@rules } );

$modified_item = Koha::Items->find($itemnumber);
is( $modified_item->new_status, 'new_updated_value_biblio', q|ToggleNewStatus: conditions on biblio| );

# Test for error handling in ToggleNewStatus with an on-loan item
subtest "ToggleNewStatus onloan error handling" => sub {
    plan tests => 3;

    # Create a new test item
    my $test_item2 = $builder->build_object( { class => 'Koha::Items' } );
    my $patron2    = $builder->build_object( { class => 'Koha::Patrons' } );

    # Check out the item to create the condition for an error
    $test_item2->checkout( $patron2->borrowernumber );
    ok( $test_item2->onloan, "Item is checked out" );

    # Create rules to try to modify the withdrawn status
    my @withdrawal_rules = (
        {
            conditions => [
                {
                    field => "items.itemnumber",
                    value => $test_item2->itemnumber
                }
            ],
            substitutions => [
                {
                    field => "items.withdrawn",
                    value => 1
                }
            ]
        }
    );

    # Run ToggleNewStatus with the rules and catch errors in the report
    my $error_report = C4::Items::ToggleNewStatus(
        {
            rules       => \@withdrawal_rules,
            report_only => 0
        }
    );

    # Verify report structure
    ok( exists $error_report->{ $test_item2->itemnumber }, "Error item appears in report" );

    is( $test_item2->withdrawn, 0, 'Item should not be withdrawn' );

};

subtest "ToggleNewStatus in-transit error handling" => sub {
    plan tests => 3;

    # Create a new test item
    my $test_item3 = $builder->build_object( { class => 'Koha::Items' } );

    # Create a transfer to put item in-transit
    my $from_library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $to_library   = $builder->build_object( { class => 'Koha::Libraries' } );

    my $transfer = Koha::Item::Transfer->new(
        {
            itemnumber => $test_item3->itemnumber,
            frombranch => $from_library->branchcode,
            tobranch   => $to_library->branchcode,
            datesent   => dt_from_string(),
        }
    )->store;

    # Mark transfer as in transit
    $transfer->datearrived(undef);
    $transfer->store;

    # Verify item is in transit
    my $item_transfer = $test_item3->get_transfer;
    ok( $item_transfer && !$item_transfer->datearrived, "Item is in transit" );

    # Create rules to try to modify the withdrawn status
    my @withdrawal_rules = (
        {
            conditions => [
                {
                    field => "items.itemnumber",
                    value => $test_item3->itemnumber
                }
            ],
            substitutions => [
                {
                    field => "items.withdrawn",
                    value => 1
                }
            ]
        }
    );

    # Run ToggleNewStatus with the rules and catch errors in the report
    my $error_report = C4::Items::ToggleNewStatus(
        {
            rules       => \@withdrawal_rules,
            report_only => 0
        }
    );

    # Verify report structure
    ok( exists $error_report->{ $test_item3->itemnumber }, "Error item appears in report" );

    is( $test_item3->withdrawn, 0, 'Item should not be withdrawn' );
};

# Run twice
t::lib::Mocks::mock_preference( 'CataloguingLog', 1 );
my $actions_nb = $schema->resultset('ActionLog')->count();
C4::Items::ToggleNewStatus( { rules => \@rules } );
is(
    $schema->resultset('ActionLog')->count(), $actions_nb,
    q|ToggleNewStatus: no substitution does not generate action logs|
);

# Cleanup
$cache = Koha::Caches->get_instance();
$cache->clear_from_cache("MarcStructure-0-$frameworkcode");
$cache->clear_from_cache("MarcStructure-1-$frameworkcode");
$cache->clear_from_cache("MarcSubfieldStructure-$frameworkcode");
$schema->storage->txn_rollback;
