#!/usr/bin/perl

# Copyright 2000-2009 Biblibre S.A
#                                         John Soros <john.soros@biblibre.com>
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
use C4::Koha;
use C4::Branch; # GetBranches
use C4::Circulation;
use C4::Reports::Guided;    #_get_column_defs
use C4::Charset;
use Koha::DateUtils;
use List::MoreUtils qw( none );


my $minlocation=$input->param('minlocation') || '';
my $maxlocation=$input->param('maxlocation');
$maxlocation=$minlocation.'Z' unless ( $maxlocation || ! $minlocation );
my $location=$input->param('location') || '';
my $itemtype=$input->param('itemtype'); # FIXME note, template does not currently supply this
my $ignoreissued=$input->param('ignoreissued');
my $datelastseen = $input->param('datelastseen');
my $markseen = $input->param('markseen');
my $branchcode = $input->param('branchcode') || '';
my $branch     = $input->param('branch');
my $op         = $input->param('op');
my $compareinv2barcd = $input->param('compareinv2barcd');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "tools/inventory.tt",
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
    today                    => dt_from_string,
    minlocation              => $minlocation,
    maxlocation              => $maxlocation,
    location                 => $location,
    ignoreissued             => $ignoreissued,
    branchcode               => $branchcode,
    branch                   => $branch,
    datelastseen             => $datelastseen,
    compareinv2barcd         => $compareinv2barcd,
    notforloanlist           => $notforloanlist
);

my @notforloans;
if (defined $notforloanlist) {
    @notforloans = split(/,/, $notforloanlist);
}

my @scanned_items;
my @errorloop;
if ( $uploadbarcodes && length($uploadbarcodes) > 0 ) {
    my $dbh = C4::Context->dbh;
    my $date = dt_from_string( $input->param('setdate') );
    $date = output_pref ( { dt => $date, dateformat => 'iso' } );

    my $strsth  = "select * from issues, items where items.itemnumber=issues.itemnumber and items.barcode =?";
    my $qonloan = $dbh->prepare($strsth);
    $strsth="select * from items where items.barcode =? and items.withdrawn = 1";
    my $qwithdrawn = $dbh->prepare($strsth);

    my $count = 0;

    my @barcodes;

    my $sth = $dbh->column_info(undef,undef,"items","barcode");
    my $barcode_def = $sth->fetchall_hashref('COLUMN_NAME');
    my $barcode_size = $barcode_def->{barcode}->{COLUMN_SIZE};
    my $err_length=0;
    my $err_data=0;
    my $lines_read=0;
    binmode($uploadbarcodes, ":encoding(UTF-8)");
    while (my $barcode=<$uploadbarcodes>){
        $barcode =~ s/\r?\n$//;
        next unless $barcode;
        ++$lines_read;
        if (length($barcode)>$barcode_size) {
            $err_length += 1;
        }
        my $check_barcode = $barcode;
        $check_barcode =~ s/\p{Print}//g;
        if (length($check_barcode)>0) { # Only printable unicode characters allowed.
            $err_data += 1;
        }
        next if length($barcode)>$barcode_size;
        next if ( length($check_barcode)>0 );
        push @barcodes,$barcode;
    }
    $template->param( LinesRead => $lines_read );
    if (! @barcodes) {
        push @errorloop, {'barcode'=>'No valid barcodes!'};
        $op=''; # force the initial inventory screen again.
    }
    else {
        $template->param( err_length => $err_length,
                          err_data   => $err_data );
    }
    foreach my $barcode (@barcodes) {
        if ( $qwithdrawn->execute($barcode) && $qwithdrawn->rows ) {
            push @errorloop, { 'barcode' => $barcode, 'ERR_WTHDRAWN' => 1 };
        } else {
            my $item = GetItem( '', $barcode );
            if ( defined $item && $item->{'itemnumber'} ) {
                ModItem( { datelastseen => $date }, undef, $item->{'itemnumber'} );
                push @scanned_items, $item;
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

    $template->param( date => $date, Number => $count );
    $template->param( errorloop => \@errorloop ) if (@errorloop);
}

# now build the result list: inventoried items if requested, and mis-placed items -always-
my $inventorylist;
my $wrongplacelist;
my @items_with_problems;
if ( $markseen or $op ) {
    # retrieve all items in this range.
    my $totalrecords;

    # We use datelastseen only when comparing the results to the barcode file.
    my $paramdatelastseen = ($compareinv2barcd) ? $datelastseen : '';
    ($inventorylist, $totalrecords) = GetItemsForInventory($minlocation, $maxlocation, $location, $itemtype, $ignoreissued, $paramdatelastseen, $branchcode, $branch, 0, undef, $staton);

    # For the items that may be marked as "wrong place", we only check the location (callnumbers, location and branch)
    ($wrongplacelist, $totalrecords) = GetItemsForInventory($minlocation, $maxlocation, $location, undef, undef, undef, $branchcode, $branch, 0, undef, undef);

}

# If "compare barcodes list to results" has been checked, we want to alert for missing items
if ( $compareinv2barcd ) {
    # set "missing" flags for all items with a datelastseen (dls) before the choosen datelastseen (cdls)
    my $dls = output_pref( { dt => dt_from_string( $datelastseen ),
                             dateformat => 'iso' } );
    foreach my $item ( @$inventorylist ) {
        my $cdls = output_pref( { dt => dt_from_string( $_->{datelastseen} ),
                                  dateformat => 'iso' } );
        if ( $cdls lt $dls ) {
            $item->{problem} = 'missingitem';
            # We have to push a copy of the item, not the reference
            push @items_with_problems, { %$item };
        }
    }
}



# insert "wrongplace" to all scanned items that are not supposed to be in this range
# note this list is always displayed, whatever the librarian has choosen for comparison
my $moddatecount = 0;
foreach my $item ( @scanned_items ) {

  # Saving notforloan code before it's replaced by it's authorised value for later comparison
  $item->{notforloancode} = $item->{notforloan};

  # Populating with authorised values
  foreach my $field ( keys %$item ) {
        # If the koha field is mapped to a marc field
        my $fc = $item->{'frameworkcode'} || '';
        my ($f, $sf) = GetMarcFromKohaField("items.$field", $fc);
        if ($f and $sf) {
            # We replace the code with it's description
            my $authvals = C4::Koha::GetKohaAuthorisedValuesFromField($f, $sf, $fc);
            if ($authvals and defined $item->{$field} and defined $authvals->{$item->{$field}}) {
              $item->{$field} = $authvals->{$item->{$field}};
            }
        }
    }

    next if $item->{onloan}; # skip checked out items

    # If we have scanned items with a non-matching notforloan value
    if (none { $item->{'notforloancode'} eq $_ } @notforloans) {
        $item->{problem} = 'changestatus';
        push @items_with_problems, { %$item };
    }
    if (none { $item->{barcode} eq $_->{barcode} && !$_->{'onloan'} } @$wrongplacelist) {
        $item->{problem} = 'wrongplace';
        push @items_with_problems, { %$item };
    }

    # Modify date last seen for scanned items
    ModDateLastSeen($_->{'itemnumber'});
    $moddatecount++;
}

if ( $compareinv2barcd ) {
    my @scanned_barcodes = map {$_->{barcode}} @scanned_items;
    for my $should_be_scanned ( @$inventorylist ) {
        my $barcode = $should_be_scanned->{barcode};
        unless ( grep /^$barcode$/, @scanned_barcodes ) {
            $should_be_scanned->{problem} = 'not_scanned';
            push @items_with_problems, { %$should_be_scanned };
        }
    }
}

for my $item ( @items_with_problems ) {
    my $biblio = C4::Biblio::GetBiblioData($item->{biblionumber});
    $item->{title} = $biblio->{title};
    $item->{author} = $biblio->{author};
}

# If a barcode file is given, we want to show problems, else all items
my @results;
@results = $uploadbarcodes
            ? @items_with_problems
            : $op
                ? @$inventorylist
                : ();

$template->param(
    moddatecount => $moddatecount,
    loop       => \@results,
    op         => $op
);

if (defined $input->param('CSVexport') && $input->param('CSVexport') eq 'on'){
    eval {use Text::CSV};
    my $csv = Text::CSV->new or
            die Text::CSV->error_diag ();
    binmode STDOUT, ":encoding(UTF-8)";
    print $input->header(
        -type       => 'text/csv',
        -attachment => 'inventory.csv',
    );

    my $columns_def_hashref = C4::Reports::Guided::_get_column_defs($input);
    foreach my $key ( keys %$columns_def_hashref ) {
        my $initkey = $key;
        $key =~ s/[^\.]*\.//;
        $columns_def_hashref->{$initkey}=NormalizeString($columns_def_hashref->{$initkey} // '');
        $columns_def_hashref->{$key} = $columns_def_hashref->{$initkey};
    }

    my @translated_keys;
    for my $key (qw / biblioitems.title    biblio.author
                      items.barcode        items.itemnumber
                      items.homebranch     items.location
                      items.itemcallnumber items.notforloan
                      items.itemlost       items.damaged
                      items.withdrawn      items.stocknumber
                      / ) {
       push @translated_keys, $columns_def_hashref->{$key};
    }
    push @translated_keys, 'problem' if $uploadbarcodes;

    $csv->combine(@translated_keys);
    print $csv->string, "\n";

    my @keys = qw / title author barcode itemnumber homebranch location itemcallnumber notforloan lost damaged withdrawn stocknumber /;
    for my $item ( @results ) {
        my @line;
        for my $key (@keys) {
            push @line, $item->{$key};
        }
        if ( defined $item->{problem} ) {
            if ( $item->{problem} eq 'wrongplace' ) {
                push @line, "wrong place";
            } elsif ( $item->{problem} eq 'missingitem' ) {
                push @line, "missing item";
            } elsif ( $item->{problem} eq 'changestatus' ) {
                push @line, "change item status";
            } elsif ($item->{problem} eq 'not_scanned' ) {
                push @line, "item not scanned";
            }
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
