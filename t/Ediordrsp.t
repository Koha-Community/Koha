#!/usr/bin/perl
use strict;
use warnings;
use FindBin qw( $Bin );

use Test::More tests => 16;

BEGIN { use_ok('Koha::Edifact') }

my $filedir = "$Bin/edi_testfiles";

my @files = map { "$filedir/$_" }
  ( 'ordrsp1.CEA', 'ordrsp2.CEA', 'ordrsp3.CEA', 'ordrsp4.CEA' );

my @responses;
for my $filename (@files) {

    my $order_response = Koha::Edifact->new( { filename => $filename, } );

    isa_ok( $order_response, 'Koha::Edifact' );
    push @responses, $order_response;
}

# tests on file 1
# Order accepted with amendments
my $order_response = $responses[0];

my $msg       = $order_response->message_array();
my $no_of_msg = @{$msg};
is( $no_of_msg, 1, "Correct number of messages returned" );

isa_ok( $msg->[0], 'Koha::Edifact::Message' );

my $lines = $msg->[0]->lineitems();

my $no_of_lines = @{$lines};

is( $no_of_lines, 3, "Correct number of orderlines returned" );

#
is( $lines->[0]->ordernumber(), 'P28837', 'Line 1 correct ordernumber' );
is(
    $lines->[0]->coded_orderline_text(),
    'Not yet published',
    'NP returned and translated'
);

is( $lines->[1]->ordernumber(), 'P28838', 'Line 2 correct ordernumber' );
is( $lines->[1]->action_notification(),
    'cancelled', 'Cancelled action returned' );
is( $lines->[1]->coded_orderline_text(),
    'Out of print', 'OP returned and translated' );

is( $lines->[2]->ordernumber(), 'P28846', 'Line 3 correct ordernumber' );
is( $lines->[2]->action_notification(),
    'recorded', 'Accepted with change action returned' );

is( $lines->[0]->availability_date(), '19971120',
    'Availability date returned' );
