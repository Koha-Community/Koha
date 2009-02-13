#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


use strict;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Dates qw/format_date/;
use C4::Serials;
use C4::Letters;
use C4::Output;
use C4::Context;


my $query = new CGI;
my $op = $query->param('op');
my $dbh = C4::Context->dbh;

my $sth;
# my $id;
my ($template, $loggedinuser, $cookie);
($template, $loggedinuser, $cookie)
  = get_template_and_user({template_name => "serials/serials-collection.tmpl",
                            query => $query,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => {serials => 1},
                            debug => 1,
                            });
my $biblionumber = $query->param('biblionumber');
my @subscriptionid = $query->param('subscriptionid');

my $subscriptiondescs ;
my $subscriptions;

if($op eq "gennext" && @subscriptionid){
    my $subscriptionid = @subscriptionid[0];
    my $subscription = GetSubscription($subscriptionid);

    my $expected = GetNextExpected($subscriptionid);
    
    my (
            $newserialseq,  $newlastvalue1, $newlastvalue2, $newlastvalue3,
            $newinnerloop1, $newinnerloop2, $newinnerloop3
        ) = GetNextSeq($subscription);

    ## We generate the next publication date    
    my $nextpublisheddate = GetNextDate( $expected->{planneddate}->output('iso'), $subscription );

    ## Creating the new issue
    NewIssue( $newserialseq, $subscriptionid, $subscription->{'biblionumber'},
            1, $nextpublisheddate, $nextpublisheddate );
            
    ## Updating the subscription seq status
    my $squery = "UPDATE subscription SET lastvalue1=?, lastvalue2=?, lastvalue3=?, innerloop1=?, innerloop2=?, innerloop3=?
                WHERE  subscriptionid = ?";
    $sth = $dbh->prepare($squery);
    $sth->execute(
        $newlastvalue1, $newlastvalue2, $newlastvalue3, $newinnerloop1,
        $newinnerloop2, $newinnerloop3, $subscriptionid
        );

    print $query->redirect('/cgi-bin/koha/serials/serials-collection.pl?subscriptionid='.$subscriptionid);
}

if (@subscriptionid){
   my @subscriptioninformation=();
   foreach my $subscriptionid (@subscriptionid){
    my $subs= GetSubscription($subscriptionid);
    $subs->{opacnote}     =~ s/\n/\<br\/\>/g;
    $subs->{missinglist}  =~ s/\n/\<br\/\>/g;
    $subs->{recievedlist} =~ s/\n/\<br\/\>/g;
    ##these are display information
    $subs->{ "periodicity" . $subs->{periodicity} } = 1;
    $subs->{ "numberpattern" . $subs->{numberpattern} } = 1;
    $subs->{ "status" . $subs->{'status'} } = 1;
    $subs->{startdate}     = format_date( $subs->{startdate} );
    $subs->{histstartdate} = format_date( $subs->{histstartdate} );
    if ( $subs->{enddate} eq '0000-00-00' ) {
        $subs->{enddate} = '';
    }
    else {
        $subs->{enddate} = format_date( $subs->{enddate} );
    }
    $subs->{'abouttoexpire'}=abouttoexpire($subs->{'subscriptionid'});
    $subs->{'subscriptionexpired'}=HasSubscriptionExpired($subs->{'subscriptionid'});
    $subs->{'subscriptionid'} = $subscriptionid;  # FIXME - why was this lost ?
    push @$subscriptiondescs,$subs;
    my $tmpsubscription= GetFullSubscription($subscriptionid);
    @subscriptioninformation=(@$tmpsubscription,@subscriptioninformation);
  }
  $subscriptions=PrepareSerialsData(\@subscriptioninformation);
} else {
  $subscriptiondescs = GetSubscriptionsFromBiblionumber($biblionumber) ;
  my $subscriptioninformation = GetFullSubscriptionsFromBiblionumber($biblionumber);
  $subscriptions=PrepareSerialsData($subscriptioninformation);
}

my $title = $subscriptiondescs->[0]{bibliotitle};
my $yearmax=($subscriptions->[0]{year} eq "manage" && scalar(@$subscriptions)>1)? $subscriptions->[1]{year} :$subscriptions->[0]{year};
my $yearmin=$subscriptions->[scalar(@$subscriptions)-1]{year};
my $subscriptionidlist="";
foreach my $subscription (@$subscriptiondescs){
  $subscriptionidlist.=$subscription->{'subscriptionid'}."," ;
  $biblionumber = $subscription->{'bibnum'} unless ($biblionumber);
}

# warn "title : $title yearmax : $yearmax nombre d'elements dans le tableau :".scalar(@$subscriptions);
#  use Data::Dumper; warn Dumper($subscriptions);
chop $subscriptionidlist;
$template->param(
          onesubscription => (scalar(@$subscriptiondescs)==1),
          subscriptionidlist => $subscriptionidlist,
          biblionumber => $biblionumber,
          subscriptions => $subscriptiondescs,
          years => $subscriptions,
          yearmin => $yearmin,
          yearmax =>$yearmax,
          bibliotitle => $title,
          suggestion => C4::Context->preference("suggestion"),
          virtualshelves => C4::Context->preference("virtualshelves"),
          subscr=>$query->param('subscriptionid'),
          );

output_html_with_http_headers $query, $cookie, $template->output;
