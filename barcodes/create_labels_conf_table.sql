-- MySQL dump 9.11
--
-- Host: localhost    Database: opusdev
-- ------------------------------------------------------
-- Server version	4.0.24_Debian-10sarge1

--
-- Table structure for table `labels_conf`
--

DROP TABLE IF EXISTS `labels_conf`;
CREATE TABLE `labels_conf` (
  `id` int(4) NOT NULL auto_increment,
  `barcodetype` char(100) default '',
  `title` tinyint(1) default '0',
  `isbn` tinyint(1) default '0',
  `itemtype` tinyint(1) default '0',
  `barcode` tinyint(1) default '0',
  `dewey` tinyint(1) default '0',
  `class` tinyint(1) default '0',
  `author` tinyint(1) default '0',
  `papertype` char(100) default '',
  `startrow` int(2) default NULL,
  `printingtype` char(10) default NULL,
  `guidebox` tinyint(1) default NULL,
  PRIMARY KEY  (`id`)
) TYPE=MyISAM;

--
-- Table structure for table `labels`
--

DROP TABLE IF EXISTS `labels`;
CREATE TABLE `labels` (
  `labelid` int(11) NOT NULL auto_increment,
  `itemnumber` varchar(100) NOT NULL default '',
  `timestamp` timestamp(14) NOT NULL,
  PRIMARY KEY  (`labelid`)
) TYPE=MyISAM;





