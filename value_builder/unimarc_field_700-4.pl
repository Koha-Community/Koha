#!/usr/bin/perl

# written 10/5/2002 by Paul

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
use CGI;
use C4::Context;
use HTML::Template;
use C4::Search;
use C4::Output;

=head1 NAME

plugin unimarc_field_700-4

=head1 SYNOPSIS

This plug-in deals with unimarc field 700-4 (

=head1 DESCRIPTION

=head1 FUNCTIONS

=over 2

=cut

sub plugin_parameters {
my ($dbh,$record,$tagslib,$morethan,$begin_tabloop) = @_;
my $index2; # the resulting index
my $i;		# counter
# loop to find 700$a subfield. We look for the 1st after $i
for (my $tabloop = $begin_tabloop; $tabloop<=9;$tabloop++) {
	my @loop_data =();
	foreach my $tag (keys %{$tagslib}) {
# loop through each subfield
		foreach my $subfield (keys %{$tagslib->{$tag}}) {
			next if ($subfield eq 'lib'); # skip lib and tabs, which are koha internal
			next if ($subfield eq 'tab');
			next if ($tagslib->{$tag}->{$subfield}->{tab}  ne $tabloop);
			if ($tag eq '700' && $subfield eq 'a' && $i>$morethan) {
				$index2 = $i;
			}
			$i++;
		}
	}
}
#	my $index2=6;
	return "&index2=$index2";
}

sub plugin_javascript {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return ("","");
}

sub plugin {
my ($input) = @_;
	my %env;

#	my $input = new CGI;
	my $index= $input->param('index');
	my $index2= $input->param('index2');
	$index2=-1 unless($index2);
	my $result= $input->param('result');


	my $dbh = C4::Context->dbh;

	my $template = gettemplate("value_builder/unimarc_field_700-4.tmpl",0);
	$template->param(index => $index,
							index2 => $index2,
							"f1_$result" => "f1_".$result,
							);
	print "Content-Type: text/html\n\n", $template->output;
}

1;
