package KohaTest::Installer;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;
use C4::Languages;
use C4::Installer;

sub SKIP_CLASS : Expensive { }

sub testing_class { 'C4::Installer' };

sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw(
                       new 
                       marcflavour_list 
                       marc_framework_sql_list 
                       sample_data_sql_list 
                       sql_file_list 
                       load_db_schema 
                       load_sql_in_order 
                       set_marcflavour_syspref 
                       set_indexing_engine 
                       set_version_syspref 
                       load_sql 
    );
    can_ok( $self->testing_class, @methods );
}

# ensure that we have a fresh, empty database
# after running through the installer tests
sub shutdown_50_init_db : Tests( shutdown )  {
    my $self = shift;

    KohaTest::clear_test_database();
    KohaTest::create_test_database();
}

1;
