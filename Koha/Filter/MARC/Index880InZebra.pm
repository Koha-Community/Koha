package Koha::Filter::MARC::Index880InZebra;

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

Koha::Filter::MARC::Index880InZebra - replace 880 with its linked field number
so that the alternate graphic representation gets indexed appropriately
(see Koha::SearchEngine::Elasticsearch for the ES version)

=head1 SYNOPSIS

  my $processor = Koha::RecordProcessor->new({ filters => ('Index880InZebra') });

=head1 DESCRIPTION

Filter to rewrite 880 to linked field

=cut

use Modern::Perl;

use C4::Context;

use base qw(Koha::RecordProcessor::Base);
our $NAME = 'Index880InZebra';

our $marcflavour = lc C4::Context->preference('marcflavour');

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
    if ($marcflavour && $marcflavour eq 'marc21'){
        my @fields = $record->field('880');
        foreach my $field (@fields){
            my $sub6 = $field->subfield('6');
            if ($sub6 =~ /^(...)-\d+/) {
                my $tag = $1;
                if ($tag){
                    $field->set_tag($tag);
                }
            }
        }
    }
    return $record;
}

1;
