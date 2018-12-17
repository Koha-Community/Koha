DROP TABLE IF EXISTS `reporting_import_settings`;
CREATE TABLE reporting_import_settings (
    primary_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    primary_column VARCHAR(255),
    last_inserted VARCHAR(255),
    last_selected VARCHAR(255),
    last_allowed_select VARCHAR(255),
    last_inserted_fact VARCHAR(255),
    batch_limit VARCHAR(255),
    UNIQUE(name)
);

insert into reporting_import_settings (name, primary_column, batch_limit) values ('loans_fact', 'datetime', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('fines_overdue_fact', 'accountlines_id', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('fines_paid_fact', 'accountlines_id', '20000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('borrowers_new_fact', 'borrowernumber', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('borrowers_deleted_fact', 'borrowernumber', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('acquisitions_fact', 'itemnumber', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('items_fact', 'itemnumber', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('deleteditems_fact', 'itemnumber', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('returns_fact', 'datetime', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('reserves_fact', 'timestamp', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('items_update', 'itemnumber', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('messages_fact', 'message_id', '30000');
insert into reporting_import_settings (name, primary_column, batch_limit) values ('reserves_old_fact', 'timestamp', '30000');


DROP TABLE IF EXISTS `reporting_item_dim`;
CREATE TABLE reporting_item_dim (
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
    UNIQUE(itemnumber)
) ENGINE=InnoDB CHARACTER SET=utf8;
CREATE INDEX itemnumber_idx ON reporting_item_dim (itemnumber);
CREATE INDEX published_year_idx ON reporting_item_dim (published_year);
CREATE INDEX acquired_year_idx ON reporting_item_dim (acquired_year);
CREATE INDEX collection_code_idx ON reporting_item_dim (collection_code);
CREATE INDEX language_idx ON reporting_item_dim (language);
CREATE INDEX barcode_idx ON reporting_item_dim (barcode);
CREATE INDEX biblioitemnumber_idx ON reporting_item_dim (biblioitemnumber);

CREATE INDEX cn_class_primary_idx ON reporting_item_dim (cn_class_primary);
CREATE INDEX cn_class_fict_idx ON reporting_item_dim (cn_class_fict);
CREATE INDEX language_all_idx ON reporting_item_dim (language_all);


DROP TABLE IF EXISTS `reporting_date_dim`;
CREATE TABLE reporting_date_dim (
    date_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    year INT(4) NOT NULL,
    month INT(2) NOT NULL,
    day INT(2) NOT NULL,
    hour INT(2) NOT NULL
);

DROP TABLE IF EXISTS `reporting_borrower_dim`;
CREATE TABLE reporting_borrower_dim (
    borrower_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    borrowernumber INT(11) NOT NULL,
    categorycode VARCHAR(30),
    cardnumber VARCHAR(30),
    age_group VARCHAR(30) ,
    postcode VARCHAR(30),
    UNIQUE(borrowernumber)
);
CREATE INDEX cardnumber_idx ON reporting_borrower_dim (cardnumber);
CREATE INDEX categorycode_idx ON reporting_borrower_dim (categorycode);

DROP TABLE IF EXISTS `reporting_location_dim`;
CREATE TABLE reporting_location_dim (
    location_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    branch VARCHAR(30) NOT NULL,
    location VARCHAR(30) NOT NULL,
    location_type VARCHAR(30) NOT NULL,
    location_age VARCHAR(30) NOT NULL,
    UNIQUE(branch, location, location_type, location_age)
);

CREATE INDEX branch_idx ON reporting_location_dim (branch);
CREATE INDEX location_idx ON reporting_location_dim (location);
CREATE INDEX location_type_idx ON reporting_location_dim (location_type);

DROP TABLE IF EXISTS `reporting_loans_fact`;
CREATE TABLE reporting_loans_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    borrower_id BIGINT UNSIGNED NOT NULL,
    loan_ccode VARCHAR(30) NOT NULL,
    loan_type VARCHAR(30) NOT NULL,
    loaned_amount INT(11) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_loans_fact (date_id);
CREATE INDEX item_id_idx ON reporting_loans_fact (item_id);
CREATE INDEX location_id_idx ON reporting_loans_fact (location_id);
CREATE INDEX borrower_id_idx ON reporting_loans_fact (borrower_id);
CREATE INDEX loan_type_idx ON reporting_loans_fact (loan_type);
CREATE INDEX loaned_amount_idx ON reporting_loans_fact (loaned_amount);
CREATE INDEX loan_ccode_idx ON reporting_loans_fact (loan_ccode);

DROP TABLE IF EXISTS `reporting_fines_overdue_fact`;
CREATE TABLE reporting_fines_overdue_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    borrower_id BIGINT UNSIGNED NOT NULL,
    is_overdue VARCHAR(30) NOT NULL,
    amount decimal(28,6) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_fines_overdue_fact (date_id);
CREATE INDEX location_id_idx ON reporting_fines_overdue_fact (location_id);
CREATE INDEX borrower_id_idx ON reporting_fines_overdue_fact (borrower_id);
CREATE INDEX is_overdue_idx ON reporting_fines_overdue_fact (is_overdue);


DROP TABLE IF EXISTS `reporting_borrowers_fact`;
CREATE TABLE reporting_borrowers_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    borrower_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    activity_type INT(11) UNSIGNED NOT NULL,
    amount int(11) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_borrowers_fact (date_id);
CREATE INDEX location_id_idx ON reporting_borrowers_fact (location_id);
CREATE INDEX borrower_id_idx ON reporting_borrowers_fact (borrower_id);
CREATE INDEX activity_type_idx ON reporting_borrowers_fact (activity_type);


DROP TABLE IF EXISTS `reporting_acquisitions_fact`;
CREATE TABLE reporting_acquisitions_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    quantity INT(11) UNSIGNED NOT NULL,
    amount decimal(28,6) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_acquisitions_fact (date_id);
CREATE INDEX location_id_idx ON reporting_acquisitions_fact (location_id);
CREATE INDEX item_id_idx ON reporting_acquisitions_fact (item_id);

DROP TABLE IF EXISTS `reporting_items_fact`;
CREATE TABLE reporting_items_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    is_deleted int(11) UNSIGNED NOT NULL,
    amount int(11) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_items_fact (date_id);
CREATE INDEX location_id_idx ON reporting_items_fact (location_id);
CREATE INDEX item_id_idx ON reporting_items_fact (item_id);
CREATE INDEX is_deleted_idx ON reporting_items_fact (is_deleted);


DROP TABLE IF EXISTS `reporting_deleteditems_fact`;
CREATE TABLE reporting_deleteditems_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    amount int(11) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_deleteditems_fact (date_id);
CREATE INDEX location_id_idx ON reporting_deleteditems_fact (location_id);
CREATE INDEX item_id_idx ON reporting_deleteditems_fact (item_id);

DROP TABLE IF EXISTS `reporting_update_items`;
CREATE TABLE reporting_update_items (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    itemnumber INT(11) UNSIGNED NOT NULL
);

CREATE INDEX item_number_idx ON reporting_update_items (itemnumber);

DROP TABLE IF EXISTS `reporting_returns_fact`;
CREATE TABLE reporting_returns_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    borrower_id BIGINT UNSIGNED NOT NULL,
    loan_type VARCHAR(30) NOT NULL,
    amount INT(11) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_returns_fact (date_id);
CREATE INDEX item_id_idx ON reporting_returns_fact (item_id);
CREATE INDEX location_id_idx ON reporting_returns_fact (location_id);
CREATE INDEX borrower_id_idx ON reporting_returns_fact (borrower_id);
CREATE INDEX loan_type_idx ON reporting_returns_fact (loan_type);


DROP TABLE IF EXISTS `reporting_reserves_fact`;
CREATE TABLE reporting_reserves_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    item_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    borrower_id BIGINT UNSIGNED NOT NULL,
    reserve_status VARCHAR(30) NOT NULL,
    amount INT(11) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_reserves_fact (date_id);
CREATE INDEX item_id_idx ON reporting_reserves_fact (item_id);
CREATE INDEX location_id_idx ON reporting_reserves_fact (location_id);
CREATE INDEX borrower_id_idx ON reporting_reserves_fact (borrower_id);
CREATE INDEX reserve_status_idx ON reporting_reserves_fact (reserve_status);


DROP TABLE IF EXISTS `reporting_fines_paid_fact`;
CREATE TABLE reporting_fines_paid_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date_id BIGINT UNSIGNED NOT NULL,
    location_id BIGINT UNSIGNED NOT NULL,
    borrower_id BIGINT UNSIGNED NOT NULL,
    amount decimal(28,6) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_fines_paid_fact (date_id);
CREATE INDEX location_id_idx ON reporting_fines_paid_fact (location_id);
CREATE INDEX borrower_id_idx ON reporting_fines_paid_fact (borrower_id);


DROP TABLE IF EXISTS `reporting_messages_fact`;
CREATE TABLE reporting_messages_fact (
    primary_key BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    location_id BIGINT UNSIGNED NOT NULL,
    date_id BIGINT UNSIGNED NOT NULL,
    borrower_id BIGINT UNSIGNED NOT NULL,
    transport_type VARCHAR(30) NOT NULL,
    message_type VARCHAR(30) NOT NULL,
    amount INT(11) UNSIGNED NOT NULL
);

CREATE INDEX date_id_idx ON reporting_messages_fact (date_id);
CREATE INDEX location_id_idx ON reporting_messages_fact (location_id);
CREATE INDEX borrower_id_idx ON reporting_messages_fact (borrower_id);
CREATE INDEX transport_type_idx ON reporting_messages_fact (transport_type);
CREATE INDEX message_type_idx ON reporting_messages_fact (message_type);


DROP TABLE IF EXISTS `reporting_acquisitions_isfirst`;
CREATE TABLE reporting_acquisitions_isfirst (
    item_id BIGINT UNSIGNED NOT NULL,
    branch_group VARCHAR(30) NOT NULL
);

CREATE INDEX item_id_idx ON reporting_acquisitions_isfirst (item_id);
CREATE INDEX branch_group_idx ON reporting_acquisitions_isfirst (branch_group);
