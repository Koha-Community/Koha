  DROP TABLE IF EXISTS `special_holidays`;
CREATE TABLE `special_holidays` (
                `id` int(11) NOT NULL auto_increment,
                `branchcode` varchar(4) NOT NULL default '',
                `day` smallint(6) NOT NULL default '0',
                `month` smallint(6) NOT NULL default '0',
                `year` smallint(6) NOT NULL default '0',
                `isexception` smallint(1) NOT NULL default '1',
                `title` varchar(50) NOT NULL default '',
                `description` text NOT NULL,
                PRIMARY KEY  (`id`)
) TYPE=MyISAM;


 DROP TABLE IF EXISTS `repeatable_holidays`;
CREATE TABLE `repeatable_holidays` (
                `id` int(11) NOT NULL auto_increment,
                `branchcode` varchar(4) NOT NULL default '',
                `weekday` smallint(6) default NULL,
                `day` smallint(6) default NULL,
                `month` smallint(6) default NULL,
                `title` varchar(50) NOT NULL default '',
                `description` text NOT NULL,
                PRIMARY KEY  (`id`)
) TYPE=MyISAM;





