# 
# parse-config: Parse an XML-format
# ACS configuration file and build the configuration
# structure.
#

package Sip::Configuration;

use strict;
use warnings;
use XML::Simple qw(:strict);

use Sip::Configuration::Institution;
use Sip::Configuration::Account;
use Sip::Configuration::Service;

my $parser = new XML::Simple( KeyAttr   => { login => '+id',
					     institution => '+id',
					     service => '+port' },
			      GroupTags =>  { listeners => 'service',
					      accounts => 'login',
					      institutions => 'institution', },
			      ForceArray=> [ 'service',
					     'login',
					     'institution' ],
			      ValueAttr =>  { 'error-detect' => 'enabled',
					     'min_servers' => 'value',
					     'max_servers' => 'value'} );

sub new {
    my ($class, $config_file) = @_;
    my $cfg = $parser->XMLin($config_file);
    my %listeners;

    foreach my $acct (values %{$cfg->{accounts}}) {
		new Sip::Configuration::Account $acct;
    }

    # The key to the listeners hash is the 'port' component of the
    # configuration, which is of the form '[host]:[port]/proto', and
    # the 'proto' component could be upper-, lower-, or mixed-cased.
    # Regularize it here to lower-case, and then do the same below in
    # find_server() when building the keys to search the hash.

    foreach my $service (values %{$cfg->{listeners}}) {
		new Sip::Configuration::Service $service;
		$listeners{lc $service->{port}} = $service;
    }
    $cfg->{listeners} = \%listeners;

    foreach my $inst (values %{$cfg->{institutions}}) {
		new Sip::Configuration::Institution $inst;
    }
    return bless $cfg, $class;
}

sub error_detect {
    my $self = shift;
    return $self->{'error-detect'};
}
sub accounts {
    my $self = shift;
    return values %{$self->{accounts}};
}

# sub policy {
#     my $self = shift;
#     return values %{$self->{policy}};
# }

sub find_service {
    my ($self, $sockaddr, $port, $proto) = @_;
    my $portstr;
	foreach my $addr ('', '*:', "$sockaddr:", "[$sockaddr]:") {
		$portstr = sprintf("%s%s/%s", $addr, $port, lc $proto);
		Sys::Syslog::syslog("LOG_DEBUG", "Configuration::find_service: Trying $portstr");
		last if (exists(($self->{listeners})->{$portstr}));
	}
    return $self->{listeners}->{$portstr};
}

1;
__END__

    my $config = new Sip::Configuration $ARGV[0];


foreach my $acct ($config->accounts) {
    print "Found account '", $acct->name, "', part of '"
    print $acct->institution, "'\n";
}

1;
