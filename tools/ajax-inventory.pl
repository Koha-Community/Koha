#!/usr/bin/perl

use Modern::Perl;
use CGI       qw ( -utf8 );
use C4::Auth  qw( check_api_auth );
use C4::Items qw( ModDateLastSeen );

my $input = CGI->new;

# Authentication
my ( $status, $cookie, $sessionId ) = C4::Auth::check_api_auth( $input, { tools => 'inventory' } );
exit unless ( $status eq "ok" );

my $op = $input->param('op') // q{};

if ( $op eq 'cud-seen' ) {
    my $seen  = $input->param('seen');
    my @seent = split( /\|/, $seen );

    # mark seen if applicable (ie: coming form mark seen checkboxes)
    foreach (@seent) {
        /SEEN-(.+)/ and &ModDateLastSeen($1);
    }
}

print $input->header('application/json');
