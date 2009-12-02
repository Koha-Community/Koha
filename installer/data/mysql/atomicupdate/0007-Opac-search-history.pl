#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;

$dbh->do("INSERT INTO `systempreferences` (`variable`, `value`, `options`, `explanation`, `type`) VALUES ('EnableOpacSearchHistory', '1', '', 'Enable or disable opac search history', 'YesNo')");

my $create = <<END;
CREATE TABLE IF NOT EXISTS `search_history` (
  `userid` int(11) NOT NULL,
  `sessionid` varchar(32) NOT NULL,
  `query_desc` varchar(255) NOT NULL,
  `query_cgi` varchar(255) NOT NULL,
  `total` int(11) NOT NULL,
  `time` timestamp NOT NULL default CURRENT_TIMESTAMP,
  KEY `userid` (`userid`),
  KEY `sessionid` (`sessionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Opac search history results';
END

$dbh->do($create);

print "Upgrade done (added OPAC search history preference and table)\n";
