package KohaTest::Context;
use base qw( KohaTest );

use strict;
use warnings;

use Test::More;

use C4::Context;
sub testing_class { 'C4::Context' };


sub methods : Test( 1 ) {
    my $self = shift;
    my @methods = qw(
                        AUTOLOAD
                        boolean_preference
                        config
                        dbh
                        db_scheme2dbi
                        get_shelves_userenv
                        get_versions
                        import
                        KOHAVERSION
                        marcfromkohafield
                        ModZebrations
                        new
                        new_dbh
                        preference
                        read_config_file
                        restore_context
                        restore_dbh
                        set_context
                        set_dbh
                        set_shelves_userenv
                        set_userenv
                        stopwords
                        userenv
                        Zconn
                        zebraconfig
                        _common_config
                        _new_dbh
                        _new_marcfromkohafield
                        _new_stopwords
                        _new_userenv
                        _new_Zconn
                        _unset_userenv
                );
    
    can_ok( $self->testing_class, @methods );    
}

1;

