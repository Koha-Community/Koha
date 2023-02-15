#!/usr/bin/perl

use Modern::Perl;
use File::Temp qw();
use Test::More tests => 2;
use Test::Exception;

use C4::Context;
use Koha::Database;
use Koha::Database::Commenter;

our $schema = Koha::Database->new->schema;
our $dbh = C4::Context->dbh;

our $mgr;

subtest '->new, dry_run' => sub {
    plan tests => 6;
    $schema->storage->txn_begin; # just cosmetic, no changes expected in a dry run

    # Two exceptions on dbh parameter
    throws_ok { Koha::Database::Commenter->new } 'Koha::Exceptions::MissingParameter', 'No dbh';
    throws_ok { Koha::Database::Commenter->new({ dbh => 'dbh' }) } 'Koha::Exceptions::WrongParameter', 'dbh no string';

    # Another exception: delete schema file and reset should raise exception
    my $filename = create_schema_file();
    my $stdout;
    open my $fh, '>', \$stdout;
    $mgr = Koha::Database::Commenter->new({ dbh => $dbh, schema_file => $filename, fh => $fh });
    unlink $filename;
    throws_ok { $mgr->reset_to_schema({ dry_run => 1, table => 'biblio' }) } 'Koha::Exceptions::FileNotFound', 'Schema deleted';

    # Clear comments for article_requests in dry run mode
    $stdout = q{};
    $mgr->clear({ table => 'article_requests', dry_run => 1 });
    like( $stdout, qr/COLUMN `toc_request`.*DEFAULT 0;$/m, 'No comment for toc_request' );

    # Renumber this field in dry run mode
    $stdout = q{};
    $mgr->renumber({ table => 'article_requests', dry_run => 1 });
    like( $stdout, qr/COLUMN `toc_request`.*COMMENT 'Column_\d+';$/m, 'Numbered comment for toc_request' );

    # Reset in dry run mode, first fix schema file again
    # Our fake schema contains only one column for article_requests now.
    $filename = create_schema_file();
    $mgr = Koha::Database::Commenter->new({ dbh => $dbh, schema_file => $filename, fh => $fh });
    $stdout = q{};
    $mgr->reset_to_schema({ table => 'article_requests', dry_run => 1 });
    # We expect an ALTER clearing toc_request first, followed by an ALTER adding comment.
    # Note: This is based on the fair assumption that toc_request had a comment! This test could fail if it had not.
    like( $stdout, qr/ALTER.*toc_request.*DEFAULT 0;(.*\n)+ALTER.*toc_request.*COMMENT.*$/m, 'Reset for one-columned article_requests' );

    $schema->storage->txn_rollback;
};

subtest '->clear, ->reset, ->renumber' => sub {
    plan tests => 6;
    #$schema->storage->txn_begin; # commented: DDL statements implicitly commit; we are testing only 1 new table here btw

    create_test_table1($dbh);
    $mgr->clear({ table => 'database_commenter_1' });
    my $info = $mgr->_columns_info( 'database_commenter_1' );
    is( $info->{sometext}->{Comment}, q{}, 'Found no comment for sometext' );
    is( $info->{anotherint}->{Comment}, q{}, 'Found no comment for anotherint' );

    # Created temporary file serves as schema/kohastructure.sql now
    $mgr->reset_to_schema({ table => 'database_commenter_1' });
    $info = $mgr->_columns_info( 'database_commenter_1' );
    is( $info->{sometext}->{Comment}, 'some nice quote\'s', 'Found comment for sometext' );
    is( $info->{anotherint}->{Comment}, 'my int', 'Found comment for anotherint' );

    # Renumber follows alphabetical order
    $mgr->renumber({ table => 'database_commenter_1' });
    $info = $mgr->_columns_info( 'database_commenter_1' );
    is( $info->{anotherint}->{Comment}, 'Column_1', 'Found Column_1' );
    is( $info->{timestamp2}->{Comment}, 'Column_5', 'Found Column_5' );

    eval { $dbh->do('DROP TABLE database_commenter_1') };
    #$schema->storage->txn_rollback; # commented: DDL statements implicitly commit
};

sub create_schema_file {
    my ( $fh, $filename ) = File::Temp::tempfile();
    print $fh schema_table1();
    print $fh "\n";
    print $fh schema_table2(); # fragment of Koha table
    close $fh;
    return $filename;
}

sub schema_table1 {
    return q|CREATE TABLE database_commenter_1 (
    id int AUTO_INCREMENT,
    sometext varchar(80) NOT NULL DEFAULT '' COMMENT 'some nice quote''s',
    anotherint int NULL COMMENT 'my int',
    date1 DATE NOT NULL,
    timestamp2 timestamp NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (id) );|;
}

sub schema_table2 { # only a fragment
    return q|CREATE TABLE article_requests (
    `toc_request` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'borrower requested table of contents')|;
}

sub create_test_table1 {
    my ( $dbh ) = @_;
    eval { $dbh->do('DROP TABLE database_commenter_1') };
    $dbh->do( schema_table1() );
}
