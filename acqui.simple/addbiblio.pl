#!/usr/bin/perl

# $Id$

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
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use HTML::Template;
use MARC::File::USMARC;

use vars qw( $tagslib );
use vars qw( $is_a_modif );


=item find_value

    ($indicators, $value) = find_value($tag, $subfield, $record);

Find the given $subfield in the given $tag in the given
MARC::Record $record.  If the subfield is found, returns
the (indicators, value) pair; otherwise, (undef, undef) is
returned.

=cut

sub find_value {
	my ($tagfield,$insubfield,$record) = @_;
#	warn "$tagfield / $insubfield // ";
	my $result;
	my $indicator;
	foreach my $field ($record->field($tagfield)) {
		my @subfields = $field->subfields();
		foreach my $subfield (@subfields) {
			if (@$subfield[0] eq $insubfield) {
				$result .= @$subfield[1];
				$indicator = $field->indicator(1).$field->indicator(2);
			}
		}
	}
	return($indicator,$result);
}


=item find_value

    $record = MARCfindbreeding($dbh, $breedingid);

Look up the breeding farm with database handle $dbh, for the
record with id $breedingid.  If found, returns the decoded
MARC::Record; otherwise, -1 is returned (FIXME).

=cut

sub MARCfindbreeding {
	my ($dbh,$id) = @_;
	my $sth = $dbh->prepare("select file,marc from marc_breeding where id=?");
	$sth->execute($id);
	my ($file,$marc) = $sth->fetchrow;
	if ($marc) {
		my $record = MARC::File::USMARC::decode($marc);
		if (ref($record) eq undef) {
			return -1;
		} else {
			return $record;
		}
	}
	return -1;
}


=item build_authorized_values_list

=cut

sub build_authorized_values_list ($$$$$) {
    my($tag, $subfield, $value, $dbh, $authorised_values_sth) = @_;

    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...

    #---- branch
    if ($tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
	my $sth=$dbh->prepare("select branchcode,branchname from branches");
	$sth->execute;
	push @authorised_values, ""
		unless ($tagslib->{$tag}->{$subfield}->{mandatory});

	while (my ($branchcode,$branchname) = $sth->fetchrow_array) {
	    push @authorised_values, $branchcode;
	    $authorised_lib{$branchcode}=$branchname;
	}

    #----- itemtypes
    } elsif ($tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes") {
	my $sth=$dbh->prepare("select itemtype,description from itemtypes");
	$sth->execute;
	push @authorised_values, ""
		unless ($tagslib->{$tag}->{$subfield}->{mandatory});

	while (my ($itemtype,$description) = $sth->fetchrow_array) {
	    push @authorised_values, $itemtype;
	    $authorised_lib{$itemtype}=$description;
	}

    #---- "true" authorised value
    } else {
	$authorised_values_sth->execute
		($tagslib->{$tag}->{$subfield}->{authorised_value});

	push @authorised_values, ""
		unless ($tagslib->{$tag}->{$subfield}->{mandatory});

	while (my ($value,$lib) = $authorised_values_sth->fetchrow_array) {
	    push @authorised_values, $value;
	    $authorised_lib{$value}=$lib;
	}
    }
    return CGI::scrolling_list( -name     => 'field_value',
				-values   => \@authorised_values,
				-default  => $value,
				-labels   => \%authorised_lib,
				-size     => 1,
				-multiple => 0 );
}

sub build_tabs ($$$) {
    my($template, $record, $dbh) = @_;

    # fill arrays
    my @loop_data =();
    my $tag;
    my $i=0;
    my $authorised_values_sth = $dbh->prepare("select authorised_value,lib
	from authorised_values
	where category=? order by authorised_value");

    # loop through each tab 0 through 9
    for (my $tabloop = 0; $tabloop <= 9; $tabloop++) {
    #	my @fields = $record->fields();
	my @loop_data = ();
	foreach my $tag (sort(keys (%{$tagslib}))) {
	    my $previous_tag = '';
	    my @subfields_data;
	    my $indicator;

	    # loop through each subfield
	    foreach my $subfield (sort(keys %{$tagslib->{$tag}})) {
		next if subfield_is_koha_internal_p($subfield);
		next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
		my %subfield_data;
		$subfield_data{tag}=$tag;
		$subfield_data{subfield}=$subfield;
		$subfield_data{marc_lib}="<DIV id=\"error$i\">".$tagslib->{$tag}->{$subfield}->{lib}."</div>";
		$subfield_data{tag_mandatory}=$tagslib->{$tag}->{mandatory};
		$subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
		$subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
		# if breeding is not empty
		if ($record ne -1) {
		    my ($x,$value) = find_value($tag,$subfield,$record);
		    $value=char_decode($value) unless ($is_a_modif);
		    $indicator = $x if $x; #XXX
		    if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
			$subfield_data{marc_value}= build_authorized_values_list($tag, $subfield, $value, $dbh, $authorised_values_sth);
		    } elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>"; #"
		    } elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
			my $plugin="../value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
			require $plugin;
			my $extended_param = plugin_parameters($dbh,$record,$tagslib,$i,$tabloop);
			my ($function_name,$javascript) = plugin_javascript($dbh,$record,$tagslib,$i,$tabloop);
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  value=\"$value\" size=47 maxlength=255 OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i)\"> <a href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
		    } else {
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" value=\"$value\" size=50 maxlength=255>";
		    }

		# if breeding is empty
		} else {
		    my ($x,$value);
		    ($x,$value) = find_value($tag,$subfield,$record) if ($record ne -1);
		    $value=char_decode($value) unless ($is_a_modif);
		    if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
			$subfield_data{marc_value}= build_authorized_values_list($tag, $subfield, $value, $dbh, $authorised_values_sth);
		    } elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>";
		    } elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
			my $plugin="../value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
			require $plugin;
			my $extended_param = plugin_parameters($dbh,$record,$tagslib,$i,$tabloop);
			my ($function_name,$javascript) = plugin_javascript($dbh,$record,$tagslib,$i,$tabloop);
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  DISABLE READONLY size=47 maxlength=255 OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i)\"> <a href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
		    } else {
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" size=50 maxlength=255>";
		    }
		}
		push(@subfields_data, \%subfield_data);
		$i++;
	    }
	    if ($#subfields_data >= 0) {
		my %tag_data;
		$tag_data{tag} = $tag;
		$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
		$tag_data{indicator} = $indicator;
		$tag_data{subfield_loop} = \@subfields_data;
		push (@loop_data, \%tag_data);
	    }
	}
	$template->param($tabloop."XX" =>\@loop_data);
    }
}


sub build_hidden_data () {
    # build hidden data =>
    # we store everything, even if we show only requested subfields.

    my @loop_data =();
    my $i=0;
    foreach my $tag (keys %{$tagslib}) {
	my $previous_tag = '';

	# loop through each subfield
	foreach my $subfield (keys %{$tagslib->{$tag}}) {
	    next if ($subfield eq 'lib');
	    next if ($subfield eq 'tab');
	    next if ($subfield eq 'mandatory');
	    next if ($tagslib->{$tag}->{$subfield}->{'tab'}  ne "-1");
	    my %subfield_data;
	    $subfield_data{marc_lib}=$tagslib->{$tag}->{$subfield}->{lib};
	    $subfield_data{marc_mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
	    $subfield_data{marc_repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
	    $subfield_data{marc_value}="<input type=\"hidden\" name=\"field_value[]\">";
	    push(@loop_data, \%subfield_data);
	    $i++
	}
    }
}


my $input = new CGI;
my $error = $input->param('error');
my $oldbiblionumber=$input->param('oldbiblionumber'); # if bib exists, it's a modif, not a new biblio.
my $breedingid = $input->param('breedingid');
my $op = $input->param('op');
my $dbh = C4::Context->dbh;
my $bibid;
if ($oldbiblionumber) {
	$bibid = &MARCfind_MARCbibid_from_oldbiblionumber($dbh,$oldbiblionumber);
}else {
	$bibid = $input->param('bibid');
}
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "acqui.simple/addbiblio.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

$tagslib = &MARCgettagslib($dbh,1);
my $record=-1;
$record = MARCgetbiblio($dbh,$bibid) if ($bibid);
#warn "1= ".$record->as_formatted;
$record = MARCfindbreeding($dbh,$breedingid) if ($breedingid);
$is_a_modif=0;
my ($oldbiblionumtagfield,$oldbiblionumtagsubfield);
my ($oldbiblioitemnumtagfield,$oldbiblioitemnumtagsubfield,$bibitem,$oldbiblioitemnumber);
if ($bibid) {
	$is_a_modif=1;
	# if it's a modif, retrieve old biblio and bibitem numbers for the future modification of old-DB.
	($oldbiblionumtagfield,$oldbiblionumtagsubfield) = &MARCfind_marc_from_kohafield($dbh,"biblio.biblionumber");
	($oldbiblioitemnumtagfield,$oldbiblioitemnumtagsubfield) = &MARCfind_marc_from_kohafield($dbh,"biblioitems.biblioitemnumber");
	# search biblioitems value
	my $sth=$dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
	$sth->execute($oldbiblionumber);
	($oldbiblioitemnumber) = $sth->fetchrow;
}
#------------------------------------------------------------------------------------------------------------------------------
if ($op eq "addbiblio") {
#------------------------------------------------------------------------------------------------------------------------------
	# rebuild
	my @tags = $input->param('tag');
	my @subfields = $input->param('subfield');
	my @values = $input->param('field_value');
	# build indicator hash.
	my @ind_tag = $input->param('ind_tag');
	my @indicator = $input->param('indicator');
	my %indicators;
	for (my $i=0;$i<=$#ind_tag;$i++) {
		$indicators{$ind_tag[$i]} = $indicator[$i];
	}
	my $record = MARChtml2marc($dbh,\@tags,\@subfields,\@values,%indicators);
# MARC::Record built => now, record in DB
	my $oldbibnum;
	my $oldbibitemnum;
	if ($is_a_modif) {
		 NEWmodbiblio($dbh,$record,$bibid);
	} else {
		($bibid,$oldbibnum,$oldbibitemnum) = NEWnewbiblio($dbh,$record);
	}
# now, redirect to additem page
	print $input->redirect("additem.pl?bibid=$bibid");
	exit;
#------------------------------------------------------------------------------------------------------------------------------
} else {
#------------------------------------------------------------------------------------------------------------------------------
	build_tabs ($template, $record, $dbh);
	build_hidden_data;
	$template->param(
		oldbiblionumber             => $oldbiblionumber,
		bibid                       => $bibid,
		oldbiblionumtagfield        => $oldbiblionumtagfield,
		oldbiblionumtagsubfield     => $oldbiblionumtagsubfield,
		oldbiblioitemnumtagfield    => $oldbiblioitemnumtagfield,
		oldbiblioitemnumtagsubfield => $oldbiblioitemnumtagsubfield,
		oldbiblioitemnumber         => $oldbiblioitemnumber );
}
output_html_with_http_headers $input, $cookie, $template->output;
