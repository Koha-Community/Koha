package t::lib::Page::Opac::LeftNavigation;

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
use Scalar::Util qw(blessed);
use Test::More;

use t::lib::Page::Opac::OpacApiKeys;
use t::lib::Page::Opac::OpacMessaging;

=head NAME t::lib::Page::Opac::LeftNavigation

=head SYNOPSIS

Provides the services of the Opac left navigation column/frame for the implementing PageObject

=cut

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

=head _getLeftNavigationActionElements
@RETURNS HASHRef of Selenium::Driver::Webelements matching all the clickable elements
                 in the left navigation frame/column at all Opac pages requiring login.
=cut

sub _getLeftNavigationActionElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $e = {};
    eval {
        $e->{yourSummary} = $d->find_element("a[href*='opac-user.pl']", 'css');
    };
    eval {
        $e->{yourFines}   = $d->find_element("a[href*='opac-account.pl']", 'css');
    };
    eval {
        $e->{yourPersonalDetails} = $d->find_element("a[href*='opac-memberentry.pl']", 'css');
    };
    eval {
        $e->{yourTags}    = $d->find_element("a[href*='opac-tags.pl']", 'css');
    };
    eval {
        $e->{changeYourPassword} = $d->find_element("a[href*='opac-passwd.pl']", 'css');
    };
    eval {
        $e->{yourSearchHistory} = $d->find_element("a[href*='opac-search-history.pl']", 'css');
    };
    eval {
        $e->{yourReadingHistory} = $d->find_element("a[href*='opac-readingrecord.pl']", 'css');
    };
    eval {
        $e->{yourPurchaseSuggestions} = $d->find_element("a[href*='opac-suggestions.pl']", 'css');
    };
    eval {
        $e->{yourMessaging} = $d->find_element("a[href*='opac-messaging.pl']", 'css');
    };
    eval {
        $e->{yourLists} = $d->find_element("a[href*='opac-shelves.pl']", 'css');
    };
    eval {
        $e->{yourAPIKeys} = $d->find_element("a[href*='opac-apikeys.pl']", 'css');
    };
    return $e;
}



################################################################################
=head PageObject Services

=cut
################################################################################

sub navigateYourAPIKeys {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getLeftNavigationActionElements();
    $elements->{yourAPIKeys}->click();
    $self->debugTakeSessionSnapshot();

    my $breadcrumbs = $self->_getBreadcrumbLinks();

    ok(ref($breadcrumbs) eq 'ARRAY' &&
       $breadcrumbs->[scalar(@$breadcrumbs)-1]->get_text() =~ m/API keys/i,
       "Opac Navigate to Your API Keys");

    return t::lib::Page::Opac::OpacApiKeys->rebrandFromPageObject($self);
}

sub navigateYourMessaging {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getLeftNavigationActionElements();
    $elements->{yourMessaging}->click();
    $self->debugTakeSessionSnapshot();

    my $breadcrumbs = $self->_getBreadcrumbLinks();

    ok(ref($breadcrumbs) eq 'ARRAY' &&
       $breadcrumbs->[scalar(@$breadcrumbs)-1]->get_text() =~ m/Your messaging/i,
       "Opac Navigate to Your messaging");

    return t::lib::Page::Opac::OpacMessaging->rebrandFromPageObject($self);
}

sub navigateYourPersonalDetails {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getLeftNavigationActionElements();
    $elements->{yourPersonalDetails}->click();
    $self->debugTakeSessionSnapshot();

    my $breadcrumbs = $self->_getBreadcrumbLinks();

    ok(ref($breadcrumbs) eq 'ARRAY' &&
       $breadcrumbs->[scalar(@$breadcrumbs)-1]->get_text() =~ m/Your personal details/i,
       "Opac Navigate to Your personal details");

    return t::lib::Page::Opac::OpacMemberentry->rebrandFromPageObject($self);
}

1; #Make the compiler happy!
