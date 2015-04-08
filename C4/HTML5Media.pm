package C4::HTML5Media;

# Copyright 2012 Mirko Tietgen
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

use strict;
use warnings;

use C4::Context;
use MARC::Field;


=head1 HTML5Media

C4::HTML5Media

=head1 Description

This module gets the relevant data from field 856 (MARC21/UNIMARC) to create a HTML5 audio or video element containing the file(s) catalogued in 856.

=cut

=head2 gethtml5media

Get all relevant data from field 856. Takes a $record in the subroutine call, sets appropriate params.

=cut

sub gethtml5media {
    my $self = shift;
    my $record = shift;
    my @HTML5Media_sets = ();
    my @HTML5Media_fields = $record->field(856);
    my $HTML5MediaParent;
    my $HTML5MediaWidth;
    my @HTML5MediaExtensions = split( /\|/, C4::Context->preference("HTML5MediaExtensions") );
    my $marcflavour          = C4::Context->preference("marcflavour");
    foreach my $HTML5Media_field (@HTML5Media_fields) {
        my %HTML5Media;
        # protocol
        if ( $HTML5Media_field->indicator(1) eq '1' ) {
            $HTML5Media{protocol} = 'ftp';
        }
        elsif ( $HTML5Media_field->indicator(1) eq '4' ) {
            $HTML5Media{protocol} = 'http';
        }
        elsif ( $HTML5Media_field->indicator(1) eq '7' ) {
            if ($marcflavour eq 'MARC21' || $marcflavour eq 'NORMARC') {
                $HTML5Media{protocol} = $HTML5Media_field->subfield('2');
            }
            elsif ($marcflavour eq 'UNIMARC') {
                $HTML5Media{protocol} = $HTML5Media_field->subfield('y');
            }
        }
        else {
            $HTML5Media{protocol} = 'http';
        }
        # user
        if ( $HTML5Media_field->subfield('l') ) {
            $HTML5Media{username} = $HTML5Media_field->subfield('l'); # yes, that is arbitrary if h and l are not the same. originally i flipped a coin in that case.
        }
        elsif ( $HTML5Media_field->subfield('h') ) {
            $HTML5Media{username} = $HTML5Media_field->subfield('h');
        }
        # user/pass
        if ( $HTML5Media{username} && $HTML5Media_field->subfield('k') ) {
            $HTML5Media{loginblock} = $HTML5Media{username} . ':' . $HTML5Media_field->subfield('k') . '@';
        }
        elsif ( $HTML5Media{username} ) {
            $HTML5Media{loginblock} = $HTML5Media{username} . '@';
        }
        else {
            $HTML5Media{loginblock} = '';
        }
        # port
        if ( $HTML5Media_field->subfield('p') ) {
            $HTML5Media{portblock} = ':' . $HTML5Media_field->subfield('k');
        }
        else {
            $HTML5Media{portblock} = '';
        }
        # src
        if ( $HTML5Media_field->subfield('u') ) {
            $HTML5Media{srcblock} = $HTML5Media_field->subfield('u');
        }
        elsif ( $HTML5Media_field->subfield('a') && $HTML5Media_field->subfield('d') && $HTML5Media_field->subfield('f') ) {
            $HTML5Media{host}        = $HTML5Media_field->subfield('a');
            $HTML5Media{host}        =~ s/(^\/|\/$)//g;
            $HTML5Media{path}        = $HTML5Media_field->subfield('d');
            $HTML5Media{path}        =~ s/(^\/|\/$)//g;
            $HTML5Media{file}        = $HTML5Media_field->subfield('f');
            $HTML5Media{srcblock}    = $HTML5Media{protocol} . '://' . $HTML5Media{loginblock} . $HTML5Media{host} . $HTML5Media{portblock} . '/' . $HTML5Media{path} . '/' . $HTML5Media{file};
        }
        else {
            next; # no file to play
        }
        # extension
        $HTML5Media{extension} = ($HTML5Media{srcblock} =~ m/([^.]+)$/)[0];
        if ( !grep /$HTML5Media{extension}/, @HTML5MediaExtensions ) {
            next; # not a specified media file
        }
        # mime
        if ( $HTML5Media_field->subfield('c') ) {
            $HTML5Media{codecs} = $HTML5Media_field->subfield('c');
        }
        ### from subfield q…
        if ( $HTML5Media_field->subfield('q') ) {
            $HTML5Media{mime} = $HTML5Media_field->subfield('q');
        }
        ### …or from file extension and codecs…
        elsif ( $HTML5Media{codecs} ) {
            if ( $HTML5Media{codecs} =~ /theora.*vorbis/ ) {
                $HTML5Media{mime} = 'video/ogg';
            }
            elsif ( $HTML5Media{codecs} =~ /vp8.*vorbis/ ) {
                $HTML5Media{mime} = 'video/webm';
            }
            elsif ( ($HTML5Media{codecs} =~ /^vorbis$/) && ($HTML5Media{extension} eq 'ogg') ) {
                $HTML5Media{mime} = 'audio/ogg';
            }
            elsif ( ($HTML5Media{codecs} =~ /^vorbis$/) && ($HTML5Media{extension} eq 'webm') ) {
                $HTML5Media{mime} = 'audio/webm';
            }
        }
        ### …or just from file extension
        else {
            if ( $HTML5Media{extension} eq 'ogv' ) {
                $HTML5Media{mime} = 'video/ogg';
                $HTML5Media{codecs} = 'theora,vorbis';
            }
            if ( $HTML5Media{extension} eq 'oga' ) {
                $HTML5Media{mime} = 'audio/ogg';
              $HTML5Media{codecs} = 'vorbis';
            }
            elsif ( $HTML5Media{extension} eq 'spx' ) {
                $HTML5Media{mime} = 'audio/ogg';
                $HTML5Media{codecs} = 'speex';
            }
            elsif ( $HTML5Media{extension} eq 'opus' ) {
                $HTML5Media{mime} = 'audio/ogg';
                $HTML5Media{codecs} = 'opus';
            }
            elsif ( $HTML5Media{extension} eq 'vtt' ) {
                $HTML5Media{mime} = 'text/vtt';
            }
        }
        # codecs
        if ( $HTML5Media{codecs} ) {
            $HTML5Media{codecblock} = '; codecs="' . $HTML5Media{codecs} . '"';
        }
        else {
            $HTML5Media{codecblock} = '';
        }
        # type
        if ( $HTML5Media{mime} ) {
            $HTML5Media{typeblock} = ' type=\'' . $HTML5Media{mime} . $HTML5Media{codecblock} . '\'';
        }
        else {
          $HTML5Media{typeblock} = '';
        }
        # element
        if ( $HTML5Media{mime} =~ /audio/ ) {
            $HTML5Media{type} = 'audio';
        }
        elsif ( $HTML5Media{mime} =~ /video/ ) {
            $HTML5Media{type} = 'video';
        }
        elsif ( $HTML5Media{mime} =~ /text/ ) {
            $HTML5Media{type} = 'track';
        }
        # push
        if ( $HTML5Media{srcblock} && $HTML5Media{type} ) {
            push (@HTML5Media_sets, \%HTML5Media);
        }
    }
    # parent element
    for my $media ( @HTML5Media_sets ) {
        if ( ($media->{mime}) && ($media->{mime} =~ /audio/) ) {
            if ( $HTML5MediaParent ne 'video' ) {
                $HTML5MediaParent = 'audio';
                $HTML5MediaWidth = '';
            }
        }
        elsif ( ($media->{mime}) && ($media->{mime} =~ /video/) ) {
            $HTML5MediaParent = 'video';
            $HTML5MediaWidth = ' width="480"';
        }
    }
    # child element
    for my $media ( @HTML5Media_sets ) {
        if ( ($media->{type}) && ( ($media->{type} eq 'video') || ($media->{type} eq 'audio') ) ) {
            if ( $media->{type} eq $HTML5MediaParent ) {
                $media->{child} = 'source';
            }
        }
        else {
            $media->{child} = $media->{type};
        }
    }

    return (
        HTML5MediaEnabled  => ( (scalar(@HTML5Media_sets) > 0) && ($HTML5MediaParent) ),
        HTML5MediaSets     => \@HTML5Media_sets,
        HTML5MediaParent   => $HTML5MediaParent,
        HTML5MediaWidth    => $HTML5MediaWidth,
    );
}

1;
