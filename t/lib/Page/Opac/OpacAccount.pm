package t::lib::Page::Opac::OpacAccount;

# Copyright 2016 KohaSuomi
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
# You should have received a copy of the GNU General Public Lice strongnse
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Scalar::Util qw(blessed);
use Test::More;

use t::lib::Page::Opac::OpacAccount;
use t::lib::Page::Opac::OpacPaycollect;

use base qw(t::lib::Page::Opac t::lib::Page::Opac::LeftNavigation);

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Opac::OpacAccount

=head SYNOPSIS

PageObject providing page functionality as a service!

=cut

=head new

    my $opacaccount = t::lib::Page::Opac::OpacAccount->new();

Instantiates a WebDriver and loads the opac/opac-account.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    none atm.

@RETURNS t::lib::Page::Opac::OpacAccount, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/opac-account.pl';
    $params->{type}     = 'opac';

    my $self = $class->SUPER::new($params);

    return $self;
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

sub findFine {
    my ($self, $note) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $payment_note = $d->find_element("//td[contains(.,\"".$note."\")]", "xpath");

    ok(1, "Opac Found payment with description ".$note);

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

    $noteColumnIndex = 2 if not defined $noteColumnIndex;
    $amountColumnIndex = 3 if not defined $amountColumnIndex;

    my $fine = $d->find_element("//tr[(td[".$noteColumnIndex."][contains(.,\"".$note."\")]) and (td[".$amountColumnIndex."][text()=\"".$amount."\"])]", "xpath");

    ok(1, "Opac Found payment with note ".$note." and amount ".$amount);

    return $self;
}

sub isFineAmountOutstanding {
    my ($self, $note, $amountOutstanding, $noteColumnIndex, $amountOutstandingColumnIndex) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    $noteColumnIndex = 2 if not defined $noteColumnIndex;
    $amountOutstandingColumnIndex = 4 if not defined $amountOutstandingColumnIndex;

    my $fine = $d->find_element("//tr[(td[".$noteColumnIndex."][contains(.,\"".$note."\")]) and (td[".$amountOutstandingColumnIndex."][text()=\"".$amountOutstanding."\"])]", "xpath");

    ok(1, "Opac Found payment with note ".$note." and amountoutstanding ".$amountOutstanding);

    return $self;
}

sub isEverythingPaid {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $transaction_columns = $d->find_element("//td[contains(\@class, 'sum') and text() = '0.00']", "xpath");

    ok(1, "Opac Found total due 0.00, no outstanding fines");

    return $self;
}

sub PayFines {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $payButton = $d->find_element("button.pay-fines", "css");

    $payButton->click();

    return t::lib::Page::Opac::OpacPaycollect->rebrandFromPageObject($self);;
}

1;
