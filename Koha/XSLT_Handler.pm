package Koha::XSLT_Handler;

# Copyright 2014 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::XSLT_Handler - Facilitate use of XSLT transformations

=head1 SYNOPSIS

    use Koha::XSLT_Handler;
    my $xslt_engine = Koha::XSLT_Handler->new;
    my $output = $xslt_engine->transform($xml, $xsltfilename);
    $output = $xslt_engine->transform({ xml => $xml, file => $file });
    $output = $xslt_engine->transform({ xml => $xml, code => $code });
    my $err= $xslt_engine->err; # error code
    $xslt_engine->refresh($xsltfilename);

=head1 DESCRIPTION

    A XSLT handler object on top of LibXML and LibXSLT, allowing you to
    run XSLT stylesheets repeatedly without loading them again.
    Errors occurring during loading, parsing or transforming are reported
    via the err attribute.
    Reloading XSLT files can be done with the refresh method.

=head1 METHODS

=head2 new

    Create handler object (via Class::Accessor)

=head2 transform

    Run transformation for specific string and stylesheet

=head2 refresh

    Allow to reload stylesheets when transforming again

=head1 PROPERTIES

=head2 err

    Error code (see list of ERROR CODES)

=head2 do_not_return_source

    If true, transform returns undef on failure. By default, it returns the
    original string passed. Errors are reported as described.

=head2 print_warns

    If set, print error messages to STDERR. False by default. Looks at the
    DEBUG environment variable too.

=head1 ERROR CODES

=head2 Error XSLTH_ERR_NO_FILE

    No XSLT file passed

=head2 Error XSLTH_ERR_FILE_NOT_FOUND

    XSLT file not found

=head2 Error XSLTH_ERR_LOADING

    Error while loading stylesheet xml: [optional warnings]

=head2 Error XSLTH_ERR_PARSING_CODE

    Error while parsing stylesheet: [optional warnings]

=head2 Error XSLTH_ERR_PARSING_DATA

    Error while parsing input: [optional warnings]

=head2 Error XSLTH_ERR_TRANSFORMING

    Error while transforming input: [optional warnings]

=head2 Error XSLTH_NO_STRING_PASSED

    No string to transform

=head1 INTERNALS

    For documentation purposes. You are not encouraged to access them.

=head2 last_xsltfile

    Contains the last successfully executed XSLT filename

=head2 xslt_hash

    Hash reference to loaded stylesheets

=head1 ADDITIONAL COMMENTS

=cut

use Modern::Perl;
use XML::LibXML;
use XML::LibXSLT;

use base qw(Class::Accessor);

__PACKAGE__->mk_ro_accessors(qw( err ));
__PACKAGE__->mk_accessors(qw( do_not_return_source print_warns ));

use constant XSLTH_ERR_1    => 'XSLTH_ERR_NO_FILE';
use constant XSLTH_ERR_2    => 'XSLTH_ERR_FILE_NOT_FOUND';
use constant XSLTH_ERR_3    => 'XSLTH_ERR_LOADING';
use constant XSLTH_ERR_4    => 'XSLTH_ERR_PARSING_CODE';
use constant XSLTH_ERR_5    => 'XSLTH_ERR_PARSING_DATA';
use constant XSLTH_ERR_6    => 'XSLTH_ERR_TRANSFORMING';
use constant XSLTH_ERR_7    => 'XSLTH_NO_STRING_PASSED';

=head2 transform

    my $output= $xslt_engine->transform( $xml, $xsltfilename, [$format] );
    #Alternatively:
    #$output = $xslt_engine->transform({ xml => $xml, file => $file, [parameters => $parameters], [format => ['chars'|'bytes'|'xmldoc']] });
    #$output = $xslt_engine->transform({ xml => $xml, code => $code, [parameters => $parameters], [format => ['chars'|'bytes'|'xmldoc']] });
    if( $xslt_engine->err ) {
        #decide what to do on failure..
    }
    my $output2= $xslt_engine->transform( $xml2 );

    Pass a xml string and a fully qualified path of a XSLT file.
    Instead of a filename, you may also pass a URL.
    You may also pass the contents of a xsl file as a string like $code above.
    If you do not pass a filename, the last file used is assumed.
    Normally returns the transformed string; if you pass format => 'xmldoc' in
    the hash format, it returns a xml document object.
    Check the error number in err to know if something went wrong.
    In that case do_not_return_source did determine the return value.

=cut

sub transform {
    my $self = shift;

    #check parameters
    #  old style: $xml, $filename, $format
    #  new style: $hashref
    my ( $xml, $filename, $xsltcode, $format );
    my $parameters = {};
    if( ref $_[0] eq 'HASH' ) {
        $xml = $_[0]->{xml};
        $xsltcode = $_[0]->{code};
        $filename = $_[0]->{file} if !$xsltcode; #xsltcode gets priority
        $parameters = $_[0]->{parameters} if ref $_[0]->{parameters} eq 'HASH';
        $format = $_[0]->{format} || 'chars';
    } else {
        ( $xml, $filename, $format ) = @_;
        $format ||= 'chars';
    }

    #Initialized yet?
    if ( !$self->{xslt_hash} ) {
        $self->_init;
    }
    else {
        $self->_set_error;    #clear last error
    }
    my $retval = $self->{do_not_return_source} ? undef : $xml;

    #check if no string passed
    if ( !defined $xml ) {
        $self->_set_error( XSLTH_ERR_7 );
        return;               #always undef
    }

    #load stylesheet
    my $key = $self->_load( $filename, $xsltcode );
    my $stsh = $key? $self->{xslt_hash}->{$key}: undef;
    return $retval if $self->{err};

    #parse input and transform
    my $parser = XML::LibXML->new();
    my $source = eval { $parser->parse_string($xml) };
    if ($@) {
        $self->_set_error( XSLTH_ERR_5, $@ );
        return $retval;
    }
    my $result = eval {
        #$parameters is an optional hashref that contains
        #key-value pairs to be sent to the XSLT.
        #Numbers may be bare but strings must be double quoted
        #(e.g. "'string'" or '"string"'). See XML::LibXSLT for
        #more details.

        #NOTE: Parameters are not cached. They are provided for
        #each different transform.
        my $transformed = $stsh->transform($source, %$parameters);
        $format eq 'bytes'
            ? $stsh->output_as_bytes( $transformed )
            : $format eq 'xmldoc'
            ? $transformed
            : $stsh->output_as_chars( $transformed ); # default: chars
    };
    if ($@) {
        $self->_set_error( XSLTH_ERR_6, $@ );
        return $retval;
    }
    $self->{last_xsltfile} = $key;
    return $result;
}

=head2 refresh

    $xslt_engine->refresh;
    $xslt_engine->refresh( $xsltfilename );

    Pass a file for an individual refresh or no file to refresh all.
    Refresh returns the number of items affected.
    What we actually do, is just clear the internal cache for reloading next
    time when transform is called.
    The return value is mainly theoretical. Since this is supposed to work
    always(...), there is no actual need to test it.
    Note that refresh does also clear the error information.

=cut

sub refresh {
    my ( $self, $file ) = @_;
    $self->_set_error;
    return if !$self->{xslt_hash};
    my $rv;
    if ($file) {
        $rv = delete $self->{xslt_hash}->{$file} ? 1 : 0;
    }
    else {
        $rv = scalar keys %{ $self->{xslt_hash} };
        $self->{xslt_hash} = {};
    }
    return $rv;
}

# **************  INTERNAL ROUTINES ********************************************

# _init
# Internal routine for initialization.

sub _init {
    my $self = shift;

    $self->_set_error;
    $self->{xslt_hash} = {};
    $self->{print_warns} = exists $self->{print_warns}
        ? $self->{print_warns}
        : $ENV{DEBUG} // 0;
    $self->{do_not_return_source} = 0
      unless exists $self->{do_not_return_source};

    #by default we return source on a failing transformation
    #but it could be passed at construction time already
    return;
}

# _load
# Internal routine for loading a new stylesheet.

sub _load {
    my ( $self, $filename, $code ) = @_;
    my ( $digest, $codelen, $salt, $rv );
    $salt = 'AZ'; #just a constant actually

    #If no file or code passed, use the last file again
    if ( !$filename && !$code ) {
        my $last = $self->{last_xsltfile};
        if ( !$last || !exists $self->{xslt_hash}->{$last} ) {
            $self->_set_error( XSLTH_ERR_1 );
            return;
        }
        return $last;
    }

    #check if it is loaded already
    if( $code ) {
        $codelen = length( $code );
        $digest = eval { crypt($code, $salt) };
        if( $digest && exists $self->{xslt_hash}->{$digest.$codelen} ) {
            return $digest.$codelen;
        }
    } elsif( $filename && exists $self->{xslt_hash}->{$filename} ) {
          return $filename;
    }

    #Check file existence (skipping URLs)
    if( $filename && $filename !~ /^https?:\/\// && !-e $filename ) {
        $self->_set_error( XSLTH_ERR_2 );
        return;
    }

    #load sheet
    my $parser = XML::LibXML->new;
    my $style_doc = eval {
        $parser->load_xml( $self->_load_xml_args($filename, $code) )
    };
    if ($@) {
        $self->_set_error( XSLTH_ERR_3, $@ );
        return;
    }

    #parse sheet
    my $xslt = XML::LibXSLT->new;
    $rv = $code? $digest.$codelen: $filename;
    $self->{xslt_hash}->{$rv} = eval { $xslt->parse_stylesheet($style_doc) };
    if ($@) {
        $self->_set_error( XSLTH_ERR_4, $@ );
        delete $self->{xslt_hash}->{$rv};
        return;
    }
    return $rv;
}

sub _load_xml_args {
    my $self = shift;
    return $_[1]? { 'string' => $_[1]//'' }: { 'location' => $_[0]//'' };
}

# _set_error
# Internal routine for handling error information.

sub _set_error {
    my ( $self, $errcode, $warn ) = @_;

    $self->{err} = $errcode; #set or clear error
    warn 'XSLT_Handler: '. $warn if $warn && $self->{print_warns};
}

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Netherlands

=cut

1;
