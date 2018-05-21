package Koha::REST::V1::Payments::Online::CPU::Reports;

use Modern::Perl;
use Mojo::Base 'Mojolicious::Controller';

use C4::Context;

use Koha::Logger;
use Koha::Payment::Online;
use Koha::PaymentsTransaction;
use Koha::PaymentsTransactions;

use Data::Dumper;

use Try::Tiny;

=head2 cpu_online_report

Receives the success report from CPU.

=cut

sub cpu_online_report {
    my $c = shift->openapi->valid_input or return;

    my $transaction;

    return try {
        my $invoicenumber = $c->validation->param('invoicenumber');
        $transaction = Koha::PaymentsTransactions->find($invoicenumber);
        my $params = $c->req->json;

        C4::Context->setCommandlineEnvironment();
        C4::Context->interface('rest');

        $c->app->log->info("Report received: ".Dumper($params));

        my $interface = Koha::Payment::Online->new({
            branch => $transaction->user_branch });
        my $valid_hash = $interface->is_valid_hash($params);

        unless ($valid_hash) {
            $c->app->log->warn("Invalid hash for transaction $invoicenumber.");
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
            && defined $_->syspref && $_->syspref eq 'OnlinePayments') {
            return $c->render( status => 404, openapi => {
                error => "Online payments are disabled."
            });
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

1;
