SET foreign_key_checks = 0;
TRUNCATE itemtypes;
SET foreign_key_checks = 1;
INSERT INTO itemtypes (itemtype, description, rentalcharge, notforloan, imageurl, summary) VALUES
('BK', ' Книги',0,0,'bridge/book.png',''),
('MX', 'Смешанные атериалы',5,0,'bridge/kit.png',''),
('CF', 'Компьютерные файлы',5,0,'bridge/computer_file.png',''),
('MP', 'Карты',5,0,'bridge/map.png',''),
('VM', 'Визуальные материалы',5,1,'bridge/dvd.png',''),
('MU', 'Музыка',5,0,'bridge/sound.png',''),
('CR', 'Продолжающиеся ресурсы',5,0,'bridge/periodical.png',''),
('REF', 'Справочники',0,1,'','');
