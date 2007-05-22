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
use C4::Biblio;
use C4::Search;
use C4::Context;
use MARC::Record;
use C4::Log;
use C4::Koha; # XXX subfield_is_koha_internal_p
use Date::Calc qw(Today);

use MARC::File::USMARC;
use MARC::File::XML;
if (C4::Context->preference('marcflavour') eq 'UNIMARC') {
    MARC::File::XML->default_record_format( 'UNIMARC' );
}

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
        my $record = MARC::Record->new_from_usmarc($marc);
	if ($record->field('010')){ 
	foreach my $field ($record->field('010'))
		{
			foreach my $subfield ($field->subfield('a')){
  				my $newisbn = $field->subfield('a');
 				$newisbn =~ s/-//g;
 				$field->update( 'a' => $newisbn );
				
						
			}
# 			$record->insert_fields_ordered($record->field('010'));
		}		
	}
    	
    if ($record->subfield(100,'a')){
 	my $f100a=$record->subfield(100,'a');
 	my $f100 = $record->field(100);
 	my $f100temp = $f100->as_string;
 	$record->delete_field($f100);
 	if (length($f100temp)>28){
 	substr($f100temp,26,2,"50");
 	$f100->update('a' => $f100temp);
 	my $f100 = MARC::Field->new('100','','','a' => $f100temp);
 	$record->insert_fields_ordered($f100);
 	}
    }
        if (ref($record) eq undef) {
            return -1;
        } else {
            if (C4::Context->preference("z3950NormalizeAuthor") and C4::Context->preference("z3950AuthorAuthFields")){
                my ($tag,$subfield) = GetMarcFromKohaField("biblio.author");
#                 my $summary = C4::Context->preference("z3950authortemplate");
                my $auth_fields = C4::Context->preference("z3950AuthorAuthFields");
                my @auth_fields= split /,/,$auth_fields;
                my $field;
                #warn $record->as_formatted;
                if ($record->field($tag)){
                    foreach my $tmpfield ($record->field($tag)->subfields){
#                        foreach my $subfieldcode ($tmpfield->subfields){
                        my $subfieldcode=shift @$tmpfield;
                        my $subfieldvalue=shift @$tmpfield;
                        if ($field){
                            $field->add_subfields("$subfieldcode"=>$subfieldvalue) if ($subfieldcode ne $subfield);
                        } else {
                            $field=MARC::Field->new($tag,"","",$subfieldcode=>$subfieldvalue) if ($subfieldcode ne $subfield);
                        }
                    }
#                    warn $field->as_formatted;
#                    }
                }
                $record->delete_field($record->field($tag));
                foreach my $fieldtag (@auth_fields){
                    next unless ($record->field($fieldtag));
                    my $lastname = $record->field($fieldtag)->subfield('a');
                    my $firstname= $record->field($fieldtag)->subfield('b');
                    my $title = $record->field($fieldtag)->subfield('c');
                    my $number= $record->field($fieldtag)->subfield('d');
                    if ($title){
#                         $field->add_subfields("$subfield"=>"[ ".ucfirst($title).ucfirst($firstname)." ".$number." ]");
                        $field->add_subfields("$subfield"=>ucfirst($title)." ".ucfirst($firstname)." ".$number);
                    }else{
#                         $field->add_subfields("$subfield"=>"[ ".ucfirst($firstname).", ".ucfirst($lastname)." ]");
                        $field->add_subfields("$subfield"=>ucfirst($firstname).", ".ucfirst($lastname));
                    }
                }
                $record->insert_fields_ordered($field);
            }
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
    my ($tag,$subfield,$value,$i,$tabloop,$rec,$authorised_values_sth) = @_;
    # must be encoded as utf-8 before it reaches the editor
        #use Encode;
        #$value = encode('utf-8', $value);
    $value =~ s/"/&quot;/g;
    # if there is no value provided but a default value in parameters, get it 
    unless ($value) {
        $value = $tagslib->{$tag}->{$subfield}->{defaultvalue};
        # get today date & replace YYYY, MM, DD if provided in the default value
        my ($year,$month,$day) = Today();
        $month = sprintf("%02d",$month);
        $day = sprintf("%02d",$day);
        $value =~ s/YYYY/$year/g;
        $value =~ s/MM/$month/g;
        $value =~ s/DD/$day/g;
        
    }
    my $dbh = C4::Context->dbh;
    my %subfield_data;
    $subfield_data{tag}=$tag;
    $subfield_data{subfield}=$subfield;
    $subfield_data{marc_lib}="<span id=\"error$i\" title=\"".$tagslib->{$tag}->{$subfield}->{lib}."\">".substr($tagslib->{$tag}->{$subfield}->{lib},0,15)."</span>";
    $subfield_data{marc_lib_plain}=$tagslib->{$tag}->{$subfield}->{lib};
    $subfield_data{tag_mandatory}=$tagslib->{$tag}->{mandatory};
    $subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
    $subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
    $subfield_data{kohafield}=$tagslib->{$tag}->{$subfield}->{kohafield};
    $subfield_data{index} = $i;
    $subfield_data{visibility} = "display:none" unless (($tagslib->{$tag}->{$subfield}->{hidden}%2==0) or $value ne ''); #check parity
    # it's an authorised field
    if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
        $subfield_data{marc_value}= build_authorized_values_list($tag, $subfield, $value, $dbh,$authorised_values_sth);
    # it's a thesaurus / authority field
    } elsif ($tagslib->{$tag}->{$subfield}->{authtypecode}) {
        $subfield_data{marc_value}="<input type=\"text\" onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffff00;'\"\" tabindex=\"1\" type=\"text\" name=\"field_value\" value=\"$value\" size=\"70\" maxlength=\"255\" DISABLE READONLY> <a  style=\"cursor: help;\" href=\"javascript:Dopop('../authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{authtypecode}."&index=$i',$i)\">...</a>";
    # it's a plugin field
    } elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
        # opening plugin. Just check wether we are on a developper computer on a production one
        # (the cgidir differs)
        my $cgidir = C4::Context->intranetdir ."/cgi-bin/cataloguing/value_builder";
        unless (opendir(DIR, "$cgidir")) {
            $cgidir = C4::Context->intranetdir."/cataloguing/value_builder";
        }
        my $plugin=$cgidir."/".$tagslib->{$tag}->{$subfield}->{'value_builder'};
        do $plugin;
        my $extended_param = plugin_parameters($dbh,$rec,$tagslib,$i,$tabloop);
        my ($function_name,$javascript) = plugin_javascript($dbh,$rec,$tagslib,$i,$tabloop);
        $subfield_data{marc_value}="<input tabindex=\"1\" type=\"text\" name=\"field_value\"  value=\"$value\" size=\"70\" maxlength=\"255\" OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i); \"> <a  style=\"cursor: help;\" href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
    # it's an hidden field
    } elsif  ($tag eq '') {
         $subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffff00'; \" tabindex=\"1\" type=\"hidden\" name=\"field_value\" value=\"$value\">";
    } elsif  ($tagslib->{$tag}->{$subfield}->{'hidden'}) {
        $subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffff00'; \" tabindex=\"1\" type=\"text\" name=\"field_value\" value=\"$value\" size=\"70\" maxlength=\"255\" >";
    # it's a standard field
    } else {
        if (length($value) >100 or (C4::Context->preference("marcflavour") eq "UNIMARC" && $tag >=300 and $tag <400 && $subfield eq 'a') or ($tag >=500 and $tag <600 && C4::Context->preference("marcflavour") eq "MARC21")) {
            $subfield_data{marc_value}="<textarea tabindex=\"1\" name=\"field_value\" cols=\"70\" rows=\"5\" >$value</textarea>";
        } else {
            $subfield_data{marc_value}="<input onblur=\"this.style.backgroundColor='#ffffff';\" onfocus=\"this.style.backgroundColor='#ffff00'; \" tabindex=\"1\" type=\"text\" name=\"field_value\" value=\"$value\" size=\"70\">"; #"
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
    
    # in this array, we will push all the 10 tabs
    # to avoid having 10 tabs in the template : they will all be in the same BIG_LOOP
    my @BIG_LOOP;

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
                        next if ($tagslib->{$tag}->{$subfield}->{kohafield} eq 'biblio.biblionumber');
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
                        next if (($tagslib->{$tag}->{$subfield}->{hidden}<=-4) or ($tagslib->{$tag}->{$subfield}->{hidden}>=5) ); #check for visibility flag
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
    # if breeding is empty
            } else {
                my @subfields_data;
                foreach my $subfield (sort(keys %{$tagslib->{$tag}})) {
                    next if (length $subfield !=1);
                    next if (($tagslib->{$tag}->{$subfield}->{hidden}<=-5) or ($tagslib->{$tag}->{$subfield}->{hidden}>=4) ); #check for visibility flag
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
        if ($#loop_data >=0) {
            my %big_loop_line;
            $big_loop_line{number}=$tabloop;
            $big_loop_line{innerloop}=\@loop_data;
            push @BIG_LOOP,\%big_loop_line;
        }
#         $template->param($tabloop."XX" =>\@loop_data);
    }
    $template->param(BIG_LOOP => \@BIG_LOOP);
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
my $error = $input->param('error');
my $biblionumber=$input->param('biblionumber'); # if biblionumber exists, it's a modif, not a new biblio.
my $breedingid = $input->param('breedingid');
my $z3950 = $input->param('z3950');
my $op = $input->param('op');
my $frameworkcode = $input->param('frameworkcode');
my $dbh = C4::Context->dbh;

$frameworkcode = &GetFrameworkCode($biblionumber) if ($biblionumber and not ($frameworkcode));

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
my $queryfwk =$dbh->prepare("select frameworktext, frameworkcode from biblio_framework");
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
my $framework=CGI::scrolling_list( 
            -name     => 'Frameworks',
            -id => 'Frameworks',
            -default => $curfwk,
            -OnChange => 'Changefwk(this);',
            -values   => \@select_fwk,
            -labels   => \%select_fwk,
            -size     => 1,
            -multiple => 0 );
$template->param( framework => $framework, breedingid => $breedingid);

$tagslib = &GetMarcStructure(1,$frameworkcode);
my $record=-1;
my $encoding="";
$record = GetMarcBiblio( $biblionumber ) if ($biblionumber);
($record,$encoding) = MARCfindbreeding($dbh,$breedingid) if ($breedingid);

# warn "biblionumber : $biblionumber = ".$record->as_formatted;
$is_a_modif=0;
my ($biblionumtagfield,$biblionumtagsubfield);
my ($biblioitemnumtagfield,$biblioitemnumtagsubfield,$bibitem,$biblioitemnumber);
if ($biblionumber) {
    $is_a_modif=1;
    # if it's a modif, retrieve bibli and biblioitem numbers for the future modification of old-DB.
    ($biblionumtagfield,$biblionumtagsubfield) = &GetMarcFromKohaField("biblio.biblionumber",$frameworkcode);
    ($biblioitemnumtagfield,$biblioitemnumtagsubfield) = &GetMarcFromKohaField("biblioitems.biblioitemnumber",$frameworkcode);
    # search biblioitems value
    my $sth=$dbh->prepare("select biblioitemnumber from biblioitems where biblionumber=?");
    $sth->execute($biblionumber);
    ($biblioitemnumber) = $sth->fetchrow;
}
#-------------------------------------------------------------------------------------
if ($op eq "addbiblio") {
#-------------------------------------------------------------------------------------
    # rebuild
    my @tags = $input->param('tag');
    my @subfields = $input->param('subfield');
    my @values = $input->param('field_value');
    # build indicator hash.
    my @ind_tag = $input->param('ind_tag');
    my @indicator = $input->param('indicator');
    if (C4::Context->preference('TemplateEncoding') eq "iso-8859-1") {
        $record = TransformHtmlToMarc($dbh,\@tags,\@subfields,\@values,\@indicator,\@ind_tag);
    } else {
        my $xml = TransformHtmlToXml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag);
        $record=MARC::Record->new_from_xml($xml,C4::Context->preference('TemplateEncoding'),C4::Context->preference('marcflavour'));
#         warn "MARC :".$record->as_formatted;
#         die;
    }
    # check for a duplicate
    my ($duplicatebiblionumber,$duplicatebiblionumber,$duplicatetitle) = FindDuplicate($record) if ($op eq "addbiblio") && (!$is_a_modif);
    my $confirm_not_duplicate = $input->param('confirm_not_duplicate');
    # it is not a duplicate (determined either by Koha itself or by user checking it's not a duplicate)
    if (!$duplicatebiblionumber or $confirm_not_duplicate) {
        # MARC::Record built => now, record in DB
        my $oldbibnum;
        my $oldbibitemnum;
        if ($is_a_modif) {
            ModBiblioframework($biblionumber,$frameworkcode);
            ModBiblio($record,$biblionumber,$frameworkcode);
        }
        else {
            ($biblionumber,$oldbibitemnum) = AddBiblio($record,$frameworkcode);
        }
    # now, redirect to additem page
        print $input->redirect("additem.pl?biblionumber=$biblionumber&frameworkcode=$frameworkcode");
        exit;
    } else {
    # it may be a duplicate, warn the user and do nothing
        build_tabs ($template, $record, $dbh,$encoding);
        build_hidden_data;
        $template->param(
            biblionumber             => $biblionumber,
            biblionumtagfield        => $biblionumtagfield,
            biblionumtagsubfield     => $biblionumtagsubfield,
            biblioitemnumtagfield    => $biblioitemnumtagfield,
            biblioitemnumtagsubfield => $biblioitemnumtagsubfield,
            biblioitemnumber         => $biblioitemnumber,
            duplicatebiblionumber    => $duplicatebiblionumber,
            duplicatebibid           => $duplicatebiblionumber,
            duplicatetitle           => $duplicatetitle,
        );
    }
#--------------------------------------------------------------------------
} elsif ($op eq "addfield") {
#--------------------------------------------------------------------------
    my $addedfield = $input->param('addfield_field');
    my $cntrepeatfield=$input->param('repeat_field');
    $cntrepeatfield=1 unless ($cntrepeatfield);
    my $tagaddfield_subfield = $input->param('addfield_subfield');
    my @tags = $input->param('tag');
    my @subfields = $input->param('subfield');
    my @values = $input->param('field_value');
    # build indicator hash.
    my @ind_tag = $input->param('ind_tag');
    my @indicator = $input->param('indicator');
    my $xml = TransformHtmlToXml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag);
    my $record;
    if (C4::Context->preference('TemplateEncoding') eq "iso-8859-1") {
        my %indicators;
        for (my $i=0;$i<=$#ind_tag;$i++) {
            $indicators{$ind_tag[$i]} = $indicator[$i];
        }
        $record = TransformHtmlToMarc($dbh,\@tags,\@subfields,\@values,%indicators);
    } else {
        my $xml = TransformHtmlToXml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag);
        $record=MARC::Record->new_from_xml($xml,C4::Context->preference('TemplateEncoding'),C4::Context->preference('marcflavour'));
    }
    for (my $i=1;$i<=$cntrepeatfield;$i++){
        my $field = MARC::Field->new("$addedfield",'','',"$tagaddfield_subfield" => "");
        $record->append_fields($field);
    }
    #warn "result : ".$record->as_formatted;
    build_tabs ($template, $record, $dbh,$encoding);
    build_hidden_data;
    $template->param(
        biblionumber             => $biblionumber,
        biblionumtagfield        => $biblionumtagfield,
        biblionumtagsubfield     => $biblionumtagsubfield,
        biblioitemnumtagfield    => $biblioitemnumtagfield,
        biblioitemnumtagsubfield => $biblioitemnumtagsubfield,
        biblioitemnumber         => $biblioitemnumber );
} elsif ($op eq "delete") {
#-----------------------------------------------------------------------------
    my $error = &DelBiblio($biblionumber);
    if ($error) {
        warn "ERROR when DELETING BIBLIO $biblionumber : $error";
        print "Content-Type: text/html\n\n<html><body><h1>ERROR when DELETING BIBLIO $biblionumber : $error</h1></body></html>";
    } else {
    print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=/cgi-bin/koha/catalogue/search.pl?type=intranet\"></html>";
    }
    exit;
#----------------------------------------------------------------------------
} else {
#----------------------------------------------------------------------------
    # If we're in a duplication case, we have to set to "" the biblionumber
    # as we'll save the biblio as a new one.
    if ($op eq "duplicate")
    {
        $biblionumber= "";
    }
    #FIXME: it's kind of silly to go from MARC::Record to MARC::File::XML and then back again just to fix the encoding
    eval {
        my $uxml = $record->as_xml;
        MARC::Record::default_record_format("UNIMARC") if (C4::Context->preference("marcflavour") eq "UNIMARC");
        my $urecord = MARC::Record::new_from_xml($uxml, 'UTF-8');
        $record = $urecord;
    };
    build_tabs ($template, $record, $dbh,$encoding);
    build_hidden_data;
    $template->param(
        biblionumber             => $biblionumber,
        biblionumtagfield        => $biblionumtagfield,
        biblionumtagsubfield     => $biblionumtagsubfield,
        biblioitemnumtagfield    => $biblioitemnumtagfield,
        biblioitemnumtagsubfield => $biblioitemnumtagsubfield,
        biblioitemnumber         => $biblioitemnumber,
        );
}
$template->param( title => $record->title() ) if ($record ne "-1");
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
