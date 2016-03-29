package t::lib::Page::Opac::OpacPaycollect;

# Copyright 2016 KohaSuomi
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
# You should have received a copy of the GNU General Public Lice strongnse
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Scalar::Util qw(blessed);
use Test::More;

use t::lib::Page::Opac::OpacPaycollect;

use base qw(t::lib::Page::Opac t::lib::Page::Opac::LeftNavigation);

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Opac::OpacPaycollect

=head SYNOPSIS

PageObject providing page functionality as a service!

=cut

=head new

    my $opacpaycollect = t::lib::Page::Opac::OpacPaycollect->new();

Instantiates a WebDriver and loads the opac/opac-paycollect.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    none atm.

@RETURNS t::lib::Page::Opac::OpacPaycollect, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/opac-paycollect.pl';
    $params->{type}     = 'opac';

    my $self = $class->SUPER::new($params);

    return $self;
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

sub isPreparing {
    my ($self, $status) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $h3 = $d->find_element("//h3[contains(.,\"Preparing to pay fines\")]",'xpath');
    is($h3->get_text(), "Preparing to pay fines", "Opac preparing to redirect user to online shop (but skipping online shop in these tests)");
    my $continueLink = $d->find_element("//p[contains(.,\"automatically redirected to\")]/a[text()=\"online payment\"]", "xpath");

    $continueLink->click();
    ok(1, "Opac Clicked to continue with the payment");

    return $self;
}

sub isPaymentPaid {
    my ($self, $status) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $h3 = $d->find_element("//h3[contains(.,\"You have no outstanding\")]",'xpath');
    ok(1, "Opac Skipped online store. No outstanding fines");

    return $self;
}
1;
