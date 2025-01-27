package Koha::Template::Plugin::I18N;

# Copyright BibLibre 2015
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

use Modern::Perl;

use base qw( Template::Plugin );

use C4::Context;
use Koha::I18N qw( __ __n __np __npx __nx __p __px __x __xn );

=head1 NAME

Koha::Template::Plugin::I18N - Translate strings in templates

=head1 SYNOPSIS

    [% PROCESS 'i18n.inc' %]

    . . .

    [% I18N.t("Hello!") %]
    [% I18N.tx("Hello {name}", { name = name }) %]
    [% I18N.tn("Hello friend", "Hello friends", count) %]
    [% I18N.tnx("Hello my {count} friend", "Hello my {count} friends", count, { count = count }) %]
    [% I18N.tp('verb', 'Item') # to order %]
    [% I18N.tnp('bibliographic material', "item", "items", count) %]
    [% I18N.tnpx('bibliographic material', "{count} item", "{count} items", count, { count = count }) %]

Do not use this plugin directly. Add the following directive

    [% PROCESS 'i18n.inc' %]

and use the macros defined.

See: https://wiki.koha-community.org/wiki/Internationalization,_plural_forms,_context,_and_more_(RFC)
for further context.

=head1 METHODS

=head2 t

    [% I18N.t("hello") %]

Translate - The simplest type of translatable string where
there are no variables and not pluralisations to consider.

=cut

sub t {
    my ( $self, $msgid ) = @_;
    return __($msgid);
}

=head2 tx

    [% I18N.tx("hello {name}", { name = name }) %]

Translate with variable - A translatable string that
includes a variable

=cut

sub tx {
    my ( $self, $msgid, $vars ) = @_;
    return __x( $msgid, %$vars );
}

=head2 tn

    [% I18N.tn("item", "items", count) %]

Translate with plural - A translatable string that needs
singular and plural forms

=cut

sub tn {
    my ( $self, $msgid, $msgid_plural, $count ) = @_;
    return __n( $msgid, $msgid_plural, $count );
}

=head2 tnx

    [% I18N.tnx("{count} item", "{count} items", count, { count = count }) %]

Translate with plural and variable - A translatable string
that needs singular and plural forms and includes a variable

=cut

sub tnx {
    my ( $self, $msgid, $msgid_plural, $count, $vars ) = @_;
    return __nx( $msgid, $msgid_plural, $count, %$vars );
}

=head2 txn

Alias of tnx

=cut

sub txn {
    my ( $self, $msgid, $msgid_plural, $count, $vars ) = @_;
    return __xn( $msgid, $msgid_plural, $count, %$vars );
}

=head2 tp

    [% I18N.tp("context", "hello") %]

Translate with context - A translatable string where a
context hint would be helpful to translators.

An example would be where in english a single word may be
be used as both a verb and a noun. You may want to add a
note to distinguish this particular use case so translators
can understand the context correctly.

=cut

sub tp {
    my ( $self, $msgctxt, $msgid ) = @_;
    return __p( $msgctxt, $msgid );
}

=head2 tpx

    [% I18N.tpx("context", "hello {name}", { name = name }) %]

Translate with context and variable - A translatable string
that needs both a contextual hint and includes a variable.

=cut

sub tpx {
    my ( $self, $msgctxt, $msgid, $vars ) = @_;
    return __px( $msgctxt, $msgid, %$vars );
}

=head2 tnp

    [% I18N.tnp("context", "item", "items", count) %]

Translate with context and plural - A translatable string
that needs both a contextual hints and singular and plural
forms.

=cut

sub tnp {
    my ( $self, $msgctxt, $msgid, $msgid_plural, $count ) = @_;
    return __np( $msgctxt, $msgid, $msgid_plural, $count );
}

=head2 tnpx

    [% I18N.tnpx("context", "{count} item", "{count} items", count, { count = count }) %]

Translate with context, plural and variables - A translatable
string that needs contextual hints, singular and plural forms
and also includes variables.

=cut

sub tnpx {
    my ( $self, $msgctxt, $msgid, $msgid_plural, $count, $vars ) = @_;
    return __npx( $msgctxt, $msgid, $msgid_plural, $count, %$vars );
}

1;
