package t::lib::Page::Members::Notices;

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

use base qw(t::lib::Page::Intra t::lib::Page::Members::Toolbar t::lib::Page::Members::LeftNavigation);

use Koha::Exception::BadParameter;

use t::lib::Page::Circulation::Circulation;


sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/members/notices.pl';
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

sub _getNoticesTable {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $e = {};

    eval {
        $e->{noticestable_headers} = $d->find_elements("#noticestable th", 'css');
    };
    eval {
        $e->{noticestable_cells} = $d->find_elements("#noticestable td", 'css');
    };
    eval {
        $e->{noticestable_rows} = $d->find_elements("#noticestable tr", 'css');
    };

    return $e;
}

################################################################################
=head PageObject Services

=cut
################################################################################


# column and row first index is 1
sub getTextInColumnAtRow {
    my ($self, $searchText, $params) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    if (not exists $params->{column} or not exists $params->{row} or
        not $params->{column} or not $params->{row}) {
        warn "t::lib::Page::Members::Notices->getColumnAtRow must be called with column and row numbers, e.g. {column => 1, row=1}";
    }

    my $col = $params->{column};
    my $row = $params->{row};

    my $cell = $d->find_element("#noticestable tr:nth-child($row) td:nth-child($col)");

    ok(($cell->get_text() =~ /^(.*)$searchText(.*)$/), "Intra Notices Text \"$searchText\" found at column ".
       $params->{column}." row ".$params->{row}." matches \"".$cell->get_text()."\".");

    return $self;
}

sub hasDeliveryNoteColumnInNoticesTable {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getNoticesTable();

    my $headers = $elements->{noticestable_headers};

    my $hasDeliveryNote = 0;

    foreach my $header(@$headers){
        $hasDeliveryNote = 1 if ($header->get_text() =~ /^Delivery note$/);
    }

    ok($hasDeliveryNote, "Intra Notices Table has all headings");

    return $self;
}

sub hasTextInTableCell {
    my ($self, $txt) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getNoticesTable();

    my $cells = $elements->{noticestable_cells};

    my $hasText = 0;

    foreach my $cell(@$cells){
        $hasText = 1 if ($cell->get_text() =~ /^(.*)$txt(.*)$/);
    }

    ok($hasText, "Intra Notices Found text '$txt' from table");

    return $self;
}

sub verifyNoMessages {
    my ($self, $note) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $dialog = $d->find_element("div.yui-b div.dialog", 'css')->get_text();

    ok($dialog =~ /^There is no record of any(.*)$/, "Intra Notices No messages sent");

    return $self;
}

sub openNotice {
    my ($self, $titleText) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my @titles = $d->find_elements(".notice-title", 'css');

    my $opened = 0;
    foreach my $title (@titles){
        if ($title->get_text() eq $titleText) {
            $title->click();
            $opened++;
        }
    }

    ok(($opened > 0), "Opened ". $opened ." notices '".$titleText."' successfully.");

    return $self;
}

sub resendMessage {
    my ($self, $titleText, $shouldSucceed) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my @resendLinks = $d->find_elements('//tr/td[a//text()[contains(.,\''.$titleText.'\')]]/following-sibling::td[2]/div/a[text()=\'Resend\']', 'xpath');

    my $resent = 0;
    foreach my $link (@resendLinks){
        $link->click();
        $resent++;
    }
    is(($resent > 0) ? 1:0, $shouldSucceed, "Resent ". $resent ." notices '".$titleText."' successfully.");

    return $self;
}

1;
