ALTER TABLE reserves ADD COLUMN itemtype VARCHAR(10) NULL DEFAULT NULL AFTER suspend_until;
ALTER TABLE reserves ADD KEY `itemtype` (`itemtype`);
ALTER TABLE reserves ADD CONSTRAINT `reserves_ibfk_5` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE old_reserves ADD COLUMN itemtype VARCHAR(10) NULL DEFAULT NULL AFTER suspend_until;
ALTER TABLE old_reserves ADD KEY `itemtype` (`itemtype`);
ALTER TABLE old_reserves ADD CONSTRAINT `old_reserves_ibfk_4` FOREIGN KEY (`itemtype`) REFERENCES `itemtypes` (`itemtype`) ON DELETE CASCADE ON UPDATE CASCADE;

INSERT INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
('AllowHoldItemTypeSelection','0','','If enabled, patrons and staff will be able to select the itemtype when placing a hold','YesNo');
