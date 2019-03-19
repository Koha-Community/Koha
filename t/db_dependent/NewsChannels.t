#!/usr/bin/perl

use Modern::Perl;
use Koha::Database;
use Koha::DateUtils;
use Koha::Libraries;
use Koha::News;

use Test::More tests => 4;

BEGIN {
    use_ok('C4::NewsChannels');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

# Add LIB1, if it doesn't exist.
my $addbra = 'LIB1';
unless ( Koha::Libraries->find($addbra) ) {
    $dbh->do( q{ INSERT INTO branches (branchcode,branchname) VALUES (?,?) },
        undef, ( $addbra, "$addbra branch" ) );
}

# Add CAT1, if it doesn't exist.
my $addcat = 'CAT1';
{
    my $sth = $dbh->prepare( q{ SELECT categorycode FROM categories WHERE categorycode = ? } );
    $sth->execute ( $addcat );
    if ( not defined $sth->fetchrow () ) {
        $dbh->do( q{ INSERT INTO categories (categorycode,description) VALUES (?,?) },
            undef, ( $addcat, "$addcat description") );
    }
}

# Add a test user if not already present.
my $addbrwr = 'BRWR1';
my $brwrnmbr;
{
    my $query =
        q{ SELECT borrowernumber from borrowers WHERE surname = ? AND branchcode = ? AND categorycode = ? };
    my $sth = $dbh->prepare( $query );
    $sth->execute( ($addbrwr, $addbra, $addcat) );
    $brwrnmbr = $sth->fetchrow;

    # Not found, let us insert it.
    if ( not defined $brwrnmbr ) {
        $dbh->do( q{ INSERT INTO borrowers (surname, address, city, branchcode, categorycode) VALUES (?, ?, ?, ?, ?) },
            undef, ($addbrwr, '(test) address', '(test) city', $addbra, $addcat) );

        # Retrieve the njew borrower number.
        $query =
            q{ SELECT borrowernumber from borrowers WHERE surname = ? AND branchcode = ? AND categorycode = ? };
        my $sth = $dbh->prepare( $query );
        $sth->execute( ($addbrwr, $addbra, $addcat) );
        $brwrnmbr = $sth->fetchrow;
    }
}

# Must have valid borrower number, or tests are meaningless.
ok ( defined $brwrnmbr );

# Test GetNewsToDisplay
my ( $opac_news_count, $arrayref_opac_news ) = GetNewsToDisplay( q{}, 'LIB1' );
ok( $opac_news_count >= 2, 'Successfully tested GetNewsToDisplay for LIB1!' );

