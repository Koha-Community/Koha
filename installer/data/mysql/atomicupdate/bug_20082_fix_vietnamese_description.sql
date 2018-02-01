INSERT IGNORE INTO language_descriptions(subtag, type, lang, description)
  VALUES ('vi', 'language', 'de', 'Vietnamesisch');
UPDATE language_descriptions SET description = 'Tiếng Việt'
  WHERE subtag = 'vi' and type = 'language' and lang = 'vi';

-- print "Upgrade to $DBversion done (Bug 20082 - Update descriptions of Vietnamese language)\n";
