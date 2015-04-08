#!/usr/bin/perl

# Displays sent notices for a given borrower

# Copyright (c) 2009 BibLibre
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

use strict;
#use warnings; FIXME - Bug 2505
use C4::Auth;
use C4::Output;
use CGI;
use C4::Members;
use C4::Branch;
use C4::Letters;
use C4::Members::Attributes qw(GetBorrowerAttributes);

use C4::Dates qw/format_date/;
my $input=new CGI;


my $borrowernumber = $input->param('borrowernumber');
#get borrower details
my $borrower = GetMember(borrowernumber => $borrowernumber);

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "members/notices.tt",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});

$template->param( $borrower );
my ($picture, $dberror) = GetPatronImage($borrower->{'borrowernumber'});
$template->param( picture => 1 ) if $picture;

# Getting the messages
my $queued_messages = C4::Letters::GetQueuedMessages({borrowernumber => $borrowernumber});
$template->param( %{$borrower} );

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my $attributes = GetBorrowerAttributes($borrowernumber);
    $template->param(
        ExtendedPatronAttributes => 1,
        extendedattributes => $attributes
    );
}

# Computes full borrower address
my $roadtype = C4::Koha::GetAuthorisedValueByCode( 'ROADTYPE', $borrower->{'streettype'} );
my $address = $borrower->{'streetnumber'} . " $roadtype " . $borrower->{'address'};

$template->param(
			QUEUED_MESSAGES 	=> $queued_messages,
			borrowernumber 		=> $borrowernumber,
			sentnotices 		=> 1,
                        branchname              => GetBranchName($borrower->{'branchcode'}),
                        categoryname            => $borrower->{'description'},
                        address                 => $address,
			activeBorrowerRelationship => (C4::Context->preference('borrowerRelationship') ne ''),
            RoutingSerials => C4::Context->preference('RoutingSerials'),
);
output_html_with_http_headers $input, $cookie, $template->output;

