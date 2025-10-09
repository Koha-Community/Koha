#
# parse-config: Parse an XML-format
# ACS configuration file and build the configuration
# structure.
#

package C4::SIP::Sip::Configuration;

use strict;
use warnings;
use XML::Simple     qw(:strict);
use List::MoreUtils qw(uniq);

use C4::SIP::Sip qw(siplog);
use Koha::Libraries;
use Koha::SIP2::Institutions;
use Koha::SIP2::Accounts;
use Koha::SIP2::SystemPreferenceOverrides;

my $parser = XML::Simple->new(
    KeyAttr => {
        login       => '+id',
        institution => '+id',
        service     => '+port'
    },
    GroupTags => {
        listeners    => 'service',
        accounts     => 'login',
        institutions => 'institution',
    },
    ForceArray => [ 'service', 'login', 'institution' ],
    ValueAttr  => {
        'error-detect' => 'enabled',
        'min_servers'  => 'value',
        'max_servers'  => 'value'
    }
);

sub get_configuration {
    my ( $class, $config_file ) = @_;

    my $cfg = $parser->XMLin($config_file) if $config_file;
    my %listeners;

    # The key to the listeners hash is the 'port' component of the
    # configuration, which is of the form '[host]:[port]/proto[/IPv[46]]'
    # The 'proto' component could be upper-, lower-, or mixed-cased.
    # Regularize it here to lower-case, and then do the same below in
    # find_server() when building the keys to search the hash.

    foreach my $service ( values %{ $cfg->{listeners} } ) {
        $listeners{ lc $service->{port} } = $service;
    }
    $cfg->{listeners} = \%listeners;

    $cfg->{accounts}     = Koha::SIP2::Accounts->get_for_config()     if Koha::SIP2::Accounts->search()->count;
    $cfg->{institutions} = Koha::SIP2::Institutions->get_for_config() if Koha::SIP2::Institutions->search()->count;
    $cfg->{'syspref_overrides'} = Koha::SIP2::SystemPreferenceOverrides->get_for_config()
        if Koha::SIP2::SystemPreferenceOverrides->search()->count;

    my @branchcodes  = Koha::Libraries->search()->get_column('branchcode');
    my @institutions = uniq( keys %{ $cfg->{institutions} } );
    foreach my $i (@institutions) {
        siplog(
            "LOG_ERR",
            "ERROR: Institution $i does does not match a branchcode. This can cause unexpected behavior."
        ) unless grep( /^$i$/, @branchcodes );
    }
    return $cfg;
}

sub new {
    my ( $class, $config_file ) = @_;
    my $cfg = $class->get_configuration($config_file);
    return bless $cfg, $class;
}

sub error_detect {
    my $self = shift;
    return $self->{'error-detect'};
}

sub accounts {
    my $self = shift;
    return values %{ $self->{accounts} };
}

sub find_service {
    my ( $self, $sockaddr, $port, $proto ) = @_;
    my $portstr;
    foreach my $addr ( '', '*:', "$sockaddr:", "[$sockaddr]:" ) {
        $portstr = sprintf( "%s%s/%s", $addr, $port, lc $proto );
        siplog(
            "LOG_DEBUG",
            "Configuration::find_service: Trying $portstr"
        );
        last if ( exists( ( $self->{listeners} )->{$portstr} ) );
        $portstr .= '/ipv4';    # lc, see ->new
        last if ( exists( ( $self->{listeners} )->{$portstr} ) );
        $portstr .= '/ipv6';    # lc, see ->new
        last if ( exists( ( $self->{listeners} )->{$portstr} ) );
    }
    return $self->{listeners}->{$portstr};
}

1;
