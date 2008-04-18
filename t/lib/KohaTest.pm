package KohaTest;
use base qw(Test::Class);

use Test::More;
use Data::Dumper;

eval "use Test::Class";
plan skip_all => "Test::Class required for performing database tests" if $@;
# Or, maybe I should just die there.

use lib qw(..);
use C4::Biblio;
use C4::Bookfund;
use C4::Bookseller;
use C4::Context;
use C4::Items;
use C4::Members;
use C4::Search;

# Since this is an abstract base class, this prevents these tests from
# being run directly unless we're testing a subclass. It just makes
# things faster.
__PACKAGE__->SKIP_CLASS( 1 );


=head2 startup methods

these are run once, at the beginning of the whole test suite

=cut

=head2 startup_10_prepare_database

prepare a blank database.

This ends up getting run once for each test module, so that's several
times throughout the test suite. That may be too many times to refresh
the database. We may have to tune that.

=cut

sub startup_10_prepare_database : Test(startup => 1) {
    my $self = shift;
    # this is how I'm refreshing my database for now.  I'll think of
    # something better later.  Eventually, I'd like to drop the
    # database entirely and use the regular install code to rebuild a
    # base database.
    my $class = ref $self;

    # like( C4::Context->config( 'database '), qr/test$/, 'using test database: ' . C4::Context->config( 'database' ) )
    like( C4::Context->database(), qr/test$/, 'using test database: ' . C4::Context->database() )
      or BAIL_OUT( 'This appears to not be a test database.' );

    return;
}

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
#                               categorytable               
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
#                               mediatypetable              
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
#                               subcategorytable            
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
                              categorytable               
                              cities                      
                              deletedbiblio               
                              deletedbiblioitems          
                              deletedborrowers            
                              deleteditems                
                              ethnicity                   
                              import_items                
                              import_record_matches       
                              issues                      
                              issuingrules                
                              items                       
                              labels                      
                              labels_profile              
                              matchchecks                 
                              mediatypetable              
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
                              subcategorytable            
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

=head2 startup_24_add_member

Add a patron/member for the tests to use

=cut

sub startup_24_add_member : Test(startup => 1) {
    my $self = shift;

    my $memberinfo = { surname      => 'surname '  . $self->random_string(),
                       firstname    => 'firstname' . $self->random_string(),
                       address      => 'address'   . $self->random_string(),
                       city         => 'city'      . $self->random_string(),
                       branchcode   => 'CPL', # CPL => Centerville
                       categorycode => 'PT',  # PT  => PaTron
                  };

    my $id = AddMember( %$memberinfo );
    ok( $id, "created member: $id" );
    $self->{'memberid'} = $id;
    
    return;
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

    my $wordsize = 6;  # how many letters in your string?

    # leave out these characters: "oOlL10". They're too confusing.
    my @alphabet = ( 'a'..'k','m','n','p'..'z', 'A'..'K','M','N','P'..'Z', 2..9 );

    my $randomstring;
    foreach ( 0..$wordsize ) {
        $randomstring .= $alphabet[ rand( scalar( @alphabet ) ) ];
    }
    return $randomstring;
    
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
        my $appendedfieldscount = $marcrecord->append_fields( MARC::Field->new( '100', '1', '0',
                                                                                a => 'Twain, Mark',
                                                                                d => "1835-1910." ),
                                                              MARC::Field->new( '245', '1', '4',
                                                                                a => sprintf( 'The Adventures of Huckleberry Finn Test %s', $counter ),
                                                                                c => "Mark Twain ; illustrated by E.W. Kemble." )
                                                         );
        is( $appendedfieldscount, 2, 'added 2 fields' );
        
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
        }
        push @{$self->{'biblios'}}, $biblionumber;
    }
    
    my $query = 'Finn Test';

    # XXX we're going to repeatedly try to fetch the marc records that
    # we inserted above. It may take a while before they all show
    # up. why?
    my $tries = 30;
    DELAY: foreach my $trial ( 1..$tries ) {
        diag "waiting for zebra indexing. Trial: $trial of $tries";
        my ( $error, $results ) = SimpleSearch( $query );
        if ( $param{'count'} <= scalar( @$results ) ) {
            ok( $tries, "found all $param{'count'} titles after $trial tries" );
            last DELAY;
        }
        sleep( 3 );
    } continue {
        if ( $trial == $tries ) {
            fail( "we never found all $param{'count'} titles even after $tries tries." );
        }
    }

    
}

1;
