-- MySQL dump 9.08
--
-- Host: localhost    Database: Koha
---------------------------------------------------------
-- Server version	4.0.13-log

--
-- Table structure for table 'attempted_contacts'
--

CREATE TABLE attempted_contacts (
  borrowernumber int(11) default NULL,
  method varchar(50) default NULL,
  address varchar(255) default NULL,
  result int(11) default NULL,
  message text,
  date datetime default NULL
) TYPE=MyISAM;

