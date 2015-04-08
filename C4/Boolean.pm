package C4::Boolean;

#package to handle Boolean values in the parameters table
# Note: This is just a utility module; it should not be instantiated.


# Copyright 2003 Katipo Communications
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

use Carp;
use base qw(Exporter);

our    $VERSION = 3.07.00.049;
our    @EXPORT_OK = qw( true_p);

=head1 NAME

C4::Boolean - Convenience function to handle boolean values
in the parameter table

=head1 SYNOPSIS

  use C4::Boolean;

=head1 DESCRIPTION

In the parameter table, there are various Boolean values that
variously require a 0/1, no/yes, false/true, or off/on values.
This module aims to provide scripts a means to interpret these
Boolean values in a consistent way which makes common sense.

=head1 FUNCTIONS

=over 2

=cut

use constant INVALID_BOOLEAN_STRING_EXCEPTION =>
  q{The given value does not seem to be interpretable as a Boolean value};

our %strings = (
   '0'     => 0,    '1'     => 1,    # C
                    '-1'    => 1,    # BASIC
   'nil'   => 0,    't'     => 1,    # LISP
   'false' => 0,    'true'  => 1,    # Pascal
   'off'   => 0,    'on'    => 1,
   'no'    => 0,    'yes'   => 1,
   'n'     => 0,    'y'     => 1,
);

=item true_p

    if ( C4::Boolean::true_p(C4::Context->preference("IndependentBranches")) ) {
    ...
    }

Tries to interpret the passed string as a Boolean value. Returns
the value if the string can be interpreted as such; otherwise an
exception is thrown.

=cut

sub true_p  {
    my $x = shift;
    my $it;
    if (!defined $x || ref $x ) {
        carp INVALID_BOOLEAN_STRING_EXCEPTION;
        return;
    }
    $x = lc $x;
    $x =~ s/\s//g;
    if (defined $strings{$x}) {
        $it = $strings{$x};
    } else {
        carp INVALID_BOOLEAN_STRING_EXCEPTION;
    }
    return $it;
}

1;
__END__

=back

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut
