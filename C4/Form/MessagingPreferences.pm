package C4::Form::MessagingPreferences;

# Copyright 2008-2009 LibLime
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

use strict;
use warnings;

use CGI qw ( -utf8 );
use C4::Context;
use C4::Debug;
use Koha::Patron::Message::Preferences;
use Koha::Patrons;

use constant MAX_DAYS_IN_ADVANCE => 30;

=head1 NAME

C4::Form::MessagingPreferences - manage messaging preferences form

=head1 SYNOPSIS

In script:

    use C4::Form::MessagingPreferences;
    C4::Form::MessagingPreferences::set_form_value({ borrowernumber => 51 }, $template);
    C4::Form::MessagingPreferences::handle_form_action($input, { categorycode => 'CPL' }, $template);

In HTML template:

    <!-- TMPL_INCLUDE NAME="messaging-preference-form.inc" -->

=head1 DESCRIPTION

This module manages input and output for the messaging preferences form
that is used in the staff patron editor, the staff patron category editor,
and the OPAC patron messaging prefereneces form.  It in its current form,
it essentially serves only to eliminate copy-and-paste code, but suggests
at least one approach for reconciling functionality that does mostly
the same thing in staff and OPAC.

=head1 FUNCTIONS

=head2 handle_form_action

    C4::Form::MessagingPreferences::handle_form_action($input, { categorycode => 'CPL' }, $template, $insert);

Processes CGI parameters and updates the target patron or patron category's
preferences.

C<$input> is the CGI query object.

C<$target_params> is a hashref containing either a C<categorycode> key or a C<borrowernumber> key 
identifying the patron or patron category whose messaging preferences are to be updated.

C<$template> is the Template::Toolkit object for the response; this routine
adds a settings_updated template variable.

=cut

sub handle_form_action {
    my ($query, $target_params, $template, $insert, $categorycode) = @_;
    my $messaging_options = Koha::Patron::Message::Preferences->get_options;
    # TODO: If a "NONE" box and another are checked somehow (javascript failed), we should pay attention to the "NONE" box
    my $prefs_set = 0;
    my $borrowernumber;
    my $logEntries = [];
    OPTION: foreach my $option ( @$messaging_options ) {
        my $updater = {
            message_attribute_id  => $option->{'message_attribute_id'}
        };

        $updater->{borrowernumber} = $target_params->{borrowernumber};
        $borrowernumber            = $target_params->{borrowernumber};
        if ($target_params->{categorycode} && !$target_params->{borrowernumber}) {
            $updater->{categorycode} = $target_params->{categorycode};
            delete $updater->{borrowernumber};
        }

        # find the desired transports
        @{$updater->{'message_transport_types'}} =
            $query->multi_param( $option->{'message_attribute_id'} );

        my $email     = $query->param('email');
        my $phone     = $query->param('phone');
        my $smsnumber = $query->param('SMSnumber');

        # Messaging preference validation. Make sure there is a valid contact
        # information provided for every transport method. Otherwise remove
        # the transport method, because the message cannot be delivered!
        if (_no_contact_set($email, $target_params, 'email')) {
            my $id = _transport_set(
                'email', @{$updater->{'message_transport_types'}}
            );
            splice(@{$updater->{'message_transport_types'}}, $id, 1) if $id > -1;
        }
        if (_no_contact_set($phone, $target_params, 'phone')) {
            my $id = _transport_set(
                'phone',@{$updater->{'message_transport_types'}}
            );
            splice(@{$updater->{'message_transport_types'}}, $id, 1) if $id > -1;
        }
        if (_no_contact_set($smsnumber, $target_params, 'smsalertnumber')) {
            my $id = _transport_set(
                'sms',
                @{$updater->{'message_transport_types'}}
            );
            splice(@{$updater->{'message_transport_types'}}, $id, 1) if $id > -1;
        }

        next OPTION unless $updater->{'message_transport_types'};

        if ( $option->{'has_digest'} ) {
            if ( List::Util::first { $_ == $option->{'message_attribute_id'} } $query->multi_param( 'digest' ) ) {
                $updater->{'wants_digest'} = 1;
            }
        }

        if ( $option->{'takes_days'} ) {
            if ( defined $query->param( $option->{'message_attribute_id'} . '-DAYS' ) ) {
                $updater->{'days_in_advance'} = $query->param( $option->{'message_attribute_id'} . '-DAYS' );
            }
        }

        $updater->{'days_in_advance'} = undef unless exists $updater->{'days_in_advance'};
        $updater->{'wants_digest'} = 0 unless exists $updater->{'wants_digest'};
        my $preference = Koha::Patron::Message::Preferences->find({
            borrowernumber => $updater->{'borrowernumber'},
            message_attribute_id => $option->{'message_attribute_id'},
            categorycode => $categorycode || $updater->{'categorycode'},
        });
        unless ($preference) {
            $preference = Koha::Patron::Message::Preference->new($updater)->store;
        } else {
            $preference->set($updater)->store;
        }

        $preference->_push_to_action_buffer($logEntries);

	if ($query->param( $option->{'message_attribute_id'})){
	    $prefs_set = 1;
	}
    }
    if (! $prefs_set && $insert){
        # this is new borrower, and we have no preferences set, use the defaults
        $target_params->{categorycode} = $categorycode;
        my $patron = Koha::Patrons->find($target_params->{'borrowernumber'});
        $patron->set_default_messaging_preferences if $patron;
    }
    # show the success message
    $template->param( settings_updated => 1 );

    Koha::Patron::Message::Preferences->_log_action_buffer($logEntries, $borrowernumber);
}

=head2 set_form_values

    C4::Form::MessagingPreferences::set_form_value({ borrowernumber => 51 }, $template);

Retrieves the messaging preferences for the specified patron or patron category
and fills the corresponding template variables.

C<$target_params> is a hashref containing either a C<categorycode> key or a C<borrowernumber> key 
identifying the patron or patron category.

C<$template> is the Template::Toolkit object for the response.

=cut

sub set_form_values {
    my ($target_params, $template) = @_;
    # walk through the options and update them with these borrower_preferences
    my $messaging_options = Koha::Patron::Message::Preferences->get_options;
    PREF: foreach my $option ( @$messaging_options ) {
        my $pref = Koha::Patron::Message::Preferences->find( { %{ $target_params }, message_attribute_id => $option->{'message_attribute_id'} } );
        $option->{ $option->{'message_name'} } = 1;
        # make a hashref of the days, selecting one.
        if ( $option->{'takes_days'} ) {
            my $days_in_advance = $pref && $pref->days_in_advance ? $pref->days_in_advance : 0;
            $option->{days_in_advance} = $days_in_advance;
            @{$option->{'select_days'}} = map { {
                day        => $_,
                selected   => $_ == $days_in_advance  }
            } ( 0..MAX_DAYS_IN_ADVANCE );
        }
        next unless $pref;
        foreach my $transport ( keys %{$pref->message_transport_types} ) {
            $option->{'transports_'.$transport} = 1;
        }
        $option->{'digest'} = 1 if $pref->wants_digest;
    }
    $template->param(messaging_preferences => $messaging_options);
}

sub _no_contact_set {
    my ($param, $target_params, $target_param_name) = @_;

    if (defined $param && !$param) {
        return 1;
    }
    elsif (!defined $param && exists $target_params->{$target_param_name}
                           && !$target_params->{$target_param_name}) {
        return 1;
    } else {
        return 0;
    }
}

sub _transport_set {
    my ($name, @transport_methods) = @_;

    return List::MoreUtils::firstidx { $_ eq $name } @transport_methods;
}

=head1 TODO

=over 4

=item Reduce coupling between processing CGI parameters and updating the messaging preferences

=item Handle when form input is invalid

=item Generalize into a system of form handler clases

=back

=head1 SEE ALSO

L<Koha::Patron::Message::Preference>, F<admin/categories.pl>, F<opac/opac-messaging.pl>, F<members/messaging.pl>

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

Galen Charlton <galen.charlton@liblime.com> refactoring code by Andrew Moore.

=cut

1;
