#!/usr/bin/perl
use Modern::Perl;

use C4::Members;
use C4::Circulation qw( AddIssue AddReturn CanBookBeIssued );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;

use Test::More tests => 61;

use_ok('Koha::Patron');

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $yesCatCode = $builder->build({
    source => 'Category',
    value => {
        categorycode => 'yesCat',
        checkprevcheckout => 'yes',
    },
});

my $noCatCode = $builder->build({
    source => 'Category',
    value => {
        categorycode => 'noCat',
        checkprevcheckout => 'no',
    },
});

my $inheritCatCode = $builder->build({
    source => 'Category',
    value => {
        categorycode => 'inheritCat',
        checkprevcheckout => 'inherit',
    },
});

# Create context for some tests late on in the file.
my $library = $builder->build({ source => 'Branch' });
my $staff = $builder->build({source => 'Borrower'});

t::lib::Mocks::mock_userenv({ branchcode => $library->{branchcode} });

# wants_check_for_previous_checkout

# We expect the following result matrix:
#
# (1/0 indicates the return value of WantsCheckPrevCheckout; i.e. 1 says we
# should check whether the item was previously issued)
#
# | System Preference | hardyes                           | softyes                           | softno                            | hardno                            |
# |-------------------+-----------------------------------+-----------------------------------+-----------------------------------+-----------------------------------|
# | Category Setting  | yes       | no        | inherit   | yes       | no        | inherit   | yes       | no        | inherit   | yes       | no        | inherit   |
# |-------------------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------+-----------|
# | Patron Setting    | y | n | i | y | n | i | y | n | i | y | n | i | y | n | i | y | n | i | y | n | i | y | n | i | y | n | i | y | n | i | y | n | i | y | n | i |
# |-------------------+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
# | Expected Result   | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 1 | 1 | 0 | 0 | 1 | 0 | 1 | 1 | 0 | 1 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |

my $mappings = [
    {
        syspref    => 'hardyes',
        categories => [
            {
                setting => 'yes',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 1},
                    {setting => 'inherit', result => 1},
                ],
            },
            {
                setting => 'no',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 1},
                    {setting => 'inherit', result => 1},
                ],
            },
            {
                setting => 'inherit',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 1},
                    {setting => 'inherit', result => 1},
                ],
            },
        ],
    },
    {
        syspref    => 'softyes',
        categories => [
            {
                setting => 'yes',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 1},
                ],
            },
            {
                setting => 'no',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 0},
                ],
            },
            {
                setting => 'inherit',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 1},
                ],
            },
        ],
    },
    {
        syspref    => 'softno',
        categories => [
            {
                setting => 'yes',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 1},
                ],
            },
            {
                setting => 'no',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 0},
                ],
            },
            {
                setting => 'inherit',
                patrons => [
                    {setting => 'yes',     result => 1},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 0},
                ],
            },
        ],
    },
    {
        syspref    => 'hardno',
        categories => [
            {
                setting => 'yes',
                patrons => [
                    {setting => 'yes',     result => 0},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 0},
                ],
            },
            {
                setting => 'no',
                patrons => [
                    {setting => 'yes',     result => 0},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 0},
                ],
            },
            {
                setting => 'inherit',
                patrons => [
                    {setting => 'yes',     result => 0},
                    {setting => 'no',      result => 0},
                    {setting => 'inherit', result => 0},
                ],
            },
        ],
    },
];

map {
    my $syspref = $_->{syspref};
    t::lib::Mocks::mock_preference('checkprevcheckout', $syspref);
    map {
        my $code = $_->{setting} . 'Cat';
        map {
            my $kpatron = $builder->build({
                source => 'Borrower',
                value  => {
                    checkprevcheckout => $_->{setting},
                    categorycode => $code,
                },
            });
            my $patron = Koha::Patrons->find($kpatron->{borrowernumber});
            is(
                $patron->wants_check_for_previous_checkout, $_->{result},
                "Predicate with syspref " . $syspref . ", cat " . $code
                    . ", patron " . $_->{setting}
              );
        } @{$_->{patrons}};
    } @{$_->{categories}};
} @{$mappings};

# do_check_for_previous_checkout

# We want to test:
# - DESCRIPTION [RETURNVALUE (0/1)]
## PreIssue (sanity checks)
# - Item, patron [0]
# - Diff item, same bib, same patron [0]
# - Diff item, diff bib, same patron [0]
# - Same item, diff patron [0]
# - Diff item, same bib, diff patron [0]
# - Diff item, diff bib, diff patron [0]
## PostIssue
# - Same item, same patron [1]
# - Diff item, same bib, same patron [1]
# - Diff item, diff bib, same patron [0]
# - Same item, diff patron [0]
# - Diff item, same bib, diff patron [0]
# - Diff item, diff bib, diff patron [0]
## PostReturn
# - Same item, same patron [1]
# - Diff item, same bib, same patron [1]
# - Diff item, diff bib, same patron [0]
# - Same item, diff patron [0]
# - Diff item, same bib, diff patron [0]
# - Diff item, diff bib, diff patron [0]

# Requirements:
# $patron, $different_patron, $items (same bib number), $different_item
my $patron = $builder->build({source => 'Borrower'});
my $patron_d = $builder->build({source => 'Borrower'});

my $biblio = $builder->build_sample_biblio;
$biblio->serial(0)->store;
my $item_1 = $builder->build_sample_item({biblionumber => $biblio->biblionumber})->unblessed;
my $item_2 = $builder->build_sample_item({biblionumber => $biblio->biblionumber})->unblessed;
my $item_d = $builder->build_sample_item->unblessed;

## Testing Sub
sub test_it {
    my ($mapping, $stage) = @_;
    map {
        my $patron = Koha::Patrons->find($_->{patron}->{borrowernumber});
        is(
            $patron->do_check_for_previous_checkout($_->{item}),
            $_->{result}, $stage . ": " . $_->{msg}
        );
    } @{$mapping};
};

## Initial Mappings
my $cpvmappings = [
    {
        msg => "Item, patron [0]",
        item => $item_1,
        patron => $patron,
        result => 0,
    },
    {
        msg => "Diff item, same bib, same patron [0]",
        item => $item_2,
        patron => $patron,
        result => 0,
    },
    {
        msg => "Diff item, diff bib, same patron [0]",
        item => $item_d,
        patron => $patron,
        result => 0,
    },
    {
        msg => "Same item, diff patron [0]",
        item => $item_1,
        patron => $patron_d,
        result => 0,
    },
    {
        msg => "Diff item, same bib, diff patron [0]",
        item => $item_2,
        patron => $patron_d,
        result => 0,
    },
    {
        msg => "Diff item, diff bib, diff patron [0]",
        item => $item_d,
        patron => $patron_d,
        result => 0,
    },
];

test_it($cpvmappings, "PreIssue");

# Issue item_1 to $patron:
my $patron_get_mem = Koha::Patrons->find( $patron->{borrowernumber} );
BAIL_OUT("Issue failed")
    unless AddIssue($patron_get_mem, $item_1->{barcode});

# Then test:
my $cpvPmappings = [
    {
        msg => "Same item, same patron [1]",
        item => $item_1,
        patron => $patron,
        result => 1,
    },
    {
        msg => "Diff item, same bib, same patron [1]",
        item => $item_2,
        patron => $patron,
        result => 1,
    },
    {
        msg => "Diff item, diff bib, same patron [0]",
        item => $item_d,
        patron => $patron,
        result => 0,
    },
    {
        msg => "Same item, diff patron [0]",
        item => $item_1,
        patron => $patron_d,
        result => 0,
    },
    {
        msg => "Diff item, same bib, diff patron [0]",
        item => $item_2,
        patron => $patron_d,
        result => 0,
    },
    {
        msg => "Diff item, diff bib, diff patron [0]",
        item => $item_d,
        patron => $patron_d,
        result => 0,
    },
];

test_it($cpvPmappings, "PostIssue");

# Return item_1 from patron:
BAIL_OUT("Return Failed") unless AddReturn($item_1->{barcode}, $patron->{branchcode});

# Then:
test_it($cpvPmappings, "PostReturn");

# Finally test C4::Circulation::CanBookBeIssued

# We have already tested ->wants_check_for_previous_checkout and
# ->do_check_for_previous_checkout, so all that remains to be tested is
# whetherthe different combinational outcomes of the above return values in
# CanBookBeIssued result in the approriate $needsconfirmation.

# We want to test:
# - DESCRIPTION [RETURNVALUE (0/1)]
# - patron, !wants_check_for_previous_checkout, !do_check_for_previous_checkout
#   [!$issuingimpossible,!$needsconfirmation->{PREVISSUE}]
# - patron, wants_check_for_previous_checkout, !do_check_for_previous_checkout
#   [!$issuingimpossible,!$needsconfirmation->{PREVISSUE}]
# - patron, !wants_check_for_previous_checkout, do_check_for_previous_checkout
#   [!$issuingimpossible,!$needsconfirmation->{PREVISSUE}]
# - patron, wants_check_for_previous_checkout, do_check_for_previous_checkout
#   [!$issuingimpossible,$needsconfirmation->{PREVISSUE}]

# Needs:
# - $patron
# - $item objects (one not issued, another prevIssued)
# - $checkprevcheckout pref (first hardno, then hardyes)

# Our Patron
my $patron_category = $builder->build({ source => 'Category', value => { category_type => 'P', enrolmentfee => 0 } });
my $CBBI_patron = $builder->build({source => 'Borrower', value => { categorycode => $patron_category->{categorycode} }});
$patron = Koha::Patrons->find( $CBBI_patron->{borrowernumber} );
# Our Items

my $new_item = $builder->build_sample_item->unblessed;
my $prev_item = $builder->build_sample_item->unblessed;
# Second is Checked Out
BAIL_OUT("CanBookBeIssued Issue failed")
    unless AddIssue($patron, $prev_item->{barcode});

# Mappings
my $CBBI_mappings = [
    {
        syspref => 'hardno',
        item    => $new_item,
        result  => undef,
        msg     => "patron, !wants_check_for_previous_checkout, !do_check_for_previous_checkout"

    },
    {
        syspref => 'hardyes',
        item    => $new_item,
        result  => undef,
        msg     => "patron, wants_check_for_previous_checkout, !do_check_for_previous_checkout"
    },
    {
        syspref => 'hardno',
        item    => $prev_item,
        result  => undef,
        msg     => "patron, !wants_check_for_previous_checkout, do_check_for_previous_checkout"
    },
    {
        syspref => 'hardyes',
        item    => $prev_item,
        result  => 1,
        msg     => "patron, wants_check_for_previous_checkout, do_check_for_previous_checkout"
    },
];

# Tests
map {
    t::lib::Mocks::mock_preference('checkprevcheckout', $_->{syspref});
    my ( $issuingimpossible, $needsconfirmation ) =
        C4::Circulation::CanBookBeIssued(
            $patron, $_->{item}->{barcode}
        );
    is($needsconfirmation->{PREVISSUE}, $_->{result}, $_->{msg});
} @{$CBBI_mappings};

$schema->storage->txn_rollback;

subtest 'Check previous checkouts for serial' => sub {
    plan tests => 2;
    $schema->storage->txn_begin;

    my $library = $builder->build_object({ class => 'Koha::Libraries'});

    my $patron = $builder->build_object({
            class => 'Koha::Patrons',
            value => {
                branchcode => $library->branchcode
            }
        });
    t::lib::Mocks::mock_userenv({ patron => $patron });

    my $biblio = $builder->build_sample_biblio;
    $biblio->serial(1)->store;

    my $item1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    AddIssue($patron, $item1->barcode);

    is($patron->do_check_for_previous_checkout($item1->unblessed), 1, 'Check only one item if bibliographic record is serial');
    is($patron->do_check_for_previous_checkout($item2->unblessed), 0, 'Check only one item if bibliographic record is serial');

    $schema->storage->txn_rollback;
};

subtest 'Check previous checkouts with delay' => sub {
    plan tests => 3;
    $schema->storage->txn_begin;
    my $library = $builder->build_object({ class => 'Koha::Libraries'});
    my $biblio = $builder->build_sample_biblio;
    my $patron = $builder->build({source => 'Borrower'});
    my $item_object = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    my $issue = Koha::Checkout->new({ branchcode => $library->branchcode, borrowernumber => $patron->{borrowernumber}, itemnumber => $item_object->itemnumber })->store;
    my $returndate = dt_from_string()->subtract( days => 3 );
    my $return = AddReturn($item_object->barcode, $library->branchcode, undef, $returndate);

    t::lib::Mocks::mock_preference('checkprevcheckout', 'hardyes');
    t::lib::Mocks::mock_preference('checkprevcheckoutdelay', 0);
    my $patron1 = Koha::Patrons->find($patron->{borrowernumber});
    is(
            $patron1->do_check_for_previous_checkout($item_object->unblessed),
            1, "Checking CheckPrevCheckoutDelay disabled"
    );
    t::lib::Mocks::mock_preference('checkprevcheckoutdelay', 5);
    is(
            $patron1->do_check_for_previous_checkout($item_object->unblessed),
            1, "Checking CheckPrevCheckoutDelay enabled within delay"
    );
    t::lib::Mocks::mock_preference('checkprevcheckoutdelay', 1);
    is(
            $patron1->do_check_for_previous_checkout($item_object->unblessed),
            0, "Checking CheckPrevCheckoutDelay enabled after delay"
    );
    $schema->storage->txn_rollback;
}
