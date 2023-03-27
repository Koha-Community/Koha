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
use Crypt::Eksblowfish::Bcrypt qw( bcrypt en_base64 );
use Encode;
use Fcntl qw( O_RDONLY ); # O_RDONLY is used in generate_salt
use List::MoreUtils qw( any );
use String::Random qw( random_string );
use Koha::Exceptions::Password;

use C4::Context;


our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK = qw(hash_password get_script_name is_password_valid);
};
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

Hash I<$password> using Bcrypt. Accepts an extra I<$settings> parameter for salt.
If I<$settings> is not passed, a new salt is generated.

WARNING: If this method implementation is changed in the future, as of
bug 28772 there's at least one DBRev that uses this code and should
be taken care of.

=cut

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
    # Hash it
    return bcrypt($password, $settings);
}

=head2 generate_salt

    my $salt = Koha::Auth::generate_salt($strength, $length);

=over

=item strength

For general password salting a C<$strength> of C<weak> is recommend,
For generating a server-salt a C<$strength> of C<strong> is recommended

'strong' uses /dev/random which may block until sufficient entropy is achieved.
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

    my $source_fh;
    sysopen $source_fh, $source, O_RDONLY
        or die "failed to open source '$source' in Koha::AuthUtils::generate_salt\n";

    # $bytes is the bytes just read
    # $string is the concatenation of all the bytes read so far
    my( $bytes, $string ) = ("", "");

    # keep reading until we have $length bytes in $strength
    while( length($string) < $length ){
        # return the number of bytes read, 0 (EOF), or -1 (ERROR)
        my $return = sysread $source_fh, $bytes, $length - length($string);

        # if no bytes were read, keep reading (if using /dev/random it is possible there was insufficient entropy so this may block)
        next unless $return;
        if( $return == -1 ){
            die "error while reading from $source in Koha::AuthUtils::generate_salt\n";
        }

        $string .= $bytes;
    }

    close $source_fh;
    return $string;
}

=head2 is_password_valid

my ( $is_valid, $error ) = is_password_valid( $password, $category );

return $is_valid == 1 if the password match category's minimum password length and strength if provided, or general minPasswordLength and RequireStrongPassword conditions
otherwise return $is_valid == 0 and $error will contain the error ('too_short' or 'too_weak')

=cut

sub is_password_valid {
    my ($password, $category) = @_;
    if(!$category) {
        Koha::Exceptions::Password::NoCategoryProvided->throw();
    }
    my $minPasswordLength = $category->effective_min_password_length;
    $minPasswordLength = 3 if not $minPasswordLength or $minPasswordLength < 3;
    if ( length($password) < $minPasswordLength ) {
        return ( 0, 'too_short' );
    }
    elsif ( $category->effective_require_strong_password ) {
        return ( 0, 'too_weak' )
          if $password !~ m|(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).{$minPasswordLength,}|;
    }
    return ( 0, 'has_whitespaces' ) if $password =~ m[^\s|\s$];
    return ( 1, undef );
}

=head2 generate_password

my password = generate_password($category);

Generate a password according to category's minimum password length and strength if provided, or to the minPasswordLength and RequireStrongPassword system preferences.

=cut

sub generate_password {
    my ($category) = @_;
    if(!$category) {
        Koha::Exceptions::Password::NoCategoryProvided->throw();
    }
    my $minPasswordLength = $category->effective_min_password_length;
    $minPasswordLength = 8 if not $minPasswordLength or $minPasswordLength < 8;

    my ( $password, $is_valid );
    do {
        $password = random_string('.' x $minPasswordLength );
        ( $is_valid, undef ) = is_password_valid( $password, $category );
    } while not $is_valid;
    return $password;
}


=head2 get_script_name

This returns the correct script name, for use in redirecting back to the correct page after showing
the login screen. It depends on details of the package Plack configuration, and should not be used
outside this context.

=cut

sub get_script_name {
    if ( ( C4::Context->psgi_env ) && $ENV{SCRIPT_NAME} && $ENV{SCRIPT_NAME} =~ m,^/(intranet|opac)(.*), ) {
        return '/cgi-bin/koha' . $2;
    } else {
        return $ENV{SCRIPT_NAME};
    }
}

1;

__END__

=head1 SEE ALSO

Crypt::Eksblowfish::Bcrypt(3)

=cut
