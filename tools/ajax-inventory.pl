#!/usr/bin/perl

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Auth;
use C4::Items qw( ModDateLastSeen );

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
