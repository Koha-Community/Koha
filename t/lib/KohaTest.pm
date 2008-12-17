package KohaTest;
use base qw(Test::Class);

use Test::More;
use Data::Dumper;

eval "use Test::Class";
plan skip_all => "Test::Class required for performing database tests" if $@;
# Or, maybe I should just die there.

use C4::Auth;
use C4::Biblio;
use C4::Bookfund;
use C4::Bookseller;
use C4::Context;
use C4::Items;
use C4::Members;
use C4::Search;
use C4::Installer;
use C4::Languages;
use File::Temp qw/ tempdir /;
use CGI;
use Time::localtime;

# Since this is an abstract base class, this prevents these tests from
# being run directly unless we're testing a subclass. It just makes
# things faster.
__PACKAGE__->SKIP_CLASS( 1 );

INIT {
    if ($ENV{SINGLE_TEST}) {
        # if we're running the tests in one
        # or more test files specified via
        #
        #   make test-single TEST_FILES=lib/KohaTest/Foo.pm
        #
        # use this INIT trick taken from the POD for
        # Test::Class::Load.
        start_zebrasrv();
        Test::Class->runtests;
        stop_zebrasrv();
    }
}

use Attribute::Handlers;

=head2 Expensive test method attribute

If a test method is decorated with an Expensive
attribute, it is skipped unless the RUN_EXPENSIVE_TESTS
environment variable is defined.

To declare an entire test class and its subclasses expensive,
define a SKIP_CLASS with the Expensive attribute:

    sub SKIP_CLASS : Expensive { }

=cut

sub Expensive : ATTR(CODE) {
    my ($package, $symbol, $sub, $attr, $data, $phase) = @_;
    my $name = *{$symbol}{NAME};
    if ($name eq 'SKIP_CLASS') {
        if ($ENV{'RUN_EXPENSIVE_TESTS'}) {
            *{$symbol} = sub { 0; }
        } else {
            *{$symbol} = sub { "Skipping expensive test classes $package (and subclasses)"; }
        }
    } else {
        unless ($ENV{'RUN_EXPENSIVE_TESTS'}) {
            # a test method that runs no tests and just returns a scalar is viewed by Test::Class as a skip
            *{$symbol} = sub { "Skipping expensive test $package\:\:$name"; }
        }
    }
}

=head2 startup methods

these are run once, at the beginning of the whole test suite

=cut

sub startup_15_truncate_tables : Test( startup => 1 ) {
    my $self = shift;
    
#     my @truncate_tables = qw( accountlines 
#                               accountoffsets              
#                               action_logs                 
#                               alert                       
#                               aqbasket                    
#                               aqbookfund                  
#                               aqbooksellers               
#                               aqbudget                    
#                               aqorderbreakdown            
#                               aqorderdelivery             
#                               aqorders                    
#                               auth_header                 
#                               auth_subfield_structure     
#                               auth_tag_structure          
#                               auth_types                  
#                               authorised_values           
#                               biblio                      
#                               biblio_framework            
#                               biblioitems                 
#                               borrowers                   
#                               branchcategories            
#                               branches                    
#                               branchrelations             
#                               branchtransfers             
#                               browser                     
#                               categories                  
#                               cities                      
#                               class_sort_rules            
#                               class_sources               
#                               currency                    
#                               deletedbiblio               
#                               deletedbiblioitems          
#                               deletedborrowers            
#                               deleteditems                
#                               ethnicity                   
#                               import_batches              
#                               import_biblios              
#                               import_items                
#                               import_record_matches       
#                               import_records              
#                               issues                      
#                               issuingrules                
#                               items                       
#                               itemtypes                   
#                               labels                      
#                               labels_conf                 
#                               labels_profile              
#                               labels_templates            
#                               language_descriptions       
#                               language_rfc4646_to_iso639  
#                               language_script_bidi        
#                               language_script_mapping     
#                               language_subtag_registry    
#                               letter                      
#                               marc_matchers               
#                               marc_subfield_structure     
#                               marc_tag_structure          
#                               matchchecks                 
#                               matcher_matchpoints         
#                               matchpoint_component_norms  
#                               matchpoint_components       
#                               matchpoints                 
#                               notifys                     
#                               nozebra                     
#                               old_issues                  
#                               old_reserves                
#                               opac_news                   
#                               overduerules                
#                               patroncards                 
#                               patronimage                 
#                               printers                    
#                               printers_profile            
#                               repeatable_holidays         
#                               reports_dictionary          
#                               reserveconstraints          
#                               reserves                    
#                               reviews                     
#                               roadtype                    
#                               saved_reports               
#                               saved_sql                   
#                               serial                      
#                               serialitems                 
#                               services_throttle           
#                               sessions                    
#                               special_holidays            
#                               statistics                  
#                               stopwords                   
#                               subscription                
#                               subscriptionhistory         
#                               subscriptionroutinglist     
#                               suggestions                 
#                               systempreferences           
#                               tags                        
#                               userflags                   
#                               virtualshelfcontents        
#                               virtualshelves              
#                               z3950servers                
#                               zebraqueue                  
#                         );

    my @truncate_tables = qw( accountlines 
                              accountoffsets              
                              alert                       
                              aqbasket                    
                              aqbooksellers               
                              aqorderbreakdown            
                              aqorderdelivery             
                              aqorders                    
                              auth_header                 
                              branchcategories            
                              branchrelations             
                              branchtransfers             
                              browser                     
                              cities                      
                              deletedbiblio               
                              deletedbiblioitems          
                              deletedborrowers            
                              deleteditems                
                              ethnicity                   
                              issues                      
                              issuingrules                
                              labels                      
                              labels_profile              
                              matchchecks                 
                              notifys                     
                              nozebra                     
                              old_issues                  
                              old_reserves                
                              overduerules                
                              patroncards                 
                              patronimage                 
                              printers                    
                              printers_profile            
                              reports_dictionary          
                              reserveconstraints          
                              reserves                    
                              reviews                     
                              roadtype                    
                              saved_reports               
                              saved_sql                   
                              serial                      
                              serialitems                 
                              services_throttle           
                              special_holidays            
                              statistics                  
                              subscription                
                              subscriptionhistory         
                              subscriptionroutinglist     
                              suggestions                 
                              tags                        
                              virtualshelfcontents        
                        );
    
    my $failed_to_truncate = 0;
    foreach my $table ( @truncate_tables ) {
        my $dbh = C4::Context->dbh();
        $dbh->do( "truncate $table" )
          or $failed_to_truncate = 1;
    }
    is( $failed_to_truncate, 0, 'truncated tables' );
}

=head2 startup_20_add_bookseller

we need a bookseller for many of the tests, so let's insert one. Feel
free to use this one, or insert your own.

=cut

sub startup_20_add_bookseller : Test(startup => 1) {
    my $self = shift;

    my $booksellerinfo = { name => 'bookseller ' . $self->random_string(),
                      };

    my $id = AddBookseller( $booksellerinfo );
    ok( $id, "created bookseller: $id" );
    $self->{'booksellerid'} = $id;
    
    return;
}

=head2 startup_22_add_bookfund

we need a bookfund for many of the tests. This currently uses one that
is in the skeleton database.  free to use this one, or insert your
own.

=cut

sub startup_22_add_bookfund : Test(startup => 2) {
    my $self = shift;

    my $bookfundid = 'GEN';
    my $bookfund = GetBookFund( $bookfundid, undef );
    # diag( Data::Dumper->Dump( [ $bookfund ], qw( bookfund  ) ) );
    is( $bookfund->{'bookfundid'},   $bookfundid,      "found bookfund: '$bookfundid'" );
    is( $bookfund->{'bookfundname'}, 'General Stacks', "found bookfund: '$bookfundid'" );
    
    $self->{'bookfundid'} = $bookfundid;
    return;
}

=head2 startup_24_add_branch

=cut

sub startup_24_add_branch : Test(startup => 1) {
    my $self = shift;

    my $branch_info = {
        add            => 1,
        branchcode     => $self->random_string(3),
        branchname     => $self->random_string(),
        branchaddress1 => $self->random_string(),
        branchaddress2 => $self->random_string(),
        branchaddress3 => $self->random_string(),
        branchphone    => $self->random_phone(),
        branchfax      => $self->random_phone(),
        brancemail     => $self->random_email(),
        branchip       => $self->random_ip(),
        branchprinter  => $self->random_string(),
      };
    C4::Branch::ModBranch($branch_info);
    $self->{'branchcode'} = $branch_info->{'branchcode'};
    ok( $self->{'branchcode'}, "created branch: $self->{'branchcode'}" );

}

=head2 startup_24_add_member

Add a patron/member for the tests to use

=cut

sub startup_24_add_member : Test(startup => 1) {
    my $self = shift;

    my $memberinfo = { surname      => 'surname '  . $self->random_string(),
                       firstname    => 'firstname' . $self->random_string(),
                       address      => 'address'   . $self->random_string(),
                       city         => 'city'      . $self->random_string(),
                       cardnumber   => 'card'      . $self->random_string(),
                       branchcode   => 'CPL', # CPL => Centerville
                       categorycode => 'PT',  # PT  => PaTron
                       dateexpiry   => '2010-01-01',
                       password     => 'testpassword',
                       dateofbirth  => $self->random_date(),
                  };

    my $borrowernumber = AddMember( %$memberinfo );
    ok( $borrowernumber, "created member: $borrowernumber" );
    $self->{'memberid'} = $borrowernumber;
    
    return;
}

=head2 startup_30_login

=cut

sub startup_30_login : Test( startup => 2 ) {
    my $self = shift;

    $self->{'sessionid'} = '12345678'; # does this value matter?
    my $borrower_details = C4::Members::GetMemberDetails( $self->{'memberid'} );
    ok( $borrower_details->{'cardnumber'}, 'cardnumber' );
    
    # make a cookie and force it into $cgi.
    # This would be a lot easier with Test::MockObject::Extends.
    my $cgi = CGI->new( { userid   => $borrower_details->{'cardnumber'},
                          password => 'testpassword' } );
    my $setcookie = $cgi->cookie( -name  => 'CGISESSID',
                                  -value => $self->{'sessionid'} );
    $cgi->{'.cookies'} = { CGISESSID => $setcookie };
    is( $cgi->cookie('CGISESSID'), $self->{'sessionid'}, 'the CGISESSID cookie is set' );
    # diag( Data::Dumper->Dump( [ $cgi->cookie('CGISESSID') ], [ qw( cookie ) ] ) );

    # C4::Auth::checkauth sometimes emits a warning about unable to append to sessionlog. That's OK.
    my ( $userid, $cookie, $sessionID ) = C4::Auth::checkauth( $cgi, 'noauth', {}, 'intranet' );
    # diag( Data::Dumper->Dump( [ $userid, $cookie, $sessionID ], [ qw( userid cookie sessionID ) ] ) );

    # my $session = C4::Auth::get_session( $sessionID );
    # diag( Data::Dumper->Dump( [ $session ], [ qw( session ) ] ) );
    

}

=head2 setup methods

setup methods are run before every test method

=cut

=head2 teardown methods

teardown methods are many time, once at the end of each test method.

=cut

=head2 shutdown methods

shutdown methods are run once, at the end of the test suite

=cut

=head2 utility methods

These are not test methods, but they're handy

=cut

=head3 random_string

Nice for generating names and such. It's not actually random, more
like arbitrary.

=cut

sub random_string {
    my $self = shift;

    my $wordsize = shift || 6;  # how many letters in your string?

    # leave out these characters: "oOlL10". They're too confusing.
    my @alphabet = ( 'a'..'k','m','n','p'..'z', 'A'..'K','M','N','P'..'Z', 2..9 );

    my $randomstring;
    foreach ( 0..$wordsize ) {
        $randomstring .= $alphabet[ rand( scalar( @alphabet ) ) ];
    }
    return $randomstring;
    
}

=head3 random_phone

generates a random phone number. Currently, it's not actually random. It's an unusable US phone number

=cut

sub random_phone {
    my $self = shift;

    return '212-555-5555';
    
}

=head3 random_email

generates a random email address. They're all in the unusable
'example.com' domain that is designed for this purpose.

=cut

sub random_email {
    my $self = shift;

    return $self->random_string() . '@example.com';
    
}

=head3 random_ip

returns an IP address suitable for testing purposes.

=cut

sub random_ip {
    my $self = shift;

    return '127.0.0.2';
    
}

=head3 random_date

returns a somewhat random date in the iso (yyyy-mm-dd) format.

=cut

sub random_date {
    my $self = shift;

    my $year  = 1800 + int( rand(300) );    # 1800 - 2199
    my $month = 1 + int( rand(12) );        # 1 - 12
    my $day   = 1 + int( rand(28) );        # 1 - 28
                                            # stop at the 28th to keep us from generating February 31st and such.

    return sprintf( '%04d-%02d-%02d', $year, $month, $day );

}

=head3 tomorrow

returns tomorrow's date as YYYY-MM-DD.

=cut

sub tomorrow {
    my $self = shift;

    return $self->days_from_now( 1 );

}

=head3 yesterday

returns yesterday's date as YYYY-MM-DD.

=cut

sub yesterday {
    my $self = shift;

    return $self->days_from_now( -1 );
}


=head3 days_from_now

returns an arbitrary date based on today in YYYY-MM-DD format.

=cut

sub days_from_now {
    my $self = shift;
    my $days = shift or return;

    my $seconds = time + $days * 60*60*24;
    my $yyyymmdd = sprintf( '%04d-%02d-%02d',
                            localtime( $seconds )->year() + 1900,
                            localtime( $seconds )->mon() + 1,
                            localtime( $seconds )->mday() );
    return $yyyymmdd;
}

=head3 add_biblios

  $self->add_biblios( count     => 10,
                      add_items => 1, );

  named parameters:
     count: number of biblios to add
     add_items: should you add items for each one?

  returns:
    I don't know yet.

  side effects:
    adds the biblionumbers to the $self->{'biblios'} listref

  Notes:
    Should I allow you to pass in biblio information, like title?
    Since this method is in the KohaTest class, all tests in it will be ignored, unless you call this from your own namespace.
    This runs 10 tests, plus 4 for each "count", plus 3 more for each item added.

=cut

sub add_biblios {
    my $self = shift;
    my %param = @_;

    $param{'count'}     = 1 unless defined( $param{'count'} );
    $param{'add_items'} = 0 unless defined( $param{'add_items'} );

    foreach my $counter ( 1..$param{'count'} ) {
        my $marcrecord  = MARC::Record->new();
        isa_ok( $marcrecord, 'MARC::Record' );
        my @marc_fields = ( MARC::Field->new( '100', '1', '0',
                                              a => 'Twain, Mark',
                                              d => "1835-1910." ),
                            MARC::Field->new( '245', '1', '4',
                                              a => sprintf( 'The Adventures of Huckleberry Finn Test %s', $counter ),
                                              c => "Mark Twain ; illustrated by E.W. Kemble." ),
                            MARC::Field->new( '952', '0', '0',
                                              p => '12345678' . $self->random_string() ),   # barcode
                            MARC::Field->new( '952', '0', '0',
                                              o => $self->random_string() ),   # callnumber
                            MARC::Field->new( '952', '0', '0',
                                              a => 'CPL',
                                              b => 'CPL' ),
                       );

        my $appendedfieldscount = $marcrecord->append_fields( @marc_fields );
        
        diag $MARC::Record::ERROR if ( $MARC::Record::ERROR );
        is( $appendedfieldscount, scalar @marc_fields, 'added correct number of MARC fields' );
        
        my $frameworkcode = ''; # XXX I'd like to put something reasonable here.
        my ( $biblionumber, $biblioitemnumber ) = AddBiblio( $marcrecord, $frameworkcode );
        ok( $biblionumber, "the biblionumber is $biblionumber" );
        ok( $biblioitemnumber, "the biblioitemnumber is $biblioitemnumber" );
        if ( $param{'add_items'} ) {
            # my @iteminfo = AddItem( {}, $biblionumber );
            my @iteminfo = AddItemFromMarc( $marcrecord, $biblionumber );
            is( $iteminfo[0], $biblionumber,     "biblionumber is $biblionumber" );
            is( $iteminfo[1], $biblioitemnumber, "biblioitemnumber is $biblioitemnumber" );
            ok( $iteminfo[2], "itemnumber is $iteminfo[2]" );
        push @{ $self->{'items'} },
          { biblionumber     => $iteminfo[0],
            biblioitemnumber => $iteminfo[1],
            itemnumber       => $iteminfo[2],
          };
        }
        push @{$self->{'biblios'}}, $biblionumber;
    }
   
    $self->reindex_marc(); 
    my $query = 'Finn Test';
    my ( $error, $results ) = SimpleSearch( $query );
    if ( $param{'count'} <= scalar( @$results ) ) {
        pass( "found all $param{'count'} titles" );
    } else {
        fail( "we never found all $param{'count'} titles" );
    }
    
}

=head3 reindex_marc

Do a fast reindexing of all of the bib and authority
records and mark all zebraqueue entries done.

Useful for test routines that need to do a
lot of indexing without having to wait for
zebraqueue.

In NoZebra model, this only marks zebraqueue
done - the records should already be indexed.

=cut

sub reindex_marc {
    my $self = shift;

    # mark zebraqueue done regardless of the indexing mode
    my $dbh = C4::Context->dbh();
    $dbh->do("UPDATE zebraqueue SET done = 1 WHERE done = 0");

    return if C4::Context->preference('NoZebra');

    my $directory = tempdir(CLEANUP => 1);
    foreach my $record_type qw(biblio authority) {
        mkdir "$directory/$record_type";
        my $sth = $dbh->prepare($record_type eq "biblio" ? "SELECT marc FROM biblioitems" : "SELECT marc FROM auth_header");
        $sth->execute();
        open OUT, ">:utf8", "$directory/$record_type/records";
        while (my ($blob) = $sth->fetchrow_array) {
            print OUT $blob;
        }
        close OUT;
        my $zebra_server = "${record_type}server";
        my $zebra_config  = C4::Context->zebraconfig($zebra_server)->{'config'};
        my $zebra_db_dir  = C4::Context->zebraconfig($zebra_server)->{'directory'};
        my $zebra_db = $record_type eq 'biblio' ? 'biblios' : 'authorities';
        system "zebraidx -c $zebra_config -d $zebra_db -g iso2709 init > /dev/null 2>\&1";
        system "zebraidx -c $zebra_config -d $zebra_db -g iso2709 update $directory/${record_type} > /dev/null 2>\&1";
        system "zebraidx -c $zebra_config -d $zebra_db -g iso2709 commit > /dev/null 2>\&1";
    }
        
}


=head3 clear_test_database

  removes all tables from test database so that install starts with a clean slate

=cut

sub clear_test_database {

    diag "removing tables from test database";

    my $dbh = C4::Context->dbh;
    my $schema = C4::Context->config("database");

    my @tables = get_all_tables($dbh, $schema);
    foreach my $table (@tables) {
        drop_all_foreign_keys($dbh, $table);
    }

    foreach my $table (@tables) {
        drop_table($dbh, $table);
    }
}

sub get_all_tables {
  my ($dbh, $schema) = @_;
  my $sth = $dbh->prepare("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ?");
  my @tables = ();
  $sth->execute($schema);
  while (my ($table) = $sth->fetchrow_array) {
    push @tables, $table;
  }
  $sth->finish;
  return @tables;
}

sub drop_all_foreign_keys {
    my ($dbh, $table) = @_;
    # get the table description
    my $sth = $dbh->prepare("SHOW CREATE TABLE $table");
    $sth->execute;
    my $vsc_structure = $sth->fetchrow;
    # split on CONSTRAINT keyword
    my @fks = split /CONSTRAINT /,$vsc_structure;
    # parse each entry
    foreach (@fks) {
        # isolate what is before FOREIGN KEY, if there is something, it's a foreign key to drop
        $_ = /(.*) FOREIGN KEY.*/;
        my $id = $1;
        if ($id) {
            # we have found 1 foreign, drop it
            $dbh->do("ALTER TABLE $table DROP FOREIGN KEY $id");
            if ( $dbh->err ) {
                diag "unable to DROP FOREIGN KEY '$id' on TABLE '$table' due to: " . $dbh->errstr();
            }
            undef $id;
        }
    }
}

sub drop_table {
    my ($dbh, $table) = @_;
    $dbh->do("DROP TABLE $table");
    if ( $dbh->err ) {
        diag "unable to drop table: '$table' due to: " . $dbh->errstr();
    }
}

=head3 create_test_database

  sets up the test database.

=cut

sub create_test_database {

    diag 'creating testing database...';
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

    my $command = q(run/bin/koha-zebraqueue-ctl.sh start);
    diag $command;
    my $started = system( $command );
    diag "started: $started";
    
}

=head3 stop_zebraqueue_daemon


=cut

sub stop_zebraqueue_daemon {

    my $command = q(run/bin/koha-zebraqueue-ctl.sh stop);
    diag $command;
    my $started = system( $command );
    diag "started: $started";

}

1;
