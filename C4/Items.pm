package C4::Items;

# Copyright 2007 LibLime, Inc.
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

require Exporter;

use C4::Context;
use C4::Biblio;
use C4::Dates;
use MARC::Record;
use C4::ClassSource;
use C4::Log;

use vars qw($VERSION @ISA @EXPORT);

my $VERSION = 3.00;

@ISA = qw( Exporter );

# function exports
@EXPORT = qw(
    AddItemFromMarc
    AddItem
    ModItemFromMarc
    ModItem
    ModDateLastSeen
    ModItemTransfer
);

=head1 NAME

C4::Items - item management functions

=head1 DESCRIPTION

This module contains an API for manipulating item 
records in Koha, and is used by cataloguing, circulation,
acquisitions, and serials management.

A Koha item record is stored in two places: the
items table and embedded in a MARC tag in the XML
version of the associated bib record in C<biblioitems.marcxml>.
This is done to allow the item information to be readily
indexed (e.g., by Zebra), but means that each item
modification transaction must keep the items table
and the MARC XML in sync at all times.

Consequently, all code that creates, modifies, or deletes
item records B<must> use an appropriate function from 
C<C4::Items>.  If no existing function is suitable, it is
better to add one to C<C4::Items> than to use add
one-off SQL statements to add or modify items.

The items table will be considered authoritative.  In other
words, if there is ever a discrepancy between the items
table and the MARC XML, the items table should be considered
accurate.

=head1 HISTORICAL NOTE

Most of the functions in C<C4::Items> were originally in
the C<C4::Biblio> module.

=head1 EXPORTED FUNCTIONS

The following functions are meant for use by users
of C<C4::Items>

=cut

=head2 AddItemFromMarc

=over 4

my ($biblionumber, $biblioitemnumber, $itemnumber) 
    = AddItemFromMarc($source_item_marc, $biblionumber);

=back

Given a MARC::Record object containing an embedded item
record and a biblionumber, create a new item record.

=cut

sub AddItemFromMarc {
    my ( $source_item_marc, $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;

    # parse item hash from MARC
    my $frameworkcode = GetFrameworkCode( $biblionumber );
    my $item = &TransformMarcToKoha( $dbh, $source_item_marc, $frameworkcode );

    return AddItem($item, $biblionumber, $dbh, $frameworkcode);
}

=head2 AddItem

=over 4

my ($biblionumber, $biblioitemnumber, $itemnumber) 
    = AddItem($item, $biblionumber[, $dbh, $frameworkcode]);

=back

Given a hash containing item column names as keys,
create a new Koha item record.

The two optional parameters (C<$dbh> and C<$frameworkcode>)
do not need to be supplied for general use; they exist
simply to allow them to be picked up from AddItemFromMarc.

=cut

sub AddItem {
    my $item = shift;
    my $biblionumber = shift;

    my $dbh           = @_ ? shift : C4::Context->dbh;
    my $frameworkcode = @_ ? shift : GetFrameworkCode( $biblionumber );

    # needs old biblionumber and biblioitemnumber
    $item->{'biblionumber'} = $biblionumber;
    my $sth = $dbh->prepare("SELECT biblioitemnumber FROM biblioitems WHERE biblionumber=?");
    $sth->execute( $item->{'biblionumber'} );
    ($item->{'biblioitemnumber'}) = $sth->fetchrow;

    _set_defaults_for_add($item);
    _set_derived_columns_for_add($item);
    # FIXME - checks here
    my ( $itemnumber, $error ) = _koha_new_item( $dbh, $item, $item->{barcode} );
    $item->{'itemnumber'} = $itemnumber;

    # create MARC tag representing item and add to bib
    my $new_item_marc = _marc_from_item_hash($item, $frameworkcode);
    _add_item_field_to_biblio($new_item_marc, $item->{'biblionumber'}, $frameworkcode );
   
    logaction(C4::Context->userenv->{'number'},"CATALOGUING","ADD",$itemnumber,"item") 
        if C4::Context->preference("CataloguingLog");
    
    return ($item->{biblionumber}, $item->{biblioitemnumber}, $itemnumber);
}

=head2 ModItemFromMarc

=cut

sub ModItemFromMarc {
    my $item_marc = shift;
    my $biblionumber = shift;
    my $itemnumber = shift;

    my $dbh = C4::Context->dbh;
    my $frameworkcode = GetFrameworkCode( $biblionumber );
    my $item = &TransformMarcToKoha( $dbh, $item_marc, $frameworkcode );
   
    return ModItem($item, $biblionumber, $itemnumber, $dbh, $frameworkcode); 
}

=head2 ModItem

=cut

sub ModItem {
    my $item = shift;
    my $biblionumber = shift;
    my $itemnumber = shift;

    # if $biblionumber is undefined, get it from the current item
    unless (defined $biblionumber) {
        $biblionumber = _get_single_item_column('biblionumber', $itemnumber);
    }

    my $dbh           = @_ ? shift : C4::Context->dbh;
    my $frameworkcode = @_ ? shift : GetFrameworkCode( $biblionumber );

    $item->{'itemnumber'} = $itemnumber;
    _set_derived_columns_for_mod($item);
    _do_column_fixes_for_mod($item);
    # FIXME add checks

    # update items table
    _koha_modify_item($dbh, $item);

    # update biblio MARC XML
    my $whole_item = GetItem($itemnumber);
    my $new_item_marc = _marc_from_item_hash($whole_item, $frameworkcode);
    _replace_item_field_in_biblio($new_item_marc, $biblionumber, $itemnumber, $frameworkcode);
    
    logaction(C4::Context->userenv->{'number'},"CATALOGUING","MODIFY",$itemnumber,$new_item_marc->as_formatted)
        if C4::Context->preference("CataloguingLog");
}

=head2 ModItemTransfer

=cut

sub ModItemTransfer {
    my ( $itemnumber, $frombranch, $tobranch ) = @_;

    my $dbh = C4::Context->dbh;

    #new entry in branchtransfers....
    my $sth = $dbh->prepare(
        "INSERT INTO branchtransfers (itemnumber, frombranch, datesent, tobranch)
        VALUES (?, ?, NOW(), ?)");
    $sth->execute($itemnumber, $frombranch, $tobranch);

    ModItem({ holdingbranch => $tobranch }, undef, $itemnumber);
    ModDateLastSeen($itemnumber);
    return;
}

=head2 ModDateLastSeen

=over 4

ModDateLastSeen($itemnum);

=back

Mark item as seen. Is called when an item is issued, returned or manually marked during inventory/stocktaking.
C<$itemnum> is the item number

=cut

sub ModDateLastSeen {
    my ($itemnumber) = @_;
    
    my $today = C4::Dates->new();    
    ModItem({ itemlost => 0, datelastseen => $today->output("iso") }, undef, $itemnumber);
}

=head1 PRIVATE FUNCTIONS AND VARIABLES

The following functions are not meant to be called
directly, but are documented in order to explain
the inner workings of C<C4::Items>.

=cut

=head2 %derived_columns

This hash keeps track of item columns that
are strictly derived from other columns in
the item record and are not meant to be set
independently.

Each key in the hash should be the name of a
column (as named by TransformMarcToKoha).  Each
value should be hashref whose keys are the
columns on which the derived column depends.  The
hashref should also contain a 'BUILDER' key
that is a reference to a sub that calculates
the derived value.

=cut

my %derived_columns = (
    'items.cn_sort' => {
        'itemcallnumber' => 1,
        'items.cn_source' => 1,
        'BUILDER' => \&_calc_items_cn_sort,
    }
);

=head2 _set_derived_columns_for_add 

=over 4

_set_derived_column_for_add($item);

=back

Given an item hash representing a new item to be added,
calculate any derived columns.  Currently the only
such column is C<items.cn_sort>.

=cut

sub _set_derived_columns_for_add {
    my $item = shift;

    foreach my $column (keys %derived_columns) {
        my $builder = $derived_columns{$column}->{'BUILDER'};
        my $source_values = {};
        foreach my $source_column (keys %{ $derived_columns{$column} }) {
            next if $source_column eq 'BUILDER';
            $source_values->{$source_column} = $item->{$source_column};
        }
        $builder->($item, $source_values);
    }
}

=head2 _set_derived_columns_for_mod 

=over 4

_set_derived_column_for_mod($item);

=back

Given an item hash representing a new item to be modified.
calculate any derived columns.  Currently the only
such column is C<items.cn_sort>.

This routine differs from C<_set_derived_columns_for_add>
in that it needs to handle partial item records.  In other
words, the caller of C<ModItem> may have supplied only one
or two columns to be changed, so this function needs to
determine whether any of the columns to be changed affect
any of the derived columns.  Also, if a derived column
depends on more than one column, but the caller is not
changing all of then, this routine retrieves the unchanged
values from the database in order to ensure a correct
calculation.

=cut

sub _set_derived_columns_for_mod {
    my $item = shift;

    foreach my $column (keys %derived_columns) {
        my $builder = $derived_columns{$column}->{'BUILDER'};
        my $source_values = {};
        my %missing_sources = ();
        my $must_recalc = 0;
        foreach my $source_column (keys %{ $derived_columns{$column} }) {
            next if $source_column eq 'BUILDER';
            if (exists $item->{$source_column}) {
                $must_recalc = 1;
                $source_values->{$source_column} = $item->{$source_column};
            } else {
                $missing_sources{$source_column} = 1;
            }
        }
        if ($must_recalc) {
            foreach my $source_column (keys %missing_sources) {
                $source_values->{$source_column} = _get_single_item_column($source_column, $item->{'itemnumber'});
            }
            $builder->($item, $source_values);
        }
    }
}

=head2 _do_column_fixes_for_mod

=over 4

_do_column_fixes_for_mod($item);

=back

Given an item hashref containing one or more
columns to modify, fix up certain values.
Specifically, set to 0 any passed value
of C<notforloan>, C<damaged>, C<itemlost>, or
C<wthdrawn> that is either undefined or
contains the empty string.

=cut

sub _do_column_fixes_for_mod {
    my $item = shift;

    if (exists $item->{'notforloan'} and
        (not defined $item->{'notforloan'} or $item->{'notforloan'} eq '')) {
        $item->{'notforloan'} = 0;
    }
    if (exists $item->{'damaged'} and
        (not defined $item->{'damaged'} or $item->{'damaged'} eq '')) {
        $item->{'damaged'} = 0;
    }
    if (exists $item->{'itemlost'} and
        (not defined $item->{'itemlost'} or $item->{'itemlost'} eq '')) {
        $item->{'itemlost'} = 0;
    }
    if (exists $item->{'wthdrawn'} and
        (not defined $item->{'wthdrawn'} or $item->{'wthdrawn'} eq '')) {
        $item->{'wthdrawn'} = 0;
    }
}

=head2 _get_single_item_column

=over 4

_get_single_item_column($column, $itemnumber);

=back

Retrieves the value of a single column from an C<items>
row specified by C<$itemnumber>.

=cut

sub _get_single_item_column {
    my $column = shift;
    my $itemnumber = shift;
    
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("SELECT $column FROM items WHERE itemnumber = ?");
    $sth->execute($itemnumber);
    my ($value) = $sth->fetchrow();
    return $value; 
}

=head2 _calc_items_cn_sort

=over 4

_calc_items_cn_sort($item, $source_values);

=back

Helper routine to calculate C<items.cn_sort>.

=cut

sub _calc_items_cn_sort {
    my $item = shift;
    my $source_values = shift;

    $item->{'items.cn_sort'} = GetClassSort($source_values->{'items.cn_source'}, $source_values->{'itemcallnumber'}, "");
}

=head2 _set_defaults_for_add 

=over 4

_set_defaults_for_add($item_hash);

=back

Given an item hash representing an item to be added, set
correct default values for columns whose default value
is not handled by the DBMS.  This includes the following
columns:

=over 2

=item * 

C<items.dateaccessioned>

=item *

C<items.notforloan>

=item *

C<items.damaged>

=item *

C<items.itemlost>

=item *

C<items.wthdrawn>

=back

=cut

sub _set_defaults_for_add {
    my $item = shift;

    # if dateaccessioned is provided, use it. Otherwise, set to NOW()
    if (!(exists $item->{'dateaccessioned'}) || 
         ($item->{'dateaccessioned'} eq '')) {
        # FIXME add check for invalid date
        my $today = C4::Dates->new();    
        $item->{'dateaccessioned'} =  $today->output("iso"); #TODO: check time issues
    }

    # various item status fields cannot be null
    $item->{'notforloan'} = 0 unless exists $item->{'notforloan'} and defined $item->{'notforloan'};
    $item->{'damaged'}    = 0 unless exists $item->{'damaged'}    and defined $item->{'damaged'};
    $item->{'itemlost'}   = 0 unless exists $item->{'itemlost'}   and defined $item->{'itemlost'};
    $item->{'wthdrawn'}   = 0 unless exists $item->{'wthdrawn'}   and defined $item->{'wthdrawn'};
}

=head2 _set_calculated_values

=head2 _koha_new_item

=over 4

my ($itemnumber,$error) = _koha_new_item( $dbh, $item, $barcode );

=back

=cut

sub _koha_new_item {
    my ( $dbh, $item, $barcode ) = @_;
    my $error;

    my $query = 
           "INSERT INTO items SET
            biblionumber        = ?,
            biblioitemnumber    = ?,
            barcode             = ?,
            dateaccessioned     = ?,
            booksellerid        = ?,
            homebranch          = ?,
            price               = ?,
            replacementprice    = ?,
            replacementpricedate = NOW(),
            datelastborrowed    = ?,
            datelastseen        = NOW(),
            stack               = ?,
            notforloan          = ?,
            damaged             = ?,
            itemlost            = ?,
            wthdrawn            = ?,
            itemcallnumber      = ?,
            restricted          = ?,
            itemnotes           = ?,
            holdingbranch       = ?,
            paidfor             = ?,
            location            = ?,
            onloan              = ?,
            issues              = ?,
            renewals            = ?,
            reserves            = ?,
            cn_source           = ?,
            cn_sort             = ?,
            ccode               = ?,
            itype               = ?,
            materials           = ?,
            uri                 = ?
          ";
    my $sth = $dbh->prepare($query);
    $sth->execute(
            $item->{'biblionumber'},
            $item->{'biblioitemnumber'},
            $barcode,
            $item->{'dateaccessioned'},
            $item->{'booksellerid'},
            $item->{'homebranch'},
            $item->{'price'},
            $item->{'replacementprice'},
            $item->{datelastborrowed},
            $item->{stack},
            $item->{'notforloan'},
            $item->{'damaged'},
            $item->{'itemlost'},
            $item->{'wthdrawn'},
            $item->{'itemcallnumber'},
            $item->{'restricted'},
            $item->{'itemnotes'},
            $item->{'holdingbranch'},
            $item->{'paidfor'},
            $item->{'location'},
            $item->{'onloan'},
            $item->{'issues'},
            $item->{'renewals'},
            $item->{'reserves'},
            $item->{'items.cn_source'},
            $item->{'items.cn_sort'},
            $item->{'ccode'},
            $item->{'itype'},
            $item->{'materials'},
            $item->{'uri'},
    );
    my $itemnumber = $dbh->{'mysql_insertid'};
    if ( defined $sth->errstr ) {
        $error.="ERROR in _koha_new_item $query".$sth->errstr;
    }
    $sth->finish();
    return ( $itemnumber, $error );
}

=head2 _koha_modify_item

=over 4

my ($itemnumber,$error) =_koha_modify_item( $dbh, $item, $op );

=back

=cut

sub _koha_modify_item {
    my ( $dbh, $item ) = @_;
    my $error;

    my $query = "UPDATE items SET ";
    my @bind;
    for my $key ( keys %$item ) {
        $query.="$key=?,";
        push @bind, $item->{$key};
    }
    $query =~ s/,$//;
    $query .= " WHERE itemnumber=?";
    push @bind, $item->{'itemnumber'};
    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    if ( $dbh->errstr ) {
        $error.="ERROR in _koha_modify_item $query".$dbh->errstr;
        warn $error;
    }
    $sth->finish();
    return ($item->{'itemnumber'},$error);
}

=head2 _marc_from_item_hash

=over 4

my $item_marc = _marc_from_item_hash($item, $frameworkcode);

=back

Given an item hash representing a complete item record,
create a C<MARC::Record> object containing an embedded
tag representing that item.

=cut

sub _marc_from_item_hash {
    my $item = shift;
    my $frameworkcode = shift;
   
    # Tack on 'items.' prefix to column names so lookup from MARC frameworks will work
    # Also, don't emit a subfield if the underlying field is blank.
    my $mungeditem = { map {  $item->{$_} ne '' ? 
                                (/^items\./ ? ($_ => $item->{$_}) : ("items.$_" => $item->{$_})) 
                                : ()  } keys %{ $item } }; 

    my $item_marc = MARC::Record->new();
    foreach my $item_field (keys %{ $mungeditem }) {
        my ($tag, $subfield) = GetMarcFromKohaField($item_field, $frameworkcode);
        next unless defined $tag and defined $subfield; # skip if not mapped to MARC field
        if (my $field = $item_marc->field($tag)) {
            $field->add_subfields($subfield => $mungeditem->{$item_field});
        } else {
            $item_marc->add_fields( $tag, " ", " ", $subfield =>  $mungeditem->{$item_field});
        }
    }

    return $item_marc;
}

=head2 _add_item_field_to_biblio

=over 4

_add_item_field_to_biblio($record, $biblionumber, $frameworkcode);

=back

Adds the fields from a MARC record containing the
representation of a Koha item record to the MARC
biblio record.  The input C<$item_marc> record
is expect to contain just one field, the embedded
item information field.

=cut

sub _add_item_field_to_biblio {
    my ($item_marc, $biblionumber, $frameworkcode) = @_;

    my $biblio_marc = GetMarcBiblio($biblionumber);

    foreach my $field ($item_marc->fields()) {
        $biblio_marc->append_fields($field);
    }

    ModBiblioMarc($biblio_marc, $biblionumber, $frameworkcode);
}

=head2 _replace_item_field_in_biblio

=over

&_replace_item_field_in_biblio( $record, $biblionumber, $itemnumber, $frameworkcode )

=back

=cut

sub _replace_item_field_in_biblio {
    my ($ItemRecord, $biblionumber, $itemnumber, $frameworkcode) = @_;
    my $dbh = C4::Context->dbh;
    
    # get complete MARC record & replace the item field by the new one
    my $completeRecord = GetMarcBiblio($biblionumber);
    my ($itemtag,$itemsubfield) = GetMarcFromKohaField("items.itemnumber",$frameworkcode);
    my $itemField = $ItemRecord->field($itemtag);
    my @items = $completeRecord->field($itemtag);
    foreach (@items) {
        if ($_->subfield($itemsubfield) eq $itemnumber) {
            $_->replace_with($itemField);
        }
    }

    # save the record
    ModBiblioMarc($completeRecord, $biblionumber, $frameworkcode);
}

1;
