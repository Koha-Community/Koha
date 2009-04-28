#!/usr/bin/perl

# Copyright 2008 BibLibre, Olivier SAURY
#                SAN Ouest Provence
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


## modules
###################################################################################

use strict;
require Exporter;
use CGI;

use List::Util qw/min/;
use C4::Context;
use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Suggestions;
use C4::Koha;    # GetAuthorisedValue
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Branch; # GetBranches

## variables
###############################################################################

my $input           = new CGI;

my $ordernumber     = $input->param('ordernumber');
my $bookfundgroupname = $input->param('bookfundgroupname');

my $op              = $input->param('op');

my $bookfundgroupnumber   = $input->param('bookfundgroupnumber');


my $dbh = C4::Context->dbh;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   =>
        "/suggestion/suggestiondetailspd.tmpl",
        type            => "intranet",
        query           => $input,
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);



if ($op eq "add_confirm") {

################################################################################################
################################################################################################
## modify a suggestion
################################################################################################
################################################################################################

    ## 'bookfundgroupnumber', 'bookfundnumber', 'audiencenumber'
    my $bookfund_loop = ($input->param('bookfund_loop') eq "")?undef:$input->param('bookfund_loop');
    my $audience_loop = ($input->param('audience_loop') eq "")?undef:$input->param('audience_loop');

    ## modify the suggestion
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare('
        UPDATE aq2orders
        SET       title = ?
                , author = ?
                , copyrightdate = ?
                , isbn = ?
                , publishercode = ?
                , seriestitle = ?
                , note = ?
                , itemtype = ?
                , rrp = ?
                , bookfundgroupnumber = ?
                , bookfundnumber = ?
                , audiencenumber = ?
                , branchcode = ?
        WHERE ordernumber = ?
    ');


    $sth->execute(
        $input->param('title')?$input->param('title'):"",
        $input->param('author')?$input->param('author'):"",
        $input->param('copyrightdate')?$input->param('copyrightdate'):"",
        $input->param('isbn')?$input->param('isbn'):"",
        $input->param('publishercode')?$input->param('publishercode'):"",
        $input->param('seriestitle')?$input->param('seriestitle'):"",
        $input->param('note')?$input->param('note'):"",
        $input->param('itemtype')?$input->param('itemtype'):"",
        $input->param('rrp')?$input->param('rrp'):undef,
        $bookfundgroupnumber ? $bookfundgroupnumber : undef,
        $bookfundgroupnumber ? $bookfund_loop: undef,
        $bookfundgroupnumber ? $audience_loop : undef,
        $input->param('branch_loop')?$input->param('branch_loop'):"",
        $input->param('ordernumber'),
    );
    $sth->finish;


    if ($input->param("aorr")) {

        ModStatus(
            $input->param('ordernumber'),
            $input->param("aorr"),
            $input->param('reason'),
            $bookfundgroupnumber,
            $bookfund_loop,
            $loggedinuser,
            2,                              ##$step
            '',
            $input,
            );
    }



    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=acceptorrejectpd.pl?bookfundgroupnumber=".$bookfundgroupnumber."\"></html>";
    exit;

}
else {

################################################################################################
################################################################################################
## display the suggestion details
################################################################################################
################################################################################################
    my @bookfund_loop;
    my @audience_loop;
    my $chooseabookfund=0;
    my $chooseanaudience=0;
    my $bookfundgroupname;
    my $bookfundname;
    my $audiencename;
    my $itemtypedescription;

    ###################################################################################
    ## get the suggestion (from 'aq2orders')
    ###################################################################################
    my $suggestion;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
    SELECT *
    FROM aq2orders
    WHERE ordernumber=?
    ");

    $sth->execute($ordernumber);
    my $suggestion = $sth->fetchrow_hashref;
    my $bookfundgroupnumber=$suggestion->{'bookfundgroupnumber'};
    my $bookfundnumber=$suggestion->{'bookfundnumber'};
    my $branchcode=$suggestion->{'branchcode'};
    my $itemtype=$suggestion->{'itemtype'};
    my $audiencenumber=$suggestion->{'audiencenumber'};
    my $step=$suggestion->{'step'};
    $sth->finish;


    ###################################################################################
    ## get data from other tables
    ###################################################################################

    ## get data about book fund groups
    ###################################################################################

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
    SELECT bookfundgroupname
    FROM aq2bookfundgroups
    WHERE bookfundgroupnumber=?
    ");

    $sth->execute($bookfundgroupnumber);

    $bookfundgroupname = $sth->fetchrow_hashref->{'bookfundgroupname'};
    $sth->finish;


    ## get data about book funds
    ###################################################################################

    if ($bookfundgroupnumber) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("
        SELECT bookfundnumber, bookfundname
        FROM aq2bookfunds
        WHERE bookfundgroupnumber=?
        ORDER BY bookfundname
        ");

        $sth->execute($bookfundgroupnumber);

        while (my $data = $sth->fetchrow_hashref) {

            if ($data->{'bookfundnumber'} eq $bookfundnumber) {
                $data->{selected}=1;
                $bookfundname=$data->{'bookfundname'};
            }
            else {
                $data->{selected}=0;
            }

            push(@bookfund_loop, $data);
            }
        $sth->finish;
    }


    ## get data about audiences
    ###################################################################################

    if ($bookfundgroupnumber) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("
        SELECT audiencenumber, audiencename
        FROM aq2audiences
        WHERE bookfundgroupnumber=?
        ORDER BY audiencename
        ");

        $sth->execute($bookfundgroupnumber);

    ## get 'audiencenumber' value (in the table 'aq2orders')

        while (my $data = $sth->fetchrow_hashref) {
            if ($data->{'audiencenumber'} eq $audiencenumber) {
                $data->{selected}=1;
                $audiencename = $data->{'audiencename'};
            }
            else {$data->{selected}=0;}

            push(@audience_loop, $data);
            }
        $sth->finish;
    }


    ## get branch names
    ###################################################################################
    my $branches = GetBranches;
    my @branch_loop;
    my $branchname;

    foreach my $thisbranch (keys %$branches) {
        my %row =   (branchcode => $thisbranch,
                    branchname => $branches->{$thisbranch}->{'branchname'},
        );
        if ($thisbranch eq $branchcode) {
            $row{"selected"}=1;
            $branchname=$branches->{$thisbranch}->{'branchname'};
        }
        else {$row{"selected"}=0;}

        push @branch_loop, \%row;
    }


    ## get item types
    ###################################################################################
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("
    SELECT description,itemtype
    FROM itemtypes
    ORDER BY description");
    $sth->execute();

    my @itemtypeloop;

    while ( my $data = $sth->fetchrow_hashref ) {
        if ($data->{'itemtype'} eq $itemtype) {
            $data->{selected}=1;
            $itemtypedescription=$data->{'description'};
        }
        else { $data->{selected}=0;}
        push( @itemtypeloop, $data);
    }
    $sth->finish;


    ### get names
    ###################################################################################

    ## name of the person who 1st wrote the suggestion
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
    SELECT  firstname AS firstnamesuggestedby,
            surname AS surnamesuggestedby
    FROM borrowers
    WHERE borrowernumber=?
    ");
    $sth->execute($suggestion->{'suggestedby'});
    my $namesuggestedby = $sth->fetchrow_hashref;
    $sth->finish;

    ## name of the person who managed the suggestion in the General Purchase Department

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
    SELECT  firstname AS firstnamemanagedingpdby,
            surname AS surnamemanagedingpdby
    FROM borrowers
    WHERE borrowernumber=?
    ");
    $sth->execute($suggestion->{'suggestionmanagedingpdby'});
    my $namemanagedingpdby = $sth->fetchrow_hashref;
    $sth->finish;


    ## name of the person who managed the suggestion in a Purchase Department
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
    SELECT  firstname AS firstnamemanagedinpdby,
            surname AS surnamemanagedinpdby
    FROM borrowers
    WHERE borrowernumber=?
    ");
    $sth->execute($suggestion->{'suggestionmanagedinpdby'});
    my $namemanagedinpdby = $sth->fetchrow_hashref;
    $sth->finish;

    if ($chooseabookfund) {
        $template->param(chooseabookfund => $chooseabookfund,);
        warn "valeur de chooseabookfund = $chooseabookfund";
    }

    if ($chooseanaudience) {
        $template->param(chooseanaudience => $chooseanaudience,);
        warn "valeur de chooseanaudience = $chooseanaudience";
    }


    ## list of reasons why a suggestion can be rejected
    ###################################################################################

    my $reasons_loop = GetAuthorisedValues("SUGGEST");


################################################################################################
################################################################################################
### $template
################################################################################################
################################################################################################

    $template->param(

        ##argument en entrée du script

        ordernumber     => $ordernumber,

        ## other variables from 'aq2orders'
        ########################################################################################

        title           => $suggestion->{'title'},
        author          => $suggestion->{'author'},
        copyrightdate   => $suggestion->{'copyrightdate'},
        isbn            => $suggestion->{'isbn'},
        rrp             => $suggestion->{'rrp'},
        publishercode   => $suggestion->{'publishercode'},
        seriestitle     => $suggestion->{'seriestitle'},
        note            => $suggestion->{'note'},
        reason          => $suggestion->{'reason'},
        reasons_loop            => $reasons_loop,
        bookfundgroupnumber     => $bookfundgroupnumber,
        bookfundgroup_loop      => $bookfundgroupnumber,

        ## dates 'metric format'
        suggestioncreatedon  => format_date($suggestion->{'suggestioncreatedon'}),
        suggestionmanagedingpdon  => format_date($suggestion->{'suggestionmanagedingpdon'}),
        suggestionmanagedinpdon  => format_date($suggestion->{'suggestionmanagedinpdon'}),

        ## suggestions'status
        status          => $suggestion->{'status'},
        step2           => ($step==2)?1:0,
        step3           => ($step==3)?1:0,
        step3ormore        => ($step>=3)?1:0,
        rejected3       => (($suggestion->{'status'} eq "REJECTED") and ($step==3))?1:0,


        ## variables from other tables
        ########################################################################################

        ## loop variables
        bookfund_loop    => \@bookfund_loop,
        audience_loop    => \@audience_loop,
        branch_loop      => \@branch_loop,
        itemtypeloop    => \@itemtypeloop,

        ## names (person who 1st write the suggestion, persons who managed the suggestion)
        firstnamesuggestedby   => $namesuggestedby->{'firstnamesuggestedby'},
        surnamesuggestedby     => $namesuggestedby->{'surnamesuggestedby'},

        firstnamemanagedingpdby =>$namemanagedingpdby->{'firstnamemanagedingpdby'},
        surnamemanagedingpdby =>$namemanagedingpdby->{'surnamemanagedingpdby'},

        firstnamemanagedinpdby =>$namemanagedinpdby->{'firstnamemanagedinpdby'},
        surnamemanagedinpdby =>$namemanagedinpdby->{'surnamemanagedinpdby'},

        ## other variables
        branchname      => $branchname,
        bookfundgroupname => $bookfundgroupname,
        bookfundname    => $bookfundname,
        audiencename    => $audiencename,
        itemtypedescription => $itemtypedescription,

        template        => C4::Context->preference('template'),
    );

}


output_html_with_http_headers $input, $cookie, $template->output;
