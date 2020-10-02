#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
# Copyright 2010 BibLibre
# Copyright 2014 ByWater Solutions
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


=head1 moremember.pl

 script to do a borrower enquiry/bring up patron details etc
 Displays all the details about a patron

=cut

use Modern::Perl;
use CGI qw ( -utf8 );
use C4::Context;
use C4::Auth qw( get_template_and_user );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use C4::Form::MessagingPreferences;
use List::MoreUtils qw( uniq );
use Scalar::Util qw( looks_like_number );
use Koha::Patron::Attribute::Types;
use Koha::Patron::Restriction::Types;
use Koha::Patron::Messages;
use Koha::CsvProfiles;
use Koha::Holds;
use Koha::Patrons;
use Koha::Patron::Files;
use Koha::Token;
use Koha::Checkouts;

my $input = CGI->new;

my $print = $input->param('print');

my $template_name;

if (defined $print and $print eq "brief") {
        $template_name = "members/moremember-brief.tt";
} else {
        $template_name = "members/moremember.tt";
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => $template_name,
        query           => $input,
        type            => "intranet",
        flagsrequired   => { borrowers => 'edit_borrowers' },
    }
);
my $borrowernumber = $input->param('borrowernumber');
my $error = $input->param('error');
$template->param( error => $error ) if ( $error );

my $patron         = Koha::Patrons->find( $borrowernumber );
my $logged_in_user = Koha::Patrons->find( $loggedinuser );
output_and_exit_if_error( $input, $cookie, $template, { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron } );

my $category_type = $patron->category->category_type;

for (qw(gonenoaddress lost borrowernotes is_debarred)) {
    $patron->$_ and $template->param(flagged => 1) and last;
}

$template->param(
    restriction_types => scalar Koha::Patron::Restriction::Types->search()
);

if ( $patron->is_debarred ) {
    $template->param(
        'userdebarred'    => $patron->debarred,
        'debarredcomment' => $patron->debarredcomment,
        'debarredsince'   => $patron->restrictions->search()->single->created,
    );

    if ( $patron->debarred ne "9999-12-31" ) {
        $template->param( 'userdebarreddate' => $patron->debarred );
    }
}

$template->param( flagged => 1 ) if $patron->account_locked;

my @relatives;
my $guarantor_relationships = $patron->guarantor_relationships;
my @guarantees              = $patron->guarantee_relationships->guarantees->as_list;
my @guarantors              = $guarantor_relationships->guarantors->as_list;
if (@guarantors) {
    push( @relatives, $_->id ) for @guarantors;
    push( @relatives, $_->id ) for $patron->siblings->as_list;
}
else {
    push( @relatives, $_->id ) for @guarantees;
}
$template->param(
    guarantor_relationships => $guarantor_relationships,
    guarantees              => \@guarantees,
);

my $relatives_issues_count =
    Koha::Checkouts->count({ borrowernumber => \@relatives });

if ( @guarantees ) {
    my $total_amount = $patron->relationships_debt({ include_guarantors => 0, only_this_guarantor => 1, include_this_patron => 1 });
    $template->param( guarantees_fines => $total_amount );
}

# Calculate and display patron's age
if ( !$patron->is_valid_age ) {
    $template->param( age_limitations => 1 );
    $template->param( age_low => $patron->category->dateofbirthrequired );
    $template->param( age_high => $patron->category->upperagelimit );
}

# Generate CSRF token for upload and delete image buttons
$template->param(
    csrf_token => Koha::Token->new->generate_csrf({ session_id => $input->cookie('CGISESSID'),}),
);

if (C4::Context->preference('ExtendedPatronAttributes')) {
    my @attributes = $patron->extended_attributes->as_list; # FIXME Must be improved!
    my @classes = uniq( map {$_->type->class} @attributes );
    @classes = sort @classes;

    my @attributes_loop;
    for my $class (@classes) {
        my @items;
        for my $attr (@attributes) {
            push @items, $attr if $attr->type->class eq $class
        }
        my $av = Koha::AuthorisedValues->search({ category => 'PA_CLASS', authorised_value => $class });
        my $lib = $av->count ? $av->next->lib : $class;

        push @attributes_loop, {
            class => $class,
            items => \@items,
            lib   => $lib,
        };
    }

    $template->param(
        attributes_loop => \@attributes_loop
    );

    my $library_id = C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef;
    my $nb_of_attribute_types = Koha::Patron::Attribute::Types->search_with_library_limits({}, {}, $library_id)->count;
    if ( $nb_of_attribute_types == 0 ) {
        $template->param(no_patron_attribute_types => 1);
    }
}

if (C4::Context->preference('EnhancedMessagingPreferences')) {
    C4::Form::MessagingPreferences::set_form_values({ borrowernumber => $borrowernumber }, $template);
    $template->param(messaging_form_inactive => 1);
}

if ( C4::Context->preference("ExportCircHistory") ) {
    $template->param(csv_profiles => Koha::CsvProfiles->search({ type => 'marc' }));
}

my $patron_messages = Koha::Patron::Messages->search(
    {
        'me.borrowernumber' => $patron->borrowernumber,
    },
    {
        join => 'manager',
        '+select' => ['manager.surname', 'manager.firstname' ],
        '+as' => ['manager_surname', 'manager_firstname'],
    }
);

if( $patron_messages->count > 0 ){
    $template->param( patron_messages => $patron_messages );
}

# Display the language description instead of the code
# Note that this is certainly wrong
my ( $subtag, $region ) = split '-', $patron->lang;
my $translated_language = C4::Languages::language_get_description( $subtag, $subtag, 'language' );

# if the expiry date is before today ie they have expired
if ( $patron->is_expired || $patron->is_going_to_expire ) {
    $template->param(
        flagged => 1
    );
}

my $holds = Koha::Holds->search( { borrowernumber => $borrowernumber } ); # FIXME must be Koha::Patron->holds
my $waiting_holds = $holds->waiting;
$template->param(
    holds_count  => $holds->count(),
    WaitingHolds => $waiting_holds,
);

if ( C4::Context->preference('UseRecalls') ) {
    my $waiting_recalls = $patron->recalls->search({ status => 'waiting' });
    $template->param( waiting_recalls => $waiting_recalls );
}

my $no_issues_charge_guarantees = C4::Context->preference("NoIssuesChargeGuarantees");
$no_issues_charge_guarantees = undef unless looks_like_number( $no_issues_charge_guarantees );
if ( defined $no_issues_charge_guarantees ) {
    my $guarantees_non_issues_charges = 0;
    my $guarantees = $patron->guarantee_relationships->guarantees;
    while ( my $g = $guarantees->next ) {
        $guarantees_non_issues_charges += $g->account->non_issues_charges;
    }
    if ( $guarantees_non_issues_charges > $no_issues_charge_guarantees ) {
        $template->param(
            charges_guarantees    => 1,
            chargesamount_guarantees => $guarantees_non_issues_charges,
        );
    }
}

if ( $patron->has_overdues ) {
    $template->param( odues => 1 );
}
my $issues = $patron->checkouts;

my $balance = 0;
$balance = $patron->account->balance;

my $account = $patron->account;
if( ( my $owing = $account->non_issues_charges ) > 0 ) {
    my $noissuescharge = C4::Context->preference("noissuescharge") || 5; # FIXME If noissuescharge == 0 then 5, why??
    $template->param(
        charges => 1,
        chargesamount => $owing,
    )
} elsif ( $balance < 0 ) {
    $template->param(
        credits => 1,
        creditsamount => -$balance,
    );
}

# if the expiry date is before today ie they have expired
if ( $patron->is_expired ) {
    #borrowercard expired, no issues
    $template->param(
        expired => "1",
    );
}
# check for NotifyBorrowerDeparture
elsif ( $patron->is_going_to_expire ) {
    # borrower card soon to expire warn librarian
    $template->param( "warndeparture" => $patron->dateexpiry ,
                    );
    if (C4::Context->preference('ReturnBeforeExpiry')){
        $template->param("returnbeforeexpiry" => 1);
    }
}


my $has_modifications = Koha::Patron::Modifications->search( { borrowernumber => $borrowernumber } )->count;

$template->param(
    patron          => $patron,
    issuecount      => $patron->checkouts->count,
    holds_count     => $patron->holds->count,
    fines           => $patron->account->balance,
    translated_language => $translated_language,
    detailview      => 1,
    was_renewed     => scalar $input->param('was_renewed') ? 1 : 0,
    $category_type  => 1, # [% IF ( I ) %] = institutional/organisation
    housebound_role => scalar $patron->housebound_role,
    relatives_issues_count => $relatives_issues_count,
    relatives_borrowernumbers => \@relatives,
    logged_in_user => $logged_in_user,
    files => Koha::Patron::Files->new( borrowernumber => $borrowernumber ) ->GetFilesInfo(),
    has_modifications         => $has_modifications,
);

if ( C4::Context->preference('UseRecalls') ) {
    $template->param(
        recalls         => $patron->recalls({},{ order_by => { -asc => 'recalldate' } })->filter_by_current,
        specific_patron => 1,
    );
}

output_html_with_http_headers $input, $cookie, $template->output;
