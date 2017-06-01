package Koha::REST::V1::Notices::Report;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::Notice::Messages;

use Try::Tiny;

sub labyrintti {
    my $c = shift->openapi->valid_input or return;

    my $message_id = $c->validation->param('message_id');
    my $status = $c->validation->param('status');
    my $delivery_note = $c->validation->param('message');
    my $notice;

    return try {
        my $config = C4::Context->config('smsProviders');
        if ($config && exists $config->{labyrintti}->{reportUrlAllowedIPs}) {
            my @allowed_ips = split /\s|,/, $config->{labyrintti}->{reportUrlAllowedIPs};
            my $ip = $c->tx->remote_address;
            if (!@allowed_ips || !grep(/^$ip$/,@allowed_ips)) {
                return $c->render( status  => 401,
                                   openapi => { error => 'Unauthorized' });
            }
        }
        else {
            return $c->render( status  => 401,
                               openapi => { error => 'Unauthorized' });
        }

        $notice = Koha::Notice::Messages->find($message_id);

        if ($status eq "ERROR") {
            # Delivery was failed. Set notice status to failed and add delivery
            # note provided by Labyrintti.
            $notice->set({
                status        => 'failed',
                delivery_note => $delivery_note,
            })->store;
        }
        return $c->render(status => 200, openapi => "");
    }
    catch {
        unless ($notice) {
            return $c->render( status  => 404,
                               openapi => { error => "Notice not found" } );
        }
        Koha::Exceptions::rethrow_exception($_);
    };
}

1;
