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

use C4::Languages;
use C4::Context;

use Encode;
use List::Util qw( first );
use Locale::Messages qw(
    bindtextdomain
    gettext
    LC_MESSAGES
    ngettext
    npgettext
    pgettext
    textdomain
);
use POSIX qw();
use Koha::Cache::Memory::Lite;

use parent 'Exporter';
our @EXPORT = qw(
    __
    __x
    __n
    __nx
    __xn
    __p
    __px
    __np
    __npx
    N__
    N__n
    N__p
    N__np
);

our $textdomain = 'Koha';

sub init {
    my $cache = Koha::Cache::Memory::Lite->get_instance();
    my $cache_key = 'i18n:initialized';
    unless ($cache->get_from_cache($cache_key)) {
        my @system_locales = grep { chomp; not (/^C/ || $_ eq 'POSIX') } qx/locale -a/;
        if (@system_locales) {
            # LANG needs to be set to a valid locale,
            # otherwise LANGUAGE is ignored
            $ENV{LANG} = $system_locales[0];
            POSIX::setlocale(LC_MESSAGES, '');

            my $langtag = C4::Languages::getlanguage;
            my @subtags = split /-/, $langtag;
            my ($language, $region) = @subtags;
            if ($region && length $region == 4) {
                $region = $subtags[2];
            }
            my $locale = $language;
            if ($region) {
                $locale .= '_' . $region;
            }

            $ENV{LANGUAGE} = $locale;
            $ENV{OUTPUT_CHARSET} = 'UTF-8';

            my $directory = _base_directory();
            textdomain($textdomain);
            bindtextdomain($textdomain, $directory);
        } else {
            warn "No locale installed. Localization cannot work and is therefore disabled";
        }

        $cache->set_in_cache($cache_key, 1);
    }
}

sub __ {
    my ($msgid) = @_;

    $msgid = Encode::encode_utf8($msgid);

    return _gettext(\&gettext, [ $msgid ]);
}

sub __x {
    my ($msgid, %vars) = @_;

    $msgid = Encode::encode_utf8($msgid);

    return _gettext(\&gettext, [ $msgid ], %vars);
}

sub __n {
    my ($msgid, $msgid_plural, $count) = @_;

    $msgid = Encode::encode_utf8($msgid);
    $msgid_plural = Encode::encode_utf8($msgid_plural);

    return _gettext(\&ngettext, [ $msgid, $msgid_plural, $count ]);
}

sub __nx {
    my ($msgid, $msgid_plural, $count, %vars) = @_;

    $msgid = Encode::encode_utf8($msgid);
    $msgid_plural = Encode::encode_utf8($msgid_plural);

    return _gettext(\&ngettext, [ $msgid, $msgid_plural, $count ], %vars);
}

sub __xn {
    return __nx(@_);
}

sub __p {
    my ($msgctxt, $msgid) = @_;

    $msgctxt = Encode::encode_utf8($msgctxt);
    $msgid = Encode::encode_utf8($msgid);

    return _gettext(\&pgettext, [ $msgctxt, $msgid ]);
}

sub __px {
    my ($msgctxt, $msgid, %vars) = @_;

    $msgctxt = Encode::encode_utf8($msgctxt);
    $msgid = Encode::encode_utf8($msgid);

    return _gettext(\&pgettext, [ $msgctxt, $msgid ], %vars);
}

sub __np {
    my ($msgctxt, $msgid, $msgid_plural, $count) = @_;

    $msgctxt = Encode::encode_utf8($msgctxt);
    $msgid = Encode::encode_utf8($msgid);
    $msgid_plural = Encode::encode_utf8($msgid_plural);

    return _gettext(\&npgettext, [ $msgctxt, $msgid, $msgid_plural, $count ]);
}

sub __npx {
    my ($msgctxt, $msgid, $msgid_plural, $count, %vars) = @_;

    $msgctxt = Encode::encode_utf8($msgctxt);
    $msgid = Encode::encode_utf8($msgid);
    $msgid_plural = Encode::encode_utf8($msgid_plural);

    return _gettext(\&npgettext, [ $msgctxt, $msgid, $msgid_plural, $count], %vars);
}

sub N__ {
    return $_[0];
}

sub N__n {
    return $_[0];
}

sub N__p {
    return $_[1];
}

sub N__np {
    return $_[1];
}

sub _base_directory {
    # Directory structure is not the same for dev and standard installs
    # Here we test the existence of several directories and use the first that exist
    # FIXME There has to be a better solution
    my @dirs = (
        C4::Context->config('intranetdir') . '/misc/translator/po',
        C4::Context->config('intranetdir') . '/../../misc/translator/po',
    );
    my $dir = first { -d } @dirs;

    unless ($dir) {
        die "The PO directory has not been found. There is a problem in your Koha installation.";
    }

    return $dir;
}

sub _gettext {
    my ($sub, $args, %vars) = @_;

    init();

    my $text = Encode::decode_utf8($sub->(@$args));
    if (%vars) {
        $text = _expand($text, %vars);
    }

    return $text;
}

sub _expand {
    my ($text, %vars) = @_;

    my $re = join '|', map { quotemeta $_ } keys %vars;
    $text =~ s/\{($re)\}/defined $vars{$1} ? $vars{$1} : "{$1}"/ge;

    return $text;
}

1;
