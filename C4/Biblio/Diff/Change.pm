package C4::Biblio::Diff::Change;

# Copyright KohaSuomi 2016
#
# This file is part of Koha.
#

use Modern::Perl;

=head SYNOPSIS

    Change is a single row of changes between two or more records

=cut

=head new

    my $change = C4::Biblio::Diff::Change->new($fieldCode, $subfieldCode, @diffedValues);
    my $change = C4::Biblio::Diff::Change->new('084', 'a', 'Text and subfield content', ... , 'Moar text');

=cut

sub new {
    my $class = shift @_;
    my $self = \@_;
    bless($self, $class);
    return $self;
}

sub getFieldCode {
    return shift->[0];
}
sub getSubfieldCode {
    return shift->[1];
}
sub getVal {
    my ($self, $i) = @_;
    return $self->[$i+2];
}
sub getVals {
    my ($self) = @_;
    return $self->[2..@$self];
}

1;
