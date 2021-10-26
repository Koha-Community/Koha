package t::lib::Mocks::Zebra;

use Modern::Perl;
use Test::More;
use File::Basename qw(dirname );
use File::Temp qw( tempdir );
use File::Path qw( rmtree );
use JSON qw( decode_json );
use C4::ImportBatch;

sub new {
    my ( $class, $params ) = @_;

    my $datadir = tempdir();;
    my $self = {
        datadir   => $datadir,
        koha_conf => $params->{koha_conf},
        user      => $params->{user},
        password  => $params->{password},
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
    my ( $self, $file ) = @_;
    my $jsonresponse;
    my $cgi_root = $self->{intranet} . '/cgi-bin/koha';

    our $agent = Test::WWW::Mechanize->new( autocheck => 1 );
    $agent->get_ok( "$cgi_root/mainpage.pl", 'connect to intranet' );
    $agent->form_name('loginform');
    $agent->field( 'password', $self->{password} );
    $agent->field( 'userid',   $self->{user} );
    $agent->field( 'branch',   '' );
    $agent->click_ok( '', 'login to staff interface' );

    $agent->get_ok( "$cgi_root/mainpage.pl", 'load main page' );

    $agent->follow_link_ok( { url_regex => qr/tools-home/i }, 'open tools module' );
    $agent->follow_link_ok( { text => 'Stage MARC records for import' },
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
            "$cgi_root/tools/background-job-progress.pl?jobID=$jobID"
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
        "$cgi_root/tools/stage-marc-import.pl",
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
    my $batch_id = $2;

    # wait enough time for the indexer
    sleep 10;

    return $batch_id;

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
