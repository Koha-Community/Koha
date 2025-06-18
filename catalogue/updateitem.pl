#!/usr/bin/perl

# $Id: updateitem.pl,v 1.9.2.1.2.4 2006/10/05 18:36:50 kados Exp $
# Copyright 2006 LibLime
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.
use Modern::Perl;
use CGI      qw ( -utf8 );
use C4::Auth qw( checkauth );
use C4::Context;
use C4::Output;
use C4::Circulation qw( LostItem );
use C4::Reserves;

my $cgi = CGI->new;

checkauth( $cgi, 0, { circulate => 'circulate_remaining_permissions' }, 'intranet' );

my $op                                = $cgi->param('op') || "";
my $biblionumber                      = $cgi->param('biblionumber');
my $itemnumber                        = $cgi->param('itemnumber');
my $biblioitemnumber                  = $cgi->param('biblioitemnumber');
my $itemlost                          = $cgi->param('itemlost');
my $itemnotes                         = $cgi->param('itemnotes');
my $itemnotes_nonpublic               = $cgi->param('itemnotes_nonpublic');
my $withdrawn                         = $cgi->param('withdrawn');
my $damaged                           = $cgi->param('damaged');
my $exclude_from_local_holds_priority = $cgi->param('exclude_from_local_holds_priority');
my $bookable                          = $cgi->param('bookable') // q{};

my $confirm = $cgi->param('confirm');
my $dbh     = C4::Context->dbh;

# get the rest of this item's information
my $item              = Koha::Items->find($itemnumber);
my $item_data_hashref = $item->unblessed;

# make sure item statuses are set to 0 if empty or NULL
for ( $damaged, $itemlost, $withdrawn ) {
    if ( !$_ or $_ eq "" ) {
        $_ = 0;
    }
}

my $messages = q{};

# modify MARC item if input differs from items table.
if ( $op eq "cud-set_non_public_note" ) {
    checkauth( $cgi, 0, { editcatalogue => 'edit_items' }, 'intranet' );
    if ( ( not defined $item_data_hashref->{'itemnotes_nonpublic'} )
        or $itemnotes_nonpublic ne $item_data_hashref->{'itemnotes_nonpublic'} )
    {
        $item->itemnotes_nonpublic($itemnotes_nonpublic);
    }
} elsif ( $op eq "cud-set_public_note" ) {    # i.e., itemnotes parameter passed from form
    checkauth( $cgi, 0, { editcatalogue => 'edit_items' }, 'intranet' );
    if ( ( not defined $item_data_hashref->{'itemnotes'} ) or $itemnotes ne $item_data_hashref->{'itemnotes'} ) {
        $item->itemnotes($itemnotes);
    }
} elsif ( $op eq "cud-set_lost" && $itemlost ne $item_data_hashref->{'itemlost'} ) {
    $item->itemlost($itemlost);
} elsif ( $op eq "cud-set_withdrawn" && $withdrawn ne $item_data_hashref->{'withdrawn'} ) {
    $item->withdrawn($withdrawn);
} elsif ( $op eq "cud-set_exclude_priority"
    && $exclude_from_local_holds_priority ne $item_data_hashref->{'exclude_from_local_holds_priority'} )
{
    $item->exclude_from_local_holds_priority($exclude_from_local_holds_priority);
    $messages = "updated_exclude_from_local_holds_priority=$exclude_from_local_holds_priority&";
} elsif ( $op eq "cud-set_bookable" && $bookable ne $item_data_hashref->{'bookable'} ) {
    undef $bookable if $bookable eq q{};
    $item->bookable($bookable);
} elsif ( $op eq "cud-set_damaged" && $damaged ne $item_data_hashref->{'damaged'} ) {
    $item->damaged($damaged);
} else {

    #nothings changed, so do nothing.
    print $cgi->redirect("moredetail.pl?biblionumber=$biblionumber&itemnumber=$itemnumber#item$itemnumber");
    exit;
}
eval { $item->store; };
if ($@) {
    my $error_message = $@->message;
    print $cgi->redirect(
        "moredetail.pl?biblionumber=$biblionumber&itemnumber=$itemnumber&nowithdraw=$error_message#item$itemnumber");
    exit;
}
LostItem( $itemnumber, 'moredetail' ) if $op eq "cud-set_lost";

print $cgi->redirect(
    "moredetail.pl?" . $messages . "biblionumber=$biblionumber&itemnumber=$itemnumber#item$itemnumber" );
