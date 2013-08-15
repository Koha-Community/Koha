package Koha::I18N;

# Copyright 2012 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
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
use base qw(Locale::Maketext);

use C4::Templates;
use C4::Context;

use Locale::Maketext::Lexicon {
    'en' => ['Auto'],
    '*' => [
        Gettext =>
            C4::Context->config('intranetdir')
            . '/misc/translator/po/*-messages.po'
    ],
    '_AUTO' => 1,
};

sub get_handle_from_context {
    my ($class, $cgi, $interface) = @_;

    my $lh;
    my $lang = C4::Templates::getlanguage($cgi, $interface);
    if ($lang) {
        $lh = $class->get_handle($lang)
            or die "No language handle for '$lang'";
    } else {
        $lh = $class->get_handle()
            or die "Can't get a language handle";
    }

    return $lh;
}

1;
