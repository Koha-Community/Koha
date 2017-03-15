package t::lib::TestObjects::BiblioFactory;

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
use MARC::Record;
use MARC::File::XML;

use C4::Biblio;
use Koha::Database;
use Koha::BiblioDataElements;

use Koha::Exception::BadParameter;

use base qw(t::lib::TestObjects::ObjectFactory);

sub getDefaultHashKey {
    return 'biblioitems.isbn';
}
sub getObjectType {
    return 'MARC::Record';
}

=head t::lib::TestObjects::createTestGroup

    my $record = t::lib::TestObjects::BiblioFactory->createTestGroup(
                        $marcxml || $MARC::Record, undef, $testContext1, $testContext2, $testContext3);

    my $records = t::lib::TestObjects::BiblioFactory->createTestGroup([
                        {'biblio.title' => 'I wish I met your mother',
                         'biblio.author'   => 'Pertti Kurikka',
                         'biblio.copyrightdate' => '1960',
                         'biblio.biblionumber' => 1212,
                         'biblioitems.isbn'     => '9519671580',
                         'biblioitems.itemtype' => 'BK',
                        },
                    ], undef, $testContext1, $testContext2, $testContext3);

Factory takes either a HASH of database table keys, or a MARCXML or a MARC::Record.

Calls C4::Biblio::TransformKohaToMarc() to make a MARC::Record and add it to
the DB
or
transforms a MARC::Record into database tables.
Returns a HASH of MARC::Records or a single MARC::Record depedning if input is an ARRAY or a single object.

The HASH is keyed with the 'biblioitems.isbn', or the given $hashKey. Using for example
'biblioitems.isbn' is very much recommended to make linking objects more easy in test cases.
The biblionumber is injected to the MARC::Record-object to be easily accessable,
so we can get it like this:
    $records->{$key}->{biblionumber};

There is a duplication check to first look for Records with the same ISBN.
If a matching ISBN is found, then we use the existing Record instead of adding a new one.

See C4::Biblio::TransformKohaToMarc() for how the biblio- or biblioitem-tables'
columns need to be given.

@RETURNS HASHRef of MARC::Record-objects

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;

    my $record;
    #Turn the given MARCXML or MARC::Record into a input object.
    if (not(ref($object))) { #scalar, prolly MARCXML
        $object = MARC::Record::new_from_xml( $object, "utf8", 'marc21' );
    }
    elsif ($object->{record} && $object->{record} =~ /<record/) { #This is MARCXML
        $object = MARC::Record::new_from_xml( $object->{record}, "utf8", 'marc21' );
    }
    if (blessed($object) && $object->isa('MARC::Record')) {
        ($record, $object) = $class->handleMARCXML($object);
    }
    else {
        ($record, $object) = $class->handleObject($object);
    }

    #Clone all the parameters of $object to $record
    foreach my $key (keys(%$object)) {
        $record->{$key} = $object->{$key};
    }

    return $record;
}

sub handleMARCXML {
    my ($class, $record) = @_;
    my ($biblionumber, $biblioitemnumber);
    my $object = C4::Biblio::TransformMarcToKoha($record, '');
    $object->{record} = $record;

    $object->{'biblio.title'} = $object->{title};
    delete $object->{title};
    $object->{'biblioitems.isbn'} = $object->{isbn};
    delete $object->{isbn};

    $class->_validateCriticalFields($object);

    my $existingBiblio = $class->existingObjectFound($object);

    unless ($existingBiblio) {
        ($biblionumber, $biblioitemnumber) = C4::Biblio::AddBiblio($record, $object->{frameworkcode} || '', undef);
        $record->{biblionumber} = $biblionumber;
        $record->{biblioitemnumber} = $biblioitemnumber;
    }
    else {
        ($record, $biblionumber, $biblioitemnumber) = C4::Biblio::UpsertBiblio($record, $object->{frameworkcode} || '', undef);
        $record->{biblionumber} = $biblionumber;
        $record->{biblioitemnumber} = $biblioitemnumber;
    }
    return ($record, $object);
}

sub handleObject {
    my ($class, $object) = @_;
    my ($record, $biblionumber, $biblioitemnumber);

    $class->_validateCriticalFields($object);

    my $existingBiblio = $class->existingObjectFound($object);

    unless ($existingBiblio) {
        $record = C4::Biblio::TransformKohaToMarc($object);
        ($biblionumber, $biblioitemnumber) = C4::Biblio::AddBiblio($record,'');
        $record->{biblionumber} = $biblionumber;
        $record->{biblioitemnumber} = $biblioitemnumber;
    }
    else {
        my $bn = $existingBiblio->biblionumber->biblionumber;
        my $bin = $existingBiblio->biblioitemnumber;
        $record = C4::Biblio::GetMarcBiblio($bn); #Funny!
        $record->{biblionumber} = $bn;
        $record->{biblioitemnumber} = $bin;
    }
    return ($record, $object);
}

sub existingObjectFound {
    my ($class, $object) = @_;
    ##First see if the given Record already exists in the DB. For testing purposes we use the isbn as the UNIQUE identifier.
    my $resultset = Koha::Database->new()->schema()->resultset('Biblioitem');
    my $existingBiblio = $resultset->search({isbn => $object->{"biblioitems.isbn"}})->next();
    $existingBiblio = $resultset->search({biblionumber => $object->{"biblio.biblionumber"}})->next() unless $existingBiblio;
    return $existingBiblio;
}

sub _validateCriticalFields {
    my ($class, $object) = @_;

    unless (ref($object) eq 'HASH' && scalar(%$object)) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->createTestGroup():> Given \$object is empty. You must provide some minimum data to build a Biblio, preferably with somekind of a unique identifier.");
    }
    unless ($object->{'biblio.title'}) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->createTestGroup():> 'biblio.title' is a mandatory parameter!");
    }
    $object->{'biblioitems.isbn'} = '971-972-call-me' unless $object->{'biblioitems.isbn'};
}

=head getHashKey
@OVERLOADS
=cut

sub getHashKey {
    my ($class, $object, $primaryKey, $hashKeys) = @_;

    my @collectedHashKeys;
    $hashKeys = [$hashKeys] unless ref($hashKeys) eq 'ARRAY';
    foreach my $hashKey (@$hashKeys) {
        if (not($hashKey) ||
            (not($object->{$hashKey}) && not($object->$hashKey()))
           ) {
            croak $class."->getHashKey($object, $primaryKey, $hashKey):> Given ".ref($object)." has no \$hashKey '$hashKey'.";
        }
        push @collectedHashKeys, $object->{$hashKey} || $object->$hashKey();
    }
    return join('-', @collectedHashKeys);
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey) = @_;
}

=head

    my $records = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($records);

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($class, $records) = @_;

    my ( $biblionumberFieldCode, $biblionumberSubfieldCode ) =
            C4::Biblio::GetMarcFromKohaField( "biblio.biblionumber", '' );

    my $schema = Koha::Database->new_schema();
    while( my ($key, $record) = each %$records) {
        my $biblionumber = $record->subfield($biblionumberFieldCode, $biblionumberSubfieldCode);
        my @biblios = $schema->resultset('Biblio')->search({"-or" => [{biblionumber => $biblionumber},
                                                                      {title => $record->title}]});
        foreach my $b (@biblios) {
            $b->delete();
        }

#ENABLE THIS WHEN PORTING COMPONENT PART CODE
#        #Remove any attached component parts.
#        foreach my $componentPartBiblionumber (  @{C4::Biblio::getComponentBiblionumbers( $record )}  ) {
#            my $error = C4::Biblio::DelBiblio($componentPartBiblionumber);
#        }

        #Remove biblio_data_elements
        Koha::BiblioDataElements->delete($record->{biblioitemnumber});
    }
}
#sub _deleteTestGroupFromIdentifiers {
#    my ($class, $testGroupIdentifiers) = @_;
#
#    my $schema = Koha::Database->new_schema();
#    foreach my $isbn (@$testGroupIdentifiers) {
#        $schema->resultset('Biblio')->search({"biblioitems.isbn" => $isbn},{join => 'biblioitems'})->delete();
#        $schema->resultset('Biblioitem')->search({isbn => $isbn})->delete();
#    }
#}

1;
