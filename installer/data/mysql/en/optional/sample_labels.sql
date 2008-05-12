-- Label Templates
LOCK TABLES `labels_templates` WRITE;
INSERT INTO `labels_templates`
(tmpl_id,tmpl_code,tmpl_desc,page_width,page_height,label_width,label_height,topmargin,leftmargin,cols,`rows`,colgap,rowgap,
active,units,fontsize,font)
VALUES
(1,'Avery 5160 | 1 x 2-5/8','3 columns, 10 rows of labels',8.5,11,2.625,1,0.5,0.1875,3,10,0.125,0,1,'INCH',7,'TR'),
(2,'Gaylord 8511 Spine Label','Prints only the left-hand column of a Gaylord 8511.',8.5,11,1,1.25,0.6,0.5,1,8,0,0,NULL,'INCH',10,'TR'),
(3,'Avery 5460 vertical','',3.625,5.625,1.5,0.75,0.38,0.35,2,7,0.25,0,NULL,'INCH',8,'TR'),
(4,'Avery 5460 spine labels','',5.625,3.625,0.75,1.5,0.35,0.31,7,2,0,0.25,NULL,'INCH',8,'TR'),
(5,'Avery 8163','2rows x 5 rows',8.5,11,4,2,0.5,0.17,2,5,0.2,0.01,NULL,'INCH',11,'TR'),
(6,'cards','Avery 5160 | 1 x 2-5/8 : 1 x 2-5/8\"  [3x10] : equivalent: Gaylord JD-ML3000',8.5,11,2.75,1.05,0.25,0,3,10,0.2,0.01,NULL,'INCH',8,'TR'),
(7,'HB-PC0001','A template for home brewed patron card forms',8.5,11,3.125,1.875,0.375,0.5625,2,5,1.125,0.1875,NULL,'INCH',16,'TR');
UNLOCK TABLES; 
LOCK TABLES `labels_conf` WRITE;
/*!40000 ALTER TABLE `labels_conf` DISABLE KEYS */;
INSERT INTO `labels_conf` 
(id,barcodetype,title,subtitle,itemtype,barcode,dewey,classification,subclass,itemcallnumber,author,issn,isbn,startlabel,
printingtype,formatstring,layoutname,guidebox,active,fonttype,ccode,callnum_split)
VALUES 
(5,'CODE39',2,0,3,0,0,0,0,4,1,0,0,1,'BIBBAR','biblio and barcode',1,1,NULL,NULL,NULL,NULL),
(6,'CODE39',2,0,0,0,0,3,4,0,1,0,3,1,'BAR','alternating',1,1,NULL,NULL,NULL,NULL),
(7,'CODE39',1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,1,'PATCRD','Patron ID Cards',1,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `labels_conf` ENABLE KEYS */;
UNLOCK TABLES;
