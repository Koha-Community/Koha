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
    my $err= $xslt_engine->err; # error number
    my $errstr= $xslt_engine->errstr; # error message
    $xslt_engine->refresh($xsltfilename);

=head1 DESCRIPTION

    A XSLT handler object on top of LibXML and LibXSLT, allowing you to
    run XSLT stylesheets repeatedly without loading them again.
    Errors occurring during loading, parsing or transforming are reported
    via the err and errstr attributes.
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

    Error number (see list of ERROR CODES)

=head2 errstr

    Error message

=head2 do_not_return_source

    If true, transform returns undef on failure. By default, it returns the
    original string passed. Errors are reported as described.

=head1 ERROR CODES

=head2 Error 1

    No XSLT file passed

=head2 Error 2

    XSLT file not found

=head2 Error 3

    Error while loading stylesheet xml: [furter information]

=head2 Error 4

    Error while parsing stylesheet: [furter information]

=head2 Error 5

    Error while parsing input: [furter information]

=head2 Error 6

    Error while transforming input: [furter information]

=head2 Error 7

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

__PACKAGE__->mk_ro_accessors(qw( err errstr ));
__PACKAGE__->mk_accessors(qw( do_not_return_source ));

=head2 transform

    my $output= $xslt_engine->transform( $xml, $xsltfilename );
    if( $xslt_engine->err ) {
        #decide what to do on failure..
    }
    my $output2= $xslt_engine->transform( $xml2 );

    Pass a xml string and a fully qualified path of a XSLT file.
    Instead of a filename, you may also pass a URL.
    If you do not pass a filename, the last file used is assumed.
    Returns the transformed string.
    Check the error number in err to know if something went wrong.
    In that case do_not_return_source did determine the return value.

=cut

sub transform {
    my ( $self, $orgxml, $file ) = @_;

    #Initialized yet?
    if( !$self->{xslt_hash} ) {
        $self->_init;
    }
    else {
        $self->_set_error; #clear error
    }
    my $retval= $self->{do_not_return_source}? undef: $orgxml;

    #check if no string passed
    if( !defined $orgxml ) {
        $self->_set_error(7);
        return; #always undef
    }

    #If no file passed, use the last file again
    if( !$file ) {
        if( !$self->{last_xsltfile} ) {
            $self->_set_error(1);
            return $retval;
        }
        $file= $self->{last_xsltfile};
    }

    #load stylesheet
    my $stsh= $self->{xslt_hash}->{$file} // $self->_load($file);
    return $retval if $self->{err};

    #parse input and transform
    my $parser = XML::LibXML->new();
    my $source= eval { $parser->parse_string($orgxml) };
    if( $@ ) {
        $self->_set_error(5, $@);
        return $retval;
    }
    my $str= eval {
        my $result= $stsh->transform($source);
        $stsh->output_as_chars($result);
    };
    if( $@ ) {
        $self->_set_error(6, $@);
        return $retval;
    }
    $self->{last_xsltfile}= $file;
    return $str;
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
    my ( $self, $file )= @_;
    $self->_set_error;
    return if !$self->{xslt_hash};
    my $rv;
    if( $file ) {
        $rv= delete $self->{xslt_hash}->{$file}? 1: 0;
    }
    else {
        $rv= scalar keys %{ $self->{xslt_hash} };
        $self->{xslt_hash}= {};
    }
    return $rv;
}

# **************  INTERNAL ROUTINES ********************************************

# _init
# Internal routine for initialization.

sub _init {
    my $self= shift;

    $self->_set_error;
    $self->{xslt_hash}={};
    $self->{do_not_return_source}=0 unless exists $self->{do_not_return_source};
        #by default we return source on a failing transformation
        #but it could be passed at construction time already
    return;
}

# _load
# Internal routine for loading a new stylesheet.

sub _load {
    my ($self, $file)= @_;

    if( !$file || ( $file!~ /^https?:\/\// && !-e $file ) ) {
        $self->_set_error(2);
        return;
    }

    #load sheet
    my $parser = XML::LibXML->new;
    my $style_doc = eval { $parser->load_xml( location => $file ) };
    if( $@ ) {
        $self->_set_error(3, $@);
        return;
    }

    #parse sheet
    my $xslt = XML::LibXSLT->new;
    $self->{xslt_hash}->{$file} = eval { $xslt->parse_stylesheet($style_doc) };
    if( $@ ) {
        $self->_set_error(4, $@);
        delete $self->{xslt_hash}->{$file};
        return;
    }
    return $self->{xslt_hash}->{$file};
}

# _set_error
# Internal routine for handling error information.

sub _set_error {
    my ($self, $errno, $addmsg)= @_;

    if(!$errno) { #clear the error
        $self->{err}= undef;
        $self->{errstr}= undef;
        return;
    }

    $self->{err}= $errno;
    if($errno==1) {
        $self->{errstr}= "No XSLT file passed.";
    }
    elsif($errno==2) {
        $self->{errstr}= "XSLT file not found.";
    }
    elsif($errno==3) {
        $self->{errstr}= "Error while loading stylesheet xml:";
    }
    elsif($errno==4) {
        $self->{errstr}= "Error while parsing stylesheet:";
    }
    elsif($errno==5) {
        $self->{errstr}= "Error while parsing input:";
    }
    elsif($errno==6) {
        $self->{errstr}= "Error while transforming input:";
    }
    elsif($errno==7) {
        $self->{errstr}= "No string to transform.";
    }

    if( $addmsg ) {
        $self->{errstr}.= " $addmsg";
    }
    return;
}

=head1 AUTHOR

    Marcel de Rooy, Rijksmuseum Netherlands

=cut

1;
