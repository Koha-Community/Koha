SET foreign_key_checks = 0;
TRUNCATE itemtypes;
SET foreign_key_checks = 1;
INSERT INTO itemtypes (itemtype, description, rentalcharge, notforloan, imageurl, summary) VALUES
('BK', ' Книги',5,0,'bridge/book.gif',''),
('MX', 'Смешанные атериалы',5,0,'bridge/kit.gif',''),
('CF', 'Компьютерные файлы',5,0,'bridge/computer_file.gif',''),
('MP', 'Карты',5,0,'bridge/map.gif',''),
('VM', 'Визуальные материалы',5,1,'bridge/dvd.gif',''),
('MU', 'Музыка',5,0,'bridge/sound.gif',''),
('CR', 'Продолжающиеся ресурсы',5,0,'bridge/periodical.gif',''),
('REF', 'Справочники',0,1,'','');
