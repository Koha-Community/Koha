SET FOREIGN_KEY_CHECKS=0;

INSERT INTO `itemtypes` (`itemtype`,`description`,`rentalcharge`,`notforloan`,`imageurl`,`summary`) VALUES ('BK', 'Libro',0,0,'bridge/book.gif','');
INSERT INTO `itemtypes` (`itemtype`,`description`,`rentalcharge`,`notforloan`,`imageurl`,`summary`) VALUES ('MX', 'Materiale misto',0,0,'bridge/kit.gif','');
INSERT INTO `itemtypes` (`itemtype`,`description`,`rentalcharge`,`notforloan`,`imageurl`,`summary`) VALUES ('CF', 'Computer Files',0,0,'bridge/computer_file.gif','');
INSERT INTO `itemtypes` (`itemtype`,`description`,`rentalcharge`,`notforloan`,`imageurl`,`summary`) VALUES ('MP', 'Mappe',0,0,'bridge/map.gif','');
INSERT INTO `itemtypes` (`itemtype`,`description`,`rentalcharge`,`notforloan`,`imageurl`,`summary`) VALUES ('VM', 'Audiovisivi',0,1,'bridge/dvd.gif','');
INSERT INTO `itemtypes` (`itemtype`,`description`,`rentalcharge`,`notforloan`,`imageurl`,`summary`) VALUES ('MU', 'Musica',0,0,'bridge/sound.gif','');
INSERT INTO `itemtypes` (`itemtype`,`description`,`rentalcharge`,`notforloan`,`imageurl`,`summary`) VALUES ('CR', 'Periodici',0,0,'bridge/periodical.gif','');
INSERT INTO `itemtypes` (`itemtype`,`description`,`rentalcharge`,`notforloan`,`imageurl`,`summary`) VALUES ('REF', 'Reference',0,1,'','');

SET FOREIGN_KEY_CHECKS=1;
