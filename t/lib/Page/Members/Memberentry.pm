package t::lib::Page::Members::Memberentry;

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
    $params->{resource} = '/cgi-bin/koha/members/memberentry.pl';
    $params->{type}     = 'staff';

    $params->{getParams} = [];
    #Handle MANDATORY parameters
    if ($params->{borrowernumber}) {
        push @{$params->{getParams}}, "borrowernumber=".$params->{borrowernumber};
    }
    else {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__."->new():> Parameter 'borrowernumber' is missing.");
    }
    push @{$params->{getParams}}, "destination=".$params->{destination} if $params->{destination};
    push @{$params->{getParams}}, "op=".$params->{op} if $params->{op};
    push @{$params->{getParams}}, "categorycode=".$params->{categorycode} if $params->{categorycode};
    my $self = $class->SUPER::new($params);

    return $self;
}

################################################################################
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
=cut
################################################################################


sub _getInputFieldsForValidation {
    my ($self) = @_;
    my $d = $self->getDriver();

    my ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput, $SMSnumber);
    eval {
        $emailInput  = $d->find_element('#email');
    };
    eval {
        $emailProInput  = $d->find_element('#emailpro');
    };
    eval {
        $email_BInput  = $d->find_element('#B_email');
    };
    eval {
        $phoneInput  = $d->find_element('#phone');
    };
    eval {
        $phoneProInput  = $d->find_element('#phonepro');
    };
    eval {
        $phone_BInput  = $d->find_element('#B_phone');
    };
    eval {
        $SMSnumber = $d->find_element('#SMSnumber');
    };

    return ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput, $SMSnumber);
}

sub _getMessagingPreferenceCheckboxes {
    my ($self) = @_;
    my $d = $self->getDriver();

    my @email_prefs = $d->find_elements('input[type="checkbox"][id^="email"]');
    my @phone_prefs = $d->find_elements('input[type="checkbox"][id^="phone"]');
    my @sms_prefs = $d->find_elements('input[type="checkbox"][id^="sms"]');

    return  { email => \@email_prefs, phone => \@phone_prefs, sms => \@sms_prefs };
}


################################################################################
=head PageObject Services

=cut
################################################################################

sub checkMessagingPreferencesSet {
    my ($self, $valid, @prefs) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    foreach my $type (@prefs){
        my @this_pref = $d->find_elements('input[type="checkbox"][id^="'.$type.'"]');

        my $ok = 0;

        foreach my $checkbox (@this_pref){
            ok(0, "Intra Memberentry $type messaging checkbox ".$checkbox->get_attribute('id')." not checked") if !$checkbox->is_selected() and $valid;
            ok(0, "Intra Memberentry $type messaging checkbox ".$checkbox->get_attribute('id')." checked (not supposed to be)") if $checkbox->is_selected() and !$valid;
            $ok = 1;
        }
        ok($ok, "Intra Memberentry $type messaging checkboxes ok (all " . (($valid) ? 'checked':'unchecked') . ")");
    }

    return $self;
}

sub clearMessagingContactFields {
    my ($self, @fields) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput, $SMSnumber) = $self->_getInputFieldsForValidation();

    if (@fields) {
        for my $field (@fields){
            $emailInput->clear() if $field eq "email";
            $emailProInput->clear() if $field eq "emailpro";
            $email_BInput->clear() if $field eq "B_email";
            $phoneInput->clear() if $field eq "phone";
            $phoneProInput->clear() if $field eq "phonepro";
            $phone_BInput->clear() if $field eq "B_phone";
            $SMSnumber->clear() if $field eq "SMSnumber";
        }
        ok(1, "Intra Memberentry contact fields (@fields) cleared");
    } else {
        $emailInput->clear();
        $emailProInput->clear();
        $email_BInput->clear();
        $phoneInput->clear();
        $phoneProInput->clear();
        $phone_BInput->clear();
        $SMSnumber->clear();
        ok(1, "Intra Memberentry contact fields (email, emailpro, email_B, phone, phonepro, phone_B, SMSnumber) cleared");
    }

    return $self;
}

sub checkPreferences {
    my ($self, $valid, $type) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $checkboxes = $self->_getMessagingPreferenceCheckboxes();

    ok (0, "Intra $type checkboxes not defined") if not defined $checkboxes->{$type};
    return 0 if not defined $checkboxes->{$type};

    foreach my $checkbox (@{ $checkboxes->{$type} }){
        ok(0, "Intra Memberentry $type messaging checkbox ".$checkbox->get_attribute('id')." not available") if !$checkbox->is_enabled() and $valid;
        ok(0, "Intra Memberentry $type messaging checkbox ".$checkbox->get_attribute('id')." available (not supposed to be)") if $checkbox->is_enabled() and !$valid;

        $checkbox->click() if not $checkbox->is_selected();
    }
    ok (1, "Intra Memberentry $type messaging checkboxes checked") if $valid;

    return $self;
}
sub setEmail {
    my ($self, $input) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput, $SMSnumber) = $self->_getInputFieldsForValidation();

    $emailInput->clear();
    $emailProInput->clear();
    $email_BInput->clear();
    $emailInput->send_keys($input);
    $emailProInput->send_keys($input);
    $email_BInput->send_keys($input);
    ok(1, "Intra Memberentry Wrote \"$input\" to email fields.");

    return $self;
}

sub setPhone {
    my ($self, $input) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput, $SMSnumber) = $self->_getInputFieldsForValidation();

    $phoneInput->clear();
    $phoneProInput->clear();
    $phone_BInput->clear();
    $phoneInput->send_keys($input);
    $phoneProInput->send_keys($input);
    $phone_BInput->send_keys($input);
    ok(1, "Intra Memberentry Wrote \"$input\" to phone fields.");

    return $self;
}

sub setSMSNumber {
    my ($self, $input) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput, $SMSnumber) = $self->_getInputFieldsForValidation();

    $SMSnumber->clear();
    $SMSnumber->send_keys($input);
    ok(1, "Intra Memberentry Wrote \"$input\" to SMSnumber.");

    return $self;
}

sub submitForm {
    my ($self, $valid) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    eval {
        my $holdsIdentifier = $d->find_element('#othernames');
        $holdsIdentifier->click();
    };
    my $submitButton = $d->find_element('form#entryform input[type="submit"]');
    $submitButton->submit();
    $self->debugTakeSessionSnapshot();

    if ($valid) {
        my $submitted = $d->find_element("#editpatron", 'css');
        ok(1, "Intra Memberentry Submit changes success");
        return t::lib::Page::Circulation::Circulation->rebrandFromPageObject($self);
    } else {
        my @notsubmitted = $d->find_elements('form#entryform label[class="error"]', 'css');
        my $error_ids = "";

        foreach my $el_id (@notsubmitted){
            my $attr_id = $el_id->get_attribute("for");
            $error_ids .=  "'".$attr_id . "' ";
        }

        ok(1, "Intra Memberentry Submit changes ". $error_ids .", validation error (as expected).");
        $d->refresh();
        return $self;
    }
}

1;