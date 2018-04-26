# Copyright Tamil s.a.r.l. 2008-2015
# Copyright Biblibre 2008-2015
# Copyright The National Library of Finland, University of Helsinki 2016
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

package Koha::OAI::Server::Repository;

use Modern::Perl;
use HTTP::OAI;
use HTTP::OAI::Repository qw/:validate/;

use base ("HTTP::OAI::Repository");

use Koha::OAI::Server::Identify;
use Koha::OAI::Server::ListSets;
use Koha::OAI::Server::ListMetadataFormats;
use Koha::OAI::Server::GetRecord;
use Koha::OAI::Server::ListRecords;
use Koha::OAI::Server::ListIdentifiers;
use XML::SAX::Writer;
use YAML::Syck qw( LoadFile );
use CGI qw/:standard -oldstyle_urls/;
use C4::Context;
use C4::Biblio;
use Koha::XSLT_Handler;

=head1 NAME

Koha::OAI::Server::Repository - Handles OAI-PMH requests for a Koha database.

=head1 SYNOPSIS

  use Koha::OAI::Server::Repository;

  my $repository = Koha::OAI::Server::Repository->new();

=head1 DESCRIPTION

This object extend HTTP::OAI::Repository object.
It accepts OAI-PMH HTTP requests and returns result.

This OAI-PMH server can operate in a simple mode and extended one.

In simple mode, repository configuration comes entirely from Koha system
preferences (OAI-PMH:archiveID and OAI-PMH:MaxCount) and the server returns
records in marcxml or dublin core format. Dublin core records are created from
koha marcxml records transformed with XSLT. Used XSL file is located in koha-
tmpl/intranet-tmpl/prog/en/xslt directory and chosen based on marcflavour,
respecively MARC21slim2OAIDC.xsl for MARC21 and  MARC21slim2OAIDC.xsl for
UNIMARC.

In extended mode, it's possible to parameter other format than marcxml or
Dublin Core. A new syspref OAI-PMH:ConfFile specify a YAML configuration file
which list available metadata formats and XSL file used to create them from
marcxml records. If this syspref isn't set, Koha OAI server works in simple
mode. A configuration file koha-oai.conf can look like that:

  ---
  format:
    vs:
      metadataPrefix: vs
      metadataNamespace: http://veryspecial.tamil.fr/vs/format-pivot/1.1/vs
      schema: http://veryspecial.tamil.fr/vs/format-pivot/1.1/vs.xsd
      xsl_file: /usr/local/koha/xslt/vs.xsl
    marc21:
      metadataPrefix: marc21
      metadataNamespace: http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim
      schema: http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd
      include_items: 1
    marcxml:
      metadataPrefix: marxml
      metadataNamespace: http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim
      schema: http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd
      include_items: 1
    oai_dc:
      metadataPrefix: oai_dc
      metadataNamespace: http://www.openarchives.org/OAI/2.0/oai_dc/
      schema: http://www.openarchives.org/OAI/2.0/oai_dc.xsd
      xsl_file: /usr/local/koha/koha-tmpl/intranet-tmpl/xslt/UNIMARCslim2OAIDC.xsl

Note the 'include_items' parameter which is the only mean to return item-level info.

=cut


sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);

    $self->{ koha_identifier      } = C4::Context->preference("OAI-PMH:archiveID");
    $self->{ koha_max_count       } = C4::Context->preference("OAI-PMH:MaxCount");
    $self->{ koha_metadata_format } = ['oai_dc', 'marc21', 'marcxml'];
    $self->{ xslt_engine          } = Koha::XSLT_Handler->new;

    # Load configuration file if defined in OAI-PMH:ConfFile syspref
    if ( my $file = C4::Context->preference("OAI-PMH:ConfFile") ) {
        $self->{ conf } = LoadFile( $file );
        my @formats = keys %{ $self->{conf}->{format} };
        $self->{ koha_metadata_format } =  \@formats;
    }

    # OAI-PMH handles dates in UTC, so do that on the database level to avoid need for
    # any conversions
    my $sth = C4::Context->dbh->prepare('SELECT @@session.time_zone');
    $sth->execute();
    my ( $orig_tz ) = $sth->fetchrow();
    $self->{ mysql_orig_tz } = $orig_tz;
    C4::Context->dbh->prepare("SET time_zone='+00:00'")->execute();

    # Check for grammatical errors in the request
    my @errs = validate_request( CGI::Vars() );

    # Is metadataPrefix supported by the repository?
    my $mdp = param('metadataPrefix') || '';
    if ( $mdp && !grep { $_ eq $mdp } @{$self->{ koha_metadata_format }} ) {
        push @errs, new HTTP::OAI::Error(
            code    => 'cannotDisseminateFormat',
            message => "Dissemination as '$mdp' is not supported",
        );
    }

    my $response;
    if ( @errs ) {
        $response = HTTP::OAI::Response->new(
            requestURL  => self_url(),
            errors      => \@errs,
        );
    }
    else {
        my %attr = CGI::Vars();
        my $verb = delete $attr{verb};
        my $class = "Koha::OAI::Server::$verb";
        $response = $class->new($self, %attr);
    }

    $response->set_handler( XML::SAX::Writer->new( Output => *STDOUT ) );
    $response->xslt( "/opac-tmpl/xslt/OAI.xslt" );
    $response->generate;

    bless $self, $class;
    return $self;
}


sub DESTROY {
    my ( $self ) = @_;

    # Reset time zone to the original value
    C4::Context->dbh->prepare("SET time_zone='" . $self->{ mysql_orig_tz } . "'")->execute()
        if $self->{ mysql_orig_tz };
}


sub get_biblio_marcxml {
    my ($self, $biblionumber, $format) = @_;
    my $with_items = 0;
    if ( my $conf = $self->{conf} ) {
        $with_items = $conf->{format}->{$format}->{include_items};
    }
    my $record = GetMarcBiblio({
        biblionumber => $biblionumber,
        embed_items  => $with_items,
        opac         => 1 });
    $record ? $record->as_xml_record() : undef;
}


sub stylesheet {
    my ( $self, $format ) = @_;
    my $xsl_file = $self->{ conf }
        ? $self->{ conf }->{ format }->{ $format }->{ xsl_file }
        : ( C4::Context->config('intrahtdocs') .
            '/prog/en/xslt/' .
            C4::Context->preference('marcflavour') .
            'slim2OAIDC.xsl'
    );
    return $xsl_file;
}


sub items_included {
    my ( $self, $format ) = @_;

    if ( my $conf = $self->{ conf } ) {
        return $conf->{ format }->{ $format }->{ include_items };
    }
    return 0;
}

1;
