#!/usr/bin/perl
#

use Modern::Perl;

use CGI;
use JSON;

use C4::Auth;
use C4::Circulation qw/CanBookBeRenewed/;
use C4::Context;
use C4::Koha qw/getitemtypeimagelocation/;
use C4::Reserves qw/CheckReserves/;
use C4::Utils::DataTables;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Koha;
use C4::Branch;    # GetBranches
use C4::Reports::Guided;    #_get_column_defs
use C4::Charset;
use List::MoreUtils qw /none/;


my $input = new CGI;

# Authentication
my ($status, $cookie, $sessionId) = C4::Auth::check_api_auth($input, { tools => 'inventory' });
exit unless ($status eq "ok");


my $seen = $input->param('seen');
my @seent = split(/\|/, $seen);

# mark seen if applicable (ie: coming form mark seen checkboxes)
foreach ( @seent ) {
    /SEEN-(.+)/ and &ModDateLastSeen($1);
}


print $input->header('application/json');

