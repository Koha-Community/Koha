#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 1;

use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Reserves;
use Koha::Database;
use Koha::DateUtils;
use Koha::Holds;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

subtest 'AutoUnsuspendReserves test' => sub {
    plan tests => 2;

    my $builder = t::lib::TestBuilder->new();

    my $today = dt_from_string();
    my $today_date = output_pref({ dateformat => 'sql' });
    my $tomorrow_date = output_pref({ dt => $today->add(days=>1), dateformat=>'sql' });

    # Reserve not expired
    my $reserve1 = $builder->build({
        source => 'Reserve',
        value => {
            expirationdate => undef,
            cancellationdate => undef,
            priority => 5,
            found => undef,
            suspend_until => $today_date,
        },
    });
    # Reserve expired
    my $reserve2 = $builder->build({
        source => 'Reserve',
        value => {
            expirationdate => undef,
            cancellationdate => undef,
            priority => 6,
            found => undef,
            suspend_until => $tomorrow_date,
        },
    });

    AutoUnsuspendReserves();
    my $r1 = Koha::Holds->find($reserve1->{reserve_id});
    my $r2 = Koha::Holds->find($reserve2->{reserve_id});
    ok(!defined($r1->suspend_until), 'Reserve suspended until today should be unsuspended.');
    ok(defined($r2->suspend_until), 'Reserve suspended after today should be suspended.');

};

$schema->storage->txn_rollback;
