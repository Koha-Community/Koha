#!/usr/bin/perl
#script to set the password, and optionally a userid, for a borrower
#written 2/5/00
#by chris@katipo.co.nz
#converted to using templates 3/16/03 by mwhansen@hmc.edu

use Modern::Perl;

use C4::Auth   qw( get_template_and_user );
use C4::Output qw( output_and_exit_if_error output_and_exit output_html_with_http_headers );
use C4::Context;
use CGI qw ( -utf8 );

use Koha::Patrons;
use Koha::Patron::Categories;

use Try::Tiny qw( catch try );

my $input = CGI->new;

my $theme = $input->param('theme') || "default";

# only used if allowthemeoverride is set

my ( $template, $loggedinuser, $cookie, $staffflags ) = get_template_and_user(
    {
        template_name => "members/member-password.tt",
        query         => $input,
        type          => "intranet",
        flagsrequired => { borrowers => 'edit_borrowers' },
    }
);

my $op           = $input->param('op') // q{};
my $patron_id    = $input->param('member');
my $destination  = $input->param('destination');
my $newpassword  = $input->param('newpassword');
my $newpassword2 = $input->param('newpassword2');
my $new_user_id  = $input->param('newuserid');

my @errors;

my $logged_in_user = Koha::Patrons->find($loggedinuser);
my $patron         = Koha::Patrons->find($patron_id);
output_and_exit_if_error(
    $input, $cookie, $template,
    { module => 'members', logged_in_user => $logged_in_user, current_patron => $patron }
);

my $category_type = $patron->category->category_type;

if ( ( $patron_id ne $loggedinuser ) && ( $category_type eq 'S' ) ) {
    push( @errors, 'NOPERMISSION' )
        unless ( $staffflags->{'superlibrarian'} || $staffflags->{'staffaccess'} );

    # need superlibrarian for koha-conf.xml fakeuser.
}

push( @errors, 'NOMATCH' ) if ( ( $newpassword && $newpassword2 ) && ( $newpassword ne $newpassword2 ) );

if ( $op eq 'cud-update' && defined($newpassword) and not @errors ) {

    try {
        if ( $newpassword ne '' ) {
            $patron->set_password( { password => $newpassword } );
            $template->param( newpassword => $newpassword );
        }
        $patron->userid($new_user_id)->store
            if $new_user_id and $new_user_id ne $patron->userid;
        if ( $destination eq 'circ' ) {
            print $input->redirect( "/cgi-bin/koha/circ/circulation.pl?findborrower=" . $patron->cardnumber );
        } else {
            print $input->redirect("/cgi-bin/koha/members/moremember.pl?borrowernumber=$patron_id");
        }
    } catch {
        if ( $_->isa('Koha::Exceptions::Password::TooShort') ) {
            push @errors, 'ERROR_password_too_short';
        } elsif ( $_->isa('Koha::Exceptions::Password::WhitespaceCharacters') ) {
            push @errors, 'ERROR_password_has_whitespaces';
        } elsif ( $_->isa('Koha::Exceptions::Password::TooWeak') ) {
            push @errors, 'ERROR_password_too_weak';
        } elsif ( $_->isa('Koha::Exceptions::Password::Plugin') ) {
            push @errors, 'ERROR_from_plugin';
        } else {
            push( @errors, 'BADUSERID' );
        }
    };
}

$template->param(
    patron      => $patron,
    destination => $destination,
);

if ( scalar(@errors) ) {
    $template->param( errormsg => 1 );
    foreach my $error (@errors) {
        $template->param($error) || $template->param( $error => 1 );
    }
}

output_html_with_http_headers $input, $cookie, $template->output;
