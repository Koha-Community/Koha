DELETE cr.* FROM course_reserves AS cr LEFT JOIN course_items USING(ci_id) WHERE course_items.ci_id IS NULL;
ALTER TABLE course_reserves add CONSTRAINT course_reserves_ibfk_2 FOREIGN KEY (ci_id) REFERENCES course_items (ci_id) ON DELETE CASCADE ON UPDATE CASCADE;
