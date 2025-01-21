#!/usr/bin/perl

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

use Test::More tests => 3;
use Test::MockModule;
use Test::NoWarnings;
use Test::Warn;

use CGI qw ( -utf8 );

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    use_ok(
        'C4::Output',
        qw( redirect_if_opac_suppressed )
    );
}

my $builder = t::lib::TestBuilder->new();
my $schema  = Koha::Database->new()->schema();

subtest 'redirect_if_opac_suppressed() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    local *STDOUT;
    my $stdout;

    # variable controlling opac suppression status
    my $opac_suppressed;

    my $auth_mock = Test::MockModule->new('C4::Auth');
    $auth_mock->mock( 'safe_exit', sub { warn "safe_exit_called" } );

    my $biblio_mock = Test::MockModule->new('Koha::Biblio');
    $biblio_mock->mock( 'opac_suppressed', sub { return $opac_suppressed; } );

    my $biblio = $builder->build_sample_biblio();

    my $query = CGI->new();

    subtest 'not suppressed tests' => sub {

        plan tests => 2;

        open STDOUT, '>', \$stdout;
        $opac_suppressed = 0;

        my $warnings;
        local $SIG{__WARN__} = sub { $warnings = shift };
        redirect_if_opac_suppressed( $query, $biblio );

        is( $stdout, undef, 'No redirection if the biblio is not suppressed' );
        ok( !$warnings, "safe_exit not called" );

        close STDOUT;
    };

    subtest 'suppressed tests' => sub {

        plan tests => 11;

        $opac_suppressed = 1;

        {
            open STDOUT, '>', \$stdout;
            t::lib::Mocks::mock_preference( 'OpacSuppressionByIPRange', undef );
            t::lib::Mocks::mock_preference( 'OpacSuppressionRedirect',  1 );

            warning_is {
                redirect_if_opac_suppressed( $query, $biblio );
            }
            q{safe_exit_called},
                'Safe exit called on redirection';

            like( $stdout, qr{Status: 302 Found} );
            like( $stdout, qr{Location: /cgi-bin/koha/opac-blocked.pl} );

            undef $stdout;

            close STDOUT;
        }

        {
            open STDOUT, '>', \$stdout;
            t::lib::Mocks::mock_preference( 'OpacSuppressionByIPRange', undef );
            t::lib::Mocks::mock_preference( 'OpacSuppressionRedirect',  0 );

            warning_is {
                redirect_if_opac_suppressed( $query, $biblio );
            }
            q{safe_exit_called},
                'Safe exit called on redirection';

            like( $stdout, qr{Status: 302 Found} );
            like( $stdout, qr{Location: /cgi-bin/koha/errors/404.pl} );

            undef $stdout;

            close STDOUT;
        }

        # now IP ranges
        {
            open STDOUT, '>', \$stdout;

            t::lib::Mocks::mock_preference( 'OpacSuppressionByIPRange', '192.168' );
            t::lib::Mocks::mock_preference( 'OpacSuppressionRedirect',  0 );

            $ENV{REMOTE_ADDR} = '200.16.23.1';

            warning_is {
                redirect_if_opac_suppressed( $query, $biblio );
            }
            q{safe_exit_called},
                'Safe exit called on redirection';

            like( $stdout, qr{Status: 302 Found} );
            like( $stdout, qr{Location: /cgi-bin/koha/errors/404.pl} );

            undef $stdout;

            close STDOUT;
        }

        {
            open STDOUT, '>', \$stdout;

            t::lib::Mocks::mock_preference( 'OpacSuppressionByIPRange', '192.168' );
            t::lib::Mocks::mock_preference( 'OpacSuppressionRedirect',  0 );

            $ENV{REMOTE_ADDR} = '192.168.0.115';

            my $warnings;
            local $SIG{__WARN__} = sub { $warnings = shift };
            redirect_if_opac_suppressed( $query, $biblio );

            is( $stdout, undef, 'No redirection if the IP is on the range' );
            ok( !$warnings, "safe_exit not called" );

            undef $stdout;

            close STDOUT;
        }
    };

    $schema->storage->txn_rollback;
};
