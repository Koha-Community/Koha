package Koha::I18N;

# This file is part of Koha.
#
# Copyright 2012-2014 BibLibre
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

use Modern::Perl;
use base qw(Locale::Maketext Exporter);

use CGI;
use C4::Languages;

use Locale::Maketext::Lexicon {
    'en' => ['Auto'],
    '*' => [
        Gettext =>
            C4::Context->config('intranetdir')
            . '/misc/translator/po/*-messages.po'
    ],
    '_AUTO' => 1,
    '_style' => 'gettext',
};

our @EXPORT = qw( gettext );

my %language_handles;

sub get_language_handle {
    my $cgi = new CGI;
    my $language = C4::Languages::getlanguage;

    if (not exists $language_handles{$language}) {
        $language_handles{$language} = __PACKAGE__->get_handle($language)
            or die "No language handle for '$language'";
    }

    return $language_handles{$language};
}

sub gettext {
    my $lh = get_language_handle;
    $lh->maketext(@_);
}

1;
