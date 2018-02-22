#!/usr/bin/perl

# Copyright 2014 Rijksmuseum
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use FindBin;
use Test::More tests => 3;
use Test::Warn;

use C4::Breeding;
use Koha::XSLT_Handler;

#Main object of this unit test is the Breeding module and its subroutines
#A start has been made to define tests for subroutines of Z3950Search.
#These subroutines are actually internal, but these tests may pave the way for
#a more comprehensive test of Z3950Search itself.
#TODO
#Furthermore, we need additional tests for:
#Z3950SearchAuth, BreedingSearch, ImportBreedingAuth

#Group 1: testing _build_query and _translate_query (part of Z3950Search)
subtest '_build_query' => sub {
    plan tests => 12;
    test_build_translate_query();
};
#Group 2: testing _create_connection (part of Z3950Search)
subtest '_create_connection' => sub {
    plan tests => 5;
    test_create_connection();
};
#Group 3: testing _do_xslt_proc (part of Z3950Search)
subtest '_do_xslt_proc' => sub {
    plan tests => 6;
    test_do_xslt();
};

#-------------------------------------------------------------------------------

sub test_build_translate_query {
    my $str;
    #First pass no parameters
    my @queries= C4::Breeding::_build_query( {} );
    is( defined $queries[0] && $queries[0] eq '' && defined $queries[1] &&
        $queries[1] eq '', 1, '_build_query gets no parameters');

    #We now pass one parameter
    my $pars1= { isbn => '234567' };
    @queries= C4::Breeding::_build_query( $pars1 );
    #Passed only one par: zquery should start with @attr 1=\d+
    is( $queries[0] =~ /^\@attr 1=\d+/, 1, 'Z39.50 query with one parameter');
    $str=$pars1->{isbn};
    #Find back ISBN?
    is( $queries[0] =~ /$str/, 1, 'First Z39.50 query contains ISBN');
    #SRU query should contain translation for ISBN
    my $server= { sru_fields => 'isbn=ie-es-bee-en,srchany=overal' };
    my $squery= C4::Breeding::_translate_query( $server, $queries[1] );
    is( $squery =~ /ie-es-bee-en/, 1, 'SRU query has translated ISBN index');
    #Another try with fallback to any
    $server= { sru_fields => 'srchany=overal' };
    $squery= C4::Breeding::_translate_query( $server, $queries[1] );
    is( $squery =~ /overal/, 1, 'SRU query fallback to translated any');
    #Another try even without any
    $server= { sru_fields => 'this,is,bad,input' };
    $squery= C4::Breeding::_translate_query( $server, $queries[1] );
    is( $squery =~ /$str/ && $squery !~ /=/, 1, 'SRU query without indexes');

    #We now pass two parameters
    my $pars2= { isbn => '123456', title => 'You should read this.' };
    @queries= C4::Breeding::_build_query( $pars2 );
    #The Z39.50 query should start with @and (we passed two pars)
    is( $queries[0] =~ /^\@and/, 1, 'Second Z39.50 query starts with @and');
    #We should also find two @attr 1=\d+
    my @matches= $queries[0] =~ /\@attr 1=\d+/g;
    is( @matches == 2, 1, 'Second Z39.50 query includes two @attr 1=');
    #We should find text of both parameters in the query
    $str= $pars2->{isbn};
    is( $queries[0] =~ /\"$str\"/, 1,
        'Second query contains ISBN enclosed by double quotes');
    $str= $pars2->{title};
    is( $queries[0] =~ /\"$str\"/, 1,
        'Second query contains title enclosed by double quotes');

    #SRU revisited
    $server= { sru_fields => 'isbn=nb,title=dc.title,srchany=overal' };
    $squery= C4::Breeding::_translate_query( $server, $queries[1] );
    is ( $squery =~ /dc.title/ && $squery =~ / and / &&
        $squery =~ /nb=/, 1, 'SRU query with two parameters');

    #We now pass a third wrong parameter (should not make a difference)
    my $pars3= { isbn => '123456', title => 'You should read this.', xyz => 1 };
    my @queries2= C4::Breeding::_build_query( $pars3 );
    is( $queries[0] eq $queries2[0] && $queries[1] eq $queries2[1], 1,
        'Third query makes no difference');
}

sub test_create_connection {
    #TODO This is just a *simple* start

    my $str;
    my $server= { servertype => 'zed', db => 'MyDatabase',
        host => 'really-not-a-domain-i-hope.nl', port => 80,
    };
    my $obj= C4::Breeding::_create_connection( $server );

    #We should get back an object, even if it did not connect
    is( ref $obj eq 'ZOOM::Connection', 1, 'Got back a ZOOM connection');

    #Remember: it is async
    my $i= ZOOM::event( [ $obj ] );
    if( $i == 1 ) {
        #We could examine ZOOM::event_str( $obj->last_event )
        #For now we are satisfied with an error message
        #Probably: Connect failed
        is( ($obj->errmsg//'') ne '', 1, 'Connection failed as expected');

    } else {
        ok( 1, 'No ZOOM event found: skipped errmsg' );
    }

    #Checking the databaseName for Z39.50 server
    $str=$obj->option('databaseName')//'';
    is( $str eq $server->{db}, 1, 'Check ZOOM option for database');

    #Another test for SRU
    $obj->destroy();
    $server->{ servertype } = 'sru';
    $server->{ sru_options } =  'just_testing=fun';
    $obj= C4::Breeding::_create_connection( $server );
    #In this case we expect no databaseName, but we expect just_testing
    $str=$obj->option('databaseName');
    is( $str, undef, 'No databaseName for SRU connection');
    $str=$obj->option('just_testing')//'';
    is( $str eq 'fun', 1, 'Additional ZOOM option for SRU found');
    $obj->destroy();
}

sub test_do_xslt {
    my $biblio = MARC::Record->new();
    $biblio->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'John Writer'),
        MARC::Field->new('245', ' ', ' ', a => 'Just a title'),
    );
    my $file= $FindBin::Bin.'/XSLT_Handler/test01.xsl';
    my $server= { add_xslt => $file };
    my $engine=Koha::XSLT_Handler->new;

    #ready for the main test
    my @res = C4::Breeding::_do_xslt_proc( $biblio, $server, $engine );
    is( $res[1], undef, 'No error returned' );
    is( ref $res[0], 'MARC::Record', 'Got back MARC record');
    is( $res[0]->subfield('990','a'), 'I saw you', 'Found 990a in the record');

    #forcing an error on the xslt side
    $server->{add_xslt} = 'notafile.xsl';
    @res = C4::Breeding::_do_xslt_proc( $biblio, $server, $engine );
    is( $res[1], Koha::XSLT_Handler::XSLTH_ERR_2, 'Error code found' );
    #We still expect the original record back
    is( ref $res[0], 'MARC::Record', 'Still got back MARC record' );
    is ( $res[0]->subfield('245','a'), 'Just a title',
        'At least the title is the same :)' );
}
