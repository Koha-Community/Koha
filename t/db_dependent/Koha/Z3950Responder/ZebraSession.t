#!/usr/bin/perl

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;
use Test::MockObject;
use t::lib::Mocks;

use ZOOM;

BEGIN {
    use_ok('Koha::Z3950Responder');
    use_ok('Koha::Z3950Responder::ZebraSession');
}

our $child;

subtest 'test_search' => sub {

    plan tests => 8;

    t::lib::Mocks::mock_preference( 'SearchEngine', 'Zebra' );

    my $marc_record_1 = MARC::Record->new();
    $marc_record_1->leader('     cam  22      a 4500');
    $marc_record_1->append_fields(
        MARC::Field->new( '001', '123' ),
        MARC::Field->new( '020', '', '', a => '1-56619-909-3' ),
        MARC::Field->new( '100', '', '', a => 'Author 1' ),
        MARC::Field->new( '110', '', '', a => 'Corp Author' ),
        MARC::Field->new( '210', '', '', a => 'Title 1' ),
        MARC::Field->new( '245', '', '', a => 'Title:', b => 'first record' ),
        MARC::Field->new( '999', '', '', c => '1234567' ),
    );

    my $marc_record_2 = MARC::Record->new();
    $marc_record_2->leader('     cam  22      a 4500');
    $marc_record_2->append_fields(
        MARC::Field->new( '001', '234' ),
        MARC::Field->new( '020', '', '', a => '1-56619-909-3' ),
        MARC::Field->new( '100', '', '', a => 'Author 2' ),
        MARC::Field->new( '110', '', '', a => 'Corp Author' ),
        MARC::Field->new( '210', '', '', a => 'Title 2' ),
        MARC::Field->new( '245', '', '', a => 'Title:', b => 'second record' ),
        MARC::Field->new( '999', '', '', c => '1234567' ),
    );

    my $context = Test::MockModule->new('C4::Context');
    $context->mock(
        'Zconn',
        sub {
            my $Zconn = Test::MockObject->new();
            $Zconn->mock( 'connect', sub { } );
            $Zconn->mock(
                'err_code',
                sub {
                    return 0;
                }
            );
            $Zconn->mock(
                'search_pqf',
                sub {
                    my $results = Test::MockObject->new();
                    $results->mock(
                        'size',
                        sub {
                            return 2;
                        }
                    );
                    $results->mock(
                        'record_immediate',
                        sub {
                            my ( $self, $index ) = @_;

                            my $record;
                            if ( $index == 0 ) {
                                $record = $marc_record_1;
                            } elsif ( $index == 1 ) {
                                $record = $marc_record_2;
                            }
                            my $Zrecord = Test::MockObject->new();
                            $Zrecord->mock(
                                'raw',
                                sub {
                                    return $record->as_xml();
                                }
                            );
                            return $Zrecord;
                        }
                    );
                    $results->mock( 'records', sub { } );
                    $results->mock( 'destroy', sub { } );
                }
            );
        }
    );

    $child = fork();
    if ( $child == 0 ) {
        my @yaz_options = ('@:42111');
        my $z           = Koha::Z3950Responder->new(
            {
                config_dir  => '',
                yaz_options => [@yaz_options]
            }
        );
        $z->start();
        exit;
    }
    sleep(10);    # Just a try to see if it fixes Jenkins

    my $o = ZOOM::Options->new();
    $o->option( preferredRecordSyntax => 'xml' );
    $o->option( elementSetName        => 'marcxml' );
    $o->option( databaseName          => 'biblios' );

    my $Zconn = ZOOM::Connection->create($o);
    ok( $Zconn, 'ZOOM connection created' );

    $Zconn->connect( '127.0.0.1:42111', 0 );
    is( $Zconn->errcode(), 0, 'Connection is successful: ' . $Zconn->errmsg() );

    my $rs = $Zconn->search_pqf('@and @attr 1=1 author @attr 1=4 title');
    is( $Zconn->errcode(), 0, 'Search is successful: ' . $Zconn->errmsg() );

    is( $rs->size(), 2, 'Two results returned' );

    my $returned1 = MARC::Record->new_from_xml( $rs->record(0)->raw(), 'UTF-8' );
    ok( $returned1, 'Record 1 returned as MARCXML' );
    is( $returned1->as_xml, $marc_record_1->as_xml, 'Record 1 returned properly' );

    my $returned2 = MARC::Record->new_from_xml( $rs->record(1)->raw(), 'UTF-8' );
    ok( $returned2, 'Record 2 returned as MARCXML' );
    is( $returned2->as_xml, $marc_record_2->as_xml, 'Record 2 returned properly' );

    cleanup();
};

sub cleanup {
    if ($child) {
        kill 9, $child;
        $child = undef;
    }
}

# Fall back to make sure that the Zebra process
# and files get cleaned up
END {
    cleanup();
}
