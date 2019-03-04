#!/usr/bin/perl
#
# This file is part of Koha.
#
# Copyright (c) 2015   Mark Tompsett
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

use Test::More tests => 9;
use t::lib::TestBuilder;

use List::MoreUtils qw( any none );

use C4::Biblio qw(AddBiblio);
use C4::Reserves;
use C4::ClassSource;
use Koha::AuthorisedValues;
use Koha::Biblios;
use Koha::Database;
use MARC::Record;

BEGIN {
    use_ok('C4::Context');
    use_ok('C4::Items');
    use_ok('C4::Biblio');
    use_ok('C4::Koha');
}

can_ok('C4::Items','GetItemsForInventory');

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Old version is unchanged' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $dbh = $schema->storage->dbh;

    my ($oldResults, $oldCount) = OldWay($dbh);
    my ($newResults, $newCount) = GetItemsForInventory;

    is_deeply($newResults,$oldResults,"Inventory results unchanged.");

    $schema->storage->txn_rollback;
};

subtest 'Skip items with waiting holds' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $itemtype
        = $builder->build_object( { class => 'Koha::ItemTypes', value => { rentalcharge => 0 } } );
    my $patron_1 = $builder->build_object(
        { class => 'Koha::Patrons', value => { branchcode => $library->id } } );
    my $patron_2 = $builder->build_object(
        { class => 'Koha::Patrons', value => { branchcode => $library->id } } );


    my $title_1 = 'Title 1, ';
    my $title_2 = 'Title 2, bizzarre one so doesn\'t already exist';

    my $biblio_1 = $builder->build_sample_biblio({ itemtype => $itemtype->itemtype, title => $title_1 });
    my $biblio_2 = $builder->build_sample_biblio({ itemtype => $itemtype->itemtype, title => $title_2 });

    my ( $items_1, $first_items_count ) = GetItemsForInventory();
    is( scalar @{$items_1}, $first_items_count, 'Results and count match' );

    # Add two items, so we don't depend on existing data
    my $item_1 = $builder->build_object(
        {   class => 'Koha::Items',
            value => {
                biblionumber     => $biblio_1->biblionumber,
                biblioitemnumber => $biblio_1->biblioitem->biblioitemnumber,
                homebranch       => $library->id,
                holdingbranch    => $library->id,
                itype            => $itemtype->itemtype,
                reserves         => undef
            }
        }
    );

    my $item_2 = $builder->build_object(
        {   class => 'Koha::Items',
            value => {
                biblionumber     => $biblio_2->biblionumber,
                biblioitemnumber => $biblio_2->biblioitem->biblioitemnumber,
                homebranch       => $library->id,
                holdingbranch    => $library->id,
                itype            => $itemtype->itemtype,
                reserves         => undef
            }
        }
    );

    my ( $items_2, $second_items_count ) = GetItemsForInventory();
    is( scalar @{$items_2},     $second_items_count, 'Results and count match' );
    is( $first_items_count + 2, $second_items_count, 'Two items added, count makes sense' );

    # Add 2 waiting holds
    C4::Reserves::AddReserve( $library->branchcode, $patron_1->borrowernumber,
        $item_1->biblionumber, '', 1, undef, undef, '', "title for fee",
        $item_1->itemnumber, 'W' );
    C4::Reserves::AddReserve( $library->branchcode, $patron_1->borrowernumber,
        $item_2->biblionumber, '', 1, undef, undef, '', "title for fee",
        $item_2->itemnumber, undef );
    C4::Reserves::AddReserve( $library->branchcode, $patron_2->borrowernumber,
        $item_2->biblionumber, '', 2, undef, undef, '', "title for fee",
        $item_2->itemnumber, undef );

    my ( $new_items, $new_items_count ) = GetItemsForInventory( { ignore_waiting_holds => 1 } );
    is( $new_items_count, $first_items_count + 1, 'Item on hold skipped, count makes sense' );
    ok( (any { $_->{title} eq $title_2 } @{$new_items}),
        'Item on hold skipped, the other one we added is present' );
    ok( (none { $_->{title} eq $title_1 } @{$new_items}),
        'Item on hold skipped, no one matches' );
    is( scalar(@$new_items), $new_items_count, 'total and number of items is the same');

    $schema->storage->txn_rollback;
};

subtest 'Verify results with OldWay' => sub {
    $schema->storage->txn_begin;
    plan tests => 1;

    my ($oldResults, $oldCount) = OldWay();
    my ($newResults, $newCount) = GetItemsForInventory();
    is_deeply($newResults,$oldResults,"Inventory results unchanged.");
    $schema->storage->txn_rollback;
};

subtest 'Use cn_sort rather than callnumber to determine correct location' => sub {
    $schema->storage->txn_begin;
    plan tests => 1;

    my $builder = t::lib::TestBuilder->new;

    my $class_rule = $builder->build({
        source => 'ClassSortRule',
        value => { sort_routine => "LCC" }
    });
    my $class_source = $builder->build({
        source => 'ClassSource',
        value => {
            class_sort_rule => $class_rule->{class_sort_rule},
        }
    });

    #Find if we have any items in our test range before we start
    my( undef, $pre_item_count) = GetItemsForInventory({
        maxlocation => 'GT100',
        minlocation => 'GT90',
        class_source => $class_source->{cn_source},
    });

    my $item_1 = $builder->build({
            source => 'Item',
            value  => {
                itemcallnumber => 'GT95',
                cn_sort => GetClassSort($class_source->{cn_source},undef,'GT95'),
            }
    });

    my( undef, $item_count) = GetItemsForInventory({
        maxlocation => 'GT100',
        minlocation => 'GT90',
        class_source => $class_source->{cn_source},
    });
    is($item_count,$pre_item_count + 1,"We should return GT95 as between GT90 and GT100");
    $schema->storage->txn_rollback;

};

sub OldWay { # FIXME Do we really still need so much code to check results ??
    my $ldbh = C4::Context->dbh;

    my $minlocation  = '';
    my $maxlocation  = '';
    my $location     = '';
    my $itemtype     = '';
    my $ignoreissued = '';
    my $datelastseen = '';
    my $branchcode   = '';
    my $branch       = '';
    my $offset       = '';
    my $size         = '';
    my $statushash   = '';

    my ( @bind_params, @where_strings );

    my $select_columns = q{
        SELECT items.itemnumber, barcode, itemcallnumber, title, author, biblio.biblionumber, biblio.frameworkcode, datelastseen, homebranch, location, notforloan, damaged, itemlost, withdrawn, stocknumber
    };
    my $select_count = q{SELECT COUNT(*)};
    my $query = q{
        FROM items
        LEFT JOIN biblio ON items.biblionumber = biblio.biblionumber
        LEFT JOIN biblioitems on items.biblionumber = biblioitems.biblionumber
    };
    if ($statushash){
        for my $authvfield (keys %$statushash){
            if ( scalar @{$statushash->{$authvfield}} > 0 ){
                my $joinedvals = join ',', @{$statushash->{$authvfield}};
                push @where_strings, "$authvfield in (" . $joinedvals . ")";
            }
        }
    }

    if ($minlocation) {
        push @where_strings, 'itemcallnumber >= ?';
        push @bind_params, $minlocation;
    }

    if ($maxlocation) {
        push @where_strings, 'itemcallnumber <= ?';
        push @bind_params, $maxlocation;
    }

    if ($datelastseen) {
        $datelastseen = output_pref({ str => $datelastseen, dateformat => 'iso', dateonly => 1 });
        push @where_strings, '(datelastseen < ? OR datelastseen IS NULL)';
        push @bind_params, $datelastseen;
    }

    if ( $location ) {
        push @where_strings, 'items.location = ?';
        push @bind_params, $location;
    }

    if ( $branchcode ) {
        if($branch eq "homebranch"){
        push @where_strings, 'items.homebranch = ?';
        }else{
            push @where_strings, 'items.holdingbranch = ?';
        }
        push @bind_params, $branchcode;
    }

    if ( $itemtype ) {
        push @where_strings, 'biblioitems.itemtype = ?';
        push @bind_params, $itemtype;
    }

    if ( $ignoreissued) {
        $query .= "LEFT JOIN issues ON items.itemnumber = issues.itemnumber ";
        push @where_strings, 'issues.date_due IS NULL';
    }

    if ( @where_strings ) {
        $query .= 'WHERE ';
        $query .= join ' AND ', @where_strings;
    }
    my $count_query = $select_count . $query;
    $query .= ' ORDER BY items.cn_sort, itemcallnumber, title';
    $query .= " LIMIT $offset, $size" if ($offset and $size);
    $query = $select_columns . $query;
    my $sth = $ldbh->prepare($query);
    $sth->execute( @bind_params );

    my @results = ();
    my $tmpresults = $sth->fetchall_arrayref({});
    $sth = $ldbh->prepare( $count_query );
    $sth->execute( @bind_params );
    my ($iTotalRecords) = $sth->fetchrow_array();

    my $marc_field_mapping;
    foreach my $row (@$tmpresults) {

        # Auth values
        foreach my $field (sort keys %$row) {
            # If the koha field is mapped to a marc field
            my ($f, $sf) = C4::Biblio::GetMarcFromKohaField("items.$field", $row->{'frameworkcode'});
            if (defined($f) and defined($sf)) {
                # We replace the code with it's description
                my $avs;
                if ( exists $marc_field_mapping->{$row->{frameworkcode}}{$f}{$sf} ) {
                    $avs = $marc_field_mapping->{$row->{frameworkcode}}{$f}{$sf};
                } else {
                    $avs = Koha::AuthorisedValues->search_by_marc_field({ frameworkcode => $row->{frameworkcode}, tagfield => $f, tagsubfield => $sf, });
                    $marc_field_mapping->{$row->{frameworkcode}}{$f}{$sf} = $avs->unblessed;
                }
                my $authvals = { map { $_->{authorised_value} => $_->{lib} } @{ $marc_field_mapping->{$row->{frameworkcode}}{$f}{$sf} } };
                $row->{$field} = $authvals->{$row->{$field}} if defined $authvals && defined $row->{$field} && defined $authvals->{$row->{$field}};
            }
        }
        push @results, $row;
    }

    return (\@results, $iTotalRecords);
}
