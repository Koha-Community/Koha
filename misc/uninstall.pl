#!/usr/bin/perl

sub ReadConfigFile
{
	my $fname = shift;	# Config file to read
	my $retval = {};	# Return value: ref-to-hash holding the configuration
	open (CONF, $fname) or return undef;
	while (<CONF>) {
		my $var;		# Variable name
		my $value;		# Variable value
		chomp;
		s/#.*//;		# Strip comments
		next if /^\s*$/;	# Ignore blank lines
		next if (!/^\s*(\w+)\s*=\s*(.*?)\s*$/);
		$var = $1;
		$value = $2;
		$retval->{$var} = $value;
	}
	close CONF;
	return $retval;
}

my $config = ReadConfigFile("/etc/koha.conf");
# to remove web sites:
print "\nrm -rf ".$config->{intranetdir};
print "\nrm -rf ".$config->{opacdir};
# remove mySQL stuff
# DB
print "\nmysqladmin -f -u".$config->{user}." -p".$config->{pass}." drop ".$config->{database};
# user
print "enter mySQL root password, please\n";
my $response=<STDIN>;
chomp $response;
print "\nmysql -uroot -p$response -Dmysql -e\"delete from user where user='".$config->{user}.'"';
# reload mysql
print "\nmysqladmin -uroot -p$response reload";
print "\nrm -f /etc/koha-httpd.conf";
print "\nrm -f /etc/koha.conf";
print "\nEDIT httpd.conf to remove /etc/koha-httpd.conf\n";
