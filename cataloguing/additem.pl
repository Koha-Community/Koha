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

use CGI;
use strict;
use C4::Auth;
use C4::Output;
use C4::Interface::CGI::Output;
use C4::Biblio;
use C4::Context;
use C4::Koha; # XXX subfield_is_koha_internal_p
use C4::Search;
use C4::Circulation::Circ2;
use C4::Log;

my $logstatus=C4::Context->preference('Activate_log');

sub find_value {
	my ($tagfield,$insubfield,$record) = @_;
	my $result;
	my $indicator;
my $item=$record->{datafield};
my $controlfield=$record->{controlfield};
my $leader=$record->{leader};
 if ($tagfield eq '000'){
## We are getting the leader
$result=$leader->[0];
return($indicator,$result);
}
     if ($tagfield <10){
	foreach my $control (@$controlfield) {
		if ($control->{tag} eq $tagfield){
		$result.=$control->{content};
		}
	}
      }else{
	foreach my $field (@$item) {		
	      if ($field->{tag} eq $tagfield){	
		    foreach my $subfield ( $field->{'subfield'}){
		       foreach my $code ( @$subfield){
			if ($code->{code} eq $insubfield) {
				$result .= $code->{content};
				$indicator = $field->{ind1}.$field->{ind2};
			}
		      }## each code
		  }##each subfield
	      }## if tag
	}### $field
     }## tag<10
	return($indicator,$result);
}
my $input = new CGI;
my $dbh = C4::Context->dbh;
my $error = $input->param('error');
my $biblionumber = $input->param('biblionumber');
my $oldbiblionumber =$biblionumber;
my $frameworkcode=$input->param('frameworkcode');
my $op = $input->param('op');
my $itemnumber = $input->param('itemnumber');
my $fromserials=$input->param('fromserials');## if a serial is being added do not display navigation menus
my $serialid=$input->param('serialid');
my @itemrecords; ##Builds existing items
my $bibliorecord; #Bibliorecord relared to this item
my $newrecord; ## the new record buing built
my $itemrecexist; #item record we are editing
my $xml; ## data on html
 $frameworkcode=MARCfind_frameworkcode($dbh,$biblionumber) unless $frameworkcode;
my $tagslib = &MARCitemsgettagslib($dbh,1,$frameworkcode);
my $itemrecord;
my $nextop="additem";
my @errors; # store errors found while checking data BEFORE saving item.


my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "cataloguing/additem.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {editcatalogue => 1},
			     debug => 1,
			     });

#------------------------------------------------------------------------------------------------------------------------------
if ($op eq "additem") {
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
## check for malformed xml -- non UTF-8 like (MARC8) will break xml without warning
### This usually happens with data coming from other Z3950 servers
## Slows the saving process so comment out at your own risk
eval{
 $xml = MARChtml2xml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag);	
};
 if ($@){
push @errors,"non_utf8" ;
$nextop = "additem";
goto FINAL;
  };
 my $newrecord=XML_xml2hash_onerecord($xml);
my $newbarcode=XML_readline_onerecord($newrecord,"barcode","holdings");	

	# if autoBarcode is ON, calculate barcode...
	if (C4::Context->preference('autoBarcode')) {	
		unless ($newbarcode) {
			my $sth_barcode = $dbh->prepare("select max(abs(barcode)) from items");
			$sth_barcode->execute;
			($newbarcode) = $sth_barcode->fetchrow;
			$newbarcode++;
			# OK, we have the new barcode, now create the entry in MARC record
			$newrecord=XML_writeline( $newrecord, "barcode", $newbarcode,"holdings" );
		}
	}
# check for item barcode # being unique
	my ($oldrecord)=XMLgetitem($dbh,"",$newbarcode);
	
	push @errors,"barcode_not_unique" if($oldrecord);
# MARC::Record builded => now, record in DB
## User may be keeping serialids in marc records -- check and add it 
if ($fromserials){
$newrecord=XML_writeline( $newrecord, "serialid", $serialid,"holdings" );
}
	# if barcode exists, don't create, but report the problem.
	unless ($oldrecord){
	  $itemnumber=NEWnewitem($dbh,$newrecord,$biblionumber) ;
		if ($fromserials){
		my $holdingbranch=XML_readline_onerecord($newrecord,"holdingbranch","holdings");	
		$template->param(exit=>1,holdingbranch=>$holdingbranch);
		}
	$nextop = "additem";
	}
	else{
		$nextop = "additem";
		$itemrecexist = $newrecord;
	} 
#------------------------------------------------------------------------------------------------------------------------------
} elsif ($op eq "edititem") {
#------------------------------------------------------------------------------------------------------------------------------
# retrieve item if exist => then, it's a modif
	 ($itemrecexist) = XMLgetitemhash($dbh,$itemnumber);## item is already in our array-getit
	$nextop="saveitem";
	
#logaction($loggedinuser,"acqui.simple","modify",$oldbiblionumber,"item : ".$itemnumber) if ($logstatus);
	
#------------------------------------------------------------------------------------------------------------------------------
} elsif ($op eq "delitem") {
#------------------------------------------------------------------------------------------------------------------------------
# retrieve item if exist => then, it's a modif
my $sth=$dbh->prepare("select * from issues i where i.returndate is null and i.itemnumber=?");
 $sth->execute($itemnumber);
my $onloan=$sth->fetchrow;
push @errors,"book_on_loan" if ($onloan);
	if ($onloan){
	$nextop = "additem";
}else{
	&NEWdelitem($dbh,$itemnumber);
	$nextop="additem";
}
#------------------------------------------------------------------------------------------------------------------------------
} elsif ($op eq "saveitem") {
#------------------------------------------------------------------------------------------------------------------------------
	# rebuild
#warn "save item";
	my @tags = $input->param('tag');
	my @subfields = $input->param('subfield');
	my @values = $input->param('field_value');
	# build indicator hash.
	my @ind_tag = $input->param('ind_tag');
	my @indicator = $input->param('indicator');
	my $itemnumber = $input->param('itemnumber');
	my %indicators;
	for (my $i=0;$i<=$#ind_tag;$i++) {
		$indicators{$ind_tag[$i]} = $indicator[$i];
	}
## check for malformed xml -- non UTF-8 like (MARC8) will break xml without warning
### This usually happens with data coming from other Z3950 servers
## Slows the saving process so comment out at your own risk
eval{
 $xml = MARChtml2xml(\@tags,\@subfields,\@values,\@indicator,\@ind_tag);	
};
	 if ($@){
push @errors,"non_utf8" ;
$nextop = "edititem";
goto FINAL;
  };
 my $newrecord=XML_xml2hash_onerecord($xml);
	my $newbarcode=XML_readline_onerecord($newrecord,"barcode","holdings");
	my ($oldrecord)=XMLgetitem($dbh,"",$newbarcode);
	$oldrecord=XML_xml2hash_onerecord($oldrecord);
	my $exist=XML_readline_onerecord($oldrecord,"itemnumber","holdings") if $oldrecord;
	if ($exist && ($exist ne $itemnumber)){
	push @errors,"barcode_not_unique" ; ## Although editing user may have changed the barcode
	$nextop="edititem";
	}else{
	 NEWmoditem($dbh,$newrecord,$biblionumber,$itemnumber);
	$itemnumber="";
	$nextop="additem";

	}
}

#
#------------------------------------------------------------------------------------------------------------------------------
# build screen with existing items. and "new" one
#------------------------------------------------------------------------------------------------------------------------------
FINAL:
my %indicators;
$indicators{995}='  ';
# now, build existing item list
###DO NOT CHANGE TO RETRIVE FROM ZEBRA#####
my $record =XMLgetbiblio($dbh,$biblionumber);
$bibliorecord=XML_xml2hash_onerecord($record);
my @itemxmls=XMLgetallitems($dbh,$biblionumber);
	foreach my $itemrecord(@itemxmls){
	my $itemhash=XML_xml2hash($itemrecord);
	push @itemrecords, $itemhash;
	}
####



my ($itemtagfield,$itemtagsubfield) = &MARCfind_marc_from_kohafield("itemnumber","holdings");
my @itemnums;
my @fields;
my %witness; #---- stores the list of subfields used at least once, with the "meaning" of the code
my @big_array;
my @item_value_loop;
my @header_value_loop;
unless($fromserials){ ## do not display existing items if adding a serial. It could be a looong list
foreach my $itemrecord (@itemrecords){

my $item=$itemrecord->{datafield};
my $controlfield=$itemrecord->{controlfield};
my $leader=$itemrecord->{leader};
my %this_row;
	### The leader
	unless ($tagslib->{'000'}->{'@'}->{tab}  ne 10 || substr($tagslib->{'000'}->{'@'}->{hidden},1,1)>0){
	my @datasub='000@';
	$witness{$datasub[0]} = $tagslib->{'000'}->{'@'}->{lib};
	$this_row{$datasub[0]} =$leader->[0];
	}## leader
	foreach my $control (@$controlfield){
		push @itemnums,$control->{content} if ($control->{tag} eq $itemtagfield);
		next if ($tagslib->{$control->{tag}}->{'@'}->{tab}  ne 10);
		next if (substr($tagslib->{$control->{tag}}->{'@'}->{hidden},1,1)>0);	
					
			my @datasub=$control->{tag}.'@';
			$witness{$datasub[0]} = $tagslib->{$control->{tag}}->{'@'}->{lib};
			$this_row{$datasub[0]} =$control->{content};		     	
	}## Controlfields 
	foreach my $data (@$item){
		foreach my $subfield ( $data->{'subfield'}){
		   	foreach my $code ( @$subfield){	
			# loop through each subfield			
			push @itemnums,$code->{content} if ($data->{tag} eq $itemtagfield && $code->{code} eq $itemtagsubfield);
			next if ($tagslib->{$data->{tag}}->{$code->{code}}->{tab}  ne 10);
			next if (substr($tagslib->{$data->{tag}}->{$code->{code}}->{hidden},1,1)>0);
			$witness{$data->{tag}.$code->{code}} = $tagslib->{$data->{tag}}->{$code->{code}}->{lib};
			$this_row{$data->{tag}.$code->{code}} =$code->{content};
			}
			
		}# subfield
	
	}## each data
	if (%this_row) {
	push(@big_array, \%this_row);
	}
}## each record
#fill big_row with missing datas
foreach my $subfield_code  (keys(%witness)) {
	for (my $i=0;$i<=$#big_array;$i++) {
		$big_array[$i]{$subfield_code}="&nbsp;" unless ($big_array[$i]{$subfield_code});
	}
}
# now, construct template !

for (my $i=0;$i<=$#big_array; $i++) {
	my $items_data;
	foreach my $subfield_code (sort keys(%witness)) {
		$items_data .="<td>".$big_array[$i]{$subfield_code}."</td>";
	}
	my %row_data;
	$row_data{item_value} = $items_data;
	$row_data{itemnumber} = $itemnums[$i];
	push(@item_value_loop,\%row_data);
}
foreach my $subfield_code (sort keys(%witness)) {
	my %header_value;
	$header_value{header_value} = $witness{$subfield_code};
	push(@header_value_loop, \%header_value);
}
}## unless from serials
# next item form
my @loop_data =();
my $i=0;
my $authorised_values_sth = $dbh->prepare("select authorised_value,lib from authorised_values where category=? order by lib");

foreach my $tag (sort keys %{$tagslib}) {
 if ($itemtagfield <10){
next if($tag==$itemtagfield);
}
	my $previous_tag = '';
# loop through each subfield
	foreach my $subfield (sort keys %{$tagslib->{$tag}}) {
		next if subfield_is_koha_internal_p($subfield);
		next if ($tagslib->{$tag}->{$subfield}->{'tab'}  ne "10");
		next if  ($tagslib->{$tag} eq $itemtagfield && $tagslib->{$tag}->{$subfield} eq $itemtagsubfield);
		my %subfield_data;
		$subfield_data{tag}=$tag;
		$subfield_data{subfield}=$subfield;
		$subfield_data{marc_lib}="<span id=\"error$i\">".$tagslib->{$tag}->{$subfield}->{lib}."</span>";
		$subfield_data{mandatory}=$tagslib->{$tag}->{$subfield}->{mandatory};
		$subfield_data{repeatable}=$tagslib->{$tag}->{$subfield}->{repeatable};
	$subfield_data{hidden}= "display:none" if (substr($tagslib->{$tag}->{$subfield}->{hidden},2,1)>0);
	
		my ($x,$value);
		($x,$value) = find_value($tag,$subfield,$itemrecexist) if ($itemrecexist);
		# search for itemcallnumber if applicable
		my ($itemcntag,$itemcntagsub)=MARCfind_marc_from_kohafield("itemcallnumber","holdings");
		if ($tag eq $itemcntag && $subfield eq $itemcntagsub && C4::Context->preference('itemcallnumber')) {
			my $CNtag = substr(C4::Context->preference('itemcallnumber'),0,3);
			my $CNsubfield = substr(C4::Context->preference('itemcallnumber'),3,1);
			my $CNsubfield2 = substr(C4::Context->preference('itemcallnumber'),4,1);
			my $temp1 = XML_readline_onerecord($bibliorecord,"","",$CNtag,$CNsubfield);
			my $temp2 = XML_readline_onerecord($bibliorecord,"","",$CNtag,$CNsubfield2);
			$value = $temp1.' '.$temp2;
			$value=~s/^\s+|\s+$//g;
			
		}
		if ($tagslib->{$tag}->{$subfield}->{authorised_value}) {
			my @authorised_values;
			my %authorised_lib;
			# builds list, depending on authorised value...
			#---- branch
			if ($tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
				my $sth=$dbh->prepare("select branchcode,branchname from branches order by branchname");
				$sth->execute;
				push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
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
			#---- "true" authorised value
			} else {
				$authorised_values_sth->execute($tagslib->{$tag}->{$subfield}->{authorised_value});
				push @authorised_values, "" unless ($tagslib->{$tag}->{$subfield}->{mandatory});
				while (my ($value,$lib) = $authorised_values_sth->fetchrow_array) {
					push @authorised_values, $value;
					$authorised_lib{$value}=$lib;
				}
			}
			$subfield_data{marc_value}= CGI::scrolling_list(-name=>'field_value',
																		-values=> \@authorised_values,
																		-default=>"$value",																		-labels => \%authorised_lib,																		-size=>1,
																		-multiple=>0,												);
		} elsif ($tagslib->{$tag}->{$subfield}->{thesaurus_category}) {
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  size=47 maxlength=255 DISABLE READONLY> <a href=\"javascript:Dopop('../authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{authtypecode}."&index=$i',$i)\">...</a>";
			#"
		} elsif ($tagslib->{$tag}->{$subfield}->{'value_builder'}) {
		my $cgidir = C4::Context->intranetdir ."/cgi-bin/value_builder";
		unless (opendir(DIR, "$cgidir")) {
			$cgidir = C4::Context->intranetdir."/value_builder";
		} 
		my $plugin=$cgidir."/".$tagslib->{$tag}->{$subfield}->{'value_builder'}; 
		require $plugin;
		my $extended_param = plugin_parameters($dbh,$newrecord,$tagslib,$i,0);
		my ($function_name,$javascript) = plugin_javascript($dbh,$newrecord,$tagslib,$i,0);
		$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\"  value=\"$value\" size=\"47\" maxlength=\"255\" DISABLE READONLY OnFocus=\"javascript:Focus$function_name($i)\" OnBlur=\"javascript:Blur$function_name($i)\"> <a href=\"javascript:Clic$function_name($i)\">...</a> $javascript";
		} else {
			$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\" value=\"$value\" size=50 maxlength=255>";
		}
#		$subfield_data{marc_value}="<input type=\"text\" name=\"field_value\">";
		push(@loop_data, \%subfield_data);
		$i++
	}
}


# what's the next op ? it's what we are not in : an add if we're editing, otherwise, and edit.
$template->param(item_loop => \@item_value_loop,
						item_header_loop => \@header_value_loop,
						biblionumber =>$biblionumber,
						title => &XML_readline_onerecord($bibliorecord,"title","biblios"),
						author => &XML_readline_onerecord($bibliorecord,"author","biblios"),
						item => \@loop_data,
						itemnumber => $itemnumber,
						itemtagfield => $itemtagfield,
						itemtagsubfield =>$itemtagsubfield,
						op => $nextop,
						opisadd => ($nextop eq "saveitem")?0:1,
						fromserials=>$fromserials, serialid=>$serialid,);
foreach my $error (@errors) {
	$template->param($error => 1);

}
output_html_with_http_headers $input, $cookie, $template->output;

sub XMLfinditem {
my ($itemnumber,@itemrecords)=@_;
foreach my $record (@itemrecords){
my $inumber=XML_readline_onerecord($record,"itemnumber","holdings");
	if ($inumber ==$itemnumber){
	return $record;
	}
}
}
