#!/usr/bin/perl

use Modern::Perl;
use File::Temp qw/ tempdir /;
use Test::CGI::Multipart;
use Test::More tests => 18;
use Test::Warn;

use t::lib::Mocks;

use C4::Context;
use C4::UploadedFiles;

# This simulates a multipart POST request with a file upload.
my $tcm = new Test::CGI::Multipart;
$tcm->upload_file(
    name => 'testfile',
    file => 'testfilename.txt',
    value => "This is the content of testfilename.txt",
);
my $cgi = $tcm->create_cgi;

my $tempdir = tempdir(CLEANUP => 1);
t::lib::Mocks::mock_config('upload_path', $tempdir);

my $testfilename = $cgi->param('testfile');
my $testfile_fh = $cgi->upload('testfile');
my $id = C4::UploadedFiles::UploadFile($testfilename, '', $testfile_fh->handle);
ok($id, "File uploaded, id is $id");

my $file = C4::UploadedFiles::GetUploadedFile($id);
isa_ok($file, 'HASH', "GetUploadedFiles($id)");
foreach my $key (qw(hashvalue filename filepath dir)) {
    ok(exists $file->{$key}, "GetUploadedFile($id)->{$key} exists");
}

ok(-e $file->{filepath}, "File $file->{filepath} exists");

ok(C4::UploadedFiles::DanglingEntry()==-1, "DanglingEntry() returned -1 as expected.");
ok(C4::UploadedFiles::DanglingEntry($id)==0, "DanglingEntry($id) returned 0 as expected.");
unlink ($file->{filepath});
ok(C4::UploadedFiles::DanglingEntry($id)==1, "DanglingEntry($id) returned 1 as expected.");

open my $fh,">",($file->{filepath});
print $fh "";
close $fh;

my $DelResult;
is(C4::UploadedFiles::DelUploadedFile($id),1, "DelUploadedFile($id) returned 1 as expected.");
warning_like { $DelResult=C4::UploadedFiles::DelUploadedFile($id); } qr/file for hash/, "Expected warning for deleting Dangling Entry.";
is($DelResult,-1, "DelUploadedFile($id) returned -1 as expected.");
ok(! -e $file->{filepath}, "File $file->{filepath} does not exist anymore");

my $UploadResult;
warning_like { $UploadResult=C4::UploadedFiles::UploadFile($testfilename,'../',$testfile_fh->handle); } qr/^Filename or dirname contains '..'. Aborting upload/, "Expected warning for bad file upload.";
is($UploadResult, undef, "UploadFile with dir containing \"..\" return undef");
is(C4::UploadedFiles::GetUploadedFile(), undef, 'GetUploadedFile without parameters returns undef');

#trivial test for httpheaders
my @hdrs = C4::UploadedFiles::httpheaders('does_not_matter_yet');
is( @hdrs == 4 && $hdrs[1] =~ /application\/octet-stream/, 1, 'Simple test for httpheaders'); #TODO Will be extended on report 14282
