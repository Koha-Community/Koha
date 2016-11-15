package Koha::Exceptions::Patron;

use Modern::Perl;

use Exception::Class (

    'Koha::Exceptions::Patron' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Patron::AgeRestricted' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Age restriction applies for patron.",
        fields => ["age_restriction"],
    },
    'Koha::Exceptions::Patron::CardExpired' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron's card has expired.",
        fields => ["expiration_date"],
    },
    'Koha::Exceptions::Patron::CardLost' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron's card has been marked as lost.",
    },
    'Koha::Exceptions::Patron::Debarred' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron is debarred.",
        fields => ["expiration", "comment"],
    },
    'Koha::Exceptions::Patron::DebarredOverdue' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron is debarred because of overdue checkouts.",
        fields => ["number_of_overdues"],
    },
    'Koha::Exceptions::Patron::Debt' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron has debts.",
        fields => ["max_outstanding", "current_outstanding"],
    },
    'Koha::Exceptions::Patron::DebtGuarantees' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron's guarantees have debts.",
        fields => ["max_outstanding", "current_outstanding", "guarantees"],
    },
    'Koha::Exceptions::Patron::DuplicateObject' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron cardnumber and userid must be unique",
        fields => ["conflict"],
    },
    'Koha::Exceptions::Patron::FromAnotherLibrary' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Libraries are independent and this patron is from another library than we are now logged in.",
        fields => ["patron_branch", "current_branch"],
    },
    'Koha::Exceptions::Patron::GoneNoAddress' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron gone no address.",
    },
    'Koha::Exceptions::Patron::NotFound' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron not found.",
        fields => ['borrowernumber'],
    },
    'Koha::Exceptions::Patron::OtherCharges' => {
        isa => 'Koha::Exceptions::Patron',
        description => "Patron has other outstanding charges.",
        fields => ["balance", "other_charges"],
    },

);

1;
