package t::lib::Page::Members::Pay;

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

use base qw(t::lib::Page::Intra t::lib::Page::Members::Toolbar t::lib::Page::Members::LeftNavigation);

use t::lib::Page::Members::ApiKeys;

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Members::Pay

=head SYNOPSIS

pay.pl PageObject providing page functionality as a service!

=cut

=head new

    my $pay = t::lib::Page::Members::Pay->new({borrowernumber => "1"});

Instantiates a WebDriver and loads the members/pay.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    borrowernumber => loads the page to display Borrower matching the given borrowernumber

@RETURNS t::lib::Page::Members::Pay, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/members/pay.pl';
    $params->{type}     = 'staff';

    $params->{getParams} = [];
    #Handle MANDATORY parameters
    if ($params->{borrowernumber}) {
        push @{$params->{getParams}}, "borrowernumber=".$params->{borrowernumber};
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

sub PayAmount{
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $tab = $d->find_element("input[id='paycollect'][type='submit']", 'css');
    $tab->click();
    ok($d->get_title() =~ m/Collect fine payment for/, "Intra Navigate to Paycollect (all fines)");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Paycollect->rebrandFromPageObject($self);
}

sub PaySelected {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $tab = $d->find_element("input[id='payselected'][type='submit']", 'css');
    $tab->click();
    ok($d->get_title() =~ m/Collect fine payment for/, "Intra Navigate to Paycollect (selected fines)");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Paycollect->rebrandFromPageObject($self);
}

1; #Make the compiler happy!
