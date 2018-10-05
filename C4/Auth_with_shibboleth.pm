package C4::Auth_with_shibboleth;

# Copyright 2014 PTFS Europe
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

use C4::Debug;
use C4::Context;
use Koha::AuthUtils qw(get_script_name);
use Koha::Database;
use Koha::Patrons;
use C4::Members::Messaging;
use Carp;
use CGI;
use List::Util qw(any);

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $debug);

BEGIN {
    require Exporter;
    $debug   = $ENV{DEBUG};
    @ISA     = qw(Exporter);
    @EXPORT =
      qw(shib_ok logout_shib login_shib_url checkpw_shib get_login_shib);
}

# Check that shib config is not malformed
sub shib_ok {
    my $config = _get_shib_config();

    if ($config) {
        return 1;
    }

    return 0;
}

# Logout from Shibboleth
sub logout_shib {
    my ($query) = @_;
    my $uri = _get_uri();
    print $query->redirect( $uri . "/Shibboleth.sso/Logout?return=$uri" );
}

# Returns Shibboleth login URL with callback to the requesting URL
sub login_shib_url {
    my ($query) = @_;

    my $param = _get_uri() . get_script_name();
    if ( $query->query_string() ) {
        $param = $param . '%3F' . $query->query_string();
    }
    my $uri = _get_uri() . "/Shibboleth.sso/Login?target=$param";
    return $uri;
}

# Returns shibboleth user login
sub get_login_shib {

# In case of a Shibboleth authentication, we expect a shibboleth user attribute
# to contain the login match point of the shibboleth-authenticated user. This match
# point is configured in koha-conf.xml

# Shibboleth attributes are mapped into http environmement variables, so we're getting
# the match point of the user this way

    # Get shibboleth config
    my $config = _get_shib_config();

    my $matchAttribute = $config->{mapping}->{ $config->{matchpoint} }->{is};

    if ( any { /(^psgi\.|^plack\.)/i } keys %ENV ) {
      $debug and warn $matchAttribute . " value: " . $ENV{"HTTP_".uc($matchAttribute)};
      return $ENV{"HTTP_".uc($matchAttribute)} || '';
    } else {
      $debug and warn $matchAttribute . " value: " . $ENV{$matchAttribute};
      return $ENV{$matchAttribute} || '';
    }
}

# Checks for password correctness
# In our case : does the given attribute match one of our users ?
sub checkpw_shib {
    $debug and warn "checkpw_shib";

    my ( $match ) = @_;
    my $config = _get_shib_config();
    $debug and warn "User Shibboleth-authenticated as: $match";

    # Does the given shibboleth attribute value ($match) match a valid koha user ?
    my $borrower =
      Koha::Database->new()->schema()->resultset('Borrower')
      ->find( { $config->{matchpoint} => $match } );
    if ( defined($borrower) ) {
        return ( 1, $borrower->get_column('cardnumber'), $borrower->get_column('userid') );
    }

    if ( $config->{'autocreate'} ) {
        return _autocreate( $config, $match );
    } else {
        # If we reach this point, the user is not a valid koha user
         $debug and warn "User with $config->{matchpoint} of $match is not a valid Koha user";
        return 0;
    }
}

sub _autocreate {
    my ( $config, $match ) = @_;

    my %borrower = ( $config->{matchpoint} => $match );

    while ( my ( $key, $entry ) = each %{$config->{'mapping'}} ) {
        $borrower{$key} = ( $entry->{'is'} && $ENV{ $entry->{'is'} } ) || $entry->{'content'} || '';
    }

    my $patron = Koha::Patron->new( \%borrower )->store;
    C4::Members::Messaging::SetMessagingPreferencesFromDefaults( { borrowernumber => $patron->borrowernumber, categorycode => $patron->categorycode } );

    return ( 1, $patron->cardnumber, $patron->userid );
}

sub _get_uri {

    my $protocol = "https://";
    my $interface = C4::Context->interface;
    $debug and warn "shibboleth interface: " . $interface;

    my $uri;
    if ( $interface eq 'intranet' ) {

        $uri = C4::Context->preference('staffClientBaseURL') // '';
        if ($uri eq '') {
            $debug and warn 'staffClientBaseURL not set!';
        }
    } else {
        $uri = C4::Context->preference('OPACBaseURL') // '';
        if ($uri eq '') {
            $debug and warn 'OPACBaseURL not set!';
        }
    }

    if ($uri =~ /(.*):\/\/(.*)/) {
        my $oldprotocol = $1;
        if ($oldprotocol ne 'https') {
            $debug
                and warn
                  'Shibboleth requires OPACBaseURL/staffClientBaseURL to use the https protocol!';
        }
        $uri = $2;
    }
    my $return = $protocol . $uri;
    return $return;
}

sub _get_shib_config {
    my $config = C4::Context->config('shibboleth');

    if ( !$config ) {
        carp 'shibboleth config not defined';
        return 0;
    }

    if ( $config->{matchpoint}
        && defined( $config->{mapping}->{ $config->{matchpoint} }->{is} ) )
    {
        if ($debug) {
            warn "koha borrower field to match: " . $config->{matchpoint};
            warn "shibboleth attribute to match: "
              . $config->{mapping}->{ $config->{matchpoint} }->{is};
        }
        return $config;
    }
    else {
        if ( !$config->{matchpoint} ) {
            carp 'shibboleth matchpoint not defined';
        }
        else {
            carp 'shibboleth matchpoint not mapped';
        }
        return 0;
    }
}

1;
__END__

=head1 NAME

C4::Auth_with_shibboleth

=head1 SYNOPSIS

use C4::Auth_with_shibboleth;

=head1 DESCRIPTION

This module is specific to Shibboleth authentication in koha and relies heavily upon the native shibboleth service provider package in your operating system.

=head1 CONFIGURATION

To use this type of authentication these additional packages are required:

=over

=item *

libapache2-mod-shib2

=item *

libshibsp5:amd64

=item *

shibboleth-sp2-schemas

=back

We let the native shibboleth service provider packages handle all the complexities of shibboleth negotiation for us, and configuring this is beyond the scope of this documentation.

But to sum up, to get shibboleth working in koha, as a minimum you will need to:

=over

=item 1.

Create some metadata for your koha instance (if you're in a single instance setup then the default metadata available at https://youraddress.com/Shibboleth.sso/Metadata should be adequate)

=item 2.

Swap metadata with your Identidy Provider (IdP)

=item 3.

Map their attributes to what you want to see in koha

=item 4.

Tell apache that we wish to allow koha to authenticate via shibboleth.

This is as simple as adding the below to your virtualhost config (for CGI running):

 <Location />
   AuthType shibboleth
   Require shibboleth
 </Location>

Or (for Plack running):

 <Location />
   AuthType shibboleth
   Require shibboleth
   ShibUseEnvironment Off
   ShibUseHeaders On
 </Location>

IMPORTANT: Please note, if you are running in the plack configuration you should consult https://wiki.shibboleth.net/confluence/display/SHIB2/NativeSPSpoofChecking for security advice regarding header spoof checking settings. (See also bug 17776 on Bugzilla about enabling ShibUseHeaders.)

=item 5.

Configure koha to listen for shibboleth environment variables.

This is as simple as enabling B<useshibboleth> in koha-conf.xml:

 <useshibboleth>1</useshibboleth>

=item 6.

Map shibboleth attributes to koha fields, and configure authentication match point in koha-conf.xml.

 <shibboleth>
   <matchpoint>userid</matchpoint> <!-- koha borrower field to match upon -->
   <mapping>
     <userid is="eduPersonID"></userid> <!-- koha borrower field to shibboleth attribute mapping -->
   </mapping>
 </shibboleth>

Note: The minimum you need here is a <matchpoint> block, containing a valid column name from the koha borrowers table, and a <mapping> block containing a relation between the chosen matchpoint and the shibboleth attribute name.

=back

It should be as simple as that; you should now be able to login via shibboleth in the opac.

If you need more help configuring your B<S>ervice B<P>rovider to authenticate against a chosen B<Id>entity B<P>rovider then it might be worth taking a look at the community wiki L<page|http://wiki.koha-community.org/wiki/Shibboleth_Configuration>

=head1 FUNCTIONS

=head2 logout_shib

Sends a logout signal to the native shibboleth service provider and then logs out of koha.  Depending upon the native service provider configuration and identity provider capabilities this may or may not perform a single sign out action.

  logout_shib($query);

=head2 login_shib_url

Given a query, this will return a shibboleth login url with return code to page with given given query.

  my $shibLoginURL = login_shib_url($query);

=head2 get_login_shib

Returns the shibboleth login attribute should it be found present in the http session

  my $shib_login = get_login_shib();

=head2 checkpw_shib

Given a shib_login attribute, this routine checks for a matching local user and if found returns true, their cardnumber and their userid.  If a match is not found, then this returns false.

  my ( $retval, $retcard, $retuserid ) = C4::Auth_with_shibboleth::checkpw_shib( $shib_login );

=head2 _get_uri

  _get_uri();

A sugar function to that simply returns the current page URI with appropriate protocol attached

This routine is NOT exported

=head2 _get_shib_config

  my $config = _get_shib_config();

A sugar function that checks for a valid shibboleth configuration, and if found returns a hashref of it's contents

This routine is NOT exported

=head2 _autocreate

  my ( $retval, $retcard, $retuserid ) = _autocreate( $config, $match );

Given a shibboleth attribute reference and a userid this internal routine will add the given user to Koha and return their user credentials.

This routine is NOT exported

=head1 SEE ALSO

=cut
