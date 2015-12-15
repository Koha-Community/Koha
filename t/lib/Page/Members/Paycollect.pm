package t::lib::Page::Members::Paycollect;

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

use Selenium::Remote::WDKeys;

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Members::Paycollect

=head SYNOPSIS

paycollect.pl PageObject providing page functionality as a service!

=cut

=head new

    my $paycollect = t::lib::Page::Members::Paycollect->new({borrowernumber => "1", selected => "1,2,3,4,5"});

Instantiates a WebDriver and loads the members/paycollect.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    borrowernumber => loads the page to display Borrower matching the given borrowernumber

@RETURNS t::lib::Page::Members::Paycollect, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/members/paycollect.pl';
    $params->{type}     = 'staff';

    $params->{getParams} = [];
    #Handle MANDATORY parameters
    if ($params->{borrowernumber}) {
        push @{$params->{getParams}}, "borrowernumber=".$params->{borrowernumber};
    }
    else {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->new():> Parameter 'borrowernumber' is missing.");
    }

    if ($params->{selected}) {
        push @{$params->{getParams}}, "selected=".$params->{selected};
    }

    my $self = $class->SUPER::new($params);

    return $self;
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################

sub addNewCashRegister {
    my ($self, $cashregisternumber) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $input = $d->find_element("input[id='office_new']", 'css');
    $input->clear();
    $input->send_keys($cashregisternumber);
    my $button = $d->find_element("button[id='new_office']", 'css');
    $button->click();

    my $ok = 1 if $d->find_element("button[id='office-".$cashregisternumber."']",'css');
    ok($ok, "Intra Added a new cash register '".$cashregisternumber."'");

    $self->debugTakeSessionSnapshot();

    return $self;
}

sub addNoteToSelected {
    my ($self, $note) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $input = $d->find_element("textarea[id='selected_accts_notes']", 'css');
    $input->clear();
    $input->send_keys($note);

    $self->debugTakeSessionSnapshot();

    return $self;
}

sub confirmPayment {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $confirm = $d->find_element("input[name='submitbutton'][type='submit']",'css');

    $confirm->click();

    ok(1, "Intra Confirmed payment");
    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Paycollect->rebrandFromPageObject($self);
}

sub openAddNewCashRegister {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $link = $d->find_element("span[id='add_new_office'] a", 'css');
    $link->click();
    ok($d->find_element("input[id='office_new']",'css'), "Intra Opened input for adding a new cash register");

    $self->debugTakeSessionSnapshot();

    return $self;
}

sub paymentLoadingScreen {
    my ($self, $cashregisternumber) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $ok = 1 if $d->find_element("button[id='recheck']",'css');

    ok($ok, "Intra Payment loading screen open");

    return $self;
}

sub selectCashRegister {
    my ($self, $cashregisternumber) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $cashregister = $d->find_element("button[id='office-".$cashregisternumber."']",'css');

    $cashregister->click();

    my $ok = 1 if $d->find_element("button[id='office-".$cashregisternumber."'][class='office-button selected']",'css');
    ok($ok, "Intra Selected cash register '".$cashregisternumber."'");
    $self->debugTakeSessionSnapshot();

    return $self;
}

sub sendPaymentToPOS {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $confirm = $d->find_element("input[name='submitbutton'][type='submit']",'css');

    # $confirm->click() is broken. It doesn't move on until AJAX at next page is completed. Need to use
    # alternative method. Click submit with JavaScript and poll until loading screen is open.
    my $script = q{
        $("input[name='submitbutton'][type='submit']").click();
    };
    $d->execute_script($script);

    my $func = undef; # we only need to poll for success
    my $success = sub {
        eval {
            my $el = $d->find_element("button[id='recheck']",'css');
        };
        if ($@) {
            return 0;
        }
        return 1;
    };

    $self->poll($func, $success, 50, 100); # poll for max 5 seconds

    ok(1, "Intra Sent payment to cash register");
    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Paycollect->rebrandFromPageObject($self);
}

sub setAmount {
    my ($self, $amount) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $input = $d->find_element("input[name='paid']", 'css');
    # Clear and send_keys did not work. Set values by JS
    my $script = qq(('#paid').val('$amount'););
    $d->execute_script('$'.$script);

    is($input->get_value(), $amount, "Intra Set payment amount to ".$amount);
    $self->debugTakeSessionSnapshot();

    return $self;
}

sub waitUntilPaymentIsAcceptedAtPOS {
    my ($self) = @_;

    return waitUntilPaymentIsCompletedAtPOS($self, "paid");
}
sub waitUntilPaymentIsCancelledAtPOS {
    my ($self) = @_;

    return waitUntilPaymentIsCompletedAtPOS($self, "cancelled");
}
sub waitUntilPaymentIsCompletedAtPOS {
    my ($self, $status) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $recheck = $d->find_element("button[id='recheck']",'css');

    my $func = undef; # we only need to poll for success
    my $success = sub {
        eval {
            my $el = $d->find_element("span#status span.".$status."[style*='inline-block']",'css');
        };
        if ($@) {
            return 0;
        }
        return 1;
    };

    $self->poll($func, $success, 50, 100); # poll for max 5 seconds

    ok(1, "Payment is completed");
    $self->debugTakeSessionSnapshot();

    # Poll until "recheck" button is not found. This means we have been
    # redirected to Boraccount
    $func = undef; # we only need to poll for success
    $success = sub {
        eval {
            my $el = $d->find_element("button[id='recheck']",'css');
        };
        if ($@) {
            return 1;
        }
        return 0;
    };

    $self->poll($func, $success, 50, 100); # poll for max 5 seconds

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Boraccount->rebrandFromPageObject($self);
}

1; #Make the compiler happy!
