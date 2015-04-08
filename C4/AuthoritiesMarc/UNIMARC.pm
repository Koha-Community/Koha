package C4::AuthoritiesMarc::UNIMARC;

# Copyright (C) 2007 LibLime
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
#use warnings; FIXME - Bug 2505
our $VERSION = 3.07.00.049;

=head1 NAME

C4::AuthoritiesMarc::UNIMARC

=head1 SYNOPSIS

use C4::AuthoritiesMarc::UNIMARC;

=head1 DESCRIPTION

This is a helper module providing functions used by
C<C4::AuthoritiesMarc> to deal with behavior specific
to UNIMARC authority records (as opposed to other
MARC formats).

Functions from this module generally should not be used
directly; instead, use the appropriate function from
C<C4::Authorities> that will dispatch the appropriate
function based on the marcflavour system preference.

=head1 FUNCTIONS

=cut

=head2 get_heading_type_from_marc

  my $auth_type = get_auth_type_from_marc($marc);

Given a MARC::Record object containing an authority record,
determine its heading type (e.g., personal name, topical term,
etc.).

=cut

=head2 default_auth_type_location

  my ($tag, $subfield) = default_auth_type_location();

Get the tag and subfield used to store the heading type
if not specified in the MARC framework.  For UNIMARC,
this defaults to 152$b.

=cut

sub default_auth_type_location {
    return ('152', 'b');
}

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com>

=cut

1;
