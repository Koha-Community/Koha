#!/usr/bin/perl

#script to administer the contract table
#written 02/09/2008 by john.soros@biblibre.com

# Copyright 2008-2009 BibLibre SARL
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
use warnings;
use CGI;
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Bookseller qw/GetBookSeller/;

sub StringSearch  {
    my ($searchstring)=@_;
    my $dbh = C4::Context->dbh;
    $searchstring=~ s/\'/\\\'/g;
    my @data=split(' ',$searchstring);
    my $sth=$dbh->prepare("Select * from aqcontract where (contractdescription like ? or contractname like ?) order by contractnumber");
    $sth->execute("%$data[0]%","%$data[0]%");
    my @results;
    while (my $row=$sth->fetchrow_hashref){
        push(@results,$row);
    }
    $sth->finish;
    return (scalar(@results),\@results);
}

my $input          = new CGI;
my $searchfield    = $input->param('searchfield');
my $script_name    = "/cgi-bin/koha/admin/aqcontract.pl";
my $contractnumber = $input->param('contractnumber');
my $op             = $input->param('op');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {   template_name   => "admin/aqcontract.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 'contracts_manage' },
        debug           => 1,
    }
);

$template->param(
    script_name    => $script_name,
    contractnumber => $contractnumber,
    searchfield    => $searchfield
);


#ADD_FORM: called if $op is 'add_form'. Used to create form to add or  modify a record
if ( $op eq 'add_form' ) {
    $template->param( add_form => 1 );
    my $data;
    my @booksellerloop = GetBookSeller("");

    #---- if primkey exists, it's a modify action, so read values to modify...
    if ($contractnumber) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("select * from aqcontract where contractnumber=?");
        $sth->execute($contractnumber);
        $data = $sth->fetchrow_hashref;
        $sth->finish;

        for my $bookseller (@booksellerloop) {
            if ( $bookseller->{'id'} eq $data->{'booksellerid'} ) {
                $bookseller->{'selected'} = 1;
            }
        }
    }
    $template->param(
        contractnumber           => $data->{'contractnumber'},
        contractname             => $data->{'contractname'},
        contractdescription      => $data->{'contractdescription'},
        contractstartdate        => format_date( $data->{'contractstartdate'} ),
        contractenddate          => format_date( $data->{'contractenddate'} ),
        booksellerloop           => \@booksellerloop,
        booksellerid             => $data->{'booksellerid'},
        DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
    );

    # END $OP eq ADD_FORM

    #ADD_VALIDATE: called by add_form, used to insert/modify data in DB
}
elsif ( $op eq 'add_validate' ) {
## Please see file perltidy.ERR
  $template->param( add_validate => 1 );
  my $is_a_modif = $input->param("is_a_modif");
  my $dbh        = C4::Context->dbh;
  if ($is_a_modif) {
      my $sth = $dbh->prepare(
          "UPDATE aqcontract SET contractstartdate=?,
                contractenddate=?,
                contractname=?,
                contractdescription=?,
                booksellerid=? WHERE contractnumber=?"
      );
      $sth->execute(
          format_date_in_iso( $input->param('contractstartdate') ),
          format_date_in_iso( $input->param('contractenddate') ),
          $input->param('contractname'),
          $input->param('contractdescription'),
          $input->param('booksellerid'),
          $input->param('contractnumber')
      );
      $sth->finish;
  } else {
      my $sth = $dbh->prepare("INSERT INTO aqcontract  (contractname,contractdescription,booksellerid,contractstartdate,contractenddate) values (?, ?, ?, ?, ?)");
      $sth->execute(
          $input->param('contractname'),
          $input->param('contractdescription'),
          $input->param('booksellerid'),
          format_date_in_iso( $input->param('contractstartdate') ),
          format_date_in_iso( $input->param('contractenddate') )
      );
      $sth->finish;
  }
  print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=aqcontract.pl\"></html>";
  exit;

  # END $OP eq ADD_VALIDATE

#DELETE_CONFIRM: called by default form, used to confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirm' ) {
    $template->param( delete_confirm => 1 );

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select contractnumber,contractstartdate,contractenddate,
                                contractname,contractdescription,booksellerid 
                            from aqcontract where contractnumber=?");
    $sth->execute($contractnumber);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;

    my $query = "SELECT name FROM aqbooksellers WHERE id LIKE $data->{'booksellerid'}";
    my $sth2  = $dbh->prepare($query);
    $sth2->execute;
    my $result         = $sth2->fetchrow;
    my $booksellername = $result;

    $template->param(
        contractnumber      => $data->{'contractnumber'},
        contractname        => $data->{'contractname'},
        contractdescription => $data->{'contractdescription'},
        contractstartdate   => format_date( $data->{'contractstartdate'} ),
        contractenddate     => format_date( $data->{'contractenddate'} ),
        booksellerid        => $data->{'booksellerid'},
        booksellername      => $booksellername,
    );

    # END $OP eq DELETE_CONFIRM

    #DELETE_CONFIRMED: called by delete_confirm, used to effectively confirm deletion of data in DB
}
elsif ( $op eq 'delete_confirmed' ) {
    $template->param( delete_confirmed => 1 );
    my $dbh            = C4::Context->dbh;
    my $contractnumber = $input->param('contractnumber');
    my $sth            = $dbh->prepare("delete from aqcontract where contractnumber=?");
    $sth->execute($contractnumber);
    $sth->finish;
    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=aqcontract.pl\"></html>";
    exit;

    # END $OP eq DELETE_CONFIRMED
    # DEFAULT: Builds a list of contracts and displays them
} else {
    $template->param(else => 1);
    my @loop;
    my ($count,$results)=StringSearch($searchfield);
    my $toggle = 0;
    for (my $i=0; $i < $count; $i++){
        if ( ($input->param('booksellerid') && $results->[$i]{'booksellerid'} == $input->param('booksellerid')) || ! $input->param('booksellerid') ) {
            my %row = (contractnumber => $results->[$i]{'contractnumber'},
                    contractname => $results->[$i]{'contractname'},
                    contractdescription => $results->[$i]{'contractdescription'},
                    contractstartdate => format_date($results->[$i]{'contractstartdate'}),
                    contractenddate => format_date($results->[$i]{'contractenddate'}),
                    booksellerid => $results->[$i]{'booksellerid'},
                    toggle => $toggle );
            push @loop, \%row;
            if ( $toggle eq 0 )
            {
                $toggle = 1;
            }
            else
            {
                $toggle = 0;
            }
        }
    }
    for my $contract (@loop) {
        my $dbh = C4::Context->dbh;
        my $query = "SELECT name FROM aqbooksellers WHERE id LIKE $contract->{'booksellerid'}";
        my $sth =$dbh->prepare($query);
        $sth->execute;
        my $result=$sth->fetchrow;
        $contract->{'booksellername'}=$result;
    }
    $template->param(loop => \@loop);
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;
