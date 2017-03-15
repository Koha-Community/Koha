package t::lib::TestObjects::HoldFactory;

# Copyright KohaSuomi 2015
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

use C4::Context;
use Koha::Database;
use C4::Circulation;
use C4::Members;
use C4::Items;
use C4::Reserves;
use Koha::Patrons;
use Koha::Biblios;
use Koha::Items;
use Koha::Checkouts;

use t::lib::TestObjects::PatronFactory;
use t::lib::TestObjects::ItemFactory;
use t::lib::TestObjects::BiblioFactory;

use base qw(t::lib::TestObjects::ObjectFactory);

sub new {
    my ($class) = @_;

    my $self = {};
    bless($self, $class);
    return $self;
}

sub getDefaultHashKey {
    return ['reservenotes'];
}
sub getObjectType {
    return 'HASH';
}

=head t::lib::TestObjects::HoldFactory::createTestGroup( $data [, $hashKey], @stashes )

    my $holds = t::lib::TestObjects::HoldFactory->createTestGroup([
                        {#Hold params
                        },
                        {#More hold params
                        },
                    ], undef, $testContext1, $testContext2, $testContext3);

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext1);

@PARAM1, ARRAY of HASHes.
  [ {
        cardnumber        => '167Azava0001', #Borrower's cardnumber
        isbn              => '971040323123', #ISBN of the Biblio, even if the record normally doesn't have a ISBN, you must mock one on it.
        barcode           => undef || '911N12032',    #Item's barcode, if this is an Item-level hold.
        branchcode        => 'CPL',
        waitingdate       => undef || '2015-01-15', #Since when has this hold been waiting for pickup?
    },
    {
        ...
    }
  ]
@PARAM2, String, the HASH-element to use as the returning HASHes key.
@PARAM3-5 HASHRef of test contexts. You can save the given objects to multiple
                test contexts. Usually one is enough. These test contexts are
                used to help tear down DB changes.
@RETURNS HASHRef of $hashKey => HASH-objects representing koha.reserves-table columns
                The HASH is keyed with <reservenotes>, or the given $hashKey.
    Example: {
        '11A001-971040323123-43' => {...},
        'my-nice-hold' => {...},
        ...
    }
}
=cut

sub handleTestObject {
    my ($class, $object, $stashes) = @_;
$DB::single=1;
    C4::Reserves::AddReserve($object->{branchcode} || 'CPL',
                                        $object->{borrower}->borrowernumber,
                                        $object->{biblio}->{biblionumber},
                                        undef, #bibitems
                                        undef, #priority
                                        $object->{reservedate}, #resdate
                                        $object->{expirationdate}, #expdate
                                        $object->{reservenotes}, #notes
                                        undef, #title
                                        ($object->{item} ? $object->{item}->itemnumber : undef), #checkitem
                                        undef, #found
                            );
    my $reserve_id = C4::Reserves::GetReserveId({biblionumber   => $object->{biblio}->{biblionumber},
                                            itemnumber     => ($object->{item} ? $object->{item}->itemnumber : undef),
                                            borrowernumber => $object->{borrower}->borrowernumber,
                                        });
    unless ($reserve_id) {
        die "HoldFactory->handleTestObject():> Couldn't create a reserve. for isbn => ".$object->{isbn}.", barcode => ".$object->{barcode}.
            ", item => ".($object->{barcode} ? $object->{barcode} : '')."\n";
    }
    my $hold = C4::Reserves::GetReserve($reserve_id);
    foreach my $key (keys %$object) {
        $hold->{$key} = $object->{$key};
    }

    if ($object->{waitingdate}) {
        eval {
            C4::Reserves::ModReserveAffect($hold->{item}->itemnumber, $hold->{borrower}->borrowernumber);

            #Modify the waitingdate. An ugly hack for a ugly module. Bear with me my men!
            my $dbh = C4::Context->dbh;
            my $query = "UPDATE reserves SET waitingdate = ? WHERE  reserve_id = ?";
            my $sth = $dbh->prepare($query);
            $sth->execute( $hold->{waitingdate}, $hold->{reserve_id} );
        };
        if ($@) {
            warn "HoldFactory->handleTestObject():> Error when setting the waitingdate for ".$class->getHashKey($object)."$@";
        }
    }

    return $hold;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey, $stashes) = @_;
    $self->SUPER::validateAndPopulateDefaultValues($object, $hashKey);

    unless ($object->{cardnumber}) {
        croak __PACKAGE__.":> Mandatory parameter 'cardnumber' missing.";
    }
    unless ($object->{isbn}) {
        croak __PACKAGE__.":> Mandatory parameter 'isbn' missing.";
    }

    my $borrower = t::lib::TestObjects::PatronFactory->createTestGroup(
                                {cardnumber => $object->{cardnumber}},
                                undef, @$stashes);
    $object->{borrower} = $borrower if $borrower;

    my $biblio = t::lib::TestObjects::BiblioFactory->createTestGroup({"biblio.title" => "Test holds' Biblio",
                                                                           "biblioitems.isbn" => $object->{isbn}},
                                                                          undef, @$stashes);
    $object->{biblio} = $biblio if $biblio;

    #Get test Item
    if ($object->{barcode}) {
        my $item = t::lib::TestObjects::ItemFactory->createTestGroup({barcode => $object->{barcode}, isbn => $object->{isbn}}, undef, @$stashes);
        $object->{item} = $item;
    }

    return $object;
}

=head

    my $objects = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($records);

Removes the given test group from the DB.

=cut

sub deleteTestGroup {
    my ($self, $objects) = @_;

    #For some reason DBIx cannot delete from OldReserves-table so using DBI and not losing sleep
    my $dbh = C4::Context->dbh();
    my $del_old_sth = $dbh->prepare("DELETE FROM old_reserves WHERE reserve_id = ?");
    my $del_sth = $dbh->prepare("DELETE FROM reserves WHERE reserve_id = ?");

    while( my ($key, $object) = each %$objects) {
        $del_sth->execute($object->{reserve_id});
        $del_old_sth->execute($object->{reserve_id});
    }
}

1;
