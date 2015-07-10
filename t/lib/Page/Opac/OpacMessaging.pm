package t::lib::Page::Opac::OpacMessaging;

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
# You should have received a copy of the GNU General Public Lice strongnse
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Scalar::Util qw(blessed);
use Test::More;

use t::lib::Page::Opac::OpacUser;

use base qw(t::lib::Page::Opac t::lib::Page::Opac::LeftNavigation);

use Koha::Exception::BadParameter;

=head NAME t::lib::Page::Opac::OpacMessaging

=head SYNOPSIS

PageObject providing page functionality as a service!

=cut

=head new

    my $opacmemberentry = t::lib::Page::Opac::OpacMessaging->new();

Instantiates a WebDriver and loads the opac/opac-messaging.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    none atm.

@RETURNS t::lib::Page::Opac::OpacMessaging, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/opac-messaging.pl';
    $params->{type}     = 'opac';

    my $self = $class->SUPER::new($params);

    return $self;
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
=head UI Mapping helper subroutines
See. Selenium documentation best practices for UI element mapping to common language descriptions.
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
            ok(0, "Opac Messaging $type checkbox ".$checkbox->get_attribute('id')." not checked") if !$checkbox->is_selected() and $valid;
            ok(0, "Opac Messaging $type checkbox ".$checkbox->get_attribute('id')." checked (not supposed to be)") if $checkbox->is_selected() and !$valid;
            $ok = 1;
        }
        ok($ok, "Opac Messaging $type checkboxes ok (all " . (($valid) ? 'checked':'unchecked') . ")");
    }

    return $self;
}

1;
