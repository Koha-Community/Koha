#!/usr/bin/perl
# This code has been modified by Trendsetters (originally from circulation.pl)
use strict;
use CGI;

use C4::Auth;
use C4::Output;
use HTML::Template::Pro;

# begin code modifed by dan
my $query = new CGI;
my ($template, $borrowernumber, $cookie) 
#Begin code modified by Christina Lee
# function comes from C4::Auth
    = get_template_and_user({template_name => "sco/help.tmpl",
#End code modified by Christina Lee
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {circulate => "circulate_remaining_permissions"},
			     debug => 1,
			     });
# end code modified by dan


# function comes from C4::Interface::CGI::Output
output_html_with_http_headers $query, $cookie, $template->output;

