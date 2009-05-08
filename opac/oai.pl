#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use CGI qw/:standard -oldstyle_urls/;
use vars qw( $GZIP );
use C4::Context;


BEGIN {
    eval { require PerlIO::gzip };
    $GZIP = $@ ? 0 : 1;
}

unless ( C4::Context->preference('OAI-PMH') ) {
    print
        header(
            -type       => 'text/plain; charset=utf-8',
            -charset    => 'utf-8',
            -status     => '404 OAI-PMH service is disabled',
        ),
        "OAI-PMH service is disabled";
    exit;
}

my @encodings = http('HTTP_ACCEPT_ENCODING');
if ( $GZIP && grep { defined($_) && $_ eq 'gzip' } @encodings ) {
    print header(
        -type               => 'text/xml; charset=utf-8',
        -charset            => 'utf-8',
        -Content-Encoding   => 'gzip',
    );
    binmode( STDOUT, ":gzip" );
}
else {
    print header(
        -type       => 'text/xml; charset=utf-8',
        -charset    => 'utf-8',
    );
}

binmode( STDOUT, ":utf8" );
my $repository = C4::OAI::Repository->new();

# __END__ Main Prog


#
# Extends HTTP::OAI::ResumptionToken
# A token is identified by:
# - metadataPrefix
# - from
# - until
# - offset
# 
package C4::OAI::ResumptionToken;

use strict;
use warnings;
use diagnostics;
use HTTP::OAI;

use base ("HTTP::OAI::ResumptionToken");


sub new {
    my ($class, %args) = @_;

    my $self = $class->SUPER::new(%args);

    my ($metadata_prefix, $offset, $from, $until);
    if ( $args{ resumptionToken } ) {
        ($metadata_prefix, $offset, $from, $until)
            = split( ':', $args{resumptionToken} );
    }
    else {
        $metadata_prefix = $args{ metadataPrefix };
        $from = $args{ from } || '1970-01-01';
        $until = $args{ until };
        unless ( $until) {
            my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime( time );
            $until = sprintf( "%.4d-%.2d-%.2d", $year+1900, $mon+1,$mday );
        }
        $offset = $args{ offset } || 0;
    }

    $self->{ metadata_prefix } = $metadata_prefix;
    $self->{ offset          } = $offset;
    $self->{ from            } = $from;
    $self->{ until           } = $until;

    $self->resumptionToken(
        join( ':', $metadata_prefix, $offset, $from, $until ) );
    $self->cursor( $offset );

    return $self;
}

# __END__ C4::OAI::ResumptionToken



package C4::OAI::Identify;

use strict;
use warnings;
use diagnostics;
use HTTP::OAI;
use C4::Context;

use base ("HTTP::OAI::Identify");

sub new {
    my ($class, $repository) = @_;

    my ($baseURL) = $repository->self_url() =~ /(.*)\?.*/;
    my $self = $class->SUPER::new(
        baseURL             => $baseURL,
        repositoryName      => C4::Context->preference("LibraryName"),
        adminEmail          => C4::Context->preference("KohaAdminEmailAddress"),
        MaxCount            => C4::Context->preference("OAI-PMH:MaxCount"),
        granularity         => 'YYYY-MM-DD',
        earliestDatestamp   => '0001-01-01',
        deletedRecord       => 'no',
    );
    $self->description( "Koha OAI Repository" );
    $self->compression( 'gzip' );

    return $self;
}

# __END__ C4::OAI::Identify



package C4::OAI::ListMetadataFormats;

use strict;
use warnings;
use diagnostics;
use HTTP::OAI;

use base ("HTTP::OAI::ListMetadataFormats");

sub new {
    my ($class, $repository) = @_;

    my $self = $class->SUPER::new();

    $self->metadataFormat( HTTP::OAI::MetadataFormat->new(
        metadataPrefix    => 'oai_dc',
        schema            => 'http://www.openarchives.org/OAI/2.0/oai_dc.xsd',
        metadataNamespace => 'http://www.openarchives.org/OAI/2.0/oai_dc/'
    ) );
    $self->metadataFormat( HTTP::OAI::MetadataFormat->new(
        metadataPrefix    => 'marcxml',
        schema            => 'http://www.loc.gov/MARC21/slim http://www.loc.gov/ standards/marcxml/schema/MARC21slim.xsd',
        metadataNamespace => 'http://www.loc.gov/MARC21/slim http://www.loc.gov/ standards/marcxml/schema/MARC21slim'
    ) );

    return $self;
}

# __END__ C4::OAI::ListMetadataFormats



package C4::OAI::Record;

use strict;
use warnings;
use diagnostics;
use HTTP::OAI;
use HTTP::OAI::Metadata::OAI_DC;

use base ("HTTP::OAI::Record");

sub new {
    my ($class, $repository, $marcxml, $timestamp, %args) = @_;

    my $self = $class->SUPER::new(%args);

    $timestamp =~ s/ /T/, $timestamp .= 'Z';
    $self->header( new HTTP::OAI::Header(
        identifier  => $args{identifier},
        datestamp   => $timestamp,
    ) );

    my $parser = XML::LibXML->new();
    my $record_dom = $parser->parse_string( $marcxml );
    if ( $args{metadataPrefix} ne 'marcxml' ) {
        $record_dom = $repository->oai_dc_stylesheet()->transform( $record_dom );
    }
    $self->metadata( HTTP::OAI::Metadata->new( dom => $record_dom ) );

    return $self;
}

# __END__ C4::OAI::Record



package C4::OAI::GetRecord;

use strict;
use warnings;
use diagnostics;
use HTTP::OAI;

use base ("HTTP::OAI::GetRecord");


sub new {
    my ($class, $repository, %args) = @_;

    my $self = HTTP::OAI::GetRecord->new(%args);

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
        SELECT marcxml, timestamp
        FROM   biblioitems
        WHERE  biblionumber=? " );
    my $prefix = $repository->{koha_identifier} . ':';
    my ($biblionumber) = $args{identifier} =~ /^$prefix(.*)/;
    $sth->execute( $biblionumber );
    my ($marcxml, $timestamp);
    unless ( ($marcxml, $timestamp) = $sth->fetchrow ) {
        return HTTP::OAI::Response->new(
            requestURL  => $repository->self_url(),
            errors      => [ new HTTP::OAI::Error(
                code    => 'idDoesNotExist',
                message => "There is no biblio record with this identifier",
                ) ] ,
        );
    }

    #$self->header( HTTP::OAI::Header->new( identifier  => $args{identifier} ) );
    $self->record( C4::OAI::Record->new(
        $repository, $marcxml, $timestamp, %args ) );

    return $self;
}

# __END__ C4::OAI::GetRecord



package C4::OAI::ListIdentifiers;

use strict;
use warnings;
use diagnostics;
use HTTP::OAI;

use base ("HTTP::OAI::ListIdentifiers");


sub new {
    my ($class, $repository, %args) = @_;

    my $self = HTTP::OAI::ListIdentifiers->new(%args);

    my $token = new C4::OAI::ResumptionToken( %args );
    my $dbh = C4::Context->dbh;
    my $sql = "SELECT biblionumber, timestamp
               FROM   biblioitems
               WHERE  timestamp >= ? AND timestamp <= ?
               LIMIT  " . $repository->{koha_max_count} . "
               OFFSET " . $token->{offset};
    my $sth = $dbh->prepare( $sql );
   	$sth->execute( $token->{from}, $token->{until} );

    my $pos = $token->{offset};
 	while ( my ($biblionumber, $timestamp) = $sth->fetchrow ) {
 	    $timestamp =~ s/ /T/, $timestamp .= 'Z';
        $self->identifier( new HTTP::OAI::Header(
            identifier => $repository->{ koha_identifier} . ':' . $biblionumber,
            datestamp  => $timestamp,
        ) );
        $pos++;
 	}
 	$self->resumptionToken( new C4::OAI::ResumptionToken(
        metadataPrefix  => $token->{metadata_prefix},
        from            => $token->{from},
        until           => $token->{until},
        offset          => $pos ) );

    return $self;
}

# __END__ C4::OAI::ListIdentifiers



package C4::OAI::ListRecords;

use strict;
use warnings;
use diagnostics;
use HTTP::OAI;

use base ("HTTP::OAI::ListRecords");


sub new {
    my ($class, $repository, %args) = @_;

    my $self = HTTP::OAI::ListRecords->new(%args);

    my $token = new C4::OAI::ResumptionToken( %args );
    my $dbh = C4::Context->dbh;
    my $sql = "SELECT biblionumber, marcxml, timestamp
               FROM   biblioitems
               WHERE  timestamp >= ? AND timestamp <= ?
               LIMIT  " . $repository->{koha_max_count} . "
               OFFSET " . $token->{offset};
    my $sth = $dbh->prepare( $sql );
   	$sth->execute( $token->{from}, $token->{until} );

    my $pos = $token->{offset};
 	while ( my ($biblionumber, $marcxml, $timestamp) = $sth->fetchrow ) {
        $self->record( C4::OAI::Record->new(
            $repository, $marcxml, $timestamp,
            identifier      => $repository->{ koha_identifier } . ':' . $biblionumber,
            metadataPrefix  => $token->{metadata_prefix}
        ) );
        $pos++;
 	}
 	$self->resumptionToken( new C4::OAI::ResumptionToken(
        metadataPrefix  => $token->{metadata_prefix},
        from            => $token->{from},
        until           => $token->{until},
        offset          => $pos ) );

    return $self;
}

# __END__ C4::OAI::ListRecords



package C4::OAI::Repository;

use base ("HTTP::OAI::Repository");

use strict;
use warnings;
use diagnostics;

use HTTP::OAI;
use HTTP::OAI::Repository qw/:validate/;

use XML::SAX::Writer;
use XML::LibXML;
use XML::LibXSLT;
use CGI qw/:standard -oldstyle_urls/;

use C4::Context;
use C4::Biblio;


=head1 NAME

C4::OAI::Repository - Handles OAI-PMH requests for a Koha database.

=head1 SYNOPSIS

  use C4::OAI::Repository;

  my $repository = C4::OAI::Repository->new();

=head1 DESCRIPTION

This object extend HTTP::OAI::Repository object.

=cut



sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);

    $self->{ koha_identifier      } = C4::Context->preference("OAI-PMH:archiveID");
    $self->{ koha_max_count       } = C4::Context->preference("OAI-PMH:MaxCount");
    $self->{ koha_metadata_format } = ['oai_dc', 'marcxml'];

    # Check for grammatical errors in the request
    my @errs = validate_request( CGI::Vars() );

    # Is metadataPrefix supported by the respository?
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
        my $verb = delete( $attr{verb} );
        if ( grep { $_ eq $verb } qw( ListSets ) ) {
            $response = HTTP::OAI::Response->new(
                requestURL  => $self->self_url(),
                errors      => [ new HTTP::OAI::Error(
                    code    => 'noSetHierarchy',
                    message => "Koha repository doesn't have sets",
                    ) ] ,
            );
        }
        elsif ( $verb eq 'Identify' ) {
            $response = C4::OAI::Identify->new( $self );
        }
        elsif ( $verb eq 'ListMetadataFormats' ) {
            $response = C4::OAI::ListMetadataFormats->new( $self );
        }
        elsif ( $verb eq 'GetRecord' ) {
            $response = C4::OAI::GetRecord->new( $self, %attr );
        }
        elsif ( $verb eq 'ListRecords' ) {
            $response = C4::OAI::ListRecords->new( $self, %attr );
        }
        elsif ( $verb eq 'ListIdentifiers' ) {
            $response = C4::OAI::ListIdentifiers->new( $self, %attr );
        }
    }

    $response->set_handler( XML::SAX::Writer->new( Output => *STDOUT ) );
    $response->generate;

    bless $self, $class;
    return $self;
}


#
# XSLT stylesheet used to transform MARCXML record into OAI Dublin Core.
# The object is constructed the fist time this method is called.
#
# Styleeet file is located in /koha-tmpl/intranet-tmpl/prog/en/xslt/ directory.
# Its name is constructed with 'marcflavour' syspref:
#   - MARC21slim2OAIDC.xsl
#   - UNIMARCslim2OADIC.xsl
#
sub oai_dc_stylesheet {
    my $self = shift;

    unless ( $self->{ oai_dc_stylesheet } ) {
        my $xslt_file = C4::Context->config('intranetdir') .
                        "/koha-tmpl/intranet-tmpl/prog/en/xslt/" .
                        C4::Context->preference('marcflavour') .
                        "slim2OAIDC.xsl";
        my $parser = XML::LibXML->new();
        my $xslt = XML::LibXSLT->new();
        my $style_doc = $parser->parse_file( $xslt_file );
        my $stylesheet = $xslt->parse_stylesheet( $style_doc );
        $self->{ oai_dc_stylesheet } = $stylesheet;
    }

    return $self->{ oai_dc_stylesheet };
}

