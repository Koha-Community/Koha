package t::lib::TestObjects::Acquisition::BooksellerFactory;

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
use Scalar::Util qw(blessed);

use t::lib::TestObjects::Acquisition::Bookseller::ContactFactory;
use Koha::Acquisition::Bookseller2;
use Koha::Acquisition::Booksellers;

use base qw(t::lib::TestObjects::ObjectFactory);

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);
    return $self;
}

sub getDefaultHashKey {
    return 'name';
}
sub getObjectType {
    return 'Koha::Acquisition::Bookseller2';
}

=head createTestGroup( $data [, $hashKey, $testContexts...] )
@OVERLOADED

    my $booksellers = t::lib::TestObjects::Acquisition::BooksellerFactory->createTestGroup([
                        {url => 'www.muscle.com',
                         name => 'Bookselling Vendor',
                         postal   => 'post',
                         phone => '+358700123123',
                         notes     => 'Notes',
                         listprice => 'EUR',
                         listincgst => 0,
                         invoiceprice => 'EUR',
                         invoiceincgst => 0,
                         gstreg => 1,
                         gstrate => 0,
                         fax => '+358700123123',
                         discount => 10,
                         deliverytime => 2,
                         address1 => 'Where I am',
                         active => 1,
                         accountnumber => 'IBAN 123456789 FI',
                         contacts => [{#Parameters for Koha::Acquisition::Bookseller},
                                      {#DEFAULT is to use ContactFactory's default values}],
                        },
                        {...},
                    ], undef, $testContext1, $testContext2, $testContext3);

    #Do test stuff...

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext3);

The HASH is keyed with the given $hashKey or 'koha.aqbookseller.name'

@PARAM1 ARRAYRef of HASHRefs
@PARAM2 koha.aqbookseller-column which is used as the test context HASH key,
                defaults to the most best option 'name'.
@PARAM3-5 HASHRef of test contexts. You can save the given borrowers to multiple
                test contexts. Usually one is enough. These test contexts are
                used to help tear down DB changes.
@RETURNS HASHRef of $hashKey => Objects:

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    my $contacts = $object->{contacts};
    delete $object->{contacts};

    my $bookseller = Koha::Acquisition::Bookseller2->new();
    $bookseller->set($object);
    $bookseller->store();
    #Refresh from DB the object we just made, since there is no UNIQUE identifier aside from PK, we cannot know if there are many objects like this.
    my @booksellers = Koha::Acquisition::Booksellers->search($object);
    if (scalar(@booksellers)) {
        $bookseller = $booksellers[0];
    }
    else {
        die "No Bookseller added to DB. Fix me to autorecover from this error!";
    }

    foreach my $c (@$contacts) {
        $c->{booksellerid} = $bookseller->id;
    }
    #$bookseller->{contacts} = t::lib::TestObjects::Acquisition::Bookseller::ContactFactory->createTestGroup($contacts, undef, @$stashes);

    return $bookseller;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey) = @_;

    $object->{url} = 'www.muscle.com' unless $object->{url};
    $object->{postal} = 'post' unless $object->{postal};
    $object->{phone} = '+358700123123' unless $object->{phone};
    $object->{notes} = 'Notes' unless $object->{notes};
    $object->{name} = 'Bookselling Vendor' unless $object->{name};
    $object->{listprice} = 'EUR' unless $object->{listprice};
    $object->{listincgst} = 0 unless $object->{listincgst};
    $object->{invoiceprice} = 'EUR' unless $object->{invoiceprice};
    $object->{invoiceincgst} = 0 unless $object->{invoiceincgst};
    $object->{gstreg} = 1 unless $object->{gstreg};
    $object->{gstrate} = 0 unless $object->{gstrate};
    $object->{fax} = '+358700123123' unless $object->{fax};
    $object->{discount} = 10 unless $object->{discount};
    $object->{deliverytime} = 2 unless $object->{deliverytime};
    $object->{address1} = 'Where I am' unless $object->{address1};
    $object->{active} = 1 unless $object->{active};
    $object->{accountnumber} = 'IBAN 123456789 FI' unless $object->{accountnumber};
    $object->{contacts} = [{}] unless $object->{contacts}; #Prepare to create one default contact.

    $self->SUPER::validateAndPopulateDefaultValues($object, $hashKey);
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

    while( my ($key, $object) = each %$objects) {
        my $bookseller = Koha::Acquisition::Booksellers->cast($object);
        eval {
            #Since there is no UNIQUE constraint for Contacts, we might end up with several exactly the same Contacts, so clean up all of them.
            my @booksellers = Koha::Acquisition::Booksellers->search({name => $bookseller->name});
            foreach my $b (@booksellers) {
                $b->delete();
            }
        };
        if ($@) {
            die $@;
        }
    }
}

1;
