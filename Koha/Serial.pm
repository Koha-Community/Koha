package Koha::Serial;

# Copyright ByWater Solutions 2015
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Serial - Koha Serial Object class

=head1 API

=head2 Class Methods

=cut

=head3 update_patterns_xyz

=cut

sub update_patterns_xyz {
    my ($self, $params) = @_;
    my $verbose = $params->{verbose};
    my $serialSequenceSplitter = $params->{serialSequenceSplitterRegexp};

    sub trim {
        my $string = shift;
        $string =~ s/^\s*//;
        $string =~ s/\s*$//;
        return $string;
    }

    $self->set({
        serialseq_x => undef,
        serialseq_y => undef,
        serialseq_z => undef,
    })->store();

    my ($x, $y, $z);
    my @elem = split(/$serialSequenceSplitter/, $self->serialseq);
    if (1) {
        $x = $elem[0] ? trim($elem[0]) : '';
        $y = $elem[1] ? trim($elem[1]) : '';
        $z = $elem[2] ? trim($elem[2]) : '';
    }
    elsif ($self->serialseq =~ /^(\d+) ?: ?([-0-9A-Za-z]+) $/) {
        $x = $1;
        $y = $2;
        $z = $3;
    }
    elsif ($self->serialseq =~ /^(\d+) ?: ?([-0-9A-Za-z]*) ?:? ?(.*)/) {
        $x = $1;
        $y = $2;
        $z = $3;
    }
    else {
        print "Couldn't parse serialid '".$self->serialid."'s serialseq '"
                . $self->serialseq . "'\n" if $verbose;
    }

    if ($x && $y && $z) {
        $self->set({
            serialseq_x => $x,
            serialseq_y => $y,
            serialseq_z => $z,
        });
    }
    elsif ($x && $y) {
        $self->set({
            serialseq_x => $x,
            serialseq_y => $y,
        });
    }
    else {
        $self->set({
            serialseq_x => $x ? $x : undef,
        });
    }

    $self->store;

    if ($verbose) {
        print "UPDATE serialid '" . $self->serialid . "', '$x' '$y' '$z'\n";
    }

    return $self;
}

=head3 type

=cut

sub _type {
    return 'Serial';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
