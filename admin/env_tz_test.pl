#!/usr/bin/perl 

use strict;
use warnings;
use CGI;
# use Data::Dumper;

use C4::Context;
use C4::Auth;

my $q = CGI->new();
my ($template, $loggedinuser, $cookie) = get_template_and_user({
	   template_name => "admin/admin-home.tmpl",	# whatever, we don't really use the template anyway.
			   query => $q,
			 	type => "intranet",
	 authnotrequired => 0,
 	   flagsrequired => {parameters => 1},
		       debug => 1,
});

my $dbh = C4::Context->dbh;
my  $tz_sth = $dbh->prepare("SHOW VARIABLES LIKE 'time_zone'");
$tz_sth->execute();
my $now_sth = $dbh->prepare("SELECT now()");
$now_sth->execute();

print $q->header(), 
	$q->html(
	$q->body(
	$q->p("This is a test for debugging purposes.  It isn't supposed to look pretty.")
	.
	$q->h1("Dumping ENV:") 
	.
	join("\n<br\>", map {"$_ = $ENV{$_}"} sort keys %ENV)
	.
	$q->h1("Checking different TIME elements in the system:") 
	. "\n" . $q->p("perl localime: " . localtime)
	. "\n" . $q->p( "system(date): " . `date`)
	. "\n" . $q->p( "mysql dbh (Context) time_zone : " .  $tz_sth->fetchrow)
	. "\n" . $q->p( "mysql dbh (Context) now() : "     . $now_sth->fetchrow)
	)), "\n";

__END__

=pod

=head1 MULTIPLE TIME ZONE SUPPORT

Koha supports running multiple instances on the same server, even if they need to be homed
in different timezones.  However, your database must have the timezones installed (see below).

If you are only running one installation of Koha, and want to change the timezone of the server,
please do NOT use this feature at all, and instead set your system timezone via the OS.  If you 
are running multiple Kohas, all in the same timezone, do the same. 

Only use this feature if
you are running multiple Kohas on the same server, and they are not in the same timezone.  

=head2 Perl

For the most part, in execution perl will respect the environmental
variable TZ, if it is set.  This affects calls to localtime() and other similar functions.
Remember that the environment will be different for different users, and for cron jobs.  
See the example below.

=head2 Apache2

We affect the running perl code of Koha with the Apache directive:

SetEnv TZ "US/Central"

This should be added inside the VirtualHost definition for the intended Koha instance.  In 
almost ALL cases, be sure to set it for both INTRANET and OPAC VirtualHosts.  Remember this
does not affect the command line environment for any terminal sessions, or your cron jobs.

=head2 Database (mysql)

Your MySQL installation must be configured with appropriate time zones.  This extends beyond
Koha and affects mysql itself.  On debian, for example, you can use:

	mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -u root mysql

See http://dev.mysql.com/doc/refman/5.0/en/time-zone-support.html

=head2 cron/crontab

Current versions of cron in debian allow ENV variables to be set in the lines preceeding 
scheduled commands.  They will be exported to the environment of the scheduled job.  This is 
an example for crontab:

	TZ="US/Central"
	# m h  dom mon dow   command
	0  1 * * *  /home/liblime/kohaclone/misc/cronjobs/overdue_notices.pl
	15 * * * *  /home/liblime/kohaclone/misc/cronjobs/process_message_queue.pl
	*/10 * * * *   /home/liblime/kohaclone/misc/migration_tools/rebuild_zebra.pl -b -z >/dev/null

=head1 EXAMPLE

Try these on a command line to confirm Context is setting time_zone based on TZ:

perl -MC4::Context -e 'my $dbh=C4::Context->dbh; my $tz_sth=$dbh->prepare(q(SHOW VARIABLES LIKE "time_zone"));
 	$tz_sth->execute(); print "mysql dbh (Context) time_zone : " .  $tz_sth->fetchrow, "\n";'

export TZ="US/Central";  # or any TZ other than the current one.

perl -MC4::Context -e 'my $dbh=C4::Context->dbh; my $tz_sth=$dbh->prepare(q(SHOW VARIABLES LIKE "time_zone"));
 	$tz_sth->execute(); print "mysql dbh (Context) time_zone : " .  $tz_sth->fetchrow, "\n";'

Then update your VirtualHosts to do, for example:

	SetEnv TZ "US/Central"

Reset Apache, then on your intranet check out the debug page:

	cgi-bin/koha/admin/env_tz_test.pl

The TZ that Koha has in effect and the TZ from the database should be displayed at the bottom.
Hopefully they match what you set.

=head1 BUGS

WARNING: Multiple timezones may or may not work under mod_perl and mod_perl2.  

=head1 AUTHOR

	Joe Atzberger
	atz at liblime.com

=cut

