package Koha::Upload;

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

Koha::Upload - Facilitate file uploads (temporary and permanent)

=head1 SYNOPSIS

    use Koha::Upload;

    # add an upload (see tools/upload-file.pl)
    # the public flag allows retrieval via OPAC
    my $upload = Koha::Upload->new( public => 1, category => 'A' );
    my $cgi = $upload->cgi;
    # Do something with $upload->count, $upload->result or $upload->err

    # get some upload records (in staff)
    # Note: use the public flag for OPAC
    my @uploads = Koha::Upload->new->get( term => $term );
    $template->param( uploads => \@uploads );

    # staff download
    my $rec = Koha::Upload->new->get({ id => $id, filehandle => 1 });
    my $fh = $rec->{fh};
    my @hdr = Koha::Upload->httpheaders( $rec->{name} );
    print Encode::encode_utf8( $input->header( @hdr ) );
    while( <$fh> ) { print $_; }
    $fh->close;

    # delete an upload
    my ( $fn ) = Koha::Upload->new->delete({ id => $id });

=head1 DESCRIPTION

    This module is a refactored version of C4::UploadedFile but adds on top
    of that the new functions from report 6874 (Upload plugin in editor).
    That report added module UploadedFiles.pm. This module contains the
    functionality of both.

=head1 METHODS

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

__PACKAGE__->mk_ro_accessors( qw|| );

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

    Returns hash with errors in format { file => err, ... }
    Undefined if there are no errors.

=cut

sub err {
    my ( $self ) = @_;
    my $err;
    foreach my $f ( keys %{ $self->{files} } ) {
        my $e = $self->{files}->{$f}->{errcode};
        $err->{ $f } = $e if $e;
    }
    return $err;
}

=head2 get

    Returns arrayref of uploaded records (hash) or one uploaded record.
    You can pass id => $id or hashvalue => $hash or term => $term.
    Optional parameter filehandle => 1 returns you a filehandle too.

=cut

sub get {
    my ( $self, $params ) = @_;
    my $temp= $self->_lookup( $params );
    my ( @rv, $res);
    foreach my $r ( @$temp ) {
        undef $res;
        foreach( qw[id hashvalue filesize uploadcategorycode public permanent owner] ) {
            $res->{$_} = $r->{$_};
        }
        $res->{name} = $r->{filename};
        $res->{path} = $self->_full_fname($r);
        if( $res->{path} && -r $res->{path} ) {
            if( $params->{filehandle} ) {
                my $fh = IO::File->new( $res->{path}, "r" );
                $fh->binmode if $fh;
                $res->{fh} = $fh;
            }
            push @rv, $res;
        } else {
            $self->{files}->{ $r->{filename} }->{errcode}=5; #not readable
        }
        last if !wantarray;
    }
    return wantarray? @rv: $res;
}

=head2 delete

    Returns array of deleted filenames or undef.
    Since it now only accepts id as parameter, you should not expect more
    than one filename.

=cut

sub delete {
    my ( $self, $params ) = @_;
    return if !$params->{id};
    my @res;
    my $temp = $self->_lookup({ id => $params->{id} });
    foreach( @$temp ) {
        my $d = $self->_delete( $_ );
        push @res, $d if $d;
    }
    return if !@res;
    return @res;
}

=head1 CLASS METHODS

=head2 getCategories

    getCategories returns a list of upload category codes and names

=cut

sub getCategories {
    my ( $class ) = @_;
    my $cats = C4::Koha::GetAuthorisedValues('UPLOAD');
    [ map {{ code => $_->{authorised_value}, name => $_->{lib} }} @$cats ];
}

=head2 httpheaders

    httpheaders returns http headers for a retrievable upload
    Will be extended by report 14282

=cut

sub httpheaders {
    my ( $class, $name ) = @_;
    return (
        '-type'       => 'application/octet-stream',
        '-attachment' => $name,
    );
}

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

    $self->{rootdir} = C4::Context->config('upload_path');
    $self->{tmpdir} = File::Spec->tmpdir;

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
        my $fn = $self->{files}->{$filename}->{hash}. '_'. $filename;
        if( -e "$dir/$fn" && @{ $self->_lookup({
          hashvalue => $self->{files}->{$filename}->{hash} }) } ) {
        # if the file exists and it is registered, then set error
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

sub _full_fname {
    my ( $self, $rec ) = @_;
    my $p;
    if( ref $rec ) {
        $p = File::Spec->catfile(
            $rec->{permanent}? $self->{rootdir}: $self->{tmpdir},
            $rec->{dir},
            $rec->{hashvalue}. '_'. $rec->{filename}
        );
    }
    return $p;
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
    my $dbh= C4::Context->dbh;
    my $sql= 'INSERT INTO uploaded_files (hashvalue, filename, dir, filesize,
        owner, uploadcategorycode, public, permanent) VALUES (?,?,?,?,?,?,?,?)';
    my @pars= (
        $self->{files}->{$filename}->{hash},
        $filename,
        $self->{category},
        $size,
        $self->{uid},
        $self->{category},
        $self->{public},
        $self->{temporary}? 0: 1,
    );
    $dbh->do( $sql, undef, @pars );
    my $i = $dbh->last_insert_id(undef, undef, 'uploaded_files', undef);
    $self->{files}->{$filename}->{id} = $i if $i;
}

sub _lookup {
    my ( $self, $params ) = @_;
    my $dbh = C4::Context->dbh;
    my $sql = q|
SELECT id,hashvalue,filename,dir,filesize,uploadcategorycode,public,permanent,owner
FROM uploaded_files
    |;
    my @pars;
    if( $params->{id} ) {
        return [] if $params->{id} !~ /^\d+(,\d+)*$/;
        $sql.= 'WHERE id IN ('.$params->{id}.')';
        @pars = ();
    } elsif( $params->{hashvalue} ) {
        $sql.= 'WHERE hashvalue=?';
        @pars = ( $params->{hashvalue} );
    } elsif( $params->{term} ) {
        $sql.= 'WHERE (filename LIKE ? OR hashvalue LIKE ?)';
        @pars = ( '%'.$params->{term}.'%', '%'.$params->{term}.'%' );
    } else {
        return [];
    }
    $sql.= $self->{public}? ' AND public=1': '';
    $sql.= ' ORDER BY id';
    my $temp= $dbh->selectall_arrayref( $sql, { Slice => {} }, @pars );
    return $temp;
}

sub _delete {
    my ( $self, $rec ) = @_;
    my $dbh = C4::Context->dbh;
    my $sql = 'DELETE FROM uploaded_files WHERE id=?';
    my $file = $self->_full_fname($rec);
    if( !-e $file ) { # we will just delete the record
        # TODO Should we add a trace here for the missing file?
        $dbh->do( $sql, undef, ( $rec->{id} ) );
        return $rec->{filename};
    } elsif( unlink($file) ) {
        $dbh->do( $sql, undef, ( $rec->{id} ) );
        return $rec->{filename};
    }
    $self->{files}->{ $rec->{filename} }->{errcode} = 7;
    #NOTE: errcode=6 is used to report successful delete (see template)
    return;
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
