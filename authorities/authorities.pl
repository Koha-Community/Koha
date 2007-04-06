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
use C4::AuthoritiesMarc;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p

use MARC::File::USMARC;
use MARC::File::XML;
use C4::Biblio;
use vars qw( $tagslib);
use vars qw( $authorised_values_sth);
use vars qw( $is_a_modif );

my $itemtype; # created here because it can be used in build_authorized_values_list sub

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
				push @result,@$subfield[1];
							$indicator = $field->indicator(1).$field->indicator(2);
				}
			}
		}
	}
	return($indicator,@result);
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
	my $sth=$dbh->prepare("select branchcode,branchname from branches order by branchname");
	$sth->execute;
	push @authorised_values, ""
		unless ($tagslib->{$tag}->{$subfield}->{mandatory});

	while (my ($branchcode,$branchname) = $sth->fetchrow_array) {
		push @authorised_values, $branchcode;
		$authorised_lib{$branchcode}=$branchname;
	}

	#----- itemtypes
	} elsif ($tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes") {
		my $sth=$dbh->prepare("select itemtype,description from itemtypes order by description");
		$sth->execute;
		push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
	
		while (my ($itemtype,$description) = $sth->fetchrow_array) {
			push @authorised_values, $itemtype;
			$authorised_lib{$itemtype}=$description;
		}
		$value=$itemtype unless ($value);

	#---- "true" authorised value
	} else {
		$authorised_values_sth->execute($tagslib->{$tag}->{$subfield}->{authorised_value});

		push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
	
		while (my ($value,$lib) = $authorised_values_sth->fetchrow_array) {
			push @authorised_values, $value;
			$authorised_lib{$value}=$lib;
		}
    }
    return CGI::scrolling_list( -name     => 'field_value',
				-values   => \@authorised_values,
				-default  => $value,
				-labels   => \%authorised_lib,
				-override => 1,
				-size     => 1,
	 			-tabindex=>'',
				-multiple => 0 );
}


=item create_input
 builds the <input ...> entry for a subfield.
=cut
sub create_input () {
	my ($tag,$subfield,$value,$i,$tabloop,$rec,$authorised_values_sth) = @_;
	# must be encoded as utf-8 before it reaches the editor
       my $dbh=C4::Context->dbh;
	$value =~ s/"/&quot;/g;
	my %subfield_data;
	$subfield_data{tag}=$tag;
	$subfield_data{subfield}=$subfield;
	$subfield_data{marc_lib}="<span id=\"error$i\">".$tagslib->{$tag}->{$subfield}->{lib}."</span>";
	$subfield_data{marc_lib_plain}=$tagslib->{$tag}->{$subfield}->{lib};
	$subfield_data{tag_mandatory}=$tagslib->{$tag}->{mandatory};
	$subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
	$subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
	$subfield_data{kohafield}=$tagslib->{$tag}->{$subfield}->{kohafield};
	$subfield_data{index} = $i;
	$subfield_data{visibility} = "display:none" if (substr($tagslib->{$tag}->{$subfield}->{hidden},2,1) gt "0") ; #check parity
	# it's an authorised field
	if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
		$subfield_data{marc_value}= build_authorized_values_list($tag, $subfield, $value, $dbh,$authorised_values_sth);
	# it's a thesaurus / authority field
	} elsif ($tagslib->{$tag}->{$subfield}->{frameworkcode}) {
		$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" value=\"$value\" size=\"67\" maxlength=\"255\" DISABLE READONLY> <a href=\"javascript:Dopop('../authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{frameworkcode}."&index=$i',$i)\">...</a>";
	} elsif ($tagslib->{$tag}->{$subfield}->{link}) {
		$subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffffff;'\" tabindex=\"1\" type=\"text\" name=\"field_value\" value=\"$value\" size=\"40\" maxlength=\"255\" DISABLE READONLY> <a  style=\"cursor: help;\" href=\"javascript:Dopop('../authorities/auth_linker.pl?index=$i',$i)\">...</a>";
	
		# it's a plugin field
	} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
		# opening plugin. Just check wether we are on a developper computer on a production one
		# (the cgidir differs)
		my $cgidir = C4::Context->intranetdir ."/cgi-bin/cataloguing/value_builder";
		unless (opendir(DIR, "$cgidir")) {
			$cgidir = C4::Context->intranetdir."/cataloguing/value_builder";
		} 
		my $plugin=$cgidir."/".$tagslib->{$tag}->{$subfield}->{'value_builder'}; 
		require $plugin;
		my $extended_param = plugin_parameters($dbh,$rec,$tagslib,$i,$tabloop);
		my ($function_name,$javascript) = plugin_javascript($dbh,$rec,$tagslib,$i,$tabloop);
		$subfield_data{marc_value}="<input tabindex=\"1\" type=\"text\" name=\"field_value\"  value=\"$value\" size=\"40\" maxlength=\"255\" OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i); \"> <a  style=\"cursor: help;\" href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
	# it's an hidden field
	} elsif  ($tag eq '') {
		$subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffffff'; \" tabindex=\"1\" type=\"hidden\" name=\"field_value\" value=\"$value\">";
	} elsif  (substr($tagslib->{$tag}->{$subfield}->{'hidden'},2,1) gt "1") {

		$subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffffff'; \" tabindex=\"1\" type=\"text\" name=\"field_value\" value=\"$value\" size=\"40\" maxlength=\"255\" >";
	# it's a standard field
	} else {
		if (length($value) >100) {
			$subfield_data{marc_value}="<textarea tabindex=\"1\" name=\"field_value\" cols=\"40\" rows=\"5\" >$value</textarea>";
		} else {
			$subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffffff'; \" tabindex=\"1\" type=\"text\" name=\"field_value\" value=\"$value\" size=\"50\">"; #"
		}
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
			if ($record ne -1 && ($record->field($tag) || $tag eq '000')) {
				my @fields;
				if ($tag ne '000') {
					@fields = $record->field($tag);
				} else {
					push @fields,$record->leader();
				}
				foreach my $field (@fields)  {
					my @subfields_data;
					if ($tag<10) {
						my ($value,$subfield);
						if ($tag ne '000') {
							$value=$field->data();
							$subfield="@";
						} else {
							$value = $field;
							$subfield='@';
						}
						next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
					#	next if ($tagslib->{$tag}->{$subfield}->{kohafield} eq 'auth_header.authid');
						push(@subfields_data, &create_input($tag,$subfield,$value,$i,$tabloop,$record,$authorised_values_sth));
						$i++;
					} else {
						my @subfields=$field->subfields();
						foreach my $subfieldcount (0..$#subfields) {
							my $subfield=$subfields[$subfieldcount][0];
							my $value=$subfields[$subfieldcount][1];
							next if (length $subfield !=1);
							next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
							push(@subfields_data, &create_input($tag,$subfield,$value,$i,$tabloop,$record,$authorised_values_sth));
							$i++;
						}
					}
# now, loop again to add parameter subfield that are not in the MARC::Record
					foreach my $subfield (sort( keys %{$tagslib->{$tag}})) {
						next if (length $subfield !=1);
						next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
						next if ($tag<10);
						next if ((substr($tagslib->{$tag}->{$subfield}->{hidden},2,1) gt "1")  ); #check for visibility flag
						next if (defined($field->subfield($subfield)));
						push(@subfields_data, &create_input($tag,$subfield,'',$i,$tabloop,$record,$authorised_values_sth));
						$i++;
					}
					if ($#subfields_data >= 0) {
						my %tag_data;
						$tag_data{tag} = $tag;
						$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
						$tag_data{repeatable} = $tagslib->{$tag}->{repeatable};
						$tag_data{indicator} = $record->field($tag)->indicator(1). $record->field($tag)->indicator(2) if ($tag>=10);
						$tag_data{subfield_loop} = \@subfields_data;
						if ($tag<10) {
                                                	$tag_data{fixedfield} = 1;
                                        	}

						push (@loop_data, \%tag_data);
					}
# If there is more than 1 field, add an empty hidden field as separator.
					if ($#fields >=1 && $#loop_data >=0 && $loop_data[$#loop_data]->{'tag'} eq $tag) {
						my @subfields_data;
						my %tag_data;
						push(@subfields_data, &create_input('','','',$i,$tabloop,$record,$authorised_values_sth));
						$tag_data{tag} = '';
						$tag_data{tag_lib} = '';
						$tag_data{indicator} = '';
						$tag_data{subfield_loop} = \@subfields_data;
						if ($tag<10) {
       		                                        $tag_data{fixedfield} = 1;
	                    			}
						push (@loop_data, \%tag_data);
						$i++;
					}
				}
	
			} else {
				my @subfields_data;
				foreach my $subfield (sort(keys %{$tagslib->{$tag}})) {
					next if (length $subfield !=1);
					next if ((substr($tagslib->{$tag}->{$subfield}->{hidden},2,1) gt "1")  ); #check for visibility flag
					next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
					push(@subfields_data, &create_input($tag,$subfield,'',$i,$tabloop,$record,$authorised_values_sth));
					$i++;
				}
				if ($#subfields_data >= 0) {
					my %tag_data;
					$tag_data{tag} = $tag;
					$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
					$tag_data{repeatable} = $tagslib->{$tag}->{repeatable};
					$tag_data{indicator} = $indicator;
					$tag_data{subfield_loop} = \@subfields_data;
					$tag_data{tagfirstsubfield} = $tag_data{subfield_loop}[0];
					if ($tag<10) {
						$tag_data{fixedfield} = 1;
					}
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
		next if ($subfield eq 'repeatable');
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

# ======================== 
#          MAIN 
#=========================
my $input = new CGI;
my $z3950 = $input->param('z3950');
my $error = $input->param('error');
my $authid=$input->param('authid'); # if authid exists, it's a modif, not a new authority.
my $op = $input->param('op');
my $nonav = $input->param('nonav');
my $myindex = $input->param('index');
my $linkid=$input->param('linkid');
my $authtypecode = $input->param('authtypecode');

my $dbh = C4::Context->dbh;
$authtypecode = &GetAuthTypeCode($authid) if !$authtypecode;


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "authorities/authorities.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editauthorities => 1},
			     debug => 1,
			     });
$template->param(nonav   => $nonav,index=>$myindex,authtypecode=>$authtypecode,);
$tagslib = GetTagsLabels(1,$authtypecode);
my $record=-1;
my $encoding="";
$record = GetAuthority($authid) if ($authid);
my ($oldauthnumtagfield,$oldauthnumtagsubfield);
my ($oldauthtypetagfield,$oldauthtypetagsubfield);
$is_a_modif=0;
if ($authid) {
  $is_a_modif=1;
  ($oldauthnumtagfield,$oldauthnumtagsubfield) = &GetAuthMARCFromKohaField("auth_header.authid",$authtypecode);
  ($oldauthtypetagfield,$oldauthtypetagsubfield) = &GetAuthMARCFromKohaField("auth_header.authtypecode",$authtypecode);
}

#------------------------------------------------------------------------------------------------------------------------------
if ($op eq "add") {
#------------------------------------------------------------------------------------------------------------------------------

	# rebuild
	my @tags = $input->param('tag');
	my @subfields = $input->param('subfield');
	my @values = $input->param('field_value');
	# build indicator hash.
	my @ind_tag = $input->param('ind_tag');
	my @indicator = $input->param('indicator');
	my $xml = TransformHtmlToXml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag);
#     warn $record->as_formatted;
# 	warn $xml;
	my $record=MARC::Record->new_from_xml($xml,'UTF-8',(C4::Context->preference("marcflavour") eq "UNIMARC"?"UNIMARCAUTH":C4::Context->preference("marcflavour")));
	$record->encoding('UTF-8');
	#warn $record->as_formatted;
	# check for a duplicate
	my ($duplicateauthid,$duplicateauthvalue) = FindDuplicateAuthority($record,$authtypecode) if ($op eq "add") && (!$is_a_modif);
warn "duplicate:$duplicateauthid,$duplicateauthvalue";	
	my $confirm_not_duplicate = $input->param('confirm_not_duplicate');
# it is not a duplicate (determined either by Koha itself or by user checking it's not a duplicate)
	if (!$duplicateauthid or $confirm_not_duplicate) {
# warn "noduplicate";
          if ($is_a_modif ) {	
            $authid=ModAuthority($authid,$record,$authtypecode,1);		
          } else {
            ($authid) = AddAuthority($record,$authid,$authtypecode);
          }
          print $input->redirect("detail.pl?authid=$authid");
          exit;
 	} else {
	# it may be a duplicate, warn the user and do nothing
            build_tabs ($template, $record, $dbh,$encoding);
            build_hidden_data;
            $template->param(authid =>$authid,
                            duplicateauthid     => $duplicateauthid,
                            duplicateauthvalue  => $duplicateauthvalue,
                            );
 	}
#------------------------------------------------------------------------------------------------------------------------------
} elsif ($op eq "addfield") {
#------------------------------------------------------------------------------------------------------------------------------
	my $addedfield = $input->param('addfield_field');
	my $tagaddfield_subfield = $input->param('addfield_subfield');
	my @tags = $input->param('tag');
	my @subfields = $input->param('subfield');
	my @values = $input->param('field_value');
	# build indicator hash.
	my @ind_tag = $input->param('ind_tag');
	my @indicator = $input->param('indicator');
	my $xml = TransformHtmlToXml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag);
	my $record=MARC::Record->new_from_xml($xml,'UTF-8');
	$record->encoding('UTF-8');
	# adding an empty field
	my $field = MARC::Field->new("$addedfield",'','','$tagaddfield_subfield' => "");
	$record->append_fields($field);
	build_tabs ($template, $record, $dbh,$encoding);
	build_hidden_data;
	$template->param(
		authid => $authid,);

} elsif ($op eq "delete") {
#------------------------------------------------------------------------------------------------------------------------------
	&AUTHdelauthority($authid);
	if ($nonav){
	print $input->redirect("auth_finder.pl");
	}else{
	print $input->redirect("authorities-home.pl?authid=0");
	}
		exit;
} else {
if ($op eq "duplicate")
	{
		$authid = "";
	}
	build_tabs ($template, $record, $dbh,$encoding);
	build_hidden_data;
	$template->param(oldauthtypetagfield=>$oldauthtypetagfield, oldauthtypetagsubfield=>$oldauthtypetagsubfield,
		oldauthnumtagfield=>$oldauthnumtagfield, oldauthnumtagsubfield=>$oldauthnumtagsubfield,
		authid                      => $authid , authtypecode=>$authtypecode,	);
}

$template->param(
	authid                       => $authid,
	authtypecode => $authtypecode,
	linkid=>$linkid,
	);

my $authtypes = getauthtypes;
my @authtypesloop;
foreach my $thisauthtype (keys %$authtypes) {
	my $selected = 1 if $thisauthtype eq $authtypecode;
	my %row =(value => $thisauthtype,
				selected => $selected,
				authtypetext => $authtypes->{$thisauthtype}{'authtypetext'},
			);
	push @authtypesloop, \%row;
}

$template->param(authtypesloop => \@authtypesloop,
				authtypetext => $authtypes->{$authtypecode}{'authtypetext'},
				hide_marc => C4::Context->preference('hide_marc'),
				intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
				);
output_html_with_http_headers $input, $cookie, $template->output;
