package Koha::Regex::Replacement;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

=head1 NAME

Koha::Regex::Replacement - expand a regular-expression replacement string as data

=head1 SYNOPSIS

    use Koha::Regex::Replacement;

    if ( $value =~ /$search/ ) {
        my $text = Koha::Regex::Replacement::expand_template(
            $replacement,      # the user-supplied replacement string
            [ @{^CAPTURE} ],   # numbered capture groups from the match ($1 is element 0)
            { %+ },            # named capture groups from the match
        );
    }

=head1 DESCRIPTION

Koha lets staff run regular-expression find and replace over MARC fields, item
fields and call numbers. The replacement half of those substitutions used to be
run through Perl's C<s///ee>, which evaluated the replacement as Perl code and
so allowed arbitrary code execution (see bug 30233).

This module expands the replacement string as B<data> instead of evaluating it.
It walks the string once, from left to right, and only acts on the handful of
placeholders a replacement legitimately contains:

=over

=item * numbered backreferences: C<$1> .. C<$n>, C<${n}>, and the older
        C<\1> .. C<\9> form

=item * named captures: C<$+{name}> and C<${name}>

=item * the escapes C<\n>, C<\r> and C<\t>, plus C<\\> and C<\$> for a literal
        backslash or dollar sign

=back

Every other character is copied through unchanged. Because the string is never
evaluated, interpolation blocks such as C<@{[ ... ]}> and C<${ ... }> end up in
the output as ordinary text rather than being run as Perl.

Case-folding escapes (C<\U>, C<\L>, C<\u>, C<\l>, C<\E>) are deliberately left
out. They are a display nicety rather than a requirement, and omitting them
keeps this routine small and easy to follow. They can be added later if a real
call-number or MARC workflow turns out to need them.

=head1 FUNCTIONS

=head2 expand_template

    my $text = Koha::Regex::Replacement::expand_template( $replacement, \@captures, \%named_captures );

Returns C<$replacement> with the placeholders listed above resolved. Numbered
backreferences are looked up in C<\@captures> (element 0 is group 1, matching
C<@{^CAPTURE}>) and named captures in C<\%named_captures> (matching C<%+>). A
reference to a group that did not match, or to a name that is not present,
expands to the empty string. The input is treated purely as data and is never
run as code.

=cut

sub expand_template {
    my ( $replacement, $captures, $named_captures ) = @_;
    $captures       //= [];
    $named_captures //= {};

    my $output     = '';
    my @characters = split //, $replacement;
    my $position   = 0;

    while ( $position < @characters ) {
        my $character = $characters[$position];

        # Backslash escapes: \n \r \t, the legacy \1 .. \9 backreference, and
        # \\ or \$ for a literal backslash or dollar. Any other \X is emitted as
        # a literal X, so a stray backslash can never introduce executable syntax.
        if ( $character eq '\\' && $position + 1 < @characters ) {
            my $escaped = $characters[ $position + 1 ];

            if    ( $escaped eq 'n' )     { $output .= "\n"; }
            elsif ( $escaped eq 'r' )     { $output .= "\r"; }
            elsif ( $escaped eq 't' )     { $output .= "\t"; }
            elsif ( $escaped =~ /[1-9]/ ) {                    # legacy \1 .. \9 backreference
                my $group_value = $captures->[ $escaped - 1 ];
                $output .= defined $group_value ? $group_value : '';
            }
            else {                                             # \\ -> \, \$ -> $, any other \X -> X
                $output .= $escaped;
            }

            $position += 2;
            next;
        }

        if ( $character eq '$' ) {

            # ${name} or ${number}: read up to the closing brace, then treat a
            # number as a positional group and anything else as a named group.
            if ( $position + 1 < @characters && $characters[ $position + 1 ] eq '{' ) {
                my $scan = $position + 2;
                my $name = '';
                $name .= $characters[ $scan++ ] while $scan < @characters && $characters[$scan] ne '}';

                if ( $scan < @characters ) {    # found the closing brace
                    if ( $name =~ /^[0-9]+\z/ ) {
                        my $group_value = $name >= 1 ? $captures->[ $name - 1 ] : undef;
                        $output .= defined $group_value ? $group_value : '';
                    } else {
                        my $named_value = $named_captures->{$name};
                        $output .= defined $named_value ? $named_value : '';
                    }
                    $position = $scan + 1;
                    next;
                }

                # An unterminated ${ : emit the dollar literally and carry on.
                $output .= '$';
                $position += 1;
                next;
            }

            # $+{name}: a named capture written with the %+ syntax.
            if (   $position + 2 < @characters
                && $characters[ $position + 1 ] eq '+'
                && $characters[ $position + 2 ] eq '{' )
            {
                my $scan = $position + 3;
                my $name = '';
                $name .= $characters[ $scan++ ] while $scan < @characters && $characters[$scan] ne '}';

                if ( $scan < @characters ) {
                    my $named_value = $named_captures->{$name};
                    $output .= defined $named_value ? $named_value : '';
                    $position = $scan + 1;
                    next;
                }

                $output .= '$';
                $position += 1;
                next;
            }

            # $1 .. $n: a plain numbered backreference (a run of digits after $).
            if ( $position + 1 < @characters && $characters[ $position + 1 ] =~ /[0-9]/ ) {
                my $scan         = $position + 1;
                my $group_number = '';
                $group_number .= $characters[ $scan++ ] while $scan < @characters && $characters[$scan] =~ /[0-9]/;

                my $group_value = $group_number >= 1 ? $captures->[ $group_number - 1 ] : undef;
                $output .= defined $group_value ? $group_value : '';
                $position = $scan;
                next;
            }

            # A lone $ that is not a backreference is a literal dollar sign.
            $output .= '$';
            $position += 1;
            next;
        }

        # Anything that is not a recognised placeholder is copied verbatim.
        $output .= $character;
        $position += 1;
    }

    return $output;
}

1;
