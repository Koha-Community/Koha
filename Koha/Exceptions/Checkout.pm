package Koha::Exceptions::Checkout;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::Checkout' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Checkout::FailedRenewal' => {
        isa         => 'Koha::Exceptions::Checkout',
        description => "Renewing checkout failed"
    },
);

1;
