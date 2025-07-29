#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

detail.pl : script to show an authority in MARC format

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This script needs an authid

It shows the authority in a (nice) MARC format depending on authority MARC
parameters tables.

=head1 FUNCTIONS

=cut

use Modern::Perl;

use CGI qw ( -utf8 );

use C4::Auth qw( get_template_and_user );
use C4::AuthoritiesMarc qw( GetAuthority GenerateHierarchy GetTagsLabels );
use C4::Context;
use C4::Koha;
use C4::Languages;
use C4::Output qw( output_html_with_http_headers );

use Koha::Authorities;
use Koha::Authority::Types;
use Koha::Token;
use Koha::XSLT::Base;
use Koha::Z3950Servers;

our ($tagslib);

sub build_tabs {
    my ( $template, $record, $dbh, $encoding,$input ) = @_;

    # fill arrays
    my @loop_data = ();
    my $tag;

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

            # if MARC::Record is not empty =>use it as master loop, then add missing subfields that should be in the tab.
            # if MARC::Record is empty => use tab as master loop.
            if ( $record != -1 && ( $record->field($tag) || $tag eq '000' ) ) {
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
                    #   next if ($tagslib->{$field->tag()}->{'@'}->{hidden});
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
                        $subf[$i][0] = "@" unless defined $subf[$i][0];
                        next
                        if (
                            $tagslib->{ $field->tag() }->{ $subf[$i][0] }->{tab}
                            ne $tabloop );
                        # next
                        # if ( $tagslib->{ $field->tag() }->{ $subf[$i][0] }
                        #     ->{hidden} );
                        my %subfield_data;
                        $subfield_data{marc_lib}=$tagslib->{$field->tag()}->{$subf[$i][0]}->{lib};
                        if ($tagslib->{$field->tag()}->{$subf[$i][0]}->{isurl}) {
                            $subfield_data{marc_value} = $subf[$i][1];
                            $subfield_data{is_url} = 1;
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
                      $tag_data{tag_number} = $tag;
                      $tag_data{tag_desc} = $tagslib->{$field->tag()}->{lib};
                      $tag_data{subfield} = \@subfields_data;
                      my $indicators = C4::Koha::display_marc_indicators($field);
                      if ( $indicators ) {
                          $tag_data{ind1} = substr $indicators, 0, 1;
                          $tag_data{ind2} = substr $indicators, 1, 1;
                      }

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
my $query=CGI->new;

my $dbh=C4::Context->dbh;

# open template
my ($template, $loggedinuser, $cookie) = get_template_and_user(
    {
        template_name   => "authorities/detail.tt",
        query           => $query,
        type            => "intranet",
        flagsrequired   => { catalogue => 1 },
    }
);

my $authid = $query->param('authid');

my $authobj = Koha::Authorities->find($authid);
my $authtypecode = $authobj ? $authobj->authtypecode : q{};
$tagslib = GetTagsLabels(1,$authtypecode);

# Build list of authtypes for showing them
my $authority_types = Koha::Authority::Types->search({}, { order_by => ['authtypetext']});

my $record=GetAuthority($authid);

if (not defined $record) {
    # authid invalid
    $template->param ( errauthid => $authid,
                       unknownauthid => 1,
                       authority_types => $authority_types, );
    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

if (C4::Context->preference("AuthDisplayHierarchy")){
    $template->{VARS}->{'displayhierarchy'} = C4::Context->preference("AuthDisplayHierarchy");
    $template->{VARS}->{'loophierarchies'} = GenerateHierarchy($authid);
}

my $count = $authobj ? $authobj->get_usage_count : 0;

# find the marc field/subfield used in biblio by this authority
my $sth = $dbh->prepare("select distinct tagfield from marc_subfield_structure where authtypecode=?");
$sth->execute($authtypecode);
my $biblio_fields;
while (my ($tagfield) = $sth->fetchrow) {
	$biblio_fields.= $tagfield."9,";
}
chop $biblio_fields if $biblio_fields;

my $AuthorityXSLTDetailsDisplay = C4::Context->preference('AuthorityXSLTDetailsDisplay');
if ( $AuthorityXSLTDetailsDisplay ) {
    my $xsl = $AuthorityXSLTDetailsDisplay;
    my $lang = C4::Languages::getlanguage();
    $xsl =~ s/\{langcode\}/$lang/g;
    $xsl =~ s/\{authtypecode\}/$authtypecode/g;

    my $xslt_engine = Koha::XSLT::Base->new;
    my $output = $xslt_engine->transform({ xml => $authobj->marcxml, file => $xsl });
    if ($xslt_engine->err) {
        warn "XSL transformation failed ($xsl): " . $xslt_engine->err;
        next;
    }

    $template->param( html => $output );
} else {
    build_tabs ($template, $record, $dbh,"",$query);
}

my $servers = Koha::Z3950Servers->search(
    {
        recordtype => 'authority',
        servertype => ['zed', 'sru'],
    },
);

my $type = $authority_types->find($authtypecode);
$template->param(
    authid          => $authid,
    count           => $count,
    biblio_fields   => $biblio_fields,
    authtypetext    => $type ? $type->authtypetext: "",
    authtypecode    => $authtypecode,
    authority_types => $authority_types,
    servers => $servers,
);

$template->{VARS}->{marcflavour} = C4::Context->preference("marcflavour");
output_html_with_http_headers $query, $cookie, $template->output;

