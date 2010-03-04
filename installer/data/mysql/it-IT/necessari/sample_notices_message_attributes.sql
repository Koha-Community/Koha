SET FOREIGN_KEY_CHECKS=0;

insert into `message_attributes`
(`message_attribute_id`, message_name, `takes_days`)
values
(1, 'Copia scaduta', 0),
(2, 'Avviso preventivo', 1),
(3, 'Eventi in arrivo', 1),
(4, 'Prenotazione compilata', 0),
(5, 'Check In', 0),
(6, 'Check Out', 0);

SET FOREIGN_KEY_CHECKS=1;
