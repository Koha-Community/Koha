#!/usr/bin/perl

use Modern::Perl;
use CGI qw ( -utf8 );

use C4::Auth;
use C4::Context;
use C4::Output;
use C4::ShelfBrowser;

my $cgi = new CGI;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "svc/shelfbrowser.tt",
        query           => $cgi,
        type            => "opac",
        authnotrequired => ( C4::Context->preference("OpacPublic") ? 1 : 0 ),
    }
);

# Shelf Browser Stuff
if (C4::Context->preference("OPACShelfBrowser")) {
    my $starting_itemnumber = $cgi->param('shelfbrowse_itemnumber');
    if (defined($starting_itemnumber)) {
        my $nearby = GetNearbyItems($starting_itemnumber);

        $template->param(
            starting_homebranch => $nearby->{starting_homebranch}->{description},
            starting_location => $nearby->{starting_location}->{description},
            starting_ccode => $nearby->{starting_ccode}->{description},
            shelfbrowser_prev_item => $nearby->{prev_item},
            shelfbrowser_next_item => $nearby->{next_item},
            shelfbrowser_items => $nearby->{items},
            OpenOPACShelfBrowser => 1,
        );
    }
}

output_html_with_http_headers $cgi, $cookie, $template->output;
