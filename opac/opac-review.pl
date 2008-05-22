#!/usr/bin/perl

# Copyright 2006 Katipo Communications
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
use warnings;
use CGI;
use C4::Auth;
use C4::Koha;
use C4::Output;
use C4::Review;
use C4::Biblio;
use C4::Scrubber;
use C4::Debug;

my $query        = new CGI;
my $biblionumber = $query->param('biblionumber');
my $review       = $query->param('review');
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-review.tmpl",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    }
);

# FIXME: need to allow user to delete their own comment(s)

my $biblio = GetBiblioData($biblionumber);
my $savedreview = getreview($biblionumber,$borrowernumber);
my ($clean, @errors);
if (defined $review) {
	if ($review !~ /\S/) {
		push @errors, {empty=>1};
	} else {
		$clean = C4::Scrubber->new('comment')->scrub($review);
		if ($clean !~ /\S/) {
			push @errors, {scrubbed_all=>1};
		} else {
			if ($clean ne $review) {
				push @errors, {scrubbed=>$clean};
				my $js_ok_review = $clean;
				$js_ok_review =~ s/"/&quot;/g;	# probably redundant w/ TMPL ESCAPE=JS
				$template->param(clean_review=>$js_ok_review);
			}
			if ($savedreview) {
    			updatereview($biblionumber, $borrowernumber, $clean);
			} else {
    			savereview($biblionumber, $borrowernumber, $clean);
			}
			unless (@errors){ $template->param(WINDOW_CLOSE=>1); }
		}
	}
}
(@errors   ) and $template->param(   ERRORS=>\@errors);
($cgi_debug) and $template->param(cgi_debug=>1       );
$template->param(
    'biblionumber'   => $biblionumber,
    'borrowernumber' => $borrowernumber,
    'review'         => $clean || $savedreview->{'review'},
	'reviewid'       => $query->param('reviewid') || 0,
    'title'          => $biblio->{'title'},
);

output_html_with_http_headers $query, $cookie, $template->output;

