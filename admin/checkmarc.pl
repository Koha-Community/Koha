#!/usr/bin/perl


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
use C4::Output;
use C4::Auth;
use CGI;
use C4::Context;
use C4::Biblio;


my $input = new CGI;

my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "admin/checkmarc.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });

my $dbh = C4::Context->dbh;
my $total = 0;
# checks itemnum field
my $sth = $dbh->prepare("select tab from marc_subfield_structure where kohafield=\"items.itemnumber\"");
$sth->execute;
my ($res) = $sth->fetchrow;
if ($res==-1) {
	$template->param(itemnum => 0);
} else {
	$template->param(itemnum => 1);
	$total++;
}

# checks biblio.biblionumber and biblioitem.biblioitemnumber (same tag and tab=-1)
$sth = $dbh->prepare("select tagfield,tab from marc_subfield_structure where kohafield=\"biblio.biblionumber\"");
$sth->execute;
my $tab;
($res,$tab) = $sth->fetchrow;
$sth = $dbh->prepare("select tagfield,tab from marc_subfield_structure where kohafield=\"biblioitems.biblioitemnumber\"");
$sth->execute;
my ($res2,$tab2) = $sth->fetchrow;
if ($res && $res2 && $tab==-1 && $tab2==-1) {
	$template->param(biblionumber => 0);
} else {
	$template->param(biblionumber => 1);
	$total++;
}

# checks all item fields are in the same tag and in tab 10

$sth = $dbh->prepare("select tagfield,tab,kohafield from marc_subfield_structure where kohafield like \"items.%\" and tab >=0");
$sth->execute;
my $field;
($res,$res2,$field) = $sth->fetchrow;
my $tagfield = $res;
$tab = $res2;
my $subtotal=0;
#warn "TAGF : $tagfield";
while (($res,$res2,$field) = $sth->fetchrow) {
	# (ignore itemnumber, that must be in -1 tab)
	if (($res ne $tagfield) or ($res2 ne $tab)) {
		$subtotal++;
	}
}
$sth = $dbh->prepare("select kohafield from marc_subfield_structure where tagfield=?");
$sth->execute($tagfield);
while (($res2) = $sth->fetchrow) {
	if (!$res2 || $res2 =~ /^items/) {
	} else {
		$subtotal++;
	}
}
if ($subtotal == 0) {
	$template->param(itemfields => 0);
} else {
	$template->param(itemfields => 1);
	$total++;
}

$sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where tab = 10");
$sth->execute;
my $totaltags = 0;
my $list = "";
while (($res2) = $sth->fetchrow) {
	$totaltags++;
	$list.=$res2.",";
}
if ($totaltags > 1) {
	$template->param(itemtags => $list);
	$total++;
} else {
	$template->param(itemtags => 0);
}


# checks biblioitems.itemtype must be mapped and use authorised_value=itemtype
$sth = $dbh->prepare("select tagfield,tab,authorised_value from marc_subfield_structure where kohafield = \"biblioitems.itemtype\"");
$sth->execute;
($res,$res2,$field) = $sth->fetchrow;
if ($res && $res2>=0 && $field eq "itemtypes") {
	$template->param(itemtype => 0);
} else {
	$template->param(itemtype => 1);
	$total++;
}

# checks items.homebranch must be mapped and use authorised_value=branches
$sth = $dbh->prepare("select tagfield,tab,authorised_value from marc_subfield_structure where kohafield = \"items.homebranch\"");
$sth->execute;
($res,$res2,$field) = $sth->fetchrow;
if ($res && $res2 eq 10 && $field eq "branches") {
	$template->param(branch => 0);
} else {
	$template->param(branch => 1);
	$total++;
}
# checks items.homebranch must be mapped and use authorised_value=branches
$sth = $dbh->prepare("select tagfield,tab,authorised_value from marc_subfield_structure where kohafield = \"items.holdingbranch\"");
$sth->execute;
($res,$res2,$field) = $sth->fetchrow;
if ($res && $res2 eq 10 && $field eq "branches") {
	$template->param(holdingbranch => 0);
} else {
	$template->param(holdingbranch => 1);
	$total++;
}

# checks that itemtypes & branches tables are not empty
$sth = $dbh->prepare("select count(*) from itemtypes");
$sth->execute;
($res) = $sth->fetchrow;
if ($res) {
	$template->param(itemtypes_empty =>0);
} else {
	$template->param(itemtypes_empty =>1);
	$total++;
}


$sth = $dbh->prepare("select count(*) from branches");
$sth->execute;
($res) = $sth->fetchrow;
if ($res) {
	$template->param(branches_empty =>0);
} else {
	$template->param(branches_empty =>1);
	$total++;
}

$sth = $dbh->prepare("select count(*) from marc_subfield_structure where frameworkcode is NULL");
$sth->execute;
($res) = $sth->fetchrow;
if ($res) {
	$template->param(frameworknull =>1);
	$total++;
}
$sth = $dbh->prepare("select count(*) from marc_tag_structure where frameworkcode is NULL");
$sth->execute;
($res) = $sth->fetchrow;
if ($res) {
	$template->param(frameworknull =>1);
	$total++;
}

# verify that all of a field's subfields (except the ones explicitly ignore) 
# are in the same tab
$sth = $dbh->prepare("SELECT tagfield, frameworkcode, frameworktext, GROUP_CONCAT(DISTINCT tab) AS tabs
                      FROM marc_subfield_structure
                      LEFT JOIN biblio_framework USING (frameworkcode)
                      WHERE tab != -1
                      GROUP BY tagfield, frameworkcode, frameworktext
                      HAVING COUNT(DISTINCT tab) > 1");
$sth->execute;
my $inconsistent_tabs = $sth->fetchall_arrayref({});
if (scalar(@$inconsistent_tabs) > 0) {
    $total++;
    $template->param(inconsistent_tabs => 1);
    $template->param(tab_info => $inconsistent_tabs);
}

$template->param(total => $total,
		);

output_html_with_http_headers $input, $cookie, $template->output;
