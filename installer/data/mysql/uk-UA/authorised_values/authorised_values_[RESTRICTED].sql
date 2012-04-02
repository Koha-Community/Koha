DELETE FROM authorised_values WHERE category='RESTRICTED';

INSERT INTO `authorised_values` (`category`, `authorised_value`, `lib`) VALUES 
('RESTRICTED','1','Обмежений доступ');
