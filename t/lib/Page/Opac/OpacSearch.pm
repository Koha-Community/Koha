package t::lib::Page::Opac::OpacSearch;

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
use Scalar::Util qw(blessed);
use Test::More;

use t::lib::Page::PageUtils;
use t::lib::Page::Opac::OpacMain;
use t::lib::Page::Opac::OpacSearchHistory;

use base qw(t::lib::Page::Opac);

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Opac::OpacSearch

=head SYNOPSIS

PageObject providing page functionality as a service!

=cut

=head new

    my $opacsearch = t::lib::Page::Opac::OpacSearch->new();

Instantiates a WebDriver and loads the opac/opac-search.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    none atm.

@RETURNS t::lib::Page::Opac::OpacSearch, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/opac-search.pl';
    $params->{type}     = 'opac';

    my $self = $class->SUPER::new($params);

    return $self;
}


################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

sub _findSearchFieldElements {
    my ($self, $searchField) = @_;
    my $d = $self->getDriver();
    $searchField = '0' unless $searchField;

    my $indexSelect = $d->find_element("#search-field_$searchField");
    my $termInput = $d->find_element("#search-field_$searchField + input[name='q']");
    my $searchSubmit = $d->find_element("input[type='submit'].btn-success"); #Returns the first instance.
    return ($indexSelect, $termInput, $searchSubmit);
}



################################################################################
=head PageObject Services

=cut
################################################################################

=head doSetSearchFieldTerm

Sets the search index and term for one of the (by default) three search fields.
@PARAM1, Integer, which search field to put the parameters into?
                  Starts from 0 == the topmost search field.
@PARAM2, String, the index to use. Undef if you want to use whatever there is.
                 Use the english index full name, eg. "Keyword", "Title", "Author".
@PARAM3, String, the search term. This replaces any existing search terms in the search field.
=cut

sub doSetSearchFieldTerm {
    my ($self, $searchField, $selectableIndex, $term) = @_;
    $searchField = '0' unless $searchField; #Trouble with Perl interpreting 0
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($indexSelect, $termInput, $searchSubmit) = $self->_findSearchFieldElements($searchField);

    if ($selectableIndex) {
        t::lib::Page::PageUtils::displaySelectsOptions($d, $indexSelect);
        my $optionElement = t::lib::Page::PageUtils::getSelectElementsOptionByName($d, $indexSelect, $selectableIndex);
        $optionElement->click();
    }

    if ($term) {
        $termInput->clear();
        $termInput->send_keys($term);
    }
    else {
        Koha::Exception::BadParameter->throw("doSetSearchFieldTerm():> Parameter \$main is mandatory but is missing? Parameters as follow\n: @_");
    }

    $selectableIndex = '' unless $selectableIndex;
    ok(1, "SearchField parameters '$selectableIndex' and '$term' set.");
    $self->debugTakeSessionSnapshot();
    return $self;
}

sub doSearchSubmit {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($indexSelect, $termInput, $searchSubmit) = $self->_findSearchFieldElements(0); #We just want the submit button
    $searchSubmit->click();
    $self->debugTakeSessionSnapshot();

    ok(($d->get_title() =~ /Results of search/), "SearchField search.");
    return $self;
}

1; #Make the compiler happy!
