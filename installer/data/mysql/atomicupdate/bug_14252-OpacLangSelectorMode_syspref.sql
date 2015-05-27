--
-- Adds OpacLangSelectorMode syspref for bug 14252
--
INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('OpacLangSelectorMode','both','both|head|foot','Select the location to display the language selector','Choice');
