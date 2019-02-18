$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
  $dbh->do( "UPDATE `search_field` SET `name` = 'date-of-publication', `label` = 'date-of-publication' WHERE `name` = 'pubdate'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'title-series', `label` = 'title-series' WHERE `name` = 'se'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'identifier-standard', `label` = 'identifier-standard' WHERE `name` = 'identifier-standard'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'author', `label` = 'author' WHERE `name` = 'author'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'control-number', `label` = 'control-number' WHERE `name` = 'control-number'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'place-of-publication', `label` = 'place-of-publication' WHERE `name` = 'place'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'date-of-acquisition', `label` = 'date-of-acquisition' WHERE `name` = 'acqdate'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'isbn', `label` = 'isbn' WHERE `name` = 'isbn'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'koha-auth-number', `label` = 'koha-auth-number' WHERE `name` = 'an'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'subject', `label` = 'subject' WHERE `name` = 'subject'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'publisher', `label` = 'publisher' WHERE `name` = 'publisher'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'record-source', `label` = 'record-source' WHERE `name` = 'record-source'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'title', `label` = 'title' WHERE `name` = 'title'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'local-classification', `label` = 'local-classification' WHERE `name` = 'local-classification'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'bib-level', `label` = 'bib-level' WHERE `name` = 'bib-level'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'microform-generation', `label` = 'microform-generation' WHERE `name` = 'microform-generation'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'material-type', `label` = 'material-type' WHERE `name` = 'material-type'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'bgf-number', `label` = 'bgf-number' WHERE `name` = 'bgf-number'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'number-db', `label` = 'number-db' WHERE `name` = 'number-db'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'number-natl-biblio', `label` = 'number-natl-biblio' WHERE `name` = 'number-natl-biblio'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'number-legal-deposit', `label` = 'number-legal-deposit' WHERE `name` = 'number-legal-deposit'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'issn', `label` = 'issn' WHERE `name` = 'issn'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'local-number', `label` = 'local-number' WHERE `name` = 'local-number'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'suppress', `label` = 'supress' WHERE `name` = 'suppress'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'bnb-card-number', `label` = 'bnb-card-number' WHERE `name` = 'bnb-card-number'" );
  $dbh->do( "UPDATE `search_field` SET `name` = 'date/time-last-modified', `label` = 'date/time-last-modified' WHERE `name` = 'date-time-last-modified'" );
  $dbh->do( "DELETE FROM `search_field` WHERE `name` = 'lc-cardnumber'" );
  $dbh->do( "DELETE FROM `search_marc_map` WHERE `id` NOT IN(SELECT `search_marc_map_id` FROM `search_marc_to_field`)" );

  SetVersion( $DBversion );
  print "Upgrade to $DBversion done (Bug 19575 - Use canonical field names and resolve aliased fields)\n";
}
