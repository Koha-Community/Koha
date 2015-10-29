/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

LOCK TABLES `creator_layouts` WRITE;
INSERT INTO `creator_layouts` (`layout_id`, `barcode_type`, `start_label`, `printing_type`, `layout_name`, `guidebox`, `font`, `font_size`, `units`, `callnum_split`, `text_justify`, `format_string`, `layout_xml`, `creator`) VALUES (17,'CODE39',1,'BIBBAR','Etikettentest',0,'TR',3,'POINT',0,'L','title, author, isbn, issn, itemtype, barcode, itemcallnumber','<opt></opt>','Labels'),(18,'CODE39',1,'BAR','DEFAULT',0,'TR',3,'POINT',0,'L','title, author, isbn, issn, itemtype, barcode, itemcallnumber','<opt></opt>','Labels'),(19,'CODE39',1,'BAR','DEFAULT',0,'TR',3,'POINT',0,'L','title, author, isbn, issn, itemtype, barcode, itemcallnumber','<opt></opt>','Labels'),(20,'CODE39',1,'BAR','Testlayout',0,'TR',10,'POINT',0,'L','barcode','<opt page_side="F" units="POINT">
  <images name="image_1" Dx="72" Ox="0" Oy="0" Sx="0" Sy="0" Tx="4.5" Ty="63">
    <data_source image_name="none" image_source="patronimages" />
  </images>
  <text>&lt;firstname&gt; &lt;surname&gt;</text>
  <text enable="1" font="TR" font_size="10" llx="100" lly="100" text_alignment="L" />
  <text>Bibliothek: &lt;branchcode&gt;</text>
  <text enable="1" font="TR" font_size="10" llx="100" lly="75" text_alignment="L" />
  <text>Ablaufdatum: 31.06.2014</text>
  <text font="TR" font_size="6" llx="115" lly="65" text_alignment="L" />
</opt>
','Patroncards');
UNLOCK TABLES;


LOCK TABLES `creator_templates` WRITE;
INSERT INTO `creator_templates` VALUES (1,1,'Avery 5160 | 1 x 2-5/8','3 Spalten, 10 Reihen mit Etiketten',8.5,11,2.63,1,0.139,0,0.35,0.23,3,10,0.13,0,'INCH','Labels'),(7,13,'Demco WS14942260','1\" X 1.5\" Rückenschild | Bis zu 4 Zeilen Text',8.5,11,1.5,1,0.236,0,0.5,0.25,5,10,0.0625,0,'INCH','Labels'),(12,14,'Demco WS14942260','1\" X 1.5\" Rückenschild | Bis zu 5 Zeilen Text',8.5,11,1.5,1,0.139,0,0.53,0.3,5,10,0.0625,0,'INCH','Labels'),(22,0,'Standardtemplate 01','Standardbeschreibung',0,5,0,0,0,0,0,0,0,0,0,0,'POINT','Labels'),(23,16,'HB-PC0001','Template für selbsterstellte Benutzerausweise',8.5,11,3.1875,1.9375,0,0,0.6875,0.875,2,4,0.4375,0.1875,'INCH','Patroncards');
UNLOCK TABLES;

LOCK TABLES `printers_profile` WRITE;
INSERT INTO `printers_profile` VALUES (1,'Laserdrucker Bibliothek',1,'Bypass',-2,9,3,0,'POINT','Labels'),(11,'Laserdrucker Bibliothek',1,'Fach 1',0,0,0,0,'POINT','Labels'),(16,'Testdrucker 01',23,'Testfach',0,0,0,0,'POINT','Patroncards');
UNLOCK TABLES;

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
