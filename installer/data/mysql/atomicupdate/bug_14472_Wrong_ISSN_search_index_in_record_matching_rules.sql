UPDATE matchpoints SET search_index ='issn' where matcher_id = (SELECT matcher_id FROM marc_matchers WHERE code = 'ISSN');
