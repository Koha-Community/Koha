package t::lib::Page::Members::ApiKeys;

# Copyright 2015 KohaSuomi!
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

use base qw(t::lib::Page::Intra t::lib::Page::Members::Toolbar);

use Koha::Exception::BadParameter;
use Koha::Exception::UnknownObject;

=head NAME t::lib::Page::Members::ApiKeys

=head SYNOPSIS

apikeys.pl PageObject providing page functionality as a service!

=cut

=head new

    my $apikeys = t::lib::Page::Members::ApiKeys->new({borrowernumber => "1"});

Instantiates a WebDriver and loads the members/apikeys.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    borrowernumber => loads the page to display Borrower matching the given borrowernumber

@RETURNS t::lib::Page::Members::ApiKeys, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/members/apikeys.pl';
    $params->{type}     = 'staff';

    $params->{getParams} = [];
    #Handle MANDATORY parameters
    if ($params->{borrowernumber}) {
        push @{$params->{getParams}}, "borrowernumber=".$params->{borrowernumber};
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

=head _getActionsAndTableElements
@RETURNS List of
         HASHRef of Selenium::Driver::Webelement-objects matching the generic
                 actions on this page, eg. 'generateNewKey'.
         HASHRef of Selenium::Driver::Webelement-objects keyed with the apiKey hash/text.
                 These are all the apiKey table rows present, and have the
                 elements prefetched for easy access.

=cut

sub _getActionsAndTableElements {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $generateNewKeySubmit = $d->find_element("#generatenewkey", 'css');

    my $a = {}; #Collect action elements here
    $a->{generateNewKey} = $generateNewKeySubmit; #Bind the global action here for easy reference.

    my $apiKeyRows;
    eval { #We might not have ApiKeys yet.
        $apiKeyRows = $d->find_elements("#apikeystable tr", 'css');
        shift @$apiKeyRows; #Remove the table header row
    };
    my %apiKeys;
    for(my $i=0 ; $i<scalar(@$apiKeyRows) ; $i++) {
        #Iterate every apiKey in the apiKeys table and prefetch the interesting data as text and available action elements.
        my $row = $apiKeyRows->[$i];
        $row->{'nth-of-type'} = $i+1; #starts from 1
        $row->{key} = $d->find_child_element($row, "td.apikeykey", 'css')->get_text();
        $row->{active} = $d->find_child_element($row, "td.apikeyactive", 'css')->get_text();
        $row->{lastTransaction} = $d->find_child_element($row, "td.apikeylastransaction", 'css')->get_text();
        $row->{delete} = $d->find_child_element($row, "input.apikeydelete", 'css');
        eval {
            $row->{revoke} = $d->find_child_element($row, "input.apikeyrevoke", 'css');
        };
        eval {
            $row->{activate} = $d->find_child_element($row, "input.apikeyactivate", 'css');
        };
        $apiKeys{$row->{key}} = $row;
    }

    return ($a, \%apiKeys);
}



################################################################################
=head PageObject Services

=cut
################################################################################

sub generateNewApiKey {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($actionElements, $apiKeyRows) = $self->_getActionsAndTableElements();
    my $apiKeyRowsCountPre = (ref $apiKeyRows eq 'HASH') ? scalar(keys(%$apiKeyRows)) : 0;
    $actionElements->{generateNewKey}->click();
    $self->debugTakeSessionSnapshot();

    ($actionElements, $apiKeyRows) = $self->_getActionsAndTableElements();
    my $apiKeyRowsCountPost = (ref $apiKeyRows eq 'HASH') ? scalar(keys(%$apiKeyRows)) : 0;
    is($apiKeyRowsCountPre+1, $apiKeyRowsCountPost, "ApiKey generated");
    return $self;
}

sub revokeApiKey {
    my ($self, $apiKey) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($actionElements, $apiKeyRows) = $self->_getActionsAndTableElements();
    my $apiKeyRow = $apiKeyRows->{$apiKey};
    Koha::Exception::UnknownObject->throw(error => __PACKAGE__."revokeApiKey():> No matching apiKey '$apiKey' found.") unless $apiKeyRow;
    $apiKeyRow->{revoke}->click();
    $self->debugTakeSessionSnapshot();

    ($actionElements, $apiKeyRows) = $self->_getActionsAndTableElements();
    $apiKeyRow = $apiKeyRows->{$apiKey};
    Koha::Exception::UnknownObject->throw(error => __PACKAGE__."revokeApiKey():> No matching apiKey '$apiKey' found after revoking it.") unless $apiKeyRow;
    is($apiKeyRow->{active}, 'No', "ApiKey revoked");
    return $self;
}

sub activateApiKey {
    my ($self, $apiKey) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($actionElements, $apiKeyRows) = $self->_getActionsAndTableElements();
    my $apiKeyRow = $apiKeyRows->{$apiKey};
    Koha::Exception::UnknownObject->throw(error => __PACKAGE__."revokeApiKey():> No matching apiKey '$apiKey' found.") unless $apiKeyRow;
    $apiKeyRow->{activate}->click();
    $self->debugTakeSessionSnapshot();

    ($actionElements, $apiKeyRows) = $self->_getActionsAndTableElements();
    $apiKeyRow = $apiKeyRows->{$apiKey};
    Koha::Exception::UnknownObject->throw(error => __PACKAGE__."revokeApiKey():> No matching apiKey '$apiKey' found after activating it.") unless $apiKeyRow;
    is($apiKeyRow->{active}, 'Yes', "ApiKey activated");
    return $self;
}

sub deleteApiKey {
    my ($self, $apiKey) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($actionElements, $apiKeyRows) = $self->_getActionsAndTableElements();
    my $apiKeyRowsCountPre = (ref $apiKeyRows eq 'HASH') ? scalar(keys(%$apiKeyRows)) : 0;
    my $apiKeyRow = $apiKeyRows->{$apiKey};
    Koha::Exception::UnknownObject->throw(error => __PACKAGE__."revokeApiKey():> No matching apiKey '$apiKey' found.") unless $apiKeyRow;
    $apiKeyRow->{delete}->click();
    $self->debugTakeSessionSnapshot();

    ($actionElements, $apiKeyRows) = $self->_getActionsAndTableElements();
    my $apiKeyRowsCountPost = (ref $apiKeyRows eq 'HASH') ? scalar(keys(%$apiKeyRows)) : 0;
    is($apiKeyRowsCountPre-1, $apiKeyRowsCountPost, "ApiKey deleted");
    return $self;
}

1; #Make the compiler happy!
