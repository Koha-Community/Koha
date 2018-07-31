#!/usr/bin/perl

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

use Koha::Items;
use Koha::Authorities;

{
    my $items = Koha::Items->search({ -or => { homebranch => undef, holdingbranch => undef }});
    if ( $items->count ) { new_section("Not defined items.homebranch and/or items.holdingbranch")}
    while ( my $item = $items->next ) {
        if ( not $item->homebranch and not $item->holdingbranch ) {
            new_item(sprintf "Item with itemnumber=%s does not have homebranch and holdingbranch defined", $item->itemnumber);
        } elsif ( not $item->homebranch ) {
            new_item(sprintf "Item with itemnumber=%s does not have homebranch defined", $item->itemnumber);
        } else {
            new_item(sprintf "Item with itemnumber=%s does not have holdingbranch defined", $item->itemnumber);
        }
    }
    if ( $items->count ) { new_hint("Edit these items and set valid homebranch and/or holdingbranch")}
}

{
    # No join possible, FK is missing at DB level
    my @auth_types = Koha::Authority::Types->search->get_column('authtypecode');
    my $authorities = Koha::Authorities->search({authtypecode => { 'not in' => \@auth_types } });
    if ( $authorities->count ) {new_section("Invalid auth_header.authtypecode")}
    while ( my $authority = $authorities->next ) {
        new_item(sprintf "Authority with authid=%s does not have a code defined (%s)", $authority->authid, $authority->authtypecode);
    }
    if ( $authorities->count ) {new_hint("Go to 'Home › Administration › Authority types' to define them")}
}

sub new_section {
    my ( $name ) = @_;
    say "\n== $name ==";
}

sub new_item {
    my ( $name ) = @_;
    say "\t* $name";
}
sub new_hint {
    my ( $name ) = @_;
    say "=> $name";
}

=head1 NAME

search_for_data_inconsistencies.pl

=head1 SYNOPSIS

    perl search_for_data_inconsistencies.pl

=head1 DESCRIPTION

Catch data inconsistencies in Koha database

* Items with undefined homebranch and/or holdingbranch
* Authorities with undefined authtypecodes/authority types

=cut
