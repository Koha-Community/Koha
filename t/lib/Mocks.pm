package t::lib::Mocks;

use Modern::Perl;
use C4::Context;

use Koha::Schema;
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
    my ( $pref, $value ) = @_;

    $preferences{lc($pref)} = $value;

    my $context = new Test::MockModule('C4::Context');
    $context->mock('preference', sub {
        my ( $self, $pref ) = @_;
        $pref = lc($pref);
        if ( exists $preferences{$pref} ) {
            return $preferences{$pref}
        } else {
            my $method = $context->original('preference');
            return $method->($self, $pref);
        }
    });
}

sub mock_dbh {
    our $context = new Test::MockModule('Koha::Database');
    $context->mock( '_new_schema', sub {
        my $dbh = Koha::Schema->connect( 'DBI:Mock:', '', '' );
        return $dbh;
    } );
    return $context;
}

1;
