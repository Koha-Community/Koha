#!/usr/bin/perl

# Copyright 2023 Koha Development team
#
# This file is part of Koha
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
#use Data::Dumper qw/Dumper/;
use Test::More tests => 4;
use Test::MockModule;
use Test::Warn;

use C4::Context;
use Koha::Database;
use Koha::DateUtils qw/dt_from_string/;
use Koha::Notice::Util;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'load_domain_limits' => sub {
    plan tests => 8;

    my $domain_limits;
    t::lib::Mocks::mock_config( 'message_domain_limits', undef );
    is( Koha::Notice::Util->load_domain_limits, undef, 'koha-conf does not contain entry' );
    t::lib::Mocks::mock_config( 'message_domain_limits', q{} );
    is( Koha::Notice::Util->load_domain_limits, undef, 'koha-conf contains blank entry' );
    t::lib::Mocks::mock_config( 'message_domain_limits', { domain => { name => 'A', limit => 2, unit => '1d' } } );
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    is( keys %$domain_limits, 1, 'koha-conf contains one domain' );
    is( $domain_limits->{a}->{limit}, 2, 'check limit of first entry' );
    is( $domain_limits->{a}->{unit}, '1d', 'check unit of first entry' );
    t::lib::Mocks::mock_config( 'message_domain_limits',
        { domain => [ { name => 'A', limit => 2, unit => '2d' }, { name => 'B', limit => 3, unit => '3h' } ] },
    );
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    is( keys %$domain_limits, 2, 'koha-conf contains two domains' );
    is( $domain_limits->{b}->{limit}, 3, 'check limit of second entry' );
    is( $domain_limits->{b}->{count}, undef, 'check if count still undefined' );
};

subtest 'counting in exceeds_limit' => sub {
    plan tests => 3;

    my $domain_limits;
    # Check counting
    my @values = ( message_transport_type => 'email', status => 'sent' );
    my $today = dt_from_string();
    #FIXME Why are the three following build calls so slow?
    $builder->build_object({ class => 'Koha::Notice::Messages',
        value => { @values, to_address => 'a@A', updated_on => $today->clone->subtract( hours => 36 ) }});
    $builder->build_object({ class => 'Koha::Notice::Messages',
        value => { @values, to_address => 'b@A', updated_on => $today->clone->subtract( hours => 49 ) }});
    $builder->build_object({ class => 'Koha::Notice::Messages',
        value => { @values, to_address => 'c@A', updated_on => $today->clone->subtract( days => 3 ) }});

    $domain_limits = Koha::Notice::Util->load_domain_limits; # still using last mocked config A:2/2d
    Koha::Notice::Util->exceeds_limit({ to => '@A', limits => $domain_limits, incr => 0 }); # force counting
    is( $domain_limits->{a}->{count}, 1, '1 message to A within unit of 2d' );
    t::lib::Mocks::mock_config( 'message_domain_limits',
        { domain => [ { name => 'A', limit => 2, unit => '50h' }, { name => 'B', limit => 3, unit => '3h' } ] },
    );
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    Koha::Notice::Util->exceeds_limit({ to => 'x@A ', limits => $domain_limits, incr => 0 }); # force counting
    is( $domain_limits->{a}->{count}, 2, '2 messages to A within unit of 50h' );
    # Check count for B; if counted, there would be 0 or higher, otherwise undef
    ok( !defined $domain_limits->{b}->{count}, 'Prove that we did not count b if not asked for' );
};

subtest '_convert_unit' => sub {
    plan tests => 3;

    # Date subtraction - edge case (start of summer time)
    my $mock_context = Test::MockModule->new('C4::Context');
    $mock_context->mock( 'tz', sub { return DateTime::TimeZone->new( name => 'Europe/Amsterdam' )} );
    my $dt = dt_from_string( '2023-03-31 02:30:00', 'iso', '+02:00' );
    is( Koha::Notice::Util::_convert_unit( $dt, '4d')->stringify, '2023-03-27T02:30:00', '02:30 is fine' );
    is( Koha::Notice::Util::_convert_unit( $dt, '1d')->stringify, '2023-03-26T01:30:00', 'Moved 02:30 to 01:30' );
    # Test bad unit
    is( Koha::Notice::Util::_convert_unit( $dt, 'y')->stringify, '2023-03-26T01:30:00', 'No further shift for bad unit' );
    $mock_context->unmock('tz');
};

subtest 'exceeds_limit with group domains' => sub {
    plan tests => 12;

    my $domain_limits;
    t::lib::Mocks::mock_config( 'message_domain_limits', undef );
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    is( Koha::Notice::Util->exceeds_limit({ to => 'marcel@koha.nl', limits => $domain_limits }), 0, 'False when having no limits' );

    t::lib::Mocks::mock_config( 'message_domain_limits', { domain => [
        { name => 'A', limit => 3, unit => '5m' },
        { name => 'B', limit => 2, unit => '5m' },
        { name => 'C', belongs_to => 'A' },
    ]});
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    my $result;
    is( Koha::Notice::Util->exceeds_limit({ to => '1@A', limits => $domain_limits }), 0, 'First message to A' );
    is( Koha::Notice::Util->exceeds_limit({ to => '2@C', limits => $domain_limits }), 0, 'Second message to A (via C)' );
    ok( !exists $domain_limits->{c}->{count}, 'No count exists for grouped domain' );
    warning_like { $result = Koha::Notice::Util->exceeds_limit({ to => '3@A', limits => $domain_limits }) }
        qr/Sending messages: domain a reached limit/, 'Check warn for reaching limit A';
    is( $result, 0, 'Limit for A reached, not exceeded' );
    is( Koha::Notice::Util->exceeds_limit({ to => '4@C', limits => $domain_limits }), 1, 'Limit for A exceeded (via C)' );
    is( Koha::Notice::Util->exceeds_limit({ to => '5@B', limits => $domain_limits }), 0, 'First message to B' );
    is( $domain_limits->{b}->{count}, 1, 'Count B updated' );
    is( Koha::Notice::Util->exceeds_limit({ to => '5@B', limits => $domain_limits, incr => 0 }), 0, 'Test incr flag' );
    is( $domain_limits->{b}->{count}, 1, 'Count B still 1' );
    is( Koha::Notice::Util->exceeds_limit({ to => '6@D', limits => $domain_limits }), 0, 'No limits for D' );
};

$schema->storage->txn_rollback;
