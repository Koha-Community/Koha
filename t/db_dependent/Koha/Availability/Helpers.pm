use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Circulation;
use C4::Context;
use C4::Reserves;

use Koha::Biblios;
use Koha::Biblioitems;
use Koha::DateUtils;
use Koha::IssuingRules;
use Koha::Items;
use Koha::Patrons;

sub build_a_test_item {
    my ($biblio, $biblioitem) = @_;

    my $builder = t::lib::TestBuilder->new;
    my $branch_built = $builder->build({source => 'Branch'});
    my $itemtype_built = $builder->build({
        source => 'Itemtype',
        value => {
            notforloan => 0,
            rentalcharge => 0,
        }
    });
    my $another_itemtype_built = $builder->build({
        source => 'Itemtype',
        value => {
            notforloan => 0,
            rentalcharge => 0,
        }
    });
    my $bib = MARC::Record->new();
    my $title = 'Silence in the library';
    if( C4::Context->preference('marcflavour') eq 'UNIMARC' ) {
        $bib->append_fields(
            MARC::Field->new('600', '', '1', a => 'Moffat, Steven'),
            MARC::Field->new('200', '', '', a => $title),
        );
    }
    else {
        $bib->append_fields(
            MARC::Field->new('100', '', '', a => 'Moffat, Steven'),
            MARC::Field->new('245', '', '', a => $title),
        );
    }
    my ($bibnum, $bibitemnum) = C4::Biblio::AddBiblio($bib, '');
    $biblio ||= Koha::Biblios->find($bibnum);
    $biblioitem ||= Koha::Biblioitems->find($bibitemnum);
    $biblioitem->itemtype($another_itemtype_built->{'itemtype'})->store;
    my $item = Koha::Items->find($builder->build({
        source => 'Item',
        value => {
            notforloan => 0,
            damaged => 0,
            biblioitemnumber => $biblioitem->biblioitemnumber,
            biblionumber => $biblio->biblionumber,
            itype => $itemtype_built->{'itemtype'},
            itemlost => 0,
            withdrawn => 0,
            onloan => undef,
            restricted => 0,
            homebranch => $branch_built->{'branchcode'},
            holdingbranch => $branch_built->{'branchcode'},
        }
    })->{'itemnumber'});

    return $item;
}

sub build_a_test_patron {
    my ($params) = @_;

    my $builder = t::lib::TestBuilder->new;
    my $branch_built = $builder->build({ source => 'Branch' });
    my $cat_built = $builder->build({ source => 'Category' });
    return Koha::Patrons->find($builder->build({
        source => 'Borrower',
        value => {
            categorycode => $cat_built->{'categorycode'},
            branchcode => $branch_built->{'branchcode'},
            debarred => undef,
            debarredcomment => undef,
            lost => undef,
            gonenoaddress => undef,
            dateexpiry => output_pref({ dt => dt_from_string()->add_duration( # expires in 100 days
                          DateTime::Duration->new(days => 100)), dateformat => 'iso', dateonly => 1 }),
            dateofbirth => '1950-10-10',
        }
    })->{'borrowernumber'});
}

sub set_default_circulation_rules {
    my ($params) = @_;

    my $dbh = C4::Context->dbh;

    Koha::IssuingRules->search->delete;
    my $rule = Koha::IssuingRule->new({
        branchcode   => '*',
        itemtype     => '*',
        categorycode => '*',
        ccode        => '*',
        permanent_location => '*',
        maxissueqty => 3,
        renewalsallowed => 1,
        holds_per_record => 1,
        reservesallowed => 1,
        opacitemholds => 'Y',
        onshelfholds => 1
    })->store;
    $dbh->do('DELETE FROM branch_item_rules');
    $dbh->do('DELETE FROM default_branch_circ_rules');
    $dbh->do('DELETE FROM default_branch_item_rules');
    $dbh->do('DELETE FROM default_circ_rules');
}

sub set_default_system_preferences {
    t::lib::Mocks::mock_preference('item-level_itypes', 1);
    t::lib::Mocks::mock_preference('AllowHoldsOnDamagedItems', 1);
    t::lib::Mocks::mock_preference('ReservesControlBranch', 'ItemHomeLibrary');
    t::lib::Mocks::mock_preference('BlockExpiredPatronOpacActions', 0);
    t::lib::Mocks::mock_preference('CircControl', 'ItemHomeLibrary');
    t::lib::Mocks::mock_preference('canreservefromotherbranches', 1);
    t::lib::Mocks::mock_preference('IndependentBranches', 0);
    t::lib::Mocks::mock_preference('HomeOrHoldingBranch', 'holdingbranch');
    t::lib::Mocks::mock_preference('maxoutstanding', 5);
    t::lib::Mocks::mock_preference('AgeRestrictionMarker', 'PEGI');
    t::lib::Mocks::mock_preference('maxreserves', 50);
    t::lib::Mocks::mock_preference('NoIssuesChargeGuarantees', 5);
}

sub add_item_level_hold {
    my ($item, $patron, $branch) = @_;

    return C4::Reserves::AddReserve(
            $branch,
            $patron->borrowernumber,
            $item->biblionumber, '',
            1, undef, undef, undef,
            undef, $item->itemnumber,
    );
}

sub add_biblio_level_hold {
    my ($item, $patron, $branch) = @_;

    return C4::Reserves::AddReserve(
            $branch,
            $patron->borrowernumber,
            $item->biblionumber, '',
            1,
    );
}

sub issue_item {
    my ($item, $patron) = @_;

    C4::Context->_new_userenv('xxx');
    C4::Context->set_userenv(0,0,0,'firstname','surname', $patron->branchcode, 'Midway Public Library', '', '', '');
    return C4::Circulation::AddIssue(
            $patron->unblessed,
            $item->barcode
    );
}

1;
