package t::lib::Page::Catalogue::Search;

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
use Time::HiRes;
use Test::More;

use base qw(t::lib::Page::Intra t::lib::Page::Catalogue::Toolbar);

use Koha::Exception::UnknownObject;

=head NAME t::lib::Page::Catalogue::Search

=head SYNOPSIS

search.pl PageObject providing page functionality as a service!

=cut

=head new

    my $search = t::lib::Page::Catalogue::Search->new()->doPasswordLogin('admin', '2134');

Instantiates a WebDriver and loads the catalogue/search.pl to show the given Biblio
@PARAM1 HASHRef of optional and MANDATORY parameters

@RETURNS t::lib::Page::Catalogue::Search, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/catalogue/search.pl';
    $params->{type}     = 'staff';

    $params->{getParams} = [];

    my $self = $class->SUPER::new($params);

    return $self;
}

=head rebrandFromPageObject
@EXTENDS t::lib::Page->rebrandFromPageObject()

Checks that the rebranding succeeds by making sure that the page we are rebranding to
is the page we have.
=cut

sub rebrandFromPageObject {
    my ($class, $self) = @_;
    my $d = $self->getDriver();

    my $waitCycles = 0;
    while ($waitCycles <= 10 &&
           $d->get_current_url() !~ m!catalogue/search.pl! ) {
        Time::HiRes::usleep(250000);
        $waitCycles++;
    }

    if ($waitCycles > 10) {
        my ($package, $filename, $line, $subroutine) = caller(1);
        Koha::Exception::UnknownObject->throw(error => __PACKAGE__."->rebrandFromPageObject():> Timeout looking for proper Page markers. This is not a 'catalogue/search.pl'-page!\n    Called from $package->$subroutine");
    }
    return $class->SUPER::rebrandFromPageObject($self);
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################





################################################################################
=head PageObject Services

=cut
################################################################################





1; #Make the compiler happy!
