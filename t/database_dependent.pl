#!/usr/bin/perl

use warnings;
use strict;

=head2



=cut

use C4::Context;
use C4::Installer;
use C4::Languages;
use Data::Dumper;
use Test::More;

use lib q( . .. );

use Test::Class::Load qw ( . ); # run from the t directory

create_test_database();

start_zebrasrv();
start_zebraqueue_daemon();

Test::Class->runtests;

stop_zebraqueue_daemon();
stop_zebrasrv();

# stop_zebrasrv();

=head3 create_test_database

  sets up the test database.

=cut

sub create_test_database {

    diag 'creating testing datbase...';
    my $installer = C4::Installer->new() or die 'unable to create new installer';
    # warn Data::Dumper->Dump( [ $installer ], [ 'installer' ] );
    my $all_languages = getAllLanguages();
    my $error = $installer->load_db_schema();
    die "unable to load_db_schema: $error" if ( $error );
    my $list = $installer->sql_file_list('en', 'marc21', { optional  => 1,
                                                           mandatory => 1 } );
    my ($fwk_language, $installed_list) = $installer->load_sql_in_order($all_languages, @$list);
    $installer->set_version_syspref();
    $installer->set_marcflavour_syspref('MARC21');
    $installer->set_indexing_engine(0);
    diag 'database created.'
}


=head3 start_zebrasrv

  This method deletes and reinitializes the zebra database directory,
  and then spans off a zebra server.

=cut

sub start_zebrasrv {

    stop_zebrasrv();
    diag 'cleaning zebrasrv...';

    foreach my $zebra_server ( qw( biblioserver authorityserver ) ) {
        my $zebra_config  = C4::Context->zebraconfig($zebra_server)->{'config'};
        my $zebra_db_dir  = C4::Context->zebraconfig($zebra_server)->{'directory'};
        foreach my $zebra_db_name ( qw( biblios authorities ) ) {
            my $command = "zebraidx -c $zebra_config -d $zebra_db_name init";
            my $return = system( $command . ' > /dev/null 2>&1' );
            if ( $return != 0 ) {
                diag( "command '$command' died with value: " . $? >> 8 );
            }
            
            $command = "zebraidx -c $zebra_config -d $zebra_db_name create $zebra_db_name";
            diag $command;
            $return = system( $command . ' > /dev/null 2>&1' );
            if ( $return != 0 ) {
                diag( "command '$command' died with value: " . $? >> 8 );
            }
        }
    }
    
    diag 'starting zebrasrv...';

    my $pidfile = File::Spec->catdir( C4::Context->config("logdir"), 'zebra.pid' );
    my $command = sprintf( 'zebrasrv -f %s -D -l %s -p %s',
                           $ENV{'KOHA_CONF'},
                           File::Spec->catdir( C4::Context->config("logdir"), 'zebra.log' ),
                           $pidfile,
                      );
    diag $command;
    my $output = qx( $command );
    if ( $output ) {
        diag $output;
    }
    if ( -e $pidfile, 'pidfile exists' ) {
        diag 'zebrasrv started.';
    } else {
        die 'unable to start zebrasrv';
    }
    return $output;
}

=head3 stop_zebrasrv

  using the PID file for the zebra server, send it a TERM signal with
  "kill". We can't tell if the process actually dies or not.

=cut

sub stop_zebrasrv {

    my $pidfile = File::Spec->catdir( C4::Context->config("logdir"), 'zebra.pid' );
    if ( -e $pidfile ) {
        open( my $pidh, '<', $pidfile )
          or return;
        if ( defined $pidh ) {
            my ( $pid ) = <$pidh> or return;
            close $pidh;
            my $killed = kill 15, $pid; # 15 is TERM
            if ( $killed != 1 ) {
                warn "unable to kill zebrasrv with pid: $pid";
            }
        }
    }
}


=head3 start_zebraqueue_daemon

  kick off a zebraqueue_daemon.pl process.

=cut

sub start_zebraqueue_daemon {

    my $command = q(bin/koha-zebraqueue-ctl.sh start);
    diag $command;
    my $started = system( $command );
    diag "started: $started";
    
#     my $command = sprintf( 'KOHA_CONF=%s ../misc/bin/zebraqueue_daemon.pl > %s 2>&1 &',
#                            $ENV{'KOHA_CONF'},
#                            'zebra.log',
#                       );
#     diag $command;
#     my $queue = system( $command );
#     diag "queue: $queue";

}

=head3 stop_zebraqueue_daemon


=cut

sub stop_zebraqueue_daemon {

    my $command = q(bin/koha-zebraqueue-ctl.sh stop);
    diag $command;
    my $started = system( $command );
    diag "started: $started";

}
