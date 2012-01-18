#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh = C4::Context->dbh;

$dbh->do(
    q|CREATE TABLE `biblioimages` (
      `imagenumber` int(11) NOT NULL AUTO_INCREMENT,
      `biblionumber` int(11) NOT NULL,
      `mimetype` varchar(15) NOT NULL,
      `imagefile` mediumblob NOT NULL,
      `thumbnail` mediumblob NOT NULL,
      PRIMARY KEY (`imagenumber`),
      CONSTRAINT `bibliocoverimage_fk1` FOREIGN KEY (`biblionumber`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8|
);
$dbh->do(
q|INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('OPACLocalCoverImages','0','Display local cover images on OPAC search and details pages.','1','YesNo')|
);
$dbh->do(
q|INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('LocalCoverImages','0','Display local cover images on intranet search and details pages.','1','YesNo')|
);
$dbh->do(
q|INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES ('AllowMultipleCovers','0','Allow multiple cover images to be attached to each bibliographic record.','1','YesNo')|
);
$dbh->do(
q|INSERT INTO permissions (module_bit, code, description) VALUES (13, 'upload_local_cover_images', 'Upload local cover images')|
);
print "Upgrade done (Added support for local cover images)\n";
