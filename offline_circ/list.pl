#!/usr/bin/perl

# 2009 BibLibre <jeanandre.santoni@biblibre.com>

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
#

use strict;
use warnings;

use CGI;
use C4::Output;
use C4::Auth;
use C4::Koha;
use C4::Context;
use C4::Circulation;
use C4::Branch;
use C4::Members;
use C4::Biblio;

my $query = CGI->new;

my ($template, $loggedinuser, $cookie) = get_template_and_user({
    template_name => "offline_circ/list.tt",
    query => $query,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired   => { circulate => "circulate_remaining_permissions" },
});

my $operations = GetOfflineOperations;

for (@$operations) {
    my $biblio             = GetBiblioFromItemNumber(undef, $_->{'barcode'});
    $_->{'bibliotitle'}    = $biblio->{'title'};
    $_->{'biblionumber'}   = $biblio->{'biblionumber'};
    my $borrower           = GetMemberDetails(undef,$_->{'cardnumber'});
    if ($borrower) {
        $_->{'borrowernumber'} = $borrower->{'borrowernumber'};
        $_->{'borrower'}       = ($borrower->{'firstname'}?$borrower->{'firstname'}:'').' '.$borrower->{'surname'};
    }
    $_->{'actionissue'}    = $_->{'action'} eq 'issue';
    $_->{'actionreturn'}   = $_->{'action'} eq 'return';
    $_->{'actionpayment'}  = $_->{'action'} eq 'payment';
}
$template->param(pending_operations => $operations);

output_html_with_http_headers $query, $cookie, $template->output;
