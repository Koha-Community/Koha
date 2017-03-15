package t::lib::TestObjects::ItemFactory;

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

#Somehow introducing this breaks CheckoutFactory #use C4::Items; #This seems to work fine without it.
use Koha::Biblios;
use Koha::Biblioitems;
use Koha::Items;
use Koha::Checkouts;

use t::lib::TestObjects::BiblioFactory;

use base qw(t::lib::TestObjects::ObjectFactory);

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);
    return $self;
}

sub getDefaultHashKey {
    return 'barcode';
}
sub getObjectType {
    return 'Koha::Item';
}

=head t::lib::TestObjects::ItemFactory::createTestGroup( $data [, $hashKey] )
@OVERLOADED

Returns a HASH of objects.
Each Item is expected to contain the biblionumber of the Biblio they are added into.
    eg. $item->{biblionumber} = 550242;

The HASH is keyed with the 'barcode', or the given $hashKey.

See C4::Items::AddItem() for how the table columns need to be given.

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    #Look for the parent biblio, if we don't find one, create a default one.
    my ($biblionumber, $biblioitemnumber, $itemnumber);
    my $biblio = t::lib::TestObjects::BiblioFactory->createTestGroup({"biblio.title" => "Test Items' Biblio",
                                                                       "biblioitems.isbn" => $object->{isbn},
                                                                       "biblio.biblionumber" => $object->{biblionumber}},
                                                                          undef, @$stashes);
    $object->{biblionumber} = $biblio->{biblionumber};
    $object->{biblio} = $biblio;

    #Ok we got a biblio, now we can add an Item for it. First see if the Item already exists.
    my $item;
    eval {
        eval {
            $item = Koha::Items->cast($object);
        };
        unless ($item) {
            ($biblionumber, $biblioitemnumber, $itemnumber) = C4::Items::AddItem($object, $object->{biblionumber});
        }
    };
    if ($@) {
        if (blessed($@) && $@->isa('DBIx::Class::Exception') &&
            $@->{msg} =~ /Duplicate entry '.+?' for key 'itembarcodeidx'/) { #DBIx should throw other types of exceptions instead of this general type :(
            #This exception type is OK, we ignore this and try fetching the existing Object next.
            warn "Recovering from duplicate exception.\n";
        }
        else {
            die $@;
        }
    }
    $item = Koha::Items->cast($itemnumber || $object) unless $item;
    unless ($item) {
        carp "ItemFactory:> No item for barcode '".$object->{barcode}."'";
        next();
    }

    return $item;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $item, $hashKey) = @_;
    $self->SUPER::validateAndPopulateDefaultValues($item, $hashKey);

    $item->{homebranch}     = $item->{homebranch} || 'CPL';
    $item->{holdingbranch}  = $item->{holdingbranch} || $item->{homebranch} || 'CPL';
    $item->{itemcallnumber} = 'PRE 84.FAN POST' unless $item->{itemcallnumber};
}

=head
@OVERLOADED

    my $objects = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($records);

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($self, $objects) = @_;

    while( my ($key, $object) = each %$objects) {
        my $item = Koha::Items->cast($object);

        #Delete all attached checkouts
        my @checkouts = Koha::Checkouts->search({itemnumber => $item->itemnumber});
        foreach my $c (@checkouts) {
            $c->delete;
        }

        $item->delete();
    }
}
sub _deleteTestGroupFromIdentifiers {
    my ($self, $testGroupIdentifiers) = @_;

    foreach my $key (@$testGroupIdentifiers) {
        my $item = Koha::Items->cast($key);
        my @checkouts = Koha::Checkouts->search({itemnumber => $item->itemnumber});
        foreach my $c (@checkouts) {
            $c->delete;
        }
        $item->delete();
    }
}

1;
