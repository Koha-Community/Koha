package C4::Interface::CGI::Output;

# $Id$

#package to work around problems in HTTP headers
# Note: This is just a utility module; it should not be instantiated.


# Copyright 2003 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
use strict;
require Exporter;
use open ':utf8';
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::CGI::Output - Convenience functions for handling outputting HTML pages

=head1 SYNOPSIS

  use C4::Interface::CGI::Output;

  print $query->header(-type => "text/html"), $output;

=head1 DESCRIPTION

The functions in this module peek into a piece of HTML and return strings
related to the (guessed) charset.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(	&output_html_with_http_headers
		);





=item output_html_with_http_headers

   &output_html_with_http_headers($query, $cookie, $html)

Outputs the HTML page $html with the appropriate HTTP headers,
with the authentication cookie $cookie and a Content-Type that
corresponds to the HTML page $html.

=cut

sub output_html_with_http_headers ($$$) {

    my($query, $cookie, $html) = @_;
    print $query->header(
	-type   => "text/html",
	-charset=>"UTF-8",
	-cookie => $cookie,
  ), $html;
}

#---------------------------------

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
