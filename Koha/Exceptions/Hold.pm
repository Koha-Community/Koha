package Koha::Exceptions::Hold;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Hold' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Hold::ItemLevelHoldNotAllowed' => {
        isa => 'Koha::Exceptions::Hold',
        description => "Item level hold is not allowed.",
    },
    'Koha::Exceptions::Hold::MaximumHoldsReached' => {
        isa => 'Koha::Exceptions::Hold',
        description => "Maximum number of holds have been reached.",
        fields => ["max_holds_allowed", "current_hold_count"],
    },
    'Koha::Exceptions::Hold::MaximumHoldsForRecordReached' => {
        isa => 'Koha::Exceptions::Hold',
        description => "Maximum number of holds for a record have been reached.",
        fields => ["max_holds_allowed", "current_hold_count"],
    },
    'Koha::Exceptions::Hold::NotAllowedByLibrary' => {
        isa => 'Koha::Exceptions::Hold',
        description => "This library does not allow holds.",
    },
    'Koha::Exceptions::Hold::NotAllowedFromOtherLibraries' => {
        isa => 'Koha::Exceptions::Hold',
        description => "Cannot hold from other libraries.",
    },
    'Koha::Exceptions::Hold::NotAllowedInOPAC' => {
        isa => 'Koha::Exceptions::Hold',
        description => "Holds are disabled in OPAC.",
    },
    'Koha::Exceptions::Hold::OnShelfNotAllowed' => {
        isa => 'Koha::Exceptions::Hold',
        description => "On-shelf holds are not allowed.",
    },
    'Koha::Exceptions::Hold::ZeroHoldsAllowed' => {
        isa => 'Koha::Exceptions::Hold',
        description => "Matching hold rule that does not allow any holds.",
    },

);

1;
