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

use vars qw( $tagslib);
use vars qw( $authorised_values_sth);
use vars qw( $is_a_modif );

=item find_value

    ($indicators, $value) = find_value($tag, $subfield, $record,$encoding);

Find the given $subfield in the given $tag in the given
MARC::Record $record.  If the subfield is found, returns
the (indicators, value) pair; otherwise, (undef, undef) is
returned.

=cut

sub find_value {
	my ($tagfield,$insubfield,$record,$encoding) = @_;
	my @result;
	my $indicator;
	if ($tagfield <10) {
		if ($record->field($tagfield)) {
			push @result, $record->field($tagfield)->data();
		} else {
			push @result,"";
		}
	} else {
		foreach my $field ($record->field($tagfield)) {
			my @subfields = $field->subfields();
			foreach my $subfield (@subfields) {
				if (@$subfield[0] eq $insubfield) {
					push @result,char_decode(@$subfield[1],$encoding);
					$indicator = $field->indicator(1).$field->indicator(2);
				}
			}
		}
	}
	return($indicator,@result);
}


=item MARCfindbreeding

    $record = MARCfindbreeding($dbh, $breedingid);

Look up the breeding farm with database handle $dbh, for the
record with id $breedingid.  If found, returns the decoded
MARC::Record; otherwise, -1 is returned (FIXME).
Returns as second parameter the character encoding.

=cut

sub MARCfindbreeding {
	my ($dbh,$id) = @_;
	my $sth = $dbh->prepare("select file,marc,encoding from marc_breeding where id=?");
	$sth->execute($id);
	my ($file,$marc,$encoding) = $sth->fetchrow;
	if ($marc) {
		my $record = MARC::File::USMARC::decode($marc);
		if (ref($record) eq undef) {
			return -1;
		} else {
			return $record,$encoding;
		}
	}
	return -1;
}


=item build_authorized_values_list

=cut

sub build_authorized_values_list ($$$$$) {
    my($tag, $subfield, $value, $dbh,$authorised_values_sth) = @_;

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

=item create_input
 builds the <input ...> entry for a subfield.
=cut
sub create_input () {
	my ($tag,$subfield,$value,$i,$tabloop,$rec,$authorised_values_sth) = @_;
	$value =~ s/"/&quot;/g;
	my $dbh = C4::Context->dbh;
	my %subfield_data;
	$subfield_data{tag}=$tag;
	$subfield_data{subfield}=$subfield;
	$subfield_data{marc_lib}="<DIV id=\"error$i\">".$tagslib->{$tag}->{$subfield}->{lib}."</div>";
	$subfield_data{tag_mandatory}=$tagslib->{$tag}->{mandatory};
	$subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
	$subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
	$subfield_data{kohafield}=$tagslib->{$tag}->{$subfield}->{kohafield};
	if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
		$subfield_data{marc_value}= build_authorized_values_list($tag, $subfield, $value, $dbh,$authorised_values_sth);
	} elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
		$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY> <a href=\"javascript:Dopop('../thesaurus_popup.pl?category=$tagslib->{$tag}->{$subfield}->{thesaurus_category}&index=$i',$i)\">...</a>";
	} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
		my $plugin="../value_builder/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
		require $plugin;
		my $extended_param = plugin_parameters($dbh,$rec,$tagslib,$i,$tabloop);
		my ($function_name,$javascript) = plugin_javascript($dbh,$rec,$tagslib,$i,$tabloop);
		$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  value=\"$value\" DISABLE READONLY size=47 maxlength=255 OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i)\"> <a href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
	} elsif  ($tag eq '') {
		$subfield_data{marc_value}="<input type=\"hidden\" name=\"field_value\" size=50 maxlength=255>"; #"
	} else {
		$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" value=\"$value\" size=50 maxlength=255>"; #"
	}
	return \%subfield_data;
}

sub build_tabs ($$$$) {
    my($template, $record, $dbh,$encoding) = @_;

    # fill arrays
    my @loop_data =();
    my $tag;
    my $i=0;
	my $authorised_values_sth = $dbh->prepare("select authorised_value,lib
		from authorised_values
		where category=? order by lib");

# loop through each tab 0 through 9
	for (my $tabloop = 0; $tabloop <= 9; $tabloop++) {
		my @loop_data = ();
		foreach my $tag (sort(keys (%{$tagslib}))) {
			my $indicator;
	# if MARC::Record is not empty => use it as master loop, then add missing subfields that should be in the tab.
	# if MARC::Record is empty => use tab as master loop.
			if ($record ne -1 && $record->field($tag)) {
				my @fields = $record->field($tag);
				foreach my $field (@fields)  {
					my @subfields_data;
					if ($tag<10) {
						my $value=$field->data();
						my $subfield="@";
						next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
						push(@subfields_data, &create_input($tag,$subfield,char_decode($value,$encoding),$i,$tabloop,$record,$authorised_values_sth));
						$i++;
					} else {
						my @subfields=$field->subfields();
						foreach my $subfieldcount (0..$#subfields) {
							my $subfield=$subfields[$subfieldcount][0];
							my $value=$subfields[$subfieldcount][1];
							next if (length $subfield !=1);
							next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
							push(@subfields_data, &create_input($tag,$subfield,char_decode($value,$encoding),$i,$tabloop,$record,$authorised_values_sth));
							$i++;
						}
					}
# now, loop again to add parameter subfield that are not in the MARC::Record
					foreach my $subfield (sort( keys %{$tagslib->{$tag}})) {
						next if (length $subfield !=1);
						next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
						next if ($tag<10);
						next if (defined($record->field($tag)->subfield($subfield)));
						push(@subfields_data, &create_input($tag,$subfield,'',$i,$tabloop,$record,$authorised_values_sth));
						$i++;
					}
					if ($#subfields_data >= 0) {
						my %tag_data;
						$tag_data{tag} = $tag;
						$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
						$tag_data{indicator} = $record->field($tag)->indicator(1). $record->field($tag)->indicator(2) if ($tag>=10);
						$tag_data{subfield_loop} = \@subfields_data;
						push (@loop_data, \%tag_data);
					}
# If there is more than 1 field, add an empty hidden field as separator.
					if ($#fields >=1) {
						my @subfields_data;
						my %tag_data;
						push(@subfields_data, &create_input('','','',$i,$tabloop,$record,$authorised_values_sth));
						$tag_data{tag} = '';
						$tag_data{tag_lib} = '';
						$tag_data{indicator} = '';
						$tag_data{subfield_loop} = \@subfields_data;
						push (@loop_data, \%tag_data);
						$i++;
					}
				}
	# if breeding is empty
			} else {
				my @subfields_data;
				foreach my $subfield (sort(keys %{$tagslib->{$tag}})) {
					next if (length $subfield !=1);
					next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
					push(@subfields_data, &create_input($tag,$subfield,'',$i,$tabloop,$record,$authorised_values_sth));
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
my $z3950 = $input->param('z3950');
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
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

$tagslib = &MARCgettagslib($dbh,1);
my $record=-1;
my $encoding="";
$record = MARCgetbiblio($dbh,$bibid) if ($bibid);
($record,$encoding) = MARCfindbreeding($dbh,$breedingid) if ($breedingid);

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
} elsif ($op eq "addfield") {
#------------------------------------------------------------------------------------------------------------------------------
	my $addedfield = $input->param('addfield_field');
	my @tags = $input->param('tag');
	my @subfields = $input->param('subfield');
	my @values = $input->param('field_value');
	# build indicator hash.
	my @ind_tag = $input->param('ind_tag');
	my @indicator = $input->param('indicator');
	splice(@tags,$addedfield,0,$tags[$addedfield]);
	splice(@subfields,$addedfield,0,$subfields[$addedfield]);
	splice(@values,$addedfield,0,$values[$addedfield]);
	splice(@ind_tag,$addedfield,0,$ind_tag[$addedfield]);
	my %indicators;
	for (my $i=0;$i<=$#ind_tag;$i++) {
		$indicators{$ind_tag[$i]} = $indicator[$i];
	}
# search the part of the array to duplicate.
	my $start=0;
	my $end=0;
	my $started;
	for (my $i=0;$i<=$#tags;$i++) {
		$start=$i if ($start eq 0 && $tags[$i] == $addedfield);
		$end=$i if ($start>0 && $tags[$i] eq $addedfield);
		last if ($start>0 && $tags[$i] ne $addedfield);
	}
# add an empty line in all arrays. This forces a new field in MARC::Record.
	splice(@tags,$end+1,0,'');
	splice(@subfields,$end+1,0,'');
	splice(@values,$end+1,0,'');
	splice(@ind_tag,$end+1,0,'');
	splice(@indicator,$end+1,0,'');
# then duplicate the field.
	splice(@tags,$end+2,0,@tags[$start..$end]);
	splice(@subfields,$end+2,0,@subfields[$start..$end]);
	splice(@values,$end+2,0,@values[$start..$end]);
	splice(@ind_tag,$end+2,0,@ind_tag[$start..$end]);
	splice(@indicator,$end+2,0,@indicator[$start..$end]);

	my %indicators;
	for (my $i=0;$i<=$#ind_tag;$i++) {
		$indicators{$ind_tag[$i]} = $indicator[$i];
	}
	my $record = MARChtml2marc($dbh,\@tags,\@subfields,\@values,%indicators);
	build_tabs ($template, $record, $dbh,$encoding);
	build_hidden_data;
	$template->param(
		oldbiblionumber             => $oldbiblionumber,
		bibid                       => $bibid,
		oldbiblionumtagfield        => $oldbiblionumtagfield,
		oldbiblionumtagsubfield     => $oldbiblionumtagsubfield,
		oldbiblioitemnumtagfield    => $oldbiblioitemnumtagfield,
		oldbiblioitemnumtagsubfield => $oldbiblioitemnumtagsubfield,
		oldbiblioitemnumber         => $oldbiblioitemnumber );
} elsif ($op eq "delete") {
#------------------------------------------------------------------------------------------------------------------------------
	&NEWdelbiblio($dbh,$bibid);
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=/cgi-bin/koha/search.marc/search.pl?type=intranet\"></html>";
	exit;
#------------------------------------------------------------------------------------------------------------------------------#------------------------------------------------------------------------------------------------------------------------------
} else {
#------------------------------------------------------------------------------------------------------------------------------
	build_tabs ($template, $record, $dbh,$encoding);
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