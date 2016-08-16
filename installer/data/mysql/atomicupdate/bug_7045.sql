update marc_subfield_structure set defaultvalue=REPLACE(defaultvalue, 'YYYY', '<<YYYY>>') where defaultvalue like "%YYYY%" and defaultvalue not like "%<<YYYY>>%";
update marc_subfield_structure set defaultvalue=REPLACE(defaultvalue, 'MM', '<<MM>>') where defaultvalue like "%MM%" and defaultvalue not like "%<<MM>>%";
update marc_subfield_structure set defaultvalue=REPLACE(defaultvalue, 'DD', '<<DD>>') where defaultvalue like "%DD%" and defaultvalue not like "%<<DD>>%";
update marc_subfield_structure set defaultvalue=REPLACE(defaultvalue, 'user', '<<USER>>') where defaultvalue like "%user%" and defaultvalue not like "%<<USER>>%";
