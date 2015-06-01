--
-- Adds OpacLangSelectorMode syspref for bug 14252
--
INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('OpacLangSelectorMode','footer','top|both|footer','Select the location to display the language selector','Choice');
