package t::lib::Page::Catalogue::Detail;

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

use t::lib::Page::Catalogue::Search;

use base qw(t::lib::Page::Intra t::lib::Page::Catalogue::Toolbar);

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Catalogue::Detail

=head SYNOPSIS

detail.pl PageObject providing page functionality as a service!

=cut

=head new

    my $detail = t::lib::Page::Catalogue::Detail->new({biblionumber => "1"})->doPasswordLogin('admin', '2134');

Instantiates a WebDriver and loads the catalogue/detail.pl to show the given Biblio
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    biblionumber => loads the page to display the Biblio matching the given parameter

@RETURNS t::lib::Page::Catalogue::Detail, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/catalogue/detail.pl';
    $params->{type}     = 'staff';

    $params->{getParams} = [];
    #Handle MANDATORY parameters
    if ($params->{biblionumber}) {
        push @{$params->{getParams}}, "biblionumber=".$params->{biblionumber};
    }
    else {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->new():> Parameter 'borrowernumber' is missing.");
    }

    my $self = $class->SUPER::new($params);

    return $self;
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

=head _getBiblioMarkers

@RETURNS HASHRef of Biblio data elements of the displayed Biblio details.
            'title' is guaranteed, others are optional
=cut

sub _getBiblioMarkers {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $e = {};
    $e->{title} = $d->find_element("#catalogue_detail_biblio .title", 'css')->get_text(); #title is mandatory and should always exist to simplify testing.
    eval {
        $e->{author} = $d->find_element("#catalogue_detail_biblio .author a", 'css')->get_text();
    };
    eval {
        $e->{isbn} = $d->find_element("#catalogue_detail_biblio span[property='isbn']", 'css')->get_text();
    };
    return $e;
}



################################################################################
=head PageObject Services

=cut
################################################################################

=head isBiblioMatch

    $detail->isBiblioMatch($record);

Checks that the loaded Biblio matches the give MARC::Record.
=cut

sub isBiblioMatch {
    my ($self, $record) = @_;
    $self->debugTakeSessionSnapshot();

    my $e = $self->_getBiblioMarkers();
    my $testFail;
    if (not($record->title() eq $e->{title})) {
        $testFail = 1;
    }
    if ($record->author() && not($record->author() eq $e->{author})) {
        $testFail = 1;
    }

    ok(not($testFail), "Biblio '".$record->title()."' matches loaded Biblio");
    return $self;
}

=head deleteBiblio
Deletes the displayed Biblio

@RETURNS t::lib::PageObject::Catalogue::Search as the execution moves to that PageObject.
=cut

sub deleteBiblio {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $e = $self->_getEditDropdownElements();
    $self->mockConfirmPopup('true');
    $e->{deleteRecord}->click();

    return t::lib::Page::Catalogue::Search->rebrandFromPageObject($self);
}


1; #Make the compiler happy!
