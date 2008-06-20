#!/usr/bin/perl

# Copyright 2008 LibLime
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;
require Exporter;
use CGI;

use C4::Auth;    # checkauth, getborrowernumber.
use C4::Context;
use C4::Koha;
use C4::Circulation;
use C4::Output;
use C4::Dates qw/format_date/;
use C4::Members;
use C4::Members::Messaging;
use C4::Branch;

my $query = CGI->new();

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => 'opac-messaging.tmpl',
        query           => $query,
        type            => 'opac',
        authnotrequired => 0,
        flagsrequired   => { borrow => 1 },
        debug           => 1,
    }
);

my $borrower = GetMemberDetails( $borrowernumber );
my $messaging_options = C4::Members::Messaging::GetMessagingOptions();

if ( defined $query->param('modify') && $query->param('modify') eq 'yes' ) {

    # If they've modified the SMS number, record it.
    if ( ( defined $query->param('SMSnumber') ) && ( $query->param('SMSnumber') ne $borrower->{'mobile'} ) ) {
        ModMember( borrowernumber => $borrowernumber,
                   smsalertnumber => $query->param('SMSnumber') );
        $borrower = GetMemberDetails( $borrowernumber );
    }

    # TODO: If a "NONE" box and another are checked somehow (javascript failed), we should pay attention to the "NONE" box
    
    # warn( Data::Dumper->Dump( [ $messaging_options ], [ 'messaging_options' ] ) );
    OPTION: foreach my $option ( @$messaging_options ) {
        # warn( Data::Dumper->Dump( [ $option ], [ 'option' ] ) );
        my $updater = { borrowernumber          => $borrower->{'borrowernumber'},
                        message_attribute_id    => $option->{'message_attribute_id'} };
        
        # find the desired transports
        @{$updater->{'message_transport_types'}} = $query->param( $option->{'message_attribute_id'} );
        next OPTION unless $updater->{'message_transport_types'};

        if ( $option->{'has_digest'} ) {
            if ( List::Util::first { $_ == $option->{'message_attribute_id'} } $query->param( 'digest' ) ) {
                $updater->{'wants_digest'} = 1;
            }
        }

        if ( $option->{'takes_days'} ) {
            if ( defined $query->param( $option->{'message_attribute_id'} . '-DAYS' ) ) {
                $updater->{'days_in_advance'} = $query->param( $option->{'message_attribute_id'} . '-DAYS' );
            }
        }

        # warn( 'calling SetMessaginPreferencse with ' . Data::Dumper->Dump( [ $updater ], [ 'updater' ] ) );
        C4::Members::Messaging::SetMessagingPreference( $updater );
    }

    # show the success message
    $template->param( settings_updated => 1 );
} 

$messaging_options = C4::Members::Messaging::GetMessagingOptions();
# walk through the options and update them with these borrower_preferences
PREF: foreach my $option ( @$messaging_options ) {
    my $pref = C4::Members::Messaging::GetMessagingPreferences( { borrowernumber     => $borrower->{'borrowernumber'},
                                                                  message_name       => $option->{'message_name'} } );
    # warn( Data::Dumper->Dump( [ $pref ], [ 'pref' ] ) );
    # make a hashref of the days, selecting one.
    if ( $option->{'takes_days'} ) {
        foreach my $day ( 0..30 ) { # FIXME: 30 is a magic number.
            my $dayrow = { day      => $day,
                           selected => '' };
            if ( defined $pref->{'days_in_advance'} && $pref->{'days_in_advance'} == $day ) {
                $dayrow->{'selected'} = 'SELECTED';
            }
            push @{$option->{'select_days'}}, $dayrow
        }
    }
    foreach my $transport ( @{$pref->{'transports'}} ) {
        $option->{'transport-'.$transport} = 'CHECKED';
    }

    $option->{'digest'} = $pref->{'wants_digest'} ? 'CHECKED' : '';
}

# warn( Data::Dumper->Dump( [ $messaging_options ], [ 'messaging_options' ] ) );
$template->param( BORROWER_INFO         => [ $borrower ],
                  messagingview         => 1,
                  messaging_preferences => $messaging_options,
                  SMSnumber => defined $borrower->{'smsalertnumber'} ? $borrower->{'smsalertnumber'} : $borrower->{'mobile'} );

output_html_with_http_headers $query, $cookie, $template->output;
