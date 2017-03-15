package t::lib::TestObjects::PatronFactory;

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
use Encode;

use C4::Members;
use Koha::Patrons;

use base qw(t::lib::TestObjects::ObjectFactory);

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);
    return $self;
}

sub getDefaultHashKey {
    return 'cardnumber';
}
sub getObjectType {
    return 'Koha::Patron';
}

=head createTestGroup( $data [, $hashKey, $testContexts...] )
@OVERLOADED

    my $borrowerFactory = t::lib::TestObjects::PatronFactory->new();
    my $borrowers = $borrowerFactory->createTestGroup([
                        {firstname => 'Olli-Antti',
                         surname   => 'Kivi',
                         cardnumber => '11A001',
                         branchcode     => 'CPL',
                        },
                        {firstname => 'Olli-Antti2',
                         surname   => 'Kivi2',
                         cardnumber => '11A002',
                         branchcode     => 'FPL',
                        },
                    ], undef, $testContext1, $testContext2, $testContext3);

    #Do test stuff...

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext1);
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext2);
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext3);

The HASH is keyed with the given $hashKey or 'koha.borrowers.cardnumber'
See C4::Members::AddMember() for how the table columns need to be given.

@PARAM1 ARRAYRef of HASHRefs of C4::Members::AddMember()-parameters.
@PARAM2 koha.borrower-column which is used as the test context borrowers HASH key,
                defaults to the most best option cardnumber.
@PARAM3-5 HASHRef of test contexts. You can save the given borrowers to multiple
                test contexts. Usually one is enough. These test contexts are
                used to help tear down DB changes.
@RETURNS HASHRef of $hashKey => $borrower-objects:

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    my $borrower;
    eval {
        $borrower = Koha::Patrons->cast($object); #Try getting the borrower first
    };

    my $borrowernumber;
    unless ($borrower) {
        #Try to add the Borrower, but it might fail because of the barcode or other UNIQUE constraint.
        #Catch the error and try looking for the Borrower if we suspect it is present in the DB.
        eval {
            $borrowernumber = C4::Members::AddMember(%$object);
        };
        if ($@) {
            if (blessed($@) && $@->isa('DBIx::Class::Exception') &&
                $@->{msg} =~ /Duplicate entry '.+?' for key 'cardnumber'/) { #DBIx should throw other types of exceptions instead of this general type :(
                #This exception type is OK, we ignore this and try fetching the existing Object next.
                warn "Recovering from duplicate exception.\n";
            }
            else {
                die $@;
            }
        }
        #If adding failed, we still get some strange borrowernumber result.
        #Check for sure by finding the real borrower.
        $borrower = Koha::Patrons->cast( $borrowernumber || $object );
    }

    unless ($borrower) {
        carp "PatronFactory:> No borrower for cardnumber '".$object->{cardnumber}."'";
        return();
    }

    return $borrower;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $borrower, $hashKey) = @_;
    $self->SUPER::validateAndPopulateDefaultValues($borrower, $hashKey);

    $borrower->{firstname} = 'Maija' unless $borrower->{firstname};
    $borrower->{surname} = Encode::decode('UTF-8', 'Meikäläinen') unless $borrower->{surname};
    $borrower->{cardnumber} = '167A000001TEST' unless $borrower->{cardnumber};
    $borrower->{categorycode} = 'PT' unless $borrower->{categorycode};
    $borrower->{branchcode}   = 'CPL' unless $borrower->{branchcode};
    $borrower->{dateofbirth}  = '1985-10-12' unless $borrower->{dateofbirth};
}

=head deleteTestGroup
@OVERLOADED

    my $records = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($records);

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($self, $objects) = @_;

    my $schema = Koha::Database->new_schema();
    while( my ($key, $object) = each %$objects) {
        my $borrower = Koha::Patrons->cast($object);
        eval {
            $borrower->delete();
        };
        if ($@) {
            if (blessed($@) && $@->isa('DBIx::Class::Exception') &&
                    #Trying to recover. Delete all Checkouts for the Borrower to be able to delete.
                    $@->{msg} =~ /a foreign key constraint fails.+?issues_ibfk_1/) { #DBIx should throw other types of exceptions instead of this general type :(

                my @checkouts = Koha::Checkouts->search({borrowernumber => $borrower->borrowernumber});
                foreach my $c (@checkouts) { $c->delete(); }
                $borrower->delete();
                warn "Recovering from foreign key exception.\n";
            }
            else {
                die $@;
            }
        }

    }
}

1;
