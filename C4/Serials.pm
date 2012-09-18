package C4::Serials;

# Copyright 2000-2002 Katipo Communications
# Parts Copyright 2010 Biblibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;
use C4::Dates qw(format_date format_date_in_iso);
use Date::Calc qw(:all);
use POSIX qw(strftime);
use C4::Biblio;
use C4::Log;    # logaction
use C4::Debug;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

BEGIN {
    $VERSION = 3.07.00.049;    # set version for version checking
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
      &NewSubscription    &ModSubscription    &DelSubscription    &GetSubscriptions
      &GetSubscription    &CountSubscriptionFromBiblionumber      &GetSubscriptionsFromBiblionumber
      &SearchSubscriptions
      &GetFullSubscriptionsFromBiblionumber   &GetFullSubscription &ModSubscriptionHistory
      &HasSubscriptionStrictlyExpired &HasSubscriptionExpired &GetExpirationDate &abouttoexpire

      &GetNextSeq         &NewIssue           &ItemizeSerials    &GetSerials
      &GetLatestSerials   &ModSerialStatus    &GetNextDate       &GetSerials2
      &ReNewSubscription  &GetLateIssues      &GetLateOrMissingIssues
      &GetSerialInformation                   &AddItem2Serial
      &PrepareSerialsData &GetNextExpected    &ModNextExpected

      &UpdateClaimdateIssues
      &GetSuppliersWithLateIssues             &getsupplierbyserialid
      &GetDistributedTo   &SetDistributedTo
      &getroutinglist     &delroutingmember   &addroutingmember
      &reorder_members
      &check_routing &updateClaim &removeMissingIssue
      &CountIssues
      HasItems
      &GetSubscriptionsFromBorrower

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
    my $query = qq|
        SELECT DISTINCT id, name
    FROM            subscription
    LEFT JOIN       serial ON serial.subscriptionid=subscription.subscriptionid
    LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
    WHERE id > 0
        AND (
            (planneddate < now() AND serial.status=1)
            OR serial.STATUS = 3 OR serial.STATUS = 4
        )
        AND subscription.closed = 0
    ORDER BY name|;
    return $dbh->selectall_arrayref($query, { Slice => {} });
}

=head2 GetLateIssues

@issuelist = GetLateIssues($supplierid)

this function selects late issues from the database

return :
the issuelist as an array. Each element of this array contains a hashi_ref containing
name,title,planneddate,serialseq,serial.subscriptionid from tables : subscription, serial & biblio

=cut

sub GetLateIssues {
    my ($supplierid) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($supplierid) {
        my $query = qq|
            SELECT     name,title,planneddate,serialseq,serial.subscriptionid
            FROM       subscription
            LEFT JOIN  serial ON subscription.subscriptionid = serial.subscriptionid
            LEFT JOIN  biblio ON biblio.biblionumber = subscription.biblionumber
            LEFT JOIN  aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
            WHERE      ((planneddate < now() AND serial.STATUS =1) OR serial.STATUS = 3)
            AND        subscription.aqbooksellerid=?
            AND        subscription.closed = 0
            ORDER BY   title
        |;
        $sth = $dbh->prepare($query);
        $sth->execute($supplierid);
    } else {
        my $query = qq|
            SELECT     name,title,planneddate,serialseq,serial.subscriptionid
            FROM       subscription
            LEFT JOIN  serial ON subscription.subscriptionid = serial.subscriptionid
            LEFT JOIN  biblio ON biblio.biblionumber = subscription.biblionumber
            LEFT JOIN  aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
            WHERE      ((planneddate < now() AND serial.STATUS =1) OR serial.STATUS = 3)
            AND        subscription.closed = 0
            ORDER BY   title
        |;
        $sth = $dbh->prepare($query);
        $sth->execute;
    }
    my @issuelist;
    my $last_title;
    my $odd   = 0;
    while ( my $line = $sth->fetchrow_hashref ) {
        $odd++ unless $line->{title} eq $last_title;
        $line->{title} = "" if $line->{title} eq $last_title;
        $last_title = $line->{title} if ( $line->{title} );
        $line->{planneddate} = format_date( $line->{planneddate} );
        push @issuelist, $line;
    }
    return @issuelist;
}

=head2 GetSubscriptionHistoryFromSubscriptionId

$sth = GetSubscriptionHistoryFromSubscriptionId()
this function prepares the SQL request and returns the statement handle
After this function, don't forget to execute it by using $sth->execute($subscriptionid)

=cut

sub GetSubscriptionHistoryFromSubscriptionId {
    my $dbh   = C4::Context->dbh;
    my $query = qq|
        SELECT *
        FROM   subscriptionhistory
        WHERE  subscriptionid = ?
    |;
    return $dbh->prepare($query);
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
        SELECT serial.*, serial.notes as sernotes, serial.status as serstatus,subscription.*,subscription.subscriptionid as subsid |;
    if (   C4::Context->preference('IndependantBranches')
        && C4::Context->userenv
        && C4::Context->userenv->{'flags'} != 1
        && C4::Context->userenv->{'branch'} ) {
        $query .= "
      , ((subscription.branchcode <>\"" . C4::Context->userenv->{'branch'} . "\") and subscription.branchcode <>\"\" and subscription.branchcode IS NOT NULL) as cannotedit ";
    }
    $query .= qq|             
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
    return $data;
}

=head2 AddItem2Serial

$rows = AddItem2Serial($serialid,$itemnumber);
Adds an itemnumber to Serial record
returns the number of rows affected

=cut

sub AddItem2Serial {
    my ( $serialid, $itemnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $rq  = $dbh->prepare("INSERT INTO `serialitems` SET serialid=? , itemnumber=?");
    $rq->execute( $serialid, $itemnumber );
    return $rq->rows;
}

=head2 UpdateClaimdateIssues

UpdateClaimdateIssues($serialids,[$date]);

Update Claimdate for issues in @$serialids list with date $date
(Take Today if none)

=cut

sub UpdateClaimdateIssues {
    my ( $serialids, $date ) = @_;
    my $dbh = C4::Context->dbh;
    $date = strftime( "%Y-%m-%d", localtime ) unless ($date);
    my $query = "
        UPDATE serial SET claimdate = ?, status = 7
        WHERE  serialid in (" . join( ",", map { '?' } @$serialids ) . ")";
    my $rq = $dbh->prepare($query);
    $rq->execute($date, @$serialids);
    return $rq->rows;
}

=head2 GetSubscription

$subs = GetSubscription($subscriptionid)
this function returns the subscription which has $subscriptionid as id.
return :
a hashref. This hash containts
subscription, subscriptionhistory, aqbudget.bookfundid, biblio.title

=cut

sub GetSubscription {
    my ($subscriptionid) = @_;
    my $dbh              = C4::Context->dbh;
    my $query            = qq(
        SELECT  subscription.*,
                subscriptionhistory.*,
                aqbooksellers.name AS aqbooksellername,
                biblio.title AS bibliotitle,
                subscription.biblionumber as bibnum);
    if (   C4::Context->preference('IndependantBranches')
        && C4::Context->userenv
        && C4::Context->userenv->{'flags'} != 1
        && C4::Context->userenv->{'branch'} ) {
        $query .= "
      , ((subscription.branchcode <>\"" . C4::Context->userenv->{'branch'} . "\") and subscription.branchcode <>\"\" and subscription.branchcode IS NOT NULL) as cannotedit ";
    }
    $query .= qq(             
       FROM subscription
       LEFT JOIN subscriptionhistory ON subscription.subscriptionid=subscriptionhistory.subscriptionid
       LEFT JOIN aqbooksellers ON subscription.aqbooksellerid=aqbooksellers.id
       LEFT JOIN biblio ON biblio.biblionumber=subscription.biblionumber
       WHERE subscription.subscriptionid = ?
    );

    #     if (C4::Context->preference('IndependantBranches') &&
    #         C4::Context->userenv &&
    #         C4::Context->userenv->{'flags'} != 1){
    # #       $debug and warn "flags: ".C4::Context->userenv->{'flags'};
    #       $query.=" AND subscription.branchcode IN ('".C4::Context->userenv->{'branch'}."',\"\")";
    #     }
    $debug and warn "query : $query\nsubsid :$subscriptionid";
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    return $sth->fetchrow_hashref;
}

=head2 GetFullSubscription

   $array_ref = GetFullSubscription($subscriptionid)
   this function reads the serial table.

=cut

sub GetFullSubscription {
    my ($subscriptionid) = @_;
    my $dbh              = C4::Context->dbh;
    my $query            = qq|
  SELECT    serial.serialid,
            serial.serialseq,
            serial.planneddate, 
            serial.publisheddate, 
            serial.status, 
            serial.notes as notes,
            year(IF(serial.publisheddate="00-00-0000",serial.planneddate,serial.publisheddate)) as year,
            aqbooksellers.name as aqbooksellername,
            biblio.title as bibliotitle,
            subscription.branchcode AS branchcode,
            subscription.subscriptionid AS subscriptionid |;
    if (   C4::Context->preference('IndependantBranches')
        && C4::Context->userenv
        && C4::Context->userenv->{'flags'} != 1
        && C4::Context->userenv->{'branch'} ) {
        $query .= "
      , ((subscription.branchcode <>\"" . C4::Context->userenv->{'branch'} . "\") and subscription.branchcode <>\"\" and subscription.branchcode IS NOT NULL) as cannotedit ";
    }
    $query .= qq|
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
    return $sth->fetchall_arrayref( {} );
}

=head2 PrepareSerialsData

   $array_ref = PrepareSerialsData($serialinfomation)
   where serialinformation is a hashref array

=cut

sub PrepareSerialsData {
    my ($lines) = @_;
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
            # handle both undef and undef returned as 0000-00-00
            if (!defined $subs->{$datefield} or $subs->{$datefield}=~m/^00/) {
                $subs->{$datefield} = 'XXX';
            }
            else {
                $subs->{$datefield} = format_date( $subs->{$datefield}  );
            }
        }
        $subs->{ "status" . $subs->{'status'} } = 1;
        $subs->{"checked"}                      = $subs->{'status'} =~ /1|3|4|7/;

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
        $subs->{startdate}     = format_date( $subs->{startdate} );
        $subs->{histstartdate} = format_date( $subs->{histstartdate} );
        $subs->{histenddate}   = format_date( $subs->{histenddate} );
        $subs->{opacnote}     =~ s/\n/\<br\/\>/g;
        $subs->{missinglist}  =~ s/\n/\<br\/\>/g;
        $subs->{recievedlist} =~ s/\n/\<br\/\>/g;
        $subs->{ "periodicity" . $subs->{periodicity} }     = 1;
        $subs->{ "numberpattern" . $subs->{numberpattern} } = 1;
        $subs->{ "status" . $subs->{'status'} }             = 1;
        $subs->{'cannotedit'} =
          (      C4::Context->preference('IndependantBranches')
              && C4::Context->userenv
              && C4::Context->userenv->{flags} % 2 != 1
              && C4::Context->userenv->{branch}
              && $subs->{branchcode}
              && ( C4::Context->userenv->{branch} ne $subs->{branchcode} ) );

        if ( $subs->{enddate} eq '0000-00-00' ) {
            $subs->{enddate} = '';
        } else {
            $subs->{enddate} = format_date( $subs->{enddate} );
        }
        $subs->{'abouttoexpire'}       = abouttoexpire( $subs->{'subscriptionid'} );
        $subs->{'subscriptionexpired'} = HasSubscriptionExpired( $subs->{'subscriptionid'} );
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
            serial.status, 
            serial.notes as notes,
            year(IF(serial.publisheddate="00-00-0000",serial.planneddate,serial.publisheddate)) as year,
            biblio.title as bibliotitle,
            subscription.branchcode AS branchcode,
            subscription.subscriptionid AS subscriptionid|;
    if (   C4::Context->preference('IndependantBranches')
        && C4::Context->userenv
        && C4::Context->userenv->{'flags'} != 1
        && C4::Context->userenv->{'branch'} ) {
        $query .= "
      , ((subscription.branchcode <>\"" . C4::Context->userenv->{'branch'} . "\") and subscription.branchcode <>\"\" and subscription.branchcode IS NOT NULL) as cannotedit ";
    }

    $query .= qq|      
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
    return $sth->fetchall_arrayref( {} );
}

=head2 GetSubscriptions

@results = GetSubscriptions($title,$ISSN,$ean,$biblionumber);
this function gets all subscriptions which have title like $title,ISSN like $ISSN,EAN like $ean and biblionumber like $biblionumber.
return:
a table of hashref. Each hash containt the subscription.

=cut

sub GetSubscriptions {
    my ( $string, $issn, $ean, $biblionumber ) = @_;

    #return unless $title or $ISSN or $biblionumber;
    my $dbh = C4::Context->dbh;
    my $sth;
    my $sql = qq(
            SELECT subscription.*, subscriptionhistory.*, biblio.title,biblioitems.issn,biblio.biblionumber
            FROM   subscription
            LEFT JOIN subscriptionhistory USING(subscriptionid)
            LEFT JOIN biblio ON biblio.biblionumber = subscription.biblionumber
            LEFT JOIN biblioitems ON biblio.biblionumber = biblioitems.biblionumber
    );
    my @bind_params;
    my $sqlwhere = q{};
    if ($biblionumber) {
        $sqlwhere = "   WHERE biblio.biblionumber=?";
        push @bind_params, $biblionumber;
    }
    if ($string) {
        my @sqlstrings;
        my @strings_to_search;
        @strings_to_search = map { "%$_%" } split( / /, $string );
        foreach my $index (qw(biblio.title subscription.callnumber subscription.location subscription.notes subscription.internalnotes)) {
            push @bind_params, @strings_to_search;
            my $tmpstring = "AND $index LIKE ? " x scalar(@strings_to_search);
            $debug && warn "$tmpstring";
            $tmpstring =~ s/^AND //;
            push @sqlstrings, $tmpstring;
        }
        $sqlwhere .= ( $sqlwhere ? " AND " : " WHERE " ) . "((" . join( ") OR (", @sqlstrings ) . "))";
    }
    if ($issn) {
        my @sqlstrings;
        my @strings_to_search;
        @strings_to_search = map { "%$_%" } split( / /, $issn );
        foreach my $index ( qw(biblioitems.issn subscription.callnumber)) {
            push @bind_params, @strings_to_search;
            my $tmpstring = "OR $index LIKE ? " x scalar(@strings_to_search);
            $debug && warn "$tmpstring";
            $tmpstring =~ s/^OR //;
            push @sqlstrings, $tmpstring;
        }
        $sqlwhere .= ( $sqlwhere ? " AND " : " WHERE " ) . "((" . join( ") OR (", @sqlstrings ) . "))";
    }
    if ($ean) {
        my @sqlstrings;
        my @strings_to_search;
        @strings_to_search = map { "$_" } split( / /, $ean );
        foreach my $index ( qw(biblioitems.ean) ) {
            push @bind_params, @strings_to_search;
            my $tmpstring = "OR $index = ? " x scalar(@strings_to_search);
            $debug && warn "$tmpstring";
            $tmpstring =~ s/^OR //;
            push @sqlstrings, $tmpstring;
        }
        $sqlwhere .= ( $sqlwhere ? " AND " : " WHERE " ) . "((" . join( ") OR (", @sqlstrings ) . "))";
    }

    $sql .= "$sqlwhere ORDER BY title";
    $debug and warn "GetSubscriptions query: $sql params : ", join( " ", @bind_params );
    $sth = $dbh->prepare($sql);
    $sth->execute(@bind_params);
    my @results;

    while ( my $line = $sth->fetchrow_hashref ) {
        $line->{'cannotedit'} =
          (      C4::Context->preference('IndependantBranches')
              && C4::Context->userenv
              && C4::Context->userenv->{flags} % 2 != 1
              && C4::Context->userenv->{branch}
              && $line->{branchcode}
              && ( C4::Context->userenv->{branch} ne $line->{branchcode} ) );
        push @results, $line;
    }
    return @results;
}

=head2 SearchSubscriptions

@results = SearchSubscriptions($args);
$args is a hashref. Its keys can be contained: title, issn, ean, publisher, bookseller and branchcode

this function gets all subscriptions which have title like $title, ISSN like $issn, EAN like $ean, publisher like $publisher, bookseller like $bookseller AND branchcode eq $branch.

return:
a table of hashref. Each hash containt the subscription.

=cut

sub SearchSubscriptions {
    my ( $args ) = @_;

    my $query = qq{
        SELECT subscription.*, subscriptionhistory.*, biblio.*, biblioitems.issn
        FROM subscription
            LEFT JOIN subscriptionhistory USING(subscriptionid)
            LEFT JOIN biblio ON biblio.biblionumber = subscription.biblionumber
            LEFT JOIN biblioitems ON biblioitems.biblionumber = subscription.biblionumber
            LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
    };
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
    if( defined $args->{closed} ){
        push @where_strs, "subscription.closed = ?";
        push @where_args, "$args->{closed}";
    }
    if(@where_strs){
        $query .= " WHERE " . join(" AND ", @where_strs);
    }

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute(@where_args);
    my $results = $sth->fetchall_arrayref( {} );
    $sth->finish;

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
    my $dbh = C4::Context->dbh;

    # status = 2 is "arrived"
    my $counter = 0;
    $count = 5 unless ($count);
    my @serials;
    my $query = "SELECT serialid,serialseq, status, publisheddate, planneddate,notes, routingnotes
                        FROM   serial
                        WHERE  subscriptionid = ? AND status NOT IN (2,4,5) 
                        ORDER BY IF(publisheddate<>'0000-00-00',publisheddate,planneddate) DESC";
    my $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);

    while ( my $line = $sth->fetchrow_hashref ) {
        $line->{ "status" . $line->{status} } = 1;                                         # fills a "statusX" value, used for template status select list
        for my $datefield ( qw( planneddate publisheddate) ) {
            if ($line->{$datefield} && $line->{$datefield}!~m/^00/) {
                $line->{$datefield} = format_date( $line->{$datefield});
            } else {
                $line->{$datefield} = q{};
            }
        }
        push @serials, $line;
    }

    # OK, now add the last 5 issues arrives/missing
    $query = "SELECT   serialid,serialseq, status, planneddate, publisheddate,notes, routingnotes
       FROM     serial
       WHERE    subscriptionid = ?
       AND      (status in (2,4,5))
       ORDER BY IF(publisheddate<>'0000-00-00',publisheddate,planneddate) DESC
      ";
    $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    while ( ( my $line = $sth->fetchrow_hashref ) && $counter < $count ) {
        $counter++;
        $line->{ "status" . $line->{status} } = 1;                                         # fills a "statusX" value, used for template status select list
        for my $datefield ( qw( planneddate publisheddate) ) {
            if ($line->{$datefield} && $line->{$datefield}!~m/^00/) {
                $line->{$datefield} = format_date( $line->{$datefield});
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

@serials = GetSerials2($subscriptionid,$status);
this function returns every serial waited for a given subscription
as well as the number of issues registered in the database (all types)
this number is used to see if a subscription can be deleted (=it must have only 1 issue)

=cut

sub GetSerials2 {
    my ( $subscription, $status ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|
                 SELECT   serialid,serialseq, status, planneddate, publisheddate,notes, routingnotes
                 FROM     serial 
                 WHERE    subscriptionid=$subscription AND status IN ($status)
                 ORDER BY publisheddate,serialid DESC
                    |;
    $debug and warn "GetSerials2 query: $query";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my @serials;

    while ( my $line = $sth->fetchrow_hashref ) {
        $line->{ "status" . $line->{status} } = 1; # fills a "statusX" value, used for template status select list
        # Format dates for display
        for my $datefield ( qw( planneddate publisheddate ) ) {
            if ($line->{$datefield} =~m/^00/) {
                $line->{$datefield} = q{};
            }
            else {
                $line->{$datefield} = format_date( $line->{$datefield} );
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
    my $dbh = C4::Context->dbh;

    # status = 2 is "arrived"
    my $strsth = "SELECT   serialid,serialseq, status, planneddate, notes
                        FROM     serial
                        WHERE    subscriptionid = ?
                        AND      (status =2 or status=4)
                        ORDER BY publisheddate DESC LIMIT 0,$limit
                ";
    my $sth = $dbh->prepare($strsth);
    $sth->execute($subscriptionid);
    my @serials;
    while ( my $line = $sth->fetchrow_hashref ) {
        $line->{ "status" . $line->{status} } = 1;                        # fills a "statusX" value, used for template status select list
        $line->{"planneddate"} = format_date( $line->{"planneddate"} );
        push @serials, $line;
    }

    return \@serials;
}

=head2 GetDistributedTo

$distributedto=GetDistributedTo($subscriptionid)
This function returns the field distributedto for the subscription matching subscriptionid

=cut

sub GetDistributedTo {
    my $dbh = C4::Context->dbh;
    my $distributedto;
    my $subscriptionid = @_;
    my $query          = "SELECT distributedto FROM subscription WHERE subscriptionid=?";
    my $sth            = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    return ($distributedto) = $sth->fetchrow;
}

=head2 GetNextSeq

GetNextSeq($val)
$val is a hashref containing all the attributes of the table 'subscription'
This function get the next issue for the subscription given on input arg
return:
a list containing all the input params updated.

=cut

# sub GetNextSeq {
#     my ($val) =@_;
#     my ($calculated,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3);
#     $calculated = $val->{numberingmethod};
# # calculate the (expected) value of the next issue recieved.
#     $newlastvalue1 = $val->{lastvalue1};
# # check if we have to increase the new value.
#     $newinnerloop1 = $val->{innerloop1}+1;
#     $newinnerloop1=0 if ($newinnerloop1 >= $val->{every1});
#     $newlastvalue1 += $val->{add1} if ($newinnerloop1<1); # <1 to be true when 0 or empty.
#     $newlastvalue1=$val->{setto1} if ($newlastvalue1>$val->{whenmorethan1}); # reset counter if needed.
#     $calculated =~ s/\{X\}/$newlastvalue1/g;
#
#     $newlastvalue2 = $val->{lastvalue2};
# # check if we have to increase the new value.
#     $newinnerloop2 = $val->{innerloop2}+1;
#     $newinnerloop2=0 if ($newinnerloop2 >= $val->{every2});
#     $newlastvalue2 += $val->{add2} if ($newinnerloop2<1); # <1 to be true when 0 or empty.
#     $newlastvalue2=$val->{setto2} if ($newlastvalue2>$val->{whenmorethan2}); # reset counter if needed.
#     $calculated =~ s/\{Y\}/$newlastvalue2/g;
#
#     $newlastvalue3 = $val->{lastvalue3};
# # check if we have to increase the new value.
#     $newinnerloop3 = $val->{innerloop3}+1;
#     $newinnerloop3=0 if ($newinnerloop3 >= $val->{every3});
#     $newlastvalue3 += $val->{add3} if ($newinnerloop3<1); # <1 to be true when 0 or empty.
#     $newlastvalue3=$val->{setto3} if ($newlastvalue3>$val->{whenmorethan3}); # reset counter if needed.
#     $calculated =~ s/\{Z\}/$newlastvalue3/g;
#     return ($calculated,$newlastvalue1,$newlastvalue2,$newlastvalue3,$newinnerloop1,$newinnerloop2,$newinnerloop3);
# }

sub GetNextSeq {
    my ($val) = @_;
    my ( $calculated, $newlastvalue1, $newlastvalue2, $newlastvalue3, $newinnerloop1, $newinnerloop2, $newinnerloop3 );
    my $pattern          = $val->{numberpattern};
    my @seasons          = ( 'nothing', 'Winter', 'Spring', 'Summer', 'Autumn' );
    my @southern_seasons = ( '', 'Summer', 'Autumn', 'Winter', 'Spring' );
    $calculated    = $val->{numberingmethod};
    $newlastvalue1 = $val->{lastvalue1};
    $newlastvalue2 = $val->{lastvalue2};
    $newlastvalue3 = $val->{lastvalue3};
    $newlastvalue1 = $val->{lastvalue1};

    # check if we have to increase the new value.
    $newinnerloop1 = $val->{innerloop1} + 1;
    $newinnerloop1 = 0 if ( $newinnerloop1 >= $val->{every1} );
    $newlastvalue1 += $val->{add1} if ( $newinnerloop1 < 1 );    # <1 to be true when 0 or empty.
    $newlastvalue1 = $val->{setto1} if ( $newlastvalue1 > $val->{whenmorethan1} );    # reset counter if needed.
    $calculated =~ s/\{X\}/$newlastvalue1/g;

    $newlastvalue2 = $val->{lastvalue2};

    # check if we have to increase the new value.
    $newinnerloop2 = $val->{innerloop2} + 1;
    $newinnerloop2 = 0 if ( $newinnerloop2 >= $val->{every2} );
    $newlastvalue2 += $val->{add2} if ( $newinnerloop2 < 1 );                         # <1 to be true when 0 or empty.
    $newlastvalue2 = $val->{setto2} if ( $newlastvalue2 > $val->{whenmorethan2} );    # reset counter if needed.
    if ( $pattern == 6 ) {
        if ( $val->{hemisphere} == 2 ) {
            my $newlastvalue2seq = $southern_seasons[$newlastvalue2];
            $calculated =~ s/\{Y\}/$newlastvalue2seq/g;
        } else {
            my $newlastvalue2seq = $seasons[$newlastvalue2];
            $calculated =~ s/\{Y\}/$newlastvalue2seq/g;
        }
    } else {
        $calculated =~ s/\{Y\}/$newlastvalue2/g;
    }

    $newlastvalue3 = $val->{lastvalue3};

    # check if we have to increase the new value.
    $newinnerloop3 = $val->{innerloop3} + 1;
    $newinnerloop3 = 0 if ( $newinnerloop3 >= $val->{every3} );
    $newlastvalue3 += $val->{add3} if ( $newinnerloop3 < 1 );    # <1 to be true when 0 or empty.
    $newlastvalue3 = $val->{setto3} if ( $newlastvalue3 > $val->{whenmorethan3} );    # reset counter if needed.
    $calculated =~ s/\{Z\}/$newlastvalue3/g;

    return ( $calculated, $newlastvalue1, $newlastvalue2, $newlastvalue3, $newinnerloop1, $newinnerloop2, $newinnerloop3 );
}

=head2 GetSeq

$calculated = GetSeq($val)
$val is a hashref containing all the attributes of the table 'subscription'
this function transforms {X},{Y},{Z} to 150,0,0 for example.
return:
the sequence in integer format

=cut

sub GetSeq {
    my ($val) = @_;
    my $pattern = $val->{numberpattern};
    my @seasons          = ( 'nothing', 'Winter', 'Spring', 'Summer', 'Autumn' );
    my @southern_seasons = ( '',        'Summer', 'Autumn', 'Winter', 'Spring' );
    my $calculated       = $val->{numberingmethod};
    my $x                = $val->{'lastvalue1'};
    $calculated =~ s/\{X\}/$x/g;
    my $newlastvalue2 = $val->{'lastvalue2'};

    if ( $pattern == 6 ) {
        if ( $val->{hemisphere} == 2 ) {
            my $newlastvalue2seq = $southern_seasons[$newlastvalue2];
            $calculated =~ s/\{Y\}/$newlastvalue2seq/g;
        } else {
            my $newlastvalue2seq = $seasons[$newlastvalue2];
            $calculated =~ s/\{Y\}/$newlastvalue2seq/g;
        }
    } else {
        $calculated =~ s/\{Y\}/$newlastvalue2/g;
    }
    my $z = $val->{'lastvalue3'};
    $calculated =~ s/\{Z\}/$z/g;
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
    my $dbh          = C4::Context->dbh;
    my $subscription = GetSubscription($subscriptionid);
    my $enddate;

    # we don't do the same test if the subscription is based on X numbers or on X weeks/months
    $enddate = $startdate || $subscription->{startdate};
    my @date = split( /-/, $enddate );
    return if ( scalar(@date) != 3 || not check_date(@date) );
    if ( ( $subscription->{periodicity} % 16 ) > 0 ) {

        # If Not Irregular
        if ( my $length = $subscription->{numberlength} ) {

            #calculate the date of the last issue.
            for ( my $i = 1 ; $i <= $length ; $i++ ) {
                $enddate = GetNextDate( $enddate, $subscription );
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
        }
        return $enddate;
    } else {
        return;
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
    my ( $subscriptionid, $histstartdate, $enddate, $recievedlist, $missinglist, $opacnote, $librariannote ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "UPDATE subscriptionhistory 
                    SET histstartdate=?,histenddate=?,recievedlist=?,missinglist=?,opacnote=?,librariannote=?
                    WHERE subscriptionid=?
                ";
    my $sth = $dbh->prepare($query);
    $recievedlist =~ s/^; //;
    $missinglist  =~ s/^; //;
    $opacnote     =~ s/^; //;
    $sth->execute( $histstartdate, $enddate, $recievedlist, $missinglist, $opacnote, $librariannote, $subscriptionid );
    return $sth->rows;
}

=head2 ModSerialStatus

ModSerialStatus($serialid,$serialseq, $planneddate,$publisheddate,$status,$notes)

This function modify the serial status. Serial status is a number.(eg 2 is "arrived")
Note : if we change from "waited" to something else,then we will have to create a new "waited" entry

=cut

sub ModSerialStatus {
    my ( $serialid, $serialseq, $planneddate, $publisheddate, $status, $notes ) = @_;

    #It is a usual serial
    # 1st, get previous status :
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT subscriptionid,status FROM serial WHERE  serialid=?";
    my $sth   = $dbh->prepare($query);
    $sth->execute($serialid);
    my ( $subscriptionid, $oldstatus ) = $sth->fetchrow;

    # change status & update subscriptionhistory
    my $val;
    if ( $status == 6 ) {
        DelIssue( {'serialid'=>$serialid, 'subscriptionid'=>$subscriptionid,'serialseq'=>$serialseq} );
    }
    else {
        my $query =
'UPDATE serial SET serialseq=?,publisheddate=?,planneddate=?,status=?,notes=? WHERE  serialid = ?';
        $sth = $dbh->prepare($query);
        $sth->execute( $serialseq, $publisheddate, $planneddate, $status, $notes, $serialid );
        $query = "SELECT * FROM   subscription WHERE  subscriptionid = ?";
        $sth   = $dbh->prepare($query);
        $sth->execute($subscriptionid);
        my $val = $sth->fetchrow_hashref;
        unless ( $val->{manualhistory} ) {
            $query = "SELECT missinglist,recievedlist FROM subscriptionhistory WHERE  subscriptionid=?";
            $sth   = $dbh->prepare($query);
            $sth->execute($subscriptionid);
            my ( $missinglist, $recievedlist ) = $sth->fetchrow;
            if ( $status == 2 ) {

                $recievedlist .= "; $serialseq"
                  unless ( index( "$recievedlist", "$serialseq" ) >= 0 );
            }

            #         warn "missinglist : $missinglist serialseq :$serialseq, ".index("$missinglist","$serialseq");
            $missinglist .= "; $serialseq"
              if ( $status == 4
                and not index( "$missinglist", "$serialseq" ) >= 0 );
            $missinglist .= "; not issued $serialseq"
              if ( $status == 5
                and index( "$missinglist", "$serialseq" ) >= 0 );
            $query = "UPDATE subscriptionhistory SET recievedlist=?, missinglist=? WHERE  subscriptionid=?";
            $sth   = $dbh->prepare($query);
            $recievedlist =~ s/^; //;
            $missinglist  =~ s/^; //;
            $sth->execute( $recievedlist, $missinglist, $subscriptionid );
        }
    }

    # create new waited entry if needed (ie : was a "waited" and has changed)
    if ( $oldstatus == 1 && $status != 1 ) {
        my $query = "SELECT * FROM   subscription WHERE  subscriptionid = ?";
        $sth = $dbh->prepare($query);
        $sth->execute($subscriptionid);
        my $val = $sth->fetchrow_hashref;

        # next issue number
        my (
            $newserialseq,  $newlastvalue1, $newlastvalue2, $newlastvalue3,
            $newinnerloop1, $newinnerloop2, $newinnerloop3
        ) = GetNextSeq($val);

        # next date (calculated from actual date & frequency parameters)
        my $nextpublisheddate = GetNextDate( $publisheddate, $val );
        NewIssue( $newserialseq, $subscriptionid, $val->{'biblionumber'}, 1, $nextpublisheddate, $nextpublisheddate );
        $query = "UPDATE subscription SET lastvalue1=?, lastvalue2=?, lastvalue3=?, innerloop1=?, innerloop2=?, innerloop3=?
                    WHERE  subscriptionid = ?";
        $sth = $dbh->prepare($query);
        $sth->execute( $newlastvalue1, $newlastvalue2, $newlastvalue3, $newinnerloop1, $newinnerloop2, $newinnerloop3, $subscriptionid );

# check if an alert must be sent... (= a letter is defined & status became "arrived"
        if ( $val->{letter} && $status == 2 && $oldstatus != 2 ) {
            require C4::Letters;
            C4::Letters::SendAlerts( 'issue', $val->{subscriptionid}, $val->{letter} );
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
    planneddate => C4::Dates object
    }

=cut

sub GetNextExpected {
    my ($subscriptionid) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              = $dbh->prepare('SELECT serialid, planneddate FROM serial WHERE subscriptionid=? AND status=?');

    # Each subscription has only one 'expected' issue, with serial.status==1.
    $sth->execute( $subscriptionid, 1 );
    my ( $nextissue ) = $sth->fetchrow_hashref;
    if( !$nextissue){
         $sth = $dbh->prepare('SELECT serialid,planneddate FROM serial WHERE subscriptionid  = ? ORDER BY planneddate DESC LIMIT 1');
         $sth->execute( $subscriptionid );  
         $nextissue = $sth->fetchrow_hashref;       
    }
    if (!defined $nextissue->{planneddate}) {
        # or should this default to 1st Jan ???
        $nextissue->{planneddate} = strftime('%Y-%m-%d',localtime);
    }
    $nextissue->{planneddate} = C4::Dates->new($nextissue->{planneddate},'iso');
    return $nextissue;

}

=head2 ModNextExpected

ModNextExpected($subscriptionid,$date)

Update the planneddate for the current expected issue of the subscription.
This will modify all future prediction results.  

C<$date> is a C4::Dates object.

returns 0

=cut

sub ModNextExpected {
    my ( $subscriptionid, $date ) = @_;
    my $dbh = C4::Context->dbh;

    #FIXME: Would expect to only set planneddate, but we set both on new issue creation, so updating it here
    my $sth = $dbh->prepare('UPDATE serial SET planneddate=?,publisheddate=? WHERE subscriptionid=? AND status=?');

    # Each subscription has only one 'expected' issue, with serial.status==1.
    $sth->execute( $date->output('iso'), $date->output('iso'), $subscriptionid, 1 );
    return 0;

}

=head2 ModSubscription

this function modifies a subscription. Put all new values on input args.
returns the number of rows affected

=cut

sub ModSubscription {
    my ($auser,           $branchcode,      $aqbooksellerid,    $cost,             $aqbudgetid,    $startdate,   $periodicity,   $firstacquidate,
        $dow,             $irregularity,    $numberpattern,     $numberlength,     $weeklength,    $monthlength, $add1,          $every1,
        $whenmorethan1,   $setto1,          $lastvalue1,        $innerloop1,       $add2,          $every2,      $whenmorethan2, $setto2,
        $lastvalue2,      $innerloop2,      $add3,              $every3,           $whenmorethan3, $setto3,      $lastvalue3,    $innerloop3,
        $numberingmethod, $status,          $biblionumber,      $callnumber,       $notes,         $letter,      $hemisphere,    $manualhistory,
        $internalnotes,   $serialsadditems, $staffdisplaycount, $opacdisplaycount, $graceperiod,   $location,    $enddate,       $subscriptionid
    ) = @_;

    #     warn $irregularity;
    my $dbh   = C4::Context->dbh;
    my $query = "UPDATE subscription
                    SET librarian=?, branchcode=?,aqbooksellerid=?,cost=?,aqbudgetid=?,startdate=?,
                        periodicity=?,firstacquidate=?,dow=?,irregularity=?, numberpattern=?, numberlength=?,weeklength=?,monthlength=?,
                        add1=?,every1=?,whenmorethan1=?,setto1=?,lastvalue1=?,innerloop1=?,
                        add2=?,every2=?,whenmorethan2=?,setto2=?,lastvalue2=?,innerloop2=?,
                        add3=?,every3=?,whenmorethan3=?,setto3=?,lastvalue3=?,innerloop3=?,
                        numberingmethod=?, status=?, biblionumber=?, callnumber=?, notes=?, 
						letter=?, hemisphere=?,manualhistory=?,internalnotes=?,serialsadditems=?,
						staffdisplaycount = ?,opacdisplaycount = ?, graceperiod = ?, location = ?
						,enddate=?
                    WHERE subscriptionid = ?";

    #warn "query :".$query;
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $auser,           $branchcode,     $aqbooksellerid, $cost,
        $aqbudgetid,      $startdate,      $periodicity,    $firstacquidate,
        $dow,             "$irregularity", $numberpattern,  $numberlength,
        $weeklength,      $monthlength,    $add1,           $every1,
        $whenmorethan1,   $setto1,         $lastvalue1,     $innerloop1,
        $add2,            $every2,         $whenmorethan2,  $setto2,
        $lastvalue2,      $innerloop2,     $add3,           $every3,
        $whenmorethan3,   $setto3,         $lastvalue3,     $innerloop3,
        $numberingmethod, $status,         $biblionumber,   $callnumber,
        $notes, $letter, $hemisphere, ( $manualhistory ? $manualhistory : 0 ),
        $internalnotes, $serialsadditems, $staffdisplaycount, $opacdisplaycount,
        $graceperiod,   $location,        $enddate,           $subscriptionid
    );
    my $rows = $sth->rows;

    logaction( "SERIAL", "MODIFY", $subscriptionid, "" ) if C4::Context->preference("SubscriptionLog");
    return $rows;
}

=head2 NewSubscription

$subscriptionid = &NewSubscription($auser,branchcode,$aqbooksellerid,$cost,$aqbudgetid,$biblionumber,
    $startdate,$periodicity,$dow,$numberlength,$weeklength,$monthlength,
    $add1,$every1,$whenmorethan1,$setto1,$lastvalue1,$innerloop1,
    $add2,$every2,$whenmorethan2,$setto2,$lastvalue2,$innerloop2,
    $add3,$every3,$whenmorethan3,$setto3,$lastvalue3,$innerloop3,
    $numberingmethod, $status, $notes, $serialsadditems,
    $staffdisplaycount, $opacdisplaycount, $graceperiod, $location, $enddate);

Create a new subscription with value given on input args.

return :
the id of this new subscription

=cut

sub NewSubscription {
    my ($auser,         $branchcode,      $aqbooksellerid,    $cost,             $aqbudgetid,    $biblionumber, $startdate,       $periodicity,
        $dow,           $numberlength,    $weeklength,        $monthlength,      $add1,          $every1,       $whenmorethan1,   $setto1,
        $lastvalue1,    $innerloop1,      $add2,              $every2,           $whenmorethan2, $setto2,       $lastvalue2,      $innerloop2,
        $add3,          $every3,          $whenmorethan3,     $setto3,           $lastvalue3,    $innerloop3,   $numberingmethod, $status,
        $notes,         $letter,          $firstacquidate,    $irregularity,     $numberpattern, $callnumber,   $hemisphere,      $manualhistory,
        $internalnotes, $serialsadditems, $staffdisplaycount, $opacdisplaycount, $graceperiod,   $location,     $enddate
    ) = @_;
    my $dbh = C4::Context->dbh;

    #save subscription (insert into database)
    my $query = qq|
        INSERT INTO subscription
            (librarian,branchcode,aqbooksellerid,cost,aqbudgetid,biblionumber,
            startdate,periodicity,dow,numberlength,weeklength,monthlength,
            add1,every1,whenmorethan1,setto1,lastvalue1,innerloop1,
            add2,every2,whenmorethan2,setto2,lastvalue2,innerloop2,
            add3,every3,whenmorethan3,setto3,lastvalue3,innerloop3,
            numberingmethod, status, notes, letter,firstacquidate,irregularity,
            numberpattern, callnumber, hemisphere,manualhistory,internalnotes,serialsadditems,
            staffdisplaycount,opacdisplaycount,graceperiod,location,enddate)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        |;
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $auser,         $branchcode,      $aqbooksellerid,    $cost,             $aqbudgetid,    $biblionumber, $startdate,       $periodicity,
        $dow,           $numberlength,    $weeklength,        $monthlength,      $add1,          $every1,       $whenmorethan1,   $setto1,
        $lastvalue1,    $innerloop1,      $add2,              $every2,           $whenmorethan2, $setto2,       $lastvalue2,      $innerloop2,
        $add3,          $every3,          $whenmorethan3,     $setto3,           $lastvalue3,    $innerloop3,   $numberingmethod, "$status",
        $notes,         $letter,          $firstacquidate,    $irregularity,     $numberpattern, $callnumber,   $hemisphere,      $manualhistory,
        $internalnotes, $serialsadditems, $staffdisplaycount, $opacdisplaycount, $graceperiod,   $location,     $enddate
    );

    my $subscriptionid = $dbh->{'mysql_insertid'};
    unless ($enddate){
       $enddate = GetExpirationDate($subscriptionid,$startdate);
        $query = q|
            UPDATE subscription
            SET    enddate=?
            WHERE  subscriptionid=?
        |;
        $sth = $dbh->prepare($query);
        $sth->execute( $enddate, $subscriptionid );
    }
    #then create the 1st waited number
    $query = qq(
        INSERT INTO subscriptionhistory
            (biblionumber, subscriptionid, histstartdate,  opacnote, librariannote)
        VALUES (?,?,?,?,?)
        );
    $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $subscriptionid, $startdate, $notes, $internalnotes );

    # reread subscription to get a hash (for calculation of the 1st issue number)
    $query = qq(
        SELECT *
        FROM   subscription
        WHERE  subscriptionid = ?
    );
    $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my $val = $sth->fetchrow_hashref;

    # calculate issue number
    my $serialseq = GetSeq($val);
    $query = qq|
        INSERT INTO serial
            (serialseq,subscriptionid,biblionumber,status, planneddate, publisheddate)
        VALUES (?,?,?,?,?,?)
    |;
    $sth = $dbh->prepare($query);
    $sth->execute( "$serialseq", $subscriptionid, $biblionumber, 1, $firstacquidate, $firstacquidate );

    logaction( "SERIAL", "ADD", $subscriptionid, "" ) if C4::Context->preference("SubscriptionLog");

    #set serial flag on biblio if not already set.
    my $bib = GetBiblio($biblionumber);
    if ( !$bib->{'serial'} ) {
        my $record = GetMarcBiblio($biblionumber);
        my ( $tag, $subf ) = GetMarcFromKohaField( 'biblio.serial', $bib->{'frameworkcode'} );
        if ($tag) {
            eval { $record->field($tag)->update( $subf => 1 ); };
        }
        ModBiblio( $record, $biblionumber, $bib->{'frameworkcode'} );
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

    # renew subscription
    $query = qq|
        UPDATE subscription
        SET    startdate=?,numberlength=?,weeklength=?,monthlength=?
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
    $query = qq|
        UPDATE subscriptionhistory
        SET    histenddate=?
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
    my ( $serialseq, $subscriptionid, $biblionumber, $status, $planneddate, $publisheddate, $notes ) = @_;
    ### FIXME biblionumber CAN be provided by subscriptionid. So Do we STILL NEED IT ?

    my $dbh   = C4::Context->dbh;
    my $query = qq|
        INSERT INTO serial
            (serialseq,subscriptionid,biblionumber,status,publisheddate,planneddate,notes)
        VALUES (?,?,?,?,?,?,?)
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute( $serialseq, $subscriptionid, $biblionumber, $status, $publisheddate, $planneddate, $notes );
    my $serialid = $dbh->{'mysql_insertid'};
    $query = qq|
        SELECT missinglist,recievedlist
        FROM   subscriptionhistory
        WHERE  subscriptionid=?
    |;
    $sth = $dbh->prepare($query);
    $sth->execute($subscriptionid);
    my ( $missinglist, $recievedlist ) = $sth->fetchrow;

    if ( $status == 2 ) {
      ### TODO Add a feature that improves recognition and description.
      ### As such count (serialseq) i.e. : N18,2(N19),N20
      ### Would use substr and index But be careful to previous presence of ()
        $recievedlist .= "; $serialseq" unless (index($recievedlist,$serialseq)>0);
    }
    if ( $status == 4 ) {
        $missinglist .= "; $serialseq" unless (index($missinglist,$serialseq)>0);
    }
    $query = qq|
        UPDATE subscriptionhistory
        SET    recievedlist=?, missinglist=?
        WHERE  subscriptionid=?
    |;
    $sth = $dbh->prepare($query);
    $recievedlist =~ s/^; //;
    $missinglist  =~ s/^; //;
    $sth->execute( $recievedlist, $missinglist, $subscriptionid );
    return $serialid;
}

=head2 ItemizeSerials

ItemizeSerials($serialid, $info);
$info is a hashref containing  barcode branch, itemcallnumber, status, location
$serialid the serialid
return :
1 if the itemize is a succes.
0 and @error otherwise. @error containts the list of errors found.

=cut

sub ItemizeSerials {
    my ( $serialid, $info ) = @_;
    my $now = POSIX::strftime( "%Y-%m-%d", localtime );

    my $dbh   = C4::Context->dbh;
    my $query = qq|
        SELECT *
        FROM   serial
        WHERE  serialid=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($serialid);
    my $data = $sth->fetchrow_hashref;
    if ( C4::Context->preference("RoutingSerials") ) {

        # check for existing biblioitem relating to serial issue
        my ( $count, @results ) = GetBiblioItemByBiblioNumber( $data->{'biblionumber'} );
        my $bibitemno = 0;
        for ( my $i = 0 ; $i < $count ; $i++ ) {
            if ( $results[$i]->{'volumeddesc'} eq $data->{'serialseq'} . ' (' . $data->{'planneddate'} . ')' ) {
                $bibitemno = $results[$i]->{'biblioitemnumber'};
                last;
            }
        }
        if ( $bibitemno == 0 ) {
            my $sth = $dbh->prepare( "SELECT * FROM biblioitems WHERE biblionumber = ? ORDER BY biblioitemnumber DESC" );
            $sth->execute( $data->{'biblionumber'} );
            my $biblioitem = $sth->fetchrow_hashref;
            $biblioitem->{'volumedate'}  = $data->{planneddate};
            $biblioitem->{'volumeddesc'} = $data->{serialseq} . ' (' . format_date( $data->{'planneddate'} ) . ')';
            $biblioitem->{'dewey'}       = $info->{itemcallnumber};
        }
    }

    my $fwk = GetFrameworkCode( $data->{'biblionumber'} );
    if ( $info->{barcode} ) {
        my @errors;
        if ( is_barcode_in_use( $info->{barcode} ) ) {
            push @errors, 'barcode_not_unique';
        } else {
            my $marcrecord = MARC::Record->new();
            my ( $tag, $subfield ) = GetMarcFromKohaField( "items.barcode", $fwk );
            my $newField = MARC::Field->new( "$tag", '', '', "$subfield" => $info->{barcode} );
            $marcrecord->insert_fields_ordered($newField);
            if ( $info->{branch} ) {
                my ( $tag, $subfield ) = GetMarcFromKohaField( "items.homebranch", $fwk );

                #warn "items.homebranch : $tag , $subfield";
                if ( $marcrecord->field($tag) ) {
                    $marcrecord->field($tag)->add_subfields( "$subfield" => $info->{branch} );
                } else {
                    my $newField = MARC::Field->new( "$tag", '', '', "$subfield" => $info->{branch} );
                    $marcrecord->insert_fields_ordered($newField);
                }
                ( $tag, $subfield ) = GetMarcFromKohaField( "items.holdingbranch", $fwk );

                #warn "items.holdingbranch : $tag , $subfield";
                if ( $marcrecord->field($tag) ) {
                    $marcrecord->field($tag)->add_subfields( "$subfield" => $info->{branch} );
                } else {
                    my $newField = MARC::Field->new( "$tag", '', '', "$subfield" => $info->{branch} );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ( $info->{itemcallnumber} ) {
                my ( $tag, $subfield ) = GetMarcFromKohaField( "items.itemcallnumber", $fwk );

                if ( $marcrecord->field($tag) ) {
                    $marcrecord->field($tag)->add_subfields( "$subfield" => $info->{itemcallnumber} );
                } else {
                    my $newField = MARC::Field->new( "$tag", '', '', "$subfield" => $info->{itemcallnumber} );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ( $info->{notes} ) {
                my ( $tag, $subfield ) = GetMarcFromKohaField( "items.itemnotes", $fwk );

                if ( $marcrecord->field($tag) ) {
                    $marcrecord->field($tag)->add_subfields( "$subfield" => $info->{notes} );
                } else {
                    my $newField = MARC::Field->new( "$tag", '', '', "$subfield" => $info->{notes} );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ( $info->{location} ) {
                my ( $tag, $subfield ) = GetMarcFromKohaField( "items.location", $fwk );

                if ( $marcrecord->field($tag) ) {
                    $marcrecord->field($tag)->add_subfields( "$subfield" => $info->{location} );
                } else {
                    my $newField = MARC::Field->new( "$tag", '', '', "$subfield" => $info->{location} );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ( $info->{status} ) {
                my ( $tag, $subfield ) = GetMarcFromKohaField( "items.notforloan", $fwk );

                if ( $marcrecord->field($tag) ) {
                    $marcrecord->field($tag)->add_subfields( "$subfield" => $info->{status} );
                } else {
                    my $newField = MARC::Field->new( "$tag", '', '', "$subfield" => $info->{status} );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            if ( C4::Context->preference("RoutingSerials") ) {
                my ( $tag, $subfield ) = GetMarcFromKohaField( "items.dateaccessioned", $fwk );
                if ( $marcrecord->field($tag) ) {
                    $marcrecord->field($tag)->add_subfields( "$subfield" => $now );
                } else {
                    my $newField = MARC::Field->new( "$tag", '', '', "$subfield" => $now );
                    $marcrecord->insert_fields_ordered($newField);
                }
            }
            require C4::Items;
            C4::Items::AddItemFromMarc( $marcrecord, $data->{'biblionumber'} );
            return 1;
        }
        return ( 0, @errors );
    }
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
    my $dbh              = C4::Context->dbh;
    my $subscription     = GetSubscription($subscriptionid);
    if ( ( $subscription->{periodicity} % 16 ) > 0 ) {
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
    $subscriptionid = $dbh->quote($subscriptionid);
    $dbh->do("DELETE FROM subscription WHERE subscriptionid=$subscriptionid");
    $dbh->do("DELETE FROM subscriptionhistory WHERE subscriptionid=$subscriptionid");
    $dbh->do("DELETE FROM serial WHERE subscriptionid=$subscriptionid");

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

this function selects missing issues on database - where serial.status = 4 or serial.status=3 or planneddate<now

return :
the issuelist as an array of hash refs. Each element of this array contains 
name,title,planneddate,serialseq,serial.subscriptionid from tables : subscription, serial & biblio

=cut

sub GetLateOrMissingIssues {
    my ( $supplierid, $serialid, $order ) = @_;
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
    if ($supplierid) {
        $sth = $dbh->prepare(
            "SELECT
                serialid,      aqbooksellerid,        name,
                biblio.title,  planneddate,           serialseq,
                serial.status, serial.subscriptionid, claimdate,
                subscription.branchcode
            FROM      serial 
                LEFT JOIN subscription  ON serial.subscriptionid=subscription.subscriptionid 
                LEFT JOIN biblio        ON subscription.biblionumber=biblio.biblionumber
                LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
                WHERE subscription.subscriptionid = serial.subscriptionid 
                AND (serial.STATUS = 4 OR ((planneddate < now() AND serial.STATUS =1) OR serial.STATUS = 3 OR serial.STATUS = 7))
                AND subscription.aqbooksellerid=$supplierid
                $byserial
                ORDER BY $order"
        );
    } else {
        $sth = $dbh->prepare(
            "SELECT 
            serialid,      aqbooksellerid,         name,
            biblio.title,  planneddate,           serialseq,
                serial.status, serial.subscriptionid, claimdate,
                subscription.branchcode
            FROM serial 
                LEFT JOIN subscription ON serial.subscriptionid=subscription.subscriptionid 
                LEFT JOIN biblio ON subscription.biblionumber=biblio.biblionumber
                LEFT JOIN aqbooksellers ON subscription.aqbooksellerid = aqbooksellers.id
                WHERE subscription.subscriptionid = serial.subscriptionid 
                        AND (serial.STATUS = 4 OR ((planneddate < now() AND serial.STATUS =1) OR serial.STATUS = 3 OR serial.STATUS = 7))
                $byserial
                ORDER BY $order"
        );
    }
    $sth->execute;
    my @issuelist;
    while ( my $line = $sth->fetchrow_hashref ) {

        if ($line->{planneddate} && $line->{planneddate} !~/^0+\-/) {
            $line->{planneddate} = format_date( $line->{planneddate} );
        }
        if ($line->{claimdate} && $line->{claimdate} !~/^0+\-/) {
            $line->{claimdate}   = format_date( $line->{claimdate} );
        }
        $line->{"status".$line->{status}}   = 1;
        push @issuelist, $line;
    }
    return @issuelist;
}

=head2 removeMissingIssue

removeMissingIssue($subscriptionid)

this function removes an issue from being part of the missing string in 
subscriptionlist.missinglist column

called when a missing issue is found from the serials-recieve.pl file

=cut

sub removeMissingIssue {
    my ( $sequence, $subscriptionid ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT * FROM subscriptionhistory WHERE subscriptionid = ?");
    $sth->execute($subscriptionid);
    my $data              = $sth->fetchrow_hashref;
    my $missinglist       = $data->{'missinglist'};
    my $missinglistbefore = $missinglist;

    # warn $missinglist." before";
    $missinglist =~ s/($sequence)//;

    # warn $missinglist." after";
    if ( $missinglist ne $missinglistbefore ) {
        $missinglist =~ s/\|\s\|/\|/g;
        $missinglist =~ s/^\| //g;
        $missinglist =~ s/\|$//g;
        my $sth2 = $dbh->prepare(
            "UPDATE subscriptionhistory
                    SET missinglist = ?
                    WHERE subscriptionid = ?"
        );
        $sth2->execute( $missinglist, $subscriptionid );
    }
    return;
}

=head2 updateClaim

&updateClaim($serialid)

this function updates the time when a claim is issued for late/missing items

called from claims.pl file

=cut

sub updateClaim {
    my ($serialid) = @_;
    my $dbh        = C4::Context->dbh;
    my $sth        = $dbh->prepare(
        "UPDATE serial SET claimdate = now()
                WHERE serialid = ?
        "
    );
    $sth->execute($serialid);
    return;
}

=head2 getsupplierbyserialid

$result = getsupplierbyserialid($serialid)

this function is used to find the supplier id given a serial id

return :
hashref containing serialid, subscriptionid, and aqbooksellerid

=cut

sub getsupplierbyserialid {
    my ($serialid) = @_;
    my $dbh        = C4::Context->dbh;
    my $sth        = $dbh->prepare(
        "SELECT serialid, serial.subscriptionid, aqbooksellerid
         FROM serial 
            LEFT JOIN subscription ON serial.subscriptionid = subscription.subscriptionid
            WHERE serialid = ?
        "
    );
    $sth->execute($serialid);
    my $line   = $sth->fetchrow_hashref;
    my $result = $line->{'aqbooksellerid'};
    return $result;
}

=head2 check_routing

$result = &check_routing($subscriptionid)

this function checks to see if a serial has a routing list and returns the count of routingid
used to show either an 'add' or 'edit' link

=cut

sub check_routing {
    my ($subscriptionid) = @_;
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
    if ($per && $per % 16 > 0){
        my $expirationdate   = GetExpirationDate($subscriptionid);
        my ($res) = $dbh->selectrow_array('select max(planneddate) from serial where subscriptionid = ?', undef, $subscriptionid);
        my @res;
        if (defined $res) {
            @res=split (/-/,$res);
            @res=Date::Calc::Today if ($res[0]*$res[1]==0);
        } else { # default an undefined value
            @res=Date::Calc::Today;
        }
        my @endofsubscriptiondate=split(/-/,$expirationdate);
        my @per_list = (0, 7, 7, 14, 21, 31, 62, 93, 93, 190, 365, 730, 0, 124, 0, 0);
        my @datebeforeend;
        @datebeforeend = Add_Delta_Days(  $endofsubscriptiondate[0],$endofsubscriptiondate[1],$endofsubscriptiondate[2],
            - (3 * $per_list[$per])) if (@endofsubscriptiondate && $endofsubscriptiondate[0]*$endofsubscriptiondate[1]*$endofsubscriptiondate[2]);
        return 1 if ( @res &&
            (@datebeforeend &&
                Delta_Days($res[0],$res[1],$res[2],
                    $datebeforeend[0],$datebeforeend[1],$datebeforeend[2]) <= 0) &&
            (@endofsubscriptiondate &&
                Delta_Days($res[0],$res[1],$res[2],
                    $endofsubscriptiondate[0],$endofsubscriptiondate[1],$endofsubscriptiondate[2]) >= 0) );
        return 0;
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

=head2 GetSubscriptionsFromBorrower

($count,@routinglist) = GetSubscriptionsFromBorrower($borrowernumber)

this gets the info from subscriptionroutinglist for each $subscriptionid

return :
a count of the serial subscription routing lists to which a patron belongs,
with the titles of those serial subscriptions as an array. Each element of the array
contains a hash_ref with subscriptionID and title of subscription.

=cut

sub GetSubscriptionsFromBorrower {
    my ($borrowernumber) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              = $dbh->prepare(
        "SELECT subscription.subscriptionid, biblio.title
            FROM subscription
            JOIN biblio ON biblio.biblionumber = subscription.biblionumber
            JOIN subscriptionroutinglist USING (subscriptionid)
            WHERE subscriptionroutinglist.borrowernumber = ? ORDER BY title ASC
                               "
    );
    $sth->execute($borrowernumber);
    my @routinglist;
    my $count = 0;
    while ( my $line = $sth->fetchrow_hashref ) {
        $count++;
        push( @routinglist, $line );
    }
    return ( $count, @routinglist );
}

=head2 GetNextDate

$resultdate = GetNextDate($planneddate,$subscription)

this function it takes the planneddate and will return the next issue's date and will skip dates if there
exists an irregularity
- eg if periodicity is monthly and $planneddate is 2007-02-10 but if March and April is to be 
skipped then the returned date will be 2007-05-10

return :
$resultdate - then next date in the sequence

Return 0 if periodicity==0

=cut

sub GetNextDate {
    my ( $planneddate, $subscription ) = @_;
    my @irreg = split( /\,/, $subscription->{irregularity} );

    #date supposed to be in ISO.

    my ( $year, $month, $day ) = split( /-/, $planneddate );
    $month = 1 unless ($month);
    $day   = 1 unless ($day);
    my @resultdate;

    #       warn "DOW $dayofweek";
    if ( $subscription->{periodicity} % 16 == 0 ) {    # 'without regularity' || 'irregular'
        return 0;
    }

    #   daily : n / week
    #   Since we're interpreting irregularity here as which days of the week to skip an issue,
    #   renaming this pattern from 1/day to " n / week ".
    if ( $subscription->{periodicity} == 1 ) {
        my $dayofweek = eval { Day_of_Week( $year, $month, $day ) };
        if ($@) { warn "year month day : $year $month $day $subscription->{subscriptionid} : $@"; }
        else {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                $dayofweek = 0 if ( $dayofweek == 7 );
                if ( in_array( ( $dayofweek + 1 ), @irreg ) ) {
                    ( $year, $month, $day ) = Add_Delta_Days( $year, $month, $day, 1 );
                    $dayofweek++;
                }
            }
            @resultdate = Add_Delta_Days( $year, $month, $day, 1 );
        }
    }

    #   1  week
    if ( $subscription->{periodicity} == 2 ) {
        my ( $wkno, $year ) = eval { Week_of_Year( $year, $month, $day ) };
        if ($@) { warn "year month day : $year $month $day $subscription->{subscriptionid} : $@"; }
        else {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {

                #FIXME: if two consecutive irreg, do we only skip one?
                if ( $irreg[$i] == ( ( $wkno != 51 ) ? ( $wkno + 1 ) % 52 : 52 ) ) {
                    ( $year, $month, $day ) = Add_Delta_Days( $year, $month, $day, 7 );
                    $wkno = ( ( $wkno != 51 ) ? ( $wkno + 1 ) % 52 : 52 );
                }
            }
            @resultdate = Add_Delta_Days( $year, $month, $day, 7 );
        }
    }

    #   1 / 2 weeks
    if ( $subscription->{periodicity} == 3 ) {
        my ( $wkno, $year ) = eval { Week_of_Year( $year, $month, $day ) };
        if ($@) { warn "year month day : $year $month $day $subscription->{subscriptionid} : $@"; }
        else {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                if ( $irreg[$i] == ( ( $wkno != 50 ) ? ( $wkno + 2 ) % 52 : 52 ) ) {
                    ### BUGFIX was previously +1 ^
                    ( $year, $month, $day ) = Add_Delta_Days( $year, $month, $day, 14 );
                    $wkno = ( ( $wkno != 50 ) ? ( $wkno + 2 ) % 52 : 52 );
                }
            }
            @resultdate = Add_Delta_Days( $year, $month, $day, 14 );
        }
    }

    #   1 / 3 weeks
    if ( $subscription->{periodicity} == 4 ) {
        my ( $wkno, $year ) = eval { Week_of_Year( $year, $month, $day ) };
        if ($@) { warn "année mois jour : $year $month $day $subscription->{subscriptionid} : $@"; }
        else {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                if ( $irreg[$i] == ( ( $wkno != 49 ) ? ( $wkno + 3 ) % 52 : 52 ) ) {
                    ( $year, $month, $day ) = Add_Delta_Days( $year, $month, $day, 21 );
                    $wkno = ( ( $wkno != 49 ) ? ( $wkno + 3 ) % 52 : 52 );
                }
            }
            @resultdate = Add_Delta_Days( $year, $month, $day, 21 );
        }
    }
    my $tmpmonth = $month;
    if ( $year && $month && $day ) {
        if ( $subscription->{periodicity} == 5 ) {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                if ( $irreg[$i] == ( ( $tmpmonth != 11 ) ? ( $tmpmonth + 1 ) % 12 : 12 ) ) {
                    ( $year, $month, $day ) = Add_Delta_YMD( $year, $month, $day, 0, 1, 0 );
                    $tmpmonth = ( ( $tmpmonth != 11 ) ? ( $tmpmonth + 1 ) % 12 : 12 );
                }
            }
            @resultdate = Add_Delta_YMD( $year, $month, $day, 0, 1, 0 );
        }
        if ( $subscription->{periodicity} == 6 ) {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                if ( $irreg[$i] == ( ( $tmpmonth != 10 ) ? ( $tmpmonth + 2 ) % 12 : 12 ) ) {
                    ( $year, $month, $day ) = Add_Delta_YMD( $year, $month, $day, 0, 2, 0 );
                    $tmpmonth = ( ( $tmpmonth != 10 ) ? ( $tmpmonth + 2 ) % 12 : 12 );
                }
            }
            @resultdate = Add_Delta_YMD( $year, $month, $day, 0, 2, 0 );
        }
        if ( $subscription->{periodicity} == 7 ) {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                if ( $irreg[$i] == ( ( $tmpmonth != 9 ) ? ( $tmpmonth + 3 ) % 12 : 12 ) ) {
                    ( $year, $month, $day ) = Add_Delta_YMD( $year, $month, $day, 0, 3, 0 );
                    $tmpmonth = ( ( $tmpmonth != 9 ) ? ( $tmpmonth + 3 ) % 12 : 12 );
                }
            }
            @resultdate = Add_Delta_YMD( $year, $month, $day, 0, 3, 0 );
        }
        if ( $subscription->{periodicity} == 8 ) {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                if ( $irreg[$i] == ( ( $tmpmonth != 9 ) ? ( $tmpmonth + 3 ) % 12 : 12 ) ) {
                    ( $year, $month, $day ) = Add_Delta_YMD( $year, $month, $day, 0, 3, 0 );
                    $tmpmonth = ( ( $tmpmonth != 9 ) ? ( $tmpmonth + 3 ) % 12 : 12 );
                }
            }
            @resultdate = Add_Delta_YMD( $year, $month, $day, 0, 3, 0 );
        }
        if ( $subscription->{periodicity} == 13 ) {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                if ( $irreg[$i] == ( ( $tmpmonth != 8 ) ? ( $tmpmonth + 4 ) % 12 : 12 ) ) {
                    ( $year, $month, $day ) = Add_Delta_YMD( $year, $month, $day, 0, 4, 0 );
                    $tmpmonth = ( ( $tmpmonth != 8 ) ? ( $tmpmonth + 4 ) % 12 : 12 );
                }
            }
            @resultdate = Add_Delta_YMD( $year, $month, $day, 0, 4, 0 );
        }
        if ( $subscription->{periodicity} == 9 ) {
            for ( my $i = 0 ; $i < @irreg ; $i++ ) {
                if ( $irreg[$i] == ( ( $tmpmonth != 9 ) ? ( $tmpmonth + 3 ) % 12 : 12 ) ) {
                    ### BUFIX Seems to need more Than One ?
                    ( $year, $month, $day ) = Add_Delta_YM( $year, $month, $day, 0, 6 );
                    $tmpmonth = ( ( $tmpmonth != 6 ) ? ( $tmpmonth + 6 ) % 12 : 12 );
                }
            }
            @resultdate = Add_Delta_YM( $year, $month, $day, 0, 6 );
        }
        if ( $subscription->{periodicity} == 10 ) {
            @resultdate = Add_Delta_YM( $year, $month, $day, 1, 0 );
        }
        if ( $subscription->{periodicity} == 11 ) {
            @resultdate = Add_Delta_YM( $year, $month, $day, 2, 0 );
        }
    }
    my $resultdate = sprintf( "%04d-%02d-%02d", $resultdate[0], $resultdate[1], $resultdate[2] );

    return "$resultdate";
}

=head2 is_barcode_in_use

Returns number of occurence of the barcode in the items table
Can be used as a boolean test of whether the barcode has
been deployed as yet

=cut

sub is_barcode_in_use {
    my $barcode = shift;
    my $dbh       = C4::Context->dbh;
    my $occurences = $dbh->selectall_arrayref(
        'SELECT itemnumber from items where barcode = ?',
        {}, $barcode

    );

    return @{$occurences};
}

=head2 CloseSubscription
Close a subscription given a subscriptionid
=cut
sub CloseSubscription {
    my ( $subscriptionid ) = @_;
    return unless $subscriptionid;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( qq{
        UPDATE subscription
        SET closed = 1
        WHERE subscriptionid = ?
    } );
    $sth->execute( $subscriptionid );

    # Set status = missing when status = stopped
    $sth = $dbh->prepare( qq{
        UPDATE serial
        SET status = 8
        WHERE subscriptionid = ?
        AND status = 1
    } );
    $sth->execute( $subscriptionid );
}

=head2 ReopenSubscription
Reopen a subscription given a subscriptionid
=cut
sub ReopenSubscription {
    my ( $subscriptionid ) = @_;
    return unless $subscriptionid;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( qq{
        UPDATE subscription
        SET closed = 0
        WHERE subscriptionid = ?
    } );
    $sth->execute( $subscriptionid );

    # Set status = expected when status = stopped
    $sth = $dbh->prepare( qq{
        UPDATE serial
        SET status = 1
        WHERE subscriptionid = ?
        AND status = 8
    } );
    $sth->execute( $subscriptionid );
}

1;
__END__

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
