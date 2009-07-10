#!/usr/bin/perl

use warnings;
use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Labels;
use C4::Output;
use C4::Context;
use HTML::Template::Pro;

# use Smart::Comments;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "labels/spinelabel-home.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
        debug           => 1,
    }
);

output_html_with_http_headers $query, $cookie, $template->output;
