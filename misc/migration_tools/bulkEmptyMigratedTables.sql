SET FOREIGN_KEY_CHECKS=0;

TRUNCATE action_logs;

TRUNCATE aqbasket;
TRUNCATE aqbasketgroups;
TRUNCATE aqbasketusers;
TRUNCATE aqbudgetborrowers;
TRUNCATE aqcontract;
TRUNCATE aqinvoices;
TRUNCATE aqorders;
TRUNCATE aqorders_items;
TRUNCATE aqorders_transfers;

TRUNCATE auth_header;

TRUNCATE biblio;
TRUNCATE biblioimages;
TRUNCATE biblioitems;

TRUNCATE borrowers;
TRUNCATE borrower_attributes;
TRUNCATE borrower_debarments;
TRUNCATE borrower_files;
TRUNCATE borrower_message_preferences;
TRUNCATE borrower_modifications;

TRUNCATE branchtransfers;

TRUNCATE collections_tracking;
TRUNCATE collections;

TRUNCATE deletedbiblio;
TRUNCATE deletedbiblioitems;
TRUNCATE deletedborrowers;
TRUNCATE deleteditems;

TRUNCATE import_auths;
TRUNCATE import_batches;
TRUNCATE import_biblios;
TRUNCATE import_items;
TRUNCATE import_records;
TRUNCATE import_record_matches;

TRUNCATE issues;
TRUNCATE old_issues;

TRUNCATE accountlines;

TRUNCATE messages;
TRUNCATE message_queue;

TRUNCATE patroncards;
TRUNCATE patron_lists;
TRUNCATE patron_list_patrons;
TRUNCATE pending_offline_operations;
##TRUNCATE ratings;

TRUNCATE reserves;
TRUNCATE hold_fill_targets;
TRUNCATE tmp_holdsqueue;
TRUNCATE old_reserves;

##TRUNCATE reviews;
TRUNCATE search_history;

TRUNCATE serial;
TRUNCATE serialitems;
TRUNCATE items;
TRUNCATE subscription;
TRUNCATE subscriptionhistory;
TRUNCATE subscriptionroutinglist;

TRUNCATE sessions; #Wow this table gets crazy big!
TRUNCATE social_data;
TRUNCATE statistics; #This table needs maintenance as well!
TRUNCATE suggestions;
TRUNCATE tags;
TRUNCATE tags_all;
TRUNCATE tags_approval;
TRUNCATE tags_index;

TRUNCATE virtualshelfcontents;
TRUNCATE virtualshelfshares;
TRUNCATE virtualshelves;
TRUNCATE zebraqueue;
