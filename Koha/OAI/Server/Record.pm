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

package Koha::OAI::Server::Record;

use Modern::Perl;
use HTTP::OAI;
use HTTP::OAI::Metadata::OAI_DC;
use XML::LibXML;

use base ("HTTP::OAI::Record");

sub new {
    my ( $class, $repository, $marcxml, $timestamp, $setSpecs, %args ) = @_;

    my $self = $class->SUPER::new(%args);

    $timestamp =~ s/ /T/, $timestamp .= 'Z';
    $self->header(
        HTTP::OAI::Header->new(
            identifier => $args{identifier},
            datestamp  => $timestamp,
        )
    );

    foreach my $setSpec (@$setSpecs) {
        $self->header->setSpec($setSpec);
    }

    my $format = $args{metadataPrefix};
    my $record_dom;
    my $xsl_file =
        $repository->{conf}
        ? defined $repository->{conf}->{format}->{$format}->{xsl_file}
        : undef;
    if ( ( $format ne 'marc21' && $format ne 'marcxml' )
        || $xsl_file )
    {
        my $args = { OPACBaseURL => "'" . C4::Context->preference('OPACBaseURL') . "'" };

        # call Koha::XSLT::Base now
        $record_dom = $repository->{xslt_engine}->transform(
            {
                xml        => $marcxml,
                file       => $repository->stylesheet($format),
                parameters => $args,
                format     => 'xmldoc',
            }
        );
    } else {
        $record_dom = XML::LibXML->new->parse_string($marcxml);
    }
    $self->metadata( HTTP::OAI::Metadata->new( dom => $record_dom ) );

    return $self;
}

1;
