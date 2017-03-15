package t::lib::TestObjects::CheckoutFactory;

# Copyright Vaara-kirjastot 2015
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
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

use Modern::Perl;
use Carp;
use DateTime;

use C4::Circulation;
use Koha::Patrons;
use Koha::Items;
use Koha::Checkouts;

use t::lib::TestContext;
use t::lib::TestObjects::PatronFactory;
use t::lib::TestObjects::ItemFactory;

use base qw(t::lib::TestObjects::ObjectFactory);

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);
    return $self;
}

sub getDefaultHashKey {
    return ['cardnumber', 'barcode'];
}
sub getObjectType {
    return 'Koha::Checkout';
}

=head t::lib::TestObjects::CheckoutFactory::createTestGroup( $data [, $hashKey], @stashes )

    my $checkoutFactory = t::lib::TestObjects::CheckoutFactory->new();
    my $checkouts = $checkoutFactory->createTestGroup([
                        {#Checkout params
                        },
                        {#More checkout params
                        },
                    ], undef, $testContext1, $testContext2, $testContext3);

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext1);

@PARAM1, ARRAY of HASHes.
  [ {
        cardnumber        => '167Azava0001',
        barcode           => '167Nfafa0010',
        daysOverdue       => 7,     #This Checkout's duedate was 7 days ago. If undef, then uses today as the checkout day.
        daysAgoCheckedout => 28, #This Checkout hapened 28 days ago. If undef, then uses today.
        checkoutBranchRule => 'homebranch' || 'holdingbranch' #From which branch this item is checked out from.
    },
    {
        ...
    }
  ]
@PARAM2, String, the HASH-element to use as the returning HASHes key.
@PARAM3, String, the rule on where to check these Issues out:
                 'homebranch', uses the Item's homebranch as the checkout branch
                 'holdingbranch', uses the Item's holdingbranch as the checkout branch
                 undef, uses the current Environment branch
                 '<branchCode>', checks out all Issues from the given branchCode
@PARAM4-6 HASHRef of test contexts. You can save the given objects to multiple
                test contexts. Usually one is enough. These test contexts are
                used to help tear down DB changes.
@RETURNS HASHRef of $hashKey => Koha::Checkout-objects.
                The HASH is keyed with <cardnumber>-<barcode>, or the given $hashKey.
    Example: {
        '11A001-167N0212' => Koha::Checkout,
        ...
    }
}
=cut

sub handleTestObject {
    my ($class, $checkoutParams, $stashes) = @_;

    #If running this test factory from unit tests or bare script, the context might not have been initialized.
    unless (C4::Context->userenv()) { #Defensive programming to help debug misconfiguration
        t::lib::TestContext::setUserenv();
    }
    my $oldContextBranch = C4::Context->userenv()->{branch};

    my $borrower = t::lib::TestObjects::PatronFactory->createTestGroup(
                                {cardnumber => $checkoutParams->{cardnumber}},
                                undef, @$stashes);

    my $item =     Koha::Items->find({barcode => $checkoutParams->{barcode}});
    unless($item) {
        my $items = t::lib::TestObjects::ItemFactory->createTestGroup(
                                {barcode => $checkoutParams->{barcode}},
                                undef, @$stashes);
        $item = $items->{ $checkoutParams->{barcode} };
    }

    my $duedate = DateTime->now(time_zone => C4::Context->tz());
    if ($checkoutParams->{daysOverdue}) {
        $duedate->subtract(days =>  $checkoutParams->{daysOverdue}  );
    }

    my $checkoutdate = DateTime->now(time_zone => C4::Context->tz());
    if ($checkoutParams->{daysAgoCheckedout}) {
        $checkoutdate->subtract(days =>  $checkoutParams->{daysAgoCheckedout}  );
    }

    #Set the checkout branch
    my $checkoutBranch;
    my $checkoutBranchRule = $checkoutParams->{checkoutBranchRule};
    if (not($checkoutBranchRule)) {
        #Use the existing userenv()->{branch}
    }
    elsif ($checkoutBranchRule eq 'homebranch') {
        $checkoutBranch = $item->homebranch;
    }
    elsif ($checkoutBranchRule eq 'holdingbranch') {
        $checkoutBranch = $item->holdingbranch;
    }
    elsif ($checkoutBranchRule) {
        $checkoutBranch = $checkoutBranchRule;
    }
    C4::Context->userenv()->{branch} = $checkoutBranch if $checkoutBranch;

    my $datedue = C4::Circulation::AddIssue( $borrower->unblessed, $checkoutParams->{barcode}, $duedate, undef, $checkoutdate );
    #We want the issue_id as well.
    my $checkout = Koha::Checkouts->find({ borrowernumber => $borrower->borrowernumber, itemnumber => $item->itemnumber });
    unless ($checkout) {
        carp "CheckoutFactory:> No checkout for cardnumber '".$checkoutParams->{cardnumber}."' and barcode '".$checkoutParams->{barcode}."'";
        return;
    }

    ##Inject default hash keys
    $checkout->{barcode} = $item->barcode;
    $checkout->{cardnumber} = $borrower->cardnumber;
    return $checkout;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey) = @_;
    $self->SUPER::validateAndPopulateDefaultValues($object, $hashKey);

    unless ($object->{cardnumber}) {
        croak __PACKAGE__.":> Mandatory parameter 'cardnumber' missing.";
    }
    unless ($object->{barcode}) {
        croak __PACKAGE__.":> Mandatory parameter 'barcode' missing.";
    }

    if ($object->{checkoutBranchRule} && not($object->{checkoutBranchRule} =~ m/(homebranch)|(holdingbranch)/)) {
        croak __PACKAGE__.":> Optional parameter 'checkoutBranchRule' must be one of these: homebranch, holdingbranch";
    }
}

=head

    my $objects = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($records);

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($self, $objects) = @_;

    while( my ($key, $object) = each %$objects) {
        my $checkout = Koha::Checkouts->cast($object);
        $checkout->delete();
    }
}
sub _deleteTestGroupFromIdentifiers {
    my ($self, $testGroupIdentifiers) = @_;

    my $schema = Koha::Database->new_schema();
    foreach my $key (@$testGroupIdentifiers) {
        $schema->resultset('Issue')->find({"issue_id" => $key})->delete();
    }
}

1;
