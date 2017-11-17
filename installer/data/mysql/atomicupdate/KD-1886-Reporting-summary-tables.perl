$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

	$dbh->do ( "CREATE TABLE reporting_import_settings (
	            primary_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            name VARCHAR(255) NOT NULL,
	            primary_column VARCHAR(255),
	            last_inserted VARCHAR(255),
	            last_selected VARCHAR(255),
	            last_allowed_select VARCHAR(255),
	            last_inserted_fact VARCHAR(255),
	            batch_limit VARCHAR(255),
	            UNIQUE(name));" );

	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('loans_fact', 'datetime', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('fines_overdue_fact', 'accountlines_id', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('fines_paid_fact', 'accountlines_id', '20000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('borrowers_new_fact', 'borrowernumber', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('borrowers_deleted_fact', 'borrowernumber', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('acquisitions_fact', 'itemnumber', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('items_fact', 'itemnumber', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('deleteditems_fact', 'itemnumber', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('returns_fact', 'datetime', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('reserves_fact', 'reserve_id', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('items_update', 'itemnumber', '30000');" );
	$dbh->do ( "INSERT INTO reporting_import_settings (name, primary_column, batch_limit) VALUES ('messages_fact', 'message_id', '30000');" );

	$dbh->do ( "CREATE TABLE reporting_item_dim (
	            item_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            itemnumber INT(11) UNSIGNED NOT NULL,
	            biblioitemnumber INT(11) UNSIGNED NOT NULL,
	            title VARCHAR(255),
	            acquired_year INT(4),
	            published_year INT(4),
	            cn_class VARCHAR(30),
	            cn_class_fict VARCHAR(30),
	            cn_class_primary VARCHAR(30),
	            cn_class_1_dec INT(4),
	            cn_class_2_dec INT(4),
	            cn_class_3_dec INT(4),
	            cn_class_signum VARCHAR(30),
	            itemtype VARCHAR(30),
	            itemtype_okm VARCHAR(30),
	            is_yle INT(11) NOT NULL default 0,
	            language VARCHAR(30),
	            language_all VARCHAR(30),
	            collection_code VARCHAR(30),
	            barcode varchar(20),
	            datelastborrowed DATE NULL,
	            UNIQUE(itemnumber)) ENGINE=InnoDB CHARACTER SET=utf8;" );

	$dbh->do ( "CREATE INDEX itemnumber_idx ON reporting_item_dim (itemnumber);" );
	$dbh->do ( "CREATE INDEX published_year_idx ON reporting_item_dim (published_year);" );
	$dbh->do ( "CREATE INDEX acquired_year_idx ON reporting_item_dim (acquired_year);" );
	$dbh->do ( "CREATE INDEX collection_code_idx ON reporting_item_dim (collection_code);" );
	$dbh->do ( "CREATE INDEX language_idx ON reporting_item_dim (language);" );
	$dbh->do ( "CREATE INDEX barcode_idx ON reporting_item_dim (barcode);" );
	$dbh->do ( "CREATE INDEX biblioitemnumber_idx ON reporting_item_dim (biblioitemnumber);" );

	$dbh->do ( "CREATE TABLE reporting_date_dim (
	            date_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            year INT(4) NOT NULL,
	            month INT(2) NOT NULL,
	            day INT(2) NOT NULL,
	            hour INT(2) NOT NULL);" );

	$dbh->do ( "CREATE TABLE reporting_borrower_dim (
	            borrower_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            borrowernumber INT(11) NOT NULL,
	            categorycode VARCHAR(30),
	            cardnumber VARCHAR(30),
	            age_group VARCHAR(30) ,
	            postcode VARCHAR(30),
	            UNIQUE(borrowernumber));" );

	$dbh->do ( "CREATE INDEX cardnumber_idx ON reporting_borrower_dim (cardnumber);" );

	$dbh->do ( "CREATE TABLE reporting_location_dim (
	            location_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            branch VARCHAR(30) NOT NULL,
	            location VARCHAR(30) NOT NULL,
	            location_type VARCHAR(30) NOT NULL,
	            location_age VARCHAR(30) NOT NULL,
	            UNIQUE(branch, location, location_type, location_age));" );

	$dbh->do ( "CREATE INDEX branch_idx ON reporting_location_dim (branch);" );
	$dbh->do ( "CREATE INDEX location_idx ON reporting_location_dim (location);" );
	$dbh->do ( "CREATE INDEX location_type_idx ON reporting_location_dim (location_type);" );

	$dbh->do ( "CREATE TABLE reporting_loans_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            item_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            borrower_id BIGINT UNSIGNED NOT NULL,
	            loan_type VARCHAR(30) NOT NULL,
	            loaned_amount INT(11) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_loans_fact (date_id);" );
	$dbh->do ( "CREATE INDEX item_id_idx ON reporting_loans_fact (item_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_loans_fact (location_id);" );
	$dbh->do ( "CREATE INDEX borrower_id_idx ON reporting_loans_fact (borrower_id);" );
	$dbh->do ( "CREATE INDEX loan_type_idx ON reporting_loans_fact (loan_type);" );
	$dbh->do ( "CREATE INDEX loaned_amount_idx ON reporting_loans_fact (loaned_amount);" );

	$dbh->do ( "CREATE TABLE reporting_fines_overdue_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            borrower_id BIGINT UNSIGNED NOT NULL,
	            is_overdue VARCHAR(30) NOT NULL,
	            amount decimal(28,6) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_fines_overdue_fact (date_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_fines_overdue_fact (location_id);" );
	$dbh->do ( "CREATE INDEX borrower_id_idx ON reporting_fines_overdue_fact (borrower_id);" );
	$dbh->do ( "CREATE INDEX is_overdue_idx ON reporting_fines_overdue_fact (is_overdue);" );


	$dbh->do ( "CREATE TABLE reporting_borrowers_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            borrower_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            activity_type INT(11) UNSIGNED NOT NULL,
	            amount int(11) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_borrowers_fact (date_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_borrowers_fact (location_id);" );
	$dbh->do ( "CREATE INDEX borrower_id_idx ON reporting_borrowers_fact (borrower_id);" );
	$dbh->do ( "CREATE INDEX activity_type_idx ON reporting_borrowers_fact (activity_type);" );


	$dbh->do ( "CREATE TABLE reporting_acquisitions_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            item_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            quantity INT(11) UNSIGNED NOT NULL,
	            amount decimal(28,6) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_acquisitions_fact (date_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_acquisitions_fact (location_id);" );
	$dbh->do ( "CREATE INDEX item_id_idx ON reporting_acquisitions_fact (item_id);" );

	$dbh->do ( "CREATE TABLE reporting_items_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            item_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            is_deleted int(11) UNSIGNED NOT NULL,
	            amount int(11) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_items_fact (date_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_items_fact (location_id);" );
	$dbh->do ( "CREATE INDEX item_id_idx ON reporting_items_fact (item_id);" );
	$dbh->do ( "CREATE INDEX is_deleted_idx ON reporting_items_fact (is_deleted);" );


	$dbh->do ( "CREATE TABLE reporting_deleteditems_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            item_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            amount int(11) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_deleteditems_fact (date_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_deleteditems_fact (location_id);" );
	$dbh->do ( "CREATE INDEX item_id_idx ON reporting_deleteditems_fact (item_id);" );

	$dbh->do ( "CREATE TABLE reporting_update_items (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            itemnumber INT(11) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX item_number_idx ON reporting_update_items (itemnumber);" );

	$dbh->do ( "CREATE TABLE reporting_returns_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            item_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            borrower_id BIGINT UNSIGNED NOT NULL,
	            loan_type VARCHAR(30) NOT NULL,
	            amount INT(11) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_returns_fact (date_id);" );
	$dbh->do ( "CREATE INDEX item_id_idx ON reporting_returns_fact (item_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_returns_fact (location_id);" );
	$dbh->do ( "CREATE INDEX borrower_id_idx ON reporting_returns_fact (borrower_id);" );
	$dbh->do ( "CREATE INDEX loan_type_idx ON reporting_returns_fact (loan_type);" );


	$dbh->do ( "CREATE TABLE reporting_reserves_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            item_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            borrower_id BIGINT UNSIGNED NOT NULL,
	            reserve_status VARCHAR(30) NOT NULL,
	            amount INT(11) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_reserves_fact (date_id);" );
	$dbh->do ( "CREATE INDEX item_id_idx ON reporting_reserves_fact (item_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_reserves_fact (location_id);" );
	$dbh->do ( "CREATE INDEX borrower_id_idx ON reporting_reserves_fact (borrower_id);" );
	$dbh->do ( "CREATE INDEX reserve_status_idx ON reporting_reserves_fact (reserve_status);" );


	$dbh->do ( "CREATE TABLE reporting_fines_paid_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            date_id BIGINT UNSIGNED NOT NULL,
	            location_id BIGINT UNSIGNED NOT NULL,
	            borrower_id BIGINT UNSIGNED NOT NULL,
	            amount decimal(28,6) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_fines_paid_fact (date_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_fines_paid_fact (location_id);" );
	$dbh->do ( "CREATE INDEX borrower_id_idx ON reporting_fines_paid_fact (borrower_id);" );


	$dbh->do ( "CREATE TABLE reporting_messages_fact (
	            primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
	            location_id BIGINT UNSIGNED NOT NULL,
	            date_id BIGINT UNSIGNED NOT NULL,
	            borrower_id BIGINT UNSIGNED NOT NULL,
	            transport_type VARCHAR(30) NOT NULL,
	            message_type VARCHAR(30) NOT NULL,
	            amount INT(11) UNSIGNED NOT NULL);" );

	$dbh->do ( "CREATE INDEX date_id_idx ON reporting_messages_fact (date_id);" );
	$dbh->do ( "CREATE INDEX location_id_idx ON reporting_messages_fact (location_id);" );
	$dbh->do ( "CREATE INDEX borrower_id_idx ON reporting_messages_fact (borrower_id);" );
	$dbh->do ( "CREATE INDEX transport_type_idx ON reporting_messages_fact (transport_type);" );
	$dbh->do ( "CREATE INDEX message_type_idx ON reporting_messages_fact (message_type);" );


	$dbh->do ( "CREATE TABLE reporting_acquisitions_isfirst (
	            item_id BIGINT UNSIGNED NOT NULL,
	            branch_group VARCHAR(30) NOT NULL);" );

	$dbh->do ( "CREATE INDEX item_id_idx ON reporting_acquisitions_isfirst (item_id);" );
	$dbh->do ( "CREATE INDEX branch_group_idx ON reporting_acquisitions_isfirst (branch_group);" );

	$dbh->do("INSERT INTO `systempreferences` (variable,value,explanation,options,type) VALUES('OKM','--- \nblockStatisticsGeneration: 1\nitemTypeToStatisticalCategory: \n  BK: Books\n  CF: Others\n  CR: Others\n  MU: Recordings\njuvenileShelvingLocations: \n  - CHILD\n  - AV\n',NULL,'OKM statistics configuration and statistical type mappings','Textarea')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1886 - reporting summary tables)\n";
}
