package Koha::XSLT::Security;

# Copyright 2019 Prosentient Systems, Rijksmuseum
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::XSLT::Security - Add security features to Koha::XSLT::Base

=head1 SYNOPSIS

    use Koha::XSLT::Security;
    my $secu = Koha::XSLT::Security->new;
    $secu->register_callbacks;
    $secu->set_parser_options($parser);

=head1 DESCRIPTION

    This object allows you to apply security options to Koha::XSLT::Base.
    It looks for parser options in koha-conf.xml.

=cut

use Modern::Perl;
use XML::LibXSLT;
use C4::Context;

use base qw(Class::Accessor);

=head1 METHODS

=head2 new

    Creates object, checks if koha-conf.xml contains additional configuration
    options, and checks if XML::LibXSLT::Security is present.

=cut

sub new {
    my ($class) = @_;
    my $self = {};

    $self->{_options} = {};
    my $conf = C4::Context->config('koha_xslt_security');
    if ( $conf && ref($conf) eq 'HASH' ) {
        $self->{_options} = $conf;
    }

    my $security = eval { XML::LibXSLT::Security->new };
    if ($security) {
        $self->{_security_obj} = $security;
    } else {
        warn "No XML::LibXSLT::Security object: $@";    #TODO Move to about ?
    }

    return bless $self, $class;
}

=head2 register_callbacks

    Register LibXSLT security callbacks

=cut

sub register_callbacks {
    my $self = shift;

    my $security = $self->{_security_obj};
    return if !$security;

    $security->register_callback(
        read_file => sub {
            warn "read_file called in XML::LibXSLT";

            #i.e. when using the exsl:document() element or document() function (to read a XML file)
            my ( $tctxt, $value ) = @_;
            return 0;
        }
    );
    $security->register_callback(
        write_file => sub {
            warn "write_file called in XML::LibXSLT";

            #i.e. when using the exsl:document element (or document() function?) (to write an output file of many possible types)
            #e.g.
            #<exsl:document href="file:///tmp/breached.txt">
            #   <xsl:text>breached!</xsl:text>
            #</exsl:document>
            my ( $tctxt, $value ) = @_;
            return 0;
        }
    );
    $security->register_callback(
        read_net => sub {
            warn "read_net called in XML::LibXSLT";

            #i.e. when using the document() function (to read XML from the network)
            #e.g. <xsl:copy-of select="document('http://localhost')" />
            my ( $tctxt, $value ) = @_;
            return 0;
        }
    );
    $security->register_callback(
        write_net => sub {
            warn "write_net called in XML::LibXSLT";

            #NOTE: it's unknown how one would invoke this, but covering our bases anyway
            my ( $tctxt, $value ) = @_;
            return 0;
        }
    );
}

=head2 set_callbacks

    my $xslt = XML::LibXSLT->new;
    $security->set_callbacks( $xslt );

    Apply registered callbacks to a specific xslt instance.

=cut

sub set_callbacks {
    my ( $self, $xslt ) = @_;

    my $security = $self->{_security_obj};
    return if !$security;
    $xslt->security_callbacks($security);
}

=head2 set_parser_options

    $security->set_parser_options($parser);

    If koha-conf.xml includes koha_xslt_security options, set them.
    We start with implementing expand_entities.

=cut

sub set_parser_options {
    my ( $self, $parser ) = @_;
    my $conf = $self->{_options};

    if ( $conf->{expand_entities_unsafe} ) {    # NOT recommended
        _set_option( $parser, 'expand_entities', 1 );
    } else {

        # If not explicitly set, we should disable expanding for security
        _set_option( $parser, 'expand_entities', 0 );
    }
}

sub _set_option {
    my ( $parser, $option_name, $value ) = @_;
    if ( $parser->option_exists($option_name) ) {
        $parser->set_option( $option_name, $value );
    }

    #TODO Should we warn if it does not exist?
}

=head1 AUTHOR

    David Cook, Prosentient Systems
    Marcel de Rooy, Rijksmuseum Netherlands

=cut

1;
