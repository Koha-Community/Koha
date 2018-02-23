#!/usr/bin/perl

# Copyright 2000-2009 Biblibre S.A
# John Soros <john.soros@biblibre.com>
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

use Modern::Perl;

#need to open cgi and get the fh before anything else opens a new cgi context (see C4::Auth)
use CGI qw ( -utf8 );
my $input = CGI->new;
my $uploadbarcodes = $input->param('uploadbarcodes');

use C4::Auth;
use C4::Context;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Koha;
use C4::Circulation;
use C4::Reports::Guided;    #_get_column_defs
use C4::Charset;

use Koha::Biblios;
use Koha::DateUtils;
use Koha::AuthorisedValues;
use Koha::BiblioFrameworks;
use List::MoreUtils qw( none );

my $minlocation=$input->param('minlocation') || '';
my $maxlocation=$input->param('maxlocation');
$maxlocation=$minlocation.'Z' unless ( $maxlocation || ! $minlocation );
my $location=$input->param('location') || '';
my $ignoreissued=$input->param('ignoreissued');
my $datelastseen = $input->param('datelastseen'); # last inventory date
my $branchcode = $input->param('branchcode') || '';
my $branch     = $input->param('branch');
my $op         = $input->param('op');
my $compareinv2barcd = $input->param('compareinv2barcd');
my $dont_checkin = $input->param('dont_checkin');

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {   template_name   => "tools/inventory.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'inventory' },
        debug           => 1,
    }
);

my @authorised_value_list;
my $authorisedvalue_categories = '';

my $frameworks = Koha::BiblioFrameworks->search({}, { order_by => ['frameworktext'] })->unblessed;
unshift @$frameworks, { frameworkcode => '' };

for my $fwk ( @$frameworks ){
  my $fwkcode = $fwk->{frameworkcode};
  my $mss = Koha::MarcSubfieldStructures->search({ frameworkcode => $fwkcode, kohafield => 'items.location', authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
  my $authcode = $mss->count ? $mss->next->authorised_value : undef;
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
my @notforloans;
for my $statfield (qw/items.notforloan items.itemlost items.withdrawn items.damaged/){
    my $hash = {};
    $hash->{fieldname} = $statfield;
    my $mss = Koha::MarcSubfieldStructures->search({ frameworkcode => '', kohafield => $statfield, authorised_value => [ -and => {'!=' => undef }, {'!=' => ''}] });
    $hash->{authcode} = $mss->count ? $mss->next->authorised_value : undef;
    if ($hash->{authcode}){
        my $arr = GetAuthorisedValues($hash->{authcode});
        if ( $statfield eq 'items.notforloan') {
            # Add notforloan == 0 to the list of possible notforloan statuses
            # The lib value is replaced in the template
            push @$arr, { authorised_value => 0, id => 'stat0' , lib => 'ignore' } if ! grep { $_->{authorised_value} eq '0' } @$arr;
            @notforloans = map { $_->{'authorised_value'} } @$arr;
        }
        $hash->{values} = $arr;
        push @$statuses, $hash;
    }
}

$template->param( statuses => $statuses );
my $staton = {}; #authorized values that are ticked
for my $authvfield (@$statuses) {
    $staton->{$authvfield->{fieldname}} = [];
    for my $authval (@{$authvfield->{values}}){
        if ( defined $input->param('status-' . $authvfield->{fieldname} . '-' . $authval->{authorised_value}) && $input->param('status-' . $authvfield->{fieldname} . '-' . $authval->{authorised_value}) eq 'on' ){
            push @{$staton->{$authvfield->{fieldname}}}, $authval->{authorised_value};
        }
    }
}

$template->param(
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
    uploadedbarcodesflag     => $uploadbarcodes ? 1 : 0,
);

# Walk through uploaded barcodes, report errors, mark as seen, check in
my $results = {};
my @scanned_items;
my @errorloop;
my $moddatecount = 0;
if ( $uploadbarcodes && length($uploadbarcodes) > 0 ) {
    my $dbh = C4::Context->dbh;
    my $date = dt_from_string( scalar $input->param('setdate') );
    $date = output_pref ( { dt => $date, dateformat => 'iso' } );

    my $strsth  = "select * from issues, items where items.itemnumber=issues.itemnumber and items.barcode =?";
    my $qonloan = $dbh->prepare($strsth);
    $strsth="select * from items where items.barcode =? and items.withdrawn = 1";
    my $qwithdrawn = $dbh->prepare($strsth);

    my @barcodes;
    my @uploadedbarcodes;

    my $sth = $dbh->column_info(undef,undef,"items","barcode");
    my $barcode_def = $sth->fetchall_hashref('COLUMN_NAME');
    my $barcode_size = $barcode_def->{barcode}->{COLUMN_SIZE};
    my $err_length=0;
    my $err_data=0;
    my $lines_read=0;
    binmode($uploadbarcodes, ":encoding(UTF-8)");
    while (my $barcode=<$uploadbarcodes>) {
        push @uploadedbarcodes, grep { /\S/ } split( /[\n\r,;|-]/, $barcode );
    }
    for my $barcode (@uploadedbarcodes) {
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
                # Modify date last seen for scanned items, remove lost status
                ModItem( { itemlost => 0, datelastseen => $date }, undef, $item->{'itemnumber'} );
                $moddatecount++;
                # update item hash accordingly
                $item->{itemlost} = 0;
                $item->{datelastseen} = $date;
                unless ( $dont_checkin ) {
                    $qonloan->execute($barcode);
                    if ($qonloan->rows){
                        my $data = $qonloan->fetchrow_hashref;
                        my ($doreturn, $messages, $iteminformation, $borrower) =AddReturn($barcode, $data->{homebranch});
                        if( $doreturn ) {
                            $item->{onloan} = undef;
                            $item->{datelastseen} = dt_from_string;
                        } else {
                            push @errorloop, { barcode => $barcode, ERR_ONLOAN_NOT_RET => 1 };
                        }
                    }
                }
                push @scanned_items, $item;
            } else {
                push @errorloop, { barcode => $barcode, ERR_BARCODE => 1 };
            }
        }
    }
    $template->param( date => $date );
    $template->param( errorloop => \@errorloop ) if (@errorloop);
}

# Build inventorylist: used as result list when you do not pass barcodes
# This list is also used when you want to compare with barcodes
my ( $inventorylist, $rightplacelist );
if ( $op && ( !$uploadbarcodes || $compareinv2barcd )) {
    ( $inventorylist ) = GetItemsForInventory({
      minlocation  => $minlocation,
      maxlocation  => $maxlocation,
      location     => $location,
      ignoreissued => $ignoreissued,
      datelastseen => $datelastseen,
      branchcode   => $branchcode,
      branch       => $branch,
      offset       => 0,
      statushash   => $staton,
    });
}
# Build rightplacelist used to check if a scanned item is in the right place.
if( @scanned_items ) {
    ( $rightplacelist ) = GetItemsForInventory({
      minlocation  => $minlocation,
      maxlocation  => $maxlocation,
      location     => $location,
      ignoreissued => undef,
      datelastseen => undef,
      branchcode   => $branchcode,
      branch       => $branch,
      offset       => 0,
      statushash   => undef,
    });
    # Convert the structure to a hash on barcode
    $rightplacelist = {
        map { $_->{barcode} ? ( $_->{barcode}, $_ ) : (); } @$rightplacelist
    };
}

# Report scanned items that are on the wrong place, or have a wrong notforloan
# status, or are still checked out.
foreach my $item ( @scanned_items ) {
    $item->{notforloancode} = $item->{notforloan}; # save for later use
    my $fc = $item->{'frameworkcode'} || '';

    # Populating with authorised values description
    foreach my $field (qw/ location notforloan itemlost damaged withdrawn /) {
        my $av = Koha::AuthorisedValues->get_description_by_koha_field(
            { frameworkcode => $fc, kohafield => "items.$field", authorised_value => $item->{$field} } );
        if ( $av and defined $item->{$field} and defined $av->{lib} ) {
            $item->{$field} = $av->{lib};
        }
    }

    # If we have scanned items with a non-matching notforloan value
    if( none { $item->{'notforloancode'} eq $_ } @notforloans ) {
        $item->{problems}->{changestatus} = 1;
        additemtoresults( $item, $results );
    }

    # Report an item that is checked out (unusual!) or wrongly placed
    if( $item->{onloan} ) {
        $item->{problems}->{checkedout} = 1;
        additemtoresults( $item, $results );
        next; # do not modify item
    } elsif( !exists $rightplacelist->{ $item->{barcode} } ) {
        $item->{problems}->{wrongplace} = 1;
        additemtoresults( $item, $results );
    }
}

# Compare barcodes with inventory list, report no_barcode and not_scanned.
# not_scanned can be interpreted as missing
if ( $compareinv2barcd ) {
    my @scanned_barcodes = map {$_->{barcode}} @scanned_items;
    for my $item ( @$inventorylist ) {
        my $barcode = $item->{barcode};
        if( !$barcode ) {
            $item->{problems}->{no_barcode} = 1;
        } elsif ( grep /^$barcode$/, @scanned_barcodes ) {
            next;
        } else {
            $item->{problems}->{not_scanned} = 1;
        }
        additemtoresults( $item, $results );
    }
}

# Construct final results, add biblio information
my $loop = $uploadbarcodes
    ? [ map { $results->{$_} } keys %$results ]
    : $inventorylist // [];
for my $item ( @$loop ) {
    my $biblio = Koha::Biblios->find( $item->{biblionumber} );
    $item->{title} = $biblio->title;
    $item->{author} = $biblio->author;
}

$template->param(
    moddatecount => $moddatecount,
    loop         => $loop,
    op           => $op,
);

# Export to csv
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

    my @keys = qw/ title author barcode itemnumber homebranch location itemcallnumber notforloan itemlost damaged withdrawn stocknumber /;
    for my $item ( @$loop ) {
        my @line;
        for my $key (@keys) {
            push @line, $item->{$key};
        }
        my $errstr = '';
        foreach my $key ( keys %{$item->{problems}} ) {
            if( $key eq 'wrongplace' ) {
                $errstr .= "wrong place,";
            } elsif( $key eq 'changestatus' ) {
                $errstr .= "unknown notforloan status,";
            } elsif( $key eq 'not_scanned' ) {
                $errstr .= "missing,";
            } elsif( $key eq 'no_barcode' ) {
                $errstr .= "no barcode,";
            } elsif( $key eq 'checkedout' ) {
                $errstr .= "checked out,";
            }
        }
        $errstr =~ s/,$//;
        push @line, $errstr;
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

sub additemtoresults {
    my ( $item, $results ) = @_;
    my $itemno = $item->{itemnumber};
    # since the script appends to $item, we can just overwrite the hash entry
    $results->{$itemno} = $item;
}
