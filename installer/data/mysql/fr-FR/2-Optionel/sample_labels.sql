/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

LOCK TABLES `creator_templates` WRITE;
INSERT INTO `creator_templates` VALUES
(1,0,'Avery 5160 | 1 x 2-5/8',  '3 colonnes, 10 lignes d''étiquette',                                           8.5,    11,     2.63,   1,      0.139,  0,      0.35,   0.23,   3,      10,     0.13,   0,      'INCH', 'Labels'),
(2,0,'Gaylord 8511 Spine Label','Imprime uniquement dans la colnne de gauche d''une planche Gaylord 8511.',     8.5,    11,     1,      1.25,   0.6,    0.5,    0,      0,      1,      8,      0,      0,      'INCH', 'Labels'),
(3,0,'Avery 5460 vertical',     '',                                                                             3.625,  5.625,  1.5,    0.75,   0.38,   0.35,   2,      7,      2,      1,      0.25,   0,      'INCH', 'Labels'),
(4,0,'Avery 5460 spine labels', '',                                                                             5.625,  3.625,  0.75,   1.5,    0.35,   0.31,   7,      2,      1,      0,      0.25,   0,      'INCH', 'Labels'),
(5,0,'Avery 8163',              '2colonnes x 5 colonnes',                                                       8.5,    11,     4,      2,      0,      0,      0.5,    0.17,   2,      5,      0.2,    0.01,   'INCH', 'Labels'),
(6,0,'cards',                   'Avery 5160 | 1 x 2-5/8 : 1 x 2-5/8\"  [3x10] : equivalent: Gaylord JD-ML3000', 8.5,    11,     2.75,   1.05,   0,      0,      0.25,   0,      3,      10,     0.2,    0.01,   'INCH', 'Labels'),
(7,0,'Demco WS14942260',        '1\" X 1.5\" Etiquettes de cotes',                                              8.5,    11,     1.5,    1,      0.236,  0,      0.4,    0.25,   5,      10,     0.0625, 0,      'INCH', 'Labels');
UNLOCK TABLES; 

LOCK TABLES `creator_layouts` WRITE;
INSERT INTO `creator_layouts` VALUES
(1,'CODE39',1,'BIBBAR','biblio and barcode',0,1,'TR',7,'POINT',0,'L','title, author, itemcallnumber', '<opt></opt>', 'Labels'),
(2,'CODE39',1,'BIB','spine',0,1,'TR',3,'POINT',1,'L','itemcallnumber', '<opt></opt>', 'Labels'),
(3,'CODE39',1,'BARBIB','barcode and biblio',0,1,'TR',3,'POINT',1,'L','title, author, itemcallnumber', '<opt></opt>', 'Labels');
UNLOCK TABLES;

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
