package Koha::Exceptions::Checkout;

use Modern::Perl;

use Koha::Exceptions::Exception;

use Exception::Class (
    'Koha::Exceptions::Checkout' => {
        isa => 'Koha::Exceptions::Exception',
    },
    'Koha::Exceptions::Checkout::FailedRenewal' => {
        isa         => 'Koha::Exceptions::Checkout',
        description => "Renewing checkout failed"
    },
);

1;
