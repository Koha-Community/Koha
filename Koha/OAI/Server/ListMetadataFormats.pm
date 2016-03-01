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

package Koha::OAI::Server::ListMetadataFormats;

use Modern::Perl;
use HTTP::OAI;

use base ("HTTP::OAI::ListMetadataFormats");


sub new {
    my ($class, $repository) = @_;

    my $self = $class->SUPER::new();

    if ( $repository->{ conf } ) {
        foreach my $name ( @{ $repository->{ koha_metadata_format } } ) {
            my $format = $repository->{ conf }->{ format }->{ $name };
            $self->metadataFormat( HTTP::OAI::MetadataFormat->new(
                metadataPrefix    => $format->{metadataPrefix},
                schema            => $format->{schema},
                metadataNamespace => $format->{metadataNamespace}, ) );
        }
    }
    else {
        $self->metadataFormat( HTTP::OAI::MetadataFormat->new(
            metadataPrefix    => 'oai_dc',
            schema            => 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
            metadataNamespace => 'http://www.openarchives.org/OAI/2.0/oai_dc/'
        ) );
        $self->metadataFormat( HTTP::OAI::MetadataFormat->new(
            metadataPrefix    => 'marcxml',
            schema            => 'http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd',
            metadataNamespace => 'http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim'
        ) );
    }

    return $self;
}

1;
