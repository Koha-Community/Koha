package t::lib::Page::Intra;

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

=head NAME t::lib::Page::Intra

=head SYNOPSIS

PageObject-pattern parent class for Intranet-pages (staff client). Extend this to implement specific pages shown to our users.

=cut

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

=head _getBreadcrumbLinks

@RETURNS List of all breadcrumb links
=cut

sub _getBreadcrumbLinks {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $breadcrumbLinks = $d->find_elements("div#breadcrumbs a");
    return ($breadcrumbLinks);
}

=head _getHeaderElements

@RETURNS HASHRef of all the Intranet header clickables.
=cut

sub _getHeaderElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my ($patronsA, $searchA, $cartA, $moreA, $drop3A, $helpA);
    #Always visible elements
    $patronsA = $d->find_element("#header a[href*='members-home.pl']");
    $searchA = $d->find_element ("#header a[href*='search.pl']");
    $cartA = $d->find_element   ("#header a#cartmenulink");
    $moreA = $d->find_element   ("#header a[href='#']");
    $drop3A = $d->find_element  ("#header a#drop3");
    $helpA = $d->find_element   ("#header a#helper");

    my $e = {};
    $e->{patrons} = $patronsA if $patronsA;
    $e->{search} = $searchA if $searchA;
    $e->{cart} = $cartA if $cartA;
    $e->{more} = $moreA if $moreA;
    $e->{drop3} = $drop3A if $drop3A;
    $e->{help} = $helpA if $helpA;
    return $e;
}

=head _getPasswordLoginElements

@RETURNS List of Selenium::Remote::Webelement-objects,
         ($submitButton, $useridInput, $passwordInput)
=cut

sub _getPasswordLoginElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $submitButton  = $d->find_element('#submit');
    my $useridInput   = $d->find_element('#userid');
    my $passwordInput = $d->find_element('#password');
    return ($submitButton, $useridInput, $passwordInput);
}

=head _getLoggedInBranchNameElement
@RETURNS Selenium::Remote::WebElement matching the <span> containing the currently logged in users branchname
=cut

sub _getLoggedInBranchNameElement {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $header = $self->_getHeaderElements();
    my $loggedInBranchNameSpan = $d->find_child_element($header->{drop3}, "#logged-in-branch-name", 'css');
    return $loggedInBranchNameSpan;
}

=head _getLoggedInBranchCode
@RETURNS String, the logged in branch code
=cut

sub _getLoggedInBranchCode {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    #Because the branchcode element is hidden, we need to inject some javascript to get its value since Selenium (t$
    my $script = q{
        var elem = document.getElementById('logged-in-branch-code').innerHTML;
        var callback = arguments[arguments.length-1];
        callback(elem);
    };
    my $loggedInBranchCode = $d->execute_async_script($script);
    return $loggedInBranchCode;
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
    ok(($d->get_title() =~ /Log in to Koha/), "Intra PasswordLogin available");
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

    ok(($d->get_title() !~ /Log in to Koha/ && #No longer in the login page
        $d->get_title() !~ /Access denied/ &&
        $cgisessid[0]) #Cookie CGISESSID defined!
       , "Intra PasswordLogin succeeded");

    return $self; #After a succesfull password login, we are directed to the same page we tried to access.
}

sub failPasswordLogin {
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

    ok($d->get_title() =~ /Log in to Koha/ #Still in the login page
       , "Intra PasswordLogin failed");

    return $self; #After a successful password login, we are directed to the same page we tried to access.
}

sub doPasswordLogout {
    my ($self, $username, $password) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    #Click the dropdown menu to make the logout-link visible
    my $logged_in_identifierA = $d->find_element('#drop3'); #What a nice and descriptive HTML element name!
    $logged_in_identifierA->click();

    #Logout
    my $logoutA = $d->find_element('#logout');
    $logoutA->click();
    $self->debugTakeSessionSnapshot();

    ok(($d->get_title() =~ /Log in to Koha/), "Intra PasswordLogout succeeded");
    return $self; #After a succesfull password logout, we are still in the same page we did before logout.
}

sub isLoggedInBranchCode {
    my ($self, $expectedBranchCode) = @_;

    my $loggedInBranchCode = $self->_getLoggedInBranchCode();
    is($expectedBranchCode, $loggedInBranchCode, "#logged-in-branch-code '".$loggedInBranchCode."' matches '$expectedBranchCode'");
    return $self;
}

1; #Make the compiler happy!
