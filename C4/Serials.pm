package C4::Serials;

# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2010 Biblibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Auth qw(haspermission);
use C4::Context;
use DateTime;
use Date::Calc qw(:all);
use POSIX qw(strftime);
use C4::Biblio;
use C4::Log;    # logaction
use C4::Debug;
use C4::Serials::Frequency;
use C4::Serials::Numberpattern;
use Koha::AdditionalField;
use Koha::DateUtils;
use Koha::Serial;
use Koha::Subscriptions;
use Koha::Subscription::Histories;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# Define statuses
use constant {
    EXPECTED               => 1,
    ARRIVED                => 2,
    LATE                   => 3,
    MISSING                => 4,
    MISSING_NEVER_RECIEVED => 41,
    MISSING_SOLD_OUT       => 42,
    MISSING_DAMAGED        => 43,
    MISSING_LOST           => 44,
    NOT_ISSUED             => 5,
    DELETED                => 6,
    CLAIMED                => 7,
    STOPPED                => 8,
};

use constant MISSING_STATUSES => (
    MISSING,          MISSING_NEVER_RECIEVED,
    MISSING_SOLD_OUT, MISSING_DAMAGED,
    MISSING_LOST
);

BEGIN {
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
      &NewSubscription    &ModSubscription    &DelSubscription
      &GetSubscription    &CountSubscriptionFromBiblionumber      &GetSubscriptionsFromBiblionumber
      &SearchSubscriptions
      &GetFullSubscriptionsFromBiblionumber   &GetFullSubscription &ModSubscriptionHistory
      &HasSubscriptionStrictlyExpired &HasSubscriptionExpired &GetExpirationDate &abouttoexpire
      &GetSubscriptionHistoryFromSubscriptionId

      &GetNextSeq &GetSeq &NewIssue           &GetSerials
      &GetLatestSerials   &ModSerialStatus    &GetNextDate       &GetSerials2
      &ReNewSubscription  &GetLateOrMissingIssues
      &GetSerialInformation                   &AddItem2Serial
      &PrepareSerialsData &GetNextExpected    &ModNextExpected
      &GetPreviousSerialid

      &GetSuppliersWithLateIssues
      &GetDistributedTo   &SetDistributedTo
      &getroutinglist     &delroutingmember   &addroutingmember
      &reorder_members
      &check_routing &updateClaim
      &CountIssues
      HasItems
      &subscriptionCurrentlyOnOrder

    );
}

=head1 NAME

C4::Serials - Serials Module Functions

=head1 SYNOPSIS

  use C4::Serials;

=head1 DESCRIPTION

Functions for handling subscriptions, claims routing etc.


=head1 SUBROUTINES

=head2 GetSuppliersWithLateIssues

$supplierlist = GetSuppliersWithLateIssues()

this function get all suppliers with late issues.

return :
an array_ref of suppliers each entry is a hash_ref containing id and name
the array is in name order

=cut

sub GetSuppliersWithLateIssues {
    my $dbh   = C4::Context->dbh;
    my $statuses = join(',', ( LATE, MISSING_STATUSES, CLAIMED ) );
    my $query = qq|
    SELECT DISTINCT id, name
    FROM            subscription
    LEFT JOIN       serial ON serial.subscriptionid=subscription.subscriptionid
    LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
    WHERE id > 0
        AND (
            (planneddate < now() AND serial.status=1)
            OR serial.STATUS IN ( $statuses )
        )
        AND subscription.closed = 0
    ORDER BY name|;
    return $dbh->selectall_arrayref($query, { Slice => {} });
}

=head2 GetSubscriptionHistoryFromSubscriptionId

$history = GetSubscriptionHistoryFromSubscriptionId($subscriptionid);

This function returns the subscription history as a hashref

=cut

sub GetSubscriptionHistoryFromSubscriptionId {
    my ($subscriptionid) = @_;

    return unless $subscriptionid;

    my $dbh   = C4::Context->dbh;
    my $query = qq|
        SELECT *
        FROM   subscriptionhistory
        WHERE  subscriptionid = ?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my $results = $sth->fetchrow_hashref;
    $sth->finish;

    return $results;
}

=head2 GetSerialStatusFromSerialId

$sth = GetSerialStatusFromSerialId();
this function returns a statement handle
After this function, don't forget to execute it by using $sth->execute($serialid)
return :
$sth = $dbh->prepare($query).

=cut

sub GetSerialStatusFromSerialId {
    my $dbh   = C4::Context->dbh;
    my $query = qq|
        SELECT status
        FROM   serial
        WHERE  serialid = ?
    |;
    return $dbh->prepare($query);
}

=head2 GetSerialInformation

$data = GetSerialInformation($serialid);
returns a hash_ref containing :
  items : items marcrecord (can be an array)
  serial table field
  subscription table field
  + information about subscription expiration

=cut

sub GetSerialInformation {
    my ($serialid) = @_;
    my $dbh        = C4::Context->dbh;
    my $query      = qq|
        SELECT serial.*, serial.notes as sernotes, serial.status as serstatus,subscription.*,subscription.subscriptionid as subsid
        FROM   serial LEFT JOIN subscription ON subscription.subscriptionid=serial.subscriptionid
        WHERE  serialid = ?
    |;
    my $rq = $dbh->prepare($query);
    $rq->execute($serialid);
    my $data = $rq->fetchrow_hashref;

    # create item information if we have serialsadditems for this subscription
    if ( $data->{'serialsadditems'} ) {
        my $queryitem = $dbh->prepare("SELECT itemnumber from serialitems where serialid=?");
        $queryitem->execute($serialid);
        my $itemnumbers = $queryitem->fetchall_arrayref( [0] );
        require C4::Items;
        if ( scalar(@$itemnumbers) > 0 ) {
            foreach my $itemnum (@$itemnumbers) {

                #It is ASSUMED that GetMarcItem ALWAYS WORK...
                #Maybe GetMarcItem should return values on failure
                $debug and warn "itemnumber :$itemnum->[0], bibnum :" . $data->{'biblionumber'};
                my $itemprocessed = C4::Items::PrepareItemrecordDisplay( $data->{'biblionumber'}, $itemnum->[0], $data );
                $itemprocessed->{'itemnumber'}   = $itemnum->[0];
                $itemprocessed->{'itemid'}       = $itemnum->[0];
                $itemprocessed->{'serialid'}     = $serialid;
                $itemprocessed->{'biblionumber'} = $data->{'biblionumber'};
                push @{ $data->{'items'} }, $itemprocessed;
            }
        } else {
            my $itemprocessed = C4::Items::PrepareItemrecordDisplay( $data->{'biblionumber'}, '', $data );
            $itemprocessed->{'itemid'}       = "N$serialid";
            $itemprocessed->{'serialid'}     = $serialid;
            $itemprocessed->{'biblionumber'} = $data->{'biblionumber'};
            $itemprocessed->{'countitems'}   = 0;
            push @{ $data->{'items'} }, $itemprocessed;
        }
    }
    $data->{ "status" . $data->{'serstatus'} } = 1;
    $data->{'subscriptionexpired'} = HasSubscriptionExpired( $data->{'subscriptionid'} ) && $data->{'status'} == 1;
    $data->{'abouttoexpire'} = abouttoexpire( $data->{'subscriptionid'} );
    $data->{cannotedit} = not can_edit_subscription( $data );
    return $data;
}

=head2 AddItem2Serial

$rows = AddItem2Serial($serialid,$itemnumber);
Adds an itemnumber to Serial record
returns the number of rows affected

=cut

sub AddItem2Serial {
    my ( $serialid, $itemnumber ) = @_;

    return unless ($serialid and $itemnumber);

    my $dbh = C4::Context->dbh;
    my $rq  = $dbh->prepare("INSERT INTO `serialitems` SET serialid=? , itemnumber=?");
    $rq->execute( $serialid, $itemnumber );
    return $rq->rows;
}

=head2 GetSubscription

$subs = GetSubscription($subscriptionid)
this function returns the subscription which has $subscriptionid as id.
return :
a hashref. This hash contains
subscription, subscriptionhistory, aqbooksellers.name, biblio.title

=cut

sub GetSubscription {
    my ($subscriptionid) = @_;
    my $dbh              = C4::Context->dbh;
    my $query            = qq(
        SELECT  subscription.*,
                subscriptionhistory.*,
                aqbooksellers.name AS aqbooksellername,
                biblio.title AS bibliotitle,
                subscription.biblionumber as bibnum
       FROM subscription
       LEFT JOIN subscriptionhistory ON subscription.subscriptionid=subscriptionhistory.subscriptionid
       LEFT JOIN aqbooksellers ON subscription.aqbooksellerid=aqbooksellers.id
       LEFT JOIN biblio ON biblio.biblionumber=subscription.biblionumber
       WHERE subscription.subscriptionid = ?
    );

    $debug and warn "query : $query\nsubsid :$subscriptionid";
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my $subscription = $sth->fetchrow_hashref;

    $subscription->{cannotedit} = not can_edit_subscription( $subscription );

    # Add additional fields to the subscription into a new key "additional_fields"
    my $additional_field_values = Koha::AdditionalField->fetch_all_values({
            tablename => 'subscription',
            record_id => $subscriptionid,
    });
    $subscription->{additional_fields} = $additional_field_values->{$subscriptionid};

    return $subscription;
}

=head2 GetFullSubscription

   $array_ref = GetFullSubscription($subscriptionid)
   this function reads the serial table.

=cut

sub GetFullSubscription {
    my ($subscriptionid) = @_;

    return unless ($subscriptionid);

    my $dbh              = C4::Context->dbh;
    my $query            = qq|
  SELECT    serial.serialid,
            serial.serialseq,
            serial.planneddate, 
            serial.publisheddate, 
            serial.publisheddatetext,
            serial.status, 
            serial.notes as notes,
            year(IF(serial.publisheddate="00-00-0000",serial.planneddate,serial.publisheddate)) as year,
            aqbooksellers.name as aqbooksellername,
            biblio.title as bibliotitle,
            subscription.branchcode AS branchcode,
            subscription.subscriptionid AS subscriptionid
  FROM      serial 
  LEFT JOIN subscription ON 
          (serial.subscriptionid=subscription.subscriptionid )
  LEFT JOIN aqbooksellers on subscription.aqbooksellerid=aqbooksellers.id 
  LEFT JOIN biblio on biblio.biblionumber=subscription.biblionumber 
  WHERE     serial.subscriptionid = ? 
  ORDER BY year DESC,
          IF(serial.publisheddate="00-00-0000",serial.planneddate,serial.publisheddate) DESC,
          serial.subscriptionid
          |;
    $debug and warn "GetFullSubscription query: $query";
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my $subscriptions = $sth->fetchall_arrayref( {} );
    my $cannotedit = not can_edit_subscription( $subscriptions->[0] ) if scalar @$subscriptions;
    for my $subscription ( @$subscriptions ) {
        $subscription->{cannotedit} = $cannotedit;
    }
    return $subscriptions;
}

=head2 PrepareSerialsData

   $array_ref = PrepareSerialsData($serialinfomation)
   where serialinformation is a hashref array

=cut

sub PrepareSerialsData {
    my ($lines) = @_;

    return unless ($lines);

    my %tmpresults;
    my $year;
    my @res;
    my $startdate;
    my $aqbooksellername;
    my $bibliotitle;
    my @loopissues;
    my $first;
    my $previousnote = "";

    foreach my $subs (@{$lines}) {
        for my $datefield ( qw(publisheddate planneddate) ) {
            # handle 0000-00-00 dates
            if (defined $subs->{$datefield} and $subs->{$datefield} =~ m/^00/) {
                $subs->{$datefield} = undef;
            }
        }
        $subs->{ "status" . $subs->{'status'} } = 1;
        if ( grep { $_ == $subs->{status} } ( EXPECTED, LATE, MISSING_STATUSES, CLAIMED ) ) {
            $subs->{"checked"} = 1;
        }

        if ( $subs->{'year'} && $subs->{'year'} ne "" ) {
            $year = $subs->{'year'};
        } else {
            $year = "manage";
        }
        if ( $tmpresults{$year} ) {
            push @{ $tmpresults{$year}->{'serials'} }, $subs;
        } else {
            $tmpresults{$year} = {
                'year'             => $year,
                'aqbooksellername' => $subs->{'aqbooksellername'},
                'bibliotitle'      => $subs->{'bibliotitle'},
                'serials'          => [$subs],
                'first'            => $first,
            };
        }
    }
    foreach my $key ( sort { $b cmp $a } keys %tmpresults ) {
        push @res, $tmpresults{$key};
    }
    return \@res;
}

=head2 GetSubscriptionsFromBiblionumber

$array_ref = GetSubscriptionsFromBiblionumber($biblionumber)
this function get the subscription list. it reads the subscription table.
return :
reference to an array of subscriptions which have the biblionumber given on input arg.
each element of this array is a hashref containing
startdate, histstartdate,opacnote,missinglist,recievedlist,periodicity,status & enddate

=cut

sub GetSubscriptionsFromBiblionumber {
    my ($biblionumber) = @_;

    return unless ($biblionumber);

    my $dbh            = C4::Context->dbh;
    my $query          = qq(
        SELECT subscription.*,
               branches.branchname,
               subscriptionhistory.*,
               aqbooksellers.name AS aqbooksellername,
               biblio.title AS bibliotitle
       FROM subscription
       LEFT JOIN subscriptionhistory ON subscription.subscriptionid=subscriptionhistory.subscriptionid
       LEFT JOIN aqbooksellers ON subscription.aqbooksellerid=aqbooksellers.id
       LEFT JOIN biblio ON biblio.biblionumber=subscription.biblionumber
       LEFT JOIN branches ON branches.branchcode=subscription.branchcode
       WHERE subscription.biblionumber = ?
    );
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my @res;
    while ( my $subs = $sth->fetchrow_hashref ) {
        $subs->{startdate}     = output_pref( { dt => dt_from_string( $subs->{startdate} ),     dateonly => 1 } );
        $subs->{histstartdate} = output_pref( { dt => dt_from_string( $subs->{histstartdate} ), dateonly => 1 } );
        if ( defined $subs->{histenddate} ) {
           $subs->{histenddate}   = output_pref( { dt => dt_from_string( $subs->{histenddate} ),   dateonly => 1 } );
        } else {
            $subs->{histenddate} = "";
        }
        $subs->{opacnote}     =~ s/\n/\<br\/\>/g;
        $subs->{missinglist}  =~ s/\n/\<br\/\>/g;
        $subs->{recievedlist} =~ s/\n/\<br\/\>/g;
        $subs->{ "periodicity" . $subs->{periodicity} }     = 1;
        $subs->{ "numberpattern" . $subs->{numberpattern} } = 1;
        $subs->{ "status" . $subs->{'status'} }             = 1;

        if (not defined $subs->{enddate} ) {
            $subs->{enddate} = '';
        } else {
            $subs->{enddate} = output_pref( { dt => dt_from_string( $subs->{enddate}), dateonly => 1 } );
        }
        $subs->{'abouttoexpire'}       = abouttoexpire( $subs->{'subscriptionid'} );
        $subs->{'subscriptionexpired'} = HasSubscriptionExpired( $subs->{'subscriptionid'} );
        $subs->{cannotedit} = not can_edit_subscription( $subs );
        push @res, $subs;
    }
    return \@res;
}

=head2 GetFullSubscriptionsFromBiblionumber

   $array_ref = GetFullSubscriptionsFromBiblionumber($biblionumber)
   this function reads the serial table.

=cut

sub GetFullSubscriptionsFromBiblionumber {
    my ($biblionumber) = @_;
    my $dbh            = C4::Context->dbh;
    my $query          = qq|
  SELECT    serial.serialid,
            serial.serialseq,
            serial.planneddate, 
            serial.publisheddate, 
            serial.publisheddatetext,
            serial.status, 
            serial.notes as notes,
            year(IF(serial.publisheddate="00-00-0000",serial.planneddate,serial.publisheddate)) as year,
            biblio.title as bibliotitle,
            subscription.branchcode AS branchcode,
            subscription.subscriptionid AS subscriptionid
  FROM      serial 
  LEFT JOIN subscription ON 
          (serial.subscriptionid=subscription.subscriptionid)
  LEFT JOIN aqbooksellers on subscription.aqbooksellerid=aqbooksellers.id 
  LEFT JOIN biblio on biblio.biblionumber=subscription.biblionumber 
  WHERE     subscription.biblionumber = ? 
  ORDER BY year DESC,
          IF(serial.publisheddate="00-00-0000",serial.planneddate,serial.publisheddate) DESC,
          serial.subscriptionid
          |;
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my $subscriptions = $sth->fetchall_arrayref( {} );
    my $cannotedit = not can_edit_subscription( $subscriptions->[0] ) if scalar @$subscriptions;
    for my $subscription ( @$subscriptions ) {
        $subscription->{cannotedit} = $cannotedit;
    }
    return $subscriptions;
}

=head2 SearchSubscriptions

  @results = SearchSubscriptions($args);

This function returns a list of hashrefs, one for each subscription
that meets the conditions specified by the $args hashref.

The valid search fields are:

  biblionumber
  title
  issn
  ean
  callnumber
  location
  publisher
  bookseller
  branch
  expiration_date
  closed

The expiration_date search field is special; it specifies the maximum
subscription expiration date.

=cut

sub SearchSubscriptions {
    my ( $args ) = @_;

    my $additional_fields = $args->{additional_fields} // [];
    my $matching_record_ids_for_additional_fields = [];
    if ( @$additional_fields ) {
        $matching_record_ids_for_additional_fields = Koha::AdditionalField->get_matching_record_ids({
                fields => $additional_fields,
                tablename => 'subscription',
                exact_match => 0,
        });
        return () unless @$matching_record_ids_for_additional_fields;
    }

    my $query = q|
        SELECT
            subscription.notes AS publicnotes,
            subscriptionhistory.*,
            subscription.*,
            biblio.notes AS biblionotes,
            biblio.title,
            biblio.author,
            biblio.biblionumber,
            aqbooksellers.name AS vendorname,
            biblioitems.issn
        FROM subscription
            LEFT JOIN subscriptionhistory USING(subscriptionid)
            LEFT JOIN biblio ON biblio.biblionumber = subscription.biblionumber
            LEFT JOIN biblioitems ON biblioitems.biblionumber = subscription.biblionumber
            LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
    |;
    $query .= q| WHERE 1|;
    my @where_strs;
    my @where_args;
    if( $args->{biblionumber} ) {
        push @where_strs, "biblio.biblionumber = ?";
        push @where_args, $args->{biblionumber};
    }

    if( $args->{title} ){
        my @words = split / /, $args->{title};
        my (@strs, @args);
        foreach my $word (@words) {
            push @strs, "biblio.title LIKE ?";
            push @args, "%$word%";
        }
        if (@strs) {
            push @where_strs, '(' . join (' AND ', @strs) . ')';
            push @where_args, @args;
        }
    }
    if( $args->{issn} ){
        push @where_strs, "biblioitems.issn LIKE ?";
        push @where_args, "%$args->{issn}%";
    }
    if( $args->{ean} ){
        push @where_strs, "biblioitems.ean LIKE ?";
        push @where_args, "%$args->{ean}%";
    }
    if ( $args->{callnumber} ) {
        push @where_strs, "subscription.callnumber LIKE ?";
        push @where_args, "%$args->{callnumber}%";
    }
    if( $args->{publisher} ){
        push @where_strs, "biblioitems.publishercode LIKE ?";
        push @where_args, "%$args->{publisher}%";
    }
    if( $args->{bookseller} ){
        push @where_strs, "aqbooksellers.name LIKE ?";
        push @where_args, "%$args->{bookseller}%";
    }
    if( $args->{branch} ){
        push @where_strs, "subscription.branchcode = ?";
        push @where_args, "$args->{branch}";
    }
    if ( $args->{location} ) {
        push @where_strs, "subscription.location = ?";
        push @where_args, "$args->{location}";
    }
    if ( $args->{expiration_date} ) {
        push @where_strs, "subscription.enddate <= ?";
        push @where_args, "$args->{expiration_date}";
    }
    if( defined $args->{closed} ){
        push @where_strs, "subscription.closed = ?";
        push @where_args, "$args->{closed}";
    }

    if(@where_strs){
        $query .= ' AND ' . join(' AND ', @where_strs);
    }
    if ( @$additional_fields ) {
        $query .= ' AND subscriptionid IN ('
            . join( ', ', @$matching_record_ids_for_additional_fields )
        . ')';
    }

    $query .= " ORDER BY " . $args->{orderby} if $args->{orderby};

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(@where_args);
    my $results =  $sth->fetchall_arrayref( {} );

    for my $subscription ( @$results ) {
        $subscription->{cannotedit} = not can_edit_subscription( $subscription );
        $subscription->{cannotdisplay} = not can_show_subscription( $subscription );

        my $additional_field_values = Koha::AdditionalField->fetch_all_values({
            record_id => $subscription->{subscriptionid},
            tablename => 'subscription'
        });
        $subscription->{additional_fields} = $additional_field_values->{$subscription->{subscriptionid}};
    }

    return @$results;
}


=head2 GetSerials

($totalissues,@serials) = GetSerials($subscriptionid);
this function gets every serial not arrived for a given subscription
as well as the number of issues registered in the database (all types)
this number is used to see if a subscription can be deleted (=it must have only 1 issue)

FIXME: We should return \@serials.

=cut

sub GetSerials {
    my ( $subscriptionid, $count ) = @_;

    return unless $subscriptionid;

    my $dbh = C4::Context->dbh;

    # status = 2 is "arrived"
    my $counter = 0;
    $count = 5 unless ($count);
    my @serials;
    my $statuses = join( ',', ( ARRIVED, MISSING_STATUSES, NOT_ISSUED ) );
    my $query = "SELECT serialid,serialseq, status, publisheddate,
        publisheddatetext, planneddate,notes, routingnotes
                        FROM   serial
                        WHERE  subscriptionid = ? AND status NOT IN ( $statuses )
                        ORDER BY IF(publisheddate<>'0000-00-00',publisheddate,planneddate) DESC";
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);

    while ( my $line = $sth->fetchrow_hashref ) {
        $line->{ "status" . $line->{status} } = 1;                                         # fills a "statusX" value, used for template status select list
        for my $datefield ( qw( planneddate publisheddate) ) {
            if ($line->{$datefield} && $line->{$datefield}!~m/^00/) {
                $line->{$datefield} =  output_pref( { dt => dt_from_string( $line->{$datefield} ), dateonly => 1 } );
            } else {
                $line->{$datefield} = q{};
            }
        }
        push @serials, $line;
    }

    # OK, now add the last 5 issues arrives/missing
    $query = "SELECT   serialid,serialseq, status, planneddate, publisheddate,
        publisheddatetext, notes, routingnotes
       FROM     serial
       WHERE    subscriptionid = ?
       AND      status IN ( $statuses )
       ORDER BY IF(publisheddate<>'0000-00-00',publisheddate,planneddate) DESC
      ";
    $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    while ( ( my $line = $sth->fetchrow_hashref ) && $counter < $count ) {
        $counter++;
        $line->{ "status" . $line->{status} } = 1;                                         # fills a "statusX" value, used for template status select list
        for my $datefield ( qw( planneddate publisheddate) ) {
            if ($line->{$datefield} && $line->{$datefield}!~m/^00/) {
                $line->{$datefield} = output_pref( { dt => dt_from_string( $line->{$datefield} ), dateonly => 1 } );
            } else {
                $line->{$datefield} = q{};
            }
        }

        push @serials, $line;
    }

    $query = "SELECT count(*) FROM serial WHERE subscriptionid=?";
    $sth   = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my ($totalissues) = $sth->fetchrow;
    return ( $totalissues, @serials );
}

=head2 GetSerials2

@serials = GetSerials2($subscriptionid,$statuses);
this function returns every serial waited for a given subscription
as well as the number of issues registered in the database (all types)
this number is used to see if a subscription can be deleted (=it must have only 1 issue)

$statuses is an arrayref of statuses and is mandatory.

=cut

sub GetSerials2 {
    my ( $subscription, $statuses ) = @_;

    return unless ($subscription and @$statuses);

    my $dbh   = C4::Context->dbh;
    my $query = q|
                 SELECT serialid,serialseq, status, planneddate, publisheddate,
                    publisheddatetext, notes, routingnotes
                 FROM     serial 
                 WHERE    subscriptionid=?
            |
            . q| AND status IN (| . join( ",", ('?') x @$statuses ) . q|)|
            . q|
                 ORDER BY publisheddate,serialid DESC
    |;
    $debug and warn "GetSerials2 query: $query";
    my $sth = $dbh->prepare($query);
    $sth->execute( $subscription, @$statuses );
    my @serials;

    while ( my $line = $sth->fetchrow_hashref ) {
        $line->{ "status" . $line->{status} } = 1; # fills a "statusX" value, used for template status select list
        # Format dates for display
        for my $datefield ( qw( planneddate publisheddate ) ) {
            if (!defined($line->{$datefield}) || $line->{$datefield} =~m/^00/) {
                $line->{$datefield} = q{};
            }
            else {
                $line->{$datefield} = output_pref( { dt => dt_from_string( $line->{$datefield} ), dateonly => 1 } );
            }
        }
        push @serials, $line;
    }
    return @serials;
}

=head2 GetLatestSerials

\@serials = GetLatestSerials($subscriptionid,$limit)
get the $limit's latest serials arrived or missing for a given subscription
return :
a ref to an array which contains all of the latest serials stored into a hash.

=cut

sub GetLatestSerials {
    my ( $subscriptionid, $limit ) = @_;

    return unless ($subscriptionid and $limit);

    my $dbh = C4::Context->dbh;

    my $statuses = join( ',', ( ARRIVED, MISSING_STATUSES ) );
    my $strsth = "SELECT   serialid,serialseq, status, planneddate, publisheddate, notes
                        FROM     serial
                        WHERE    subscriptionid = ?
                        AND      status IN ($statuses)
                        ORDER BY publisheddate DESC LIMIT 0,$limit
                ";
    my $sth = $dbh->prepare($strsth);
    $sth->execute($subscriptionid);
    my @serials;
    while ( my $line = $sth->fetchrow_hashref ) {
        $line->{ "status" . $line->{status} } = 1;                        # fills a "statusX" value, used for template status select list
        $line->{planneddate}   = output_pref( { dt => dt_from_string( $line->{planneddate} ),   dateonly => 1 } );
        $line->{publisheddate} = output_pref( { dt => dt_from_string( $line->{publisheddate} ), dateonly => 1 } );
        push @serials, $line;
    }

    return \@serials;
}

=head2 GetPreviousSerialid

$serialid = GetPreviousSerialid($subscriptionid, $nth)
get the $nth's previous serial for the given subscriptionid
return :
the serialid

=cut

sub GetPreviousSerialid {
    my ( $subscriptionid, $nth ) = @_;
    $nth ||= 1;
    my $dbh = C4::Context->dbh;
    my $return = undef;

    # Status 2: Arrived
    my $strsth = "SELECT   serialid
                        FROM     serial
                        WHERE    subscriptionid = ?
                        AND      status = 2
                        ORDER BY serialid DESC LIMIT $nth,1
                ";
    my $sth = $dbh->prepare($strsth);
    $sth->execute($subscriptionid);
    my @serials;
    my $line = $sth->fetchrow_hashref;
    $return = $line->{'serialid'} if ($line);

    return $return;
}



=head2 GetDistributedTo

$distributedto=GetDistributedTo($subscriptionid)
This function returns the field distributedto for the subscription matching subscriptionid

=cut

sub GetDistributedTo {
    my $dbh = C4::Context->dbh;
    my $distributedto;
    my ($subscriptionid) = @_;

    return unless ($subscriptionid);

    my $query          = "SELECT distributedto FROM subscription WHERE subscriptionid=?";
    my $sth            = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    return ($distributedto) = $sth->fetchrow;
}

=head2 GetNextSeq

    my (
        $nextseq,       $newlastvalue1, $newlastvalue2, $newlastvalue3,
        $newinnerloop1, $newinnerloop2, $newinnerloop3
    ) = GetNextSeq( $subscription, $pattern, $planneddate );

$subscription is a hashref containing all the attributes of the table
'subscription'.
$pattern is a hashref containing all the attributes of the table
'subscription_numberpatterns'.
$planneddate is a date string in iso format.
This function get the next issue for the subscription given on input arg

=cut

sub GetNextSeq {
    my ($subscription, $pattern, $planneddate) = @_;

    return unless ($subscription and $pattern);

    my ( $newlastvalue1, $newlastvalue2, $newlastvalue3,
    $newinnerloop1, $newinnerloop2, $newinnerloop3 );
    my $count = 1;

    if ($subscription->{'skip_serialseq'}) {
        my @irreg = split /;/, $subscription->{'irregularity'};
        if(@irreg > 0) {
            my $irregularities = {};
            $irregularities->{$_} = 1 foreach(@irreg);
            my $issueno = GetFictiveIssueNumber($subscription, $planneddate) + 1;
            while($irregularities->{$issueno}) {
                $count++;
                $issueno++;
            }
        }
    }

    my $numberingmethod = $pattern->{numberingmethod};
    my $calculated = "";
    if ($numberingmethod) {
        $calculated    = $numberingmethod;
        my $locale = $subscription->{locale};
        $newlastvalue1 = $subscription->{lastvalue1} || 0;
        $newlastvalue2 = $subscription->{lastvalue2} || 0;
        $newlastvalue3 = $subscription->{lastvalue3} || 0;
        $newinnerloop1 = $subscription->{innerloop1} || 0;
        $newinnerloop2 = $subscription->{innerloop2} || 0;
        $newinnerloop3 = $subscription->{innerloop3} || 0;
        my %calc;
        foreach(qw/X Y Z/) {
            $calc{$_} = 1 if ($numberingmethod =~ /\{$_\}/);
        }

        for(my $i = 0; $i < $count; $i++) {
            if($calc{'X'}) {
                # check if we have to increase the new value.
                $newinnerloop1 += 1;
                if ($newinnerloop1 >= $pattern->{every1}) {
                    $newinnerloop1  = 0;
                    $newlastvalue1 += $pattern->{add1};
                }
                # reset counter if needed.
                $newlastvalue1 = $pattern->{setto1} if ($newlastvalue1 > $pattern->{whenmorethan1});
            }
            if($calc{'Y'}) {
                # check if we have to increase the new value.
                $newinnerloop2 += 1;
                if ($newinnerloop2 >= $pattern->{every2}) {
                    $newinnerloop2  = 0;
                    $newlastvalue2 += $pattern->{add2};
                }
                # reset counter if needed.
                $newlastvalue2 = $pattern->{setto2} if ($newlastvalue2 > $pattern->{whenmorethan2});
            }
            if($calc{'Z'}) {
                # check if we have to increase the new value.
                $newinnerloop3 += 1;
                if ($newinnerloop3 >= $pattern->{every3}) {
                    $newinnerloop3  = 0;
                    $newlastvalue3 += $pattern->{add3};
                }
                # reset counter if needed.
                $newlastvalue3 = $pattern->{setto3} if ($newlastvalue3 > $pattern->{whenmorethan3});
            }
        }
        if($calc{'X'}) {
            my $newlastvalue1string = _numeration( $newlastvalue1, $pattern->{numbering1}, $locale );
            $calculated =~ s/\{X\}/$newlastvalue1string/g;
        }
        if($calc{'Y'}) {
            my $newlastvalue2string = _numeration( $newlastvalue2, $pattern->{numbering2}, $locale );
            $calculated =~ s/\{Y\}/$newlastvalue2string/g;
        }
        if($calc{'Z'}) {
            my $newlastvalue3string = _numeration( $newlastvalue3, $pattern->{numbering3}, $locale );
            $calculated =~ s/\{Z\}/$newlastvalue3string/g;
        }
    }

    return ($calculated,
            $newlastvalue1, $newlastvalue2, $newlastvalue3,
            $newinnerloop1, $newinnerloop2, $newinnerloop3);
}

=head2 GetSeq

$calculated = GetSeq($subscription, $pattern)
$subscription is a hashref containing all the attributes of the table 'subscription'
$pattern is a hashref containing all the attributes of the table 'subscription_numberpatterns'
this function transforms {X},{Y},{Z} to 150,0,0 for example.
return:
the sequence in string format

=cut

sub GetSeq {
    my ($subscription, $pattern) = @_;

    return unless ($subscription and $pattern);

    my $locale = $subscription->{locale};

    my $calculated = $pattern->{numberingmethod};

    my $newlastvalue1 = $subscription->{'lastvalue1'} || 0;
    $newlastvalue1 = _numeration($newlastvalue1, $pattern->{numbering1}, $locale) if ($pattern->{numbering1}); # reset counter if needed.
    $calculated =~ s/\{X\}/$newlastvalue1/g;

    my $newlastvalue2 = $subscription->{'lastvalue2'} || 0;
    $newlastvalue2 = _numeration($newlastvalue2, $pattern->{numbering2}, $locale) if ($pattern->{numbering2}); # reset counter if needed.
    $calculated =~ s/\{Y\}/$newlastvalue2/g;

    my $newlastvalue3 = $subscription->{'lastvalue3'} || 0;
    $newlastvalue3 = _numeration($newlastvalue3, $pattern->{numbering3}, $locale) if ($pattern->{numbering3}); # reset counter if needed.
    $calculated =~ s/\{Z\}/$newlastvalue3/g;
    return $calculated;
}

=head2 GetExpirationDate

$enddate = GetExpirationDate($subscriptionid, [$startdate])

this function return the next expiration date for a subscription given on input args.

return
the enddate or undef

=cut

sub GetExpirationDate {
    my ( $subscriptionid, $startdate ) = @_;

    return unless ($subscriptionid);

    my $dbh          = C4::Context->dbh;
    my $subscription = GetSubscription($subscriptionid);
    my $enddate;

    # we don't do the same test if the subscription is based on X numbers or on X weeks/months
    $enddate = $startdate || $subscription->{startdate};
    my @date = split( /-/, $enddate );

    return if ( scalar(@date) != 3 || not check_date(@date) );

    my $frequency = C4::Serials::Frequency::GetSubscriptionFrequency($subscription->{periodicity});
    if ( $frequency and $frequency->{unit} ) {

        # If Not Irregular
        if ( my $length = $subscription->{numberlength} ) {

            #calculate the date of the last issue.
            for ( my $i = 1 ; $i <= $length ; $i++ ) {
                $enddate = GetNextDate( $subscription, $enddate );
            }
        } elsif ( $subscription->{monthlength} ) {
            if ( $$subscription{startdate} ) {
                my @enddate = Add_Delta_YM( $date[0], $date[1], $date[2], 0, $subscription->{monthlength} );
                $enddate = sprintf( "%04d-%02d-%02d", $enddate[0], $enddate[1], $enddate[2] );
            }
        } elsif ( $subscription->{weeklength} ) {
            if ( $$subscription{startdate} ) {
                my @date = split( /-/, $subscription->{startdate} );
                my @enddate = Add_Delta_Days( $date[0], $date[1], $date[2], $subscription->{weeklength} * 7 );
                $enddate = sprintf( "%04d-%02d-%02d", $enddate[0], $enddate[1], $enddate[2] );
            }
        } else {
            $enddate = $subscription->{enddate};
        }
        return $enddate;
    } else {
        return $subscription->{enddate};
    }
}

=head2 CountSubscriptionFromBiblionumber

$subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber)
this returns a count of the subscriptions for a given biblionumber
return :
the number of subscriptions

=cut

sub CountSubscriptionFromBiblionumber {
    my ($biblionumber) = @_;

    return unless ($biblionumber);

    my $dbh            = C4::Context->dbh;
    my $query          = "SELECT count(*) FROM subscription WHERE biblionumber=?";
    my $sth            = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my $subscriptionsnumber = $sth->fetchrow;
    return $subscriptionsnumber;
}

=head2 ModSubscriptionHistory

ModSubscriptionHistory($subscriptionid,$histstartdate,$enddate,$recievedlist,$missinglist,$opacnote,$librariannote);

this function modifies the history of a subscription. Put your new values on input arg.
returns the number of rows affected

=cut

sub ModSubscriptionHistory {
    my ( $subscriptionid, $histstartdate, $enddate, $receivedlist, $missinglist, $opacnote, $librariannote ) = @_;

    return unless ($subscriptionid);

    my $dbh   = C4::Context->dbh;
    my $query = "UPDATE subscriptionhistory 
                    SET histstartdate=?,histenddate=?,recievedlist=?,missinglist=?,opacnote=?,librariannote=?
                    WHERE subscriptionid=?
                ";
    my $sth = $dbh->prepare($query);
    $receivedlist =~ s/^; // if $receivedlist;
    $missinglist  =~ s/^; // if $missinglist;
    $opacnote     =~ s/^; // if $opacnote;
    $sth->execute( $histstartdate, $enddate, $receivedlist, $missinglist, $opacnote, $librariannote, $subscriptionid );
    return $sth->rows;
}

=head2 ModSerialStatus

    ModSerialStatus($serialid, $serialseq, $planneddate, $publisheddate,
        $publisheddatetext, $status, $notes);

This function modify the serial status. Serial status is a number.(eg 2 is "arrived")
Note : if we change from "waited" to something else,then we will have to create a new "waited" entry

=cut

sub ModSerialStatus {
    my ($serialid, $serialseq, $planneddate, $publisheddate, $publisheddatetext,
        $status, $notes) = @_;

    return unless ($serialid);

    #It is a usual serial
    # 1st, get previous status :
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT serial.subscriptionid,serial.status,subscription.periodicity
        FROM serial, subscription
        WHERE serial.subscriptionid=subscription.subscriptionid
            AND serialid=?";
    my $sth   = $dbh->prepare($query);
    $sth->execute($serialid);
    my ( $subscriptionid, $oldstatus, $periodicity ) = $sth->fetchrow;
    my $frequency = GetSubscriptionFrequency($periodicity);

    # change status & update subscriptionhistory
    my $val;
    if ( $status == DELETED ) {
        DelIssue( { 'serialid' => $serialid, 'subscriptionid' => $subscriptionid, 'serialseq' => $serialseq } );
    } else {

        my $query = '
            UPDATE serial
            SET serialseq = ?, publisheddate = ?, publisheddatetext = ?,
                planneddate = ?, status = ?, notes = ?
            WHERE  serialid = ?
        ';
        $sth = $dbh->prepare($query);
        $sth->execute( $serialseq, $publisheddate, $publisheddatetext,
            $planneddate, $status, $notes, $serialid );
        $query = "SELECT * FROM   subscription WHERE  subscriptionid = ?";
        $sth   = $dbh->prepare($query);
        $sth->execute($subscriptionid);
        my $val = $sth->fetchrow_hashref;
        unless ( $val->{manualhistory} ) {
            $query = "SELECT missinglist,recievedlist FROM subscriptionhistory WHERE  subscriptionid=?";
            $sth   = $dbh->prepare($query);
            $sth->execute($subscriptionid);
            my ( $missinglist, $recievedlist ) = $sth->fetchrow;

            if ( $status == ARRIVED || ($oldstatus == ARRIVED && $status != ARRIVED) ) {
                $recievedlist .= "; $serialseq"
                    if ($recievedlist !~ /(^|;)\s*$serialseq(?=;|$)/);
            }

            # in case serial has been previously marked as missing
            if (grep /$status/, (EXPECTED, ARRIVED, LATE, CLAIMED)) {
                $missinglist=~ s/(^|;)\s*$serialseq(?=;|$)//g;
            }

            $missinglist .= "; $serialseq"
                if ( ( grep { $_ == $status } ( MISSING_STATUSES ) ) && ( $missinglist !~/(^|;)\s*$serialseq(?=;|$)/ ) );
            $missinglist .= "; not issued $serialseq"
                if ( $status == NOT_ISSUED && $missinglist !~ /(^|;)\s*$serialseq(?=;|$)/ );

            $query = "UPDATE subscriptionhistory SET recievedlist=?, missinglist=? WHERE  subscriptionid=?";
            $sth   = $dbh->prepare($query);
            $recievedlist =~ s/^; //;
            $missinglist  =~ s/^; //;
            $sth->execute( $recievedlist, $missinglist, $subscriptionid );
        }
    }

    # create new expected entry if needed (ie : was "expected" and has changed)
    my $otherIssueExpected = scalar findSerialsByStatus(EXPECTED, $subscriptionid);
    if ( !$otherIssueExpected && $oldstatus == EXPECTED && $status != EXPECTED ) {
        my $subscription = GetSubscription($subscriptionid);
        my $pattern = C4::Serials::Numberpattern::GetSubscriptionNumberpattern($subscription->{numberpattern});

        # next issue number
        my (
            $newserialseq,  $newlastvalue1, $newlastvalue2, $newlastvalue3,
            $newinnerloop1, $newinnerloop2, $newinnerloop3
          )
          = GetNextSeq( $subscription, $pattern, $publisheddate );

        # next date (calculated from actual date & frequency parameters)
        my $nextpublisheddate = GetNextDate($subscription, $publisheddate, 1);
        my $nextpubdate = $nextpublisheddate;
        $query = "UPDATE subscription SET lastvalue1=?, lastvalue2=?, lastvalue3=?, innerloop1=?, innerloop2=?, innerloop3=?
                    WHERE  subscriptionid = ?";
        $sth = $dbh->prepare($query);
        $sth->execute( $newlastvalue1, $newlastvalue2, $newlastvalue3, $newinnerloop1, $newinnerloop2, $newinnerloop3, $subscriptionid );

        NewIssue( $newserialseq, $subscriptionid, $subscription->{'biblionumber'}, 1, $nextpubdate, $nextpubdate );

        # check if an alert must be sent... (= a letter is defined & status became "arrived"
        if ( $subscription->{letter} && $status == ARRIVED && $oldstatus != ARRIVED ) {
            require C4::Letters;
            C4::Letters::SendAlerts( 'issue', $serialid, $subscription->{letter} );
        }
    }

    return;
}

=head2 GetNextExpected

$nextexpected = GetNextExpected($subscriptionid)

Get the planneddate for the current expected issue of the subscription.

returns a hashref:

$nextexepected = {
    serialid => int
    planneddate => ISO date
    }

=cut

sub GetNextExpected {
    my ($subscriptionid) = @_;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT *
        FROM serial
        WHERE subscriptionid = ?
          AND status = ?
        LIMIT 1
    };
    my $sth = $dbh->prepare($query);

    # Each subscription has only one 'expected' issue.
    $sth->execute( $subscriptionid, EXPECTED );
    my $nextissue = $sth->fetchrow_hashref;
    if ( !$nextissue ) {
        $query = qq{
            SELECT *
            FROM serial
            WHERE subscriptionid = ?
            ORDER BY publisheddate DESC
            LIMIT 1
        };
        $sth = $dbh->prepare($query);
        $sth->execute($subscriptionid);
        $nextissue = $sth->fetchrow_hashref;
    }
    foreach(qw/planneddate publisheddate/) {
        if ( !defined $nextissue->{$_} ) {
            # or should this default to 1st Jan ???
            $nextissue->{$_} = strftime( '%Y-%m-%d', localtime );
        }
        $nextissue->{$_} = ($nextissue->{$_} ne '0000-00-00')
                         ? $nextissue->{$_}
                         : undef;
    }

    return $nextissue;
}

=head2 ModNextExpected

ModNextExpected($subscriptionid,$date)

Update the planneddate for the current expected issue of the subscription.
This will modify all future prediction results.  

C<$date> is an ISO date.

returns 0

=cut

sub ModNextExpected {
    my ( $subscriptionid, $date ) = @_;
    my $dbh = C4::Context->dbh;

    #FIXME: Would expect to only set planneddate, but we set both on new issue creation, so updating it here
    my $sth = $dbh->prepare('UPDATE serial SET planneddate=?,publisheddate=? WHERE subscriptionid=? AND status=?');

    # Each subscription has only one 'expected' issue.
    $sth->execute( $date, $date, $subscriptionid, EXPECTED );
    return 0;

}

=head2 GetSubscriptionIrregularities

=over 4

=item @irreg = &GetSubscriptionIrregularities($subscriptionid);
get the list of irregularities for a subscription

=back

=cut

sub GetSubscriptionIrregularities {
    my $subscriptionid = shift;

    return unless $subscriptionid;

    my $dbh = C4::Context->dbh;
    my $query = qq{
        SELECT irregularity
        FROM subscription
        WHERE subscriptionid = ?
    };
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);

    my ($result) = $sth->fetchrow_array;
    my @irreg = split /;/, $result;

    return @irreg;
}

=head2 ModSubscription

this function modifies a subscription. Put all new values on input args.
returns the number of rows affected

=cut

sub ModSubscription {
    my (
    $auser, $branchcode, $aqbooksellerid, $cost, $aqbudgetid, $startdate,
    $periodicity, $firstacquidate, $irregularity, $numberpattern, $locale,
    $numberlength, $weeklength, $monthlength, $lastvalue1, $innerloop1,
    $lastvalue2, $innerloop2, $lastvalue3, $innerloop3, $status,
    $biblionumber, $callnumber, $notes, $letter, $manualhistory,
    $internalnotes, $serialsadditems, $staffdisplaycount, $opacdisplaycount,
    $graceperiod, $location, $enddate, $subscriptionid, $skip_serialseq,
    $itemtype, $previousitemtype
    ) = @_;

    my $dbh   = C4::Context->dbh;
    my $query = "UPDATE subscription
        SET librarian=?, branchcode=?, aqbooksellerid=?, cost=?, aqbudgetid=?,
            startdate=?, periodicity=?, firstacquidate=?, irregularity=?,
            numberpattern=?, locale=?, numberlength=?, weeklength=?, monthlength=?,
            lastvalue1=?, innerloop1=?, lastvalue2=?, innerloop2=?,
            lastvalue3=?, innerloop3=?, status=?, biblionumber=?,
            callnumber=?, notes=?, letter=?, manualhistory=?,
            internalnotes=?, serialsadditems=?, staffdisplaycount=?,
            opacdisplaycount=?, graceperiod=?, location = ?, enddate=?,
            skip_serialseq=?, itemtype=?, previousitemtype=?
        WHERE subscriptionid = ?";

    my $sth = $dbh->prepare($query);
    $sth->execute(
        $auser,           $branchcode,     $aqbooksellerid, $cost,
        $aqbudgetid,      $startdate,      $periodicity,    $firstacquidate,
        $irregularity,    $numberpattern,  $locale,         $numberlength,
        $weeklength,      $monthlength,    $lastvalue1,     $innerloop1,
        $lastvalue2,      $innerloop2,     $lastvalue3,     $innerloop3,
        $status,          $biblionumber,   $callnumber,     $notes,
        $letter,          ($manualhistory ? $manualhistory : 0),
        $internalnotes, $serialsadditems, $staffdisplaycount, $opacdisplaycount,
        $graceperiod,     $location,       $enddate,        $skip_serialseq,
        $itemtype,        $previousitemtype,
        $subscriptionid
    );
    my $rows = $sth->rows;

    logaction( "SERIAL", "MODIFY", $subscriptionid, "" ) if C4::Context->preference("SubscriptionLog");
    return $rows;
}

=head2 NewSubscription

$subscriptionid = &NewSubscription($auser,branchcode,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
    $startdate,$periodicity,$numberlength,$weeklength,$monthlength,
    $lastvalue1,$innerloop1,$lastvalue2,$innerloop2,$lastvalue3,$innerloop3,
    $status, $notes, $letter, $firstacquidate, $irregularity, $numberpattern,
    $locale, $callnumber, $manualhistory, $internalnotes, $serialsadditems,
    $staffdisplaycount, $opacdisplaycount, $graceperiod, $location, $enddate,
    $skip_serialseq, $itemtype, $previousitemtype);

Create a new subscription with value given on input args.

return :
the id of this new subscription

=cut

sub NewSubscription {
    my (
    $auser, $branchcode, $aqbooksellerid, $cost, $aqbudgetid, $biblionumber,
    $startdate, $periodicity, $numberlength, $weeklength, $monthlength,
    $lastvalue1, $innerloop1, $lastvalue2, $innerloop2, $lastvalue3,
    $innerloop3, $status, $notes, $letter, $firstacquidate, $irregularity,
    $numberpattern, $locale, $callnumber, $manualhistory, $internalnotes,
    $serialsadditems, $staffdisplaycount, $opacdisplaycount, $graceperiod,
    $location, $enddate, $skip_serialseq, $itemtype, $previousitemtype
    ) = @_;
    my $dbh = C4::Context->dbh;

    #save subscription (insert into database)
    my $query = qq|
        INSERT INTO subscription
            (librarian, branchcode, aqbooksellerid, cost, aqbudgetid,
            biblionumber, startdate, periodicity, numberlength, weeklength,
            monthlength, lastvalue1, innerloop1, lastvalue2, innerloop2,
            lastvalue3, innerloop3, status, notes, letter, firstacquidate,
            irregularity, numberpattern, locale, callnumber,
            manualhistory, internalnotes, serialsadditems, staffdisplaycount,
            opacdisplaycount, graceperiod, location, enddate, skip_serialseq,
            itemtype, previousitemtype)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        |;
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $auser, $branchcode, $aqbooksellerid, $cost, $aqbudgetid, $biblionumber,
        $startdate, $periodicity, $numberlength, $weeklength,
        $monthlength, $lastvalue1, $innerloop1, $lastvalue2, $innerloop2,
        $lastvalue3, $innerloop3, $status, $notes, $letter,
        $firstacquidate, $irregularity, $numberpattern, $locale, $callnumber,
        $manualhistory, $internalnotes, $serialsadditems, $staffdisplaycount,
        $opacdisplaycount, $graceperiod, $location, $enddate, $skip_serialseq,
        $itemtype, $previousitemtype
    );

    my $subscriptionid = $dbh->{'mysql_insertid'};
    unless ($enddate) {
        $enddate = GetExpirationDate( $subscriptionid, $startdate );
        $query = qq|
            UPDATE subscription
            SET    enddate=?
            WHERE  subscriptionid=?
        |;
        $sth = $dbh->prepare($query);
        $sth->execute( $enddate, $subscriptionid );
    }

    # then create the 1st expected number
    $query = qq(
        INSERT INTO subscriptionhistory
            (biblionumber, subscriptionid, histstartdate, missinglist, recievedlist)
        VALUES (?,?,?, '', '')
        );
    $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $subscriptionid, $startdate);

    # reread subscription to get a hash (for calculation of the 1st issue number)
    my $subscription = GetSubscription($subscriptionid);
    my $pattern = C4::Serials::Numberpattern::GetSubscriptionNumberpattern($subscription->{numberpattern});

    # calculate issue number
    my $serialseq = GetSeq($subscription, $pattern) || q{};

    Koha::Serial->new(
        {
            serialseq      => $serialseq,
            serialseq_x    => $subscription->{'lastvalue1'},
            serialseq_y    => $subscription->{'lastvalue2'},
            serialseq_z    => $subscription->{'lastvalue3'},
            subscriptionid => $subscriptionid,
            biblionumber   => $biblionumber,
            status         => EXPECTED,
            planneddate    => $firstacquidate,
            publisheddate  => $firstacquidate,
        }
    )->store();

    logaction( "SERIAL", "ADD", $subscriptionid, "" ) if C4::Context->preference("SubscriptionLog");

    #set serial flag on biblio if not already set.
    my $biblio = Koha::Biblios->find( $biblionumber );
    if ( $biblio and !$biblio->serial ) {
        my $record = GetMarcBiblio({ biblionumber => $biblionumber });
        my ( $tag, $subf ) = GetMarcFromKohaField( 'biblio.serial', $biblio->frameworkcode );
        if ($tag) {
            eval { $record->field($tag)->update( $subf => 1 ); };
        }
        ModBiblio( $record, $biblionumber, $biblio->frameworkcode );
    }
    return $subscriptionid;
}

=head2 ReNewSubscription

ReNewSubscription($subscriptionid,$user,$startdate,$numberlength,$weeklength,$monthlength,$note)

this function renew a subscription with values given on input args.

=cut

sub ReNewSubscription {
    my ( $subscriptionid, $user, $startdate, $numberlength, $weeklength, $monthlength, $note ) = @_;
    my $dbh          = C4::Context->dbh;
    my $subscription = GetSubscription($subscriptionid);
    my $query        = qq|
         SELECT *
         FROM   biblio 
         LEFT JOIN biblioitems ON biblio.biblionumber=biblioitems.biblionumber
         WHERE    biblio.biblionumber=?
     |;
    my $sth = $dbh->prepare($query);
    $sth->execute( $subscription->{biblionumber} );
    my $biblio = $sth->fetchrow_hashref;

    if ( C4::Context->preference("RenewSerialAddsSuggestion") ) {
        require C4::Suggestions;
        C4::Suggestions::NewSuggestion(
            {   'suggestedby'   => $user,
                'title'         => $subscription->{bibliotitle},
                'author'        => $biblio->{author},
                'publishercode' => $biblio->{publishercode},
                'note'          => $biblio->{note},
                'biblionumber'  => $subscription->{biblionumber}
            }
        );
    }

    $numberlength ||= 0; # Should not we raise an exception instead?
    $weeklength   ||= 0;

    # renew subscription
    $query = qq|
        UPDATE subscription
        SET    startdate=?,numberlength=?,weeklength=?,monthlength=?,reneweddate=NOW()
        WHERE  subscriptionid=?
    |;
    $sth = $dbh->prepare($query);
    $sth->execute( $startdate, $numberlength, $weeklength, $monthlength, $subscriptionid );
    my $enddate = GetExpirationDate($subscriptionid);
	$debug && warn "enddate :$enddate";
    $query = qq|
        UPDATE subscription
        SET    enddate=?
        WHERE  subscriptionid=?
    |;
    $sth = $dbh->prepare($query);
    $sth->execute( $enddate, $subscriptionid );

    logaction( "SERIAL", "RENEW", $subscriptionid, "" ) if C4::Context->preference("SubscriptionLog");
    return;
}

=head2 NewIssue

NewIssue($serialseq,$subscriptionid,$biblionumber,$status, $planneddate, $publisheddate,  $notes)

Create a new issue stored on the database.
Note : we have to update the recievedlist and missinglist on subscriptionhistory for this subscription.
returns the serial id

=cut

sub NewIssue {
    my ( $serialseq, $subscriptionid, $biblionumber, $status, $planneddate,
        $publisheddate, $publisheddatetext, $notes ) = @_;
    ### FIXME biblionumber CAN be provided by subscriptionid. So Do we STILL NEED IT ?

    return unless ($subscriptionid);

    my $schema = Koha::Database->new()->schema();

    my $subscription = Koha::Subscriptions->find( $subscriptionid );

    my $serial = Koha::Serial->new(
        {
            serialseq         => $serialseq,
            serialseq_x       => $subscription->lastvalue1(),
            serialseq_y       => $subscription->lastvalue2(),
            serialseq_z       => $subscription->lastvalue3(),
            subscriptionid    => $subscriptionid,
            biblionumber      => $biblionumber,
            status            => $status,
            planneddate       => $planneddate,
            publisheddate     => $publisheddate,
            publisheddatetext => $publisheddatetext,
            notes             => $notes,
        }
    )->store();

    my $serialid = $serial->id();

    my $subscription_history = Koha::Subscription::Histories->find($subscriptionid);
    my $missinglist = $subscription_history->missinglist();
    my $recievedlist = $subscription_history->recievedlist();

    if ( $status == ARRIVED ) {
        ### TODO Add a feature that improves recognition and description.
        ### As such count (serialseq) i.e. : N18,2(N19),N20
        ### Would use substr and index But be careful to previous presence of ()
        $recievedlist .= "; $serialseq" unless ( index( $recievedlist, $serialseq ) > 0 );
    }
    if ( grep { /^$status$/ } (MISSING_STATUSES) ) {
        $missinglist .= "; $serialseq" unless ( index( $missinglist, $serialseq ) > 0 );
    }

    $recievedlist =~ s/^; //;
    $missinglist  =~ s/^; //;

    $subscription_history->recievedlist($recievedlist);
    $subscription_history->missinglist($missinglist);
    $subscription_history->store();

    return $serialid;
}

=head2 HasSubscriptionStrictlyExpired

1 or 0 = HasSubscriptionStrictlyExpired($subscriptionid)

the subscription has stricly expired when today > the end subscription date 

return :
1 if true, 0 if false, -1 if the expiration date is not set.

=cut

sub HasSubscriptionStrictlyExpired {

    # Getting end of subscription date
    my ($subscriptionid) = @_;

    return unless ($subscriptionid);

    my $dbh              = C4::Context->dbh;
    my $subscription     = GetSubscription($subscriptionid);
    my $expirationdate = $subscription->{enddate} || GetExpirationDate($subscriptionid);

    # If the expiration date is set
    if ( $expirationdate != 0 ) {
        my ( $endyear, $endmonth, $endday ) = split( '-', $expirationdate );

        # Getting today's date
        my ( $nowyear, $nowmonth, $nowday ) = Today();

        # if today's date > expiration date, then the subscription has stricly expired
        if ( Delta_Days( $nowyear, $nowmonth, $nowday, $endyear, $endmonth, $endday ) < 0 ) {
            return 1;
        } else {
            return 0;
        }
    } else {

        # There are some cases where the expiration date is not set
        # As we can't determine if the subscription has expired on a date-basis,
        # we return -1;
        return -1;
    }
}

=head2 HasSubscriptionExpired

$has_expired = HasSubscriptionExpired($subscriptionid)

the subscription has expired when the next issue to arrive is out of subscription limit.

return :
0 if the subscription has not expired
1 if the subscription has expired
2 if has subscription does not have a valid expiration date set

=cut

sub HasSubscriptionExpired {
    my ($subscriptionid) = @_;

    return unless ($subscriptionid);

    my $dbh              = C4::Context->dbh;
    my $subscription     = GetSubscription($subscriptionid);
    my $frequency = C4::Serials::Frequency::GetSubscriptionFrequency($subscription->{periodicity});
    if ( $frequency and $frequency->{unit} ) {
        my $expirationdate = $subscription->{enddate} || GetExpirationDate($subscriptionid);
        if (!defined $expirationdate) {
            $expirationdate = q{};
        }
        my $query          = qq|
            SELECT max(planneddate)
            FROM   serial
            WHERE  subscriptionid=?
      |;
        my $sth = $dbh->prepare($query);
        $sth->execute($subscriptionid);
        my ($res) = $sth->fetchrow;
        if (!$res || $res=~m/^0000/) {
            return 0;
        }
        my @res                   = split( /-/, $res );
        my @endofsubscriptiondate = split( /-/, $expirationdate );
        return 2 if ( scalar(@res) != 3 || scalar(@endofsubscriptiondate) != 3 || not check_date(@res) || not check_date(@endofsubscriptiondate) );
        return 1
          if ( ( @endofsubscriptiondate && Delta_Days( $res[0], $res[1], $res[2], $endofsubscriptiondate[0], $endofsubscriptiondate[1], $endofsubscriptiondate[2] ) <= 0 )
            || ( !$res ) );
        return 0;
    } else {
        # Irregular
        if ( $subscription->{'numberlength'} ) {
            my $countreceived = countissuesfrom( $subscriptionid, $subscription->{'startdate'} );
            return 1 if ( $countreceived > $subscription->{'numberlength'} );
            return 0;
        } else {
            return 0;
        }
    }
    return 0;    # Notice that you'll never get here.
}

=head2 SetDistributedto

SetDistributedto($distributedto,$subscriptionid);
This function update the value of distributedto for a subscription given on input arg.

=cut

sub SetDistributedto {
    my ( $distributedto, $subscriptionid ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|
        UPDATE subscription
        SET    distributedto=?
        WHERE  subscriptionid=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute( $distributedto, $subscriptionid );
    return;
}

=head2 DelSubscription

DelSubscription($subscriptionid)
this function deletes subscription which has $subscriptionid as id.

=cut

sub DelSubscription {
    my ($subscriptionid) = @_;
    my $dbh = C4::Context->dbh;
    $dbh->do("DELETE FROM subscription WHERE subscriptionid=?", undef, $subscriptionid);
    $dbh->do("DELETE FROM subscriptionhistory WHERE subscriptionid=?", undef, $subscriptionid);
    $dbh->do("DELETE FROM serial WHERE subscriptionid=?", undef, $subscriptionid);

    my $afs = Koha::AdditionalField->all({tablename => 'subscription'});
    foreach my $af (@$afs) {
        $af->delete_values({record_id => $subscriptionid});
    }

    logaction( "SERIAL", "DELETE", $subscriptionid, "" ) if C4::Context->preference("SubscriptionLog");
}

=head2 DelIssue

DelIssue($serialseq,$subscriptionid)
this function deletes an issue which has $serialseq and $subscriptionid given on input arg.

returns the number of rows affected

=cut

sub DelIssue {
    my ($dataissue) = @_;
    my $dbh = C4::Context->dbh;
    ### TODO Add itemdeletion. Would need to get itemnumbers. Should be in a pref ?

    my $query = qq|
        DELETE FROM serial
        WHERE       serialid= ?
        AND         subscriptionid= ?
    |;
    my $mainsth = $dbh->prepare($query);
    $mainsth->execute( $dataissue->{'serialid'}, $dataissue->{'subscriptionid'} );

    #Delete element from subscription history
    $query = "SELECT * FROM   subscription WHERE  subscriptionid = ?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $dataissue->{'subscriptionid'} );
    my $val = $sth->fetchrow_hashref;
    unless ( $val->{manualhistory} ) {
        my $query = qq|
          SELECT * FROM subscriptionhistory
          WHERE       subscriptionid= ?
      |;
        my $sth = $dbh->prepare($query);
        $sth->execute( $dataissue->{'subscriptionid'} );
        my $data      = $sth->fetchrow_hashref;
        my $serialseq = $dataissue->{'serialseq'};
        $data->{'missinglist'}  =~ s/\b$serialseq\b//;
        $data->{'recievedlist'} =~ s/\b$serialseq\b//;
        my $strsth = "UPDATE subscriptionhistory SET " . join( ",", map { join( "=", $_, $dbh->quote( $data->{$_} ) ) } keys %$data ) . " WHERE subscriptionid=?";
        $sth = $dbh->prepare($strsth);
        $sth->execute( $dataissue->{'subscriptionid'} );
    }

    return $mainsth->rows;
}

=head2 GetLateOrMissingIssues

@issuelist = GetLateMissingIssues($supplierid,$serialid)

this function selects missing issues on database - where serial.status = MISSING* or serial.status = LATE or planneddate<now

return :
the issuelist as an array of hash refs. Each element of this array contains 
name,title,planneddate,serialseq,serial.subscriptionid from tables : subscription, serial & biblio

=cut

sub GetLateOrMissingIssues {
    my ( $supplierid, $serialid, $order ) = @_;

    return unless ( $supplierid or $serialid );

    my $dbh = C4::Context->dbh;

    my $sth;
    my $byserial = '';
    if ($serialid) {
        $byserial = "and serialid = " . $serialid;
    }
    if ($order) {
        $order .= ", title";
    } else {
        $order = "title";
    }
    my $missing_statuses_string = join ',', (MISSING_STATUSES);
    if ($supplierid) {
        $sth = $dbh->prepare(
            "SELECT
                serialid,      aqbooksellerid,        name,
                biblio.title,  biblioitems.issn,      planneddate,    serialseq,
                serial.status, serial.subscriptionid, claimdate, claims_count,
                subscription.branchcode
            FROM      serial
                LEFT JOIN subscription  ON serial.subscriptionid=subscription.subscriptionid
                LEFT JOIN biblio        ON subscription.biblionumber=biblio.biblionumber
                LEFT JOIN biblioitems   ON subscription.biblionumber=biblioitems.biblionumber
                LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
                WHERE subscription.subscriptionid = serial.subscriptionid
                AND (serial.STATUS IN ($missing_statuses_string) OR ((planneddate < now() AND serial.STATUS = ?) OR serial.STATUS = ? OR serial.STATUS = ?))
                AND subscription.aqbooksellerid=$supplierid
                $byserial
                ORDER BY $order"
        );
    } else {
        $sth = $dbh->prepare(
            "SELECT
            serialid,      aqbooksellerid,         name,
            biblio.title,  planneddate,           serialseq,
                serial.status, serial.subscriptionid, claimdate, claims_count,
                subscription.branchcode
            FROM serial
                LEFT JOIN subscription ON serial.subscriptionid=subscription.subscriptionid
                LEFT JOIN biblio ON subscription.biblionumber=biblio.biblionumber
                LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
                WHERE subscription.subscriptionid = serial.subscriptionid
                        AND (serial.STATUS IN ($missing_statuses_string) OR ((planneddate < now() AND serial.STATUS = ?) OR serial.STATUS = ? OR serial.STATUS = ?))
                $byserial
                ORDER BY $order"
        );
    }
    $sth->execute( EXPECTED, LATE, CLAIMED );
    my @issuelist;
    while ( my $line = $sth->fetchrow_hashref ) {

        if ($line->{planneddate} && $line->{planneddate} !~/^0+\-/) {
            $line->{planneddateISO} = $line->{planneddate};
            $line->{planneddate} = output_pref( { dt => dt_from_string( $line->{"planneddate"} ), dateonly => 1 } );
        }
        if ($line->{claimdate} && $line->{claimdate} !~/^0+\-/) {
            $line->{claimdateISO} = $line->{claimdate};
            $line->{claimdate}   = output_pref( { dt => dt_from_string( $line->{"claimdate"} ), dateonly => 1 } );
        }
        $line->{"status".$line->{status}}   = 1;

        my $additional_field_values = Koha::AdditionalField->fetch_all_values({
            record_id => $line->{subscriptionid},
            tablename => 'subscription'
        });
        %$line = ( %$line, additional_fields => $additional_field_values->{$line->{subscriptionid}} );

        push @issuelist, $line;
    }
    return @issuelist;
}

=head2 updateClaim

&updateClaim($serialid)

this function updates the time when a claim is issued for late/missing items

called from claims.pl file

=cut

sub updateClaim {
    my ($serialids) = @_;
    return unless $serialids;
    unless ( ref $serialids ) {
        $serialids = [ $serialids ];
    }
    my $dbh = C4::Context->dbh;
    return $dbh->do(q|
        UPDATE serial
        SET claimdate = NOW(),
            claims_count = claims_count + 1,
            status = ?
        WHERE serialid in (| . join( q|,|, (q|?|) x @$serialids ) . q|)|,
        {}, CLAIMED, @$serialids );
}

=head2 check_routing

$result = &check_routing($subscriptionid)

this function checks to see if a serial has a routing list and returns the count of routingid
used to show either an 'add' or 'edit' link

=cut

sub check_routing {
    my ($subscriptionid) = @_;

    return unless ($subscriptionid);

    my $dbh              = C4::Context->dbh;
    my $sth              = $dbh->prepare(
        "SELECT count(routingid) routingids FROM subscription LEFT JOIN subscriptionroutinglist 
                              ON subscription.subscriptionid = subscriptionroutinglist.subscriptionid
                              WHERE subscription.subscriptionid = ? ORDER BY ranking ASC
                              "
    );
    $sth->execute($subscriptionid);
    my $line   = $sth->fetchrow_hashref;
    my $result = $line->{'routingids'};
    return $result;
}

=head2 addroutingmember

addroutingmember($borrowernumber,$subscriptionid)

this function takes a borrowernumber and subscriptionid and adds the member to the
routing list for that serial subscription and gives them a rank on the list
of either 1 or highest current rank + 1

=cut

sub addroutingmember {
    my ( $borrowernumber, $subscriptionid ) = @_;

    return unless ($borrowernumber and $subscriptionid);

    my $rank;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( "SELECT max(ranking) rank FROM subscriptionroutinglist WHERE subscriptionid = ?" );
    $sth->execute($subscriptionid);
    while ( my $line = $sth->fetchrow_hashref ) {
        if ( $line->{'rank'} > 0 ) {
            $rank = $line->{'rank'} + 1;
        } else {
            $rank = 1;
        }
    }
    $sth = $dbh->prepare( "INSERT INTO subscriptionroutinglist (subscriptionid,borrowernumber,ranking) VALUES (?,?,?)" );
    $sth->execute( $subscriptionid, $borrowernumber, $rank );
}

=head2 reorder_members

reorder_members($subscriptionid,$routingid,$rank)

this function is used to reorder the routing list

it takes the routingid of the member one wants to re-rank and the rank it is to move to
- it gets all members on list puts their routingid's into an array
- removes the one in the array that is $routingid
- then reinjects $routingid at point indicated by $rank
- then update the database with the routingids in the new order

=cut

sub reorder_members {
    my ( $subscriptionid, $routingid, $rank ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( "SELECT * FROM subscriptionroutinglist WHERE subscriptionid = ? ORDER BY ranking ASC" );
    $sth->execute($subscriptionid);
    my @result;
    while ( my $line = $sth->fetchrow_hashref ) {
        push( @result, $line->{'routingid'} );
    }

    # To find the matching index
    my $i;
    my $key = -1;    # to allow for 0 being a valid response
    for ( $i = 0 ; $i < @result ; $i++ ) {
        if ( $routingid == $result[$i] ) {
            $key = $i;    # save the index
            last;
        }
    }

    # if index exists in array then move it to new position
    if ( $key > -1 && $rank > 0 ) {
        my $new_rank = $rank - 1;                       # $new_rank is what you want the new index to be in the array
        my $moving_item = splice( @result, $key, 1 );
        splice( @result, $new_rank, 0, $moving_item );
    }
    for ( my $j = 0 ; $j < @result ; $j++ ) {
        my $sth = $dbh->prepare( "UPDATE subscriptionroutinglist SET ranking = '" . ( $j + 1 ) . "' WHERE routingid = '" . $result[$j] . "'" );
        $sth->execute;
    }
    return;
}

=head2 delroutingmember

delroutingmember($routingid,$subscriptionid)

this function either deletes one member from routing list if $routingid exists otherwise
deletes all members from the routing list

=cut

sub delroutingmember {

    # if $routingid exists then deletes that row otherwise deletes all with $subscriptionid
    my ( $routingid, $subscriptionid ) = @_;
    my $dbh = C4::Context->dbh;
    if ($routingid) {
        my $sth = $dbh->prepare("DELETE FROM subscriptionroutinglist WHERE routingid = ?");
        $sth->execute($routingid);
        reorder_members( $subscriptionid, $routingid );
    } else {
        my $sth = $dbh->prepare("DELETE FROM subscriptionroutinglist WHERE subscriptionid = ?");
        $sth->execute($subscriptionid);
    }
    return;
}

=head2 getroutinglist

@routinglist = getroutinglist($subscriptionid)

this gets the info from the subscriptionroutinglist for $subscriptionid

return :
the routinglist as an array. Each element of the array contains a hash_ref containing
routingid - a unique id, borrowernumber, ranking, and biblionumber of subscription

=cut

sub getroutinglist {
    my ($subscriptionid) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              = $dbh->prepare(
        'SELECT routingid, borrowernumber, ranking, biblionumber
            FROM subscription 
            JOIN subscriptionroutinglist ON subscription.subscriptionid = subscriptionroutinglist.subscriptionid
            WHERE subscription.subscriptionid = ? ORDER BY ranking ASC'
    );
    $sth->execute($subscriptionid);
    my $routinglist = $sth->fetchall_arrayref({});
    return @{$routinglist};
}

=head2 countissuesfrom

$result = countissuesfrom($subscriptionid,$startdate)

Returns a count of serial rows matching the given subsctiptionid
with published date greater than startdate

=cut

sub countissuesfrom {
    my ( $subscriptionid, $startdate ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|
            SELECT count(*)
            FROM   serial
            WHERE  subscriptionid=?
            AND serial.publisheddate>?
        |;
    my $sth = $dbh->prepare($query);
    $sth->execute( $subscriptionid, $startdate );
    my ($countreceived) = $sth->fetchrow;
    return $countreceived;
}

=head2 CountIssues

$result = CountIssues($subscriptionid)

Returns a count of serial rows matching the given subsctiptionid

=cut

sub CountIssues {
    my ($subscriptionid) = @_;
    my $dbh              = C4::Context->dbh;
    my $query            = qq|
            SELECT count(*)
            FROM   serial
            WHERE  subscriptionid=?
        |;
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my ($countreceived) = $sth->fetchrow;
    return $countreceived;
}

=head2 HasItems

$result = HasItems($subscriptionid)

returns a count of items from serial matching the subscriptionid

=cut

sub HasItems {
    my ($subscriptionid) = @_;
    my $dbh              = C4::Context->dbh;
    my $query = q|
            SELECT COUNT(serialitems.itemnumber)
            FROM   serial 
			LEFT JOIN serialitems USING(serialid)
            WHERE  subscriptionid=? AND serialitems.serialid IS NOT NULL
        |;
    my $sth=$dbh->prepare($query);
    $sth->execute($subscriptionid);
    my ($countitems)=$sth->fetchrow_array();
    return $countitems;  
}

=head2 abouttoexpire

$result = abouttoexpire($subscriptionid)

this function alerts you to the penultimate issue for a serial subscription

returns 1 - if this is the penultimate issue
returns 0 - if not

=cut

sub abouttoexpire {
    my ($subscriptionid) = @_;
    my $dbh              = C4::Context->dbh;
    my $subscription     = GetSubscription($subscriptionid);
    my $per = $subscription->{'periodicity'};
    my $frequency = C4::Serials::Frequency::GetSubscriptionFrequency($per);
    if ($frequency and $frequency->{unit}){

        my $expirationdate = GetExpirationDate($subscriptionid);

        my ($res) = $dbh->selectrow_array('select max(planneddate) from serial where subscriptionid = ?', undef, $subscriptionid);
        my $nextdate = GetNextDate($subscription, $res);

        # only compare dates if both dates exist.
        if ($nextdate and $expirationdate) {
            if(Date::Calc::Delta_Days(
                split( /-/, $nextdate ),
                split( /-/, $expirationdate )
            ) <= 0) {
                return 1;
            }
        }

    } elsif ($subscription->{numberlength}>0) {
        return (countissuesfrom($subscriptionid,$subscription->{'startdate'}) >=$subscription->{numberlength}-1);
    }

    return 0;
}

sub in_array {    # used in next sub down
    my ( $val, @elements ) = @_;
    foreach my $elem (@elements) {
        if ( $val == $elem ) {
            return 1;
        }
    }
    return 0;
}

=head2 GetFictiveIssueNumber

$issueno = GetFictiveIssueNumber($subscription, $publishedate);

Get the position of the issue published at $publisheddate, considering the
first issue (at firstacquidate) is at position 1, the next is at position 2, etc...
This issuenumber doesn't take into account irregularities, so, for instance, if the 3rd
issue is declared as 'irregular' (will be skipped at receipt), the next issue number
will be 4, not 3. It's why it is called 'fictive'. It is NOT a serial seq, and is not
depending on how many rows are in serial table.
The issue number calculation is based on subscription frequency, first acquisition
date, and $publisheddate.

Returns undef when called for irregular frequencies.

The routine is used to skip irregularities when calculating the next issue
date (in GetNextDate) or the next issue number (in GetNextSeq).

=cut

sub GetFictiveIssueNumber {
    my ($subscription, $publisheddate) = @_;

    my $frequency = GetSubscriptionFrequency($subscription->{'periodicity'});
    my $unit = $frequency->{unit} ? lc $frequency->{'unit'} : undef;
    return if !$unit;
    my $issueno;

    my ( $year, $month, $day ) = split /-/, $publisheddate;
    my ( $fa_year, $fa_month, $fa_day ) = split /-/, $subscription->{'firstacquidate'};
    my $delta = _delta_units( [$fa_year, $fa_month, $fa_day], [$year, $month, $day], $unit );

    if( $frequency->{'unitsperissue'} == 1 ) {
        $issueno = $delta * $frequency->{'issuesperunit'} + $subscription->{'countissuesperunit'};
    } else { # issuesperunit == 1
        $issueno = 1 + int( $delta / $frequency->{'unitsperissue'} );
    }
    return $issueno;
}

sub _delta_units {
    my ( $date1, $date2, $unit ) = @_;
    # date1 and date2 are array refs in the form [ yy, mm, dd ]

    if( $unit eq 'day' ) {
        return Delta_Days( @$date1, @$date2 );
    } elsif( $unit eq 'week' ) {
        return int( Delta_Days( @$date1, @$date2 ) / 7 );
    }

    # In case of months or years, this is a wrapper around N_Delta_YMD.
    # Note that N_Delta_YMD returns 29 days between e.g. 22-2-72 and 22-3-72
    # while we expect 1 month.
    my @delta = N_Delta_YMD( @$date1, @$date2 );
    if( $delta[2] > 27 ) {
        # Check if we could add a month
        my @jump = Add_Delta_YM( @$date1, $delta[0], 1 + $delta[1] );
        if( Delta_Days( @jump, @$date2 ) >= 0 ) {
            $delta[1]++;
        }
    }
    if( $delta[1] >= 12 ) {
        $delta[0]++;
        $delta[1] -= 12;
    }
    # if unit is year, we only return full years
    return $unit eq 'month' ? $delta[0] * 12 + $delta[1] : $delta[0];
}

sub _get_next_date_day {
    my ($subscription, $freqdata, $year, $month, $day) = @_;

    my @newissue; # ( yy, mm, dd )
    # We do not need $delta_days here, since it would be zero where used

    if( $freqdata->{issuesperunit} == 1 ) {
        # Add full days
        @newissue = Add_Delta_Days(
            $year, $month, $day, $freqdata->{"unitsperissue"} );
    } elsif ( $subscription->{countissuesperunit} < $freqdata->{issuesperunit} ) {
        # Add zero days
        @newissue = ( $year, $month, $day );
        $subscription->{countissuesperunit}++;
    } else {
        # We finished a cycle of issues within a unit.
        # No subtraction of zero needed, just add one day
        @newissue = Add_Delta_Days( $year, $month, $day, 1 );
        $subscription->{countissuesperunit} = 1;
    }
    return @newissue;
}

sub _get_next_date_week {
    my ($subscription, $freqdata, $year, $month, $day) = @_;

    my @newissue; # ( yy, mm, dd )
    my $delta_days = int( 7 / $freqdata->{issuesperunit} );

    if( $freqdata->{issuesperunit} == 1 ) {
        # Add full weeks (of 7 days)
        @newissue = Add_Delta_Days(
            $year, $month, $day, 7 * $freqdata->{"unitsperissue"} );
    } elsif ( $subscription->{countissuesperunit} < $freqdata->{issuesperunit} ) {
        # Add rounded number of days based on frequency.
        @newissue = Add_Delta_Days( $year, $month, $day, $delta_days );
        $subscription->{countissuesperunit}++;
    } else {
        # We finished a cycle of issues within a unit.
        # Subtract delta * (issues - 1), add 1 week
        @newissue = Add_Delta_Days( $year, $month, $day,
            -$delta_days * ($freqdata->{issuesperunit} - 1) );
        @newissue = Add_Delta_Days( @newissue, 7 );
        $subscription->{countissuesperunit} = 1;
    }
    return @newissue;
}

sub _get_next_date_month {
    my ($subscription, $freqdata, $year, $month, $day) = @_;

    my @newissue; # ( yy, mm, dd )
    my $delta_days = int( 30 / $freqdata->{issuesperunit} );

    if( $freqdata->{issuesperunit} == 1 ) {
        # Add full months
        @newissue = Add_Delta_YM(
            $year, $month, $day, 0, $freqdata->{"unitsperissue"} );
    } elsif ( $subscription->{countissuesperunit} < $freqdata->{issuesperunit} ) {
        # Add rounded number of days based on frequency.
        @newissue = Add_Delta_Days( $year, $month, $day, $delta_days );
        $subscription->{countissuesperunit}++;
    } else {
        # We finished a cycle of issues within a unit.
        # Subtract delta * (issues - 1), add 1 month
        @newissue = Add_Delta_Days( $year, $month, $day,
            -$delta_days * ($freqdata->{issuesperunit} - 1) );
        @newissue = Add_Delta_YM( @newissue, 0, 1 );
        $subscription->{countissuesperunit} = 1;
    }
    return @newissue;
}

sub _get_next_date_year {
    my ($subscription, $freqdata, $year, $month, $day) = @_;

    my @newissue; # ( yy, mm, dd )
    my $delta_days = int( 365 / $freqdata->{issuesperunit} );

    if( $freqdata->{issuesperunit} == 1 ) {
        # Add full years
        @newissue = Add_Delta_YM( $year, $month, $day, $freqdata->{"unitsperissue"}, 0 );
    } elsif ( $subscription->{countissuesperunit} < $freqdata->{issuesperunit} ) {
        # Add rounded number of days based on frequency.
        @newissue = Add_Delta_Days( $year, $month, $day, $delta_days );
        $subscription->{countissuesperunit}++;
    } else {
        # We finished a cycle of issues within a unit.
        # Subtract delta * (issues - 1), add 1 year
        @newissue = Add_Delta_Days( $year, $month, $day, -$delta_days * ($freqdata->{issuesperunit} - 1) );
        @newissue = Add_Delta_YM( @newissue, 1, 0 );
        $subscription->{countissuesperunit} = 1;
    }
    return @newissue;
}

=head2 GetNextDate

$resultdate = GetNextDate($publisheddate,$subscription)

this function it takes the publisheddate and will return the next issue's date
and will skip dates if there exists an irregularity.
$publisheddate has to be an ISO date
$subscription is a hashref containing at least 'periodicity', 'firstacquidate', 'irregularity', and 'countissuesperunit'
$updatecount is a boolean value which, when set to true, update the 'countissuesperunit' in database
- eg if periodicity is monthly and $publisheddate is 2007-02-10 but if March and April is to be
skipped then the returned date will be 2007-05-10

return :
$resultdate - then next date in the sequence (ISO date)

Return undef if subscription is irregular

=cut

sub GetNextDate {
    my ( $subscription, $publisheddate, $updatecount ) = @_;

    return unless $subscription and $publisheddate;

    my $freqdata = GetSubscriptionFrequency($subscription->{'periodicity'});

    if ($freqdata->{'unit'}) {
        my ( $year, $month, $day ) = split /-/, $publisheddate;

        # Process an irregularity Hash
        # Suppose that irregularities are stored in a string with this structure
        # irreg1;irreg2;irreg3
        # where irregX is the number of issue which will not be received
        # (the first issue takes the number 1, the 2nd the number 2 and so on)
        my %irregularities;
        if ( $subscription->{irregularity} ) {
            my @irreg = split /;/, $subscription->{'irregularity'} ;
            foreach my $irregularity (@irreg) {
                $irregularities{$irregularity} = 1;
            }
        }

        # Get the 'fictive' next issue number
        # It is used to check if next issue is an irregular issue.
        my $issueno = GetFictiveIssueNumber($subscription, $publisheddate) + 1;

        # Then get the next date
        my $unit = lc $freqdata->{'unit'};
        if ($unit eq 'day') {
            while ($irregularities{$issueno}) {
                ($year, $month, $day) = _get_next_date_day($subscription,
                    $freqdata, $year, $month, $day);
                $issueno++;
            }
            ($year, $month, $day) = _get_next_date_day($subscription, $freqdata,
                $year, $month, $day);
        }
        elsif ($unit eq 'week') {
            while ($irregularities{$issueno}) {
                ($year, $month, $day) = _get_next_date_week($subscription,
                    $freqdata, $year, $month, $day);
                $issueno++;
            }
            ($year, $month, $day) = _get_next_date_week($subscription,
                $freqdata, $year, $month, $day);
        }
        elsif ($unit eq 'month') {
            while ($irregularities{$issueno}) {
                ($year, $month, $day) = _get_next_date_month($subscription,
                    $freqdata, $year, $month, $day);
                $issueno++;
            }
            ($year, $month, $day) = _get_next_date_month($subscription,
                $freqdata, $year, $month, $day);
        }
        elsif ($unit eq 'year') {
            while ($irregularities{$issueno}) {
                ($year, $month, $day) = _get_next_date_year($subscription,
                    $freqdata, $year, $month, $day);
                $issueno++;
            }
            ($year, $month, $day) = _get_next_date_year($subscription,
                $freqdata, $year, $month, $day);
        }

        if ($updatecount){
            my $dbh = C4::Context->dbh;
            my $query = qq{
                UPDATE subscription
                SET countissuesperunit = ?
                WHERE subscriptionid = ?
            };
            my $sth = $dbh->prepare($query);
            $sth->execute($subscription->{'countissuesperunit'}, $subscription->{'subscriptionid'});
        }

        return sprintf("%04d-%02d-%02d", $year, $month, $day);
    }
}

=head2 _numeration

  $string = &_numeration($value,$num_type,$locale);

_numeration returns the string corresponding to $value in the num_type
num_type can take :
    -dayname
    -dayabrv
    -monthname
    -monthabrv
    -season
    -seasonabrv

=cut

sub _numeration {
    my ($value, $num_type, $locale) = @_;
    $value ||= 0;
    $num_type //= '';
    $locale ||= 'en';
    my $string;
    if ( $num_type =~ /^dayname$/ or $num_type =~ /^dayabrv$/ ) {
        # 1970-11-01 was a Sunday
        $value = $value % 7;
        my $dt = DateTime->new(
            year    => 1970,
            month   => 11,
            day     => $value + 1,
            locale  => $locale,
        );
        $string = $num_type =~ /^dayname$/
            ? $dt->strftime("%A")
            : $dt->strftime("%a");
    } elsif ( $num_type =~ /^monthname$/ or $num_type =~ /^monthabrv$/ ) {
        $value = $value % 12;
        my $dt = DateTime->new(
            year    => 1970,
            month   => $value + 1,
            locale  => $locale,
        );
        $string = $num_type =~ /^monthname$/
            ? $dt->strftime("%B")
            : $dt->strftime("%b");
    } elsif ( $num_type =~ /^season$/ ) {
        my @seasons= qw( Spring Summer Fall Winter );
        $value = $value % 4;
        $string = $seasons[$value];
    } elsif ( $num_type =~ /^seasonabrv$/ ) {
        my @seasonsabrv= qw( Spr Sum Fal Win );
        $value = $value % 4;
        $string = $seasonsabrv[$value];
    } else {
        $string = $value;
    }

    return $string;
}

=head2 is_barcode_in_use

Returns number of occurrences of the barcode in the items table
Can be used as a boolean test of whether the barcode has
been deployed as yet

=cut

sub is_barcode_in_use {
    my $barcode = shift;
    my $dbh       = C4::Context->dbh;
    my $occurrences = $dbh->selectall_arrayref(
        'SELECT itemnumber from items where barcode = ?',
        {}, $barcode

    );

    return @{$occurrences};
}

=head2 CloseSubscription

Close a subscription given a subscriptionid

=cut

sub CloseSubscription {
    my ( $subscriptionid ) = @_;
    return unless $subscriptionid;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( q{
        UPDATE subscription
        SET closed = 1
        WHERE subscriptionid = ?
    } );
    $sth->execute( $subscriptionid );

    # Set status = missing when status = stopped
    $sth = $dbh->prepare( q{
        UPDATE serial
        SET status = ?
        WHERE subscriptionid = ?
        AND status = ?
    } );
    $sth->execute( STOPPED, $subscriptionid, EXPECTED );
}

=head2 ReopenSubscription

Reopen a subscription given a subscriptionid

=cut

sub ReopenSubscription {
    my ( $subscriptionid ) = @_;
    return unless $subscriptionid;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( q{
        UPDATE subscription
        SET closed = 0
        WHERE subscriptionid = ?
    } );
    $sth->execute( $subscriptionid );

    # Set status = expected when status = stopped
    $sth = $dbh->prepare( q{
        UPDATE serial
        SET status = ?
        WHERE subscriptionid = ?
        AND status = ?
    } );
    $sth->execute( EXPECTED, $subscriptionid, STOPPED );
}

=head2 subscriptionCurrentlyOnOrder

    $bool = subscriptionCurrentlyOnOrder( $subscriptionid );

Return 1 if subscription is currently on order else 0.

=cut

sub subscriptionCurrentlyOnOrder {
    my ( $subscriptionid ) = @_;
    my $dbh = C4::Context->dbh;
    my $query = qq|
        SELECT COUNT(*) FROM aqorders
        WHERE subscriptionid = ?
            AND datereceived IS NULL
            AND datecancellationprinted IS NULL
    |;
    my $sth = $dbh->prepare( $query );
    $sth->execute($subscriptionid);
    return $sth->fetchrow_array;
}

=head2 can_claim_subscription

    $can = can_claim_subscription( $subscriptionid[, $userid] );

Return 1 if the subscription can be claimed by the current logged user (or a given $userid), else 0.

=cut

sub can_claim_subscription {
    my ( $subscription, $userid ) = @_;
    return _can_do_on_subscription( $subscription, $userid, 'claim_serials' );
}

=head2 can_edit_subscription

    $can = can_edit_subscription( $subscriptionid[, $userid] );

Return 1 if the subscription can be edited by the current logged user (or a given $userid), else 0.

=cut

sub can_edit_subscription {
    my ( $subscription, $userid ) = @_;
    return _can_do_on_subscription( $subscription, $userid, 'edit_subscription' );
}

=head2 can_show_subscription

    $can = can_show_subscription( $subscriptionid[, $userid] );

Return 1 if the subscription can be shown by the current logged user (or a given $userid), else 0.

=cut

sub can_show_subscription {
    my ( $subscription, $userid ) = @_;
    return _can_do_on_subscription( $subscription, $userid, '*' );
}

sub _can_do_on_subscription {
    my ( $subscription, $userid, $permission ) = @_;
    return 0 unless C4::Context->userenv;
    my $flags = C4::Context->userenv->{flags};
    $userid ||= C4::Context->userenv->{'id'};

    if ( C4::Context->preference('IndependentBranches') ) {
        return 1
          if C4::Context->IsSuperLibrarian()
              or
              C4::Auth::haspermission( $userid, { serials => 'superserials' } )
              or (
                  C4::Auth::haspermission( $userid,
                      { serials => $permission } )
                  and (  not defined $subscription->{branchcode}
                      or $subscription->{branchcode} eq ''
                      or $subscription->{branchcode} eq
                      C4::Context->userenv->{'branch'} )
              );
    }
    else {
        return 1
          if C4::Context->IsSuperLibrarian()
              or
              C4::Auth::haspermission( $userid, { serials => 'superserials' } )
              or C4::Auth::haspermission(
                  $userid, { serials => $permission }
              ),
        ;
    }
    return 0;
}

=head2 findSerialsByStatus

    @serials = findSerialsByStatus($status, $subscriptionid);

    Returns an array of serials matching a given status and subscription id.

=cut

sub findSerialsByStatus {
    my ( $status, $subscriptionid ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = q| SELECT * from serial
                    WHERE status = ?
                    AND subscriptionid = ?
                |;
    my $serials = $dbh->selectall_arrayref( $query, { Slice => {} }, $status, $subscriptionid );
    return @$serials;
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
