CREATE INDEX cn_class_primary_idx ON reporting_item_dim (cn_class_primary);
CREATE INDEX cn_class_fict_idx ON reporting_item_dim (cn_class_fict);
CREATE INDEX language_all_idx ON reporting_item_dim (language_all);
CREATE INDEX categorycode_idx ON reporting_borrower_dim (categorycode);

ALTER TABLE `reporting_loans_fact`
ADD loan_ccode VARCHAR(30) NOT NULL;
CREATE INDEX loan_ccode_idx ON reporting_loans_fact (loan_ccode);

insert into reporting_import_settings (name, primary_column, batch_limit) values ('reserves_old_fact', 'timestamp', '30000');

update reporting_import_settings set primary_column = 'timestamp'  where name = 'reserves_fact';




