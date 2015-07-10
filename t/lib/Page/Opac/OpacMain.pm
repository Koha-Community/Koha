package t::lib::Page::Opac::OpacMain;

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

use t::lib::Page::Opac::OpacUser;

use base qw(t::lib::Page::Opac);

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Opac::OpacMain

=head SYNOPSIS

PageObject providing page functionality as a service!

=cut

=head new

    my $opacmain = t::lib::Page::Opac::OpacMain->new();

Instantiates a WebDriver and loads the opac/opac-main.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    none atm.

@RETURNS t::lib::Page::Opac::OpacMain, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/opac-main.pl';
    $params->{type}     = 'opac';

    my $self = $class->SUPER::new($params);

    return $self;
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

sub _getPasswordLoginElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $submitButton  = $d->find_element('form#auth input[type="submit"]');
    my $useridInput   = $d->find_element('#userid');
    my $passwordInput = $d->find_element('#password');
    return ($submitButton, $useridInput, $passwordInput);
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
    ok(1, "OpacMain PasswordLogin available");
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
    ok(($cgisessid[0]), "OpacMain PasswordLogin succeeded"); #We have the element && Cookie CGISESSID defined!

    return t::lib::Page::Opac::OpacUser->rebrandFromPageObject($self);
}

1; #Make the compiler happy!