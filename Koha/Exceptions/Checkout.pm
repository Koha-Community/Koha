package Koha::Exceptions::Checkout;

use Modern::Perl;

use Exception::Class (
    'Koha::Exceptions::Checkout' => {
        description => "Something went wrong!"
    },
    'Koha::Exceptions::Checkout::FailedRenewal' => {
        isa         => 'Koha::Exceptions::Checkout',
        description => "Renewing checkout failed"
    },
);

1;
