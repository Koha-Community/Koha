package t::lib::Mocks::Zebra;

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
use Test::More;
use File::Basename qw(dirname );
use File::Temp qw( tempdir );
use File::Path qw( rmtree );
use JSON qw( decode_json );
use C4::ImportBatch;
use Koha::BackgroundJobs;

=head1 NAME

t::lib::Mocks::Zebra - Trying to mock zebra index

IMPORTANT NOTE: This module is not working as you may think it could work.

It will effectively create a new koha-conf.xml file in a temporary directory with zebra config files correctly.
So it will not affect the koha-conf used by plack (and so the UI).

If you pass koha_conf to the constructor the usual zebra db will be used, otherwise a new koha-conf.xml file will be generated
and the usual zebra db will not be affected. However you must pass $ENV{KOHA_CONF} if you want to test the UI.

=cut


sub new {
    my ( $class, $params ) = @_;

    my $marcflavour = $params->{marcflavour} ? lc($params->{marcflavour}) : 'marc21';
    my $koha_conf = $params->{koha_conf};

    my $datadir = tempdir();
    my $zebra_db_dir;
    unless ( $koha_conf ) {
        system(dirname(__FILE__) . "/../../db_dependent/zebra_config.pl $datadir $marcflavour");

        Koha::Caches->get_instance('config')->flush_all;
        $koha_conf = "$datadir/etc/koha-conf.xml";
        my $context = C4::Context->new($koha_conf);
        $context->set_context();
        $zebra_db_dir = "$datadir/etc/koha/zebradb/";
    } else {
        $koha_conf = $ENV{KOHA_CONF};
        $zebra_db_dir = dirname($koha_conf);
    }

    my $self = {
        datadir   => $datadir,
        koha_conf => $koha_conf,
        zebra_db_dir => $zebra_db_dir,
        intranet  => $params->{intranet},
        opac      => $params->{opac}
    };

    return bless $self, $class;
}

# function that launches the zebra daemon
sub launch_zebra {
    my ( $self ) = @_;

    my $datadir = $self->{datadir};
    my $koha_conf = $self->{koha_conf};

    unlink("$datadir/zebra.log");
    my $zebra_pid = fork();
    if ( $zebra_pid == 0 ) {
        exec("zebrasrv -f $koha_conf -v none,request -l $datadir/zebra.log");
        exit;
    }
    sleep( 1 );
    $self->{zebra_pid} = $zebra_pid;
}

sub launch_indexer {
    my ($self) = @_;
    my $rootdir       = dirname(__FILE__) . '/../../../';
    my $rebuild_zebra = "$rootdir/misc/migration_tools/rebuild_zebra.pl";

    my $indexer_pid = fork();

    if ( $indexer_pid == 0 ) {
        exec("$rebuild_zebra -daemon -sleep 5");
        exit;
    }
    sleep( 1 );
    $self->{indexer_pid} = $indexer_pid;
}

sub load_records {
    my ( $self, $marc_dir, $marc_format, $record_type, $init ) = @_;

    my $datadir = $self->{datadir};
    my $zebra_cfg = $self->{zebra_db_dir}
      . ( $record_type eq 'biblios'
        ? '/zebra-biblios-dom.cfg'
        : '/zebra-authorities-dom.cfg' );

    my @cmds;
    push @cmds, "zebraidx -c $zebra_cfg  -v none,fatal -g $marc_format -d $record_type init" if $init;
    push @cmds, "zebraidx -c $zebra_cfg  -v none,fatal -g $marc_format -d $record_type update $marc_dir";
    push @cmds, "zebraidx -c $zebra_cfg  -v none,fatal -g $marc_format -d $record_type commit";

    for my $cmd ( @cmds ) {
        system($cmd);
    }
}

sub load_records_ui {
    my ( $self, $file ) = @_;
    my $jsonresponse;
    my $cgi_root = $self->{intranet} . '/cgi-bin/koha';

    our $agent = Test::WWW::Mechanize->new( autocheck => 1 );
    $agent->get_ok( "$cgi_root/mainpage.pl", 'connect to intranet' );
    $agent->form_name('loginform');
    $agent->field( 'userid', $ENV{KOHA_PASS} );
    $agent->field( 'password', $ENV{KOHA_USER} );
    $agent->field( 'branch',   '' );
    $agent->click_ok( '', 'login to staff interface' );

    $agent->get_ok( "$cgi_root/mainpage.pl", 'load main page' );

    $agent->follow_link_ok( { url_regex => qr/cataloging-home/i }, 'open caaloging module' );
    $agent->follow_link_ok( { text => 'Stage records for import' },
        'go to stage MARC' );

    $agent->post(
        "$cgi_root/tools/upload-file.pl?temp=1",
        [ 'fileToUpload' => [$file], ],
        'Content_Type' => 'form-data',
    );
    ok( $agent->success, 'uploaded file' );

    $jsonresponse = decode_json $agent->content();
    is( $jsonresponse->{'status'}, 'done', 'upload succeeded' );
    my $fileid = $jsonresponse->{'fileid'};

    $agent->get_ok( "$cgi_root/tools/stage-marc-import.pl",
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
                'record_type'     => 'biblio'
            }
        },
        'stage MARC'
    );

    sleep(1);
    # FIXME - This if fragile and can fail if there is a race condition
    my $job = Koha::BackgroundJobs->search({ type => 'stage_marc_for_import' })->last;
    my $i;
    while ( $job->discard_changes->status ne 'finished' ) {
        sleep(1);
        last if ++$i > 10;
    }
    is ( $job->status, 'finished', 'job is finished' );

    $job->discard_changes;
    my $import_batch_id = $job->report->{import_batch_id};

    $agent->get_ok(
        "$cgi_root/tools/manage-marc-import.pl?import_batch_id=$import_batch_id",
    );

    $agent->form_number(6);
    $agent->field( 'framework', '' );
    $agent->click_ok( 'mainformsubmit', "imported records into catalog" );

    # wait enough time for the indexer
    sleep 10;

    return $import_batch_id;

}

sub clean_records {
    my ( $self, $batch_id ) = @_;

    my $agent = Test::WWW::Mechanize->new( autocheck => 1 );
    my $cgi_root = $self->{intranet} . '/cgi-bin/koha';

    my $data = C4::ImportBatch::GetImportRecordsRange($batch_id, '', '', undef,
                    { order_by => 'import_record_id', order_by_direction => 'DESC' });
    my $biblionumber = $data->[0]->{'matched_biblionumber'};

    $agent->get_ok( "$cgi_root/tools/manage-marc-import.pl", 'view and clean batch' );
    $agent->form_name('clean_batch_'.$batch_id);
    $agent->click();
    $agent->get_ok( "$cgi_root/catalogue/detail.pl?biblionumber=$biblionumber", 'biblio on intranet' );
    $agent->get_ok( "$cgi_root/cataloguing/addbiblio.pl?op=delete&biblionumber=$biblionumber", 'biblio deleted' );

}

sub cleanup {
    my ( $self ) = @_;
    kill 9, $self->{zebra_pid}   if defined $self->{zebra_pid};
    kill 9, $self->{indexer_pid} if defined $self->{indexer_pid};
    # Clean up the Zebra files since the child process was just shot
    rmtree $self->{datadir};
}

1;
