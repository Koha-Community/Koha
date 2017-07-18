package t::lib::Page::Circulation::Waitingreserves;

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

use base qw(t::lib::Page::Intra);

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Circulation::Waitingreserve

=head SYNOPSIS

waitingreserves.pl PageObject providing page functionality as a service!

=cut

=head new

    my $circulation = t::lib::Page::Circulation::Waitingreserves->new({borrowernumber => "1"});

Instantiates a WebDriver and loads the circ/waitingreserves.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
Optional extra parameters:
    allbranches => 1 #Show reserves from all branches

@RETURNS t::lib::Page::Circulation::Waitingreserves, ready for user actions!

=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/circ/waitingreserves.pl';
    $params->{type}     = 'staff';

    $params->{getParams} = [];
    #Handle optional parameters
    if ($params->{allbranches}) {
        push @{$params->{getParams}}, "allbranches=".$params->{allbranches};
    }

    my $self = $class->SUPER::new($params);

    #Set special page-dependent parameters
    $self->{waitingreserves}->{tabDisplayed} = 'waiting';
    return $self;
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

sub _getTablist {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $holdswaiting_a = $d->find_element("ul a[href*='#holdswaiting']", 'css');
    my $holdsover_a = $d->find_element("ul a[href*='#holdsover']", 'css');

    my $e = {};
    $e->{holdswaiting} = $holdswaiting_a;
    $e->{holdsover} = $holdsover_a;
    return $e;
}

=head _getHoldsRows
    @RETURNS HASHRef of
         HASHRef of HASHes of Selenium::Driver::Webelement-objects matching the table rows and columns.
         Also some special identifiers will be extracted.
         eg. {
            "1" => {
                waitingdate => Selenium::Driver::Webelement,
                lastpickupdate => Selenium::Driver::Webelement,
                ...
                barcode => '167N03651343',
                biblionumber => 854323,
            },
            "2" => {
                ...
            }
         }

=cut
sub _getHoldsRows {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $waitingOrOverdue = $self->{waitingreserves}->{tabDisplayed};
    my $tableId = ($waitingOrOverdue && $waitingOrOverdue eq 'overdue') ? 'holdso' : 'holdst';

    my $holdsRows_tr;
    eval { #We might not have any rows
        $holdsRows_tr = $d->find_elements("table#$tableId tbody tr", 'css');
    };
    my %holdsRows;
    for(my $i=0 ; $i<scalar(@$holdsRows_tr) ; $i++) {
        #Iterate every apiKey in the apiKeys table and prefetch the interesting data as text and available action elements.
        my $row = $holdsRows_tr->[$i];
        $row->{waitingdate}    = $d->find_child_element($row, "td.waitingdate", 'css');
        $row->{lastpickupdate} = $d->find_child_element($row, "td.lastpickupdate", 'css');
        $row->{resobjects}     = $d->find_child_element($row, "td.resobjects", 'css');
        $row->{borrower}       = $d->find_child_element($row, "td.borrower", 'css');
        $row->{othernames}     = $d->find_child_element($row, "span.title", 'css');
        $row->{location}       = $d->find_child_element($row, "td.homebranch", 'css');
        $row->{copynumber}     = $d->find_child_element($row, "td.copynumber", 'css');
        $row->{enumchron}      = $d->find_child_element($row, "td.enumchron", 'css');
        $row->{action}         = $d->find_child_element($row, "td.action", 'css');
        $holdsRows{$i} = $row;

        #Extract textual identifiers
        my $titleText = $row->{resobjects}->get_text();
        if ($titleText =~ /Barcode:\s+(\S+)/) {
            $row->{barcode} = $1;
        }
        else {
            warn __PACKAGE__."->assertHoldRowsVisible():> Couldn't extract barcode from title-column '$titleText'\n";
        }
    }

    return \%holdsRows;
}

################################################################################
=head PageObject Services

=cut
################################################################################

sub viewAllLibraries {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $view_all_libraries_a = $d->find_element("a[href*='waitingreserves.pl?allbranches=1']", 'css');
    $view_all_libraries_a->click();

    $self->debugTakeSessionSnapshot();
    return $self;
}

sub showHoldsWaiting {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $e = $self->_getTablist();
    my $showWaiting_a = $e->{holdswaiting};
    $showWaiting_a->click();
    $self->{waitingreserves}->{tabDisplayed} = 'waiting';

    $self->debugTakeSessionSnapshot();
    return $self;
}

sub showHoldsOver {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $e = $self->_getTablist();
    my $showOver_a = $e->{holdsover};
    $showOver_a->click();
    $self->{waitingreserves}->{tabDisplayed} = 'overdue';

    $self->debugTakeSessionSnapshot();
    return $self;
}

=head assertHoldRowsVisible

@PARAM1 ARRAYref of HASHes. Represents the holds that must be present in the displayed holds table
        eg. [{
            barcode => '167N0032112',
        },
        ]
@RETURN t::lib::Page::Circulation::Waitingreserves-object
=cut
sub assertHoldRowsVisible {
    my ($self, $holds) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $holdRows = $self->_getHoldsRows();
    for (my $i=0 ; $i<scalar(@$holds) ; $i++) {
        my $h = $holds->[$i];
        my $targetRow = $holdRows->{ $i };
        is($targetRow->{barcode}, $h->{barcode},
           "assertHoldRowsVisible: Row ".$i." barcodes '".$targetRow->{barcode}."' and '".$h->{barcode}."' match.");
        is($targetRow->{othernames}->get_text(),$h->{borrower}->othernames,
           "assertHoldRowsVisible: Row ".$i." othername '".$h->{borrower}->othernames."' contained in ".$targetRow->{othernames}->get_text()."'.");
    }

    return $self;
}

1;
