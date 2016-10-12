package C4::Biblio::Diff;

# Copyright KohaSuomi 2016
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
use Scalar::Util qw(blessed);
use Try::Tiny;

use C4::Biblio::Diff::Change;

use Koha::Exception::BadParameter;

=head SYNOPSIS

    Diff takes any amount of MARC::Records and produces a diff of all the MARC
    elements that are different in atleast one of the records.

=cut

=head new

    my $diff = C4::Biblio::Diff->new($params, @MARC::Records);

@PARAM1 HASHRef of options,
        'excludedFields' => ['999', '952', ...] #Which MARC::Fields to exclude from the comparison result
@PARAM2..n MARC::Record-objects to diff
@RETURNS C4::Biblio::Diff-object

=cut

sub new {
    my ($class, $params, @records) = @_;
    my $self = (ref($params) eq 'HASH') ? $params :  {};
    bless($self, $class);

    $self->{records} = [];
    foreach my $r (@records) {
        $self->addRecord($r);
    }
    if ($self->{excludedFields}) {
        $self->setExcludedFields( $self->{excludedFields} );
    }

    return $self;
}

=head addRecord

    $diff = $diff->addRecord($MARC::Record);

@PARAM1, MARC::Record-object.
@RETURNS C4::Biblio::Diff to chain commands
@THROWS Koha::Exception::BadParameter

=cut

sub addRecord {
    my ($self, $record) = @_;

    unless(blessed($record) && $record->isa('MARC::Record')) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."()> Param \$record '$record' is not a MARC::Record-object");
    }
    push(@{$self->{records}}, $record);
    return $self;
}

sub getRecords {
    return shift->{records};
}
sub getExcludedFields {
    return shift->{excludedFields};
}
sub setExcludedFields {
    my ($self, $excludedFields) = @_;
    unless(ref($excludedFields) eq 'ARRAY') {
        my @cc1 = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc1[3]." is trying to setExcludedFields, but the param \$excludedFields '$excludedFields' is not an ARRAYref.");
    }
    $self->{excludedFields} = {}; #Make a easy to search hash
    foreach my $f (@$excludedFields) {
        $self->{excludedFields}->{$f} = 1;
    }
    return $self;
}
sub isFieldExcluded {
    my ($self, $field) = @_;
    my $ef = $self->getExcludedFields();
    if ($ef && $ef->{$field}) {
        return 1;
    }
    return 0;
}

=head diffRecords

Generates a multitiered and parallel diff which lists all the changed MARC-(sub)fields
and indicators horizontally between any amount of given MARC::Records.

@PARAMS List of MARC::Records to be compared between each others for difference.
@RETURNS HASHmonster, depicting all the MARC elements where even one of the given MARC::Records differ from the others:
    {
        '001' => [
            '3243256',
            '10042',
            undef,
        ],
        '003' => [
            'VAARA',
            'LUMME',
            'KYYTI',
        ],
        '049' => [
            {
                '_i1' => [
                    ' ',
                    1,
                    undef,
                ],
                'a' => [
                    undef,
                    'K18',
                    undef,
                ],
                'b' => [
                    undef,
                    'YLE',
                    undef,
                ],
            },
        ],
        '245' => [
            {
                '_i2' => [
                    3,
                    undef,
                    1,
                ],
                'a' => [
                    'Rickshaw /',
                    'Rickshaw',
                    'Rickshaw',
                ],
            },
        ],
    }

=cut

sub diffRecords {
    my ($self) = @_;
    my $records = $self->getRecords();
    my %availableFields;
    my %fieldRepetitions;
    my %subfieldRepetitions;

    #collect all found fields and subfields to to a single stack.
    #Collect repetiton counts of fields and subfields.
    foreach my $r (@$records) {
        foreach my $f ($r->fields()) { #iterate fields
            next if $self->isFieldExcluded($f->tag());
            if ($f->is_control_field()) {
                $availableFields{$f->tag()} = 1;
            }
            else {
                $availableFields{$f->tag()} = {} unless($availableFields{$f->tag()});
                my $sfs = $availableFields{$f->tag()};

                my @fields = $r->field($f->tag());
                $fieldRepetitions{$f->tag()} = scalar(@fields) if(not($fieldRepetitions{$f->tag()}) || $fieldRepetitions{$f->tag()} < scalar(@fields));

                foreach my $sf ($f->subfields()) { #Iterate subfields
                    my @sfs = $f->subfield( $sf->[0] );
                    $subfieldRepetitions{ $f->tag().$sf->[0] } = scalar(@sfs) if(not($subfieldRepetitions{ $f->tag().$sf->[0] }) || $subfieldRepetitions{ $f->tag().$sf->[0] } < scalar(@sfs));
                    $sfs->{ $sf->[0] } = 1;
                }
            }
        }
    }

    my %diff;

    $self->diffLeaders(\%diff, $records);

    ##Iterate all found indicators, fields and subfields and diff between all given records
    #Remember that all fields and subfields can be repeated
    foreach my $fk (sort(keys(%availableFields))) { #Iterate fields

        if (int($fk) < 10) { #Control fields
            $self->diffControlFields(\%diff, $records, $fk);
        } #EO control field
        else { #Data fields
            my @fs;
            for(my $fi=0   ;   $fi<$fieldRepetitions{$fk}   ;   $fi++) { #Iterate field repetitions

                foreach my $i (1..2) { #Diff indicators
                    my @candidates;
                    for(my $ri=0 ; $ri<scalar(@$records) ; $ri++) {
                        my $r = $records->[$ri];
                        $fs[$ri] = [$r->field($fk)] unless $fs[$ri];

                        $candidates[$ri] = ($fs[$ri]->[$fi]) ? $fs[$ri]->[$fi]->indicator($i) : undef;
                    }
                    if (_valuesDiff(\@candidates)) {
                        $diff{$fk} = [] unless $diff{$fk};
                        $diff{$fk}->[$fi] = {} unless $diff{$fk}->[$fi];
                        $diff{$fk}->[$fi]->{"_i$i"} = \@candidates;
                    }
                } #EO indicators

                foreach my $sfk (sort(keys(%{$availableFields{$fk}}))) { #Iterate subfields
                    my @sfs;

                    for(my $sfi=0   ;   $sfi<$subfieldRepetitions{$fk.$sfk}   ;   $sfi++) { #Iterate subfield repetitions

                        my @candidates;
                        for(my $ri=0 ; $ri<scalar(@$records) ; $ri++) {
                            my $r = $records->[$ri];
                            $fs[$ri] = [$r->field($fk)] unless $fs[$ri];
                            $sfs[$ri] = [$fs[$ri]->[$fi]->subfield($sfk)] if (not($sfs[$ri]) && $fs[$ri]->[$fi]);

                            $candidates[$ri] = ($sfs[$ri]) ? $sfs[$ri]->[$sfi] : undef;
                        }
                        if (_valuesDiff(\@candidates)) {
                            $diff{$fk} = [] unless $diff{$fk};
                            $diff{$fk}->[$fi] = {} unless $diff{$fk}->[$fi];
                            $diff{$fk}->[$fi]->{$sfk} = [] unless $diff{$fk}->[$fi]->{$sfk};
                            $diff{$fk}->[$fi]->{$sfk}->[$sfi] = \@candidates;
                        }
                    } #EO subfield repetiton iterator
                } #EO subfields iterator
            } #EO Field repetiton iterator
        } #EO Data fields
    } #EO fields iterator

    $self->{diff} = \%diff;
    return $self->{diff};
}

sub diffLeaders {
    my ($self, $diff, $records) = @_;

    my @candidates;
    for(my $ri=0 ; $ri<scalar(@$records) ; $ri++) {
        my $r = $records->[$ri];
        $candidates[$ri] = $r->leader();
    }
    if (_valuesDiff(\@candidates)) {
        $diff->{'000'} = \@candidates;
    }
}

sub diffControlFields {
    my ($self, $diff, $records, $fieldTag) = @_;

    my @candidates;
    for(my $ri=0 ; $ri<scalar(@$records) ; $ri++) {
        my $r = $records->[$ri];
        my $field = $r->field($fieldTag);
        $candidates[$ri] = ($field) ? $field->data() : undef;
    }
    if (_valuesDiff(\@candidates)) {
        $diff->{$fieldTag} = \@candidates;
    }
}

=head _valuesDiff

    if ($diff->_valuesDiff($candidates)) {
        #Candidates do not match
    }
    else {
        #All candidates match
    }

TODO::This is a good point to change the similarity logic of this diff:ing tool if necessary.

@PARAM1 ARRAYref of Scalar-values, these are compared for similarity.
@RETURNS Boolean, true if values differ
                  false if they are the same
=cut

sub _valuesDiff {
    my ($candidates) = @_;
    for(my $i=1 ; $i<scalar(@$candidates) ; $i++) {
        #Normalize values for comparison
        my $prevValue = defined($candidates->[$i-1]) ? $candidates->[$i-1] : '';
        my $nextValue = defined($candidates->[$i])   ? $candidates->[$i] : '';

        if ($prevValue ne $nextValue) {
            return 1;
        }
    }
    return 0;
}

=head2 grepChangedElements

@PARAM1 HASHMonster from diffRecords()
@PARAM2 ARRAYRef of HASHRefs, the MARC field-subfield tuples to search for,
            [
                {
                    f => '084',
                    sf => 'a'
                },
                ...
            ]
@RETURNS Arrayref of Arrayrefs,
            [
                [
                    '084', #Field
                    'a',   #Subfield
                    'YKL', #Old value
                    'AKT'  #New value
                ],
                ...
            ]

=cut

sub grepChangedElements {
    my ($diff, $selectors) = @_;

    my @changes;

    foreach my $n (@$selectors) { #$n as in the "needle in the haystack"
        if (int($n->{f}) < 10) { #Control fields
            my $fieldDiffs = $diff->{$n->{f}};
            push(@changes, C4::Biblio::Diff::Change->new($n->{f}, $n->{sf}, @$fieldDiffs));
        }
        else { #Data fields
            my $fieldReps = $diff->{$n->{f}}; #fieldReps as in Field Repetitons, not all Fields but the repetitions of a selected MARC Field
            next unless $fieldReps;
            foreach my $field (@$fieldReps) {

                my $subfieldReps = $field->{$n->{sf}};
                next unless $subfieldReps;
                foreach my $subfieldDiffs (@$subfieldReps) {
                    push(@changes, C4::Biblio::Diff::Change->new($n->{f}, $n->{sf}, @$subfieldDiffs));
                }
            }
        }
    }
    return \@changes;
}

1;
