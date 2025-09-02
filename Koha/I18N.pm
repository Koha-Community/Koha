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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use base 'Exporter';
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

our @EXPORT_OK = qw(
    available_locales
);

use C4::Languages;
use C4::Context;

use Encode;
use List::Util       qw( first );
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

our $textdomain = 'Koha';

=head1 NAME

Koha::I18N - Internationalization functions for Koha

=head1 SYNOPSIS

    use Koha::I18N;

    # Basic translation functions
    my $translated = __('Hello world');
    my $with_vars = __x('Hello {name}', name => 'World');
    my $plural = __n('one item', '{count} items', $count, count => $count);

    # Context-aware translations
    my $context = __p('menu', 'File');

    # Get available system locales (explicitly imported)
    use Koha::I18N qw(available_locales);
    my $locales = available_locales();

=head1 DESCRIPTION

This module provides internationalization (i18n) functions for Koha using the
GNU gettext system. It handles locale setup, message translation, and provides
utility functions for working with system locales.

The module automatically initializes the locale environment and provides a set
of translation functions that support variable substitution, plural forms, and
contextual translations.

=head1 FUNCTIONS

=head2 init

Initializes the internationalization system by setting up locale environment
variables and configuring gettext. This is called automatically when needed.

=cut

sub init {
    my $cache     = Koha::Cache::Memory::Lite->get_instance();
    my $cache_key = 'i18n:initialized';
    unless ( $cache->get_from_cache($cache_key) ) {
        my @system_locales = grep { chomp; not( /^C/ || $_ eq 'POSIX' ) } qx/locale -a/;
        if (@system_locales) {

            # LANG needs to be set to a valid locale,
            # otherwise LANGUAGE is ignored
            $ENV{LANG} = $system_locales[0];
            POSIX::setlocale( LC_MESSAGES, '' );

            my $langtag = C4::Languages::getlanguage;
            my @subtags = split /-/, $langtag;
            my ( $language, $region ) = @subtags;
            if ( $region && length $region == 4 ) {
                $region = $subtags[2];
            }
            my $locale = $language;
            if ($region) {
                $locale .= '_' . $region;
            }

            $ENV{LANGUAGE}       = $locale;
            $ENV{OUTPUT_CHARSET} = 'UTF-8';

            my $directory = _base_directory();
            textdomain($textdomain);
            bindtextdomain( $textdomain, $directory );
        } else {
            warn "No locale installed. Localization cannot work and is therefore disabled";
        }

        $cache->set_in_cache( $cache_key, 1 );
    }
}

=head2 __

    my $translated = __('Text to translate');

Basic translation function. Returns the translated text for the given message ID.

=cut

sub __ {
    my ($msgid) = @_;

    $msgid = Encode::encode_utf8($msgid);

    return _gettext( \&gettext, [$msgid] );
}

=head2 __x

    my $translated = __x('Hello {name}', name => 'World');

Translation with variable substitution. Variables in {brackets} are replaced
with the corresponding values from the provided hash.

=cut

sub __x {
    my ( $msgid, %vars ) = @_;

    $msgid = Encode::encode_utf8($msgid);

    return _gettext( \&gettext, [$msgid], %vars );
}

=head2 __n

    my $translated = __n('one item', '{count} items', $count);

Plural-aware translation. Returns singular or plural form based on the count.

=cut

sub __n {
    my ( $msgid, $msgid_plural, $count ) = @_;

    $msgid        = Encode::encode_utf8($msgid);
    $msgid_plural = Encode::encode_utf8($msgid_plural);

    return _gettext( \&ngettext, [ $msgid, $msgid_plural, $count ] );
}

=head2 __nx

    my $translated = __nx('one item', '{count} items', $count, count => $count);

Plural-aware translation with variable substitution.

=cut

sub __nx {
    my ( $msgid, $msgid_plural, $count, %vars ) = @_;

    $msgid        = Encode::encode_utf8($msgid);
    $msgid_plural = Encode::encode_utf8($msgid_plural);

    return _gettext( \&ngettext, [ $msgid, $msgid_plural, $count ], %vars );
}

=head2 __xn

Alias for __nx.

=cut

sub __xn {
    return __nx(@_);
}

=head2 __p

    my $translated = __p('context', 'Text to translate');

Context-aware translation. Allows the same text to be translated differently
based on context (e.g., 'File' in a menu vs 'File' as a document type).

=cut

sub __p {
    my ( $msgctxt, $msgid ) = @_;

    $msgctxt = Encode::encode_utf8($msgctxt);
    $msgid   = Encode::encode_utf8($msgid);

    return _gettext( \&pgettext, [ $msgctxt, $msgid ] );
}

=head2 __px

    my $translated = __px('context', 'Hello {name}', name => 'World');

Context-aware translation with variable substitution.

=cut

sub __px {
    my ( $msgctxt, $msgid, %vars ) = @_;

    $msgctxt = Encode::encode_utf8($msgctxt);
    $msgid   = Encode::encode_utf8($msgid);

    return _gettext( \&pgettext, [ $msgctxt, $msgid ], %vars );
}

=head2 __np

    my $translated = __np('context', 'one item', '{count} items', $count);

Context-aware plural translation.

=cut

sub __np {
    my ( $msgctxt, $msgid, $msgid_plural, $count ) = @_;

    $msgctxt      = Encode::encode_utf8($msgctxt);
    $msgid        = Encode::encode_utf8($msgid);
    $msgid_plural = Encode::encode_utf8($msgid_plural);

    return _gettext( \&npgettext, [ $msgctxt, $msgid, $msgid_plural, $count ] );
}

=head2 __npx

    my $translated = __npx('context', 'one item', '{count} items', $count, count => $count);

Context-aware plural translation with variable substitution.

=cut

sub __npx {
    my ( $msgctxt, $msgid, $msgid_plural, $count, %vars ) = @_;

    $msgctxt      = Encode::encode_utf8($msgctxt);
    $msgid        = Encode::encode_utf8($msgid);
    $msgid_plural = Encode::encode_utf8($msgid_plural);

    return _gettext( \&npgettext, [ $msgctxt, $msgid, $msgid_plural, $count ], %vars );
}

=head2 N__

    my $msgid = N__('Text for later translation');

No-operation translation marker. Returns the original text unchanged but marks
it for extraction by translation tools.

=cut

sub N__ {
    return $_[0];
}

=head2 N__n

    my $msgid = N__n('singular', 'plural');

No-operation plural translation marker.

=cut

sub N__n {
    return $_[0];
}

=head2 N__p

    my $msgid = N__p('context', 'Text for later translation');

No-operation context translation marker.

=cut

sub N__p {
    return $_[1];
}

=head2 N__np

    my $msgid = N__np('context', 'singular', 'plural');

No-operation context plural translation marker.

=cut

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
        warn "The PO directory has not been found. There is a problem in your Koha installation.";
    }

    return $dir;
}

sub _gettext {
    my ( $sub, $args, %vars ) = @_;

    init();

    my $text = Encode::decode_utf8( $sub->(@$args) );
    if (%vars) {
        $text = _expand( $text, %vars );
    }

    return $text;
}

sub _expand {
    my ( $text, %vars ) = @_;

    my $re = join '|', map { quotemeta $_ } keys %vars;
    $text =~ s/\{($re)\}/defined $vars{$1} ? $vars{$1} : "{$1}"/ge;

    return $text;
}

=head2 available_locales

    my $locales = Koha::I18N::available_locales();

Returns an arrayref of available system locales for use in system preferences.

Each locale is a hashref with:
  - C<value>: The locale identifier (e.g., 'en_US.utf8', 'default')
  - C<text>: Human-readable description (e.g., 'English (United States) - en_US.utf8')

Always includes 'default' as the first option. Additional locales are detected
from the system using C<locale -a> and filtered for UTF-8 locales.

=cut

sub available_locales {
    my @available_locales = ();

    # Always include default option
    push @available_locales, {
        value => 'default',
        text  => 'Default Unicode collation'
    };

    # Get system locales using the same approach as init()
    my @system_locales = grep { chomp; not( /^C/ || $_ eq 'POSIX' ) } qx/locale -a/;

    my @filtered_locales = ();
    for my $locale (@system_locales) {

        # Filter for useful locales (UTF-8 ones and common patterns)
        if ( $locale =~ /^[a-z]{2}_[A-Z]{2}\.utf8?$/i || $locale =~ /^[a-z]{2}_[A-Z]{2}$/i ) {

            # Create friendly display names
            my $display_name = $locale;
            if ( $locale =~ /^([a-z]{2})_([A-Z]{2})/ ) {
                my %lang_names = (
                    'en' => 'English',
                    'fr' => 'French',
                    'de' => 'German',
                    'es' => 'Spanish',
                    'it' => 'Italian',
                    'pt' => 'Portuguese',
                    'nl' => 'Dutch',
                    'pl' => 'Polish',
                    'fi' => 'Finnish',
                    'sv' => 'Swedish',
                    'da' => 'Danish',
                    'no' => 'Norwegian',
                    'ru' => 'Russian',
                    'ja' => 'Japanese',
                    'zh' => 'Chinese',
                    'ar' => 'Arabic',
                    'hi' => 'Hindi'
                );
                my %country_names = (
                    'US' => 'United States',
                    'GB' => 'United Kingdom',
                    'FR' => 'France',
                    'DE' => 'Germany',
                    'ES' => 'Spain',
                    'IT' => 'Italy',
                    'PT' => 'Portugal',
                    'BR' => 'Brazil',
                    'NL' => 'Netherlands',
                    'PL' => 'Poland',
                    'FI' => 'Finland',
                    'SE' => 'Sweden',
                    'DK' => 'Denmark',
                    'NO' => 'Norway',
                    'RU' => 'Russia',
                    'JP' => 'Japan',
                    'CN' => 'China',
                    'TW' => 'Taiwan',
                    'SA' => 'Saudi Arabia',
                    'IN' => 'India'
                );
                my $lang    = $lang_names{$1}    || uc($1);
                my $country = $country_names{$2} || $2;
                $display_name = "$lang ($country) - $locale";
            }
            push @filtered_locales, {
                value => $locale,
                text  => $display_name
            };
        }
    }

    # Sort locales by display name and add to available list
    @filtered_locales = sort { $a->{text} cmp $b->{text} } @filtered_locales;
    push @available_locales, @filtered_locales;

    return \@available_locales;
}

=head1 AUTHOR

Koha Development Team

=head1 COPYRIGHT

Copyright 2012-2014 BibLibre

=head1 LICENSE

This file is part of Koha.

Koha is free software; you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later
version.

=cut

1;
