#!/usr/bin/perl
#
# To start out, try something like this against your LDAP:
# ldapadd    -w metavore -D'cn=Manager,dc=metavore,dc=com' -c -f example3.ldif 
# ldapmodify -w metavore -D'cn=Manager,dc=metavore,dc=com' -c -f example3.ldif 
# 
# Then run this script to test perl interaction w/ LDAP.
#

use warnings;
use strict;

use Net::LDAP;
use Net::LDAP::Filter;

my $host = (@ARGV) ? shift : 'localhost';
my $filter = Net::LDAP::Filter->new((@ARGV) ? shift : 'objectClass=inetOrgPerson');
my %params = (
	base   => (@ARGV) ? shift : 'dc=metavore,dc=com',
	filter => $filter,
);

my $ldap = Net::LDAP->new($host) 	or die "Cannot connect to ldap on $host";
$ldap->bind("cn=Manager," . $params{'base'}, password=>'metavore') or die "Cannot bind to ldap on $host";
&ldap_dse;
&ldap_search;
&ldap_add;
&ldap_search;

sub hashup {
	my $query = shift or die "Bad hashup call";
	my %memberhash = ();
	my $key;
	foreach my $user ($query->shift_entry){
		foreach my $k (@$user) {
			foreach my $k2 ( keys %$k ) {
				if ($k2 eq 'type') {
					$key = $$k{$k2};
				} else {
					$memberhash{$key} .= map {$_ . " "} @$k{$k2};
				}
			}
		}
	}
	return %memberhash;
}

sub recursive_breakdown {
	my $dse = shift or return undef;
	if (ref($dse) =~ /HASH/) {
		return join "\n", map {"$_\t=> " . recursive_breakdown($dse->{$_})} keys %$dse;
	} elsif (ref($dse) =~ /ARRAY/) {
		return " (\n" . join("\n", map {recursive_breakdown($_)} @$dse) . "\n)\n";
	} else {
		return $dse;
	}
}

sub ldap_dse {
	print "my root DSE: \n";
	print recursive_breakdown $ldap->root_dse();
}

sub ldap_search {
	my $query = $ldap->search(%params) 	or print "Search failed\n";
	$query->code and die sprintf 'error (code:%s) - %s', $query->code , $query->error;
	my $size = scalar($query->entries);
	my $i=5;
	print "\nNumber of records returned from search: $size.\n";
	($size > $i) and print "Displaying the last $i records.\n\n";
	foreach ($query->entries) {
		($size-- > $i) and next;
		$_->dump;
	}
}

sub ldap_add {
	my $cn = shift or return 0;
	my $mail = lc $cn;
	$mail =~ s/\s+/./;
	print "Adding user $cn\n";
	my $add;
	$add = $ldap->add(
		"cn=$cn," . $params{'base'},
		attr => [
			cn => $cn,
			sn => 'atz',
			mail => $mail . '@liblime.com',
			telephoneNumber => '1 614 266 9798',
			description => 'Implementer and Destroyer',
			objectclass => ['person','inetOrgPerson'],
		])
		or printf "Add failed (code %s): %s\n", ($add->code||'unknown'), ($add->error||'unknown');
}

END {
	($ldap) and $ldap->unbind;
	print "\ndone.\n";
}
