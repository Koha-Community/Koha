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
system("rm -rf ".$config->{intranetdir});
system("\nrm -rf ".$config->{opacdir});
# remove mySQL stuff
# user
print "enter mySQL root password, please\n";
my $response=<STDIN>;
chomp $response;
# DB
system("mysqladmin -f -uroot -p$response drop ".$config->{database});
system("mysql -uroot -p$response -Dmysql -e\"delete from user where user='".$config->{user}.'\'"');
system("mysql -uroot -p$response -Dmysql -e\"delete from db where user='".$config->{user}.'\'"');
# reload mysql
system("mysqladmin -uroot -p$response reload");
system("rm -f /etc/koha-httpd.conf");
system("rm -f /etc/koha.conf");
print "EDIT httpd.conf to remove /etc/koha-httpd.conf\n";
