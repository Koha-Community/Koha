use Modern::Perl;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Test::More tests => 3;                      # last test to print
use C4::Auth;
use Koha::Database;

use Module::Load::Conditional qw( can_load );
SKIP: {
    skip "cannot filnd WebService::ILS::RecordedBooks::PartnerPatron", 3
      unless can_load( modules => {'WebService::ILS::RecordedBooks::PartnerPatron' => undef} );

    use_ok('Koha::ExternalContent::RecordedBooks');

    my $ocd_user_email = $ENV{RECORDEDBOOKS_TEST_USER_EMAIL};
    SKIP: {
        skip "Env RECORDEDBOOKS_TEST_USER_EMAIL not set", 2 unless $ocd_user_email;

        my $ocd_secret = $ENV{RECORDEDBOOKS_TEST_CLIENT_SECRET}
          || C4::Context->preference('RecordedBooksClientSecret');
        my $ocd_library_id = $ENV{RECORDEDBOOKS_TEST_LIBRARY_ID}
          || C4::Context->preference('RecordedBooksLibraryID');
        my $ocd_domain = $ENV{RECORDEDBOOKS_TEST_DOMAIN}
          || C4::Context->preference('RecordedBooksDomain');
        skip "Env RECORDEDBOOKS_TEST_CLIENT_SECRET RECORDEDBOOKS_TEST_LIBRARY_ID RECORDEDBOOKS_TEST_DOMAIN not set", 2
          unless $ocd_secret && $ocd_library_id && $ocd_domain;

        my $schema = Koha::Database->schema;
        $schema->storage->txn_begin;
        my $builder = t::lib::TestBuilder->new();

        t::lib::Mocks::mock_preference('RecordedBooksClientSecret', $ocd_secret);
        t::lib::Mocks::mock_preference('RecordedBooksLibraryID', $ocd_library_id);
        t::lib::Mocks::mock_preference('RecordedBooksDomain', $ocd_domain);

        my $patron = $builder->build({
            source => 'Borrower',
            value => {
                email => $ocd_user_email,
            }
        });

        my $session = C4::Auth::get_session("");
        $session->param('number', $patron->{borrowernumber});
        $session->flush;
        my $client = Koha::ExternalContent::RecordedBooks->new({koha_session_id => $session->id});

        my $user_agent_string = $client->user_agent->agent();
        ok ($user_agent_string =~ m/^Koha/, 'User Agent string is set')
          or diag("User Agent string: $user_agent_string");

        ok ($client->search({query => "school"}), 'search()');
    }
}
