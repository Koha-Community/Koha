#!/usr/bin/perl

use Modern::Perl;
use File::Temp qw/ tempdir /;
use Test::CGI::Multipart;
use Test::More tests => 11;

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
foreach my $key (qw(id filename filepath dir)) {
    ok(exists $file->{$key}, "GetUploadedFile($id)->{$key} exists");
}

ok(-e $file->{filepath}, "File $file->{filepath} exists");

ok(C4::UploadedFiles::DelUploadedFile($id), "DelUploadedFile($id) returned true");
ok(! -e $file->{filepath}, "File $file->{filepath} does not exist anymore");

is(C4::UploadedFiles::UploadFile($testfilename, '../', $testfile_fh->handle), undef, 'UploadFile with $dir containing ".." return undef');
is(C4::UploadedFiles::GetUploadedFile(), undef, 'GetUploadedFile without parameters returns undef');
