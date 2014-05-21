SET FOREIGN_KEY_CHECKS=0;

INSERT INTO message_transport_types
(message_transport_type)
values
('email'),
('print'),
('sms'),
('phone');

SET FOREIGN_KEY_CHECKS=1;
