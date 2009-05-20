#!/usr/bin/perl

# Copyright 2008 LibLime
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
use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Members::Messaging;
use C4::Dates;
use C4::Reserves;
use C4::Circulation;
use C4::Koha;
use C4::Letters;
use C4::Biblio;
use C4::Reserves;
use C4::Branch; # GetBranchName
use C4::Form::MessagingPreferences;

use Data::Dumper;

use vars qw($debug);

BEGIN {
	$debug = $ENV{DEBUG} || 0;
}

my $dbh = C4::Context->dbh;

my $query = CGI->new();

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => 'members/messaging.tmpl',
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { borrowers => 1 },
        debug           => 1,
    }
);
my $borrowernumber = $query->param('borrowernumber');
my $borrower       = GetMember( $borrowernumber ,'borrowernumber');
my $branch         = C4::Context->userenv->{'branch'};

$template->param( $borrower );

my $borrower = GetMemberDetails( $borrowernumber );

if ( defined $query->param('modify') && $query->param('modify') eq 'yes' ) {

    # If they've modified the SMS number, record it.
    if ( ( defined $query->param('SMSnumber') ) && ( $query->param('SMSnumber') ne $borrower->{'mobile'} ) ) {
        ModMember( borrowernumber => $borrowernumber,
                   smsalertnumber => $query->param('SMSnumber') );
        $borrower = GetMemberDetails( $borrowernumber );
    }
    C4::Form::MessagingPreferences::handle_form_action($query, { borrowernumber => $borrowernumber }, $template);
} 

C4::Form::MessagingPreferences::set_form_values({ borrowernumber => $borrowernumber }, $template);

    if ( $borrower->{'category_type'} eq 'C') {
        my  ( $catcodes, $labels ) =  GetborCatFromCatType( 'A', 'WHERE category_type = ?' );
        my $cnt = scalar(@$catcodes);
        $template->param( 'CATCODE_MULTI' => 1) if $cnt > 1;
        $template->param( 'catcode' =>    $catcodes->[0])  if $cnt == 1;
    }
	
my ($picture, $dberror) = GetPatronImage($borrower->{'cardnumber'});
$template->param( picture => 1 ) if $picture;

# get some recent messages sent to this borrower for display:
my $message_queue = C4::Letters::GetQueuedMessages( { borrowernumber => $query->param('borrowernumber') } );

$template->param( messagingview               => 1,
                  message_queue               => $message_queue,
                  DHTMLcalendar_dateformat    => C4::Dates->DHTMLcalendar(), 
                  borrowernumber              => $borrowernumber,
                  branchcode                  => $borrower->{'branchcode'},
                  branchname		      => GetBranchName($borrower->{'branchcode'}),
                  dateformat                  => C4::Context->preference("dateformat"),
                  categoryname                => $borrower->{'description'},
                  $borrower->{'categorycode'} => 1,
                  SMSSendDriver                =>  C4::Context->preference("SMSSendDriver")
);

#$messaging_preferences->{'SMSnumber'}{'value'} = defined $borrower->{'smsalertnumber'}
#  ? $borrower->{'smsalertnumber'} : $borrower->{'mobile'};

$template->param( BORROWER_INFO         => [ $borrower ],
                  messagingview         => 1,
				  is_child        => ($borrower->{'category_type'} eq 'C'),
                  SMSnumber             => defined $borrower->{'smsalertnumber'} ? $borrower->{'smsalertnumber'} : $borrower->{'mobile'} );

output_html_with_http_headers $query, $cookie, $template->output;
