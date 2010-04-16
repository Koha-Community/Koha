-- Label Templates
LOCK TABLES `labels_templates` WRITE;
/*!40000 ALTER TABLE `labels_templates` DISABLE KEYS */;
INSERT INTO `labels_templates` VALUES
(1,0,'Avery 5160 | 1 x 2-5/8',  '3 columns, 10 rows of labels',                                                 8.5,    11,     2.63,   1,      0.139,  0,      0.35,   0.23,   3,      10,     0.13,   0,      'INCH'),
(2,0,'Gaylord 8511 Spine Label','Prints only the left-hand column of a Gaylord 8511.',                          8.5,    11,     1,      1.25,   0.6,    0.5,    0,      0,      1,      8,      0,      0,      'INCH'),
(3,0,'Avery 5460 vertical',     '',                                                                             3.625,  5.625,  1.5,    0.75,   0.38,   0.35,   2,      7,      2,      1,      0.25,   0,      'INCH'),
(4,0,'Avery 5460 spine labels', '',                                                                             5.625,  3.625,  0.75,   1.5,    0.35,   0.31,   7,      2,      1,      0,      0.25,   0,      'INCH'),
(5,0,'Avery 8163',              '2rows x 5 rows',                                                               8.5,    11,     4,      2,      0,      0,      0.5,    0.17,   2,      5,      0.2,    0.01,   'INCH'),
(6,0,'cards',                   'Avery 5160 | 1 x 2-5/8 : 1 x 2-5/8\"  [3x10] : equivalent: Gaylord JD-ML3000', 8.5,    11,     2.75,   1.05,   0,      0,      0.25,   0,      3,      10,     0.2,    0.01,   'INCH'),
(7,0,'Demco WS14942260',        '1\" X 1.5\" Spine Label',                                                      8.5,    11,     1.5,    1,      0.236,  0,      0.4,    0.25,   5,      10,     0.0625, 0,      'INCH');
/*!40000 ALTER TABLE `labels_templates` ENABLE KEYS */;
UNLOCK TABLES;
LOCK TABLES `labels_layouts` WRITE;
/*!40000 ALTER TABLE `labels_layouts` DISABLE KEYS */;
INSERT INTO `labels_layouts` VALUES
(1,'CODE39','BIBBAR',   'biblio and barcode',   0,      'TR',7,0,'L','title, author, itemcallnumber'),
(2,'CODE39','BIB',      'spine',                0,      'TR',3,1,'L','itemcallnumber'),
(3,'CODE39','BARBIB',   'barcode and biblio',   0,      'TR',3,1,'L','title, author, itemcallnumber');
/*!40000 ALTER TABLE `labels_layouts` ENABLE KEYS */;
UNLOCK TABLES;
