DELETE FROM authorised_values WHERE category='RETURN_CLAIM_RESOLUTION';

INSERT INTO authorised_values (category, authorised_value, lib) VALUES
('RETURN_CLAIM_RESOLUTION', 'RET_BY_PATRON', 'Returned by patron'),
('RETURN_CLAIM_RESOLUTION', 'FOUND_IN_LIB',  'Found in library');
