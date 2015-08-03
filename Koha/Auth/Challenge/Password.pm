package Koha::Auth::Challenge::Password;

# Copyright 2015 Vaara-kirjastot
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

use Modern::Perl;

use Koha::Patrons;
use Koha::AuthUtils;

use base qw(Koha::Auth::Challenge);

use Koha::Exception::LoginFailed;

our @usernameAliasColumns = ('userid', 'cardnumber'); #Possible columns to treat as the username when authenticating. Must be UNIQUE in DB.

=head NAME Koha::Auth::Challenge::Password

=head SYNOPSIS

This module implements the more specific behaviour of the password authentication component.

=cut

=head challenge
STATIC

    Koha::Auth::Challenge::Password::challenge();

@RETURN Koha::Patron-object if check succeedes, otherwise throws exceptions.
@THROWS Koha::Exception::LoginFailed from Koha::AuthUtils password checks.
=cut

sub challenge {
    my ($userid, $password) = @_;

    my $borrower;
    if (C4::Context->config('useldapserver')) {
        $borrower = Koha::Auth::Challenge::Password::checkLDAPPassword($userid, $password);
        return $borrower if $borrower;
    }
    if (C4::Context->preference('casAuthentication')) {
        warn("Koha::Auth doesn't support CAS-authentication yet. Please refactor the CAS client implementation to work with Koha::Auth. It cant be too hard :)");
    }
    if (C4::Context->config('useshibboleth')) {
        warn("Koha::Auth doesn't support Shibboleth-authentication yet. Please refactor the Shibboleth client implementation to work with Koha::Auth. It cant be too hard :)");
    }

    return Koha::Auth::Challenge::Password::checkKohaPassword($userid, $password);
}

=head checkKohaPassword

    my $borrower = Koha::Auth::Challenge::Password::checkKohaPassword($userid, $password);

Checks if the given username and password match anybody in the Koha DB
@PARAM1 String, user identifier, either the koha.borrowers.userid, or koha.borrowers.cardnumber
@PARAM2 String, clear text password from the authenticating user
@RETURN Koha::Patron, if login succeeded.
                Sets Koha::Patron->isSuperuser() if the user is a superuser.
@THROWS Koha::Exception::LoginFailed, if no matching password was found for all username aliases in Koha.
=cut

sub checkKohaPassword {
    my ($userid, $password) = @_;
    my $borrower; #Find the borrower to return

    $borrower = Koha::AuthUtils::checkKohaSuperuser($userid, $password);
    return $borrower if $borrower;

    my $usernameFound = 0; #Report to the user if userid/barcode was found, even if the login failed.
    #Check for each username alias if we can confirm a login with that.
    for my $unameAlias (@usernameAliasColumns) {
        my $borrower = Koha::Patrons->find({$unameAlias => $userid});
        if ( $borrower ) {
            $usernameFound = 1;
            return $borrower if ( Koha::AuthUtils::checkHash( $password, $borrower->password ) );
        }
    }

    Koha::Exception::LoginFailed->throw(error => "Password authentication failed for the given ".( ($usernameFound) ? "password" : "username and password").".");
}

=head checkLDAPPassword

Checks if the given username and password match anybody in the LDAP service
@PARAM1 String, user identifier
@PARAM2 String, clear text password from the authenticating user
@RETURN Koha::Patron, or
            undef if we couldn't reliably contact the LDAP server so we should
            fallback to local Koha Password authentication.
@THROWS Koha::Exception::LoginFailed, if LDAP login failed
=cut

sub checkLDAPPassword {
    my ($userid, $password) = @_;

    #Lazy load dependencies because somebody might never need them.
    require C4::Auth_with_ldap;

    my ($retval, $cardnumber, $local_userid) = C4::Auth_with_ldap::checkpw_ldap($userid, $password);    # EXTERNAL AUTH
    if ($retval == -1) {
        Koha::Exception::LoginFailed->throw(error => "LDAP authentication failed for the given username and password");
    }

    if ($retval) {
        my $borrower = Koha::Patrons->find({userid => $local_userid});
        return $borrower;
    }
    return undef;
}

1;
