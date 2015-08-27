package t::lib::Page::Members::LeftNavigation;

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

=head NAME t::lib::Page::Members::LeftNavigation

=head SYNOPSIS

Provides the services of the members/circulation left navigation column/frame for the implementing PageObject

=cut

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

=head _getLeftNavigationActionElements
@RETURNS HASHRef of Selenium::Driver::Webelements matching all the clickable elements
                 in the left navigation frame/column at members and circulation pages.
=cut

sub _getLeftNavigationActionElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $e = {};
    eval {
        $e->{checkOut} = $d->find_element("div#menu a[href*='circ/circulation.pl']", 'css');
    };
    eval {
        $e->{details}   = $d->find_element("div#menu a[href*='members/moremember.pl']", 'css');
    };
    eval {
        $e->{fines} = $d->find_element("div#menu a[href*='members/pay.pl']", 'css');
    };
    eval {
        $e->{routingLists}    = $d->find_element("div#menu a[href*='members/routing-lists.pl']", 'css');
    };
    eval {
        $e->{circulationHistory} = $d->find_element("div#menu a[href*='members/readingrec.pl']", 'css');
    };
    eval {
        $e->{modificationLog} = $d->find_element("div#menu a[href*='tools/viewlog.pl']", 'css');
    };
    eval {
        $e->{notices} = $d->find_element("div#menu a[href*='members/notices.pl']", 'css');
    };
    eval {
        $e->{statistics} = $d->find_element("div#menu a[href*='members/statistics.pl']", 'css');
    };
    eval {
        $e->{purchaseSuggestions} = $d->find_element("div#menu a[href*='members/purchase-suggestions.pl']", 'css');
    };
    return $e;
}



################################################################################
=head PageObject Services

=cut
################################################################################

sub navigateCheckout {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getLeftNavigationActionElements();
    $elements->{checkOut}->click();
    $self->debugTakeSessionSnapshot();

    ok($d->get_title() =~ m/Checking out to/i,
       "Intra Navigate to Check out");

    return t::lib::Page::Circulation::Circulation->rebrandFromPageObject($self);
}

sub navigateToDetails {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getLeftNavigationActionElements();
    $elements->{details}->click();
    $self->debugTakeSessionSnapshot();

    ok($d->get_title() =~ m/Patron details for/i,
       "Intra Navigate to Details");

    return t::lib::Page::Members::Moremember->rebrandFromPageObject($self);
}

sub navigateToNotices {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getLeftNavigationActionElements();
    my $func = sub {
        $elements->{notices}->click();
    };
    my $success = sub {
        return $self->getDriver()->get_title() =~ m/Sent notices/;
    };

    $self->poll($func, $success, 20, 50);
    $self->debugTakeSessionSnapshot();

    ok($d->get_title() =~ m/Sent notices/i,
       "Intra Navigate to Notices");

    return t::lib::Page::Members::Notices->rebrandFromPageObject($self);
}

1; #Make the compiler happy!
