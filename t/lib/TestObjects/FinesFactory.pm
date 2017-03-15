package t::lib::TestObjects::FinesFactory;

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
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Members;
use C4::Accounts;
use Koha::Patrons;

use base qw(t::lib::TestObjects::ObjectFactory);

use t::lib::TestObjects::PatronFactory;

use Koha::Exception::ObjectExists;

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);
    return $self;
}

sub getDefaultHashKey {
    return 'note';
}
sub getObjectType {
    return 'HASH';
}

=head createTestGroup( $data [, $hashKey, $testContexts...] )
@OVERLOADED

    FinesFactory creates new fines into accountlines.
    After testing, all fines created by the FinesFactory will be
    deleted at tearDown.

    my $fines = t::lib::TestObjects::FinesFactory->createTestGroup([
                         amount => 10.0,
                         cardnumber => $borrowers->{'superuberadmin'}->cardnumber,
                         accounttype => 'FU',
                         note => 'unique identifier',
                         },
                    ], undef, $testContext1, $testContext2, $testContext3);

    #Do test stuff...

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext1);
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext2);
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext3);

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $fine, $stashes) = @_;

    my $borrower;
    try {
        $borrower = Koha::Patrons->cast($fine->{cardnumber});
    } catch {
        die $_ unless (blessed($_) && $_->can('rethrow'));
        if ($_->isa('Koha::Exception::UnknownObject')) {
            $borrower = t::lib::TestObjects::PatronFactory->createTestGroup({cardnumber => $fine->{cardnumber}}, undef, @$stashes);
        }
        else {
            $_->rethrow();
        }
    };

    my $accountno = C4::Accounts::getnextacctno($borrower->borrowernumber);

    C4::Accounts::manualinvoice(
        $borrower->borrowernumber,      # borrowernumber
        undef,                          # itemnumber
        $fine->{description},           # description
        $fine->{accounttype},           # accounttype
        $fine->{amount},                # amountoutstanding
        $fine->{note}                   # note, unique identifier
    );

    my $new_fine = $fine;

    $new_fine->{accountno} = $accountno;

    return $new_fine;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($class, $object, $hashKey) = @_;
    $class->SUPER::validateAndPopulateDefaultValues($object, $hashKey);

    unless ($object->{cardnumber}) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->createTestGroup():> 'cardnumber' is a mandatory parameter!");
    }
    unless ($object->{note}) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->createTestGroup():> 'note' is a mandatory parameter!");
    }

    $object->{description} = "Test payment" unless defined $object->{description};
    $object->{accounttype} = "FU" unless defined $object->{accounttype};
}

=head deleteTestGroup
@OVERLOADED

    my $records = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($prefs);

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($class, $acct) = @_;

    my $schema = Koha::Database->new_schema();
    while( my ($key, $val) = each %$acct) {
        if ($schema->resultset('Accountline')->find({"note" => $val->{note} })) {
            $schema->resultset('Accountline')->find({"note" => $val->{note} })->delete();
        }
    }
}

sub _deleteTestGroupFromIdentifiers {
    my ($self, $testGroupIdentifiers) = @_;

    my $schema = Koha::Database->new_schema();
    foreach my $key (@$testGroupIdentifiers) {
        if ($schema->resultset('Accountline')->find({"note" => $key})) {
            $schema->resultset('Accountline')->find({"note" => $key})->delete();
        }
    }
}


1;
