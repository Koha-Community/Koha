package t::lib::Page::Opac;

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

use C4::Context;

use t::lib::WebDriverFactory;

use Koha::Exception::BadParameter;
use Koha::Exception::SystemCall;

use base qw(t::lib::Page);

=head NAME t::lib::Page::Opac

=head SYNOPSIS

PageObject-pattern parent class for OPAC-pages. Extend this to implement specific pages shown to our users.

=cut

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

=head _getHeaderRegionActionElements

Returns each element providing some kind of an action from the topmost header bar in OPAC.
All elements are not always present on each page, so test if the return set contains your
desired element.
@PARAM1 Selenium::Remote::Driver
@RETURNS HASHRef of the found elements:
    { cart             => $cartA,
      lists            => $listsA,
      loggedinusername => $loggedinusernameA,
      searchHistory    => $searchHistoryA,
      deleteSearchHistory => $deleteSearchHistoryA,
      logout           => $logoutA,
      login            => $loginA,
    }
=cut

sub _getHeaderRegionActionElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my ($cartA, $listsA, $loggedinusernameA, $searchHistoryA, $deleteSearchHistoryA, $logoutA, $loginA);
    #Always visible elements
    $cartA = $d->find_element("#header-region a#cartmenulink");
    $listsA = $d->find_element("#header-region a#listsmenu");
    #Occasionally visible elements
    eval {
        $loggedinusernameA = $d->find_element("#header-region a[href*='opac-user.pl']");
    };
    eval {
        $searchHistoryA = $d->find_element("#header-region a[href*='opac-search-history.pl']");
    };
    eval {
        $deleteSearchHistoryA = $d->find_element("#header-region a[href*='opac-search-history.pl'] + a");
    };
    eval {
        $logoutA = $d->find_element("#header-region #logout");
    };
    eval {
        $loginA = $d->find_element("#header-region #members a.loginModal-trigger");
    };

    my $e = {};
    $e->{cart} = $cartA if $cartA;
    $e->{lists} = $listsA if $listsA;
    $e->{loggedinusername} = $loggedinusernameA if $loggedinusernameA;
    $e->{searchHistory} = $searchHistoryA if $searchHistoryA;
    $e->{deleteSearchHistory} = $deleteSearchHistoryA if $deleteSearchHistoryA;
    $e->{logout} = $logoutA if $logoutA;
    $e->{login} = $loginA if $loginA;
    return ($e);
}

sub _getMoresearchesElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $advancedSearchA = $d->find_element("#moresearches a[href*='opac-search.pl']");
    my $authoritySearchA = $d->find_element("#moresearches a[href*='opac-authorities-home.pl']");
    my $tagCloudA = $d->find_element("#moresearches a[href*='opac-tags.pl']");
    return ($advancedSearchA, $authoritySearchA, $tagCloudA);
}

sub _getBreadcrumbLinks {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $breadcrumbLinks = $d->find_elements("ul.breadcrumb a");
    return ($breadcrumbLinks);
}



################################################################################
=head PageObject Services

=cut
################################################################################

=head isPasswordLoginAvailable

    $page->isPasswordLoginAvailable();

@RETURN t::lib::Page-object
@CROAK if password login is unavailable.
=cut

sub isPasswordLoginAvailable {
    my $self = shift;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    $self->_getPasswordLoginElements();
    ok(1, "PasswordLogin available");
    return $self;
}

sub doPasswordLogin {
    my ($self, $username, $password) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($submitButton, $useridInput, $passwordInput) = $self->_getPasswordLoginElements();
    $useridInput->send_keys($username);
    $passwordInput->send_keys($password);
    $submitButton->click();
    $self->debugTakeSessionSnapshot();

    my $cookies = $d->get_all_cookies();
    my @cgisessid = grep {$_->{name} eq 'CGISESSID'} @$cookies;

    my $loggedinusernameSpan = $d->find_element('span.loggedinusername');
    ok(($cgisessid[0]), "PasswordLogin succeeded"); #We have the element && Cookie CGISESSID defined!

    return $self; #After a succesfull password login, we are directed to the same page we tried to access.
}

sub doPasswordLogout {
    my ($self, $username, $password) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    #Logout
    my $headerElements = $self->_getHeaderRegionActionElements();
    my $logoutA = $headerElements->{logout};
    $logoutA->click();
    $self->debugTakeSessionSnapshot();

    $headerElements = $self->_getHeaderRegionActionElements(); #Take the changed header elements
    my $txt = $headerElements->{login}->get_text();
    ok(($headerElements->{login}->get_text() =~ /Log in/ ||
        $d->get_title() =~ /Log in to your account/), "Opac Header PasswordLogout succeeded");
    return t::lib::Page::Opac::OpacMain->rebrandFromPageObject($self);
        ok((), "PasswordLogout succeeded");
    return t::lib::Page::Opac::OpacMain->rebrandFromPageObject($self);
}

sub navigateSearchHistory {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $headerElements = $self->_getHeaderRegionActionElements();
    my $searchHistoryA = $headerElements->{searchHistory};
    $searchHistoryA->click();
    $self->debugTakeSessionSnapshot();

    ok(($d->get_title() =~ /Your search history/), "Opac Navigation to search history.");
    return t::lib::Page::Opac::OpacSearchHistory->rebrandFromPageObject($self);
}

sub navigateAdvancedSearch {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($advancedSearchA, $authoritySearchA, $tagCloudA) = $self->_getMoresearchesElements();
    $advancedSearchA->click();

    $self->debugTakeSessionSnapshot();
    ok(($d->get_title() =~ /Advanced search/), "Opac Navigating to advanced search.");
    return t::lib::Page::Opac::OpacSearch->rebrandFromPageObject($self);
}

sub navigateHome {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $breadcrumbLinks = $self->_getBreadcrumbLinks();
    $breadcrumbLinks->[0]->click();

    $self->debugTakeSessionSnapshot();
    ok(($d->get_current_url() =~ /opac-main\.pl/), "Opac Navigating to OPAC home.");
    return t::lib::Page::Opac::OpacMain->rebrandFromPageObject($self);
}

1; #Make the compiler happy!