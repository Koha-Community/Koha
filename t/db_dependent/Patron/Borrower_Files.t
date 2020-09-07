#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014  Biblibre SARL
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

use Koha::Database;
use Koha::Patrons;
use t::lib::TestBuilder;

use Test::More tests => 23;

use_ok('Koha::Patron::Files');

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;
my $dbh = C4::Context->dbh;

$dbh->do(q|DELETE FROM issues|);
$dbh->do(q|DELETE FROM borrowers|);
$dbh->do(q|DELETE FROM borrower_files|);

my $library = $builder->build({
    source => 'Branch',
});

my $patron_category = $builder->build({ source => 'Category' });
my $borrowernumber = Koha::Patron->new({
    firstname =>  'my firstname',
    surname => 'my surname',
    categorycode => $patron_category->{categorycode},
    branchcode => $library->{branchcode},
})->store->borrowernumber;

my $bf = Koha::Patron::Files->new(
    borrowernumber => $borrowernumber,
);


my $addFile = $bf->AddFile(
    name => 'my filename',
    type => 'text/plain',
);
is( $addFile, undef, 'AddFile without the required parameter content returns undef' );
my $files = $bf->GetFilesInfo();
is( @$files, 0, 'AddFile does not add a file without the parameter content' );

$addFile = $bf->AddFile(
    type => 'text/plain',
    content => 'my filecontent',
);
is( $addFile, undef, 'AddFile without the required parameter name returns undef' );
$files = $bf->GetFilesInfo();
is( @$files, 0, 'AddFile does not add a file without the parameter name' );


my $file1 = {
    name => 'my filename1',
    type => 'text/plain',
    content => 'my filecontent1',
};
$addFile = $bf->AddFile(%$file1);
is( $addFile, 1, 'AddFile with the required parameters returns 1' );
$files = $bf->GetFilesInfo();
is( @$files, 1, 'GetFilesInfo returns 1 file' );
is( $files->[0]->{file_name}, $file1->{name}, 'Correctly stored name' );
is( $files->[0]->{file_type}, $file1->{type}, 'Correctly stored type' );


my $file2 = {
    name => 'my filename2',
    type => 'text/html',
    description => 'my filedescription2',
    content => 'my filecontent2',
};
$addFile = $bf->AddFile(%$file2);
is( $addFile, 1, 'AddFile with the required parameters returns 1' );
$files = $bf->GetFilesInfo();
is( @$files, 2, "GetFilesInfo returns 2 files" );
is( $files->[1]->{file_name}, $file2->{name}, 'Correctly stored name' );
is( $files->[1]->{file_type}, $file2->{type}, 'Correctly stored type' );
is( $files->[1]->{file_description}, $file2->{description}, 'Correctly stored description' );

my $file = $bf->GetFile();
is( $file, undef, 'GetFile without parameters returns undef' );

$file = $bf->GetFile(
    id => $files->[1]->{file_id},
);
is( $file->{file_name}, $files->[1]->{file_name}, 'GetFile returns the correct name' );
is( $file->{file_type}, $files->[1]->{file_type}, 'GetFile returns the correct type' );
is( $file->{file_description}, $files->[1]->{file_description}, 'GetFile returns the correct description' );


$bf->DelFile();
$files = $bf->GetFilesInfo();
is( @$files, 2, 'DelFile without parameters does not delete a file' );

$bf->DelFile(
    id => $files->[1]->{file_id},
);
$files = $bf->GetFilesInfo();
is( @$files, 1, 'DelFile delete a file' );
is( $files->[0]->{file_name}, $file1->{name}, 'DelFile delete the correct entry' );
is( $files->[0]->{file_type}, $file1->{type}, 'DelFile delete the correct entry' );

$bf->DelFile(
    id => $files->[0]->{file_id},
);
$files = $bf->GetFilesInfo();
is( @$files, 0, 'DelFile delete a file' );
