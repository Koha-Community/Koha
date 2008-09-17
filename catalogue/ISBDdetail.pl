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

ISBDdetail.pl : script to show a biblio in ISBD format

=head1 SYNOPSIS


=head1 DESCRIPTION

This script needs a biblionumber as parameter 

=head1 FUNCTIONS

=over 2

=cut

use strict;

use C4::Auth;
use C4::Context;
use C4::Output;
use CGI;
use C4::Koha;
use C4::Biblio;
use C4::Items;
use C4::Branch;     # GetBranchDetail
use C4::Serials;    # CountSubscriptionFromBiblionumber


#---- Internal function


my $query = new CGI;
my $dbh = C4::Context->dbh;

my $biblionumber = $query->param('biblionumber');
my $itemtype     = &GetFrameworkCode($biblionumber);
my $tagslib      = &GetMarcStructure( 1, $itemtype );

my $record = GetMarcBiblio($biblionumber);

# open template
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "catalogue/ISBDdetail.tmpl",
        query         => $query,
        type          => "intranet",
	authnotrequired => 0,
	flagsrequired   => { catalogue => 1 },
    }
);

my $ISBD = C4::Context->preference('ISBD');

# my @blocs = split /\@/,$ISBD;
# my @fields = $record->fields();
my $res;

# foreach my $bloc (@blocs) {
#     $bloc =~ s/\n//g;
my $bloc = $ISBD;
my $blocres;

my ($holdingbrtagf,$holdingbrtagsubf) = &GetMarcFromKohaField("items.holdingbranch",$itemtype);
# @big_array = sort {$a->{$holdingbrtagsubf} cmp $b->{$holdingbrtagsubf}} @big_array;

foreach my $isbdfield ( split /#/, $bloc ) {

    $isbdfield =~ /(\d\d\d)([^\|])?\|(.*)\|(.*)\|(.*)/;
    my $fieldvalue    = $1;
    my $subfvalue = $2;
    my $textbefore    = $3;
    my $analysestring = $4;
    my $textafter     = $5;

    #         warn "==> $1 / $2 / $3 / $4";
    #         my $fieldvalue=substr($isbdfield,0,3);
    if ( $fieldvalue > 0 ) {
        my $hasputtextbefore = 0;
        my @fieldslist = $record->field($fieldvalue);
        @fieldslist = sort {$a->subfield($holdingbrtagsubf) cmp $b->subfield($holdingbrtagsubf)} @fieldslist if ($fieldvalue eq $holdingbrtagf);

        #         warn "ERROR IN ISBD DEFINITION at : $isbdfield" unless $fieldvalue;
        #             warn "FV : $fieldvalue";
        if ($subfvalue ne ""){
          foreach my $field ( @fieldslist ) {
            foreach my $subfield ($field->subfield($subfvalue)){
              warn $fieldvalue."$subfvalue";    
              my $calculated = $analysestring;
              my $tag        = $field->tag();
              if ( $tag < 10 ) {
              }
              else {
                my $subfieldvalue =
                GetAuthorisedValueDesc( $tag, $subfvalue,
                  $subfield, '', $tagslib );
                my $tagsubf = $tag . $subfvalue;
                $calculated =~
                      s/\{(.?.?.?.?)$tagsubf(.*?)\}/$1$subfieldvalue$2\{$1$tagsubf$2\}/g;
#                 $calculated =~s#/cgi-bin/koha/[^/]+/([^.]*.pl\?.*)$#opac-$1#g;
            
                # field builded, store the result
                if ( $calculated && !$hasputtextbefore )
                {    # put textbefore if not done
                $blocres .= $textbefore;
                $hasputtextbefore = 1;
                }
            
                # remove punctuation at start
                $calculated =~ s/^( |;|:|\.|-)*//g;
                $blocres .= $calculated;
                            
              }         
            }          
          }
          $blocres .= $textafter if $hasputtextbefore;  
        } else {    
        foreach my $field ( @fieldslist ) {
          my $calculated = $analysestring;
          my $tag        = $field->tag();
          if ( $tag < 10 ) {
          }
          else {
            my @subf = $field->subfields;
            for my $i ( 0 .. $#subf ) {
            my $subfieldcode  = $subf[$i][0];
            my $subfieldvalue =
            GetAuthorisedValueDesc( $tag, $subf[$i][0],
              $subf[$i][1], '', $tagslib );
            my $tagsubf = $tag . $subfieldcode;
            $calculated =~
        s/\{(.?.?.?.?)$tagsubf(.*?)\}/$1$subfieldvalue$2\{$1$tagsubf$2\}/g;
#         $calculated =~s#/cgi-bin/koha/[^/]+/([^.]*.pl\?.*)$#opac-$1#g;
            }
        
            # field builded, store the result
            if ( $calculated && !$hasputtextbefore )
            {    # put textbefore if not done
            $blocres .= $textbefore;
            $hasputtextbefore = 1;
            }
        
            # remove punctuation at start
            $calculated =~ s/^( |;|:|\.|-)*//g;
            $blocres .= $calculated;
          }
        }
        $blocres .= $textafter if $hasputtextbefore;
        }       
    }
    else {
        $blocres .= $isbdfield;
    }
}
$res .= $blocres;

# }
$res =~ s/\{(.*?)\}//g;
$res =~ s/\\n/\n/g;
$res =~ s/\n/<br\/>/g;

# remove empty ()
$res =~ s/\(\)//g;
# count of item linked with biblio
my $itemcount = GetItemsCount($biblionumber);
$template->param( count => $itemcount);
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
 
if ($subscriptionsnumber) {
    my $subscriptions     = GetSubscriptionsFromBiblionumber($biblionumber);
    my $subscriptiontitle = $subscriptions->[0]{'bibliotitle'};
    $template->param(
        subscriptionsnumber => $subscriptionsnumber,
        subscriptiontitle   => $subscriptiontitle,
    );
}

$template->param (
    ISBD                => $res,
    biblionumber        => $biblionumber,
	isbdview => 1,
);

output_html_with_http_headers $query, $cookie, $template->output;

