#!/usr/bin/perl

# Copyright 2012 C & P Bibliography Services
#
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

use Modern::Perl;
use utf8;
use Test::More;
use Test::WWW::Mechanize;
use Data::Dumper;
use XML::Simple;
use JSON;
use File::Basename;
use File::Spec;
use POSIX;
use Encode;

my $testdir = File::Spec->rel2abs( dirname(__FILE__) );

my $koha_conf = $ENV{KOHA_CONF};
my $xml       = XMLin($koha_conf);

use C4::Context;
my $marcflavour = C4::Context->preference('marcflavour') || 'MARC21';

# For the purpose of this test, we can reasonably take MARC21 and NORMARC to be the same
my $file =
  $marcflavour eq 'UNIMARC'
  ? "$testdir/data/unimarcutf8record.mrc"
  : "$testdir/data/marc21utf8record.mrc";

my $user     = $ENV{KOHA_USER} || $xml->{config}->{user};
my $password = $ENV{KOHA_PASS} || $xml->{config}->{pass};
my $intranet = $ENV{KOHA_INTRANET_URL};
my $opac     = $ENV{KOHA_OPAC_URL};

my $zebra_on = ProgProcesses('zebrasrv');
my $indexer_on = ProgProcesses('koha-index');

if ($zebra_on < 2) {
    plan skip_all => "Tests skip. You must start Zebra Server to do those tests\n";
}

if ($indexer_on < 2) {
    plan skip_all => "Tests skip. You must start Zebra Background indexer to do those tests\n";
}

if (not defined $intranet) {
   plan skip_all => "Tests skip. You must set env. variable KOHA_INTRANET_URL to do tests\n";
}
if (not defined $opac) {
   plan skip_all => "Tests skip. You must set env. variable KOHA_INTRANET_URL to do tests\n";
}

$intranet =~ s#/$##;
$opac     =~ s#/$##;

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
    "$intranet/cgi-bin/koha/tools/upload-file.pl",
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
        "$intranet/cgi-bin/koha/tools/background-job-progress.pl?jobID=$jobID",
        "get job progress"
    );
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
        }
    },
    'stage MARC'
);

$agent->follow_link_ok( { text => 'Manage staged records' }, 'view batch' );


$agent->form_number(5);
$agent->field( 'framework', '' );
$agent->click_ok( 'mainformsubmit', "imported records into catalog" );
my $webpage = $agent->{content};

$webpage =~ /(.*<title>.*?)(\d{1,})(.*<\/title>)/sx;
my $id_batch = $2;

#Wait the indexer
sleep 35;

# -------------------------------------------------- TEST ON OPAC


$agent->get_ok( "$opac" , "got opac");
$agent->form_name('searchform');
$agent->field( 'q',   'deuteros' );
$agent->field( 'idx',   '' );
$agent->click( );

# ok( $agent->success, 'uploaded file' );

my $text = $agent->text() ;

#Tests on UTF-8

ok ( ( length(Encode::encode_utf8($text)) != length($text) ) , 'UTF-8 are multi-byte. Goog') ;
ok ($text =~  m/学協会. μμ/, 'UTF-8 chars are correctly present. Good');



#-------------------------------------------------- REVERT

$agent->get_ok( "$intranet/cgi-bin/koha/tools/manage-marc-import.pl", 'view and clean batch' );
$agent->form_name('clean_batch_'.$id_batch);
$agent->click();

done_testing();

sub ProgProcesses {
   return scalar grep /$_[0]/, (split /\n/, `ps -aef`);
}
