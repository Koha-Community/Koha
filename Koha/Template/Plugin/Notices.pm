package Koha::Template::Plugin::Notices;

# Copyright ByWater Solutions 2023

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

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Koha;
use C4::Context;
use Koha::Notice::Templates;

sub GetTemplates {
    my ( $self, $module ) = @_;
    my $params = {};
    $params->{module} = $module if $module;

    my @letters = Koha::Notice::Templates->search($params)->as_list;

    return \@letters;
}

1;
