package C4::BatchOverlay::SearchAlgorithms;

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
use Data::Dumper;

use C4::BatchOverlay;

use Koha::Exception::BadParameter;
use Koha::Exception::UnknownProgramState;
use Koha::Exception::BatchOverlay::Marc;

=head1 SYNOPSIS

This file defines remote searching algorithms that should conform to a common search algorithm interface

=cut

sub dispatch {
    my $subroutineAlgorithm = shift(@_);
    my ($z3950Server, $localRecord) = @_;
    _validateInterfaceCall(@_);
    my $breeding;
    try {
        $breeding = C4::BatchOverlay::SearchAlgorithms->$subroutineAlgorithm($z3950Server, $localRecord);
    } catch {
        die $_ unless(blessed($_) && $_->can('rethrow'));
        $_->{searchAlgorithm} = $subroutineAlgorithm; #Inject info about this exception
        $_->rethrow();
    };
    return _validateReturnValue( $breeding );
}

=head interface

Follow this interface pattern to implement other algorithms

=cut

sub interface {
    my ($class, $z3950Server, $localRecord) = @_;

    ##Do a lot of interesting stuff
    my $breeding = {breedingid => 10};

    return $breeding;
}
sub _validateInterfaceCall {
    my ($z3950Server, $localRecord) = @_;
    unless (ref($z3950Server) eq 'HASH' && $z3950Server->{name}) {
        my @cc1 = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc1[3]."()> Param \$z3950Server '$z3950Server' is not a proper z39.50 server HASH");
    }
    unless (blessed($localRecord) && $localRecord->isa('MARC::Record')) {
        my @cc1 = caller(1);
        Koha::Exception::BadParameter->throw(error => $cc1[3]."()> Param \$localRecord '$localRecord' is not a MARC::Record");
    }
}
sub _validateReturnValue {
    my ($breeding) = @_;
    if ($breeding && not(
                        (ref($breeding) eq 'HASH' && $breeding->{breedingid}) ||
                        (ref($breeding) eq 'ARRAY' && ref($breeding->[0]) eq 'HASH' && $breeding->[0]->{breedingid})
                    )
        ) {
        my @cc1 = caller(1);
        Koha::Exception::UnknownProgramState->throw(error => $cc1[3]."():> Return value '$breeding' is not a HASH with a 'breedingid'-key or undef, or an ARRAYref of such breeding objects");
    }
    return $breeding;
}

=head z3950Search

    my $breedingRecord = C4::BatchOverlay::SearchAlgorithms::z3950Search($bib1SearchParams, $remoteTarget, $acceptMultiple);

@PARAM1 $z3950 search parameters HASH for C4::Breeding::Z3950Search. This should be constrained to the Bib1-attribute set.
@PARAM2 HASHRef of a Z39.50 search target, from koha.z3950servers
@PARAM3 String, Is it acceptable to return multiple values? This is useful for fetching component parts who are often a legion. When overlaying a single record, DON'T ALLOW this flag!!
                If you want to receive all the results, set this param as 'acceptMultiple'.
@RETURNS HASHREf of a Breeding record
         or ARRAYref of HASHrefs of a Breeding record.
@THROWS Koha::Exception::BadParameter if @PARAMS are not defined properly
@THROWS Koha::Exception::BatchOverlay::RemoteSearchFailed if search failed
@THROWS Koha::Exception::BatchOverlay::RemoteSearchNoResults if no search results
@THROWS Koha::Exception::BatchOverlay::RemoteSearchAmbiguous if more than one search result

=cut

sub z3950Search {
    my ($searchParameters, $remoteTarget, $acceptMultiple) = @_;
    unless (ref($remoteTarget) eq 'HASH' && $remoteTarget->{id} =~ /^\d+$/) {
        my @cc = caller(0);
        Koha::Exception::BadParameter->throw(error => $cc[3]."($searchParameters, $remoteTarget):> Param \$remoteTarget '$remoteTarget' is not a Z39.50 target or is missing it's id");
    }
    if ($acceptMultiple && $acceptMultiple ne 'acceptMultiple') {
        my @cc = caller(0);
        Koha::Exception::UnknownProgramState->throw(error => $cc[3]."($searchParameters, $remoteTarget):> Param \$acceptMultiple '$acceptMultiple' is not 'acceptMultiple' or undef. Blocking importing of multiple search results for your safety. This should never happen.");
    }

    $searchParameters->{id} = [$remoteTarget->{id}];
    my $z3950results = {};

    C4::Breeding::Z3950Search($searchParameters, $z3950results, 'getAll');
    my $searchResults = $z3950results->{breeding_loop};

    if (scalar(@{$z3950results->{errconn}})) {
        my @errDescs = map {C4::Breeding::translateZOOMError($_->{error})} @{$z3950results->{errconn}};
        Koha::Exception::BatchOverlay::RemoteSearchFailed->throw(error => "Remote target '".$remoteTarget->{name}."' failed with '".join(', ', @errDescs)."'");
    }
    unless(@$searchResults) {
        Koha::Exception::BatchOverlay::RemoteSearchNoResults->throw(error => "Remote target '".$remoteTarget->{name}."'");
    }
    if ($acceptMultiple) {
        return $searchResults;
    }
    else {
        if (@$searchResults == 1) {
            return $searchResults->[0];
        }
        elsif (@$searchResults > 1) {
            Koha::Exception::BatchOverlay::RemoteSearchAmbiguous->throw(error => "Remote target '".$remoteTarget->{name}."'");
        }
    }
}

###################################
##  Start interface definitions  ##
###################################

=head Control_number_identifier

Make a search using field 001 and 003 from a remote Z39.50 target.
This probably works only with Koha's Z39.50 server configured to index
field 001 as bib1 attribute 9001
field 003 as bib1 attribute 1097

Verify operation with t/CataloguingCenter/batchOverlay.t::verifyRemoteBatchOverlayTargetCNISearch()

=cut

sub Control_number_identifier {
    my ($class, $z3950Server, $localRecord) = @_;

    my $cn  = eval {$localRecord->field('001')->data()};
    my $cni = eval {$localRecord->field('003')->data()};
    unless ($cn && $cni) {
        Koha::Exception::BatchOverlay::Marc->throw(error => "Mandatory fields 001 and 003 not defined.",
                                                   records => [$localRecord]);
    }
    my $pars = {
        controlNumber           => $cn,
        controlNumberIdentifier => $cni,
    };
    my $searchResult;
    try {
        $searchResult = C4::BatchOverlay::SearchAlgorithms::z3950Search($pars, $z3950Server);
    } catch {
        die $_ unless(blessed($_) && $_->can('rethrow'));
        $_->{searchTerm} = "001 $cn & 003 $cni";
        $_->rethrow;
    };
    return $searchResult;
}

=head Standard_identifier

Finds all standard identifiers from a given record
and uses them to make normal Z39.50 standard identifier searches

All exceptions have Hash-key 'searchTerm' injected if more than one standard id was used to search.
This is a comma-separated concatenated string of used standard identifiers.
@THROWS Koha::Exception::BatchOverlay::RemoteSearchNoResults if none of the standard identifiers match.
@THROWS from z3950Server()

=cut

sub Standard_identifier {
    my ($class, $z3950Server, $localRecord) = @_;

    my @stdids = C4::Biblio::GetMarcStdids($localRecord);
    my @usedStdids; #Report the used stdids to track which searches were being performed
    foreach my $stdid (@stdids) {
        my $pars = {
            stdid => $stdid,
        };

        my $searchResult;
        try {
            $searchResult = C4::BatchOverlay::SearchAlgorithms::z3950Search($pars, $z3950Server);
        } catch {
            die $_ unless(blessed($_) && $_->can('rethrow'));
            $_->{searchTerm} = join(', ', @usedStdids);
            $_->rethrow unless $_->isa('Koha::Exception::BatchOverlay::RemoteSearchNoResults');
        };
        return $searchResult if $searchResult;
        push @usedStdids, $stdid;
    }
    Koha::Exception::BatchOverlay::RemoteSearchNoResults->throw(error => "Remote target '".$z3950Server->{name}."'",
                                                                searchTerm => join(', ', @usedStdids));
}

=head Component_part_773w_003

=cut

sub Component_part_773w_003 {
    my ($class, $z3950Server, $hostRecord) = @_;

    my $pars;
    eval { #Not all records have 001 and 003 so prevent crashing
        $pars = {
            recordControlNumber => $hostRecord->field('001')->data(),
            controlNumberIdentifier => $hostRecord->field('003')->data(),
        };
    };
    my $searchResults = C4::BatchOverlay::SearchAlgorithms::z3950Search($pars, $z3950Server, 'acceptMultiple') if $pars;

    return $searchResults || [];
}

1; #Satisfying the compiler, we aim to please!
