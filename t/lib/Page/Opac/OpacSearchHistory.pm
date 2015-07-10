package t::lib::Page::Opac::OpacSearchHistory;

# Copyright 2015 Open Source Freedom Fighters
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

use Modern::Perl;
use Test::More;

use base qw(t::lib::Page::Opac t::lib::Page::Opac::LeftNavigation);

use Koha::Exception::FeatureUnavailable;

=head NAME t::lib::Page::Opac::OpacSearchHistory

=head SYNOPSIS

PageObject providing page functionality as a service!

=cut

=head new

YOU CANNOT GET HERE WITHOUT LOGGING IN FIRST!

=cut

sub new {
    Koha::Exception::FeatureUnavailable->throw(error => __PACKAGE__."->new():> You must login first to navigate to this page!");
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

sub _getAllSearchHistories {
    my ($self) = @_;
    my $d = $self->getDriver();

    $self->pause(500); #Wait for datatables to load the page.
    my $histories = $d->find_elements("table.historyt tr");
    #First index has the table header, so skip that.
    shift @$histories;
    for (my $i=0 ; $i<scalar(@$histories) ; $i++) {
        $histories->[$i] = $self->_castSearchHistoryRowToHash($histories->[$i]);
    }
    return $histories;
}



################################################################################
=head PageObject Services

=cut
################################################################################

=head testDoSearchHistoriesExist

    $opacsearchhistory->testDoSearchHistoriesExist([ 'maximus',
                                                     'julius',
                                                     'titus',
                                                  ]);
@PARAM1 ARRAYRef of search strings shown in the opac-search-history.pl -page.
                 These search strings need only be contained in the displayed values.
=cut

sub testDoSearchHistoriesExist {
    my ($self, $searchStrings) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $histories = $self->_getAllSearchHistories();
    foreach my $s (@$searchStrings) {

        my $matchFound;
        foreach my $h (@$histories) {
            if ($h->{searchStringA}->get_text() =~ /$s/) {
                $matchFound = $h->{searchStringA}->get_text();
                last();
            }
        }
        ok($matchFound =~ /$s/, "SearchHistory $s exists.");
    }
    return $self;
}

sub _castSearchHistoryRowToHash {
    my ($self, $historyRow) = @_;
    my $d = $self->getDriver();

    my $checkbox = $d->find_child_element($historyRow, "input[type='checkbox']","css");
    my $date = $d->find_child_element($historyRow, "span[title]","css");
    $date = $date->get_text();
    my $searchStringA = $d->find_child_element($historyRow, "a + a","css");
    my $resultsCount = $d->find_child_element($historyRow, "td + td + td + td","css");

    my $sh = {  checkbox => $checkbox,
                date => $date,
                searchStringA => $searchStringA,
                resultsCount => $resultsCount,
              };
    return $sh;
}

1; #Make the compiler happy!