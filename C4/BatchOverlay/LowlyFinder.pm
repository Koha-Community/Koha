package C4::BatchOverlay::LowlyFinder;

# Copyright (C) 2016 KohaSuomi
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

use DateTime;
use MARC::Record;
use MARC::File::XML;

use C4::Search;
use Koha::Logger;
use C4::BatchOverlay::CandidateFinder;
use C4::BatchOverlay::RuleManager;

use Koha::Exception::BatchOverlay::LocalSearch;

use constant ENC_LEVELS => {
        '#' => {full => 1, rank => 1 },
        '1' => {full => 1, rank => 2 },
        '2' => {full => 1, rank => 3 },
        '4' => {full => 1, rank => 4 },
        '3' => {full => 0, rank => 5 },
        '5' => {full => 0, rank => 6 },
        '6' => {full => 0, rank => 7 },
        '7' => {full => 1, rank => 8 },
        '8' => {full => 0, rank => 9 },
        'u' => {full => 0, rank => 10},
        'z' => {full => 0, rank => 11},
};

our $logger = Koha::Logger->get();

=head1 SYNOPSIS

C4::BatchOverlay::LowlyFinder looks for lowly catalogued bibliographic records and returns
chunks of MARC::Record-objects.

See L<isLowlyEncodingLevel> for how low encodingness is decided.

=cut

=head2 isLowlyEncodingLevel

    if (isLowlyEncodingLevel( $marcRecord )) {
        #Record is lowly encoded
    }

If the encoding level
  IS NOT ONE OF
'#', '1', '2', '4', '3', then the record is considered a lowly catalogued record.

@param {MARC::Record} $marcRecord
@returns {Boolean}, true if is low level.

=cut

sub isLowlyEncodingLevel {
    return ENC_LEVELS->{shift}->{full} ? 0 : 1;
}

=head2 getLowlyEncodingLevels

    my $levels = getLowlyEncodingLevels();

@returns {ArrayRef of Chars}, list of encoding levels considered lowly in the
                              order from least lowliest to most lowliest.

=cut

my $lowlies;
sub getLowlyEncodingLevels {
    if($lowlies) {
        my @clone = @$lowlies;
        return \@clone;
    }

    my @lowlies = grep { not(ENC_LEVELS->{$_}->{full}) } keys(%{ENC_LEVELS()});
    @lowlies = sort { ENC_LEVELS->{$a}->{rank} <=> ENC_LEVELS->{$b}->{rank} } @lowlies;
    $lowlies = \@lowlies;
    my @clone = @lowlies;
    return \@clone;
}

=head2 new

    my $lowlyFinder = C4::BatchOverlay::LowlyFinder->new({
        chunk        => 500,        #Default bibliographic records chunk size
        chunks       => 1,         #Default, how many chunks can nextLowlyCataloguedRecords() return, eg. how many times can nextLowlyCataloguedRecords() be called?
        monthsPast   => 6,     #How many months maximum to look behind? Defaults to undef
    });

=cut

sub new {
    my ($class, $self) = @_;
    $self = {} unless(ref($self) eq 'HASH');
    bless($self, $class);

    $self->{monthsPast} = undef unless $self->{monthsPast};
    $self->{chunk} = 500 unless $self->{chunk};
    $self->{chunksFetched} = 0;
    $self->{chunks} = 1 unless $self->{chunks};
    $self->{recordBuffer} = []; #Collect records here for iteration.
    $self->{levelsNotSearched} = getLowlyEncodingLevels(); #Which encoding levels have already been searched and added to the recordBuffer

    $self->{rule} = C4::BatchOverlay::RuleManager->new()->getRuleFromRuleName('default');
    my $cf = C4::BatchOverlay::CandidateFinder->new($self->{rule});
    $self->{candidateFinderSearchTerms} = $cf->getSearchTerms();

    return $self;
}

=head2 nextLowlyCataloguedRecords

    my $records = $lowlyFinder->nextLowlyCataloguedRecords();

@returns {ArrayRef of MARC::Record or undef}, as long as lowly catalogued records exists in the DB.
            Returns undef when all records have been fetched, or we have fetched as many 'chunks' as
            LowlyFinder is configured to return.

=cut

sub nextLowlyCataloguedRecords {
    my ($self) = @_;
    return undef unless ($self->{chunks} >= ++$self->{chunksFetched}); #Continue if we have fetched less chunks than we aim to
    $logger->debug('Getting chunk '.$self->{chunksFetched}.'/'.$self->{chunks});

    ##Make sure we have a buffer to fetch from
    while (scalar(@{$self->{recordBuffer}}) < $self->{chunk}) {
        my $nextEncodingLevel = pop(@{$self->{levelsNotSearched}});
        last unless $nextEncodingLevel;
        my ($records, $resultSetSize) = $self->_searchByEncodingLevel($nextEncodingLevel, undef); #no limit!
        push(@$records, @{$self->{recordBuffer}}); #Make sure the more lowly catalogued records are in the tail so we can splice more efficiently
        $self->{recordBuffer} = $records;
    }

    if (scalar(@{$self->{recordBuffer}}) >= $self->{chunk}) {
        my @newChunk = splice(@{$self->{recordBuffer}},
                              -1*$self->{chunk},
                              $self->{chunk});
        $logger->debug("Returning from buffer '".scalar(@newChunk)."' results");
        return \@newChunk;
    }
    else {
        my $rv = $self->{recordBuffer};
        $self->{recordBuffer} = [];
        $logger->debug("Returning buffer remnants '".scalar(@$rv)."' results");
        return $rv if scalar(@$rv);
        return undef;
    }
}

=head2 searchByEncodingLevel
@STATIC

    my ($searchResultBiblios, $resultSetSize) = C4::BatchOverlay::LowlyFinder::searchByEncodingLevel($encodingLevel, $limit);
    $searchResultBiblios->[1]->subfield('021','a');

Makes a 'Enc-level=?' -search using the @PARAM1 and returns a pre-processed list of slim biblio objects having the
given encoding level from MARC21 leader position 17.

The returning slim biblio has the following keys:
  title, author, stdId, marc, biblionumber

@PARAM1 Char, a single character to look from MARC21 leader, location 17.
@PARAM2 Integer, OPTIONAL, Limit of how many results to return. With encoding level 8 we have hundreds of thousands of results :)
@RETURNS1 ArrayRef of MARC::Record-objects, All found search results.
@RETURNS2 Integer, The count of results found.
@THROWS Koha::Exception::BatchOverlay::LocalSearch

=cut

sub searchByEncodingLevel {
    my ($encodingLevel, $limit) = (@_);

    my $search = "Enc-level='$encodingLevel'";

    return _searchByEncodingLevelAgain($search, $limit);
}

=head2 _searchByEncodingLevel

Same as the static subroutine searchByEncodingLevel(), except uses more complicated rules to build the query

In addition to the searchByEncodingLevel(), uses the syspref BatchOverlayRules to add extra filters to
this encoding level search.

=cut

sub _searchByEncodingLevel {
    my ($self, $encodingLevel, $limit) = (@_);

    my $search = "Enc-level='$encodingLevel'";
    $search .= ' and '.$self->{candidateFinderSearchTerms} if $self->{candidateFinderSearchTerms};

    return _searchByEncodingLevelAgain($search, $limit);
}

=head2 _searchByEncodingLevelAgain
@PRIVATE

Do not ever directly call this subroutine

=cut

sub _searchByEncodingLevelAgain {
    my ($search, $limit) = @_;

    $logger->debug("Searching with $search");
    my ($error, $results, $resultSetSize) = C4::Search::SimpleSearch( $search, undef, $limit );
    if ($error) {
        my @cc = caller(0);
        Koha::Exception::BatchOverlay::LocalSearch->throw(error => $cc[3]."():> Local search '$search' fails with error '$error'");
    }
    if ($resultSetSize) {
        for (my $i=0 ; $i<scalar(@$results) ; $i++) {
            $results->[$i] = MARC::Record->new_from_xml( $results->[$i], 'utf8', C4::Context->preference("marcflavour") );
            $results->[$i]->{biblionumber} = C4::Biblio::GetMarcBiblionumber($results->[$i]);
            $results->[$i]->{stdId} = C4::Biblio::GetMarcStdids($results->[$i]);
        }
    }
    $logger->debug("Returning '$resultSetSize' results");
    return ($results, $resultSetSize);
}

1;
