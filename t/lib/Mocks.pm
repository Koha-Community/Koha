package t::lib::Mocks;

use Modern::Perl;
use C4::Context;

use DBD::Mock;
use Test::MockModule;

my %configs;
sub mock_config {
    my $context = new Test::MockModule('C4::Context');
    my ( $conf, $value ) = @_;
    $configs{$conf} = $value;
    $context->mock('config', sub {
        my ( $self, $conf ) = @_;
        if ( exists $configs{$conf} ) {
            return $configs{$conf}
        } else {
            my $method = $context->original('config');
            return $method->($self, $conf);
        }
    });
}

my %preferences;
sub mock_preference {
    my $context = new Test::MockModule('C4::Context');
    my ( $pref, $value ) = @_;
    $preferences{$pref} = $value;
    $context->mock('preference', sub {
        my ( $self, $pref ) = @_;
        if ( exists $preferences{$pref} ) {
            return $preferences{$pref}
        } else {
            my $method = $context->original('preference');
            return $method->($self, $pref);
        }
    });
}

sub mock_dbh {
    my $context = new Test::MockModule('C4::Context');
    $context->mock( '_new_dbh', sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    } );
    return $context;
}

1;
