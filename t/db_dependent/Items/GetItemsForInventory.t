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
use Test::More tests => 6;

use Koha::AuthorisedValues;

$| = 1;

BEGIN {
    use_ok('C4::Context');
    use_ok('C4::Items');
    use_ok('C4::Biblio');
    use_ok('C4::Koha');
}

can_ok('C4::Items','GetItemsForInventory');

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

my ($oldResults, $oldCount) = OldWay($dbh);
my ($newResults, $newCount) = GetItemsForInventory;

is_deeply($newResults,$oldResults,"Inventory results unchanged.");

$dbh->rollback;

sub OldWay {
    my ($tdbh)       = @_;
    my $ldbh         = $tdbh;
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
