-- move marc21_field_003.pl 040c and 040d to marc21_orgcode.pl
update marc_subfield_structure set value_builder='marc21_orgcode.pl' where value_builder IN ( 'marc21_field_003.pl', 'marc21_field_040c.pl', 'marc21_field_040d.pl' );
update auth_subfield_structure set value_builder='marc21_orgcode.pl' where value_builder IN ( 'marc21_field_003.pl', 'marc21_field_040c.pl', 'marc21_field_040d.pl' );
