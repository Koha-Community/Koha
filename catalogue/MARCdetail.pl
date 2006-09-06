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

MARCdetail.pl : script to show a biblio in MARC format

=head1 SYNOPSIS


=head1 DESCRIPTION

This script needs a biblionumber in bib parameter (bibnumber
from koha style DB.  Automaticaly maps to marc biblionumber).

It shows the biblio in a (nice) MARC format depending on MARC
parameters tables.

The template is in <templates_dir>/catalogue/MARCdetail.tmpl.
this template must be divided into 11 "tabs".

The first 10 tabs present the biblio, the 11th one presents
the items attached to the biblio

=head1 FUNCTIONS

=over 2

=cut


use strict;
use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use C4::Biblio;
use C4::Acquisition;
use C4::Serials; #uses getsubscriptionsfrombiblionumber
use C4::Koha;

my $query=new CGI;

my $dbh=C4::Context->dbh;
my $retrieve_from=C4::Context->preference('retrieve_from');
my $biblionumber=$query->param('biblionumber');
my $frameworkcode = $query->param('frameworkcode');
my $popup = $query->param('popup'); # if set to 1, then don't insert links, it's just to show the biblio
my $record;
my @itemrecords;
my $xmlhash;
$frameworkcode=MARCfind_frameworkcode($dbh,$biblionumber);
my $tagslib = &MARCgettagslib($dbh,1,$frameworkcode);
my $itemstagslib = &MARCitemsgettagslib($dbh,1,$frameworkcode);

if ($retrieve_from eq "zebra"){
($xmlhash,@itemrecords)=ZEBRAgetrecord($biblionumber);

}else{
 $record =XMLgetbiblio($dbh,$biblionumber);
$xmlhash=XML_xml2hash_onerecord($record);
my @itemxmls=XMLgetallitems($dbh,$biblionumber);
	foreach my $itemrecord(@itemxmls){
	my $itemhash=XML_xml2hash($itemrecord);
	push @itemrecords, $itemhash;
	}
}

my ($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "catalogue/MARCdetail.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
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
# fill arrays
my @loop_data =();
my $tag;
# loop through each tab 0 through 9
##Only attempt to fill the template if we actually received a MARC record
if ($xmlhash){
my ($isbntag,$isbnsub)=MARCfind_marc_from_kohafield("isbn","biblios");
my $biblio=$xmlhash->{'datafield'};
my $controlfields=$xmlhash->{'controlfield'};
my $leader=$xmlhash->{'leader'};
for (my $tabloop = 0; $tabloop<10;$tabloop++) {
# loop through each tag
	my @loop_data =();
	my @subfields_data;

	# deal with leader 
	unless (($tagslib->{'000'}->{'@'}->{tab}  ne $tabloop)  || (substr($tagslib->{'000'}->{'@'}->{hidden},1,1)>0)) {
		
		my %subfield_data;
		$subfield_data{marc_value}=$leader->[0] ;
		push(@subfields_data, \%subfield_data);
		my %tag_data;
		$tag_data{tag}='000 -'. $tagslib->{'000'}->{lib};
		my @tmp = @subfields_data;
		$tag_data{subfield} = \@tmp;
		push (@loop_data, \%tag_data);
		undef @subfields_data;
	}
	##Controlfields
		
		 foreach my $control (@$controlfields){
			my %subfield_data;
			my %tag_data;
			next if ($tagslib->{$control->{'tag'}}->{'@'}->{tab}  ne $tabloop);
			next if (substr($tagslib->{$control->{'tag'}}->{'@'}->{hidden},1,1)>0);			
			$subfield_data{marc_value}=$control->{'content'} ;
			push(@subfields_data, \%subfield_data);
				if (C4::Context->preference('hide_marc')) {
					$tag_data{tag}=$tagslib->{$control->{'tag'}}->{lib};
				} else {
					$tag_data{tag}=$control->{'tag'}.' -'. $tagslib->{$control->{'tag'}}->{lib};
				}			
			my @tmp = @subfields_data;
			$tag_data{subfield} = \@tmp;
			push (@loop_data, \%tag_data);
			undef @subfields_data;
		}
	my $previoustag;
	my %datatags;
	my $i=0;
	foreach my $data (@$biblio){
		$datatags{$i++}=$data->{'tag'};
		 foreach my $subfield ( $data->{'subfield'}){
		     foreach my $code ( @$subfield){
			next if ($tagslib->{$data->{'tag'}}->{$code->{'code'}}->{tab}  ne $tabloop);
			next if (substr($tagslib->{$data->{'tag'}}->{$code->{'code'}}->{hidden},1,1)>0);
			my %subfield_data;
			my $value=$code->{'content'};
			$subfield_data{marc_lib}=$tagslib->{$data->{'tag'}}->{$code->{'code'}}->{lib};
			$subfield_data{link}=$tagslib->{$data->{'tag'}}->{$code->{'code'}}->{link};
			if ($tagslib->{$data->{'tag'}}->{$code->{'code'}}->{isurl}) {
				$subfield_data{marc_value}="<a href=\"$value]\">$value</a>";
			} elsif ($data->{'tag'} eq $isbntag && $code->{'code'} eq $isbnsub) {
				$subfield_data{marc_value}=DisplayISBN($value);
			} else {
				if ($tagslib->{$data->{'tag'}}->{$code->{'code'}}->{authtypecode}) {
				my ($authtag,$authtagsub)=MARCfind_marc_from_kohafield("auth_authid","biblios");
				$subfield_data{authority}=XML_readline_onerecord($xmlhash,"","",$data->{'tag'},$authtagsub);
				}	
			$subfield_data{marc_value}=get_authorised_value_desc($data->{'tag'}, $code->{'code'}, $value, '', $dbh);
			}
			$subfield_data{marc_subfield}=$code->{'code'};
			$subfield_data{marc_tag}=$data->{'tag'};
			push(@subfields_data, \%subfield_data);
		     }### $code
		
		
		if ($#subfields_data==0) {
		#	$subfields_data[0]->{marc_lib}='';
		#	$subfields_data[0]->{marc_subfield}='';
		}
		if ($#subfields_data>=0) {
			my %tag_data;
			if (($datatags{$i} eq $datatags{$i-1}) && (C4::Context->preference('LabelMARCView') eq 'economical')) {
				$tag_data{tag}="";
			} else {
				if (C4::Context->preference('hide_marc')) {
					$tag_data{tag}=$tagslib->{$data->{'tag'}}->{lib};
				} else {
					$tag_data{tag}=$data->{'tag'}.' -'. $tagslib->{$data->{'tag'}}->{lib};
				}
			}
			my @tmp = @subfields_data;
			$tag_data{subfield} = \@tmp;
			push (@loop_data, \%tag_data);
			undef @subfields_data;
		}
	      }### each $subfield
	}

	$template->param($tabloop."XX" =>\@loop_data);
}
# now, build item tab !
# the main difference is that datas are in lines and not in columns : thus, we build the <th> first, then the values...
# loop through each tag
# warning : we may have differents number of columns in each row. Thus, we first build a hash, complete it if necessary
# then construct template.
my @fields;
my %witness; #---- stores the list of subfields used at least once, with the "meaning" of the code
my @big_array;
foreach my $itemrecord (@itemrecords){
my $item=$itemrecord->{'datafield'};
my $controlfields=$itemrecord->{'controlfield'};
my $leader=$itemrecord->{'leader'};
my %this_row;
		### The leader
		unless (substr($itemstagslib->{'000'}->{'@'}->{hidden},1,1)>0){
			my @datasub='000@';
			$witness{$datasub[0]} = $itemstagslib->{'000'}->{'@'}->{lib};
			$this_row{$datasub[0]} =$leader->[0];
		}
		 foreach my $control (@$controlfields){
		next if ($itemstagslib->{$control->{'tag'}}->{'@'}->{tab}  ne 10);
			next if (substr($itemstagslib->{$control->{'tag'}}->{'@'}->{hidden},1,1)>0);
			my @datasub=$control->{'tag'}.'@';
			$witness{$datasub[0]} = $itemstagslib->{$control->{'tag'}}->{'@'}->{lib};
			$this_row{$datasub[0]} =$control->{'content'};
		}

		foreach my $data (@$item){		
		   foreach my $subfield ( $data->{'subfield'}){
			foreach my $code ( @$subfield){
			next if ($itemstagslib->{$data->{'tag'}}->{$code->{'code'}}->{tab}  ne 10);
			next if (substr($itemstagslib->{$data->{'tag'}}->{$code->{'code'}}->{hidden},1,1)>0);
			$witness{$data->{'tag'}.$code->{'code'}} = $itemstagslib->{$data->{'tag'}}->{$code->{'code'}}->{lib};
			$this_row{$data->{'tag'}.$code->{'code'}} =$code->{'content'};
			}			
		    }# subfield
		}## each field
	if (%this_row) {
	push(@big_array, \%this_row);
	}
}## each record
my ($holdingbrtagf,$holdingbrtagsubf) = &MARCfind_marc_from_kohafield("holdingbranch","holdings");
@big_array = sort {$a->{$holdingbrtagsubf} cmp $b->{$holdingbrtagsubf}} @big_array;

#fill big_row with missing datas
foreach my $subfield_code  (keys(%witness)) {
	for (my $i=0;$i<=$#big_array;$i++) {
		$big_array[$i]{$subfield_code}="&nbsp;" unless ($big_array[$i]{$subfield_code});
	}
}
# now, construct template !
my @item_value_loop;
my @header_value_loop;
for (my $i=0;$i<=$#big_array; $i++) {
	my $items_data;
	foreach my $subfield_code (keys(%witness)) {
		$items_data .="<td>".$big_array[$i]{$subfield_code}."</td>";
	}
	my %row_data;
	$row_data{item_value} = $items_data;
	push(@item_value_loop,\%row_data);
}
foreach my $subfield_code (keys(%witness)) {
	my %header_value;
	$header_value{header_value} = $witness{$subfield_code};
	push(@header_value_loop, \%header_value);
}

my $subscriptionsnumber = GetSubscriptionsFromBiblionumber($biblionumber);
$template->param(item_loop => \@item_value_loop,
						item_header_loop => \@header_value_loop,
						biblionumber => $biblionumber,
						subscriptionsnumber => $subscriptionsnumber,
						popup => $popup,
						hide_marc => C4::Context->preference('hide_marc'),
						intranetcolorstylesheet => C4::Context->preference("intranetcolorstylesheet"),
		intranetstylesheet => C4::Context->preference("intranetstylesheet"),
		IntranetNav => C4::Context->preference("IntranetNav"),
						);
}##if $xmlhash
output_html_with_http_headers $query, $cookie, $template->output;

sub get_authorised_value_desc ($$$$$) {
   my($tag, $subfield, $value, $framework, $dbh) = @_;

   #---- branch
    if ($tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
       return getbranchname($value);
    }

   #---- itemtypes
   if ($tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "itemtypes" ) {
       return ItemType($value);
    }

   #---- "true" authorized value
   my $category = $tagslib->{$tag}->{$subfield}->{'authorised_value'};

   if ($category ne "") {
       my $sth = $dbh->prepare("select lib from authorised_values where category = ? and authorised_value = ?");
       $sth->execute($category, $value);
       my $data = $sth->fetchrow_hashref;
       return $data->{'lib'};
   } else {
       return $value; # if nothing is found return the original value
   }
}
