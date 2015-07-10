package t::lib::Page::Opac::OpacMemberentry;

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

=head NAME t::lib::Page::Opac::OpacMemberentry

=head SYNOPSIS

PageObject providing page functionality as a service!

=cut

=head new

    my $opacmemberentry = t::lib::Page::Opac::OpacMemberentry->new();

Instantiates a WebDriver and loads the opac/opac-memberentry.pl.
@PARAM1 HASHRef of optional and MANDATORY parameters
MANDATORY extra parameters:
    none atm.

@RETURNS t::lib::Page::Opac::OpacMemberentry, ready for user actions!
=cut

sub new {
    my ($class, $params) = @_;
    unless (ref($params) eq 'HASH' || (blessed($params) && $params->isa('t::lib::Page') )) {
        $params = {};
    }
    $params->{resource} = '/cgi-bin/koha/opac-memberentry.pl';
    $params->{type}     = 'opac';

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

    my $emailInput  = $d->find_element('#borrower_email');
    my $emailProInput  = $d->find_element('#borrower_emailpro');
    my $email_BInput  = $d->find_element('#borrower_B_email');

    my $phoneInput  = $d->find_element('#borrower_phone');
    my $phoneProInput  = $d->find_element('#borrower_phonepro');
    my $phone_BInput  = $d->find_element('#borrower_B_phone');

    return ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput);
}


################################################################################
=head PageObject Services

=cut
################################################################################

=head isFieldsAvailable

    $page->isFieldsAvailable();

@RETURN t::lib::Page-object
@CROAK if unable to find required fields.
=cut

sub setEmail {
    my ($self, $input) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput) = $self->_getInputFieldsForValidation();

    $emailInput->send_keys($input);
    $emailProInput->send_keys($input);
    $email_BInput->send_keys($input);
    ok(1, "OpacMemberentry Wrote \"$input\" to email fields.");

    return $self;
}

sub setPhone {
    my ($self, $input) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my ($emailInput, $emailProInput, $email_BInput, $phoneInput, $phoneProInput, $phone_BInput) = $self->_getInputFieldsForValidation();

    $phoneInput->send_keys($input);
    $phoneProInput->send_keys($input);
    $phone_BInput->send_keys($input);
    ok(1, "OpacMemberentry Wrote \"$input\" to phone fields.");

    return $self;
}

sub submitForm {
    my ($self, $valid) = @_;
    my $d = $self->getDriver();
    $self->debugTakeSessionSnapshot();

    my $submitButton = $d->find_element('form#memberentry-form input[type="submit"]');
    $submitButton->click();

    $self->debugTakeSessionSnapshot();

    if ($valid) {
        my $submitted = $d->find_element('#update-submitted');
        ok(1, "OpacMemberentry Submit changes success");
    } else {
        my @notsubmitted = $d->find_elements('form#memberentry-form label[id^="borrower_"][id$="-error"]', 'css');
        my $error_ids = "";

        foreach my $el_id (@notsubmitted){
            my $attr_id = $el_id->get_attribute("id");
            $attr_id =~ s/borrower_//g;
            $attr_id =~ s/-error//g;
            $error_ids .=  "'".$attr_id . "' ";
        }

        ok(1, "OpacMemberentry Submit changes ". $error_ids .", validation error (as expected).");
    }



    return t::lib::Page::Opac::OpacUser->rebrandFromPageObject($self);
}

1;