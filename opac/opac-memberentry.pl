#!/usr/bin/perl

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

use CGI qw ( -utf8 );
use Digest::MD5 qw( md5_base64 md5_hex );
use JSON;
use List::MoreUtils qw( any each_array uniq );
use String::Random qw( random_string );

use C4::Auth;
use C4::Output;
use C4::Members;
use C4::Members::Attributes qw( GetBorrowerAttributes );
use C4::Form::MessagingPreferences;
use Koha::AuthUtils;
use Koha::Patrons;
use Koha::Patron::Modification;
use Koha::Patron::Modifications;
use C4::Scrubber;
use Email::Valid;
use Koha::DateUtils;
use Koha::Libraries;
use Koha::Patron::Attribute::Types;
use Koha::Patron::Attributes;
use Koha::Patron::Images;
use Koha::Patron::Modification;
use Koha::Patron::Modifications;
use Koha::Patrons;
use Koha::Token;

my $cgi = new CGI;
my $dbh = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-memberentry.tt",
        type            => "opac",
        query           => $cgi,
        authnotrequired => 1,
    }
);

unless ( C4::Context->preference('PatronSelfRegistration') || $borrowernumber )
{
    print $cgi->redirect("/cgi-bin/koha/opac-main.pl");
    exit;
}

my $action = $cgi->param('action') || q{};
if ( $action eq q{} ) {
    if ($borrowernumber) {
        $action = 'edit';
    }
    else {
        $action = 'new';
    }
}

my $mandatory = GetMandatoryFields($action);

my @libraries = Koha::Libraries->search;
if ( my @libraries_to_display = split '\|', C4::Context->preference('PatronSelfRegistrationLibraryList') ) {
    @libraries = map { my $b = $_; my $branchcode = $_->branchcode; grep( /^$branchcode$/, @libraries_to_display ) ? $b : () } @libraries;
}
my ( $min, $max ) = C4::Members::get_cardnumber_length();
if ( defined $min ) {
     $template->param(
         minlength_cardnumber => $min,
         maxlength_cardnumber => $max
     );
 }

$template->param(
    action            => $action,
    hidden            => GetHiddenFields( $mandatory, 'registration' ),
    mandatory         => $mandatory,
    libraries         => \@libraries,
    OPACPatronDetails => C4::Context->preference('OPACPatronDetails'),
);

my $attributes = ParsePatronAttributes($borrowernumber,$cgi);
my $conflicting_attribute = 0;

foreach my $attr (@$attributes) {
    unless ( C4::Members::Attributes::CheckUniqueness($attr->{code}, $attr->{value}, $borrowernumber) ) {
        my $attr_info = C4::Members::AttributeTypes->fetch($attr->{code});
        $template->param(
            extended_unique_id_failed_code => $attr->{code},
            extended_unique_id_failed_value => $attr->{value},
            extended_unique_id_failed_description => $attr_info->description()
        );
        $conflicting_attribute = 1;
    }
}

if ( $action eq 'create' ) {

    my %borrower = ParseCgiForBorrower($cgi);

    %borrower = DelEmptyFields(%borrower);

    my @empty_mandatory_fields = CheckMandatoryFields( \%borrower, $action );
    my $invalidformfields = CheckForInvalidFields(\%borrower);
    delete $borrower{'password2'};
    my $cardnumber_error_code;
    if ( !grep { $_ eq 'cardnumber' } @empty_mandatory_fields ) {
        # No point in checking the cardnumber if it's missing and mandatory, it'll just generate a
        # spurious length warning.
        $cardnumber_error_code = checkcardnumber( $borrower{cardnumber}, $borrower{borrowernumber} );
    }

    if ( @empty_mandatory_fields || @$invalidformfields || $cardnumber_error_code || $conflicting_attribute ) {
        if ( $cardnumber_error_code == 1 ) {
            $template->param( cardnumber_already_exists => 1 );
        } elsif ( $cardnumber_error_code == 2 ) {
            $template->param( cardnumber_wrong_length => 1 );
        }

        $template->param(
            empty_mandatory_fields => \@empty_mandatory_fields,
            invalid_form_fields    => $invalidformfields,
            borrower               => \%borrower
        );
        $template->param( patron_attribute_classes => GeneratePatronAttributesForm( undef, $attributes ) );
    }
    elsif (
        md5_base64( uc( $cgi->param('captcha') ) ) ne $cgi->param('captcha_digest') )
    {
        $template->param(
            failed_captcha => 1,
            borrower       => \%borrower
        );
        $template->param( patron_attribute_classes => GeneratePatronAttributesForm( undef, $attributes ) );
    }
    else {
        if (
            C4::Context->boolean_preference(
                'PatronSelfRegistrationVerifyByEmail')
          )
        {
            ( $template, $borrowernumber, $cookie ) = get_template_and_user(
                {
                    template_name   => "opac-registration-email-sent.tt",
                    type            => "opac",
                    query           => $cgi,
                    authnotrequired => 1,
                }
            );
            $template->param( 'email' => $borrower{'email'} );

            my $verification_token = md5_hex( time().{}.rand().{}.$$ );
            while ( Koha::Patron::Modifications->search( { verification_token => $verification_token } )->count() ) {
                $verification_token = md5_hex( time().{}.rand().{}.$$ );
            }

            $borrower{password}          = Koha::AuthUtils::generate_password unless $borrower{password};
            $borrower{verification_token} = $verification_token;

            Koha::Patron::Modification->new( \%borrower )->store();

            #Send verification email
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'members',
                letter_code => 'OPAC_REG_VERIFY',
                lang        => 'default', # Patron does not have a preferred language defined yet
                tables      => {
                    borrower_modifications => $verification_token,
                },
            );

            C4::Letters::EnqueueLetter(
                {
                    letter                 => $letter,
                    message_transport_type => 'email',
                    to_address             => $borrower{'email'},
                    from_address =>
                      C4::Context->preference('KohaAdminEmailAddress'),
                }
            );
        }
        else {
            ( $template, $borrowernumber, $cookie ) = get_template_and_user(
                {
                    template_name   => "opac-registration-confirmation.tt",
                    type            => "opac",
                    query           => $cgi,
                    authnotrequired => 1,
                }
            );

            $template->param( OpacPasswordChange =>
                  C4::Context->preference('OpacPasswordChange') );

            $borrower{categorycode}     ||= C4::Context->preference('PatronSelfRegistrationDefaultCategory');
            $borrower{password}         ||= Koha::AuthUtils::generate_password;
            my $patron = Koha::Patron->new( \%borrower )->store;
            if ( $patron ) {
                C4::Members::Attributes::SetBorrowerAttributes( $patron->borrowernumber, $attributes );
                if ( C4::Context->preference('EnhancedMessagingPreferences') ) {
                    C4::Form::MessagingPreferences::handle_form_action(
                        $cgi,
                        { borrowernumber => $patron->borrowernumber },
                        $template,
                        1,
                        C4::Context->preference('PatronSelfRegistrationDefaultCategory')
                    );
                }

                $template->param( password_cleartext => $patron->plain_text_password );
                $template->param( borrower => $patron->unblessed );
            } else {
                # FIXME Handle possible errors here
            }
            $template->param(
                PatronSelfRegistrationAdditionalInstructions =>
                  C4::Context->preference(
                    'PatronSelfRegistrationAdditionalInstructions')
            );
        }
    }
}
elsif ( $action eq 'update' ) {

    my $borrower = Koha::Patrons->find( $borrowernumber )->unblessed;
    die "Wrong CSRF token"
        unless Koha::Token->new->check_csrf({
            session_id => scalar $cgi->cookie('CGISESSID'),
            token  => scalar $cgi->param('csrf_token'),
        });

    my %borrower = ParseCgiForBorrower($cgi);
    $borrower{borrowernumber} = $borrowernumber;

    my %borrower_changes = DelEmptyFields(%borrower);
    my @empty_mandatory_fields =
      CheckMandatoryFields( \%borrower_changes, $action );
    my $invalidformfields = CheckForInvalidFields(\%borrower);

    # Send back the data to the template
    %borrower = ( %$borrower, %borrower );

    if (@empty_mandatory_fields || @$invalidformfields) {
        $template->param(
            empty_mandatory_fields => \@empty_mandatory_fields,
            invalid_form_fields    => $invalidformfields,
            borrower               => \%borrower,
            csrf_token             => Koha::Token->new->generate_csrf({
                session_id => scalar $cgi->cookie('CGISESSID'),
            }),
        );
        $template->param( patron_attribute_classes => GeneratePatronAttributesForm( $borrowernumber, $attributes ) );

        $template->param( action => 'edit' );
    }
    else {
        my %borrower_changes = DelUnchangedFields( $borrowernumber, %borrower );
        my $extended_attributes_changes = FilterUnchangedAttributes( $borrowernumber, $attributes );

        if ( %borrower_changes || scalar @{$extended_attributes_changes} > 0 ) {
            ( $template, $borrowernumber, $cookie ) = get_template_and_user(
                {
                    template_name   => "opac-memberentry-update-submitted.tt",
                    type            => "opac",
                    query           => $cgi,
                    authnotrequired => 1,
                }
            );

            $borrower_changes{borrowernumber} = $borrowernumber;
            $borrower_changes{extended_attributes} = to_json($extended_attributes_changes);

            Koha::Patron::Modifications->search({ borrowernumber => $borrowernumber })->delete;

            my $m = Koha::Patron::Modification->new( \%borrower_changes )->store();

            my $patron = Koha::Patrons->find( $borrowernumber );
            $template->param( borrower => $patron->unblessed );
        }
        else {
            my $patron = Koha::Patrons->find( $borrowernumber );
            $template->param(
                action => 'edit',
                nochanges => 1,
                borrower => $patron->unblessed,
                patron_attribute_classes => GeneratePatronAttributesForm( $borrowernumber, $attributes ),
                csrf_token => Koha::Token->new->generate_csrf({
                    session_id => scalar $cgi->cookie('CGISESSID'),
                }),
            );
        }
    }
}
elsif ( $action eq 'edit' ) {    #Display logged in borrower's data
    my $patron = Koha::Patrons->find( $borrowernumber );
    my $borrower = $patron->unblessed;

    $template->param(
        borrower  => $borrower,
        guarantor => scalar Koha::Patrons->find($borrowernumber)->guarantor(),
        hidden => GetHiddenFields( $mandatory, 'modification' ),
        csrf_token => Koha::Token->new->generate_csrf({
            session_id => scalar $cgi->cookie('CGISESSID'),
        }),
    );

    if (C4::Context->preference('OPACpatronimages')) {
        $template->param( display_patron_image => 1 ) if $patron->image;
    }

    $template->param( patron_attribute_classes => GeneratePatronAttributesForm( $borrowernumber ) );
} else {
    # Render self-registration page
    $template->param( patron_attribute_classes => GeneratePatronAttributesForm() );
}

my $captcha = random_string("CCCCC");

$template->param(
    captcha        => $captcha,
    captcha_digest => md5_base64($captcha)
);

output_html_with_http_headers $cgi, $cookie, $template->output, undef, { force_no_caching => 1 };

sub GetHiddenFields {
    my ( $mandatory, $action ) = @_;
    my %hidden_fields;

    my $BorrowerUnwantedField = $action eq 'modification' ?
      C4::Context->preference( "PatronSelfModificationBorrowerUnwantedField" ) :
      C4::Context->preference( "PatronSelfRegistrationBorrowerUnwantedField" );

    my @fields = split( /\|/, $BorrowerUnwantedField || q|| );
    foreach (@fields) {
        next unless m/\w/o;
        #Don't hide mandatory fields
        next if $mandatory->{$_};
        $hidden_fields{$_} = 1;
    }

    return \%hidden_fields;
}

sub GetMandatoryFields {
    my ($action) = @_;

    my %mandatory_fields;

    my $BorrowerMandatoryField =
      C4::Context->preference("PatronSelfRegistrationBorrowerMandatoryField");

    my @fields = split( /\|/, $BorrowerMandatoryField );

    foreach (@fields) {
        $mandatory_fields{$_} = 1;
    }

    if ( $action eq 'create' || $action eq 'new' ) {
        $mandatory_fields{'email'} = 1
          if C4::Context->boolean_preference(
            'PatronSelfRegistrationVerifyByEmail');
    }

    return \%mandatory_fields;
}

sub CheckMandatoryFields {
    my ( $borrower, $action ) = @_;

    my @empty_mandatory_fields;

    my $mandatory_fields = GetMandatoryFields($action);
    delete $mandatory_fields->{'cardnumber'};

    foreach my $key ( keys %$mandatory_fields ) {
        push( @empty_mandatory_fields, $key )
          unless ( defined( $borrower->{$key} ) && $borrower->{$key} );
    }

    return @empty_mandatory_fields;
}

sub CheckForInvalidFields {
    my $borrower = shift;
    my @invalidFields;
    if ($borrower->{'email'}) {
        unless ( Email::Valid->address($borrower->{'email'}) ) {
            push(@invalidFields, "email");
        } elsif ( C4::Context->preference("PatronSelfRegistrationEmailMustBeUnique") ) {
            my $patrons_with_same_email = Koha::Patrons->search( # FIXME Should be search_limited?
                {
                    email => $borrower->{email},
                    (
                        exists $borrower->{borrowernumber}
                        ? ( borrowernumber =>
                              { '!=' => $borrower->{borrowernumber} } )
                        : ()
                    )
                }
            )->count;
            if ( $patrons_with_same_email ) {
                push @invalidFields, "duplicate_email";
            }
        }
    }
    if ($borrower->{'emailpro'}) {
        push(@invalidFields, "emailpro") if (!Email::Valid->address($borrower->{'emailpro'}));
    }
    if ($borrower->{'B_email'}) {
        push(@invalidFields, "B_email") if (!Email::Valid->address($borrower->{'B_email'}));
    }
    if ( defined $borrower->{'password'}
        and $borrower->{'password'} ne $borrower->{'password2'} )
    {
        push( @invalidFields, "password_match" );
    }
    if ( $borrower->{'password'} ) {
        my ( $is_valid, $error ) = Koha::AuthUtils::is_password_valid( $borrower->{password} );
          unless ( $is_valid ) {
              push @invalidFields, 'password_too_short' if $error eq 'too_short';
              push @invalidFields, 'password_too_weak' if $error eq 'too_weak';
              push @invalidFields, 'password_has_whitespaces' if $error eq 'has_whitespaces';
          }
    }

    return \@invalidFields;
}

sub ParseCgiForBorrower {
    my ($cgi) = @_;

    my $scrubber = C4::Scrubber->new();
    my %borrower;

    foreach my $field ( $cgi->param ) {
        if ( $field =~ '^borrower_' ) {
            my ($key) = substr( $field, 9 );
            if ( $field !~ '^borrower_password' ) {
                $borrower{$key} = $scrubber->scrub( scalar $cgi->param($field) );
            } else {
                # Allow html characters for passwords
                $borrower{$key} = $cgi->param($field);
            }
        }
    }

    my $dob_dt;
    $dob_dt = eval { dt_from_string( $borrower{'dateofbirth'} ); }
        if ( $borrower{'dateofbirth'} );

    if ( $dob_dt ) {
        $borrower{'dateofbirth'} = output_pref ( { dt => $dob_dt, dateonly => 1, dateformat => 'iso' } );
    }
    else {
        # Trigger validation
        $borrower{'dateofbirth'} = undef;
    }

    return %borrower;
}

sub DelUnchangedFields {
    my ( $borrowernumber, %new_data ) = @_;

    my $patron = Koha::Patrons->find( $borrowernumber );
    my $current_data = $patron->unblessed;

    foreach my $key ( keys %new_data ) {
        if ( $current_data->{$key} eq $new_data{$key} ) {
            delete $new_data{$key};
        }
    }

    return %new_data;
}

sub DelEmptyFields {
    my (%borrower) = @_;

    foreach my $key ( keys %borrower ) {
        delete $borrower{$key} unless $borrower{$key};
    }

    return %borrower;
}

sub FilterUnchangedAttributes {
    my ( $borrowernumber, $entered_attributes ) = @_;

    my @patron_attributes = grep {$_->opac_editable} Koha::Patron::Attributes->search({ borrowernumber => $borrowernumber })->as_list;

    my $patron_attribute_types;
    foreach my $attr (@patron_attributes) {
        $patron_attribute_types->{ $attr->code } += 1;
    }

    my $passed_attribute_types;
    foreach my $attr (@{ $entered_attributes }) {
        $passed_attribute_types->{ $attr->{ code } } += 1;
    }

    my @changed_attributes;

    # Loop through the current patron attributes
    foreach my $attribute_type ( keys %{ $patron_attribute_types } ) {
        if ( $patron_attribute_types->{ $attribute_type } !=  $passed_attribute_types->{ $attribute_type } ) {
            # count differs, overwrite all attributes for given type
            foreach my $attr (@{ $entered_attributes }) {
                push @changed_attributes, $attr
                    if $attr->{ code } eq $attribute_type;
            }
        } else {
            # count matches, check values
            my $changes = 0;
            foreach my $attr (grep { $_->code eq $attribute_type } @patron_attributes) {
                $changes = 1
                    unless any { $_->{ value } eq $attr->attribute } @{ $entered_attributes };
                last if $changes;
            }

            if ( $changes ) {
                foreach my $attr (@{ $entered_attributes }) {
                    push @changed_attributes, $attr
                        if $attr->{ code } eq $attribute_type;
                }
            }
        }
    }

    # Loop through passed attributes, looking for new ones
    foreach my $attribute_type ( keys %{ $passed_attribute_types } ) {
        if ( !defined $patron_attribute_types->{ $attribute_type } ) {
            # YAY, new stuff
            foreach my $attr (grep { $_->{code} eq $attribute_type } @{ $entered_attributes }) {
                push @changed_attributes, $attr;
            }
        }
    }

    return \@changed_attributes;
}

sub GeneratePatronAttributesForm {
    my ( $borrowernumber, $entered_attributes ) = @_;

    # Get all attribute types and the values for this patron (if applicable)
    my @types = grep { $_->opac_editable() or $_->opac_display }
        Koha::Patron::Attribute::Types->search()->as_list();
    if ( scalar(@types) == 0 ) {
        return [];
    }

    my @displayable_attributes = grep { $_->opac_display }
        Koha::Patron::Attributes->search({ borrowernumber => $borrowernumber })->as_list;

    my %attr_values = ();

    # Build the attribute values list either from the passed values
    # or taken from the patron itself
    if ( defined $entered_attributes ) {
        foreach my $attr (@$entered_attributes) {
            push @{ $attr_values{ $attr->{code} } }, $attr->{value};
        }
    }
    elsif ( defined $borrowernumber ) {
        my @editable_attributes = grep { $_->opac_editable } @displayable_attributes;
        foreach my $attr (@editable_attributes) {
            push @{ $attr_values{ $attr->code } }, $attr->attribute;
        }
    }

    # Add the non-editable attributes (that don't come from the form)
    foreach my $attr ( grep { !$_->opac_editable } @displayable_attributes ) {
        push @{ $attr_values{ $attr->code } }, $attr->attribute;
    }

    # Find all existing classes
    my @classes = sort( uniq( map { $_->class } @types ) );
    my %items_by_class;

    foreach my $attr_type (@types) {
        push @{ $items_by_class{ $attr_type->class() } }, {
            type => $attr_type,
            # If editable, make sure there's at least one empty entry,
            # to make the template's job easier
            values => $attr_values{ $attr_type->code() } || ['']
        }
            unless !defined $attr_values{ $attr_type->code() }
                    and !$attr_type->opac_editable;
    }

    # Finally, build a list of containing classes
    my @class_loop;
    foreach my $class (@classes) {
        next unless ( $items_by_class{$class} );

        my $av = Koha::AuthorisedValues->search(
            { category => 'PA_CLASS', authorised_value => $class } );

        my $lib = $av->count ? $av->next->opac_description : $class;

        push @class_loop,
            {
            class => $class,
            items => $items_by_class{$class},
            lib   => $lib,
            };
    }

    return \@class_loop;
}

sub ParsePatronAttributes {
    my ( $borrowernumber, $cgi ) = @_;

    my @codes  = $cgi->multi_param('patron_attribute_code');
    my @values = $cgi->multi_param('patron_attribute_value');

    my @editable_attribute_types
        = map { $_->code } Koha::Patron::Attribute::Types->search({ opac_editable => 1 });

    my $ea = each_array( @codes, @values );
    my @attributes;

    my $delete_candidates = {};

    while ( my ( $code, $value ) = $ea->() ) {
        if ( any { $_ eq $code } @editable_attribute_types ) {
            # It is an editable attribute
            if ( !defined($value) or $value eq '' ) {
                $delete_candidates->{$code} = 1
                    unless $delete_candidates->{$code};
            }
            else {
                # we've got a value
                push @attributes, { code => $code, value => $value };

                # 'code' is no longer a delete candidate
                delete $delete_candidates->{$code}
                    if defined $delete_candidates->{$code};
            }
        }
    }

    foreach my $code ( keys %{$delete_candidates} ) {
        if ( Koha::Patron::Attributes->search({
                borrowernumber => $borrowernumber, code => $code })->count > 0 )
        {
            push @attributes, { code => $code, value => '' }
                unless any { $_->{code} eq $code } @attributes;
        }
    }

    return \@attributes;
}


1;
