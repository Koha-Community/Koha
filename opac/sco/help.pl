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

if (C4::Context->preference('SelfCheckoutByLogin')) {
    $template->param(SelfCheckoutByLogin => 1);
}
my $selfchecktimeout = 120;
if (C4::Context->preference('SelfCheckTimeout')) {
   $selfchecktimeout = C4::Context->preference('SelfCheckTimeout');
}

$template->param(SelfCheckTimeout => $selfchecktimeout);

if (C4::Context->preference('SelfCheckHelpMessage')) {
    $template->param(SelfCheckHelpMessage => C4::Context->preference('SelfCheckHelpMessage'));
}

output_html_with_http_headers $query, $cookie, $template->output;

