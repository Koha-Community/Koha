package t::lib::Page::Members::Moremember;

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

=head NAME t::lib::Page::Members::Moremember

=head SYNOPSIS

moremember.pl PageObject providing page functionality as a service!

=cut

=head new

    my $moremember = t::lib::Page::Members::Moremember->new({borrowernumber => "1"});

Instantiates a WebDriver and loads the members/moremember.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    borrowernumber => loads the page to display Borrower matching the given borrowernumber

@RETURNS t::lib::Page::Members::Moremember, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/members/moremember.pl';
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

sub _getEditLinks {
    my ($self) = @_;
    my $d = $self->getDriver();

    my $patron_info_edit = $d->find_element("div#patron-information div.action a[href*='memberentry.pl?op=modify'][href*='step=1']", 'css');
    my $sms_number_edit = $d->find_element("div.action a[href*='memberentry.pl?op=modify'][href*='step=5']", 'css');
    my $library_use_edit = $d->find_element("div.action a[href*='memberentry.pl?op=modify'][href*='step=3']", 'css');
    my $alternate_addr_edit = $d->find_element("div.action a[href*='memberentry.pl?op=modify'][href*='step=6']", 'css');
    my $alternative_contact_edit = $d->find_element("div.action a[href*='memberentry.pl?op=modify'][href*='step=2']", 'css');

    my $e = {};
    $e->{patron_information} = $patron_info_edit if $patron_info_edit;
    $e->{smsnumber} = $sms_number_edit if $sms_number_edit;
    $e->{library_use} = $library_use_edit if $library_use_edit;
    $e->{alternate_address} = $alternate_addr_edit if $alternate_addr_edit;
    $e->{alternative_contact} = $alternative_contact_edit if $alternative_contact_edit;
    return $e;
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
            ok(0, "Intra Moremember $type messaging checkbox ".$checkbox->get_attribute('id')." not checked") if !$checkbox->is_selected() and $valid;
            ok(0, "Intra Moremember $type messaging checkbox ".$checkbox->get_attribute('id')." checked (not supposed to be)") if $checkbox->is_selected() and !$valid;
            $ok = 1;
        }
        ok($ok, "Intra Moremember $type messaging checkboxes ok (all " . (($valid) ? 'checked':'unchecked') . ")");
    }

    return $self;
}

sub navigateToPatronInformationEdit {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getEditLinks();
    $elements->{patron_information}->click();
    ok($d->get_title() =~ m/Modify(.*)patron/, "Intra Navigate to Modify patron information");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Memberentry->rebrandFromPageObject($self);
}

sub navigateToSMSnumberEdit {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getEditLinks();
    $elements->{smsnumber}->click();
    ok($d->get_title() =~ m/Modify(.*)patron/, "Intra Navigate to Modify patron SMS number");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Memberentry->rebrandFromPageObject($self);
}

sub navigateToLibraryUseEdit {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getEditLinks();
    $elements->{library_use}->click();
    ok($d->get_title() =~ m/Modify(.*)patron/, "Intra Navigate to Modify patron Library use");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Memberentry->rebrandFromPageObject($self);
}

sub navigateToAlternateAddressEdit {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getEditLinks();
    $elements->{alternate_address}->click();
    ok($d->get_title() =~ m/Modify(.*)patron/, "Intra Navigate to Modify patron Alternate address");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Memberentry->rebrandFromPageObject($self);
}

sub navigateToAlternativeContactEdit {
    my ($self) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $elements = $self->_getEditLinks();
    $elements->{alternative_contact}->click();
    ok($d->get_title() =~ m/Modify(.*)patron/, "Intra Navigate to Modify patron Alternative contact");

    $self->debugTakeSessionSnapshot();

    return t::lib::Page::Members::Memberentry->rebrandFromPageObject($self);
}



1; #Make the compiler happy!
