package t::lib::Page::Opac::OpacUser;

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

use base qw(t::lib::Page::Opac t::lib::Page::Opac::LeftNavigation);

use Koha::Exception::FeatureUnavailable;

=head NAME t::lib::Page::Opac::OpacUser

=head SYNOPSIS

PageObject providing page functionality as a service!

=cut

=head new

YOU CANNOT GET HERE WITHOUT LOGGING IN FIRST!
Navigate here from opac-main.pl for example.
=cut

sub new {
    Koha::Exception::FeatureUnavailable->throw(error => __PACKAGE__."->new():> You must login first to navigate to this page!");
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
