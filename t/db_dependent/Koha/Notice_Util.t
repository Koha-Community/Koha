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
use Test::More tests => 2;
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
    plan tests => 12;

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

    # Check counting
    my @values = ( message_transport_type => 'email', status => 'sent' );
    my $today = dt_from_string();
    $builder->build_object({ class => 'Koha::Notice::Messages',
        value => { @values, to_address => 'a@A', updated_on => $today->clone->subtract( hours => 36 ) }});
    $builder->build_object({ class => 'Koha::Notice::Messages',
        value => { @values, to_address => 'b@A', updated_on => $today->clone->subtract( hours => 49 ) }});
    $builder->build_object({ class => 'Koha::Notice::Messages',
        value => { @values, to_address => 'c@A', updated_on => $today->clone->subtract( days => 3 ) }});
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    is( $domain_limits->{a}->{count}, 1, 'Three messages to A, 1 within unit of 2d' );
    t::lib::Mocks::mock_config( 'message_domain_limits',
        { domain => [ { name => 'A', limit => 2, unit => '50h' }, { name => 'B', limit => 3, unit => '3h' } ] },
    );
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    is( $domain_limits->{a}->{count}, 2, 'Three messages to A, 2 within unit of 50h' );

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

subtest 'exceeds_limit' => sub {
    plan tests => 6;

    my $domain_limits;

    t::lib::Mocks::mock_config( 'message_domain_limits', undef );
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    is( Koha::Notice::Util->exceeds_limit( 'marcel@koha.nl', $domain_limits ), 0, 'False when having no limits' );

    t::lib::Mocks::mock_config( 'message_domain_limits',
        { domain => [ { name => 'A', limit => 0, unit => '1d' }, { name => 'B', limit => 1, unit => '5h' } ] },
    );
    $domain_limits = Koha::Notice::Util->load_domain_limits;
    is( Koha::Notice::Util->exceeds_limit( '1@A', $domain_limits ), 1, 'Limit for A already reached' );
    my $result;
    warning_like { $result = Koha::Notice::Util->exceeds_limit( '2@B', $domain_limits ) }
        qr/Sending messages: domain b reached limit/, 'Check warn for reaching limit';
    is( $result, 0, 'Limit for B not yet exceeded' );
    is( Koha::Notice::Util->exceeds_limit( '3@B', $domain_limits ), 1, 'Limit for B already reached' );
    is( Koha::Notice::Util->exceeds_limit( '4@C', $domain_limits ), 0, 'No limits for C' );
};

$schema->storage->txn_rollback;
