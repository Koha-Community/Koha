package t::lib::Page::Mainpage;

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

use base qw(t::lib::Page::Intra);

=head NAME t::lib::Page::Mainpage

=head SYNOPSIS

Mainpage PageObject providing page functionality as a service!

=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH') {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/mainpage.pl';
    $params->{type}     = 'staff';
    my $self = $class->SUPER::new($params);

    return $self;
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