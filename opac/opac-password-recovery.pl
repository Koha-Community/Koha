#!/usr/bin/perl

use Modern::Perl;
use CGI;

use C4::Auth;
use C4::Koha;
use C4::Members qw(changepassword);
use C4::Output;
use C4::Context;
use Koha::Patron::Password::Recovery
  qw(SendPasswordRecoveryEmail ValidateBorrowernumber GetValidLinkInfo CompletePasswordRecovery);
use Koha::AuthUtils qw(hash_password);
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
my $minPassLength  = C4::Context->preference('minPasswordLength');
my $id             = $query->param('id');
my $uniqueKey      = $query->param('uniqueKey');
my $username       = $query->param('username');
my $borrower_number;

#errors
my $hasError;

#email form error
my $errNoBorrowerFound;
my $errNoBorrowerEmail;
my $errAlreadyStartRecovery;
my $errTooManyEmailFound;
my $errBadEmail;

#new password form error
my $errLinkNotValid;
my $errPassNotMatch;
my $errPassTooShort;

if ( $query->param('sendEmail') || $query->param('resendEmail') ) {

    #try with the main email
    $email ||= '';    # avoid undef
    my $borrower;
    my $search_results;

    # Find the borrower by his userid or email
    if ($username) {
        $search_results = [ Koha::Patrons->search( { userid => $username } ) ];
    }
    elsif ($email) {
        $search_results = [ Koha::Patrons->search( { -or => { email => $email, emailpro => $email, B_email  => $email } } ) ];
    }
    if ( not $search_results || scalar @$search_results > 1 ) {
        $hasError           = 1;
        $errNoBorrowerFound = 1;
    }
    elsif ( $borrower = shift @$search_results ) {    # One matching borrower
        $username ||= $borrower->userid;
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

# If we dont have an email yet. Get one of the borrower's email or raise an error.
        elsif ( !$email && !( $email = $firstNonEmptyEmail ) ) {
            $hasError           = 1;
            $errNoBorrowerEmail = 1;
        }

# Check if a password reset already issued for this borrower AND we are not asking for a new email
        elsif ( ValidateBorrowernumber( $borrower->borrowernumber )
            && !$query->param('resendEmail') )
        {
            $hasError                = 1;
            $errAlreadyStartRecovery = 1;
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
            password_recovery       => 1,
            email                   => HTML::Entities::encode($email),
            username                => $username
        );
    }
    elsif ( SendPasswordRecoveryEmail( $borrower, $email, $query->param('resendEmail') ) ) {    # generate uuid and send recovery email
        $template->param(
            mail_sent => 1,
            email     => $email
        );
    }
    else {    # if it doesn't work....
        $template->param(
            password_recovery => 1,
            sendmailError     => 1
        );
    }
}
elsif ( $query->param('passwordReset') ) {
    ( $borrower_number, $username ) = GetValidLinkInfo($uniqueKey);

    #validate password length & match
    if (   ($borrower_number)
        && ( $password eq $repeatPassword )
        && ( length($password) >= $minPassLength ) )
    {    #apply changes
        changepassword( $username, $borrower_number, hash_password($password) );
        CompletePasswordRecovery($uniqueKey);
        $template->param(
            password_reset_done => 1,
            username            => $username
        );
    }
    else {    #errors
        if ( !$borrower_number ) {    #parameters not valid
            $errLinkNotValid = 1;
        }
        elsif ( $password ne $repeatPassword ) {    #passwords does not match
            $errPassNotMatch = 1;
        }
        elsif ( length($password) < $minPassLength ) {    #password too short
            $errPassTooShort = 1;
        }
        $template->param(
            new_password    => 1,
            minPassLength   => $minPassLength,
            email           => $email,
            uniqueKey       => $uniqueKey,
            errLinkNotValid => $errLinkNotValid,
            errPassNotMatch => $errPassNotMatch,
            errPassTooShort => $errPassTooShort,
            hasError        => 1
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
        minPassLength   => $minPassLength,
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
