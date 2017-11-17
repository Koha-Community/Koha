DROP TABLE IF EXISTS `reporting_statistics_tmp`;
CREATE TABLE `reporting_statistics_tmp` (
  `primary_id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `datetime` datetime DEFAULT NULL,
  `branch` varchar(10) DEFAULT NULL,
  `proccode` varchar(4) DEFAULT NULL,
  `value` double(16,4) DEFAULT NULL,
  `type` varchar(16) DEFAULT NULL,
  `other` mediumtext,
  `usercode` varchar(10) DEFAULT NULL,
  `itemnumber` int(11) DEFAULT NULL,
  `itemtype` varchar(10) DEFAULT NULL,
  `borrowernumber` int(11) DEFAULT NULL,
  `associatedborrower` int(11) DEFAULT NULL,
  `ccode` varchar(10) DEFAULT NULL,
  KEY `timeidx` (`datetime`),
  KEY `branch_idx` (`branch`),
  KEY `proccode_idx` (`proccode`),
  KEY `type_idx` (`type`),
  KEY `usercode_idx` (`usercode`),
  KEY `itemnumber_idx` (`itemnumber`),
  KEY `itemtype_idx` (`itemtype`),
  KEY `borrowernumber_idx` (`borrowernumber`),
  KEY `associatedborrower_idx` (`associatedborrower`),
  KEY `ccode_idx` (`ccode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

insert into reporting_statistics_tmp (datetime, branch, proccode, value, type, other, usercode, itemnumber, itemtype, borrowernumber, associatedborrower, ccode) select datetime, branch, proccode, value, type, other, usercode, itemnumber, itemtype, borrowernumber, associatedborrower, ccode from statistics where usercode in ('HENKILO', 'MUUHUOL', 'KOTIPALVEL', 'LAPSI', 'YHTEISO') and other != 'KONVERSIO' and type in ('issue', 'renew') order by datetime;
