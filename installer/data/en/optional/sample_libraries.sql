INSERT INTO branchcategories ( `categorycode`,`categoryname`,`codedescription`) VALUES

-- Org Unit-style categories
('CON', 'Consortium', 'Consortium library category for scoped searching'),
('SYS', 'Library System Library', 'Library System category for scoped searching'),
('BRA', 'Branch Library', 'Branch library category for scoped searching'),

('ST', 'Status', 'This location can be used for status purposes'),

-- HLT-style categories
('CU', 'Current Library', 'Holding libraries are used in the OPAC search (items.holdingbranch)'),
('IS', 'Lending Library', 'Lending libraries can checkout items, return, fulfill holds'),
('PE', 'Permanent Library', 'Permanent libraries can be used to set an item\'s home location (items.homebranch)');

INSERT INTO branches ( `branchcode`,`branchname`,`branchaddress1`) VALUES
('ML','Shannon Media Library','372 Post St'),
('SPL','Shannon',''),
('MAIN','Shannon Public Library','123 Library Way'),
('SRR','Shannon Reading Room',''),
('SHM','Shannon Mending',''),
('SHP','Shannon Processing',''),

('SAT1','Levin','449 E. State Street'),
('SAT2','Foxton','22 Main Street');

INSERT INTO branchrelations ( `branchcode`,`categorycode`) VALUES
('ML','BRA'), -- branch-level library
('ML','IS'),
('ML','CU'),

('MAIN','PE'), -- for acqui

('SPL','SYS'), -- system-level library
('SPL','IS'),
('SPL','CU'), -- you can find, loan

('SRR','CU'), -- you can find, but you can't loan

('SHM','ST'),
('SHP','ST'),

('SAT1','BRA'),
('SAT2','BRA');
