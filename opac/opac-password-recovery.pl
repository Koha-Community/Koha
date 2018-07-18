#!/usr/bin/perl

use Modern::Perl;
use CGI;

use C4::Auth;
use C4::Koha;
use C4::Output;
use C4::Context;
use Koha::Patron::Password::Recovery
  qw(SendPasswordRecoveryEmail ValidateBorrowernumber GetValidLinkInfo CompletePasswordRecovery DeleteExpiredPasswordRecovery);
use Koha::Patrons;
use Koha::Patrons;
my $query = new CGI;
use HTML::Entities;

my ( $template, $dummy, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-password-recovery.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
        debug           => 1,
    }
);

my $email          = $query->param('email') // q{};
my $password       = $query->param('password');
my $repeatPassword = $query->param('repeatPassword');
my $id             = $query->param('id');
my $uniqueKey      = $query->param('uniqueKey');
my $username       = $query->param('username') // q{};
my $borrower_number;

#errors
my $hasError;

#email form error
my $errNoBorrowerFound;
my $errNoBorrowerEmail;
my $errMultipleAccountsForEmail;
my $errAlreadyStartRecovery;
my $errTooManyEmailFound;
my $errBadEmail;

#new password form error
my $errLinkNotValid;

if ( $query->param('sendEmail') || $query->param('resendEmail') ) {

    #try with the main email
    my $borrower;
    my $search_results;

    # Find the borrower by userid, card number, or email
    if ($username) {
        $search_results = Koha::Patrons->search( { -or => { userid => $username, cardnumber => $username } } );
    }
    elsif ($email) {
        $search_results = Koha::Patrons->search( { -or => { email => $email, emailpro => $email, B_email  => $email } } );
    }

    if ( !defined $search_results || $search_results->count < 1) {
        $hasError           = 1;
        $errNoBorrowerFound = 1;
    }
    elsif ( $username && $search_results->count > 1) { # Multiple accounts for username
        $hasError           = 1;
        $errNoBorrowerFound = 1;
    }
    elsif ( $email && $search_results->count > 1) { # Muliple accounts for E-Mail
        $hasError           = 1;
        $errMultipleAccountsForEmail = 1;
    }
    elsif ( $borrower = $search_results->next() ) {    # One matching borrower
        my @emails = ( $borrower->email, $borrower->emailpro, $borrower->B_email );

        my $firstNonEmptyEmail = '';
        foreach my $address ( @emails ) {
            $firstNonEmptyEmail = $address if length $address;
            last if $firstNonEmptyEmail;
        }

        # Is the given email one of the borrower's ?
        if ( $email && !( grep { $_ eq $email } @emails ) ) {
            $hasError    = 1;
            $errNoBorrowerFound = 1;
        }

        # If there is no given email, and there is no email on record
        elsif ( !$email && !$firstNonEmptyEmail ) {
            $hasError           = 1;
            $errNoBorrowerEmail = 1;
        }

# Check if a password reset already issued for this borrower AND we are not asking for a new email
        elsif ( not $query->param('resendEmail') ) {
            if ( ValidateBorrowernumber( $borrower->borrowernumber ) ) {
                $hasError                = 1;
                $errAlreadyStartRecovery = 1;
            }
            else {
                DeleteExpiredPasswordRecovery( $borrower->borrowernumber );
            }
        }
        # Set the $email, if we don't have one.
        if ( !$hasError && !$email ) {
            $email = $firstNonEmptyEmail;
        }
    }
    else {    # 0 matching borrower
        $hasError           = 1;
        $errNoBorrowerFound = 1;
    }
    if ($hasError) {
        $template->param(
            hasError                => 1,
            errNoBorrowerFound      => $errNoBorrowerFound,
            errTooManyEmailFound    => $errTooManyEmailFound,
            errAlreadyStartRecovery => $errAlreadyStartRecovery,
            errBadEmail             => $errBadEmail,
            errNoBorrowerEmail      => $errNoBorrowerEmail,
            errMultipleAccountsForEmail => $errMultipleAccountsForEmail,
            password_recovery       => 1,
            email                   => HTML::Entities::encode($email),
            username                => $username
        );
    }
    elsif ( SendPasswordRecoveryEmail( $borrower, $email, scalar $query->param('resendEmail') ) ) {    # generate uuid and send recovery email
        $template->param(
            mail_sent => 1,
            email     => $email
        );
    }
    else {    # if it doesn't work....
        $template->param(
            hasError          => 1,
            password_recovery => 1,
            sendmailError     => 1
        );
    }
}
elsif ( $query->param('passwordReset') ) {
    ( $borrower_number, $username ) = GetValidLinkInfo($uniqueKey);

    my $error;
    if ( not $borrower_number ) {
        $error = 'errLinkNotValid';
    } elsif ( $password ne $repeatPassword ) {
        $error = 'errPassNotMatch';
    } else {
        my ( $is_valid, $err) = Koha::AuthUtils::is_password_valid( $password );
        unless ( $is_valid ) {
            $error = 'password_too_short' if $err eq 'too_short';
            $error = 'password_too_weak' if $err eq 'too_weak';
            $error = 'password_has_whitespaces' if $err eq 'has_whitespaces';
        } else {
            Koha::Patrons->find($borrower_number)->update_password( $username, $password );
            CompletePasswordRecovery($uniqueKey);
            $template->param(
                password_reset_done => 1,
                username            => $username
            );
        }
    }
    if ( $error ) {
        $template->param(
            new_password => 1,
            email        => $email,
            uniqueKey    => $uniqueKey,
            hasError     => 1,
            $error       => 1,
        );
    }
}
elsif ($uniqueKey) {    #reset password form
                        #check if the link is valid
    ( $borrower_number, $username ) = GetValidLinkInfo($uniqueKey);

    if ( !$borrower_number ) {
        $errLinkNotValid = 1;
    }

    $template->param(
        new_password    => 1,
        email           => $email,
        uniqueKey       => $uniqueKey,
        username        => $username,
        errLinkNotValid => $errLinkNotValid,
        hasError        => ( $errLinkNotValid ? 1 : 0 ),
    );
}
else {    #password recovery form (to send email)
    $template->param( password_recovery => 1 );
}

output_html_with_http_headers $query, $cookie, $template->output;
