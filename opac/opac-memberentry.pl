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

use CGI;
use Digest::MD5 qw( md5_base64 md5_hex );
use String::Random qw( random_string );

use C4::Auth;
use C4::Output;
use C4::Members;
use Koha::Borrower::Modifications;
use C4::Branch qw(GetBranchesLoop);
use C4::Scrubber;

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
my $hidden = GetHiddenFields($mandatory);

$template->param(
    action            => $action,
    hidden            => $hidden,
    mandatory         => $mandatory,
    member_titles     => GetTitles() || undef,
    branches          => GetBranchesLoop(),
    OPACPatronDetails => C4::Context->preference('OPACPatronDetails'),
);

if ( $action eq 'create' ) {

    my %borrower = ParseCgiForBorrower($cgi);

    %borrower = DelEmptyFields(%borrower);

    my @empty_mandatory_fields = CheckMandatoryFields( \%borrower, $action );

    if (@empty_mandatory_fields) {
        $template->param(
            empty_mandatory_fields => \@empty_mandatory_fields,
            borrower               => \%borrower
        );
    }
    elsif (
        md5_base64( $cgi->param('captcha') ) ne $cgi->param('captcha_digest') )
    {
        $template->param(
            failed_captcha => 1,
            borrower       => \%borrower
        );
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

            my $verification_token = md5_hex( \%borrower );
            $borrower{'password'} = random_string("..........");

            Koha::Borrower::Modifications->new(
                verification_token => $verification_token )
              ->AddModifications(\%borrower);

            #Send verification email
            my $letter = C4::Letters::GetPreparedLetter(
                module      => 'members',
                letter_code => 'OPAC_REG_VERIFY',
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

            my ( $borrowernumber, $password ) = AddMember_Opac(%borrower);

            $template->param( password_cleartext => $password );
            $template->param(
                borrower => GetMember( borrowernumber => $borrowernumber ) );
            $template->param(
                PatronSelfRegistrationAdditionalInstructions =>
                  C4::Context->preference(
                    'PatronSelfRegistrationAdditionalInstructions')
            );
        }
    }
}
elsif ( $action eq 'update' ) {

    my %borrower = ParseCgiForBorrower($cgi);

    my %borrower_changes = DelEmptyFields(%borrower);
    my @empty_mandatory_fields =
      CheckMandatoryFields( \%borrower_changes, $action );

    if (@empty_mandatory_fields) {
        $template->param(
            empty_mandatory_fields => \@empty_mandatory_fields,
            borrower               => \%borrower
        );

        $template->param( action => 'edit' );
    }
    else {
        ( $template, $borrowernumber, $cookie ) = get_template_and_user(
            {
                template_name   => "opac-memberentry-update-submitted.tt",
                type            => "opac",
                query           => $cgi,
                authnotrequired => 1,
            }
        );

        my %borrower_changes = DelUnchangedFields( $borrowernumber, %borrower );

        my $m =
          Koha::Borrower::Modifications->new(
            borrowernumber => $borrowernumber );

        $m->DelModifications;
        $m->AddModifications(\%borrower_changes);
        $template->param(
            borrower => GetMember( borrowernumber => $borrowernumber ),
        );
    }
}
elsif ( $action eq 'edit' ) {    #Display logged in borrower's data
    my $borrower = GetMember( borrowernumber => $borrowernumber );

    if (C4::Context->preference('ExtendedPatronAttributes')) {
        my $attributes = C4::Members::Attributes::GetBorrowerAttributes($borrowernumber, 'opac');
        if (scalar(@$attributes) > 0) {
            $borrower->{ExtendedPatronAttributes} = 1;
            $borrower->{patron_attributes} = $attributes;
        }
    }

    $template->param(
        borrower => $borrower, );

    if (C4::Context->preference('OPACpatronimages')) {
        my ($image, $dberror) = GetPatronImage($borrower->{borrowernumber});
        if ($image) {
            $template->param(
                display_patron_image => 1
            );
        }
    }

}

my $captcha = random_string("CCCCC");

$template->param(
    captcha        => $captcha,
    captcha_digest => md5_base64($captcha)
);

output_html_with_http_headers $cgi, $cookie, $template->output;

sub GetHiddenFields {
    my ($mandatory) = @_;
    my %hidden_fields;

    my $BorrowerUnwantedField =
      C4::Context->preference("PatronSelfRegistrationBorrowerUnwantedField");

    my @fields = split( /\|/, $BorrowerUnwantedField );
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

sub ParseCgiForBorrower {
    my ($cgi) = @_;

    my $scrubber = C4::Scrubber->new();
    my %borrower;

    foreach ( $cgi->param ) {
        if ( $_ =~ '^borrower_' ) {
            my ($key) = substr( $_, 9 );
            $borrower{$key} = $scrubber->scrub( $cgi->param($_) );
        }
    }

    $borrower{'dateofbirth'} =
      C4::Dates->new( $borrower{'dateofbirth'} )->output("iso")
      if ( defined( $borrower{'dateofbirth'} ) );

    return %borrower;
}

sub DelUnchangedFields {
    my ( $borrowernumber, %new_data ) = @_;

    my $current_data = GetMember( borrowernumber => $borrowernumber );

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
