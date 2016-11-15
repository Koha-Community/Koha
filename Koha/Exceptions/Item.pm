package Koha::Exceptions::Item;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Item' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Item::AlreadyHeldForThisPatron' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item already held for this patron.",
    },
    'Koha::Exceptions::Item::CannotBeTransferred' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item cannot be transferred from holding library to given library.",
        fields => ["from_library", "to_library"],
    },
    'Koha::Exceptions::Item::CheckedOut' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item has already been checked out.",
        fields => ["borrowernumber", "date_due"],
    },
    'Koha::Exceptions::Item::Damaged' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item is marked as damaged.",
    },
    'Koha::Exceptions::Item::FromAnotherLibrary' => {
        isa => 'Koha::Exceptions::Item',
        description => "Libraries are independent and item is not from this library.",
        fields => ["current_library", "from_library"],
    },
    'Koha::Exceptions::Item::Held' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item held.",
        fields => ["borrowernumber", "hold_queue_length", "status"],
    },
    'Koha::Exceptions::Item::HighHolds' => {
        isa => 'Koha::Exceptions::Item',
        description => "High demand item. Loan period shortened.",
        fields => ["num_holds", "duration", "returndate"],
    },
    'Koha::Exceptions::Item::Lost' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item is marked as lost.",
        fields => ["code", "status"],
    },
    'Koha::Exceptions::Item::NotForLoan' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item is marked as not for loan.",
        fields => ["code", "status"],
    },
    'Koha::Exceptions::Item::NotFound' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item not found.",
        fields => ['itemnumber'],
    },
    'Koha::Exceptions::Item::NotForLoanForcing' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item is marked as not for loan, but it is possible to override.",
        fields => ["notforloan"],
    },
    'Koha::Exceptions::Item::Restricted' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item is marked as restricted.",
    },
    'Koha::Exceptions::Item::Transfer' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item is being transferred.",
        fields => ["datesent", "from_library", "to_library"],
    },
    'Koha::Exceptions::Item::UnknownBarcode' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item has unknown barcode, or no barcode at all.",
        fields => ["barcode"],
    },
    'Koha::Exceptions::Item::Withdrawn' => {
        isa => 'Koha::Exceptions::Item',
        description => "Item is marked as withdrawn.",
    }

);

1;
