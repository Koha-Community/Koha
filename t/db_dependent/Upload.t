#!/usr/bin/perl

use Modern::Perl;
use File::Temp qw/ tempdir /;
use Test::More tests => 13;
use Test::Warn;

use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;
use Koha::Database;
use Koha::DateUtils;
use Koha::UploadedFile;
use Koha::UploadedFiles;
use Koha::Uploader;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
our $builder = t::lib::TestBuilder->new;

our $current_upload = 0;
our $uploads = [
    [
        { name => 'file1', cat => 'A', size => 6000 },
        { name => 'file2', cat => 'A', size => 8000 },
    ],
    [
        { name => 'file3', cat => 'B', size => 1000 },
    ],
    [
        { name => 'file4', cat => undef, size => 5000 }, # temporary
    ],
    [
        { name => 'file2', cat => 'A', size => 8000 },
        # uploading a duplicate in cat A should fail
    ],
    [
        { name => 'file4', cat => undef, size => 5000 }, # temp duplicate
    ],
    [
        { name => 'file5', cat => undef, size => 7000 },
    ],
    [
        { name => 'file6', cat => undef, size => 6500 },
        { name => 'file7', cat => undef, size => 6501 },
    ],
];

# Redirect upload dir structure and mock C4::Context and CGI
my $tempdir = tempdir( CLEANUP => 1 );
t::lib::Mocks::mock_config('upload_path', $tempdir);
my $specmod = Test::MockModule->new( 'C4::Context' );
$specmod->mock( 'temporary_directory' => sub { return $tempdir; } );
my $cgimod = Test::MockModule->new( 'CGI' );
$cgimod->mock( 'new' => \&newCGI );

# Start testing
subtest 'Make a fresh start' => sub {
    plan tests => 1;

    # Delete existing records (for later tests)
    # Passing keep_file suppresses warnings (and does not delete files)
    # Note that your files are not in danger, since we redirected
    # all files to a new empty temp folder
    Koha::UploadedFiles->delete({ keep_file => 1 });
    is( Koha::UploadedFiles->count, 0, 'No records left' );
};

subtest 'permanent_directory and temporary_directory' => sub {
    plan tests => 2;

    # Check mocked directories
    is( Koha::UploadedFile->permanent_directory, $tempdir,
        'Check permanent directory' );
    is( C4::Context::temporary_directory, $tempdir,
        'Check temporary directory' );
};

subtest 'Add two uploads in category A' => sub {
    plan tests => 9;

    my $upl = Koha::Uploader->new({
        category => $uploads->[$current_upload]->[0]->{cat},
    });
    my $cgi= $upl->cgi;
    my $res= $upl->result;
    is( $res =~ /^\d+,\d+$/, 1, 'Upload 1 includes two files' );
    is( $upl->count, 2, 'Count returns 2 also' );
    is( $upl->err, undef, 'No errors reported' );

    my $rs = Koha::UploadedFiles->search({
        id => [ split ',', $res ]
    }, { order_by => { -asc => 'filename' }});
    my $rec = $rs->next;
    is( $rec->filename, 'file1', 'Check file name' );
    is( $rec->uploadcategorycode, 'A', 'Check category A' );
    is( $rec->filesize, 6000, 'Check size of file1' );
    $rec = $rs->next;
    is( $rec->filename, 'file2', 'Check file name 2' );
    is( $rec->filesize, 8000, 'Check size of file2' );
    is( $rec->public, undef, 'Check public undefined' );
};

subtest 'Add another upload, check file_handle' => sub {
    plan tests => 5;

    my $upl = Koha::Uploader->new({
        category => $uploads->[$current_upload]->[0]->{cat},
        public => 1,
    });
    my $cgi= $upl->cgi;
    is( $upl->count, 1, 'Upload 2 includes one file' );
    my $res= $upl->result;
    my $rec = Koha::UploadedFiles->find( $res );
    is( $rec->uploadcategorycode, 'B', 'Check category B' );
    is( $rec->public, 1, 'Check public == 1' );
    my $fh = $rec->file_handle;
    is( ref($fh) eq 'IO::File' && $fh->opened, 1, 'Get returns a file handle' );

    my $orgname = $rec->filename;
    $rec->filename( 'doesprobablynotexist' )->store;
    is( $rec->file_handle, undef, 'Sabotage with file handle' );
    $rec->filename( $orgname )->store;
};

subtest 'Add temporary upload' => sub {
    plan tests => 2;

    my $upl = Koha::Uploader->new({ tmp => 1 }); #temporary
    my $cgi= $upl->cgi;
    is( $upl->count, 1, 'Upload 3 includes one temporary file' );
    my $rec = Koha::UploadedFiles->find( $upl->result );
    is( $rec->uploadcategorycode =~ /_upload$/, 1, 'Check category temp file' );
};

subtest 'Add same file in same category' => sub {
    plan tests => 3;

    my $upl = Koha::Uploader->new({
        category => $uploads->[$current_upload]->[0]->{cat},
    });
    my $cgi= $upl->cgi;
    is( $upl->count, 0, 'Upload 4 failed as expected' );
    is( $upl->result, undef, 'Result is undefined' );
    my $e = $upl->err;
    is( $e->{file2}->{code}, Koha::Uploader::ERR_EXISTS, "Already exists error reported" );
};

subtest 'Test delete via UploadedFile as well as UploadedFiles' => sub {
    plan tests => 10;

    # add temporary file with same name and contents (file4)
    my $upl = Koha::Uploader->new({ tmp => 1 });
    my $cgi= $upl->cgi;
    is( $upl->count, 1, 'Add duplicate temporary file (file4)' );
    my $id = $upl->result;
    my $path = Koha::UploadedFiles->find( $id )->full_path;

    # testing delete via UploadedFiles (plural)
    my $delete = Koha::UploadedFiles->search({ id => $id })->delete;
    isnt( $delete, "0E0", 'Delete successful' );
    isnt( -e $path, 1, 'File no longer found after delete' );
    is( Koha::UploadedFiles->find( $id ), undef, 'Record also gone' );

    # testing delete via UploadedFile (singular)
    # Note that find returns a Koha::Object
    $upl = Koha::Uploader->new({ tmp => 1 });
    $upl->cgi;
    my $kohaobj = Koha::UploadedFiles->find( $upl->result );
    $path = $kohaobj->full_path;
    $delete = $kohaobj->delete;
    ok( $delete=~/^-?1$/, 'Delete successful' );
    isnt( -e $path, 1, 'File no longer found after delete' );

    # add another record with TestBuilder, so file does not exist
    # catch warning
    my $upload01 = $builder->build({ source => 'UploadedFile' });
    warning_like { $delete = Koha::UploadedFiles->find( $upload01->{id} )->delete; }
        qr/file was missing/,
        'delete warns when file is missing';
    ok( $delete=~/^-?1$/, 'Deleting record was successful' );
    is( Koha::UploadedFiles->count, 4, 'Back to four uploads now' );

    # add another one with TestBuilder and delete twice (file does not exist)
    $upload01 = $builder->build({ source => 'UploadedFile' });
    $kohaobj = Koha::UploadedFiles->find( $upload01->{id} );
    $delete = $kohaobj->delete({ keep_file => 1 });
    $delete = $kohaobj->delete({ keep_file => 1 });
    ok( $delete =~ /^(0E0|-1)$/, 'Repeated delete unsuccessful' );
    # NOTE: Koha::Object->delete does not return 0E0 (yet?)
};

subtest 'Test delete_missing' => sub {
    plan tests => 5;

    # If we add files via TestBuilder, they do not exist
    my $upload01 = $builder->build({ source => 'UploadedFile' });
    my $upload02 = $builder->build({ source => 'UploadedFile' });
    # dry run first
    my $deleted = Koha::UploadedFiles->delete_missing({ keep_record => 1 });
    is( $deleted, 2, 'Expect two records with missing files' );
    isnt( Koha::UploadedFiles->find( $upload01->{id} ), undef, 'Not deleted' );
    $deleted = Koha::UploadedFiles->delete_missing;
    ok( $deleted =~ /^(2|-1)$/, 'Deleted two records with missing files' );
    is( Koha::UploadedFiles->search({
        id => [ $upload01->{id}, $upload02->{id} ],
    })->count, 0, 'Records are gone' );
    # Repeat it
    $deleted = Koha::UploadedFiles->delete_missing;
    is( $deleted, "0E0", "Return value of 0E0 expected" );
};

subtest 'Call search_term with[out] private flag' => sub {
    plan tests => 3;

    my @recs = Koha::UploadedFiles->search_term({ term => 'file' });
    is( @recs, 1, 'Returns only one public result' );
    is( $recs[0]->filename, 'file3', 'Should be file3' );

    is( Koha::UploadedFiles->search_term({
        term => 'file', include_private => 1,
    })->count, 4, 'Returns now four results' );
};

subtest 'Simple tests for httpheaders and getCategories' => sub {
    plan tests => 2;

    my $rec = Koha::UploadedFiles->search_term({ term => 'file' })->next;
    my @hdrs = $rec->httpheaders;
    is( @hdrs == 4 && $hdrs[1] =~ /application\/octet-stream/, 1, 'Simple test for httpheaders');
    $builder->build({ source => 'AuthorisedValue', value => { category => 'UPLOAD', authorised_value => 'HAVE_AT_LEAST_ONE', lib => 'Hi there' } });
    my $cat = Koha::UploadedFiles->getCategories;
    is( @$cat >= 1, 1, 'getCategories returned at least one category' );
};

subtest 'Testing allows_add_by' => sub {
    plan tests => 4;

    my $patron = $builder->build({
        source => 'Borrower',
        value  => { flags => 0 }, #no permissions
    });
    my $patronid = $patron->{borrowernumber};
    is( Koha::Uploader->allows_add_by( $patron->{userid} ),
        undef, 'Patron is not allowed to do anything' );

    # add some permissions: edit_catalogue
    my $fl = 2**9; # edit_catalogue
    $schema->resultset('Borrower')->find( $patronid )->update({ flags => $fl });
    is( Koha::Uploader->allows_add_by( $patron->{userid} ),
        undef, 'Patron is still not allowed to add uploaded files' );

    # replace flags by all tools
    $fl = 2**13; # tools
    $schema->resultset('Borrower')->find( $patronid )->update({ flags => $fl });
    is( Koha::Uploader->allows_add_by( $patron->{userid} ),
        1, 'Patron should be allowed now to add uploaded files' );

    # remove all tools and add upload_general_files only
    $fl = 0; # no modules
    $schema->resultset('Borrower')->find( $patronid )->update({ flags => $fl });
    $builder->build({
        source => 'UserPermission',
        value  => {
            borrowernumber => $patronid,
            module_bit     => { module_bit => { flag => 'tools' } },
            code           => 'upload_general_files',
        },
    });
    is( Koha::Uploader->allows_add_by( $patron->{userid} ),
        1, 'Patron is still allowed to add uploaded files' );
};

subtest 'Testing delete_temporary' => sub {
    plan tests => 9;

    # Add two temporary files: result should be 3 + 3
    Koha::Uploader->new({ tmp => 1 })->cgi; # add file6 and file7
    is( Koha::UploadedFiles->search->count, 6, 'Test starting count' );
    is( Koha::UploadedFiles->search({ permanent => 1 })->count, 3,
        'Includes 3 permanent' );

    # Move all permanents to today - 1
    # Move temp 1 to today - 3, and temp 2,3 to today - 5
    my $today = dt_from_string;
    $today->subtract( minutes => 2 ); # should be enough :)
    my $dt = $today->clone->subtract( days => 1 );
    foreach my $rec ( Koha::UploadedFiles->search({ permanent => 1 }) ) {
        $rec->dtcreated($dt)->store;
    }
    my @recs = Koha::UploadedFiles->search({ permanent => 0 });
    $dt = $today->clone->subtract( days => 3 );
    $recs[0]->dtcreated($dt)->store;
    $dt = $today->clone->subtract( days => 5 );
    $recs[1]->dtcreated($dt)->store;
    $recs[2]->dtcreated($dt)->store;

    # Now call delete_temporary with 6, 5 and 0
    t::lib::Mocks::mock_preference('UploadPurgeTemporaryFilesDays', 6 );
    my $delete = Koha::UploadedFiles->delete_temporary;
    ok( $delete =~ /^(-1|0E0)$/, 'Check return value with 6' );
    is( Koha::UploadedFiles->search->count, 6, 'Delete with pref==6' );

    # use override parameter
    $delete = Koha::UploadedFiles->delete_temporary({ override_pref => 5 });
    ok( $delete =~ /^(2|-1)$/, 'Check return value with 5' );
    is( Koha::UploadedFiles->search->count, 4, 'Delete with override==5' );

    t::lib::Mocks::mock_preference('UploadPurgeTemporaryFilesDays', 0 );
    $delete = Koha::UploadedFiles->delete_temporary;
    ok( $delete =~ /^(-1|1)$/, 'Check return value with 0' );
    is( Koha::UploadedFiles->search->count, 3, 'Delete with pref==0 makes 3' );
    is( Koha::UploadedFiles->search({ permanent => 1 })->count, 3,
        'Still 3 permanent uploads' );
};

subtest 'Testing download headers' => sub {
    plan tests => 2;
    my $test_pdf = Koha::UploadedFile->new({ filename => 'pdf.pdf', uploadcategorycode => 'B', filesize => 1000 });
    my $test_not = Koha::UploadedFile->new({ filename => 'pdf.not', uploadcategorycode => 'B', filesize => 1000 });
    my @pdf_expect = ( '-type'=>'application/pdf','Content-Disposition'=>'inline; filename=pdf.pdf' );
    my @not_expect = ( '-type'=>'application/octet-stream','-attachment'=>'pdf.not' );
    my @pdf_head = $test_pdf->httpheaders;
    my @not_head = $test_not->httpheaders;
    is_deeply(\@pdf_head, \@pdf_expect,"Get inline pdf headers for pdf");
    is_deeply(\@not_head, \@not_expect,"Get download headers for non pdf");
};
# The end
$schema->storage->txn_rollback;

# Helper routine
sub newCGI {
    my ( $class, $hook ) = @_;
    my $read = 0;
    foreach my $uh ( @{$uploads->[ $current_upload ]} ) {
        for( my $i=0; $i< $uh->{size}; $i+=1000 ) {
            $read+= 1000;
            &$hook( $uh->{name}, 'a'x1000, $read );
        }
    }
    $current_upload++;
    return $class;
}
