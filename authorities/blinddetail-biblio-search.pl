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

=head1 NAME

etail.pl : script to show an authority in MARC format

=head1 SYNOPSIS


=head1 DESCRIPTION

This script needs an authid

It shows the authority in a (nice) MARC format depending on authority MARC
parameters tables.

=head1 FUNCTIONS

=over 2

=cut


use strict;
require Exporter;
use C4::AuthoritiesMarc;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use MARC::Record;
use C4::Koha;
use HTML::Template;

my $query=new CGI;

my $dbh=C4::Context->dbh;

my $authid = $query->param('authid');
my $index = $query->param('index');
my $authtypecode = &AUTHfind_authtypecode($dbh,$authid);
my $tagslib = &AUTHgettagslib($dbh,1,$authtypecode);

my $auth_type = AUTHgetauth_type($authtypecode);
# warn "XX = ".$auth_type->{auth_tag_to_report};

my $record =AUTHgetauthority($dbh,$authid);
# open template
my ($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "authorities/blinddetail-biblio-search.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

# fill arrays
my @loop_data =();
my $tag;
my @loop_data =();
if ($authid) {
warn "report $authtypecode => ".$auth_type->{auth_tag_to_report}.$record->as_formatted;
	foreach my $field ($record->field($auth_type->{auth_tag_to_report})) {
			my @subfields_data;
			my @subf=$field->subfields;
		# loop through each subfield
		for my $i (0..$#subf) {
			$subf[$i][0] = "@" unless $subf[$i][0];
			my %subfield_data;
			$subfield_data{marc_value}=$subf[$i][1];
			$subfield_data{marc_subfield}=$subf[$i][0];
			$subfield_data{marc_tag}=$field->tag();
			push(@subfields_data, \%subfield_data);
		}
		if ($#subfields_data>=0) {
			my %tag_data;
			$tag_data{tag}=$field->tag().' -'. $tagslib->{$field->tag()}->{lib};
			$tag_data{subfield} = \@subfields_data;
			push (@loop_data, \%tag_data);
		}
	}
} else {
# authid is empty => the user want to empty the entry.
	my @subfields_data;
	foreach my $subfield ('a'..'z') {
			my %subfield_data;
			$subfield_data{marc_value}='';
			$subfield_data{marc_subfield}=$subfield;
			push(@subfields_data, \%subfield_data);
		}
# 	if ($#subfields_data>=0) {
		my %tag_data;
# 			$tag_data{tag}=$field->tag().' -'. $tagslib->{$field->tag()}->{lib};
		$tag_data{subfield} = \@subfields_data;
		push (@loop_data, \%tag_data);
# 	}
}

$template->param("0XX" =>\@loop_data);

# my $authtypes = getauthtypes;
# my @authtypesloop;
# foreach my $thisauthtype (keys %$authtypes) {
# 	my $selected = 1 if $thisauthtype eq $authtypecode;
# 	my %row =(value => $thisauthtype,
# 				selected => $selected,
# 				authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
# 			);
# 	push @authtypesloop, \%row;
# }

$template->param(authid => $authid?$authid:"",
# 				authtypesloop => \@authtypesloop,
				index => $index);
output_html_with_http_headers $query, $cookie, $template->output;

