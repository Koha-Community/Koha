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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

#need to open cgi and get the fh before anything else opens a new cgi context (see C4::Auth)
use CGI;
my $input = CGI->new;
my $uploadbarcodes = $input->param('uploadbarcodes');

use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Dates qw/format_date format_date_in_iso/;
use C4::Koha;
use C4::Branch; # GetBranches
use C4::Circulation;
use C4::Reports::Guided;    #_get_column_defs
use C4::Charset;
use List::MoreUtils qw/none/;


my $minlocation=$input->param('minlocation') || '';
my $maxlocation=$input->param('maxlocation');
$maxlocation=$minlocation.'Z' unless ( $maxlocation || ! $minlocation );
my $location=$input->param('location') || '';
my $itemtype=$input->param('itemtype'); # FIXME note, template does not currently supply this
my $ignoreissued=$input->param('ignoreissued');
my $datelastseen = $input->param('datelastseen');
my $offset = $input->param('offset');
my $markseen = $input->param('markseen');
$offset=0 unless $offset;
my $pagesize = $input->param('pagesize');
$pagesize=50 unless $pagesize;
my $branchcode = $input->param('branchcode') || '';
my $branch     = $input->param('branch');
my $op         = $input->param('op');
my $compareinv2barcd = $input->param('compareinv2barcd');
my $res;                                            #contains the results loop

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "tools/inventory.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'inventory' },
        debug           => 1,
    }
);


my $branches = GetBranches();
my @branch_loop;
for my $branch_hash (keys %$branches) {
    push @branch_loop, {value => "$branch_hash",
                       branchname => $branches->{$branch_hash}->{'branchname'},
                       selected => ($branch_hash eq $branchcode?1:0)};
}

@branch_loop = sort {$a->{branchname} cmp $b->{branchname}} @branch_loop;
my @authorised_value_list;
my $authorisedvalue_categories = '';

my $frameworks = getframeworks();
$frameworks->{''} = {frameworkcode => ''}; # Add the default framework

for my $fwk (keys %$frameworks){
  my $fwkcode = $frameworks->{$fwk}->{'frameworkcode'};
  my $authcode = GetAuthValCode('items.location', $fwkcode);
    if ($authcode && $authorisedvalue_categories!~/\b$authcode\W/){
      $authorisedvalue_categories.="$authcode ";
      my $data=GetAuthorisedValues($authcode);
      foreach my $value (@$data){
        $value->{selected}=1 if ($value->{authorised_value} eq ($location));
      }
      push @authorised_value_list,@$data;
    }
}

my $statuses = [];
for my $statfield (qw/items.notforloan items.itemlost items.withdrawn items.damaged/){
    my $hash = {};
    $hash->{fieldname} = $statfield;
    $hash->{authcode} = GetAuthValCode($statfield);
    if ($hash->{authcode}){
        my $arr = GetAuthorisedValues($hash->{authcode});
        $hash->{values} = $arr;
        push @$statuses, $hash;
    }
}


$template->param( statuses => $statuses );
my $staton = {};                                #authorized values that are ticked
for my $authvfield (@$statuses) {
    $staton->{$authvfield->{fieldname}} = [];
    for my $authval (@{$authvfield->{values}}){
        if ( defined $input->param('status-' . $authvfield->{fieldname} . '-' . $authval->{authorised_value}) && $input->param('status-' . $authvfield->{fieldname} . '-' . $authval->{authorised_value}) eq 'on' ){
            push @{$staton->{$authvfield->{fieldname}}}, $authval->{authorised_value};
        }
    }
}

my $notforloanlist;
my $statussth = '';
for my $authvfield (@$statuses) {
    if ( scalar @{$staton->{$authvfield->{fieldname}}} > 0 ){
        my $joinedvals = join ',', @{$staton->{$authvfield->{fieldname}}};
        $statussth .= "$authvfield->{fieldname} in ($joinedvals) and ";
        $notforloanlist = $joinedvals if ($authvfield->{fieldname} eq "items.notforloan");
    }
}
$statussth =~ s, and $,,g;
$template->param(
    branchloop               => \@branch_loop,
    authorised_values        => \@authorised_value_list,
    today                    => C4::Dates->today(),
    minlocation              => $minlocation,
    maxlocation              => $maxlocation,
    location                 => $location,
    ignoreissued             => $ignoreissued,
    branchcode               => $branchcode,
    branch                   => $branch,
    offset                   => $offset,
    pagesize                 => $pagesize,
    datelastseen             => $datelastseen,
    compareinv2barcd         => $compareinv2barcd,
    notforloanlist           => $notforloanlist
);

my @notforloans;
if (defined $notforloanlist) {
    @notforloans = split(/,/, $notforloanlist);
}



my @brcditems;
my $barcodelist;
my @errorloop;
if ( $uploadbarcodes && length($uploadbarcodes) > 0 ) {
    my $dbh = C4::Context->dbh;
    my $date = format_date_in_iso( $input->param('setdate') ) || C4::Dates->today('iso');

    my $strsth  = "select * from issues, items where items.itemnumber=issues.itemnumber and items.barcode =?";
    my $qonloan = $dbh->prepare($strsth);
    $strsth="select * from items where items.barcode =? and items.withdrawn = 1";
    my $qwithdrawn = $dbh->prepare($strsth);

    my $count = 0;

    while (my $barcode=<$uploadbarcodes>){
        $barcode =~ s/\r?\n$//;
        $barcodelist .= ($barcodelist) ? '|' . $barcode : $barcode;
        if ( $qwithdrawn->execute($barcode) && $qwithdrawn->rows ) {
            push @errorloop, { 'barcode' => $barcode, 'ERR_WTHDRAWN' => 1 };
        } else {
            my $item = GetItem( '', $barcode );
            if ( defined $item && $item->{'itemnumber'} ) {
                ModItem( { datelastseen => $date }, undef, $item->{'itemnumber'} );
                push @brcditems, $item;
                $count++;
                $qonloan->execute($barcode);
                if ($qonloan->rows){
                    my $data = $qonloan->fetchrow_hashref;
                    my ($doreturn, $messages, $iteminformation, $borrower) =AddReturn($barcode, $data->{homebranch});
                    if ($doreturn){
                        push @errorloop, {'barcode'=>$barcode,'ERR_ONLOAN_RET'=>1}
                    } else {
                        push @errorloop, {'barcode'=>$barcode,'ERR_ONLOAN_NOT_RET'=>1}
                    }
                }
            } else {
                push @errorloop, {'barcode'=>$barcode,'ERR_BARCODE'=>1};
            }
        }

    }
    $qonloan->finish;
    $qwithdrawn->finish;
    $template->param( date => format_date($date), Number => $count );
    $template->param( errorloop => \@errorloop ) if (@errorloop);

}
$template->param(barcodelist => $barcodelist);

# now build the result list: inventoried items if requested, and mis-placed items -always-
my $inventorylist;
if ( $markseen or $op ) {
    # retrieve all items in this range.
    my $totalrecords;
    ($inventorylist, $totalrecords) = GetItemsForInventory($minlocation, $maxlocation, $location, $itemtype, $ignoreissued, '', $branchcode, $branch, 0, undef , $staton);

    # Real copy
    my @res_copy;
    foreach (@$inventorylist) {
        push @res_copy, $_;
    }
    $res = \@res_copy;
}

# set "missing" flags for all items with a datelastseen before the choosen datelastseen
foreach (@$res) { $_->{missingitem}=1 if C4::Dates->new($_->{datelastseen})->output('iso') lt C4::Dates->new($datelastseen)->output('iso'); }

# removing missing items from loop if "Compare barcodes list to results" has not been checked
@$res = grep {!$_->{missingitem} == 1 } @$res if (!$input->param('compareinv2barcd'));

# insert "wrongplace" to all scanned items that are not supposed to be in this range
# note this list is always displayed, whatever the librarian has choosen for comparison
foreach my $temp (@brcditems) {

  # Saving notforloan code before it's replaced by it's authorised value for later comparison
  $temp->{'notforloancode'} = $temp->{'notforloan'};

  # Populating with authorised values
  foreach (keys %$temp) {
        # If the koha field is mapped to a marc field
        my $fc = $temp->{'frameworkcode'} || '';
        my ($f, $sf) = GetMarcFromKohaField("items.$_", $fc);
        if ($f and $sf) {
            # We replace the code with it's description
            my $authvals = C4::Koha::GetKohaAuthorisedValuesFromField($f, $sf, $fc);
            if ($authvals and defined $temp->{$_} and defined $authvals->{$temp->{$_}}) {
              $temp->{$_} = $authvals->{$temp->{$_}};
            }
        }
    }

    next if $temp->{onloan}; # skip checked out items

    # If we have scanned items with a non-matching notforloan value
    if (none { $temp->{'notforloancode'} eq $_ } @notforloans) {
        $temp->{'changestatus'} = 1;
        my $biblio = C4::Biblio::GetBiblioData($temp->{biblionumber});
        $temp->{title} = $biblio->{title};
        $temp->{author} = $biblio->{author};
        $temp->{datelastseen} = format_date($temp->{datelastseen});
        push @$res, $temp;

    }
    if (none { $temp->{barcode} eq $_->{barcode} && !$_->{'onloan'} } @$inventorylist) {
        my $temp2 = { %$temp };
        $temp2->{wrongplace}=1;
        my $biblio = C4::Biblio::GetBiblioData($temp->{biblionumber});
        $temp2->{title} = $biblio->{title};
        $temp2->{author} = $biblio->{author};
        $temp2->{datelastseen} = format_date($temp->{datelastseen});
        push @$res, $temp2;
    }
}

# Finally, modifying datelastseen for remaining items
my $moddatecount = 0;
foreach (@$res) {
    unless ($_->{'missingitem'}) {
        ModDateLastSeen($_->{'itemnumber'});
        $moddatecount++;
    }
}

# Removing items that don't have any problems from loop
@$res = grep { $_->{missingitem} || $_->{wrongplace} || $_->{changestatus} } @$res;

$template->param(
    moddatecount => $moddatecount,
    loop       => $res,
    nextoffset => ( $offset + $pagesize ),
    prevoffset => ( $offset ? $offset - $pagesize : 0 ),
    op         => $op
);

if (defined $input->param('CSVexport') && $input->param('CSVexport') eq 'on'){
    eval {use Text::CSV};
    my $csv = Text::CSV->new or
            die Text::CSV->error_diag ();
    print $input->header(
        -type       => 'text/csv',
        -attachment => 'inventory.csv',
    );

    my $columns_def_hashref = C4::Reports::Guided::_get_column_defs();
    foreach my $key ( keys %$columns_def_hashref ) {
        my $initkey = $key;
        $key =~ s/[^\.]*\.//;
        $columns_def_hashref->{$initkey}=NormalizeString($columns_def_hashref->{$initkey});
        $columns_def_hashref->{$key} = $columns_def_hashref->{$initkey};
    }

    my @translated_keys;
    for my $key (qw / biblioitems.title    biblio.author
                      items.barcode        items.itemnumber
                      items.homebranch     items.location
                      items.itemcallnumber items.notforloan
                      items.itemlost       items.damaged
                      items.stocknumber
                      / ) {
       push @translated_keys, $columns_def_hashref->{$key};
    }

    $csv->combine(@translated_keys);
    print $csv->string, "\n";

    my @keys = qw / title author barcode itemnumber homebranch location itemcallnumber notforloan lost damaged stocknumber /;
    for my $re (@$res) {
        my @line;
        for my $key (@keys) {
            push @line, $re->{$key};
        }
        if ($re->{wrongplace}) {
            push @line, "wrong place";
        } elsif ($re->{missingitem}) {
            push @line, "missing item";
        } elsif ($re->{changestatus}) {
            push @line, "change item status";
        }
        $csv->combine(@line);
        print $csv->string, "\n";
    }
    # Adding not found barcodes
    foreach my $error (@errorloop) {
    my @line;
    if ($error->{'ERR_BARCODE'}) {
        push @line, map { $_ eq 'barcode' ? $error->{'barcode'} : ''} @keys;
        push @line, "barcode not found";
        $csv->combine(@line);
        print $csv->string, "\n";
    }
    }
    exit;
}

output_html_with_http_headers $input, $cookie, $template->output;
