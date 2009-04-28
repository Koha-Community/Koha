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


=head1 NAME

acceptorreject.pl

=head1 DESCRIPTION

this script modify the status of a subscription to ACCEPTED or to REJECTED

=head1 PARAMETERS

=over 4

=item op

op can be :
 * aorr_confirm : to confirm accept or reject
 * accepted : to display only accepted.
 * rejected : to display only rejected.

=back


=cut

## modules
###################################################################################

use strict;
require Exporter;
use CGI;

use C4::Auth;    # get_template_and_user
use C4::Output;
use C4::Suggestions;
use C4::Koha;    # GetAuthorisedValue
use C4::Dates qw/format_date format_date_in_iso/;


## variables
###################################################################################

## input variables
my $input           = new CGI;
my $bookfundgroupnumber = $input->param('bookfundgroupnumber');
my $op              = $input->param('op') || "aorr_confirm";

## other variables
my $bookfundgroupname;
my @suggestions_loop;

my $dbh = C4::Context->dbh;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "suggestion/acceptorrejectpd.tmpl",
        type            => "intranet",
        query           => $input,
        authnotrequired => 1,
        flagsrequired   => { catalogue => 1 },
    }
);

my $suggestion_loop0;


###################################################################################
###################################################################################
## modify suggestions'status. Choose a list of suggestions
###################################################################################
###################################################################################


if ( $op eq "aorr_confirm" ) {

## modify suggestions'status
###################################################################################

    my @suggestionlist = $input->param("aorr");

    foreach my $suggestion (@suggestionlist) {
        if ( $suggestion =~ /(A|R)(.*)/ ) {

            my ( $newstatus, $ordernumber ) = ( $1, $2 );
            $newstatus = "REJECTED" if $newstatus eq "R";
            $newstatus = "ACCEPTED" if $newstatus eq "A";
            my $reason = $input->param( "reason" . $ordernumber );
            if ( $reason eq "other" ) {
                $reason = $input->param( "other-reason" . $ordernumber );
            }

            my $bookfundnumber = $input->param( "bookfunds_loop".$ordernumber);
            my $step = $input->param( "step".$ordernumber);

            ModStatus(
                $ordernumber,
                $newstatus,
                $reason,
                $bookfundgroupnumber,
                $bookfundnumber,
                $loggedinuser,
                $step,
                '',
                $input,
                );
        }
    }
    $op = "else";
    $suggestion_loop0 = &SearchSuggestion("", "", "", "", 'ASKED', "","",2,$bookfundgroupnumber);
}


if ( $op eq "accepted" ) {

## accepted suggestions
###################################################################################

    $suggestion_loop0 = &GetSuggestionByStatus('ACCEPTED',3,$bookfundgroupnumber);
    $template->param(done => 1);
}


if ( $op eq "rejected" ) {

## rejected suggestions
###################################################################################

    $suggestion_loop0 = &GetSuggestionByStatus('REJECTED',3,$bookfundgroupnumber);
    $template->param(done => 1);
}


## book fund group name
#########################################################################################
my $dbh = C4::Context->dbh;
my $sth = $dbh->prepare("
SELECT bookfundgroupname
FROM aq2bookfundgroups
WHERE bookfundgroupnumber=?
");
$sth->execute($bookfundgroupnumber);
my $data = $sth->fetchrow_hashref;
$bookfundgroupname = $data->{'bookfundgroupname'};
$sth->finish;



foreach my $suggestion (@$suggestion_loop0) {

###################################################################################
###################################################################################
## get more information about suggestions
###################################################################################
###################################################################################


    ## reasonsloop
    $suggestion->{'reasonsloop'} = GetAuthorisedValues("SUGGEST");

    ## dates
    $suggestion->{'suggestioncreatedon'} = format_date($suggestion->{'suggestioncreatedon'});
    $suggestion->{'suggestionmanagedingpdon'} = format_date($suggestion->{'suggestionmanagedingpdon'});
    $suggestion->{'suggestionmanagedinpdon'} =
    format_date($suggestion->{'suggestionmanagedinpdon'});


    ## bookfunds_loop
    ###############################################################################
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
    SELECT bookfundnumber, bookfundname
    FROM aq2bookfunds
    WHERE bookfundgroupnumber=?
    ORDER BY bookfundname
    ");
    $sth->execute($bookfundgroupnumber);

    my @bookfunds_loop;

    while (my $data = $sth->fetchrow_hashref) {

        ## book fund number of the suggestion
        $data->{selected}=($data->{'bookfundnumber'} eq $suggestion->{'bookfundnumber'})? 1:0;

        ## book fund name of the suggestion
        if ($data->{'bookfundnumber'} eq $suggestion->{'bookfundnumber'}) {
            $suggestion->{'bookfundname'} = $data->{'bookfundname'};
        }

        push( @bookfunds_loop, $data);
    }
    $sth->finish;

    $suggestion->{'bookfunds_loop'} = \@bookfunds_loop;


    ## name of the person who managed the suggestion in the General Purchase Department
    ###################################################################################

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
    $suggestion->{'firstnamemanagedingpdby'} = $namemanagedingpdby->{'firstnamemanagedingpdby'};
    $suggestion->{'surnamemanagedingpdby'} = $namemanagedingpdby->{'surnamemanagedingpdby'};


    ## name of the person who managed the suggestion in a Purchase Department
    ###################################################################################
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
    $suggestion->{'firstnamemanagedinpdby'} = $namemanagedinpdby->{'firstnamemanagedinpdby'};
    $suggestion->{'surnamemanagedinpdby'} = $namemanagedinpdby->{'surnamemanagedinpdby'};


    ## insert the suggestion into the table of suggestions
    ################################################################################
    push @suggestions_loop, $suggestion ;


###################################################################################
## $template
###################################################################################
}

$template->param(
    suggestions_loop        => \@suggestions_loop,
    bookfundgroupnumber     => $bookfundgroupnumber,
    bookfundgroupname       => $bookfundgroupname,
    "op_$op"                => 1,
);

output_html_with_http_headers $input, $cookie, $template->output;