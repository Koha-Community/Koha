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

detail.pl : script to show an authority in MARC format

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
use CGI;
use MARC::Record;
use C4::Koha;
# use C4::Biblio;
# use C4::Catalogue;

our ($tagslib);

=item build_authorized_values_list

=cut

sub build_authorized_values_list ($$$$$$$) {
    my ( $tag, $subfield, $value, $dbh, $authorised_values_sth,$index_tag,$index_subfield ) = @_;

    my @authorised_values;
    my %authorised_lib;

    # builds list, depending on authorised value...

    #---- branch
    if ( $tagslib->{$tag}->{$subfield}->{'authorised_value'} eq "branches" ) {
        my $sth =
          $dbh->prepare(
            "select branchcode,branchname from branches order by branchname");
        $sth->execute;
        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );

        while ( my ( $branchcode, $branchname ) = $sth->fetchrow_array ) {
            push @authorised_values, $branchcode;
            $authorised_lib{$branchcode} = $branchname;
        }

        #----- itemtypes
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authorised_value} eq "itemtypes" ) {
        my $sth =
          $dbh->prepare(
            "select itemtype,description from itemtypes order by description");
        $sth->execute;
        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );
          
        my $itemtype;
        
        while ( my ( $itemtype, $description ) = $sth->fetchrow_array ) {
            push @authorised_values, $itemtype;
            $authorised_lib{$itemtype} = $description;
        }
        $value = $itemtype unless ($value);

        #---- "true" authorised value
    }
    else {
        $authorised_values_sth->execute(
            $tagslib->{$tag}->{$subfield}->{authorised_value} );

        push @authorised_values, ""
          unless ( $tagslib->{$tag}->{$subfield}->{mandatory} );

        while ( my ( $value, $lib ) = $authorised_values_sth->fetchrow_array ) {
            push @authorised_values, $value;
            $authorised_lib{$value} = $lib;
        }
    }
    return CGI::scrolling_list(
        -name     => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        -values   => \@authorised_values,
        -default  => $value,
        -labels   => \%authorised_lib,
        -override => 1,
        -size     => 1,
        -multiple => 0,
        -tabindex => 1,
        -id       => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        -class    => "input_marceditor",
    );
}


=item create_input
 builds the <input ...> entry for a subfield.
=cut

sub create_input {
    my ( $tag, $subfield, $value, $index_tag, $tabloop, $rec, $authorised_values_sth,$cgi ) = @_;
    
    my $index_subfield = CreateKey(); # create a specifique key for each subfield

    $value =~ s/"/&quot;/g;

    # if there is no value provided but a default value in parameters, get it
    unless ($value) {
        $value = $tagslib->{$tag}->{$subfield}->{defaultvalue};

        # get today date & replace YYYY, MM, DD if provided in the default value
        my ( $year, $month, $day ) = Today();
        $month = sprintf( "%02d", $month );
        $day   = sprintf( "%02d", $day );
        $value =~ s/YYYY/$year/g;
        $value =~ s/MM/$month/g;
        $value =~ s/DD/$day/g;
    }
    my $dbh = C4::Context->dbh;
    my %subfield_data = (
        tag        => $tag,
        subfield   => $subfield,
        marc_lib   => substr( $tagslib->{$tag}->{$subfield}->{lib}, 0, 22 ),
        marc_lib_plain => $tagslib->{$tag}->{$subfield}->{lib}, 
        tag_mandatory  => $tagslib->{$tag}->{mandatory},
        mandatory      => $tagslib->{$tag}->{$subfield}->{mandatory},
        repeatable     => $tagslib->{$tag}->{$subfield}->{repeatable},
        kohafield      => $tagslib->{$tag}->{$subfield}->{kohafield},
        index          => $index_tag,
        id             => "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield,
        value          => $value,
    );
    if($subfield eq '@'){
        $subfield_data{id} = "tag_".$tag."_subfield_00_".$index_tag."_".$index_subfield;
    } else {
         $subfield_data{id} = "tag_".$tag."_subfield_".$subfield."_".$index_tag."_".$index_subfield;
    }

    
    $subfield_data{visibility} = "display:none;"
        if (    ($tagslib->{$tag}->{$subfield}->{hidden} % 2 == 1) and $value ne ''
            or ($value eq '' and !$tagslib->{$tag}->{$subfield}->{mandatory})
        );
    
    # it's an authorised field
    if ( $tagslib->{$tag}->{$subfield}->{authorised_value} ) {
        $subfield_data{marc_value} =
          build_authorized_values_list( $tag, $subfield, $value, $dbh,
            $authorised_values_sth,$index_tag,$index_subfield );

    # it's a thesaurus / authority field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{authtypecode} ) {
        $subfield_data{marc_value} =
    "<input type=\"text\"
                        id=\"".$subfield_data{id}."\"
                        name=\"".$subfield_data{id}."\"
      value=\"$value\"
      class=\"input_marceditor\"
                        tabindex=\"1\"                     
      DISABLE READONLY \/>
      <span class=\"buttonDot\"
        onclick=\"Dopop('/cgi-bin/koha/authorities/auth_finder.pl?authtypecode=".$tagslib->{$tag}->{$subfield}->{authtypecode}."&index=$subfield_data{id}','$subfield_data{id}')\">...</span>
    ";
    # it's a plugin field
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'value_builder'} ) {

        # opening plugin. Just check wether we are on a developper computer on a production one
        # (the cgidir differs)
        my $cgidir = C4::Context->intranetdir . "/cgi-bin/cataloguing/value_builder";
        unless (-r $cgidir and -d $cgidir) {
            $cgidir = C4::Context->intranetdir . "/cataloguing/value_builder";
        }
        my $plugin = $cgidir . "/" . $tagslib->{$tag}->{$subfield}->{'value_builder'};
        do $plugin || die "Plugin Failed: ".$plugin;
        my $extended_param = plugin_parameters( $dbh, $rec, $tagslib, $subfield_data{id}, $tabloop );
        my ( $function_name, $javascript ) = plugin_javascript( $dbh, $rec, $tagslib, $subfield_data{id}, $tabloop );
#         my ( $function_name, $javascript,$extended_param );
        
        $subfield_data{marc_value} =
    "<input tabindex=\"1\"
                        type=\"text\"
                        id=".$subfield_data{id}."
      name=".$subfield_data{id}."
      value=\"$value\"
                        class=\"input_marceditor\"
      onfocus=\"javascript:Focus$function_name($index_tag)\"
      onblur=\"javascript:Blur$function_name($index_tag); \" \/>
    <span class=\"buttonDot\"
      onclick=\"Clic$function_name('$subfield_data{id}')\">...</a>
    $javascript";
        # it's an hidden field
    }
    elsif ( $tag eq '' ) {
        $subfield_data{marc_value} =
            "<input tabindex=\"1\"
                    type=\"hidden\"
                    id=".$subfield_data{id}."
                    name=".$subfield_data{id}."
                    value=\"$value\" \/>
            ";
    }
    elsif ( $tagslib->{$tag}->{$subfield}->{'hidden'} ) {
        $subfield_data{marc_value} =
            "<input type=\"text\"
                    id=".$subfield_data{id}."
                    name=".$subfield_data{id}."
                    class=\"input_marceditor\"
                    tabindex=\"1\"
                    value=\"$value\"
            \/>";

        # it's a standard field
    }
    else {
        if (
            length($value) > 100
            or
            ( C4::Context->preference("marcflavour") eq "UNIMARC" && $tag >= 300
                and $tag < 400 && $subfield eq 'a' )
            or (    $tag >= 500
                and $tag < 600
                && C4::Context->preference("marcflavour") eq "MARC21" )
          )
        {
            $subfield_data{marc_value} =
                "<textarea cols=\"70\"
                           rows=\"4\"
                           id=".$subfield_data{id}."
                           name=".$subfield_data{id}."
                           class=\"input_marceditor\"
                           tabindex=\"1\"
                           >$value</textarea>
                ";
        }
        else {
            $subfield_data{marc_value} =
                "<input type=\"text\"
                        id=".$subfield_data{id}."
                        name=".$subfield_data{id}."
                        value=\"$value\"
                        tabindex=\"1\"
                        class=\"input_marceditor\"
                \/>
                ";
        }
    }
    $subfield_data{'index_subfield'} = $index_subfield;
    return \%subfield_data;
}

=item CreateKey

    Create a random value to set it into the input name

=cut

sub CreateKey(){
    return int(rand(1000000));
}

sub build_tabs ($$$$$) {
    my ( $template, $record, $dbh, $encoding,$input ) = @_;

    # fill arrays
    my @loop_data = ();
    my $tag;

    my $authorised_values_sth = $dbh->prepare(
        "select authorised_value,lib
        from authorised_values
        where category=? order by lib"
    );
    
    # in this array, we will push all the 10 tabs
    # to avoid having 10 tabs in the template : they will all be in the same BIG_LOOP
    my @BIG_LOOP;
    my %seen;
    my @tab_data; # all tags to display
    
    foreach my $used ( keys %$tagslib ){
        push @tab_data,$used if not $seen{$used};
        $seen{$used}++;
    }
        
    my $max_num_tab=9;
    # loop through each tab 0 through 9
    for ( my $tabloop = 0 ; $tabloop <= $max_num_tab ; $tabloop++ ) {
        my @loop_data = (); #innerloop in the template.
        my $i = 0;
        foreach my $tag (sort @tab_data) {
            $i++;
            next if ! $tag;
            my $indicator;
            my $index_tag = CreateKey;

            # if MARC::Record is not empty =>use it as master loop, then add missing subfields that should be in the tab.
            # if MARC::Record is empty => use tab as master loop.
            if ( $record ne -1 && ( $record->field($tag) || $tag eq '000' ) ) {
                my @fields;
                if ( $tag ne '000' ) {
                    @fields = $record->field($tag);
                }
                else {
                  push @fields, MARC::Field->new('000', $record->leader()); # if tag == 000
                }
                # loop through each field
                foreach my $field (@fields) {
                    my @subfields_data;
                    if ($field->tag()<10) {
                        next
                        if (
                            $tagslib->{ $field->tag() }->{ '@' }->{tab}
                            ne $tabloop );
                      next if ($tagslib->{$field->tag()}->{'@'}->{hidden});
                      my %subfield_data;
                      $subfield_data{marc_lib}=$tagslib->{$field->tag()}->{'@'}->{lib};
                      $subfield_data{marc_value}=$field->data();
                      $subfield_data{marc_subfield}='@';
                      $subfield_data{marc_tag}=$field->tag();
                      push(@subfields_data, \%subfield_data);
                    } else {
                      my @subf=$field->subfields;
                  # loop through each subfield
                      for my $i (0..$#subf) {
                        $subf[$i][0] = "@" unless $subf[$i][0];
                        next
                        if (
                            $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{tab}
                            ne $tabloop );
                        next
                        if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }
                            ->{hidden} );
                        my %subfield_data;
                        $subfield_data{marc_lib}=$tagslib->{$field->tag()}->{$subf[$i][0]}->{lib};
                        if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{isurl}) {
                          $subfield_data{marc_value}="<a href=\"$subf[$i][1]\">$subf[$i][1]</a>";
                        } else {
                          $subfield_data{marc_value}=$subf[$i][1];
                        }
                              $subfield_data{short_desc} = substr(
                                  $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{lib},
                                  0, 20
                              );
                              $subfield_data{long_desc} =
                                $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{lib};
                        $subfield_data{marc_subfield}=$subf[$i][0];
                        $subfield_data{marc_tag}=$field->tag();
                        push(@subfields_data, \%subfield_data);
                      }
                    }
                    if ($#subfields_data>=0) {
                      my %tag_data;
                      $tag_data{tag}=$field->tag(). ' '  
                                     . C4::Koha::display_marc_indicators($field) 
                                     . ' - '
                                     . $tagslib->{$field->tag()}->{lib};
                      $tag_data{subfield} = \@subfields_data;
                      push (@loop_data, \%tag_data);
                    }
                  }
              }
            }
            if ( $#loop_data >= 0 ) {
                push @BIG_LOOP, {
                    number    => $tabloop,
                    innerloop => \@loop_data,
                };
            }
        }
        $template->param( singletab => (scalar(@BIG_LOOP)==1), BIG_LOOP => \@BIG_LOOP );
}


# 
my $query=new CGI;

my $dbh=C4::Context->dbh;

# open template
my ($template, $loggedinuser, $cookie)
		= get_template_and_user({template_name => "authorities/detail.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {catalogue => 1},
			     debug => 1,
			     });

my $authid = $query->param('authid');



my $authtypecode = &GetAuthTypeCode($authid);
$tagslib = &GetTagsLabels(1,$authtypecode);

my $record;
if (C4::Context->preference("AuthDisplayHierarchy")){
  my $trees=BuildUnimarcHierarchies($authid);
  my @trees = split /;/,$trees ;
  push @trees,$trees unless (@trees);
  my @loophierarchies;
  foreach my $tree (@trees){
    my @tree=split /,/,$tree;
    push @tree,$tree unless (@tree);
    my $cnt=0;
    my @loophierarchy;
    foreach my $element (@tree){
      my $cell;
      my $elementdata = GetAuthority($element);
      $record= $elementdata if ($authid==$element);
      push @loophierarchy, BuildUnimarcHierarchy($elementdata,"child".$cnt, $authid);
      $cnt++;
    }
    push @loophierarchies, { 'loopelement' =>\@loophierarchy};
  }
  $template->param(
    'displayhierarchy' =>C4::Context->preference("AuthDisplayHierarchy"),
    'loophierarchies' =>\@loophierarchies,
  );
} else {
  $record=GetAuthority($authid);
}
my $count = CountUsage($authid);

# find the marc field/subfield used in biblio by this authority
my $sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where authtypecode=?");
$sth->execute($authtypecode);
my $biblio_fields;
while (my ($tagfield) = $sth->fetchrow) {
	$biblio_fields.= $tagfield."9,";
}
chop $biblio_fields;


# fill arrays
my @loop_data =();
my $tag;
# loop through each tab 0 through 9
# for (my $tabloop = 0; $tabloop<=10;$tabloop++) {
# loop through each tag
  build_tabs ($template, $record, $dbh,"",$query);

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
		biblio_fields => $biblio_fields,
		authtypetext => $authtypes->{$authtypecode}{'authtypetext'},
		authtypesloop => \@authtypesloop,
		);
output_html_with_http_headers $query, $cookie, $template->output;

