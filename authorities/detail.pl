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
use C4::AuthoritiesMarc;
use C4::Auth;
use C4::Context;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use C4::Koha;


my $query=new CGI;

my $dbh=C4::Context->dbh;
my $nonav = $query->param('nonav');
my $authid = $query->param('authid');
my $authtypecode = &AUTHfind_authtypecode($dbh,$authid);
my $tagslib = &AUTHgettagslib($dbh,1,$authtypecode);

my $xmlhash =XMLgetauthorityhash($dbh,$authid);

my ($count) = AUTHcount_usage($authid);

#chop;

# open template
my ($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "authorities/detail.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });


# fill arrays
my @loop_data =();
my $tag;
if ($xmlhash){
# loop through each tab 0 through 9
my $author=$xmlhash->{'datafield'};
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
	foreach my $data (@$author){
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
			} else {
			$subfield_data{marc_value}=get_authorised_value_desc($data->{'tag'}, $code->{'code'}, $value, '', $dbh);
			}
			$subfield_data{marc_subfield}=$code->{'code'};
			$subfield_data{marc_tag}=$data->{'tag'};
			push(@subfields_data, \%subfield_data);
		     }### $code
		
		
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

$template->param(authid => $authid,
				count => $count,
				authtypetext => $authtypes->{$authtypecode}{'authtypetext'},
				authtypecode => $authtypes->{$authtypecode}{'authtypecode'},
				authtypesloop => \@authtypesloop);
$template->param(nonav =>$nonav);
}### if $xmlash exist
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