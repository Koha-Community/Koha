package t::lib::Page::Members::Toolbar;

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

=head NAME t::lib::Page::Members::Toolbar

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
Shares the same toolbar with moremember.pl
@RETURNS HASHRef of Selenium::Driver::Webelements matching all the clickable elements
                 in the actions toolbar over the Borrower information.
=cut

sub _getToolbarActionElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $editA = $d->find_element("#editpatron", 'css');
    my $changePasswordA = $d->find_element("#changepassword", 'css');
    my $duplicateA = $d->find_element("#duplicate", 'css');
    my $printButton = $d->find_element("#duplicate + div > button", 'css');
    my $searchToHoldA = $d->find_element("#searchtohold", 'css');
    my $moreButton = $d->find_element("#searchtohold + div > button", 'css');

    my $e = {};
    $e->{edit} = $editA if $editA;
    $e->{changePassword} = $changePasswordA if $changePasswordA;
    $e->{duplicate} = $duplicateA if $duplicateA;
    $e->{print} = $printButton if $printButton;
    $e->{searchToHold} = $searchToHoldA if $searchToHoldA;
    $e->{more} = $moreButton if $moreButton;
    return $e;
}

=head _getMoreDropdownElements
Clicks the dropdown open if it isnt yet.
@RETURNS HASHRef of all the dropdown elements under the More button in the toolbar
                 over Borrower information.
=cut

sub _getMoreDropdownElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $toolbarElements = $self->_getToolbarActionElements();
    my $moreButton = $toolbarElements->{more};
    my $deleteA;
    eval {
        $deleteA = $d->find_child_element($moreButton, "#deletepatron", 'css');
    };
    unless ($deleteA && $deleteA->is_visible()) {
        $moreButton->click();
        $self->debugTakeSessionSnapshot();
    }

    my $renewPatronA      = $d->find_element("#renewpatron", 'css');
    my $setPermissionsA   = $d->find_element("#patronflags", 'css');
    my $manageApiKeysA    = $d->find_element("#apikeys", 'css');
       $deleteA           = $d->find_element("#deletepatron", 'css');
    $self->debugTakeSessionSnapshot();
    my $updateChildToAdultPatronA = $d->find_element("#updatechild", 'css');
    my $exportCheckinBarcodesA = $d->find_element("#exportcheckins", 'css');

    my $e = {};
    $e->{renewPatron}     = $renewPatronA if $renewPatronA;
    $e->{setPermissions}  = $setPermissionsA if $setPermissionsA;
    $e->{manageApiKeys}   = $manageApiKeysA if $manageApiKeysA;
    $e->{delete}          = $deleteA if $deleteA;
    $e->{updateChildToAdultPatron} = $updateChildToAdultPatronA if $updateChildToAdultPatronA;
    $e->{exportCheckinBarcodes} = $exportCheckinBarcodesA if $exportCheckinBarcodesA;
    return $e;
}


################################################################################
=head PageObject Services

=cut
################################################################################

sub navigateManageApiKeys {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getMoreDropdownElements();
    $elements->{manageApiKeys}->click();
    ok($d->get_title() =~ m/API Keys/, "Intra Navigate to Manage API Keys");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::ApiKeys->rebrandFromPageObject($self);
}
sub navigateEditPatron {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getToolbarActionElements();

    my $func = sub {
        $elements->{edit}->click();
    };
    my $success = sub {
        return $self->getDriver()->get_title() =~ m/Modify(.*)patron/;
    };

    $self->poll($func, $success, 20, 50);

    ok($d->get_title() =~ m/Modify(.*)patron/, "Intra Navigate to Modify patron");
    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Memberentry->rebrandFromPageObject($self);
}


1; #Make the compiler happy!