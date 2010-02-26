truncate message_attributes;

insert into `message_attributes`
(`message_attribute_id`, message_name, `takes_days`)
values
(1, 'Единица задолжена',           0),
(2, 'Предварительное уведомление', 1),
(3, 'Предстоящие события',         1),
(4, 'Hold Filled',                 0),
(5, 'Item Check-in',               0),
(6, 'Item Checkout',               0);

