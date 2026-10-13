package Koha::Script::Usage;

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

use parent 'Getopt::Long::Descriptive::Usage';

=head1 NAME

Koha::Script::Usage - Usage object returned by Koha::Script->describe_options

=head1 SYNOPSIS

    my ( $opt, $usage ) = Koha::Script->describe_options( ... );
    $usage->die( { pre_text => "Something is wrong.\n\n" } );

=head1 DESCRIPTION

A L<Getopt::Long::Descriptive::Usage> whose C<die> makes the script exit
with status 1, like C<pod2usage(1)> did, instead of whatever C<$!> happens
to be (see L<perlfunc/die>).

=head1 API

=head2 Class methods

=head3 die

    $usage->die( { pre_text => "...", post_text => "..." } );

Dies with the usage text, as L<Getopt::Long::Descriptive::Usage/die> does.
If the exception is not caught, the script exits with status 1.

=cut

sub die {
    my ( $self, @args ) = @_;

    set_exit_status();
    return $self->SUPER::die(@args);
}

=head3 set_exit_status

    Koha::Script::Usage::set_exit_status();
    die $message;

Makes the next uncaught C<die> exit with status 1. Perl uses C<$!> as the
exit status if it is not 0, then C<< $? >> 8 >>.

=cut

sub set_exit_status {
    $! = 0;
    $? = 1 << 8;
    return;
}

1;
