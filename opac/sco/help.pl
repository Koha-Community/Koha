#!/usr/bin/perl
#
# This code  (originally from circulation.pl) has been modified by:
#   Trendsetters, 
#   dan, and
#   Christina Lee.

use strict;
use warnings;
use CGI;

use C4::Auth   qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);

my $query = new CGI;
my ($template, $borrowernumber, $cookie) = get_template_and_user({
    template_name => "sco/help.tmpl",
    query => $query,
     type => "opac",
    debug => 1,
    authnotrequired => 1,
      flagsrequired => {circulate => "circulate_remaining_permissions"},
});

output_html_with_http_headers $query, $cookie, $template->output;

