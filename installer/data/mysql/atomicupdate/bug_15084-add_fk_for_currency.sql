-- Add the new currency.archived column
alter table currency add column archived tinyint(1) default 0;
-- Set currency=NULL if empty (just in case)
update aqorders set currency=NULL where currency="";
-- Insert the missing currency and mark them as archived before adding the FK
insert into currency(currency, archived) select distinct currency, 1 from aqorders where currency not in (select currency from currency);
-- And finally add the FK
alter table aqorders add foreign key (currency) references currency(currency) on delete set null on update set null;
