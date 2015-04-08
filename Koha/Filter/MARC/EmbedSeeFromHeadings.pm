package Koha::Filter::MARC::EmbedSeeFromHeadings;

# Copyright 2012 C & P Bibliography Services
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

=head1 NAME

Koha::Filter::MARC::EmbedSeeFromHeadings - embeds see from headings into MARC for indexing

=head1 SYNOPSIS


=head1 DESCRIPTION

Filter to embed see from headings into MARC records.

=cut

use strict;
use warnings;
use Carp;
use Koha::Authority;

use base qw(Koha::RecordProcessor::Base);
our $NAME = 'EmbedSeeFromHeadings';
our $VERSION = '1.0';

=head2 filter

    my $newrecord = $filter->filter($record);
    my $newrecords = $filter->filter(\@records);

Embed see from headings into the specified record(s) and return the result.
In order to differentiate added headings from actual headings, a 'z' is
put in the first indicator.

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

    foreach my $field ( $record->fields() ) {
        next if $field->is_control_field();
        my $authid = $field->subfield('9');

        next unless $authid;

        my $authority = Koha::Authority->get_from_authid($authid);
        next unless $authority;
        my $auth_marc = $authority->record;
        my @seefrom = $auth_marc->field('4..');
        my @newfields;
        foreach my $authfield (@seefrom) {
            my $tag = substr($field->tag(), 0, 1) . substr($authfield->tag(), 1, 2);
            next if MARC::Field->is_controlfield_tag($tag);
            my $newfield = MARC::Field->new($tag,
                    'z',
                    $authfield->indicator(2) || ' ',
                    '9' => '1');
            foreach my $sub ($authfield->subfields()) {
                my ($code,$val) = @$sub;
                $newfield->add_subfields( $code => $val );
            }
            $newfield->delete_subfield( code => '9' );
            push @newfields, $newfield if (scalar($newfield->subfields()) > 0);
        }
        $record->append_fields(@newfields);
    }
    return $record;
}
