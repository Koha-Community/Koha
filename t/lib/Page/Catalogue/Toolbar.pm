package t::lib::Page::Catalogue::Toolbar;

# Copyright 2015 KohaSuomi!
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
use Test::More;

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Catalogue::Toolbar

=head SYNOPSIS

PageObject Accessory representing a shared Template between PageObjects.
This encapsulates specific page-related functionality.

In this case this encapsulates the members-module toolbar's services and provides
a reusable class from all member-module PageObjects.

=cut

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

=head _getToolbarActionElements
@RETURNS HASHRef of Selenium::Driver::Webelements matching all the clickable elements
                 in the actions toolbar over the Biblio information.
=cut

sub _getToolbarActionElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $e = {};
    eval {
        $e->{new}       = $d->find_element("#newDropdownContainer button", 'css');
    };
    eval {
        $e->{edit}      = $d->find_element("#editDropdownContainer button", 'css');
    };
    eval {
        $e->{save}      = $d->find_element("#saveDropdownContainer button", 'css');
    };
    eval {
        $e->{addTo}     = $d->find_element("#addtoDropdownContainer button", 'css');
    };
    eval {
        $e->{print}     = $d->find_element("#printbiblio", 'css');
    };
    eval {
        $e->{placeHold} = $d->find_element("#placeholdDropdownContainer button", 'css');
    };
    return $e;
}

=head _getEditDropdownElements
Clicks the dropdown open if it isnt yet.
@RETURNS HASHRef of all the dropdown elements under the Edit button in the toolbar
                 over Biblio information.
=cut

sub _getEditDropdownElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $toolbarElements = $self->_getToolbarActionElements();
    my $editButton = $toolbarElements->{edit};
    my $dropdownElement;
    eval {
        $dropdownElement = $d->find_child_element($editButton, "#editDropdownContainer ul a:nth-of-type(1)", 'css');
    };
    unless ($dropdownElement && $dropdownElement->is_visible()) {
        $editButton->click();
        $self->debugTakeSessionSnapshot();
    }

    my $e = {};
    eval {
        $e->{editRecord}         = $d->find_element("a[id|='editbiblio']", 'css');
    };
    eval {
        $e->{editItems}          = $d->find_element("a[id|='edititems']", 'css');
    };
    eval {
        $e->{editItemsInBatch}   = $d->find_element("a[id|='batchedit']", 'css');
    };
    eval {
        $e->{deleteItemsInBatch} = $d->find_element("a[id|='batchdelete']", 'css');
    };
    eval {
        $e->{attachItem}         = $d->find_element("a[href*='cataloguing/moveitem.pl']", 'css');
    };
    eval {
        $e->{editAsNew}          = $d->find_element("a[id|='duplicatebiblio']", 'css');
    };
    eval {
        $e->{replaceRecord}      = $d->find_element("a[id|='z3950copy']", 'css');
    };
    eval {
        $e->{deleteRecord}       = $d->find_element("a[id|='deletebiblio']", 'css');
    };
    eval {
        $e->{deleteAllItems}     = $d->find_element("a[id|='deleteallitems']", 'css');
    };
    return $e;
}


################################################################################
=head PageObject Services

=cut
################################################################################




1; #Make the compiler happy!