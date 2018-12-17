ALTER TABLE `reporting_loans_fact`
ADD loan_ccode VARCHAR(30) NOT NULL;

CREATE INDEX loan_ccode_idx ON reporting_loans_fact (loan_ccode);
