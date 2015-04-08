#!/usr/bin/perl

# Copyright (C) 2010 Galen Charlton
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

=head1 NAME

show-template-structure.pl

=head1 DESCRIPTION

This script displays the structure of loops and conditional statements
in an L<HTML::Template::Pro> template, and is an aid for debugging errors
reported by the xt/author/valid-templates.t test.  It also identifies
the following errors:

=over 2

=item * TMPL_IF/TMPL_UNLESS/TMPL_LOOP with no closing tag

=item * TMPL_ELSE with no initial TMPL_IF or TMPL_UNLESS

=item * extra closing tags

=item * HTML comment of the form <!-- TMPL_FOO ..., where TMPL_FOO is not a valid L<HTML::Template::Pro> tag

=back

=head2 USAGE

=over 4

xt/author/show-template-structure.pl path/to/template.tt

=back

Output is sent to STDOUT.

=cut

scalar(@ARGV) == 1 or die "Usage: $0 template-file\n";
my $file = $ARGV[0];
open IN, $file or die "Failed to open template file $file: $!\n";

my %valid_tmpl_tags = (
    tmpl_var     => 1,
    tmpl_if      => 1,
    tmpl_unless  => 1,
    tmpl_else    => 1,
    tmpl_elsif   => 1,
    tmpl_include => 1,
    tmpl_loop    => 1,
);

my %tmpl_structure_tags = (
    tmpl_if     => 1,    # hash value controls whether to push/pop from the tag stack
    tmpl_else   => 0,
    tmpl_elsif  => 0,
    tmpl_unless => 1,
    tmpl_loop   => 1,
);

my $lineno = 0;

my @tag_stack = ();

sub emit {

    # print message with indentation
    my $level = scalar(@tag_stack);
    print "  " x ( $level - 1 ), shift;
}

while (<IN>) {
    $lineno++;

    # look for TMPL_IF, TMPL_ELSE, TMPL_UNLESS, and TMPL_LOOPs in HTML comments
    # this makes the assumption that these control statements are never
    # spread across multiple lines
    foreach my $comment (/<!-- (.*?) -->/g) {

        my $norm_comment = lc $comment;
        $norm_comment =~ s/^\s+//;
        next unless $norm_comment =~ m!^/{0,1}tmpl_!;
        my ( $tmpl_tag_close, $tmpl_tag ) = $norm_comment =~ m!^(/{0,1})(tmpl_\S+)!;
        $tmpl_tag_close = "" unless defined $tmpl_tag_close;

        unless ( exists $valid_tmpl_tags{$tmpl_tag} ) {
            print "ERROR (line $lineno): $tmpl_tag is not a valid HTML::Template::Pro tag\n";
        }
        next unless exists $tmpl_structure_tags{$tmpl_tag};    # only care about tags that affect loop or conditional structure
        if ( $tmpl_structure_tags{$tmpl_tag} ) {

            # we'll either be pushing or popping the tag stack
            if ($tmpl_tag_close) {

                # popping tag
                emit "${tmpl_tag_close}${tmpl_tag} (line $lineno)";
                if ( scalar(@tag_stack) < 1 ) {
                    print "\nERROR (line $lineno): $tmpl_tag causes tag stack underflow\n";
                } else {
                    my ( $popped_tag, $target, $popped_lineno ) = @{ pop @tag_stack };
                    if ( $tmpl_tag ne $popped_tag ) {
                        print "\nERROR (line $lineno): got /$tmpl_tag but expected /$popped_tag to", 
                              " match $popped_tag from line $popped_lineno\n";
                    } else {
                        print " # $target from $popped_lineno\n";
                    }
                }
            } elsif ( $tmpl_structure_tags{$tmpl_tag} ) {

                # pushable tag
                my ($target) = $comment =~ /(?:EXPR|NAME)\s*=\s*['"](.*?)['"]/i;
                push @tag_stack, [ $tmpl_tag, $target, $lineno ];
                emit "${tmpl_tag_close}${tmpl_tag} ($target, line $lineno)\n";
            }
        } else {

            # we're either a tmpl_else or tmpl_elsif, so make sure that
            # top of stack contains a tmpl_if
            emit "${tmpl_tag_close}${tmpl_tag} (line $lineno)\n";
            if ( scalar @tag_stack < 1 ) {
                print "ERROR: found $tmpl_tag, but tag stack is empty.\n";
            } else {
                my ( $peeked_tag, $target, $peeked_lineno ) = @{ $tag_stack[0] };
                if ( $peeked_tag ne "tmpl_if" and $peeked_tag ne "tmpl_unless" ) {
                    print "ERROR: found $tmpl_tag, but it does not appear to match a tmpl_if.  Top of stack is $peeked_tag.\n";
                }
            }
        }
    }
}

close IN;

# anything left in the stack?
if (scalar @tag_stack > 0) {
    print "ERROR: tag stack is not empty - the following template structures have not been closed:\n";
    my $i = 0;
    while (my $entry = pop @tag_stack) {
        $i++;
        my ( $popped_tag, $target, $popped_lineno ) = @{ $entry };
        print "$i: $popped_tag $target (line $popped_lineno)\n";
    }
}

exit 0;

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Galen Charlton <gmcharlt@gmail.com>

=cut
