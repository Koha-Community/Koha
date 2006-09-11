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
use C4::Search; # also includes Biblio.pm, Search is used to FindDuplicate
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use MARC::Record;
use MARC::File::USMARC;
my $format="USMARC";
$format="UNIMARC" if (C4::Context->preference('marcflavour') eq 'UNIMARC');
use MARC::File::XML(RecordFormat =>$format);
use Encode;
use vars qw( $tagslib);
use vars qw( $authorised_values_sth);
use vars qw( $is_a_modif );
my $input = new CGI;
my $z3950 = $input->param('z3950');
my $logstatus=C4::Context->preference('Activate_log');
my $xml;
my $itemtype; # created here because it can be used in build_authorized_values_list sub
my $fromserials=$input->param('fromserials');## if a serial is being added do not display navigation menus

###Find related tags for Z3950 searches- required  by template
my($isbntag,$isbnsub)=MARCfind_marc_from_kohafield("isbn","biblios");
my($issntag,$issnsub)=MARCfind_marc_from_kohafield("issn","biblios");
my($titletag,$titlesub)=MARCfind_marc_from_kohafield("title","biblios");
my($authortag,$authorsub)=MARCfind_marc_from_kohafield("author","biblios");
=item MARCfindbreeding

    $record = MARCfindbreeding($dbh, $breedingid,$frameworkcode);

Look up the breeding farm with database handle $dbh, for the
record with id $breedingid.  If found, returns the decoded
MARC::Record; otherwise, -1 is returned (FIXME).
Returns as second parameter the character encoding.

=cut

sub MARCfindbreeding {
	my ($dbh,$id,$oldbiblionumber) = @_;
	my $sth = $dbh->prepare("select marc,encoding from marc_breeding where id=?");
	$sth->execute($id);
	my ($marc,$encoding) = $sth->fetchrow;
	$sth->finish;
	if ($marc) {
		my $record = MARC::File::USMARC::decode($marc);
		if (ref($record) eq undef) {
			return -1;
		} 
	if (C4::Context->preference("z3950NormalizeAuthor") and C4::Context->preference("z3950AuthorAuthFields")){
				my ($tag,$subfield) = MARCfind_marc_from_kohafield("author","biblios");
				my $auth_fields = C4::Context->preference("z3950AuthorAuthFields");
				my @auth_fields= split /,/,$auth_fields;
				my $field;
				if ($record->field($tag)){
					foreach my $tmpfield ($record->field($tag)->subfields){
						my $subfieldcode=shift @$tmpfield;
						my $subfieldvalue=shift @$tmpfield;
						if ($field){
							$field->add_subfields("$subfieldcode"=>$subfieldvalue) if ($subfieldcode ne $subfield);
						} else {
							$field=MARC::Field->new($tag,"","",$subfieldcode=>$subfieldvalue) if ($subfieldcode ne $subfield);
						}
					}
				}
				$record->delete_field($record->field($tag));
				foreach my $fieldtag (@auth_fields){
					next unless ($record->field($fieldtag));
					my $lastname = $record->field($fieldtag)->subfield('a');
					my $firstname= $record->field($fieldtag)->subfield('b');
					my $title = $record->field($fieldtag)->subfield('c');
					my $number= $record->field($fieldtag)->subfield('d');
					if ($title){
						$field->add_subfields("$subfield"=>ucfirst($title)." ".ucfirst($firstname)." ".$number);
					}else{
						$field->add_subfields("$subfield"=>ucfirst($firstname).", ".ucfirst($lastname));
					}
				}
				$record->insert_fields_ordered($field);
			}
##Delete biblionumber tag in case a similar tag is used in imported MARC ## 
	my  (  $tagfield,  $tagsubfield )  =MARCfind_marc_from_kohafield("biblionumber","biblios");
		my $old_field = $record->field($tagfield);
		$record->delete_field($old_field);
		##add the old biblionumber if a modif but coming from breedingfarm
		if ($oldbiblionumber){
			my $newfield;
			if ($tagfield<10){
	 		$newfield = MARC::Field->new($tagfield,  $oldbiblionumber);
			}else{
 			$newfield = MARC::Field->new($tagfield, '', '', "$tagsubfield" => $oldbiblionumber);
			}	
		$record->insert_fields_ordered($newfield);
		}
	my $xml=  $record->as_xml_record();
	$xml=Encode::encode('utf8',$xml);
	my $xmlhash=XML_xml2hash_onerecord($xml);
		return $xmlhash,$encoding;
		
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
				-multiple => 0 );
}

=item create_input
 builds the <input ...> entry for a subfield.
=cut
sub create_input () {
	my ($tag,$subfield,$value,$i,$tabloop,$rec,$authorised_values_sth,$id) = @_;	
	my $dbh=C4::Context->dbh;
	$value =~ s/"/&quot;/g;
	my %subfield_data;
	$subfield_data{id}=$id;
	$subfield_data{tag}=$tag;
	$subfield_data{subfield}=$subfield;
	$subfield_data{marc_lib}="<span id=\"error$i\">".$tagslib->{$tag}->{$subfield}->{lib}."</span>";
	$subfield_data{marc_lib_plain}=$tagslib->{$tag}->{$subfield}->{lib};
	$subfield_data{tag_mandatory}=$tagslib->{$tag}->{mandatory};
	$subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
	$subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
	$subfield_data{index} = $i;
	$subfield_data{visibility} = "display:none" if (substr($tagslib->{$tag}->{$subfield}->{hidden},2,1) gt "0") ; #check parity
	if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
		$subfield_data{marc_value}= build_authorized_values_list($tag, $subfield, $value, $dbh,$authorised_values_sth);
	# it's an  authority field
	} elsif ($tagslib->{$tag}->{$subfield}->{authtypecode}) {
		
		$subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffffff;'\"\" tabindex=\"1\" type=\"text\"   name=\"field_value\" id=\"field_value$id\" value=\"$value\" size=\"40\" maxlength=\"255\" DISABLE READONLY> <a  style=\"cursor: help;\" href=\"javascript:Dopop('../authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{authtypecode}."&index=$id',$id);\">...</a>";
	# it's a plugin field
	} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
		# opening plugin. Just check wether we are on a developper computer on a production one
		# (the cgidir differs)
		my $cgidir = C4::Context->intranetdir ."/cgi-bin/value_builder";
		unless (opendir(DIR, "$cgidir")) {
			$cgidir = C4::Context->intranetdir."/value_builder";
		} 
		my $plugin=$cgidir."/".$tagslib->{$tag}->{$subfield}->{'value_builder'}; 
		require $plugin;
		my $extended_param = plugin_parameters($dbh,$rec,$tagslib,$i,$tabloop);
		my ($function_name,$javascript) = plugin_javascript($dbh,$rec,$tagslib,$i,$tabloop);
		$subfield_data{marc_value}="<input tabindex=\"1\" type=\"text\"  name=\"field_value\" id=\"field_value$id\"  value=\"$value\" size=\"40\" maxlength=\"255\" DISABLE READONLY OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i); \"> <a  style=\"cursor: help;\" href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
	# it's an hidden field
	} elsif  ($tag eq '') {
		$subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffffff'; \" tabindex=\"1\" type=\"hidden\" name=\"field_value\" id=\"field_value$id\"  value=\"$value\">";
	} elsif  (substr($tagslib->{$tag}->{$subfield}->{'hidden'},2,1) gt "1") {

		$subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffffff'; \" tabindex=\"1\" type=\"text\" name=\"field_value\" id=\"field_value$id\"   value=\"$value\" size=\"40\" maxlength=\"255\" >";
	# it's a standard field
	} else {
		if (length($value) >100) {
			$subfield_data{marc_value}="<textarea tabindex=\"1\" name=\"field_value\" id=\"field_value$id\"  cols=\"40\" rows=\"5\" >$value</textarea>";
		} else {
			$subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffffff'; \" tabindex=\"1\" type=\"text\" name=\"field_value\" id=\"field_value$id\"  value=\"$value\" size=\"50\">"; #"
		}
	}
	return \%subfield_data;
}

sub build_tabs  ($$$;$){
    my($template, $xmlhash, $dbh,$addedfield) = @_;
    # fill arrays
    my @loop_data =();
    my $tag;
    my $i=0;
my $id=100;
	my $authorised_values_sth = $dbh->prepare("select authorised_value,lib
		from authorised_values
		where category=? order by lib");
my $biblio;
my $controlfields;
my $leader;
if ($xmlhash){
 $biblio=$xmlhash->{'datafield'};
 $controlfields=$xmlhash->{'controlfield'};
 $leader=$xmlhash->{'leader'};
}
    my @BIG_LOOP;
my %built;

# loop through each tab 0 through 9
for (my $tabloop = 0; $tabloop <= 9; $tabloop++) {

		my @loop_data = ();
	foreach my $tag (sort(keys (%{$tagslib}))) {
			my $indicator;
				# if MARC::Record is not empty => use it as master loop, then add missing subfields that should be in the tab.
				# if MARC::Record is empty => use tab as master loop.
		my @subfields_data;
		
	if ($xmlhash) {
			####
		
			my %tagdefined;
			my %definedsubfields;
			my $hiddenrequired;
			my ($ind1,$ind2);
			
		 if ($tag>9){
			foreach my $data (@$biblio){
					$hiddenrequired=0;
					my @subfields_data;
					undef %definedsubfields;
   	 			 if ($data->{'tag'} eq $tag){
					$tagdefined{$tag}=1 ;
					   if ($built{$tag}==1){
						$hiddenrequired=1;
					    }
					    $ind1="  ";
					      $ind2="  ";		
					      foreach my $subfieldcode ( $data->{'subfield'}){
		   				 foreach my $code ( @$subfieldcode){	
							next if ($tagslib->{$tag}->{$code->{'code'}}->{tab} ne $tabloop);						
							my $subfield=$code->{'code'}  ;
							my $value=$code->{'content'};
							$definedsubfields{$tag.$subfield}=1 ;
							 $built{$tag}=1;
							push(@subfields_data, &create_input($tag,$subfield,$value,$i,$tabloop,$xmlhash,$authorised_values_sth,$id)) ;
							$i++ ;
		   				}
					      } ##each subfield
					    $ind1=$data->{'ind1'};
					    $ind2=	$data->{'ind2'};
					  
					if ($hiddenrequired && $#loop_data >=0 && $loop_data[$#loop_data]->{'tag'} eq $tag) {
						my @hiddensubfields_data;
						my %tag_data;
						push(@hiddensubfields_data, &create_input('','','',$i,$tabloop,$xmlhash,$authorised_values_sth,$id));
						$tag_data{tag} = '';
						$tag_data{tag_lib} = '';
						$tag_data{indicator} = '';
						$tag_data{subfield_loop} = \@hiddensubfields_data;
						push (@loop_data, \%tag_data);
						$i++;
					}
					# now, loop again to add parameter subfield that are not in the MARC::Record
					
					foreach my $subfield (sort( keys %{$tagslib->{$tag}})) {
						next if (length $subfield !=1);
						next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
						next if ((substr($tagslib->{$tag}->{$subfield}->{hidden},2,1) gt "1")  ); #check for visibility flag
						next if ($definedsubfields{$tag.$subfield} );
						push(@subfields_data, &create_input($tag,$subfield,'',$i,$tabloop,$xmlhash,$authorised_values_sth,$id));
						$definedsubfields{$tag.$subfield}=1;
						$i++;
					}
					if ($#subfields_data >= 0) {
						my %tag_data;
						$tag_data{tag} = $tag;
						$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
						$tag_data{repeatable} = $tagslib->{$tag}->{repeatable};
						$tag_data{indicator} = $ind1.$ind2 if ($tag>=10);
						$tag_data{subfield_loop} = \@subfields_data;
						push (@loop_data, \%tag_data);
						
					}
					$id++;
  	  			     }## if tag matches
			
			}#eachdata
 		}else{ ## tag <10
			        if ($tag eq "000" || $tag eq "LDR"){
					my $subfield="@";
					next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
					my @subfields_data;
					my $value=$leader->[0] if $leader->[0];
					$tagdefined{$tag}=1 ;
					push(@subfields_data, &create_input($tag,$subfield,$value,$i,$tabloop,$xmlhash,$authorised_values_sth,$id));					
					$i++;
					if ($#subfields_data >= 0) {
						my %tag_data;
						$tag_data{tag} = $tag;
						$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
						$tag_data{repeatable} = $tagslib->{$tag}->{repeatable};
						$tag_data{subfield_loop} = \@subfields_data;
                                                			$tag_data{fixedfield} = 1;
						push (@loop_data, \%tag_data);
					}
			         }else{
	   			 foreach my $control (@$controlfields){
					my $subfield="@";
					next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
					my @subfields_data;
					if ($control->{'tag'} eq $tag){
					$hiddenrequired=0;
					$tagdefined{$tag}=1 ;
					 if ($built{$tag}==1){$hiddenrequired=1;}
					my $value=$control->{'content'} ;
					$definedsubfields{$tag.'@'}=1;
					push(@subfields_data, &create_input($tag,$subfield,$value,$i,$tabloop,$xmlhash,$authorised_values_sth,$id));					
					$i++;
					
					   $built{$tag}=1;
					if ($hiddenrequired && $#loop_data >=0 && $loop_data[$#loop_data]->{'tag'} eq $tag) {
						my @hiddensubfields_data;
						my %tag_data;
						push(@hiddensubfields_data, &create_input('','','',$i,$tabloop,$xmlhash,$authorised_values_sth,$id));
						$tag_data{tag} = '';
						$tag_data{tag_lib} = '';
						$tag_data{subfield_loop} = \@hiddensubfields_data;
						$tag_data{fixedfield} = 1;
						push (@loop_data, \%tag_data);
						$i++;
					}
					if ($#subfields_data >= 0) {
						my %tag_data;
						$tag_data{tag} = $tag;
						$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
						$tag_data{repeatable} = $tagslib->{$tag}->{repeatable};
						$tag_data{subfield_loop} = \@subfields_data;
						$tag_data{fixedfield} = 1;
						push (@loop_data, \%tag_data);
					}
					$id++;
					}## tag matches
	  			 }# each control
			       }
   			}##tag >9


			##### Any remaining tag
				my @subfields_data;
				# now, loop again to add parameter subfield that are not in the MARC::Record
					foreach my $subfield (sort( keys %{$tagslib->{$tag}})) {
						next if ($tagdefined{$tag} );
						next if (length $subfield !=1);
						next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
						next if ((substr($tagslib->{$tag}->{$subfield}->{hidden},2,1) gt "1")  ); #check for visibility flag
						
						push(@subfields_data, &create_input($tag,$subfield,'',$i,$tabloop,$xmlhash,$authorised_values_sth,$id));
						$tagdefined{$tag.$subfield}=1;
						$i++;
					}
					if ($#subfields_data >= 0) {
						my %tag_data;
						$tag_data{tag} = $tag;
						$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
						$tag_data{repeatable} = $tagslib->{$tag}->{repeatable};
						$tag_data{indicator} = $ind1.$ind2 if ($tag>=10);
						$tag_data{subfield_loop} = \@subfields_data;
						if ($tag<10) {
                                                			$tag_data{fixedfield} = 1;
                                        				}

						push (@loop_data, \%tag_data);
					}

					
					if ($addedfield eq $tag) {
						my %tag_data;
						my @subfields_data;
						$id++;
						$tagdefined{$tag}=1 ;
						foreach my $subfield (sort( keys %{$tagslib->{$tag}})) {
						next if (length $subfield !=1);
						next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
						next if ((substr($tagslib->{$tag}->{$subfield}->{hidden},2,1) gt "1")  ); #check for visibility flag
						$addedfield="";	
						push(@subfields_data, &create_input($tag,$subfield,'',$i,$tabloop,$xmlhash,$authorised_values_sth,$id));
						$i++;
							}
						if ($#subfields_data >= 0) {
						$tag_data{tag} = $tag;
						$tag_data{tag_lib} = $tagslib->{$tag}->{lib};
						$tag_data{repeatable} = $tagslib->{$tag}->{repeatable};
						$tag_data{indicator} = ' ' if ($tag>=10);
						$tag_data{subfield_loop} = \@subfields_data;
							if ($tag<10) {
                                                				$tag_data{fixedfield} = 1;
                                        					}
						push (@loop_data, \%tag_data);
											
						}
				
					}
				
	# if breeding is empty
			} else {
				my @subfields_data;
				foreach my $subfield (sort(keys %{$tagslib->{$tag}})) {
					next if (length $subfield !=1);
					next if ((substr($tagslib->{$tag}->{$subfield}->{hidden},2,1) gt "1")  ); #check for visibility flag
					next if ($tagslib->{$tag}->{$subfield}->{tab} ne $tabloop);
					push(@subfields_data, &create_input($tag,$subfield,'',$i,$tabloop,$xmlhash,$authorised_values_sth,$id));
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
		$id++;
	}
	if ($#loop_data >=0) {
            my %big_loop_line;
            $big_loop_line{number}=$tabloop;
            $big_loop_line{innerloop}=\@loop_data;
            push @BIG_LOOP,\%big_loop_line;
            }	
		$template->param(BIG_LOOP => \@BIG_LOOP);
}## tab loop
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
	    $subfield_data{marc_value}="<input type=\"hidden\"  name=\"field_value[]\">";
	    push(@loop_data, \%subfield_data);
	    $i++
	}
    }
}


# ======================== 
#          MAIN 
#=========================
my $input = new CGI;
my $error = $input->param('error');
my $oldbiblionumber=$input->param('oldbiblionumber'); # if bib exists, it's a modif, not a new biblio.
my $breedingid = $input->param('breedingid');
my $z3950 = $input->param('z3950');
my $op = $input->param('op');
my $duplicateok = $input->param('duplicateok');

my $frameworkcode = $input->param('frameworkcode');
my $dbh = C4::Context->dbh;
my $biblionumber;

$biblionumber=$oldbiblionumber if $oldbiblionumber;

$frameworkcode='' if ($frameworkcode eq 'Default');
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/addbiblio.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

#Getting the list of all frameworks
my $queryfwk =$dbh->prepare("select frameworktext, frameworkcode from biblios_framework");
$queryfwk->execute;
my %select_fwk;
my @select_fwk;
my $curfwk;
push @select_fwk,"Default";
$select_fwk{"Default"} = "Default";
while (my ($description, $fwk) =$queryfwk->fetchrow) {
	push @select_fwk, $fwk;
	$select_fwk{$fwk} = $description;
}
$curfwk=$frameworkcode;
my $framework=CGI::scrolling_list( -name     => 'Frameworks',
			-id => 'Frameworks',
			-default => $curfwk,
			-OnChange => 'Changefwk(this);',
			-values   => \@select_fwk,
			-labels   => \%select_fwk,
			-size     => 1,
			-multiple => 0 );
$template->param( framework => $framework);
my $xmlhash;
my $xml;
#####DO NOT RETRIVE FROM ZEBRA######
my $record =XMLgetbiblio($dbh,$biblionumber) if ($biblionumber);
$xmlhash=XML_xml2hash_onerecord($record) if ($biblionumber);
$frameworkcode=MARCfind_frameworkcode( $dbh, $biblionumber );
###########
$tagslib = &MARCgettagslib($dbh,1,$frameworkcode);

my $encoding="";
($xmlhash,$encoding) = MARCfindbreeding($dbh,$breedingid,$oldbiblionumber) if ($breedingid);

$is_a_modif=0;
$is_a_modif=1 if $oldbiblionumber; 
my ($oldbiblionumtagfield,$oldbiblionumtagsubfield);
if ($biblionumber  && !$z3950) {
	$is_a_modif=1;
	# if it's a modif, retrieve old biblionumber for the future modification of old-DB.
	($oldbiblionumtagfield,$oldbiblionumtagsubfield) = &MARCfind_marc_from_kohafield($dbh,"biblionumber","biblios");

	
}
#------------------------------------------------------------------------------------------------------------------------------
if ($op eq "addbiblio") {
#------------------------------------------------------------------------------------------------------------------------------
	# rebuild
	my @tags = $input->param('tag');
	my @subfields =$input->param('subfield');
	my @values=$input->param('field_value');
	# build indicator hash.
	my @ind_tag = $input->param('ind_tag');
	my @indicator = $input->param('indicator');
	my @tagindex=$input->param('tagindex');
	
	
## check for malformed xml -- non UTF-8 like (MARC8) will break xml without warning
### This usually happens with data coming from other Z3950 servers
## Slows the saving process so comment out at your own risk
eval{
 $xml = MARChtml2xml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag,\@tagindex);	
};
 if ($@){
warn $@;
 $template->param(error             =>1,xmlerror=>1,);
goto FINAL;
  };
my $xmlhash=XML_xml2hash_onerecord($xml);
	my ($duplicatebiblionumber,$duplicatetitle) = FindDuplicate($xmlhash) if (($op eq "addbiblio") && (!$is_a_modif) && (!$duplicateok));
	my $confirm_not_duplicate = $input->param('confirm_not_duplicate');
	# it is not a duplicate (determined either by Koha itself or by user checking it's not a duplicate)
	if (!$duplicatebiblionumber or $confirm_not_duplicate) {
		# MARC::Record built => now, record in DB
		my $oldbibnum;
		my $oldbibitemnum;
		if ($is_a_modif) {
			NEWmodbiblio($dbh,$biblionumber,$xmlhash,$frameworkcode);

		} else {

			($biblionumber) = NEWnewbiblio($dbh,$xmlhash,$frameworkcode);

		}
	# now, redirect to additem page
		unless ($fromserials){
		print $input->redirect("additem.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode") unless $fromserials;
		exit;
		}else{
		my $title=XML_readline_onerecord($xmlhash,"title","biblios");
		$template->param(exit=>1,biblionumber=>$biblionumber,title=>$title);
		goto FINAL;
		}

	} else {
FINAL:
	# it may be a duplicate, warn the user and do nothing
		build_tabs ($template, $xmlhash, $dbh);
		build_hidden_data;
		$template->param(fromserials=>$fromserials,
			oldbiblionumber             => $oldbiblionumber,
			biblionumber                      => $biblionumber,
			oldbiblionumtagfield        => $oldbiblionumtagfield,
			oldbiblionumtagsubfield     => $oldbiblionumtagsubfield,
			duplicatebiblionumber		=> $duplicatebiblionumber,
			duplicatetitle				=> $duplicatetitle,
			 );
	}
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
	my @tagindex=$input->param('tagindex');
	my $xml = MARChtml2xml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag,\@tagindex);
	my $xmlhash=XML_xml2hash_onerecord($xml);
	# adding an empty field
	build_tabs ($template, $xmlhash, $dbh,$addedfield);
	build_hidden_data;
	$template->param(
		oldbiblionumber             => $oldbiblionumber,
		biblionumber                     => $biblionumber,
		oldbiblionumtagfield        => $oldbiblionumtagfield,
		oldbiblionumtagsubfield     => $oldbiblionumtagsubfield,
		fromserials=>$fromserials
		 );
} elsif ($op eq "delete") {
#------------------------------------------------------------------------------------------------------------------------------
my $sth=$dbh->prepare("select iss.itemnumber from items i ,issues iss where iss.itemnumber=i.itemnumber and iss.returndate is null and  i.biblionumber=?");
 $sth->execute($biblionumber);
my $onloan=$sth->fetchrow;

 	if (!$onloan){	
	NEWdelbiblio($dbh,$biblionumber);
print	$input->redirect("/cgi-bin/koha/catalogue/catalogue-search.pl");
	exit;
	}else{

$template->param(error            => 1, onloan=>1,);
	}
#------------------------------------------------------------------------------------------------------------------------------
#------------------------------------------------------------------------------------------------------------------------------
} else {
#------------------------------------------------------------------------------------------------------------------------------

	# If we're in a duplication case, we have to set to "" the  biblionumber
	# as we'll save the biblio as a new one.
	if ($op eq "duplicate")
	{
		$biblionumber = "";
		$oldbiblionumber= "";
	$template->param(duplicateok            => 1);
	}
	build_tabs ($template, $xmlhash, $dbh);
	build_hidden_data;
	$template->param(
		oldbiblionumber             => $oldbiblionumber,
		biblionumber                       => $biblionumber,
		oldbiblionumtagfield        => $oldbiblionumtagfield,
		oldbiblionumtagsubfield     => $oldbiblionumtagsubfield,
		fromserials=>$fromserials			
		);
}
$template->param(
		isbntag             => $isbntag,
		isbnsub                       => $isbnsub,
		issntag             => $isbntag,
		issnsub                       => $issnsub,
		titletag             => $titletag,
		titlesub                       => $titlesub,
		authortag             => $authortag,
		authorsub                       => $authorsub,
		);

$template->param(
		frameworkcode => $frameworkcode,
		itemtype => $frameworkcode, # HINT: if the library has itemtype = framework, itemtype is auto filled !
		hide_marc => C4::Context->preference('hide_marc'),
		intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
		advancedMARCEditor => C4::Context->preference("advancedMARCEditor"),
		);

output_html_with_http_headers $input, $cookie, $template->output;
