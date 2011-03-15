SET FOREIGN_KEY_CHECKS=0;

insert into `message_attributes`
(`message_attribute_id`, message_name, `takes_days`)
values
(1, 'Item DUE', 0),
(2, 'Advance Notice', 1),
(4, 'Hold Filled', 0),
(5, 'Item Check-in', 0),
(6, 'Item Checkout', 0);

SET FOREIGN_KEY_CHECKS=1;
