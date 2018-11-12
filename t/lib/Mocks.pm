package t::lib::Mocks;

use Modern::Perl;
use C4::Context;

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

sub mock_userenv {
    my ( $params ) = @_;

    C4::Context->_new_userenv(42);

    my $userenv;
    if ( $params and my $patron = $params->{patron} ) {
        $userenv = $patron->unblessed;
        $userenv->{branchcode} = $params->{branchcode} || $patron->library->branchcode;
        $userenv->{branchname} = $params->{branchname} || $patron->library->branchname;
    }
    my $usernum    = $params->{borrowernumber} || $userenv->{borrowernumber} || 51;
    my $userid     = $params->{userid}         || $userenv->{userid}         || 'userid4tests';
    my $cardnumber = $params->{cardnumber}     || $userenv->{cardnumber};
    my $firstname  = $params->{firstname}      || $userenv->{firstname}      || 'firstname';
    my $surname    = $params->{surname}        || $userenv->{surname}        || 'surname';
    my $branchcode = $params->{branchcode}     || $userenv->{branchcode}     || 'Branch4T';
    my $branchname   = $params->{branchname}   || $userenv->{branchname};
    my $flags        = $params->{flags}        || $userenv->{flags}          || 0;
    my $emailaddress = $params->{emailaddress} || $userenv->{emailaddress};
    my ( $branchprinter, $shibboleth );

    C4::Context->set_userenv($usernum, $userid, $cardnumber, $firstname, $surname, $branchcode, $branchname, $flags, $emailaddress, $branchprinter, $shibboleth );
}

1;
