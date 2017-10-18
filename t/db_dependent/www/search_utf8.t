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

use utf8;
use Test::More; #See plan tests => \d+ below
use Test::WWW::Mechanize;
use Data::Dumper;
use XML::Simple;
use JSON;
use File::Basename;
use File::Path;
use File::Spec;
use File::Temp qw/ tempdir /;
use POSIX;
use Encode;
use URI::Escape;

use C4::Context;

my $testdir = File::Spec->rel2abs( dirname(__FILE__) );
# global variables that will be used when forking
our $zebra_pid;
our $indexer_pid;
our $datadir = tempdir();;

my $koha_conf = $ENV{KOHA_CONF};
my $xml       = XMLin($koha_conf);

my $marcflavour = C4::Context->preference('marcflavour') || 'MARC21';

# For the purpose of this test, we can reasonably take MARC21 and NORMARC to be the same
my $file1 =
  $marcflavour eq 'UNIMARC'
  ? "$testdir/data/unimarcutf8record.mrc"
  : "$testdir/data/marc21utf8record.mrc";

my $file2 =
  $marcflavour eq 'UNIMARC'
  ? "$testdir/data/unimarclatin1utf8rec.mrc"
  : "$testdir/data/marc21latin1utf8rec.mrc";

my $user     = $ENV{KOHA_USER} || $xml->{config}->{user};
my $password = $ENV{KOHA_PASS} || $xml->{config}->{pass};
my $intranet = $ENV{KOHA_INTRANET_URL};
my $opac     = $ENV{KOHA_OPAC_URL};


# test KOHA_INTRANET_URL is set
if ( not defined $intranet ) {
   plan skip_all => "Tests skip. You must set env. variable KOHA_INTRANET_URL to do tests\n";
}
# test KOHA_OPAC_URL is set
elsif ( not defined $opac ) {
   plan skip_all => "Tests skip. You must set env. variable KOHA_OPAC_URL to do tests\n";
}
else {
    plan tests => 66;
}

$intranet =~ s#/$##;
$opac     =~ s#/$##;

#-------------------------------- Test with greek and corean chars;
# launch the zebra saerch process
launch_zebra( $datadir, $koha_conf );
if ( not defined $zebra_pid ) {
    plan skip_all => "Tests skip. Error starting Zebra Server to do those tests\n";
}
# launch the zebra index process
launch_indexer( );
if ( not defined $indexer_pid ) {
    plan skip_all => "Tests skip. Error starting the indexer daemon to do those tests\n";
}

my $utf8_reg1 = qr/学協会. μμ/;
test_search($file1,'Αθήνα', 'deuteros', $utf8_reg1);


#--------------------------------- Test with only utf-8 chars in the latin-1 range;
launch_zebra( $datadir, $koha_conf );
if ( not defined $zebra_pid ) {
    plan skip_all => "Tests skip. Error starting Zebra Server to do those tests\n";
}
launch_indexer( );
if ( not defined $indexer_pid ) {
    plan skip_all => "Tests skip. Error starting the indexer daemon to do those tests\n";
}
my $utf8_reg2 = qr/Tòmas/;
test_search($file2,'Ramòn', 'Tòmas',$utf8_reg2);


sub test_search{
    #Params
    my $file = $_[0];
    my $publisher = $_[1];
    my $search_key = $_[2];
    my $utf8_reg = $_[3];

    my $agent = Test::WWW::Mechanize->new( autocheck => 1 );
    my $jsonresponse;

    # -------------------------------------------------- LOAD RECORD

    $agent->get_ok( "$intranet/cgi-bin/koha/mainpage.pl", 'connect to intranet' );
    $agent->form_name('loginform');
    $agent->field( 'password', $password );
    $agent->field( 'userid',   $user );
    $agent->field( 'branch',   '' );
    $agent->click_ok( '', 'login to staff client' );

    $agent->get_ok( "$intranet/cgi-bin/koha/mainpage.pl", 'load main page' );

    $agent->follow_link_ok( { url_regex => qr/tools-home/i }, 'open tools module' );
    $agent->follow_link_ok( { text => 'Stage MARC records for import' },
        'go to stage MARC' );

    $agent->post(
        "$intranet/cgi-bin/koha/tools/upload-file.pl?temp=1",
        [ 'fileToUpload' => [$file], ],
        'Content_Type' => 'form-data',
    );
    ok( $agent->success, 'uploaded file' );

    $jsonresponse = decode_json $agent->content();
    is( $jsonresponse->{'status'}, 'done', 'upload succeeded' );
    my $fileid = $jsonresponse->{'fileid'};

    $agent->get_ok( "$intranet/cgi-bin/koha/tools/stage-marc-import.pl",
        'reopen stage MARC page' );
    $agent->submit_form_ok(
        {
            form_number => 5,
            fields      => {
                'uploadedfileid'  => $fileid,
                'nomatch_action'  => 'create_new',
                'overlay_action'  => 'replace',
                'item_action'     => 'always_add',
                'matcher'         => '',
                'comments'        => '',
                'encoding'        => 'utf8',
                'parse_items'     => '1',
                'runinbackground' => '1',
                'record_type'     => 'biblio'
            }
        },
        'stage MARC'
    );

    $jsonresponse = decode_json $agent->content();
    my $jobID = $jsonresponse->{'jobID'};
    ok( $jobID, 'have job ID' );

    my $completed = 0;

    # if we haven't completed the batch in two minutes, it's not happening
    for my $counter ( 1 .. 24 ) {
        $agent->get(
            "$intranet/cgi-bin/koha/tools/background-job-progress.pl?jobID=$jobID"
        ); # get job progress
        $jsonresponse = decode_json $agent->content();
        if ( $jsonresponse->{'job_status'} eq 'completed' ) {
            $completed = 1;
            last;
        }
        warn(
            (
                $jsonresponse->{'job_size'}
                ? floor(
                    100 * $jsonresponse->{'progress'} / $jsonresponse->{'job_size'}
                  )
                : '100'
            )
            . "% completed"
        );
        sleep 5;
    }
    is( $jsonresponse->{'job_status'}, 'completed', 'job was completed' );

    $agent->get_ok(
        "$intranet/cgi-bin/koha/tools/stage-marc-import.pl",
        'reopen stage MARC page at end of upload'
    );
    $agent->submit_form_ok(
        {
            form_number => 5,
            fields      => {
                'uploadedfileid'  => $fileid,
                'nomatch_action'  => 'create_new',
                'overlay_action'  => 'replace',
                'item_action'     => 'always_add',
                'matcher'         => '1',
                'comments'        => '',
                'encoding'        => 'utf8',
                'parse_items'     => '1',
                'runinbackground' => '1',
                'completedJobID'  => $jobID,
                'record_type'     => 'biblio'
            }
        },
        'stage MARC'
    );

    $agent->follow_link_ok( { text => 'Manage staged records' }, 'view batch' );


    $agent->form_number(6);
    $agent->field( 'framework', '' );
    $agent->click_ok( 'mainformsubmit', "imported records into catalog" );
    my $webpage = $agent->{content};

    $webpage =~ /(.*<title>.*?)(\d{1,})(.*<\/title>)/sx;
    my $id_batch = $2;
    my $id_bib_number = GetBiblionumberFromImport($id_batch);

    # wait enough time for the indexer
    sleep 10;

    # --------------------------------- TEST INTRANET SEARCH


    $agent->get_ok( "$intranet/cgi-bin/koha/catalogue/search.pl" , "got search on intranet");
    $agent->form_number(5);
    $agent->field('idx', 'kw');
    $agent->field('q', $search_key);
    $agent->click();
    my $intra_text = $agent->text() ;
    like( $intra_text, qr|Publisher: $publisher|, );

    $agent->get_ok( "$intranet/cgi-bin/koha/catalogue/search.pl" , "got search on intranet");
    $agent->form_number(5);
    $agent->field('idx', 'kw');
    $agent->field('q', $publisher);
    $agent->click();
    $intra_text = $agent->text();

    like( $intra_text, qr|Publisher: $publisher|, );
    my $expected_base = q|search.pl\?idx=kw&q=| . uri_escape_utf8( $publisher );
    $agent->base_like(qr|$expected_base|, );

    ok ( ( length(Encode::encode('UTF-8', $intra_text)) != length($intra_text) ) , 'UTF-8 are multi-byte. Good') ;
    ok ($intra_text =~  $utf8_reg, 'UTF-8 chars are correctly present. Good');
    # -------------------------------------------------- TEST ON OPAC

    $agent->get_ok( "$opac" , "got opac");
    $agent->form_name('searchform');
    $agent->field( 'q',   $search_key );
    $agent->field( 'idx',   '' );
    $agent->click( );
    my $opac_text = $agent->text() ;
    like( $opac_text, qr|Publisher: $publisher|, );

    $agent->get_ok( "$opac" , "got opac");
    $agent->form_name('searchform');
    $agent->field('q', $publisher);
    $agent->field( 'idx',   '' );
    $agent->click();
    $opac_text = $agent->text();

    like( $opac_text, qr|Publisher: $publisher|, );
    $expected_base = q|opac-search.pl\?(idx=&)?q=| . uri_escape_utf8( $publisher );
    $agent->base_like(qr|$expected_base|, );
    # Test added on BZ 14909 in addition to making the empty idx= optional
    # in the previous regex
    $agent->base_unlike( qr|idx=\w+|, 'Base does not contain an idx' );


    ok ( ( length(Encode::encode('UTF-8', $opac_text)) != length($opac_text) ) , 'UTF-8 are multi-byte. Good') ;
    ok ($opac_text =~  $utf8_reg, 'UTF-8 chars are correctly present. Good');

    #-------------------------------------------------- REVERT

    $agent->get_ok( "$intranet/cgi-bin/koha/tools/manage-marc-import.pl", 'view and clean batch' );
    $agent->form_name('clean_batch_'.$id_batch);
    $agent->click();
    $agent->get_ok( "$intranet/cgi-bin/koha/catalogue/detail.pl?biblionumber=$id_bib_number", 'biblio on intranet' );
    $agent->get_ok( "$intranet/cgi-bin/koha/cataloguing/addbiblio.pl?op=delete&biblionumber=$id_bib_number", 'biblio deleted' );

    # clean
    cleanup();
}


# function that launches the zebra daemon
sub launch_zebra {

    my ( $datadir, $koha_conf ) = @_;

    $zebra_pid = fork();
    if ( $zebra_pid == 0 ) {
        exec("zebrasrv -f $koha_conf -v none,request -l $datadir/zebra.log");
        exit;
    }
    sleep( 1 );
}

sub launch_indexer {

    my $rootdir       = dirname(__FILE__) . '/../../../';
    my $rebuild_zebra = "$rootdir/misc/migration_tools/rebuild_zebra.pl";

    $indexer_pid = fork();

    if ( $indexer_pid == 0 ) {
        exec("$rebuild_zebra -daemon -sleep 5");
        exit;
    }
    sleep( 1 );
}

sub cleanup {

    kill 9, $zebra_pid   if defined $zebra_pid;
    kill 9, $indexer_pid if defined $indexer_pid;
    # Clean up the Zebra files since the child process was just shot
    rmtree $datadir;

}

sub GetBiblionumberFromImport{
    my ( $batch_id) = @_;
    use C4::ImportBatch;
    my $data = C4::ImportBatch::GetImportRecordsRange($batch_id, '', '', undef,
                    { order_by => 'import_record_id', order_by_direction => 'DESC' });
    my $biblionumber = $data->[0]->{'matched_biblionumber'};

    return $biblionumber;
}

END {
    cleanup();
};

