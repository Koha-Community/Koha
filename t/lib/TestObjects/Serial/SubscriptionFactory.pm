package t::lib::TestObjects::Serial::SubscriptionFactory;

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
use Scalar::Util qw(blessed);
use DateTime;

use C4::Context;
use C4::Serials;

use t::lib::TestObjects::PatronFactory;
use Koha::Patrons;
use t::lib::TestObjects::Acquisition::BooksellerFactory;
use Koha::Acquisition::Booksellers;
use t::lib::TestObjects::BiblioFactory;
use Koha::Biblios;
use t::lib::TestObjects::ItemFactory;
use Koha::Items;

use Koha::Serial::Subscriptions;

use base qw(t::lib::TestObjects::ObjectFactory);

sub getDefaultHashKey {
    return 'internalnotes';
}
sub getObjectType {
    return 'Koha::Serial::Subscription';
}

=head createTestGroup( $data [, $hashKey, $testContexts...] )

    my $subscriptions = t::lib::TestObjects::Serial::SubscriptionFactory->createTestGroup([
            {
                internalnotes => 'MagazineName-CPL-1', #MANDATORY! Used as the hash-key
                receiveSerials => 3, #DEFAULT undef, receives this many serials using the default values.
                librarian => 12 || Koha::Patron, #DEFAULT creates a "Subscription Master" Borrower
                branchcode => 'CPL', #DEFAULT
                aqbookseller => 54 || Koha::Acquisition::Bookseller, #DEFAULT creates a 'Bookselling Vendor'.
                cost => undef, #DEFAULT
                aqbudgetid => undef, #DEFAULT
                biblio => 21 || Koha::Biblio, #DEFAULT creates a "Serial magazine" Record
                startdate => '2015-01-01', #DEFAULTs to 1.1 this year, so the subscription is active by default.
                periodicity => 2 || Koha::Serial::Subscription::Frequency, #DEFAULTS to a Frequency of 1/week.
                numberlength => 12, #DEFAULT one year subscription, only one of ['numberlength', 'weeklength', 'monthlength'] is needed
                weeklength => 52, #DEFAULT one year subscription
                monthlength => 12, #DEFAULT one year subscription
                lastvalue1 => 2015, #DEFAULT this year
                innerloop1 => undef, #DEFAULT
                lastvalue2 => 1, #DEFAULT
                innerloop2 => undef, #DEFAULT
                lastvalue3 => 1, #DEFAULT
                innerloop3 => undef, #DEFAULT
                status => 1, #DEFAULT
                notes => 'Public note', #DEFAULT
                letter => 'RLIST', #DEFAULT
                firstacquidate => '2015-01-01', #DEFAULT, same as startdate
                irregularity => undef, #DEFAULT
                numberpattern => 2 || Koha::Serial::Numberpattern, #DEFAULT 2, which is 'Volume, Number, Issue'
                locale => undef, #DEFAULT
                callnumber => MAG 10.2 AZ, #DEFAULT
                manualhistory => 0, #DEFAULT
                serialsadditems => 1, #DEFAULT
                staffdisplaycount => 20, #DEFAULT
                opacdisplaycount => 20, #DEFAULT
                graceperiod => 2, #DEFAULT
                location => 'DISPLAY', #DEFAULT
                enddate => undef, #DEFAULT, calculated
                skip_serialseq => 1, #DEFAULT
            },
            {...
            },
        ], undef, $testContext1, $testContext2, $testContext3);

    #Do test stuff...

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext3);

The HASH is keyed with the given $hashKey or 'koha.subscription.internalnotes'
We default to internalnotes because there is really no unique identifier
to describe the created subscription which wouldn't change across different test runs.

See C4::Serials::NewSubscription() for how the table columns need to be given.

@PARAM1 ARRAYRef of HASHRefs
@PARAM2 koha.subscription-column which is used as the test context HASH key,
@PARAM3-5 HASHRef of test contexts. You can save the given objects to multiple
                test contexts. Usually one is enough. These test contexts are
                used to help tear down DB changes.
@RETURNS HASHRef of $hashKey => $borrower-objects:

See t::lib::TestObjects::ObjectFactory for more documentation
=cut

sub handleTestObject {
    my ($class, $o, $stashes) = @_;

    my $subscriptionid;
    eval {
        $subscriptionid = C4::Serials::NewSubscription(
                                $o->{librarian}->id,
                                $o->{branchcode},
                                $o->{aqbookseller}->id,
                                $o->{cost},
                                $o->{aqbudgetid},
                                $o->{biblio}->{biblionumber} || $o->{biblio}->biblionumber,
                                $o->{startdate},
                                $o->{periodicity},
                                $o->{numberlength},
                                $o->{weeklength},
                                $o->{monthlength},
                                $o->{lastvalue1},
                                $o->{innerloop1},
                                $o->{lastvalue2},
                                $o->{innerloop2},
                                $o->{lastvalue3},
                                $o->{innerloop3},
                                $o->{status},
                                $o->{notes},
                                $o->{letter},
                                $o->{firstacquidate},
                                $o->{irregularity} || '',
                                $o->{numberpattern},
                                $o->{locale},
                                $o->{callnumber},
                                $o->{manualhistory},
                                $o->{internalnotes},
                                $o->{serialsadditems},
                                $o->{staffdisplaycount},
                                $o->{opacdisplaycount},
                                $o->{graceperiod},
                                $o->{location},
                                $o->{enddate},
                                $o->{skip_serialseq}
                        );
    };
    if ($@) {
        die $@;
    }

    my $subscription = Koha::Serial::Subscriptions->cast( $subscriptionid );
    $subscription->periodicity($o->{periodicity});
    $subscription->numberpattern($o->{numberpattern});

    $class->receiveDefaultSerials($subscription, $o->{receiveSerials});

    return $subscription;
}

=head validateAndPopulateDefaultValues
@OVERLOAD

Validates given Object parameters and makes sure that critical fields are given
and populates defaults for missing values.
=cut

sub validateAndPopulateDefaultValues {
    my ($self, $object, $hashKey, $stashes) = @_;

    #Get this year so we can use it to populate always active Objects.
    my $now = DateTime->now(time_zone => C4::Context->tz());
    my $year = $now->year();

    if ($object->{librarian}) {
        $object->{librarian} = Koha::Patrons->cast($object->{librarian});
    }
    else {
        $object->{librarian} = t::lib::TestObjects::PatronFactory->createTestGroup([
                                                        {cardnumber => 'SERIAL420KILLER',
                                                         firstname => 'Subscription',
                                                         surname => 'Master'}], undef, @$stashes)
                                                        ->{SERIAL420KILLER};
    }
    if ($object->{aqbookseller}) {
        $object->{aqbookseller} = Koha::Acquisition::Booksellers->cast($object->{aqbookseller});
    }
    else {
        $object->{aqbookseller} = t::lib::TestObjects::Acquisition::BooksellerFactory->createTestGroup([
                                                        {}], undef, @$stashes)
                                                        ->{'Bookselling Vendor'};
    }
    if ($object->{biblio}) {
        $object->{biblio} = Koha::Biblios->cast($object->{biblio});
    }
    else {
        $object->{biblio} = t::lib::TestObjects::BiblioFactory->createTestGroup([
                                    {'biblio.title' => 'Serial magazine',
                                     'biblio.author'   => 'Pertti Kurikka',
                                     'biblio.copyrightdate' => $year,
                                     'biblioitems.isbn'     => 'isbnisnotsocoolnowadays!',
                                     'biblioitems.itemtype' => 'CR',
                                    },
                                ], undef, @$stashes)
                                ->{'isbnisnotsocoolnowadays!'};
    }
    unless ($object->{internalnotes}) {
        croak __PACKAGE__.":> Mandatory parameter 'internalnotes' missing. This is used as the returning hash-key!";
    }

    $object->{periodicity}   = 4 unless $object->{periodicity};
    $object->{numberpattern} = 2 unless $object->{numberpattern};
    $object->{branchcode}    = 'CPL' unless $object->{branchcode};
    $object->{cost}          = undef unless $object->{cost};
    $object->{aqbudgetid}    = undef unless $object->{aqbudgetid};
    $object->{startdate}     = "$year-01-01" unless $object->{startdate};
    $object->{numberlength}  = undef unless $object->{numberlength};
    $object->{weeklength}    = undef unless $object->{weeklength} || $object->{numberlength};
    $object->{monthlength}   = 12 unless $object->{monthlength} || $object->{weeklength} || $object->{numberlength};
    $object->{lastvalue1}    = $year unless $object->{lastvalue1};
    $object->{innerloop1}    = undef unless $object->{innerloop1};
    $object->{lastvalue2}    = 1 unless $object->{lastvalue2};
    $object->{innerloop2}    = undef unless $object->{innerloop2};
    $object->{lastvalue3}    = 1 unless $object->{lastvalue3};
    $object->{innerloop3}    = undef unless $object->{innerloop3};
    $object->{status}        = 1 unless $object->{status};
    $object->{notes}         = 'Public note' unless $object->{notes};
    $object->{letter}        = 'RLIST' unless $object->{letter};
    $object->{firstacquidate} = "$year-01-01" unless $object->{firstacquidate};
    $object->{irregularity}  = undef unless $object->{irregularity};
    $object->{locale}        = undef unless $object->{locale};
    $object->{callnumber}    = 'MAG 10.2 AZ' unless $object->{callnumber};
    $object->{manualhistory} = 0 unless $object->{manualhistory};
    $object->{serialsadditems} = 1 unless $object->{serialsadditems};
    $object->{staffdisplaycount} = 20 unless $object->{staffdisplaycount};
    $object->{opacdisplaycount} = 20 unless $object->{opacdisplaycount};
    $object->{graceperiod}   = 2 unless $object->{graceperiod};
    $object->{location}      = 'DISPLAY' unless $object->{location};
    $object->{enddate}       = undef unless $object->{enddate};
    $object->{skip_serialseq} = 1 unless $object->{skip_serialseq};
}

sub receiveDefaultSerials {
    my ($class, $subscription, $receiveSerials, $stashes) = @_;
    return unless $receiveSerials;

    foreach (1..$receiveSerials) {
        my ($totalIssues, $waitingSerial) = C4::Serials::GetSerials($subscription->subscriptionid);
        C4::Serials::ModSerialStatus($waitingSerial->{serialid},
                                     $waitingSerial->{serialseq},
                                     Koha::DateUtils::dt_from_string($waitingSerial->{planneddate})->ymd('-'),
                                     Koha::DateUtils::dt_from_string($waitingSerial->{publisheddate})->ymd('-'),
                                     2, #Status => 2 == Received
                                     $waitingSerial->{notes},
                                    );
        my $item = t::lib::TestObjects::ItemFactory->createTestGroup({ barcode => $waitingSerial->{serialid}."-".Koha::DateUtils::dt_from_string($waitingSerial->{publisheddate})->ymd('-'),
                                                                       enumchron => $waitingSerial->{serialseq},
                                                                       biblionumber => $subscription->biblionumber,
                                                                       homebranch => $subscription->branchcode,
                                                                       location => $subscription->location,
                                                                    }, undef, @$stashes);
        C4::Serials::AddItem2Serial( $waitingSerial->{serialid},
                                     $item->itemnumber, );
    }
}

=head deleteTestGroup
@OVERLOADED

    my $records = createTestGroup();
    ##Do funky stuff
    deleteTestGroup($records);

Removes the given test group from the DB.
Also removes all attached serialitems and serials

=cut

sub deleteTestGroup {
    my ($self, $objects) = @_;

    my $schema = Koha::Database->new_schema();
    while( my ($key, $object) = each %$objects) {
        my $subscription = Koha::Serial::Subscriptions->cast($object);
        eval {
            my @serials = $schema->resultset('Serial')->search({subscriptionid => $subscription->subscriptionid});

            ##Because serialitems-table doesn't have a primary key, resorting to a DBI hack.
            my $dbh = C4::Context->dbh();
            my $sth_delete_serialitems = $dbh->prepare("DELETE FROM serialitems WHERE serialid = ?");

            foreach my $s (@serials) {
                $sth_delete_serialitems->execute($s->serialid);
                $s->delete();
            }
            $subscription->delete();
        };
        if ($@) {
            die $@;
        }
    }
}

1;
