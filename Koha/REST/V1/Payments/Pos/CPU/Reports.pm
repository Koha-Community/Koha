package Koha::REST::V1::Payments::Pos::CPU::Reports;

use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';

use Koha::Logger;
use Koha::Payment::POS;
use Koha::PaymentsTransaction;
use Koha::PaymentsTransactions;

use Data::Dumper;

use Try::Tiny;

=head2 cpu_pos_report

Receives the success report from CPU.

=cut

sub cpu_pos_report {
    my $c = shift->openapi->valid_input or return;

    my $transaction;

    return try {
        my $invoicenumber = $c->validation->param('invoicenumber');
        $transaction = Koha::PaymentsTransactions->find($invoicenumber);
        my $params = $c->req->json;

        C4::Context->setCommandlineEnvironment();
        C4::Context->interface('rest');

        my $logger = Koha::Logger->get();
        $logger->info("Report received: ".Dumper($params));

        my $interface = Koha::Payment::POS->new({
            branch => $transaction->user_branch });
        my $valid_hash = $interface->is_valid_hash($params);

        unless ($valid_hash) {
            $logger->warn("Invalid hash for transaction $invoicenumber.");
            return $c->render( status  => 400,
                               openapi => { error => "Invalid Hash" });
        }

        $interface->complete_payment($params);

        return $c->render( status => 200, openapi => "");
    }
    catch {
        unless (defined $transaction) {
            return $c->render( status  => 404,
                               openapi => { error => "Transaction not found"});
        }
        if ($_->isa('Koha::Exception::NoSystemPreference')
            && defined $_->syspref && $_->syspref eq 'POSIntegration') {
            return $c->render( status => 404, openapi => {
                error => "POS integration is disabled."
            });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

1;
