package Koha::Deduplicator;


# Copyright 2014-2015 Koha-community
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
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use C4::Matcher;
use C4::Items qw(MoveItemFromBiblio);
use C4::Biblio qw(GetBiblionumberSlice GetMarcBiblio GetBiblioItemByBiblioNumber DelBiblio);
use C4::Serials qw(CountSubscriptionFromBiblionumber);
use C4::Reserves qw/MergeHolds/;
use C4::Acquisition qw/ModOrder GetOrdersByBiblionumber/;

use Koha::Exception::Deduplicator::TooManyMatches;

sub new {
    my ($self, $initErrors) = _validate_new(@_);
    return ($self, $initErrors) if @$initErrors;

    return ($self, undef);
}
sub _validate_new {
    my ($class, $matcher_id, $limit, $offset, $biblionumber, $alertMatchCountThreshold, $verbose) = @_;

    my $self = {};
    my @initErrors;
    if (not($matcher_id) || $matcher_id !~ /^\d+$/) {
        push @initErrors, "Koha::Deduplicator->new(): Parameter matcher_id $matcher_id must be defined and a number pointing to koha.marc_matchers.matcher_id!";
    }

    if ($limit && $limit !~ /^\d+$/ ) {
        push @initErrors, "$class( $matcher_id, $limit, $offset, $biblionumber ): Parameter limit $limit must be a number!";
    }
    elsif (not($limit)) {
        $limit = 500; #Limit defaults to 500
    }
    $self->{limit} = $limit;

    if ($offset && $offset !~ /^\d+$/ ) {
        push @initErrors, "$class( $matcher_id, $limit, $offset, $biblionumber ): Parameter offset $offset must be a number!";
    }
    elsif (not($offset)) {
        undef $offset; #Offset defaults to undef
    }
    $self->{offset} = $offset;

    if ($biblionumber && $biblionumber !~ /^\d+$/ ) {
        push @initErrors, "$class( $matcher_id, $limit, $offset, $biblionumber ): Parameter biblionumber $biblionumber must be a number!";
    }
    elsif (not($biblionumber)) {
        undef $biblionumber; #Biblionumber defaults to undef
    }
    $self->{biblionumber} = $biblionumber;

    if ($verbose && $verbose !~ /^\d+$/) {
        push @initErrors, "$class( $matcher_id, $limit, $offset, $biblionumber ): Parameter verbose $verbose must be a number or don't define it!";
    }
    elsif ($verbose && $verbose =~ /^\d+$/) {
        $self->{verbose} = $verbose;
    }
    else {
        $self->{verbose} = 0;
    }

    if ($alertMatchCountThreshold && $alertMatchCountThreshold !~ /^\d+$/) {
        push @initErrors, "$class( $matcher_id, $limit, $offset, $biblionumber ): Parameter alertMatchCountThreshold $alertMatchCountThreshold must be a number or don't define it!";
    }
    elsif ($alertMatchCountThreshold && $alertMatchCountThreshold =~ /^\d+$/) {
        $self->{alertMatchCountThreshold} = $alertMatchCountThreshold;
    }
    else {
        $self->{alertMatchCountThreshold} = 3;
    }

    my $matcher = C4::Matcher->fetch($matcher_id);
    if (not($matcher)) {
        push @initErrors, "Koha::Deduplicator->new(): No Matcher with the given matcher_id $matcher_id.";
    }
    $self->{matcher} = $matcher;

    $self->{max_matches} = 100; #Default the max number of matches to return per matched biblionumber to 100

    return (undef, \@initErrors) if @initErrors;
    bless $self, $class;
    return ($self, \@initErrors);
}

sub deduplicate {
    my $self = shift;
    my $verbose = $self->{verbose};
    my $biblionumbers = C4::Biblio::GetBiblionumberSlice( $self->{limit}, $self->{offset}, $self->{biblionumber} );

    $self->{duplicates} = [];
    foreach my $biblionumber (@$biblionumbers) {
        my $marc = C4::Biblio::GetMarcBiblio($biblionumber);
        my $matches = Koha::Deduplicator->getMatches($self->{matcher}, $marc, $self->{max_matches}, $self->{alertMatchCountThreshold});

        if (scalar(@$matches) > 1) {
            for (my $i=0 ; $i<scalar(@$matches) ; $i++) {
                my $match = $matches->[$i];
                my $biblio = Koha::Biblios->find( $match->{record_id} );
                my $itemsCount = $biblio->items->count;
                $match->{itemsCount} = $itemsCount;
                unless(  _buildSlimBiblio($match->{record_id}, $match, C4::Biblio::GetMarcBiblio($match->{record_id}))  ) {
                    #Sometimes we get an error where the marcxml is not available.
                    splice(@$matches, $i, 1);
                    $i--; #Don't advance the iterator after this round or we will skip one record!
                    next();
                }
                if ($match->{record_id} == $biblionumber) {
                    $match->{matchSource} = 'matchSource';
                }
            }
            my $biblio = _buildSlimBiblio($biblionumber, undef, $marc);
            unless ($biblio) { #Sometimes we get an error where the marcxml is not available.
                next();
            }
            $biblio->{matches} = $matches;

            push @{$self->{duplicates}}, $biblio;
        }
        if ($verbose > 1) {
            print $biblionumber."\n";
        }
    }
    return $self->{duplicates};
}

=head getMatches

Is a wrapper for C4::Matcher->get_matches() fixing an issue where the resultset is not sorted and adds extra safety checks.

@PARAM1 C4::Matcher
@PARAM2 MARC::Record
@PARAM3 Integer, how many matches to return even if there would be more
@PARAM4 Integer, If there are this many matches, throw an exception. This is a safeguard to detect
                 destructive matching attempts which can potentially destroy the whole bibliographic database.
                 So if you expect to match only 1-3 records at max, you can stop deduplicating if there are more matches.
                 Defaults to 100.

=cut

sub getMatches {
    my ($class, $matcher, $record, $maxMatches, $alertMatchCountThreshold) = @_;
    Koha::Exception::BadParameter->throw(error => (caller(0))[3]."($matcher, $record, $maxMatches, $alertMatchCountThreshold):> Param \$alertMatchCountThreshold is not defined")
            unless $alertMatchCountThreshold;

    my @matches = $matcher->get_matches( $record, $maxMatches );
    if (scalar(@matches) >= $alertMatchCountThreshold) {
        my @cc = caller(0);
        my @biblionumbers = map {$_->{record_id}} @matches;
        Koha::Exception::Deduplicator::TooManyMatches->throw(error => $cc[3]."():> The match operation using matcher '".$matcher->code()."' returned too many search results and a safety mechanisms has been triggered preventing merging of all the found records. Revise your Matcher configuration. List of matched biblionumbers follows: [@biblionumbers]");
    }

    #sort @matches by record_id, because the C4::Matcher sorts them randomly.
    #This prevents some strange bugs when figuring out the automatic merge target
    #in cases where each match is a equally valid merge target.
    @matches = sort {$b->{record_id} <=> $a->{record_id}} @matches;
    return \@matches;
}

sub _buildSlimBiblio {
    my ($biblionumber, $biblio, $marc) = @_;

    if ($biblio) {
        $biblio->{biblionumber} = $biblionumber;
    }
    else {
        $biblio = {biblionumber => $biblionumber};
    }
    if (not($marc)) {
        warn "C4::Deduplicator::_buildSlimBiblio(), No MARC::Record for bn:$biblionumber";
        return undef;
    }

    $biblio->{marc} = $marc;

    my $title = $marc->subfield('245','a');
    my $titleField;
    my @titles;
    if ($title) {
        $titleField = '245';
    }
    else {
        $titleField = '240';
        $title = $marc->subfield('240','a');
    }
    my $enumeration = $marc->subfield( $titleField ,'n');
    my $partName = $marc->subfield( $titleField ,'p');
    my $publicationYear = $marc->subfield( '260' ,'c');
    push @titles, $title if $title;
    push @titles, $enumeration if $enumeration;
    push @titles, $partName if $partName;
    push @titles, $publicationYear if $publicationYear;

    my $author = $marc->subfield('100','a');
    $author = $marc->subfield('110','a') unless $author;

    $biblio->{author} = ($author) ? $author : '';
    $biblio->{title} = join(' ', @titles);
    $biblio->{title} = '' unless $biblio->{title};

    return $biblio;
}

=head batchMergeDuplicates

    $deduplicator->batchMergeDuplicates( $duplicates, $mergeTargetFindingAlgorithm );

=cut

sub batchMergeDuplicates {
    my ($self, $duplicates, $mergeTargetFindingAlgorithm) = @_;

    $self->{mergeErrors} = [];
    _findMergeTargets($duplicates, $mergeTargetFindingAlgorithm, $self->{mergeErrors});

    foreach my $duplicate (@$duplicates) {
        foreach my $match (@{$duplicate->{matches}}) {
            if ($match eq $duplicate->{'mergeTarget'}) { #Comparing Perl references, if they point to the same object.
                next(); #Don't merge itself to oneself.
            }
            merge($match, $duplicate->{'mergeTarget'}, $self->{mergeErrors}) if $duplicate->{'mergeTarget'}; #Dont merge if not know where to merge
        }
    }
    return $self->{mergeErrors} if scalar @{$self->{mergeErrors}} > 0;
    return undef;
}

sub _findMergeTargets {
    my ($duplicates, $mergeTargetFindingAlgorithm) = @_;

    my $subroutine;
    if ($mergeTargetFindingAlgorithm eq 'newest') {
        $subroutine = "_mergeTargetFindingAlgorithm_newest";
    }
    else {
        warn "Unknown merge target finding algorithm given: '$mergeTargetFindingAlgorithm'";
    }

    foreach my $duplicate (@$duplicates) {
        $duplicate->{mergeTarget} = __PACKAGE__->$subroutine( $duplicate );
    }
}

sub _mergeTargetFindingAlgorithm_newest {
    my ($class, $duplicate) = @_;

    my $target_leader; #Run through all matches and find the newest record.
    my $target_leader_f005 = 0;
    foreach my $match (@{$duplicate->{matches}}) {
        my $f005;
        eval {$f005 = $match->{marc}->field('005')->data(); }; #If marc is not defined this will crash unless we catch the die-signal
        if ($f005 && $f005 > $target_leader_f005) {
            $target_leader = $match;
            $target_leader_f005 = $f005;
        }
    }

    if ($target_leader) {
        return $target_leader;
    }
    else {
        warn "Koha::Deduplicator::_mergeTargetFindingAlgorithm_newest($duplicate), Couldn't get the merge target for duplicate bn:".$duplicate->{biblionumber};
        return undef;
    }
}

=head mergeMatches

Merges an array of records.
@RETURNS C4::Matchers match-HASH

=cut

sub mergeMatches {
    my ($class, $matches) = @_;

    my $duplicate = {
        matches => $matches,
    };

    my $mergeToRecord = _mergeTargetFindingAlgorithm_newest($duplicate);
    foreach my $match (@{$duplicate->{matches}}) {
        if ($match eq $mergeToRecord) {
            next(); #Do not merge thyself into oneself.
        }
        merge($match, $mergeToRecord);
    }

    return _validateMatchHASH($mergeToRecord);
}

=head _validateMatchHASH

Quarantee for modules consuming this endpoint that we always return the expected values.

=cut

sub _validateMatchHASH {
    my ($match) = @_;

    my $errorDesc = "Cannot return a Match-hash because it is invalid.";
    unless (ref($match) eq 'HASH') {
        Koha::Exception::UnknownObject->throw(error => (caller(1))[3]."():> $errorDesc \$match is not a HASH");
    }
    unless (blessed($match->{target_record}) && $match->{target_record}->isa('Koha::Exception')) {
        Koha::Exception::UnknownObject->throw(error => (caller(1))[3]."():> $errorDesc \$match key 'target_record' is not a MARC::Record");
    }
    unless ($match->{record_id} =~ /^\d+$/) {
        Koha::Exception::UnknownObject->throw(error => (caller(1))[3]."():> $errorDesc \$match key 'record_id' is not an Integer");
    }

    return $match;
}

=head merge
CODE DUPLICATION WARNING!!
Most of this is copypasted from cataloguing/merge.pl

=cut

sub merge {
    my ($match, $mergeTarget, $errors) = @_;

    my $dbh = C4::Context->dbh;
    my $sth;

    my $tobiblio     =  $mergeTarget->{biblionumber};
    my $frombiblio   =  $match->{biblionumber};
    if ($tobiblio == $frombiblio) {
        warn "Koha::Deduplicator::merge($match, $mergeTarget, $errors), source biblio is the same as the destination.";
        return;
    }

    my @notmoveditems;

    # Moving items from the other record to the reference record
    # Also moving orders from the other record to the reference record, only if the order is linked to an item of the other record
    my $items = Koha::Items->search({ biblionumber => $frombiblio });
    while (my $item = $items->next) {
        my $res = MoveItemFromBiblio($item->itemnumber, $frombiblio, $tobiblio);
        if (not defined $res) {
            push @notmoveditems, $item->itemnumber;
        }
    }
    # If some items could not be moved :
    if (scalar(@notmoveditems) > 0) {
        my $itemlist = join(' ',@notmoveditems);
        push @$errors, { code => "CANNOT_MOVE", value => $itemlist };
    }

    # Moving subscriptions from the other record to the reference record
    my $subcount = CountSubscriptionFromBiblionumber($frombiblio);
    if ($subcount > 0) {
        $sth = $dbh->prepare("UPDATE subscription SET biblionumber = ? WHERE biblionumber = ?");
        $sth->execute($tobiblio, $frombiblio);

        $sth = $dbh->prepare("UPDATE subscriptionhistory SET biblionumber = ? WHERE biblionumber = ?");
        $sth->execute($tobiblio, $frombiblio);

    }

    # Moving serials
    $sth = $dbh->prepare("UPDATE serial SET biblionumber = ? WHERE biblionumber = ?");
    $sth->execute($tobiblio, $frombiblio);

    # TODO : Moving reserves

    # Moving orders (orders linked to items of frombiblio have already been moved by MoveItemFromBiblio)
    my @allorders = GetOrdersByBiblionumber($frombiblio);
    my @tobiblioitem = GetBiblioItemByBiblioNumber ($tobiblio);
    my $tobiblioitem_biblioitemnumber = $tobiblioitem [0]-> {biblioitemnumber };
    foreach my $myorder (@allorders) {
        $myorder->{'biblionumber'} = $tobiblio;
        ModOrder ($myorder);
    # TODO : add error control (in ModOrder?)
    }

    # Deleting the other record
    if (scalar(@$errors) == 0) {
        # Move holds
        MergeHolds($dbh,$tobiblio,$frombiblio);
        my $error = DelBiblio($frombiblio, 1);
        push @$errors, $error if ($error);
    }
}


=head deduplicateSingleRecord

    my $count = Koha::Deduplicator->deduplicateSingleRecord($record, $matcher, $maxMatches, $alertMatchCountThreshold);

@PARAM1 MARC::Record to deduplicate
@PARAM2 C4::Matcher to find matches for @PARAM1
@PARAM3 Integer, How many matches to merge, even if there were more
@PARAM4 Integer, see getMatches() \$alertMatchCountThreshold
@RETURN Integer, how many duplicates found and deduplicated?
@THROWS Koha::Exception::Deduplicator::TooManyMatches if there are more or as many matches than the \$alertMatchCountThreshold-parameter

=cut

sub deduplicateSingleRecord {
    my ($class, $record, $matcher, $maxMatches, $alertMatchCountThreshold) = _validate_deduplicateSingleRecord(@_);

    my $matches = Koha::Deduplicator->getMatches($matcher, $record, $maxMatches, $alertMatchCountThreshold);


    $class->mergeMatches($matches);

    return scalar(@$matches);
}
sub _validate_deduplicateSingleRecord {
    my ($class, $record, $matcher, $maxMatches, $alertMatchCountThreshold) = @_;
    unless($matcher) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($record, $matcher):> Param \$matcher '$matcher' is undefined");
    }
    if ($matcher =~ /^\d+$/) {
        $matcher = C4::Matcher->fetch($matcher);
        unless($matcher) {
            my @cc = caller(0);
            Koha::Exception::BadParameter->throw(error => $cc[3]."($record, $matcher):> Param \$matcher '$matcher' is an id, but no matcher found with that id");
        }
    }
    elsif (blessed($matcher) && $matcher->isa('C4::Matcher')) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($record, $matcher):> Param \$matcher '$matcher' is not an id or a 'C4::Matcher'-object");
    }
    unless (blessed($record) && $record->isa('MARC::Record')) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($record, $matcher):> Param \$record '$record' is not a MARC::Record");
    }
    if($maxMatches && $maxMatches !~ /^\d$/) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($record, $matcher):> Param \$maxMatches '$maxMatches' is not an integer");
    }
    if($alertMatchCountThreshold && $alertMatchCountThreshold !~ /^\d$/) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($record, $matcher):> Param \$alertMatchCountThreshold '$alertMatchCountThreshold' is not an integer");
    }
    $alertMatchCountThreshold = 3 unless(defined($alertMatchCountThreshold));

    return ($record, $matcher, $maxMatches, $alertMatchCountThreshold);
}

sub printDuplicatesAsText {
    my ($self) = @_;

    foreach my $duplicate (@{$self->{duplicates}}) {
        print 'Match source: '.$duplicate->{biblionumber}.' - '.$duplicate->{title}.' '.$duplicate->{author}."\n";
        foreach my $match (@{$duplicate->{matches}}) {
            print $match->{record_id}.' - '.$match->{score}.' '.$match->{itemsCount}.'  '.$match->{title}.' '.$match->{author}."\n";
        }
        print "\n\n";
    }
}

sub printMergesAsText {
    my ($self) = @_;
    foreach my $error (@{$self->{mergeErrors}}) {
        print $error;
    }
}
1;
