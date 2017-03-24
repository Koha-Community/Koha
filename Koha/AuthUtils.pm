package Koha::AuthUtils;

# Copyright 2013 Catalyst IT
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
use Crypt::Eksblowfish::Bcrypt qw(bcrypt en_base64);
use Encode qw( encode is_utf8 );
use Fcntl qw/O_RDONLY/; # O_RDONLY is used in generate_salt
use List::MoreUtils qw/ any /;
use Koha::Patron;

use base 'Exporter';

our @EXPORT_OK   = qw(hash_password get_script_name);

=head1 NAME

Koha::AuthUtils - utility routines for authentication

=head1 SYNOPSIS

    use Koha::AuthUtils qw/hash_password/;
    my $hash = hash_password($password);

=head1 DESCRIPTION

This module provides utility functions related to managing
user passwords.

=head1 FUNCTIONS

=head2 hash_password

    my $hash = Koha::AuthUtils::hash_password($password, $settings);

=cut

# Using Bcrypt method for hashing. This can be changed to something else in future, if needed.
sub hash_password {
    my $password = shift;
    $password = Encode::encode( 'UTF-8', $password )
      if Encode::is_utf8($password);

    # Generate a salt if one is not passed
    my $settings = shift;
    unless( defined $settings ){ # if there are no settings, we need to create a salt and append settings
    # Set the cost to 8 and append a NULL
        $settings = '$2a$08$'.en_base64(generate_salt('weak', 16));
    }
    # Encrypt it
    return bcrypt($password, $settings);
}

=head2 generate_salt

    my $salt = Koha::Auth::generate_salt($strength, $length);

=over

=item strength

For general password salting a C<$strength> of C<weak> is recommend,
For generating a server-salt a C<$strength> of C<strong> is recommended

'strong' uses /dev/random which may block until sufficient entropy is acheived.
'weak' uses /dev/urandom and is non-blocking.

=item length

C<$length> is a positive integer which specifies the desired length of the returned string

=back

=cut


# the implementation of generate_salt is loosely based on Crypt::Random::Provider::File
sub generate_salt {
    # strength is 'strong' or 'weak'
    # length is number of bytes to read, positive integer
    my ($strength, $length) = @_;

    my $source;

    if( $length < 1 ){
        die "non-positive strength of '$strength' passed to Koha::AuthUtils::generate_salt\n";
    }

    if( $strength eq "strong" ){
        $source = '/dev/random'; # blocking
    } else {
        unless( $strength eq 'weak' ){
            warn "unsuppored strength of '$strength' passed to Koha::AuthUtils::generate_salt, defaulting to 'weak'\n";
        }
        $source = '/dev/urandom'; # non-blocking
    }

    sysopen SOURCE, $source, O_RDONLY
        or die "failed to open source '$source' in Koha::AuthUtils::generate_salt\n";

    # $bytes is the bytes just read
    # $string is the concatenation of all the bytes read so far
    my( $bytes, $string ) = ("", "");

    # keep reading until we have $length bytes in $strength
    while( length($string) < $length ){
        # return the number of bytes read, 0 (EOF), or -1 (ERROR)
        my $return = sysread SOURCE, $bytes, $length - length($string);

        # if no bytes were read, keep reading (if using /dev/random it is possible there was insufficient entropy so this may block)
        next unless $return;
        if( $return == -1 ){
            die "error while reading from $source in Koha::AuthUtils::generate_salt\n";
        }

        $string .= $bytes;
    }

    close SOURCE;
    return $string;
}

=head2 get_script_name

This returns the correct script name, for use in redirecting back to the correct page after showing
the login screen. It depends on details of the package Plack configuration, and should not be used
outside this context.

=cut

sub get_script_name {
    # This is the method about.pl uses to detect Plack; now that two places use it, it MUST be
    # right.
    if ( ( any { /(^psgi\.|^plack\.)/i } keys %ENV ) && $ENV{SCRIPT_NAME} =~ m,^/(intranet|opac)(.*), ) {
        return '/cgi-bin/koha' . $2;
    } else {
        return $ENV{SCRIPT_NAME};
    }
}

=head checkHash

    my $passwordOk = Koha::AuthUtils::checkHash($password1, $password2)

Checks if a clear-text String/password matches the given hash when
MD5 or Bcrypt hashing algorith is applied to it.

Bcrypt is applied if @PARAM2 starts with '$2'
MD5 otherwise

@PARAM1 String, clear text passsword or any other String
@PARAM2 String, hashed text password or any other String.
@RETURN Boolean, 1 if given parameters match
               , 0 if not
=cut

sub checkHash {
    my ( $password, $stored_hash ) = @_;

    $password = Encode::encode( 'UTF-8', $password )
            if Encode::is_utf8($password);

    return if $stored_hash eq '!';

    my $hash;
    if ( substr( $stored_hash, 0, 2 ) eq '$2' ) {
        $hash = hash_password( $password, $stored_hash );
    } else {
        #@DEPRECATED Digest::MD5, don't use it or you will get hurt.
        require Digest::MD5;
        $hash = Digest::MD5::md5_base64($password);
    }
    return $hash eq $stored_hash;
}

=head checkKohaSuperuser

    my $borrower = Koha::AuthUtils::checkKohaSuperuser($userid, $password);

Check if the userid and password match the ones in the $KOHA_CONF
@PARAM1 String, user identifier, either the koha.borrowers.userid, or koha.borrowers.cardnumber
@PARAM2 String, clear text password from the authenticating user
@RETURNS Koha::Borrower branded as superuser with ->isSuperuser()
         or undef if user logging in is not a superuser.
@THROWS Koha::Exception::LoginFailed if user identifier matches, but password doesn't
=cut

sub checkKohaSuperuser {
    my ($userid, $password) = @_;

    if ( $userid && $userid eq C4::Context->config('user') ) {
        if ( $password && $password eq C4::Context->config('pass') ) {
            return _createTemporarySuperuser();
        }
        else {
            Koha::Exception::LoginFailed->throw(error => "Password authentication failed");
        }
    }
}

=head checkKohaSuperuserFromUserid
See checkKohaSuperuser(), with only the "user identifier"-@PARAM.
@THROWS nothing.
=cut

sub checkKohaSuperuserFromUserid {
    my ($userid) = @_;

    if ( $userid && $userid eq C4::Context->config('user') ) {
        return _createTemporarySuperuser();
    }
}

=head _createTemporarySuperuser

Create a temporary superuser which should be instantiated only to the environment
and then discarded. So do not ->store() it!
@RETURN Koha::Borrower, stamped as superuser.
=cut

sub _createTemporarySuperuser {
    my $borrower = Koha::Patron->new();

    my $superuserName = C4::Context->config('user');
    $borrower->isSuperuser(1);
    $borrower->set({borrowernumber => 0,
                       userid     => $superuserName,
                       cardnumber => $superuserName,
                       firstname  => $superuserName,
                       surname    => $superuserName,
                       branchcode => 'NO_LIBRARY_SET',
                       email      => C4::Context->preference('KohaAdminEmailAddress')
                    });
    return $borrower;
}

1;

__END__

=head1 SEE ALSO

Crypt::Eksblowfish::Bcrypt(3)

=cut
