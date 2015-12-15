package t::lib::Page::Members::Boraccount;

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

use t::lib::Page::Members::ApiKeys;

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Members::Boraccount

=head SYNOPSIS

boraccount.pl PageObject providing page functionality as a service!

=cut

=head new

    my $boraccount = t::lib::Page::Members::Boraccount->new({borrowernumber => "1"});

Instantiates a WebDriver and loads the members/boraccount.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    borrowernumber => loads the page to display Borrower matching the given borrowernumber

@RETURNS t::lib::Page::Members::Boraccount, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/members/boraccount.pl';
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

sub navigateToPayFinesTab {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $tab = $d->find_element("div.statictabs ul li a[href*='pay.pl?borrowernumber=']", 'css');
    $tab->click();
    ok($d->get_title() =~ m/Pay Fines for/, "Intra Navigate to Pay fines tab");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Pay->rebrandFromPageObject($self);
}

sub findFine {
    my ($self, $note) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $payment_note = $d->find_element("//td[text() = \"".$note."\"]", "xpath");

    ok(1, "Intra Found payment with note ".$note);

    return $self;
}

sub isFinePaid {
    my ($self, $note, $noteColumnIndex, $amountOutstandingColumnIndex) = @_;

    return isFineAmountOutstanding($self, $note, "0.00", $noteColumnIndex, $amountOutstandingColumnIndex);
}

sub isFineAmount {
    my ($self, $note, $amount, $noteColumnIndex, $amountColumnIndex) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    $noteColumnIndex = 3 if not defined $noteColumnIndex;
    $amountColumnIndex = 4 if not defined $amountColumnIndex;

    # If POS integration is enabled, add 1 to index (because of column "transaction id")
    if (C4::Context->preference("POSIntegration") ne "OFF") {
        $noteColumnIndex++;
        $amountColumnIndex++;
    }

    my $fine = $d->find_element("//tr[(td[".$noteColumnIndex."][text()=\"".$note."\"]) and (td[".$amountColumnIndex."][text()=\"".$amount."\"])]", "xpath");

    ok(1, "Intra Found payment with note ".$note." and amount ".$amount);

    return $self;
}

sub isFineAmountOutstanding {
    my ($self, $note, $amountOutstanding, $noteColumnIndex, $amountOutstandingColumnIndex) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    $noteColumnIndex = 3 if not defined $noteColumnIndex;
    $amountOutstandingColumnIndex = 5 if not defined $amountOutstandingColumnIndex;

    # If POS integration is enabled, add 1 to index (because of column "transaction id")
    if (C4::Context->preference("POSIntegration") ne "OFF") {
        $noteColumnIndex++;
        $amountOutstandingColumnIndex++;
    }

    my $fine = $d->find_element("//tr[(td[".$noteColumnIndex."][text()=\"".$note."\"]) and (td[".$amountOutstandingColumnIndex."][text()=\"".$amountOutstanding."\"])]", "xpath");

    ok(1, "Intra Found payment with note ".$note." and amountoutstanding ".$amountOutstanding);

    return $self;
}

sub isTransactionComplete {
    my ($self, $transactionnumber) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $transaction_columns = $d->find_element("//td[contains(\@class, 'transactionnumber') and text() = '".$transactionnumber."']", "xpath");

    ok(1, "Intra Found transaction, number ".$transactionnumber);

    return $self;
}

1; #Make the compiler happy!
