# Copyright Tamil s.a.r.l. 2008-2015
# Copyright Biblibre 2008-2015
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

package Koha::OAI::Server::Description;

use Modern::Perl;
use HTTP::OAI;
use HTTP::OAI::SAXHandler qw/ :SAX /;


sub new {
    my ( $class, %args ) = @_;

    my $self = {};

    if(my $setDescription = $args{setDescription}) {
        $self->{setDescription} = $setDescription;
    }
    if(my $handler = $args{handler}) {
        $self->{handler} = $handler;
    }

    bless $self, $class;
    return $self;
}


sub set_handler {
    my ( $self, $handler ) = @_;

    $self->{handler} = $handler if $handler;

    return $self;
}


sub generate {
    my ( $self ) = @_;

    g_data_element($self->{handler}, 'http://www.openarchives.org/OAI/2.0/', 'setDescription', {}, $self->{setDescription});

    return $self;
}

1;
