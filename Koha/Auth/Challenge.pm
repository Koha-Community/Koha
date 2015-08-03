package Koha::Auth::Challenge;

# Copyright 2015 Vaara-kirjastot
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

=head1 NAME Koha::Auth::Challenge

=head2 SYNOPSIS

This is a authentication challenge parent class.
All Challenge-objects must implement the challenge()-method.

=head SUBLASSING

package Koha::Auth::Challenge::YetAnotherChallenge;

use base qw('Koha::Auth::Challenge');

sub challenge {
    #Implement the parent method to make this subclass interoperable.
}

=head2 USAGE

    use Scalar::Util qw(blessed);
    try {
        ...
        Koha::Auth::Challenge::Version::challenge();
        Koha::Auth::Challenge::OPACMaintenance::challenge();
        Koha::Auth::Challenge::YetAnotherChallenge::challenge();
        ...
    } catch {
        if (blessed($_)) {
            if ($_->isa('Koha::Exception::VersionMismatch')) {
                ##handle exception
            }
            elsif ($_->isa('Koha::Exception::AnotherKindOfException')) {
                ...
            }
            ...
            else {
                warn "Unknown exception class ".ref($_)."\n";
                die $_; #Unhandled exception case
            }
        }
        else {
            die $_; #Not a Koha::Exception-object
        }
    };

=cut

sub challenge {
    #@OVERLOAD this "interface"
    warn caller()." doesn't implement challenge()\n";
}

1;
