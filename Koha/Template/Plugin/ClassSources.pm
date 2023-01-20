package Koha::Template::Plugin::ClassSources;

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

use base qw( Template::Plugin );

use C4::Context;
use Koha::ClassSources;

sub all {
    my ($self, $params) = @_;

    my $selected = $params->{selected};

    my $default_source = C4::Context->preference("DefaultClassificationSource");

    my @class_sources = grep {
             $_->used
          or ( $selected       and $_->cn_source eq $selected )
          or ( $default_source and $_->cn_source eq $default_source )
    } Koha::ClassSources->search->as_list;

    return @class_sources;
}

1;
