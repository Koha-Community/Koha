package Koha::Uploader;

# Copyright 2007 LibLime, Galen Charlton
# Copyright 2011-2012 BibLibre
# Copyright 2015 Rijksmuseum
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

Koha::Uploader - Facilitate file uploads (temporary and permanent)

=head1 SYNOPSIS

    use Koha::Uploader;
    use Koha::UploadedFile;
    use Koha::UploadedFiles;

    # add an upload (see tools/upload-file.pl)
    # the public flag allows retrieval via OPAC
    my $upload = Koha::Uploader->new( public => 1, category => 'A' );
    my $cgi = $upload->cgi;
    # Do something with $upload->count, $upload->result or $upload->err

    # get some upload records (in staff) via Koha::UploadedFiles
    my @uploads1 = Koha::UploadedFiles->search({ filename => $name });
    my @uploads2 = Koha::UploadedFiles->search_term({ term => $term });

    # staff download (via Koha::UploadedFile[s])
    my $rec = Koha::UploadedFiles->find( $id );
    my $fh = $rec->file_handle;
    print Encode::encode_utf8( $input->header( $rec->httpheaders ) );
    while( <$fh> ) { print $_; }
    $fh->close;

=head1 DESCRIPTION

    This module is a refactored version of C4::UploadedFile but adds on top
    of that the new functions from report 6874 (Upload plugin in editor).
    That report added module UploadedFiles.pm. This module contains the
    functionality of both.

    The module has been revised to use Koha::Object[s]; the delete method
    has been moved to Koha::UploadedFile[s], as well as the get method.

=cut

use constant KOHA_UPLOAD => 'koha_upload';
use constant BYTES_DIGEST => 2048;

use Modern::Perl;
use CGI; # no utf8 flag, since it may interfere with binary uploads
use Digest::MD5;
use Encode;
use File::Spec;
use IO::File;
use Time::HiRes;

use base qw(Class::Accessor);

use C4::Context;
use C4::Koha;
use Koha::UploadedFile;
use Koha::UploadedFiles;

__PACKAGE__->mk_ro_accessors( qw|| );

=head1 INSTANCE METHODS

=head2 new

    Returns new object based on Class::Accessor.
    Use tmp or temp flag for temporary storage.
    Use public flag to mark uploads as available in OPAC.
    The category parameter is only useful for permanent storage.

=cut

sub new {
    my ( $class, $params ) = @_;
    my $self = $class->SUPER::new();
    $self->_init( $params );
    return $self;
}

=head2 cgi

    Returns CGI object. The CGI hook is used to store the uploaded files.

=cut

sub cgi {
    my ( $self ) = @_;

    # Next call handles the actual upload via CGI hook.
    # The third parameter (0) below means: no CGI temporary storage.
    # Cancelling an upload will make CGI abort the script; no problem,
    # the file(s) without db entry will be removed later.
    my $query = CGI::->new( sub { $self->_hook(@_); }, {}, 0 );
    if( $query ) {
        $self->_done;
        return $query;
    }
}

=head2 count

    Returns number of uploaded files without errors

=cut

sub count {
    my ( $self ) = @_;
    return scalar grep { !exists $self->{files}->{$_}->{errcode} } keys %{ $self->{files} };
}

=head2 result

    Returns a string of id's for each successful upload separated by commas.

=cut

sub result {
    my ( $self ) = @_;
    my @a = map { $self->{files}->{$_}->{id} }
        grep { !exists $self->{files}->{$_}->{errcode} }
        keys %{ $self->{files} };
    return @a? ( join ',', @a ): undef;
}

=head2 err

    Returns hashref with errors in format { file => { code => err }, ... }
    Undefined if there are no errors.

=cut

sub err {
    my ( $self ) = @_;
    my $err;
    foreach my $f ( keys %{ $self->{files} } ) {
        my $e = $self->{files}->{$f}->{errcode};
        $err->{ $f }->{code} = $e if $e;
    }
    return $err;
}

=head1 CLASS METHODS

=head2 allows_add_by

    allows_add_by checks if $userid has permission to add uploaded files

=cut

sub allows_add_by {
    my ( $class, $userid ) = @_; # do not confuse with borrowernumber
    my $flags = [
        { tools      => 'upload_general_files' },
        { circulate  => 'circulate_remaining_permissions' },
        { tools      => 'stage_marc_import' },
        { tools      => 'upload_local_cover_images' },
    ];
    require C4::Auth;
    foreach( @$flags ) {
        return 1 if C4::Auth::haspermission( $userid, $_ );
    }
    return;
}

=head1 INTERNAL ROUTINES

=cut

sub _init {
    my ( $self, $params ) = @_;

    $self->{rootdir} = Koha::UploadedFile->permanent_directory;
    $self->{tmpdir} = C4::Context::temporary_directory;

    $params->{tmp} = $params->{temp} if !exists $params->{tmp};
    $self->{temporary} = $params->{tmp}? 1: 0; #default false
    if( $params->{tmp} ) {
        my $db =  C4::Context->config('database');
        $self->{category} = KOHA_UPLOAD;
        $self->{category} =~ s/koha/$db/;
    } else {
        $self->{category} = $params->{category} || KOHA_UPLOAD;
    }

    $self->{files} = {};
    $self->{uid} = C4::Context->userenv->{number} if C4::Context->userenv;
    $self->{public} = $params->{public}? 1: undef;
}

sub _fh {
    my ( $self, $filename ) = @_;
    if( $self->{files}->{$filename} ) {
        return $self->{files}->{$filename}->{fh};
    }
}

sub _create_file {
    my ( $self, $filename ) = @_;
    my $fh;
    if( $self->{files}->{$filename} &&
            $self->{files}->{$filename}->{errcode} ) {
        #skip
    } elsif( !$self->{temporary} && !$self->{rootdir} ) {
        $self->{files}->{$filename}->{errcode} = 3; #no rootdir
    } elsif( $self->{temporary} && !$self->{tmpdir} ) {
        $self->{files}->{$filename}->{errcode} = 4; #no tempdir
    } else {
        my $dir = $self->_dir;
        my $hashval = $self->{files}->{$filename}->{hash};
        my $fn = $hashval. '_'. $filename;

        # if the file exists and it is registered, then set error
        # if it exists, but is not in the database, we will overwrite
        if( -e "$dir/$fn" &&
        Koha::UploadedFiles->search({
            hashvalue          => $hashval,
            uploadcategorycode => $self->{category},
        })->count ) {
            $self->{files}->{$filename}->{errcode} = 1; #already exists
            return;
        }

        $fh = IO::File->new( "$dir/$fn", "w");
        if( $fh ) {
            $fh->binmode;
            $self->{files}->{$filename}->{fh}= $fh;
        } else {
            $self->{files}->{$filename}->{errcode} = 2; #not writable
        }
    }
    return $fh;
}

sub _dir {
    my ( $self ) = @_;
    my $dir = $self->{temporary}? $self->{tmpdir}: $self->{rootdir};
    $dir.= '/'. $self->{category};
    mkdir $dir if !-d $dir;
    return $dir;
}

sub _hook {
    my ( $self, $filename, $buffer, $bytes_read, $data ) = @_;
    $filename= Encode::decode_utf8( $filename ); # UTF8 chars in filename
    $self->_compute( $filename, $buffer );
    my $fh = $self->_fh( $filename ) // $self->_create_file( $filename );
    print $fh $buffer if $fh;
}

sub _done {
    my ( $self ) = @_;
    $self->{done} = 1;
    foreach my $f ( keys %{ $self->{files} } ) {
        my $fh = $self->_fh($f);
        $self->_register( $f, $fh? tell( $fh ): undef )
            if !$self->{files}->{$f}->{errcode};
        $fh->close if $fh;
    }
}

sub _register {
    my ( $self, $filename, $size ) = @_;
    my $rec = Koha::UploadedFile->new({
        hashvalue => $self->{files}->{$filename}->{hash},
        filename  => $filename,
        dir       => $self->{category},
        filesize  => $size,
        owner     => $self->{uid},
        uploadcategorycode => $self->{category},
        public    => $self->{public},
        permanent => $self->{temporary}? 0: 1,
    })->store;
    $self->{files}->{$filename}->{id} = $rec->id if $rec;
}

sub _compute {
# Computes hash value when sub hook feeds the first block
# For temporary files, the id is made unique with time
    my ( $self, $name, $block ) = @_;
    if( !$self->{files}->{$name}->{hash} ) {
        my $str = $name. ( $self->{uid} // '0' ).
            ( $self->{temporary}? Time::HiRes::time(): '' ).
            $self->{category}. substr( $block, 0, BYTES_DIGEST );
        # since Digest cannot handle wide chars, we need to encode here
        # there could be a wide char in the filename or the category
        my $h = Digest::MD5::md5_hex( Encode::encode_utf8( $str ) );
        $self->{files}->{$name}->{hash} = $h;
    }
}

=head1 AUTHOR

    Koha Development Team
    Larger parts from Galen Charlton, Julian Maurice and Marcel de Rooy

=cut

1;
