package Koha::Installer::Output;

# Copyright 2024 Koha Development Team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Exporter        qw(import);
use Term::ANSIColor qw(:constants);

our @EXPORT_OK = qw(say_warning say_failure say_success say_info);

=head1 NAME

Koha::Installer::Output - Module to provide colored output for Koha installer

=head1 SYNOPSIS

  use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

  # Output messages with appropriate colors
  say_warning($fh, "This is a warning message");
  say_failure($fh, "This is a failure message");
  say_success($fh, "This is a success message");
  say_info($fh, "This is an info message");

=head1 DESCRIPTION

This module provides methods to output messages with appropriate colors for different types of messages:
warnings, failures, successes, and informational messages.

=head1 EXPORTS

The following functions can be exported upon request:

=over 4

=item * say_warning($fh, $msg)

Output a warning message in yellow.

=item * say_failure($fh, $msg)

Output a failure message in red.

=item * say_success($fh, $msg)

Output a success message in green.

=item * say_info($fh, $msg)

Output an informational message in blue.

=back

=cut

sub say_warning {
    my ( $fh, $msg ) = @_;

    if ($fh) {
        say $fh YELLOW, "$msg", RESET;
    } else {
        say YELLOW, "$msg", RESET;
    }
}

sub say_failure {
    my ( $fh, $msg ) = @_;

    if ($fh) {
        say $fh RED, "$msg", RESET;
    } else {
        say RED, "$msg", RESET;
    }
}

sub say_success {
    my ( $fh, $msg ) = @_;

    if ($fh) {
        say $fh GREEN, "$msg", RESET;
    } else {
        say GREEN, "$msg", RESET;
    }
}

sub say_info {
    my ( $fh, $msg ) = @_;

    if ($fh) {
        say $fh BLUE, "$msg", RESET;
    } else {
        say BLUE, "$msg", RESET;
    }
}

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
