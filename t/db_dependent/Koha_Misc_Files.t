#!/usr/bin/perl

# Unit tests for Koha::Misc::Files
# Author: Jacek Ablewicz, abl@biblos.pk.edu.pl

use Modern::Perl;
use C4::Context;
use Test::More tests => 30;

BEGIN {
    use_ok('Koha::Misc::Files');
}

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

## new() parameter handling check
is(Koha::Misc::Files->new(), undef, "new() param check test/0");
is(Koha::Misc::Files->new(recordid => 12), undef, "new() param check test/1");
is(Koha::Misc::Files->new(recordid => 'aa123', tabletag => 'ttag_a'), undef, "new() param check test/2");

## create some test objects with arbitrary (tabletag, recordid) pairs
my $mf_a_123 = Koha::Misc::Files->new(recordid => '123', tabletag => 'tst_table_a');
my $mf_a_124 = Koha::Misc::Files->new(recordid => '124', tabletag => 'tst_table_a');
my $mf_b_221 = Koha::Misc::Files->new(recordid => '221', tabletag => 'tst_table_b');
is(ref($mf_a_123), "Koha::Misc::Files", "new() returned object type");

## GetFilesInfo() initial tests (dummy AddFile() / parameter handling checks)
is(ref($mf_a_123->GetFilesInfo()), 'ARRAY', "GetFilesInfo() return type");
is(scalar @{$mf_a_123->GetFilesInfo()}, 0, "GetFilesInfo() empty/non-empty result/1");
$mf_a_123->AddFile(name => '', type => 'text/plain', content => "aaabbcc");
is(scalar @{$mf_a_123->GetFilesInfo()}, 0, "GetFilesInfo() empty/non-empty result/2");

## AddFile(); add 5 sample file records for 3 test objects
$mf_a_123->AddFile(name => 'File_name_1.txt', type => 'text/plain',
  content => "file contents\n1111\n", description => "File #1 sample description");
$mf_a_123->AddFile(name => 'File_name_2.txt', type => 'text/plain',
  content => "file contents\n2222\n", description => "File #2 sample description");
$mf_a_124->AddFile(name => 'File_name_3.txt', content => "file contents\n3333\n", type => 'text/whatever');
$mf_a_124->AddFile(name => 'File_name_4.txt', content => "file contents\n4444\n");
$mf_b_221->AddFile(name => 'File_name_5.txt', content => "file contents\n5555\n");

## check GetFilesInfo() results for added files
my $files_a_123_infos = $mf_a_123->GetFilesInfo();
is(scalar @$files_a_123_infos, 2, "GetFilesInfo() result count/1");
is(scalar @{$mf_b_221->GetFilesInfo()}, 1, "GetFilesInfo() result count/2");
is(ref($files_a_123_infos->[0]), 'HASH', "GetFilesInfo() item file result type");
is($files_a_123_infos->[0]->{file_name}, 'File_name_1.txt', "GetFilesInfo() result check/1");
is($files_a_123_infos->[1]->{file_name}, 'File_name_2.txt', "GetFilesInfo() result check/2");
is($files_a_123_infos->[1]->{file_type}, 'text/plain', "GetFilesInfo() result check/3");
is($files_a_123_infos->[1]->{file_size}, 19, "GetFilesInfo() result check/4");
is($files_a_123_infos->[1]->{file_description}, 'File #2 sample description', "GetFilesInfo() result check/5");

## GetFile() result checks
is($mf_a_123->GetFile(), undef, "GetFile() result check/1");
is($mf_a_123->GetFile(id => 0), undef, "GetFile() result check/2");

my $a123_file_1 = $mf_a_123->GetFile(id => $files_a_123_infos->[0]->{file_id});
is(ref($a123_file_1), 'HASH', "GetFile() result check/3");
is($a123_file_1->{file_id}, $files_a_123_infos->[0]->{file_id}, "GetFile() result check/4");
is($a123_file_1->{file_content}, "file contents\n1111\n", "GetFile() result check/5");

## MergeFileRecIds() tests
$mf_a_123->MergeFileRecIds(123,221);
$files_a_123_infos = $mf_a_123->GetFilesInfo();
is(scalar @$files_a_123_infos, 2, "GetFilesInfo() result count after dummy MergeFileRecIds()");
$mf_a_123->MergeFileRecIds(124);
$files_a_123_infos = $mf_a_123->GetFilesInfo();
is(scalar @$files_a_123_infos, 4, "GetFilesInfo() result count after MergeFileRecIds()/1");
is(scalar @{$mf_a_124->GetFilesInfo()}, 0, "GetFilesInfo() result count after MergeFileRecIds()/2");
is($files_a_123_infos->[-1]->{file_name}, 'File_name_4.txt', "GetFilesInfo() result check after MergeFileRecIds()");

## DelFile() test
$mf_a_123->DelFile(id => $files_a_123_infos->[-1]->{file_id});
$files_a_123_infos = $mf_a_123->GetFilesInfo();
is(scalar @$files_a_123_infos, 3, "GetFilesInfo() result count after DelFile()");

## DelAllFiles() tests
my $number_of_deleted_files_a_123 = $mf_a_123->DelAllFiles();
is( $number_of_deleted_files_a_123, 3, "DelAllFiles returns the number of deleted files/1" );
$files_a_123_infos = $mf_a_123->GetFilesInfo();
is(scalar @$files_a_123_infos, 0, "GetFilesInfo() result count after DelAllFiles()/1");
my $number_of_deleted_files_b_221 = $mf_b_221->DelAllFiles();
is( $number_of_deleted_files_b_221, 1, "DelAllFiles returns the number of deleted files/2" );
is(scalar @{$mf_b_221->GetFilesInfo()}, 0, "GetFilesInfo() result count after DelAllFiles()/2");

$dbh->rollback;

1;
