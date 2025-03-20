#!/usr/bin/perl

use Modern::Perl;
use CGI;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_html_with_http_headers );
use C4::Context;
use Koha::Patron::Password::Recovery qw(
    CompletePasswordRecovery
    DeleteExpiredPasswordRecovery
    GetValidLinkInfo
    SendPasswordRecoveryEmail
    ValidateBorrowernumber
);
use Koha::Patrons;
my $query = CGI->new;
use HTML::Entities;
use Try::Tiny  qw( catch try );
use List::Util qw( any );

my ( $template, $dummy, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-password-recovery.tt",
        query           => $query,
        type            => "opac",
        authnotrequired => 1,
    }
);

my $op             = $query->param('op')    // q{};
my $email          = $query->param('email') // q{};
my $password       = $query->param('newPassword');
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
my $errResetForbidden;

#new password form error
my $errLinkNotValid;

if ( $op eq 'cud-sendEmail' || $op eq 'cud-resendEmail' ) {

    #try with the main email
    my $borrower;
    my $search_results;

    # Find the borrower by userid, card number, or email
    if ($username) {
        $search_results = Koha::Patrons->search(
            {
                -or            => { userid => $username, cardnumber => $username },
                login_attempts => { '!=', Koha::Patron::ADMINISTRATIVE_LOCKOUT }
            }
        );
    } elsif ($email) {
        $search_results = Koha::Patrons->search(
            {
                -or            => { email => $email, emailpro => $email, B_email => $email },
                login_attempts => { '!=', Koha::Patron::ADMINISTRATIVE_LOCKOUT }
            }
        );
    }

    if ( !defined $search_results || $search_results->count < 1 ) {
        $hasError           = 1;
        $errNoBorrowerFound = 1;
    } elsif ( $username && $search_results->count > 1 ) {    # Multiple accounts for username
        $hasError           = 1;
        $errNoBorrowerFound = 1;
    } elsif ( $email && $search_results->count > 1 ) {       # Multiple accounts for E-Mail
        $hasError                    = 1;
        $errMultipleAccountsForEmail = 1;
    } elsif ( $borrower = $search_results->next() ) {        # One matching borrower

        if ( $borrower->category->effective_reset_password ) {

            my @emails = grep { $_ } ( $borrower->email, $borrower->emailpro, $borrower->B_email );

            my $firstNonEmptyEmail;
            $firstNonEmptyEmail = $emails[0] if @emails;

            # Is the given email one of the borrower's ?
            if ( $email && !( any { lc($_) eq lc($email) } @emails ) ) {
                $hasError           = 1;
                $errNoBorrowerFound = 1;
            }

            # If there is no given email, and there is no email on record
            elsif ( !$email && !$firstNonEmptyEmail ) {
                $hasError           = 1;
                $errNoBorrowerEmail = 1;
            }

            # Check if a password reset already issued for this
            # borrower AND we are not asking for a new email
            elsif ( $op ne 'cud-resendEmail' ) {
                if ( ValidateBorrowernumber( $borrower->borrowernumber ) ) {
                    $hasError                = 1;
                    $errAlreadyStartRecovery = 1;
                } else {
                    DeleteExpiredPasswordRecovery( $borrower->borrowernumber );
                }
            }

            # Set the $email, if we don't have one.
            if ( !$hasError && !$email ) {
                $email = $firstNonEmptyEmail;
            }
        } else {
            $hasError          = 1;
            $errResetForbidden = 1;
        }
    } else {    # 0 matching borrower
        $hasError           = 1;
        $errNoBorrowerFound = 1;
    }
    if ($hasError) {
        $template->param(
            hasError                    => 1,
            errNoBorrowerFound          => $errNoBorrowerFound,
            errAlreadyStartRecovery     => $errAlreadyStartRecovery,
            errNoBorrowerEmail          => $errNoBorrowerEmail,
            errMultipleAccountsForEmail => $errMultipleAccountsForEmail,
            errResetForbidden           => $errResetForbidden,
            password_recovery           => 1,
            email                       => HTML::Entities::encode($email),
            username                    => $username
        );
    } elsif ( SendPasswordRecoveryEmail( $borrower, $email ) ) {    # generate uuid and send recovery email
        $template->param(
            mail_sent => 1,
            email     => $email
        );
    } else {                                                        # if it doesn't work....
        $template->param(
            hasError          => 1,
            password_recovery => 1,
            sendmailError     => 1
        );
    }
} elsif ( $op eq 'cud-reset_password' ) {
    ( $borrower_number, $username ) = GetValidLinkInfo($uniqueKey);

    my $error;
    my $min_password_length     = C4::Context->preference('minPasswordLength');
    my $require_strong_password = C4::Context->preference('RequireStrongPassword');
    if ( not $borrower_number ) {
        $error = 'errLinkNotValid';
    } elsif ( $password ne $repeatPassword ) {
        $error = 'errPassNotMatch';
    } else {
        my $borrower = Koha::Patrons->find($borrower_number);
        $min_password_length     = $borrower->category->effective_min_password_length;
        $require_strong_password = $borrower->category->effective_require_strong_password;
        try {
            $borrower->set_password( { password => $password, action => 'RESET PASS' } );

            CompletePasswordRecovery($uniqueKey);
            $template->param(
                password_reset_done => 1,
                username            => $username
            );
        } catch {
            if ( $_->isa('Koha::Exceptions::Password::TooShort') ) {
                $error = 'password_too_short';
            } elsif ( $_->isa('Koha::Exceptions::Password::WhitespaceCharacters') ) {
                $error = 'password_has_whitespaces';
            } elsif ( $_->isa('Koha::Exceptions::Password::TooWeak') ) {
                $error = 'password_too_weak';
            }
        };
    }
    if ($error) {
        $template->param(
            new_password          => 1,
            email                 => $email,
            uniqueKey             => $uniqueKey,
            hasError              => 1,
            $error                => 1,
            minPasswordLength     => $min_password_length,
            RequireStrongPassword => $require_strong_password
        );
    }
} elsif ($uniqueKey) {    #reset password form
                          #check if the link is valid
    ( $borrower_number, $username ) = GetValidLinkInfo($uniqueKey);

    if ( !$borrower_number ) {
        $errLinkNotValid = 1;
    }

    my $borrower = Koha::Patrons->find($borrower_number);

    $template->param(
        new_password          => 1,
        email                 => $email,
        uniqueKey             => $uniqueKey,
        username              => $username,
        errLinkNotValid       => $errLinkNotValid,
        hasError              => ( $errLinkNotValid ? 1 : 0 ),
        minPasswordLength     => $borrower ? $borrower->category->effective_min_password_length     : undef,
        RequireStrongPassword => $borrower ? $borrower->category->effective_require_strong_password : undef,
    );
} else {    #password recovery form (to send email)
    $template->param( password_recovery => 1 );
}

output_html_with_http_headers $query, $cookie, $template->output;
