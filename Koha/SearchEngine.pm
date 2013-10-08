package Koha::SearchEngine;

# This file is part of Koha.
#
# Copyright 2012 BibLibre
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

use Moose;
use C4::Context;
use Koha::SearchEngine::Config;

has 'name' => (
    is => 'ro',
    default => sub {
        C4::Context->preference('SearchEngine');
    }
);

has config => (
    is => 'rw',
    lazy => 1,
    default => sub {
        Koha::SearchEngine::Config->new;
    }
#    lazy => 1,
#    builder => '_build_config',
);

#sub _build_config {
#    my ( $self ) = @_;
#    Koha::SearchEngine::Config->new( $self->name );
#);

1;
