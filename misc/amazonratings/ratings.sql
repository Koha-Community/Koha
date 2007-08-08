-- MySQL dump 8.21
--
-- Host: localhost    Database: Koha2
---------------------------------------------------------
-- Server version	3.23.49-log

--
-- Table structure for table 'ratings'
--

CREATE TABLE ratings (
  biblioitemnumber int(11) NOT NULL default '0',
  biblionumber int(11) default NULL,
  rating varchar(10) default NULL,
  modified timestamp(14) NOT NULL,
  PRIMARY KEY  (biblioitemnumber)
) TYPE=MyISAM;

