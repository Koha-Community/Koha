package C4::Matcher;

# Copyright (C) 2007 LibLime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use C4::Context;
use MARC::Record;
use C4::Search;
use C4::Biblio;

use vars qw($VERSION);

# set the version for version checking
$VERSION = 3.00;

=head1 NAME

C4::Matcher - find MARC records matching another one

=head1 SYNOPSIS

=over 4

my $matcher = C4::Matcher->new($record_type);
$matcher->threshold($threshold);
$matcher->add_matchpoint($source_tag, $source_subfields, $source_normalizer,
                         $index, $score);
$matcher->add_required_check($check_name, $source_tag, $source_subfields, $source_normalizer,
                             $target_tag, $target_subfields, $target_normalizer);

my @matches = $matcher->get_matches($marc_record, $max_matches);

foreach $match (@matches) {

    # matches already sorted in order of
    # decreasing score
    print "record ID: $match->{'record_id'};
    print "score:     $match->{'score'};

}

=back

=head1 METHODS

=cut

=head2 new

=over 4

my $matcher = C4::Matcher->new($record_type, $threshold);

=back

Creates a new Matcher.  C<$record_type> indicates which search
database to use, e.g., 'biblio' or 'authority' and defaults to
'biblio', while C<$threshold> is the minimum score required for a match
and defaults to 1000.

=cut

sub new {
    my $class = shift;
    my $self = {};

    if ($#_ > -1) {
        $self->{'record_type'} = shift;
    } else {
        $self->{'record_type'} = 'biblio';
    }

    if ($#_ > -1) {
        $self->{'threshold'} = shift;
    } else {
        $self->{'threshold'} = 1000;
    }

    $self->{'matchpoints'} = [];
    $self->{'required_checks'} = [];

    bless $self, $class;
    return $self;
}

=head2 threshold

=over 4

$matcher->threshold(1000);
my $threshhold = $matcher->threshhold();

=back

Accessor method.

=cut

sub threshold {
    my $self = shift;
    @_ ? $self->{'threshold'} = shift : $self->{'threshold'};
}

=head2 add_matchpoint

=over 4

$matcher->add_matchpoint($source_tag, $source_subfields, $source_normalizer,
                         $index, $score);

=back

Adds a matchpoint rule -- after composing a key based on the source tag and subfields,
normalized per the normalization fuction, search the index.  All records retrieved
will receive the assigned score.

=cut

sub add_matchpoint {
    my $self = shift;
    my ($source_tag, $source_subfields, $source_normalizer, $index, $score) = @_;

    # FIXME - $source_normalizer not used yet
    my $matchpoint = {
        'source_tag'        => $source_tag,
        'source_subfields'  => { map { $_ => 1 } split(//, $source_subfields) },
        'source_normalizer' => $source_normalizer,
        'index'             => $index,
        'score'             => $score
    };
    push @{ $self->{'matchpoints'} }, $matchpoint;
}

=head2 add_required_check

$matcher->add_required_check($check_name, $source_tag, $source_subfields, $source_normalizer,
                             $target_tag, $target_subfields, $target_normalizer);

=over 4

Adds a required check, which requires that the normalized keys made from the source and targets
must match for a match to be considered valid.

=back

=cut

sub add_required_check {
    my $self = shift;
    my ($check_name, $source_tag, $source_subfields, $source_normalizer, $target_tag, $target_subfields, $target_normalizer) = @_;

    my $check = {
        'check_name'        => $check_name,
        'source_tag'        => $source_tag,
        'source_subfields'  => { map { $_ => 1 } split(//, $source_subfields) },
        'source_normalizer' => $source_normalizer,
        'target_tag'        => $target_tag,
        'target_subfields'  => { map { $_ => 1 } split(//, $target_subfields) },
        'target_normalizer' => $target_normalizer
    };

    push @{ $self->{'required_checks'} }, $check;
}

=head2 find_matches

my @matches = $matcher->get_matches($marc_record, $max_matches);
foreach $match (@matches) {
  # matches already sorted in order of
  # decreasing score
  print "record ID: $match->{'record_id'};
  print "score:     $match->{'score'};
}

=back

Identifies all of the records matching the given MARC record.  For a record already 
in the database to be considered a match, it must meet the following criteria:

=over 2

=item 1. Total score from its matching field must exceed the supplied threshold.

=item 2. It must pass all required checks.

=back

Only the top $max_matches matches are returned.  The returned array is sorted
in order of decreasing score, i.e., the best match is first.

=cut

sub get_matches {
    my $self = shift;
    my ($source_record, $max_matches) = @_;

    my %matches = ();

    foreach my $matchpoint (@{ $self->{'matchpoints'} }) {
        my @source_keys = _get_match_keys($source_record, $matchpoint->{'source_tag'}, 
                                          $matchpoint->{'source_subfields'}, $matchpoint->{'source_normalizer'});
        next if scalar(@source_keys) == 0;
        # build query
        my $query = join(" or ", map { "$matchpoint->{'index'}=$_" } @source_keys);
        # FIXME only searching biblio index at the moment
        my ($error, $searchresults) = SimpleSearch($query);

        warn "search failed ($query) $error" if $error;
        foreach my $matched (@$searchresults) {
            $matches{$matched} += $matchpoint->{'score'};
        }
    }

    # get rid of any that don't meet the threshold
    %matches = map { ($matches{$_} >= $self->{'threshold'}) ? ($_ => $matches{$_}) : () } keys %matches;

    # FIXME - implement record checks
    my @results = ();
    foreach my $marcblob (keys %matches) {
        my $target_record = MARC::Record->new_from_usmarc($marcblob);
        my $result = TransformMarcToKoha(C4::Context->dbh, $target_record, '');
        # FIXME - again, bibliospecific
        # also, can search engine be induced to give just the number in the first place?
        my $record_number = $result->{'biblionumber'};
        push @results, { 'record_id' => $record_number, 'score' => $matches{$marcblob} };
    }
    @results = sort { $b->{'score'} cmp $a->{'score'} } @results;
    if (scalar(@results) > $max_matches) {
        @results = @results[0..$max_matches-1];
    }
    return @results;

}

sub _get_match_keys {
    my ($source_record, $source_tag, $source_subfields, $source_normalizer) = @_;

    use Data::Dumper;
    my @keys = ();
    foreach my $field ($source_record->field($source_tag)) {
        if ($field->is_control_field()) {
            push @keys, _normalize($field->data());
        } else {
            my $key = "";
            foreach my $subfield ($field->subfields()) {
                if (exists $source_subfields->{$subfield->[0]}) {
                    $key .= " " . $subfield->[1];
                }
            }
            $key = _normalize($key);

            push @keys, $key if $key;
        }
    }
    return @keys;
    
}

# FIXME - default normalizer
sub _normalize {
    my $value = uc shift;
    $value =~ s/^\s+//;
    $value =~ s/^\s+$//;
    $value =~ s/\s+/ /g;
    $value =~ s/[.;,\]\[\)\(\/"']//g;
    return $value;
}

1;

=head1 AUTHOR

Koha Development Team <info@koha.org>

Galen Charlton <galen.charlton@liblime.com>

=cut
