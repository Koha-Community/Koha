#!/usr/bin/perl

# Copyright 2000-2009 Biblibre S.A
#                                         John Soros <john.soros@biblibre.com>
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
use warnings;

#need to open cgi and get the fh before anything else opens a new cgi context (see C4::Auth)
use CGI;
my $input = new CGI;
my $barcodefh = $input->upload('uploadbarcodes');

use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Branch qw(GetBranches);
use C4::Koha qw(GetAuthorisedValues GetAuthValCode);
use C4::Items qw(GetItemnumberFromBarcode GetItem ModItem DelItemCheck);
use C4::Biblio qw(GetBiblioData);
use C4::Koha qw(GetItemTypes);


my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "tools/batchMod.tmpl",
                query => $input,
                type => "intranet",
                authnotrequired => 0,
                flagsrequired => {tools => 'batchmod'},
                debug => 1,
                });

#get all input vars and put it in a hash
my $invars = $input->Vars;

# Global item status lists (this has proven to be very handy :)
my $authloop = [];
my $authvals = [['items.notforloan', 'Item not for loan', 'notforloan'],
                             ['items.itemlost', 'Item lost', 'itemlost'],
                             ['items.wthdrawn', 'item withdrawn', 'sele'],
                             ['items.damaged', 'item damaged', 'damaged'],
                             ['items.location', 'item location', 'location'],
                             ['items.ccode', 'items.ccode', 'ccode'],
                            ];

my $itemlevelpref = C4::Context->preference('item-level_itypes');
#we use item -level itemtypes
if ( $itemlevelpref ){
    push(@$authvals, ['items.itype', 'itemtype', 'itype']);
}
if ( $invars->{op} && $invars->{op} eq 'barcodes'){
    #Parse barcodes list
    my @barcodelist;
    if ( $invars->{'uploadbarcodes'} && length($invars->{'uploadbarcodes'})>0){
        while (my $barcode=<$barcodefh>){
            chomp $barcode;
            push @barcodelist, $barcode;
        }
    }
    if ( $invars->{barcodelist} && length($invars->{barcodelist}) > 0){
        @barcodelist = split(/\s\n/, $invars->{barcodelist});
    }
    #get all branches
    my $brancheshash = GetBranches();
    my $branches = [];
    for my $branchcode (keys %$brancheshash){
        my $branch;
        $branch->{'name'} = $brancheshash->{$branchcode}->{'branchname'};
        $branch->{'code'} = $branchcode;
        push @$branches, $branch;
    }
    
    #get all item statuses
    for my $field (@$authvals){
        my $fieldstatusauth = {};
        my ($fieldname, $fielddesc, $hashfdname) = @$field;
        $fieldstatusauth->{authcode} = GetAuthValCode($fieldname);
        if ($fieldstatusauth->{authcode} && length($fieldstatusauth->{authcode}) > 0){
            $fieldstatusauth->{values} = GetAuthorisedValues($fieldstatusauth->{authcode});
            $fieldstatusauth->{fieldname} = $fieldname;
            $fieldstatusauth->{description} = $fielddesc;
            $fieldstatusauth->{itemfieldname} = $hashfdname;
            push @$authloop, $fieldstatusauth;
        }
    }
    my $itemtypes = [];
    #we use biblio level itype
    if ( ! $itemlevelpref){
        my $itypes = GetItemTypes();
        for my $key (keys %$itypes){
            push(@$itemtypes, $itypes->{$key});
        }
    }
    #build items list
    my @items;
    my $itemslst = '';
    if (scalar @barcodelist > 0){
        for my $barcode (@barcodelist){
            my $itemno = GetItemnumberFromBarcode($barcode);
            my $item = GetItem($itemno, $barcode);
            my $iteminfo = GetBiblioData($item->{biblionumber});
            for my $field (qw(title isbn itemtype)){
                $item->{$field} = $iteminfo->{$field};
            }
#kind of flakey, though we can be pretty sure the values will be in the same order as in the authloop
#have to use this since in html::template::pro i can't access one loop from inside an other,
#and variable substitution doesn't work (<!-- TMPL_VAR name="<!-- TMPL_VAR name="foo" -->" -->)
#this pushes a list of authorized valuse into each item's hash
            my $itemauthloop = [];
            for my $authfield (@$authloop){
                my $authvaluename;
#looking for the authvalues human-readable form
                for my $val (@{$authfield->{values}}){
                    if( $item->{$authfield->{itemfieldname}} eq $val->{lib} || $item->{$authfield->{itemfieldname}} eq $val->{authorised_value}){
                        $authvaluename = $val->{lib};
                    }
                }
                if ( ! $authvaluename){
                    $authvaluename = "Not found or invalid";
                }
                push(@$itemauthloop, { 'authvalue' => $authvaluename} );
            }
            for my $type (@$itemtypes){
                if ( $item->{itemtype} eq $type->{itemtype} ) {
                    $item->{itemtypedesc} = $type->{description};
                }
            }
            $item->{authloop} = $itemauthloop;
            push @items, $item;
            $itemslst .= $item->{'itemnumber'} . ',';
        }
    }
    
    $template->param( 'itemsloop' => \@items,
                                        'authloop' => $authloop,
                                        'branches' => $branches,
                                        'actions'    => 1,
                                        'op'            => '1',
                                        'itemslst'   => $itemslst,
                                        'itemtypes' => $itemtypes,
                                      );
} elsif ( $invars->{'itemslst'} ) {
    for my $itemno ( split(',', $invars->{itemslst}) ) {
		my $item = GetItem($itemno);
		if ( $invars->{'del'} ) {
			DelItemCheck(C4::Context->dbh, $item->{'biblionumber'}, $item->{'itemnumber'})
		} else {
			for my $auth (@$authvals){
				my ($authfieldname, $description, $hashfdname) = @$auth;
				my $authcode = GetAuthValCode($authfieldname);
				if ($authcode && $invars->{$authcode} && $invars->{$authcode} ne '0'){
					$item->{$hashfdname}=$invars->{$authcode};
				}
			}
			if ($invars->{holdingbranch} && $invars->{holdingbranch} ne '0'){
				$item->{holdingbranch} = $invars->{holdingbranch};
			}
			if ($invars->{homebranch} && $invars->{homebranch} ne '0'){
				$item->{homebranch} = $invars->{homebranch};
			}
			ModItem($item, $item->{biblionumber}, $item->{itemnumber});
		}
    }
}
$template->param('del' => $input->param('del'));
output_html_with_http_headers $input, $cookie, $template->output;
