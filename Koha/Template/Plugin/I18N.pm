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

sub t {
    my ($self, $msgid) = @_;
    return __($msgid);
}

sub tx {
    my ($self, $msgid, $vars) = @_;
    return __x($msgid, %$vars);
}

sub tn {
    my ($self, $msgid, $msgid_plural, $count) = @_;
    return __n($msgid, $msgid_plural, $count);
}

sub tnx {
    my ($self, $msgid, $msgid_plural, $count, $vars) = @_;
    return __nx($msgid, $msgid_plural, $count, %$vars);
}

sub txn {
    my ($self, $msgid, $msgid_plural, $count, $vars) = @_;
    return __xn($msgid, $msgid_plural, $count, %$vars);
}

sub tp {
    my ($self, $msgctxt, $msgid) = @_;
    return __p($msgctxt, $msgid);
}

sub tpx {
    my ($self, $msgctxt, $msgid, $vars) = @_;
    return __px($msgctxt, $msgid, %$vars);
}

sub tnp {
    my ($self, $msgctxt, $msgid, $msgid_plural, $count) = @_;
    return __np($msgctxt, $msgid, $msgid_plural, $count);
}

sub tnpx {
    my ($self, $msgctxt, $msgid, $msgid_plural, $count, $vars) = @_;
    return __np($msgctxt, $msgid, $msgid_plural, $count, %$vars);
}

1;
