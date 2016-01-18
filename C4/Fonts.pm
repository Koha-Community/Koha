package C4::Fonts;
# Copyright 2015 KohaSuomi
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

use Modern::Perl;
use List::Util;
use Try::Tiny;
use Scalar::Util qw(blessed);
use File::Basename;

use Koha::Exception::UnknownObject;
use Koha::Exception::NoSystemPreference;

sub getFonts {
    my $ttf = _getFontsSyspref();
    return $ttf;
}

=head getAvailableFontsNicely

@RETURNS HASHRef of HASHRef, fonts rebranded with human readable attributes
        { CO =>  {
             name => 'DejaVuSansMono-Oblique',
             path => '/usr/share/fonts/truetype/ttf-dejavu/DejaVuSansMono-Oblique.ttf',
             id   => 'CO',
          },
          ...
        }

=cut

sub getAvailableFontsNicely {
    my $fonts = getFonts();
    my %names;
    foreach my $f (@$fonts) {
        my $name = File::Basename::fileparse($f->{content}, qr/\.[^.]*/);
        $names{$f->{type}} = {
            id => $f->{type},
            name => $name,
            path => $f->{content},
        };
    }
    return \%names;
}

=head getFont

    my $font = C4::Fonts::getFont($fontName);

$PARAM1 String,
@RETURNS The font
@THROWS Koha::Exception::UnknownObject if no such font is configured or exists in the filesystem.
=cut

sub getFont {
    my ($font) = @_;
    $font = $font->{type} if ref $font eq 'HASH';

    my $ttf = _getFontsSyspref();
    my $ttf_path = List::Util::first { $_->{type} eq $font } @$ttf;
    if ( -e $ttf_path->{content} ) {
        return $ttf_path;
    } else {
        my @cc = caller(0);
        Koha::Exception::UnknownObject->throw(error => $cc[3]."($font):> No such font defined in koha-conf.xml <font type=\"$font\">/path/to/font.ttf</font>");
    }
}

sub hasFont {
    my ($fontName) = @_;

    try {
        return (getFont($fontName)) ? 1 : undef;
    } catch {
        if (blessed($_) && $_->isa('Koha::Exception::UnknownObject')) {
            #OK, return undef
        }
        elsif (blessed($_)) {
            $_->rethrow();
        }
        else {
            die $_;
        }
    }
    return undef;
}

sub _getFontsSyspref {
    my $ttf = C4::Context->config('ttf') or Koha::Exception::NoSystemPreference->throw(error => __PACKAGE__.":: TrueType-fonts not configured in \$KOHA_CONF!");
    return $ttf->{font};
}

1;
