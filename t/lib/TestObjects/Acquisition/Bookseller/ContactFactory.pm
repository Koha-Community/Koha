package t::lib::TestObjects::Acquisition::Bookseller::ContactFactory;

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

use Koha::Acquisition::Bookseller::Contacts;
use Koha::Acquisition::Bookseller::Contact;

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
    return 'Koha::Acquisition::Bookseller::Contact';
}

=head createTestGroup( $data [, $hashKey, $testContexts...] )
@OVERLOADED

    my $contacts = t::lib::TestObjects::Acquisition::Bookseller::ContactFactory->createTestGroup([
                        {acqprimary     => 1,                     #DEFAULT
                         claimissues    => 1,                     #DEFAULT
                         claimacquisition => 1,                   #DEFAULT
                         serialsprimary => 1,                     #DEFAULT
                         position       => 'Boss',                #DEFAULT
                         phone          => '+358700123123',       #DEFAULT
                         notes          => 'Noted',               #DEFAULT
                         name           => "Julius Augustus Caesar", #DEFAULT
                         fax            => '+358700123123',       #DEFAULT
                         email          => 'vendor@example.com',  #DEFAULT
                         booksellerid   => 12124                  #MANDATORY to link to Bookseller
                         #id => #Don't use id, since we are just adding a new one
                        },
                        {...},
                    ], undef, $testContext1, $testContext2, $testContext3);

    #Do test stuff...

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext3);

The HASH is keyed with the given $hashKey or 'koha.aqcontacts.name'
See C4::Bookseller::Contact->new() for how the table columns need to be given.

@PARAM1 ARRAYRef of HASHRefs of VendorContact parameters.
@PARAM2 koha.aqcontacs-column which is used as the test context HASH key,
                defaults to the most best option 'name'.
@PARAM3-5 HASHRef of test contexts. You can save the given objects to multiple
                test contexts. Usually one is enough. These test contexts are
                used to help tear down DB changes.
@RETURNS HASHRef of $hashKey => object:

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    my $contact = Koha::Acquisition::Bookseller::Contact->new();
    $contact->set($object);
    $contact->store();
    #Refresh from DB the contact we just made, since there is no UNIQUE identifier aside from PK, we cannot know if there are many objects like this.
    my @contacts = Koha::Acquisition::Bookseller::Contacts->search($object);
    if (scalar(@contacts)) {
        $contact = $contacts[0];
    }
    else {
        die "No Contact added to DB. Fix me to autorecover from this error!";
    }

    return $contact;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey) = @_;

    $object->{acqprimary}     = 1 unless $object->{acqprimary};
    $object->{claimissues}    = 1 unless $object->{claimissues};
    $object->{claimacquisition} = 1 unless $object->{claimacquisition};
    $object->{serialsprimary} = 1 unless $object->{serialsprimary};
    $object->{position}       = 'Boss' unless $object->{position};
    $object->{phone}          = '+358700123123' unless $object->{phone};
    $object->{notes}          = 'Noted' unless $object->{notes};
    $object->{name}           = "Julius Augustus Caesar" unless $object->{name};
    $object->{fax}            = '+358700123123' unless $object->{fax};
    $object->{email}          = 'vendor@example.com' unless $object->{email};
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
        my $contact = Koha::Acquisition::Bookseller::Contacts->cast($object);
        eval {
            #Since there is no UNIQUE constraint for Contacts, we might end up with several exactly the same Contacts, so clean up all of them.
            my @contacts = Koha::Acquisition::Bookseller::Contacts->search({name => $contact->name});
            foreach my $c (@contacts) {
                $c->delete();
            }
        };
        if ($@) {
            die $@;
        }
    }
}

1;
