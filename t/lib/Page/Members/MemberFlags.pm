package t::lib::Page::Members::MemberFlags;

# Copyright 2015 Open Source Freedom Fighters
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

use t::lib::Page::Members::Moremember;

use base qw(t::lib::Page::Intra t::lib::Page::Members::Toolbar);

=head NAME t::lib::Page::Members::MemberFlags

=head SYNOPSIS

member-flags.pl PageObject providing page functionality as a service!

=cut

=head new

    my $memberflags = t::lib::Page::Members::MemberFlags->new({borrowernumber => "1"});

Instantiates a WebDriver and loads the members/member-flags.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    borrowernumber => loads the page to display Borrower matching the given borrowernumber

@RETURNS t::lib::Page::Members::MemberFlags, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH') {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/members/member-flags.pl';
    $params->{type}     = 'staff';

    $params->{getParams} = [];
    #Handle MANDATORY parameters
    if ($params->{borrowernumber}) {
        push @{$params->{getParams}}, "member=".$params->{borrowernumber};
    }
    else {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->new():> Parameter 'borrowernumber' is missing.");
    }

    my $self = $class->SUPER::new($params);

    return $self;
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

sub _getPermissionTreeControlElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $saveButton   = $d->find_element('input[value="Save"]');
    my $cancelButton = $d->find_element('a.cancel');
    return ($saveButton, $cancelButton);
}

=head _getPermissionTreePermissionElements

@PARAM1 Scalar, Koha::Auth::PermissionModule's module
@PARAM2 Scalar, Koha::Auth::Permission's code
=cut

sub _getPermissionTreePermissionElements {
    my ($self, $module, $code) = @_;
    my $d = $self->getDriver();

    my $moduleTreeExpansionButton = $d->find_element("div.$module-hitarea");
    my $moduleCheckbox   = $d->find_element("input#flag-$module");
    my $permissionCheckbox = $d->find_element('input#'.$module.'_'.$code);
    return ($moduleTreeExpansionButton, $moduleCheckbox, $permissionCheckbox);
}



################################################################################
=head PageObject Services

=cut
################################################################################

sub togglePermission {
    my ($self, $permissionModule, $permissionCode) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($moduleTreeExpansionButton, $moduleCheckbox, $permissionCheckbox) = $self->_getPermissionTreePermissionElements($permissionModule, $permissionCode);
    if ($moduleTreeExpansionButton->get_attribute("class") =~ /expandable-hitarea/) { #Permission checkboxes are hidden and need to be shown.
        $moduleTreeExpansionButton->click();
        $d->pause( $self->{userInteractionDelay} );
    }


    #$moduleCheckbox->click(); #Clicking this will toggle all module permissions.
    my $checked = $permissionCheckbox->get_attribute("checked") || ''; #Returns undef if not checked
    $permissionCheckbox->click();
    ok($checked ne ($permissionCheckbox->get_attribute("checked") || ''),
       "Module '$permissionModule', permission '$permissionCode', checkbox toggled");
    $self->debugTakeSessionSnapshot();

    return $self;
}

sub submitPermissionTree {
    my $self = shift;
    my $d = $self->getDriver();

    my ($submitButton, $cancelButton) = $self->_getPermissionTreeControlElements();
    $submitButton->click();
    $self->debugTakeSessionSnapshot();

    ok(($d->get_title() =~ /Patron details for/), "Permissions set");

    return t::lib::Page::Members::Moremember->rebrandFromPageObject($self);
}

1; #Make the compiler happy!
