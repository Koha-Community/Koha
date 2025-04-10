#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use C4::Context;
use C4::Letters qw( GetQueuedMessages );
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Patrons;

use t::lib::TestBuilder;
use t::lib::Mocks;

use Test::NoWarnings;
use Test::More tests => 23;
use Test::MockModule;
use Test::Warn;
use Carp;

my ( $email_object, $sendmail_params );

my $email_sender_module = Test::MockModule->new('Email::Stuffer');
$email_sender_module->mock(
    'send_or_die',
    sub {
        ( $email_object, $sendmail_params ) = @_;
        warn 'Fake sendmail';
    }
);

use_ok('Koha::Patron::Password::Recovery');

t::lib::Mocks::mock_preference( 'KohaAdminEmailAddress', 'test@koha-community.org' );

my $schema = Koha::Database->new()->schema();
$schema->storage->txn_begin();

#
# Start with fresh data
#
my $builder         = t::lib::TestBuilder->new;
my $borrowernumber1 = '2000000000';
my $borrowernumber2 = '2000000001';
my $borrowernumber3 = '2000000002';
my $userid1         = "I83MFItzRpGPxD3vW0";
my $userid2         = "Gh5t43980hfSAOcvne";
my $userid3         = "adsfada80hfSAOcvne";
my $email1          = $userid1 . '@koha-community.org';
my $email2          = $userid2 . '@koha-community.org';
my $email3          = $userid3 . '@koha-community.org';
my $uuid1           = "ABCD1234";
my $uuid2           = "WXYZ0987";
my $uuid3           = "LMNO4561";

my $patron_category = $builder->build( { source => 'Category' } );
my $branch          = $builder->build(
    {
        source => 'Branch',
        value  => {
            branchemail      => undef,
            branchreplyto    => undef,
            branchreturnpath => $email1,
        },
    }
);

$schema->resultset('BorrowerPasswordRecovery')->delete_all();

$schema->resultset('Borrower')->create(
    {
        borrowernumber => $borrowernumber1,
        surname        => '',
        address        => '',
        city           => '',
        userid         => $userid1,
        email          => $email1,
        categorycode   => $patron_category->{categorycode},
        branchcode     => $branch->{branchcode},
    }
);
$schema->resultset('Borrower')->create(
    {
        borrowernumber => $borrowernumber2,
        surname        => '',
        address        => '',
        city           => '',
        userid         => $userid2,
        email          => $email2,
        categorycode   => $patron_category->{categorycode},
        branchcode     => $branch->{branchcode},
    }
);
$schema->resultset('Borrower')->create(
    {
        borrowernumber => $borrowernumber3,
        surname        => '',
        address        => '',
        city           => '',
        userid         => $userid3,
        email          => $email3,
        categorycode   => $patron_category->{categorycode},
        branchcode     => $branch->{branchcode},
    }
);

$schema->resultset('BorrowerPasswordRecovery')->create(
    {
        borrowernumber => $borrowernumber1,
        uuid           => $uuid1,
        valid_until    => dt_from_string()->add( days => 2 )->datetime()
    }
);
$schema->resultset('BorrowerPasswordRecovery')->create(
    {
        borrowernumber => $borrowernumber2,
        uuid           => $uuid2,
        valid_until    => dt_from_string()->subtract( days => 2 )->datetime()
    }
);
$schema->resultset('BorrowerPasswordRecovery')->create(
    {
        borrowernumber => $borrowernumber3,
        uuid           => $uuid3,
        valid_until    => dt_from_string()->subtract( days => 3 )->datetime()
    }
);

can_ok(
    "Koha::Patron::Password::Recovery",
    qw(ValidateBorrowernumber GetValidLinkInfo SendPasswordRecoveryEmail CompletePasswordRecovery)
);

############################################################
# Koha::Patron::Password::Recovery::ValidateBorrowernumber #
############################################################

ok(
    Koha::Patron::Password::Recovery::ValidateBorrowernumber($borrowernumber1),
    "[ValidateBorrowernumber] Borrower has a password recovery entry"
);
ok(
    !Koha::Patron::Password::Recovery::ValidateBorrowernumber($borrowernumber2),
    "[ValidateBorrowernumber] Borrower's number is not found; password recovery entry is expired"
);
ok(
    !Koha::Patron::Password::Recovery::ValidateBorrowernumber(9999),
    "[ValidateBorrowernumber] Borrower has no password recovery entry"
);

######################################################
# Koha::Patron::Password::Recovery::GetValidLinkInfo #
######################################################

my ( $bnum1, $uname1 ) = Koha::Patron::Password::Recovery::GetValidLinkInfo($uuid1);
my ( $bnum2, $uname2 ) = Koha::Patron::Password::Recovery::GetValidLinkInfo($uuid2);
my ( $bnum3, $uname3 ) = Koha::Patron::Password::Recovery::GetValidLinkInfo("THISISANINVALIDUUID");

is( $bnum1,  $borrowernumber1, "[GetValidLinkInfo] Borrower has a valid link" );
is( $uname1, $userid1,         "[GetValidLinkInfo] Borrower's username is fetched when a valid link is found" );
ok( !defined($bnum2), "[GetValidLinkInfo] Borrower's link is no longer valid; entry is expired" );
ok( !defined($bnum3), "[GetValidLinkInfo] Invalid UUID returns no borrowernumber" );

##############################################################
# Koha::Patron::Password::Recovery::CompletePasswordRecovery #
##############################################################

is(
    Koha::Patron::Password::Recovery::CompletePasswordRecovery($uuid1), 3,
    "[CompletePasswordRecovery] Completing a password recovery deletes the used entry"
);

$schema->resultset('BorrowerPasswordRecovery')->create(
    {
        borrowernumber => $borrowernumber2,
        uuid           => $uuid2,
        valid_until    => dt_from_string()->subtract( days => 2 )->datetime()
    }
);

ok(
    Koha::Patron::Password::Recovery::CompletePasswordRecovery($uuid2) == 1,
    "[CompletePasswordRecovery] An expired or invalid UUID purges expired entries"
);
ok(
    Koha::Patron::Password::Recovery::CompletePasswordRecovery($uuid2) == 0,
    "[CompletePasswordRecovery] Returns 0 on a clean table"
);

###################################################################
# Koha::Patron::Password::Recovery::DeleteExpiredPasswordRecovery #
###################################################################

$schema->resultset('BorrowerPasswordRecovery')->create(
    {
        borrowernumber => $borrowernumber3,
        uuid           => $uuid3,
        valid_until    => dt_from_string()->subtract( days => 3 )->datetime()
    }
);

ok(
    Koha::Patron::Password::Recovery::DeleteExpiredPasswordRecovery($borrowernumber3) == 1,
    "[DeleteExpiredPasswordRecovery] we can delete the unused entry"
);
ok(
    Koha::Patron::Password::Recovery::DeleteExpiredPasswordRecovery($borrowernumber3) == 0,
    "[DeleteExpiredPasswordRecovery] Returns 0 on a clean table"
);

###############################################################
# Koha::Patron::Password::Recovery::SendPasswordRecoveryEmail #
###############################################################

my $borrower = Koha::Patrons->search( { userid => $userid1 } )->next;
my $success;
warning_is {
    $success = Koha::Patron::Password::Recovery::SendPasswordRecoveryEmail( $borrower, $email1 );
}
"Fake sendmail",
    '[SendPasswordRecoveryEmail] expecting fake sendmail';
ok( $success == 1, '[SendPasswordRecoveryEmail] Returns 1 on success' );

my $letters = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber1, limit => 99 } );
ok( scalar @$letters == 1, "[SendPasswordRecoveryEmail] There is a letter in the queue for our borrower" );

my $bpr       = $schema->resultset('BorrowerPasswordRecovery')->search( { borrowernumber => $borrowernumber1 } );
my $tempuuid1 = $bpr->next->uuid;

warning_is {
    Koha::Patron::Password::Recovery::SendPasswordRecoveryEmail( $borrower, $email1 );
}
"Fake sendmail",
    '[SendPasswordRecoveryEmail] expecting fake sendmail';

$bpr = $schema->resultset('BorrowerPasswordRecovery')->search( { borrowernumber => $borrowernumber1 } );
my $tempuuid2 = $bpr->next->uuid;

$letters = C4::Letters::GetQueuedMessages( { borrowernumber => $borrowernumber1, limit => 99 } );

ok(
    $tempuuid1 ne $tempuuid2,
    "[SendPasswordRecoveryEmail] UPDATE == ON changes uuid in the database and updates the expirydate"
);
ok( scalar @$letters == 2, "[SendPasswordRecoveryEmail] UPDATE == ON sends a new letter with updated uuid" );

foreach my $letter (@$letters) {
    ok(
        $letter->{status} eq 'sent',
        'Test SendPasswordRecoverEmail sent due to TestBuilder Sender being a valid email address as expected.'
    );
}

$schema->storage->txn_rollback();

