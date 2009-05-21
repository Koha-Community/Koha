TRUNCATE aqbookfund;
INSERT INTO `aqbookfund` (`bookfundid`, `bookfundname`, `bookfundgroup`, `branchcode`) VALUES ('CHILD','Дитячі матеріали',NULL,'STL');
INSERT INTO `aqbookfund` (`bookfundid`, `bookfundname`, `bookfundgroup`, `branchcode`) VALUES ('DISK','Електронні носії',NULL,'STL');
INSERT INTO `aqbookfund` (`bookfundid`, `bookfundname`, `bookfundgroup`, `branchcode`) VALUES ('GEN','Загальний пакет',NULL,'STL');
INSERT INTO `aqbookfund` (`bookfundid`, `bookfundname`, `bookfundgroup`, `branchcode`) VALUES ('REF','Довідкові матеріали',NULL,'STL');

TRUNCATE aqbudget;
INSERT INTO `aqbudget` (`bookfundid`, `startdate`, `enddate`, `budgetamount`, `aqbudgetid`, `branchcode`) VALUES ('CHILD','2008-01-01','2008-12-31','5000.00',1,'');
INSERT INTO `aqbudget` (`bookfundid`, `startdate`, `enddate`, `budgetamount`, `aqbudgetid`, `branchcode`) VALUES ('GEN','2008-01-01','2008-12-31','20000.00',2,'STL');
INSERT INTO `aqbudget` (`bookfundid`, `startdate`, `enddate`, `budgetamount`, `aqbudgetid`, `branchcode`) VALUES ('REF','2008-01-01','2008-12-31','5000.00',3,'STL');
INSERT INTO `aqbudget` (`bookfundid`, `startdate`, `enddate`, `budgetamount`, `aqbudgetid`, `branchcode`) VALUES ('GEN','2008-01-01','2008-12-31','10000.00',4,'STL');
INSERT INTO `aqbudget` (`bookfundid`, `startdate`, `enddate`, `budgetamount`, `aqbudgetid`, `branchcode`) VALUES ('DISK','2008-02-01','2008-07-25','2000.00',5,'STL');
