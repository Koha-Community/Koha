#!/usr/bin/perl
# WARNING: 4-character tab stops here

# Copyright 2000-2002 Katipo Communications
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
use CGI;
use C4::Auth;
use HTML::Template;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::SearchMarc;
use C4::Koha; # XXX subfield_is_koha_internal_p

my $query=new CGI;
my $type=$query->param('type');
my $op = $query->param('op');
#$type="opac" unless $type;

my $dbh = C4::Context->dbh;

my ($loggedinuser, $cookie, $sessionID) = checkauth($query, ($type eq 'opac') ? (1) : (0));

my $startfrom=$query->param('startfrom');
($startfrom) || ($startfrom=0);
my ($template, $loggedinuser, $cookie);

if ($op eq "do_search") {
	my @marclist = $query->param('marclist');
	my @and_or = $query->param('and_or');
	my @excluding = $query->param('excluding');
	my @operator = $query->param('operator');
	my @value = $query->param('value');
	# builds tag and subfield arrays
	my @tags;
	my @subfields;
	foreach my $marc (@marclist) {
		push @tags, substr($marc,0,3);
		push @subfields, substr($marc,3,1);
	}
	my @results = catalogsearch($dbh, \@tags, \@subfields, \@and_or, 
											\@excluding, \@operator, \@value, 
											$startfrom, 20);
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "search.marc/result.tmpl",
				query => $query,
				type => $type,
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
	$template->param(loggedinuser => $loggedinuser,
							result => \@results);

} else {
	($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "search.marc/search.tmpl",
				query => $query,
				type => $type,
				authnotrequired => 0,
				flagsrequired => {catalogue => 1},
				debug => 1,
				});
	$template->param(loggedinuser => $loggedinuser);
	my $tagslib;
	if ($type eq "opac") {
		$tagslib = &MARCgettagslib($dbh,1);
	} else {
		$tagslib = &MARCgettagslib($dbh,1);
	}
	my @marcarray;
	push @marcarray,"";
	my $widest_menu_item_width = 0;
	for (my $pass = 1; $pass <= 2; $pass += 1) {
		for (my $tabloop = 0; $tabloop<=9;$tabloop++) {
			my $separator_inserted_p = 0; # FIXME... should not use!!
			foreach my $tag (sort(keys (%{$tagslib}))) {
				foreach my $subfield (sort(keys %{$tagslib->{$tag}})) {
					next if subfield_is_koha_internal_p($subfield);
					next unless ($tagslib->{$tag}->{$subfield}->{tab} eq $tabloop);
					my $menu_item = "$tag$subfield - $tagslib->{$tag}->{$subfield}->{lib}";
					if ($pass == 1) {
						$widest_menu_item_width = length $menu_item
								if $widest_menu_item_width < length $menu_item;
					} else {
						if (!$separator_inserted_p) {
							my $w = int(($widest_menu_item_width - 3 + 0.5)/2);
							my $s = ('-' x ($w * 4/5));
							push @marcarray,  "$s $tabloop $s";
							$separator_inserted_p = 1;
						}
						push @marcarray, $menu_item;
					}
				}
			}
		}
	}
	my $marclist = CGI::scrolling_list(-name=>"marclist",
					-values=> \@marcarray,
					-size=>1,
					-multiple=>0,
					-onChange => "sql_update()",
					);
	$template->param("marclist" => $marclist);
}
# Print the page
output_html_with_http_headers $query, $cookie, $template->output;


# Local Variables:
# tab-width: 4
# End:
