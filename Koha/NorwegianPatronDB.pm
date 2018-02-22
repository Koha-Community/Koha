package Koha::NorwegianPatronDB;

# Copyright 2014 Oslo Public Library
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::NorwegianPatronDB

=head1 SYNOPSIS

  use Koha::NorwegianPatronDB;

=head1 CONDITIONAL LOADING

This module depends on some Perl modules that have not been marked as required.
This is because the module only will be of interest to Norwegian libraries, and
it seems polite not to bother the rest of the world with these modules. It is
also good practice to check that the module is actually needed before loading
it. So in a NorwegianPatronDB page or script it will be OK to just do:

  use Koha::NorwegianPatronDB qw(...);

But in scripts that are also used by others (like e.g. moremember.pl), it will
be polite to only load the module at runtime, if it is needed:

  use Module::Load;
  if ( C4::Context->preference('NorwegianPatronDBEnable') && C4::Context->preference('NorwegianPatronDBEnable') == 1 ) {
      load Koha::NorwegianPatronDB, qw( NLGetSyncDataFromBorrowernumber );
  }

(Module::Load::Conditional is used for this in other parts of Koha, but it does
not seem to allow for a list of subroutines to import, so Module::Load looks
like a better candidate.)

=head1 FUNCTIONS

=cut

use Modern::Perl;
use C4::Context;
use C4::Members::Attributes qw( UpdateBorrowerAttribute );
use SOAP::Lite;
use Crypt::GCrypt;
use Digest::SHA qw( sha256_hex );
use Convert::BaseN;
use DateTime;

use base 'Exporter';

our %EXPORT_TAGS = ( all => [qw(
        NLCheckSysprefs
        NLSearch
        NLSync
        NLGetChanged
        NLMarkForDeletion
        NLDecodePin
        NLEncryptPIN
        NLUpdateHashedPIN
        NLGetFirstname
        NLGetSurname
        NLGetSyncDataFromBorrowernumber
)] );
Exporter::export_ok_tags('all');

my $nl_uri   = 'http://lanekortet.no';

=head2 SOAP::Transport::HTTP::Client::get_basic_credentials

This is included to set the username and password used by SOAP::Lite.

=cut

sub SOAP::Transport::HTTP::Client::get_basic_credentials {
    # Library username and password from Base Bibliotek (stored as system preferences)
    my $library_username = C4::Context->preference("NorwegianPatronDBUsername");
    my $library_password = C4::Context->preference("NorwegianPatronDBPassword");
    # Vendor username and password (stored in koha-conf.xml)
    my $vendor_username = C4::Context->config( 'nlvendoruser' );
    my $vendor_password = C4::Context->config( 'nlvendorpass' );
    # Combine usernames and passwords, and encrypt with SHA256
    my $combined_username = "$vendor_username-$library_username";
    my $combined_password = sha256_hex( "$library_password-$vendor_password" );
    return $combined_username => $combined_password;
}

=head2 NLCheckSysprefs

Check that sysprefs relevant to NL are set.

=cut

sub NLCheckSysprefs {

    my $response = {
        'error'     => 0,
        'nlenabled' => 0,
        'endpoint'  => 0,
        'userpass'  => 0,
    };

    # Check that the Norwegian national paron database is enabled
    if ( C4::Context->preference("NorwegianPatronDBEnable") == 1 ) {
        $response->{ 'nlenabled' } = 1;
    } else {
        $response->{ 'error' } = 1;
    }

    # Check that an endpoint is specified
    if ( C4::Context->preference("NorwegianPatronDBEndpoint") ne '' ) {
        $response->{ 'endpoint' } = 1;
    } else {
        $response->{ 'error' } = 1;
    }

    # Check that the username and password for the patron database is set
    if ( C4::Context->preference("NorwegianPatronDBUsername") ne '' && C4::Context->preference("NorwegianPatronDBPassword") ne '' ) {
        $response->{ 'userpass' } = 1;
    } else {
        $response->{ 'error' } = 1;
    }

    return $response;

}

=head2 NLSearch

Search the NL patron database.

SOAP call: "hent" (fetch)

=cut

sub NLSearch {

    my ( $identifier ) = @_;

    my $client = SOAP::Lite
        ->on_action( sub { return '""';})
        ->uri( $nl_uri )
        ->proxy( C4::Context->preference("NorwegianPatronDBEndpoint") );

    my $id = SOAP::Data->type('string');
    $id->name('identifikator');
    $id->value( $identifier );
    my $som = $client->hent( $id );

    return $som;

}

=head2 NLSync

Sync a patron that has been changed or created in Koha "upstream" to NL.

Input is a hashref with one of two possible elements, either a patron retrieved
from the database:

    my $result = NLSync({ 'patron' => $borrower_from_dbic });

or a plain old borrowernumber:

    my $result = NLSync({ 'borrowernumber' => $borrowernumber });

In the latter case, this function will retrieve the patron record from the
database using DBIC.

Which part of the API is called depends on the value of the "syncstatus" column:

=over 4

=item * B<new> = The I<nyPost> ("new record") method is called.

=item * B<edited> = The I<endre> ("change/update") method is called.

=item * B<delete> = The I<slett> ("delete") method is called.

=back

Required values for B<new> and B<edited>:

=over 4

=item * sist_endret (last updated)

=item * adresse, postnr eller sted (address, zip or city)

=item * fdato (birthdate)

=item * fnr_hash (social security number, but not hashed...)

=item * kjonn (gender, M/F)

=back

=cut

sub NLSync {

    my ( $input ) = @_;

    my $patron;
    if ( defined $input->{'borrowernumber'} ) {
        $patron = Koha::Database->new->schema->resultset('Borrower')->find( $input->{'borrowernumber'} );
    } elsif ( defined $input->{'patron'} ) {
        $patron = $input->{'patron'};
    }

    # There should only be one sync, so we use the first one
    my @syncs = $patron->borrower_syncs;
    my $sync;
    foreach my $this_sync ( @syncs ) {
        if ( $this_sync->synctype eq 'norwegianpatrondb' ) {
            $sync = $this_sync;
        }
    }

    my $client = SOAP::Lite
        ->on_action( sub { return '""';})
        ->uri( $nl_uri )
        ->proxy( C4::Context->preference("NorwegianPatronDBEndpoint") );

    my $cardnumber = SOAP::Data->name( 'lnr' => $patron->cardnumber );

    # Call the appropriate method based on syncstatus
    my $response;
    if ( $sync->syncstatus eq 'edited' || $sync->syncstatus eq 'new' ) {
        my $soap_patron = _koha_patron_to_soap( $patron );
        if ( $sync->syncstatus eq 'edited' ) {
            $response = $client->endre( $cardnumber, $soap_patron );
        } elsif ( $sync->syncstatus eq 'new' ) {
            $response = $client->nyPost( $soap_patron );
        }
    }
    if ( $sync->syncstatus eq 'delete' ) {
        $response = $client->slett( $cardnumber );
    }

    # Update the sync data according to the results
    if ( $response->{'status'} && $response->{'status'} == 1 ) {
        if ( $sync->syncstatus eq 'delete' ) {
            # Turn off any further syncing
            $sync->update( { 'sync' => 0 } );
        }
        # Update the syncstatus to 'synced'
        $sync->update( { 'syncstatus' => 'synced' } );
        # Update the 'synclast' attribute with the "server time" ("server_tid") returned by the method
        $sync->update( { 'lastsync' => $response->{'server_tid'} } );
    }
    return $response;

}

=head2 NLGetChanged

Fetches patrons from NL that have been changed since a given timestamp. This includes
patrons that have been changed by the library that runs the sync, so we have to
check which library was the last one to change a patron, before we update patrons
locally.

This is supposed to be executed once per night.

SOAP call: soekEndret

=cut

sub NLGetChanged {

    my ( $from_arg ) = @_;

    my $client = SOAP::Lite
        ->on_action( sub { return '""';})
        ->uri( $nl_uri )
        ->proxy( C4::Context->preference("NorwegianPatronDBEndpoint") );

    my $from_string;
    if ( $from_arg && $from_arg ne '' ) {
        $from_string = $from_arg;
    } else {
        # Calculate 1 second past midnight of the day before
        my $dt = DateTime->now( time_zone => 'Europe/Oslo' );
        $dt->subtract( days => 1 );
        my $from = DateTime->new(
            year       => $dt->year(),
            month      => $dt->month(),
            day        => $dt->day(),
            hour       => 0,
            minute     => 0,
            second     => 1,
            time_zone  => 'Europe/Oslo',
        );
        $from_string = $from->ymd . "T" . $from->hms;
    }

    my $timestamp   = SOAP::Data->name( 'tidspunkt'    => $from_string );
    my $max_results = SOAP::Data->name( 'max_antall'   => 0 ); # 0 = no limit
    my $start_index = SOAP::Data->name( 'start_indeks' => 0 ); # 1 is the first record

    # Call the appropriate method based on syncstatus
    my $som = $client->soekEndret( $timestamp, $max_results, $start_index );

    # Extract and massage patron data
    my $result = $som->result;
    foreach my $patron ( @{ $result->{'respons_poster'} } ) {
        # Only handle patrons that have lnr (barcode) and fnr_hash (social security number)
        # Patrons that lack these two have been deleted from NL
        if ( $patron->{'lnr'} && $patron->{'fnr_hash'} ) {
            push @{ $result->{'kohapatrons'} }, _soap_to_kohapatron( $patron );
        }
    }
    return $result;

}

=head2 NLMarkForDeletion

Mark a borrower for deletion, but do not do the actual deletion. Deleting the
borrower from NL will be done later by the nl-sync-from-koha.pl script.

=cut

sub NLMarkForDeletion {

    my ( $borrowernumber ) = @_;

    my $borrowersync = Koha::Database->new->schema->resultset('BorrowerSync')->find({
        'synctype'       => 'norwegianpatrondb',
        'borrowernumber' => $borrowernumber,
    });
    return $borrowersync->update( { 'syncstatus' => 'delete' } );

}

=head2 NLDecodePin

Takes a string encoded with AES/ECB/PKCS5PADDING and a 128-bits key, and returns
the decoded string as plain text.

The key needs to be stored in koha-conf.xml, like so:

<yazgfs>
  ...
  <config>
    ...
    <nlkey>xyz</nlkey>
  </config>
</yazgfs>

=cut

sub NLDecodePin {

    my ( $hash ) = @_;
    my $key = C4::Context->config( 'nlkey' );

    # Convert the hash from Base16
    my $cb = Convert::BaseN->new( base => 16 );
    my $decoded_hash = $cb->decode( $hash );

    # Do the decryption
    my $cipher = Crypt::GCrypt->new(
        type      => 'cipher',
        algorithm => 'aes',
        mode      => 'ecb',
        padding   => 'standard', # "This is also known as PKCS#5"
    );
    $cipher->start( 'decrypting' );
    $cipher->setkey( $key ); # Must be called after start()
    my $plaintext  = $cipher->decrypt( $decoded_hash );
    $plaintext .= $cipher->finish;

    return $plaintext;

}

=head2 NLEncryptPIN

Takes a plain text PIN as argument, returns the encrypted PIN, according to the
NL specs.

    my $encrypted_pin = NLEncryptPIN( $plain_text_pin );

=cut

sub NLEncryptPIN {

    my ( $pin ) = @_;
    return _encrypt_pin( $pin );

}

=head2 NLUpdateHashedPIN

Takes two arguments:

=over 4

=item * Borrowernumber

=item * Clear text PIN code

=back

Hashes the password and saves it in borrower_sync.hashed_pin.

=cut

sub NLUpdateHashedPIN {

    my ( $borrowernumber, $pin ) = @_;
    my $borrowersync = Koha::Database->new->schema->resultset('BorrowerSync')->find({
        'synctype'       => 'norwegianpatrondb',
        'borrowernumber' => $borrowernumber,
        });
    return $borrowersync->update({ 'hashed_pin', _encrypt_pin( $pin ) });

}

=head2 _encrypt_pin

Takes a plain text PIN and returns the encrypted version, according to the NL specs.

=cut

sub _encrypt_pin {

    my ( $pin ) = @_;
    my $key = C4::Context->config( 'nlkey' );

    # Do the encryption
    my $cipher = Crypt::GCrypt->new(
        type      => 'cipher',
        algorithm => 'aes',
        mode      => 'ecb',
        padding   => 'standard', # "This is also known as PKCS#5"
    );
    $cipher->start( 'encrypting' );
    $cipher->setkey( $key ); # Must be called after start()
    my $ciphertext  = $cipher->encrypt( $pin );
    $ciphertext .= $cipher->finish;

    # Encode as Bas16
    my $cb = Convert::BaseN->new( base => 16 );
    my $encoded_ciphertext = $cb->encode( $ciphertext );

    return $encoded_ciphertext;

}

=head2 NLGetSyncDataFromBorrowernumber

Takes a borrowernumber as argument, returns a Koha::Schema::Result::BorrowerSync
object.

    my $syncdata = NLGetSyncDataFromBorrowernumber( $borrowernumber );

=cut

sub NLGetSyncDataFromBorrowernumber {

    my ( $borrowernumber ) = @_;
    my $data = Koha::Database->new->schema->resultset('BorrowerSync')->find({
        'synctype'       => 'norwegianpatrondb',
        'borrowernumber' => $borrowernumber,
    });
    return $data;

}

=head2 NLGetFirstname

Takes a string like "Surname, Firstname" and returns the "Firstname" part.

If there is no comma, the string is returned unaltered.

    my $firstname = NLGetFirstname( $name );

=cut

sub NLGetFirstname {

    my ( $s ) = @_;
    my ( $surname, $firstname ) = _split_name( $s );
    if ( $surname eq $s ) {
        return $s;
    } else {
        return $firstname;
    }

}

=head2 NLGetSurname

Takes a string like "Surname, Firstname" and returns the "Surname" part.

If there is no comma, the string is returned unaltered.

    my $surname = NLGetSurname( $name );

=cut

sub NLGetSurname {

    my ( $s ) = @_;
    my ( $surname, $firstname ) = _split_name( $s );
    return $surname;

}

=head2 _split_name

Takes a string like "Surname, Firstname" and returns a list of surname and firstname.

If there is no comma, the string is returned unaltered.

    my ( $surname, $firstname ) = _split_name( $name );

=cut

sub _split_name {

    my ( $s ) = @_;

    # Return the string if there is no comma
    unless ( $s =~ m/,/ ) {
        return $s;
    }

    my ( $surname, $firstname ) = split /, /, $s;

    return ( $surname, $firstname );

}

=head2 _format_soap_error

Takes a soap result object as input and returns a formatted string containing SOAP error data.

=cut

sub _format_soap_error {

    my ( $result ) = @_;
    if ( $result ) {
        return join ', ', $result->faultcode, $result->faultstring, $result->faultdetail;
    } else {
        return 'No result';
    }

}

=head2 _soap_to_koha_patron

Convert a SOAP object of type "Laaner" into a hash that can be sent to Koha::Patron

=cut

sub _soap_to_kohapatron {

    my ( $soap ) = @_;

    return {
        'cardnumber'      => $soap->{ 'lnr' },
        'surname'         => NLGetSurname(   $soap->{ 'navn' } ),
        'firstname'       => NLGetFirstname( $soap->{ 'navn' } ),
        'sex'             => $soap->{ 'kjonn' },
        'dateofbirth'     => $soap->{ 'fdato' },
        'address'         => $soap->{ 'p_adresse1' },
        'address2'        => $soap->{ 'p_adresse2' },
        'zipcode'         => $soap->{ 'p_postnr' },
        'city'            => $soap->{ 'p_sted' },
        'country'         => $soap->{ 'p_land' },
        'b_address'       => $soap->{ 'm_adresse1' },
        'b_address2'      => $soap->{ 'm_adresse2' },
        'b_zipcode'       => $soap->{ 'm_postnr' },
        'b_city'          => $soap->{ 'm_sted' },
        'b_country'       => $soap->{ 'm_land' },
        'password'        => $soap->{ 'pin' },
        'dateexpiry'      => $soap->{ 'gyldig_til' },
        'email'           => $soap->{ 'epost' },
        'mobile'          => $soap->{ 'tlf_mobil' },
        'phone'           => $soap->{ 'tlf_hjemme' },
        'phonepro'        => $soap->{ 'tlf_jobb' },
        '_extra'          => { # Data that should not go in the borrowers table
            'socsec'         => $soap->{ 'fnr_hash' },
            'created'        => $soap->{ 'opprettet' },
            'created_by'     => $soap->{ 'opprettet_av' },
            'last_change'    => $soap->{ 'sist_endret' },
            'last_change_by' => $soap->{ 'sist_endret_av' },
        },
    };

}

=head2 _koha_patron_to_soap

Convert a patron (in the form of a Koha::Schema::Result::Borrower) into a SOAP
object that can be sent to NL.

=cut

sub _koha_patron_to_soap {

    my ( $patron ) = @_;

    # Extract attributes
    my $patron_attributes = {};
    foreach my $attribute ( $patron->borrower_attributes ) {
        $patron_attributes->{ $attribute->code->code } = $attribute->attribute;
    }

    # There should only be one sync, so we use the first one
    my @syncs = $patron->borrower_syncs;
    my $sync = $syncs[0];

    # Create SOAP::Data object
    my $soap_patron = SOAP::Data->name(
        'post' => \SOAP::Data->value(
            SOAP::Data->name( 'lnr'         => $patron->cardnumber ),
            SOAP::Data->name( 'fnr_hash'    => $patron_attributes->{ 'fnr' } )->type( 'string' )->type( 'string' ),
            SOAP::Data->name( 'navn'        => $patron->surname . ', ' . $patron->firstname    )->type( 'string' ),
            SOAP::Data->name( 'sist_endret' => $sync->lastsync      )->type( 'string' ),
            SOAP::Data->name( 'kjonn'       => $patron->sex         )->type( 'string' ),
            SOAP::Data->name( 'fdato'       => $patron->dateofbirth )->type( 'string' ),
            SOAP::Data->name( 'p_adresse1'  => $patron->address     )->type( 'string' ),
            SOAP::Data->name( 'p_adresse2'  => $patron->address2    )->type( 'string' ),
            SOAP::Data->name( 'p_postnr'    => $patron->zipcode     )->type( 'string' ),
            SOAP::Data->name( 'p_sted'      => $patron->city        )->type( 'string' ),
            SOAP::Data->name( 'p_land'      => $patron->country     )->type( 'string' ),
            SOAP::Data->name( 'm_adresse1'  => $patron->b_address   )->type( 'string' ),
            SOAP::Data->name( 'm_adresse2'  => $patron->b_address2  )->type( 'string' ),
            SOAP::Data->name( 'm_postnr'    => $patron->b_zipcode   )->type( 'string' ),
            SOAP::Data->name( 'm_sted'      => $patron->b_city      )->type( 'string' ),
            SOAP::Data->name( 'm_land'      => $patron->b_country   )->type( 'string' ),
            # Do not send the PIN code as it has been hashed by Koha, but use the version hashed according to NL
            SOAP::Data->name( 'pin'         => $sync->hashed_pin    )->type( 'string' ),
            SOAP::Data->name( 'gyldig_til'  => $patron->dateexpiry  )->type( 'string' ),
            SOAP::Data->name( 'epost'       => $patron->email       )->type( 'string' ),
            SOAP::Data->name( 'tlf_mobil'   => $patron->mobile      )->type( 'string' ),
            SOAP::Data->name( 'tlf_hjemme'  => $patron->phone       )->type( 'string' ),
            SOAP::Data->name( 'tlf_jobb'    => $patron->phonepro    )->type( 'string' ),
        ),
    )->type("Laaner");

    return $soap_patron;

}

=head1 EXPORT

None by default.

=head1 AUTHOR

Magnus Enger <digitalutvikling@gmail.com>

=cut

1;

__END__
