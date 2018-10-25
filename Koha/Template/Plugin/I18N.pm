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
use Koha::I18N;

=head1 NAME

Koha::Template::Plugin::I18N - Translate strings in templates

=head1 SYNOPSIS

Do not use this plugin directly. Add the following directive

    [% PROCESS 'i18n.inc' %]

and use the macros defined here

=head1 METHODS

=head2 t

    [% I18N.t("hello") %]

=cut

sub t {
    my ($self, $msgid) = @_;
    return __($msgid);
}

=head2 tx

    [% I18N.tx("hello {name}", { name = name }) %]

=cut

sub tx {
    my ($self, $msgid, $vars) = @_;
    return __x($msgid, %$vars);
}

=head2 tn

    [% I18N.tn("item", "items", count) %]

=cut

sub tn {
    my ($self, $msgid, $msgid_plural, $count) = @_;
    return __n($msgid, $msgid_plural, $count);
}

=head2 tnx

    [% I18N.tnx("{count} item", "{count} items", count, { count = count }) %]

=cut

sub tnx {
    my ($self, $msgid, $msgid_plural, $count, $vars) = @_;
    return __nx($msgid, $msgid_plural, $count, %$vars);
}

=head2 txn

Alias of tnx

=cut

sub txn {
    my ($self, $msgid, $msgid_plural, $count, $vars) = @_;
    return __xn($msgid, $msgid_plural, $count, %$vars);
}

=head2 tp

    [% I18N.tp("context", "hello") %]

=cut

sub tp {
    my ($self, $msgctxt, $msgid) = @_;
    return __p($msgctxt, $msgid);
}

=head2 tpx

    [% I18N.tpx("context", "hello {name}", { name = name }) %]

=cut

sub tpx {
    my ($self, $msgctxt, $msgid, $vars) = @_;
    return __px($msgctxt, $msgid, %$vars);
}

=head2 tnp

    [% I18N.tnp("context", "item", "items") %]

=cut

sub tnp {
    my ($self, $msgctxt, $msgid, $msgid_plural, $count) = @_;
    return __np($msgctxt, $msgid, $msgid_plural, $count);
}

=head2 tnpx

    [% I18N.tnpx("context", "{count} item", "{count} items", { count = count }) %]

=cut

sub tnpx {
    my ($self, $msgctxt, $msgid, $msgid_plural, $count, $vars) = @_;
    return __np($msgctxt, $msgid, $msgid_plural, $count, %$vars);
}

1;
