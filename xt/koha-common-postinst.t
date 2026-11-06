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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use File::Temp qw(tempdir);
use File::Spec;
use JSON::PP qw(encode_json decode_json);
use Test::More;
use Test::NoWarnings;

my $postinst = File::Spec->rel2abs('debian/koha-common.postinst');
my @cases    = (
    { name => 'fresh installation without instances', instances => {} },
    { name => 'polling instance',      instances => { a => { method => 'polling' } } },
    { name => 'missing preference',    instances => { a => {} } },
    { name => 'empty preference',      instances => { a => { method => '' } } },
    { name => 'local STOMP instance',  instances => { a => { method => 'STOMP', host => 'localhost' } }, broker => 1 },
    { name => 'remote STOMP instance', instances => { a => { method => 'STOMP', host => 'mq.example.invalid' } } },
    { name => 'STOMP without broker hostname', instances => { a => { method => 'STOMP' } }, broker => 1 },
    { name => 'IPv4 loopback STOMP',  instances => { a => { method => 'STOMP', host => '127.0.0.1' } }, broker => 1 },
    { name => 'IPv6 loopback STOMP',  instances => { a => { method => 'STOMP', host => '::1' } },       broker => 1 },
    { name => 'local hostname STOMP', instances => { a => { method => 'STOMP', host => 'test-host' } }, broker => 1 },
    {
        name   => 'local FQDN STOMP', instances => { a => { method => 'STOMP', host => 'test-host.example.invalid' } },
        broker => 1
    },
    {
        name      => 'mixed instances restart once',
        instances => {
            a => { method => 'polling' }, b => { method => 'STOMP', host => 'localhost' },
            c => { method => 'STOMP', host => 'localhost' }
        },
        broker => 1
    },
    { name => 'database unavailable',     instances => { a => { error  => 1 } },       warning => 1 },
    { name => 'broker package absent',    instances => { a => { method => 'STOMP' } }, absent  => 1 },
    { name => 'non-configure invocation', instances => { a => { method => 'STOMP' } }, action  => 'abort-upgrade' },
);
plan tests => scalar(@cases) + 1;

for my $case (@cases) {
    subtest $case->{name} => sub {

        # KTD can mount /tmp with noexec, so keep executable stubs in the checkout.
        my $dir = tempdir( DIR => File::Spec->rel2abs('.'), CLEANUP => 1 );
        mkdir "$dir/bin" or die $!;
        for my $command (qw(koha-list koha-mysql xmlstarlet hostname service rabbitmq-plugins)) {
            next if $command eq 'rabbitmq-plugins' && $case->{absent};
            open my $stub, '>', "$dir/bin/$command" or die $!;
            print {$stub} "#!$^X\n";
            print {$stub} <<'STUB';
use strict;
use warnings;
use File::Basename qw(basename);
use JSON::PP qw(encode_json decode_json);
my $case = decode_json($ENV{KOHA_POSTINST_CASE});
my $name = basename($0);
open my $log, '>>', $ENV{KOHA_POSTINST_CALLS} or die $!;
print {$log} encode_json([$name,@ARGV])."\n";
close $log;
if ($name eq 'koha-list') {
    print join("\n",sort keys %{$case->{instances}}),"\n";
} elsif ($name eq 'koha-mysql') {
    my $instance = $case->{instances}{$ARGV[0]} or exit 1;
    exit 1 if $instance->{error};
    print $instance->{method},"\n" if defined $instance->{method};
} elsif ($name eq 'xmlstarlet') {
    my ($instance) = $ARGV[-1] =~ m{/sites/([^/]+)/koha-conf.xml$};
    my $host = $case->{instances}{$instance}{host};
    exit 1 unless defined $host;
    print $host;
} elsif ($name eq 'hostname') {
    print @ARGV ? 'test-host.example.invalid' : 'test-host';
}
STUB
            close $stub;
            chmod 0755, "$dir/bin/$command" or die $!;
        }
        local $ENV{PATH}                = "$dir/bin";
        local $ENV{KOHA_POSTINST_CASE}  = encode_json($case);
        local $ENV{KOHA_POSTINST_CALLS} = "$dir/calls";
        my $pid = fork();
        die 'fork failed' unless defined $pid;
        unless ($pid) {
            open STDOUT, '>', "$dir/output" or die $!;
            open STDERR, '>', "$dir/errors" or die $!;
            exec '/bin/sh', $postinst, $case->{action} // 'configure', '25.11.00';
            die 'exec failed';
        }
        waitpid $pid, 0;
        my $status = $? >> 8;
        is( $status, 0, 'Package configuration succeeds' );
        if ($status) {
            open my $error, '<', "$dir/errors" or die $!;
            diag( do { local $/; <$error> } );
            close $error;
        }
        my @calls;
        if ( open my $log, '<', "$dir/calls" ) {
            @calls = map { decode_json($_) } <$log>;
            close $log;
        }
        my @broker =
            grep { $_->[0] eq 'rabbitmq-plugins' || ( $_->[0] eq 'service' && $_->[1] eq 'rabbitmq-server' ) } @calls;
        is_deeply(
            \@broker,
            $case->{broker}
            ? [
                [qw(rabbitmq-plugins enable --offline rabbitmq_stomp)],
                [qw(service rabbitmq-server restart)],
                ]
            : [],
            'Only a local STOMP instance configures and restarts RabbitMQ, once'
        );
        my @memcached = grep { $_->[0] eq 'service' && $_->[1] eq 'memcached' } @calls;
        is( scalar @memcached, $case->{action} ? 0 : 1, 'Memcached restart is preserved for configure' );
        if ( $case->{warning} ) {
            open my $error, '<', "$dir/errors" or die $!;
            like( do { local $/; <$error> }, qr/Cannot read JobsNotificationMethod/, 'Unavailable DB is reported' );
            close $error;
        }
        done_testing;
    };
}
