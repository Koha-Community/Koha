package Koha::Filter::MARC::ISBNTrim;

# Copyright 2016 Koha-Suomi Oy
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

=head1 SYNOPSIS

Move physical edition details from 020a to 020q

020a <ISBN> (nid.)

 =>

020a <ISBN>
020q (nid.)

=cut

use Modern::Perl;

use base qw(Koha::RecordProcessor::Base);
our $NAME = 'ISBNTrim';
our $VERSION = '1.0';

use Koha::Logger;
our $logger = Koha::Logger->get({category => __PACKAGE__});

=head2 filter

    my $newrecord = $filter->filter($record);
    my $newrecords = $filter->filter(\@records);

=cut

sub filter {
    my $self = shift;
    my $record = shift;
    my $newrecord;

    return unless defined $record;

    if (ref $record eq 'ARRAY') {
        my @recarray;
        foreach my $thisrec (@$record) {
            push @recarray, _processrecord($thisrec);
        }
        $newrecord = \@recarray;
    } elsif (ref $record eq 'MARC::Record') {
        $newrecord = _processrecord($record);
    }

    return $newrecord;
}

sub _processrecord {
    my $record = shift;

    my $biblionumber = $record->subfield('999', 'c');
    foreach my $field ( $record->field('020') ) {
        next if $field->is_control_field();

        my @sfs = $field->subfields();
        for (my $i=0 ; $i<scalar(@sfs) ; $i++) {
            my $sfC = $sfs[$i]->[0];
            my $sfV = $sfs[$i]->[1];
            next unless $sfC eq 'a';

            my $isbn; #Extract ISBN
            if ($sfV =~ s/^\s*(\d+-\d+-\d+-\d+-\d*X?)\s*//) { #ISBN 13
                $isbn = $1;
            }
            elsif ($sfV =~ s/^\s*(\d+-\d+-\d+-\d*X?)\s*//) { #ISBN 10
                $isbn = $1;
            }
            elsif ($sfV =~ s/^\s*(\d{9,12}[0-9X])\s*//) {
                $isbn = $1;
            }
            else {
                $logger->warn("ERROR: Unknown 020a '".$sfV."' for biblionumber '$biblionumber'\n") if $logger->is_warn();
                next();
            }

            my $remnant; #Check what the tail of 020a is made of
            if ($sfV) {
                $remnant = $sfV;
                $logger->warn("020a remnant '".$sfV."' for biblionumber '$biblionumber'\n") if $logger->is_warn();
            }

            if ($remnant) {
                $field->delete_subfield(code => $sfC, pos => $i);
                $field->add_subfields($sfC => $isbn);
                $field->delete_subfield(code => 'q');
                $field->add_subfields('q' => $remnant);
            }
        }
    }
    return $record;
}

1;
