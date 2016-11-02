#!/usr/bin/perl

use Modern::Perl;
use File::Temp qw/ tempdir /;
use Test::More tests => 8;

use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;

use C4::Context;
use Koha::Database;
use Koha::Upload;

my $schema  = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh = C4::Context->dbh;

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
];

# Redirect upload dir structure and mock File::Spec and CGI
my $tempdir = tempdir( CLEANUP => 1 );
t::lib::Mocks::mock_config('upload_path', $tempdir);
my $specmod = Test::MockModule->new( 'File::Spec' );
$specmod->mock( 'tmpdir' => sub { return $tempdir; } );
my $cgimod = Test::MockModule->new( 'CGI' );
$cgimod->mock( 'new' => \&newCGI );

# Start testing
subtest 'Test01' => sub {
    plan tests => 7;
    test01();
};
subtest 'Test02' => sub {
    plan tests => 4;
    test02();
};
subtest 'Test03' => sub {
    plan tests => 2;
    test03();
};
subtest 'Test04' => sub {
    plan tests => 3;
    test04();
};
subtest 'Test05' => sub {
    plan tests => 5;
    test05();
};
subtest 'Test06' => sub {
    plan tests => 2;
    test06();
};
subtest 'Test07' => sub {
    plan tests => 2;
    test07();
};
subtest 'Test08: allows_add_by' => sub {
    plan tests => 4;
    test08();
};
$schema->storage->txn_rollback;

sub test01 {
    # Delete existing records (for later tests)
    $dbh->do( "DELETE FROM uploaded_files" );

    my $upl = Koha::Upload->new({
        category => $uploads->[$current_upload]->[0]->{cat},
    });
    my $cgi= $upl->cgi;
    my $res= $upl->result;
    is( $res =~ /^\d+,\d+$/, 1, 'Upload 1 includes two files' );
    is( $upl->count, 2, 'Count returns 2 also' );
    foreach my $r ( $upl->get({ id => $res }) ) {
        if( $r->{name} eq 'file1' ) {
            is( $r->{uploadcategorycode}, 'A', 'Check category A' );
            is( $r->{filesize}, 6000, 'Check size of file1' );
        } elsif( $r->{name} eq 'file2' ) {
            is( $r->{filesize}, 8000, 'Check size of file2' );
            is( $r->{public}, undef, 'Check public undefined' );
        }
    }
    is( $upl->err, undef, 'No errors reported' );
}

sub test02 {
    my $upl = Koha::Upload->new({
        category => $uploads->[$current_upload]->[0]->{cat},
        public => 1,
    });
    my $cgi= $upl->cgi;
    is( $upl->count, 1, 'Upload 2 includes one file' );
    my $res= $upl->result;
    my $r = $upl->get({ id => $res, filehandle => 1 });
    is( $r->{uploadcategorycode}, 'B', 'Check category B' );
    is( $r->{public}, 1, 'Check public == 1' );
    is( ref($r->{fh}) eq 'IO::File' && $r->{fh}->opened, 1, 'Get returns a file handle' );
}

sub test03 {
    my $upl = Koha::Upload->new({ tmp => 1 }); #temporary
    my $cgi= $upl->cgi;
    is( $upl->count, 1, 'Upload 3 includes one temporary file' );
    my $r = $upl->get({ id => $upl->result });
    is( $r->{uploadcategorycode} =~ /_upload$/, 1, 'Check category temp file' );
}

sub test04 { # Fail on a file already there
    my $upl = Koha::Upload->new({
        category => $uploads->[$current_upload]->[0]->{cat},
    });
    my $cgi= $upl->cgi;
    is( $upl->count, 0, 'Upload 4 failed as expected' );
    is( $upl->result, undef, 'Result is undefined' );
    my $e = $upl->err;
    is( $e->{file2}, 1, "Errcode 1 [already exists] reported" );
}

sub test05 { # add temporary file with same name and contents, delete it
    my $upl = Koha::Upload->new({ tmp => 1 });
    my $cgi= $upl->cgi;
    is( $upl->count, 1, 'Upload 5 adds duplicate temporary file' );
    my $id = $upl->result;
    my $r = $upl->get({ id => $id });
    my @d = $upl->delete({ id => $id });
    is( $d[0], $r->{name}, 'Delete successful' );
    is( -e $r->{path}? 1: 0, 0, 'File no longer found after delete' );
    is( scalar $upl->get({ id => $id }), undef, 'Record also gone' );
    is( $upl->delete({ id => $id }), undef, 'Repeated delete failed' );
}

sub test06 { #some extra tests for get
    my $upl = Koha::Upload->new({ public => 1 });
    my @rec = $upl->get({ term => 'file' });
    is( @rec, 1, 'Get returns only one public result (file3)' );
    $upl = Koha::Upload->new; # public == 0
    @rec = $upl->get({ term => 'file' });
    is( @rec, 4, 'Get returns now four results' );
}

sub test07 { #simple test for httpheaders and getCategories
    my @hdrs = Koha::Upload->httpheaders('does_not_matter_yet');
    is( @hdrs == 4 && $hdrs[1] =~ /application\/octet-stream/, 1, 'Simple test for httpheaders');
    my $builder = t::lib::TestBuilder->new;
    $builder->build({ source => 'AuthorisedValue', value => { category => 'UPLOAD', authorised_value => 'HAVE_AT_LEAST_ONE', lib => 'Hi there' } });
    my $cat = Koha::Upload->getCategories;
    is( @$cat >= 1, 1, 'getCategories returned at least one category' );
}

sub test08 { # allows_add_by
    my $builder = t::lib::TestBuilder->new;
    my $patron = $builder->build({
        source => 'Borrower',
        value  => { flags => 0 }, #no permissions
    });
    my $patronid = $patron->{borrowernumber};
    is( Koha::Upload->allows_add_by( $patron->{userid} ),
        undef, 'Patron is not allowed to do anything' );

    # add some permissions: edit_catalogue
    my $fl = 2**9; # edit_catalogue
    $schema->resultset('Borrower')->find( $patronid )->update({ flags => $fl });
    is( Koha::Upload->allows_add_by( $patron->{userid} ),
        undef, 'Patron is still not allowed to add uploaded files' );

    # replace flags by all tools
    $fl = 2**13; # tools
    $schema->resultset('Borrower')->find( $patronid )->update({ flags => $fl });
    is( Koha::Upload->allows_add_by( $patron->{userid} ),
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
    is( Koha::Upload->allows_add_by( $patron->{userid} ),
        1, 'Patron is still allowed to add uploaded files' );
}

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
