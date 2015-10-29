/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;

LOCK TABLES `creator_templates` WRITE;
INSERT INTO `creator_templates`
(template_id,template_code,template_desc,page_width,page_height,label_width,label_height,top_margin,left_margin,cols,rows,col_gap,row_gap,
units)
VALUES
(1,'Avery 5160 | 1 x 2-5/8','3 колонки, 10 рядов наклеек',8.5,11,2.625,1,0.5,0.1875,3,10,0.125,0,'INCH'),
(2,'Gaylord 8511 боковая наклейка','Печать только левой колонки Gaylord 8511.',8.5,11,1,1.25,0.6,0.5,1,8,0,0,'INCH'),
(3,'Avery 5460 вертикальная','',3.625,5.625,1.5,0.75,0.38,0.35,2,7,0.25,0,'INCH'),
(4,'Avery 5460 боковые наклейки','',5.625,3.625,0.75,1.5,0.35,0.31,7,2,0,0.25,'INCH'),
(5,'Avery 8163','2 ряда x 5 рядов',8.5,11,4,2,0.5,0.17,2,5,0.2,0.01,'INCH'),
(6,'cards','Avery 5160 | 1 x 2-5/8 : 1 x 2-5/8\"  [3x10] : эквивалент: Gaylord JD-ML3000',8.5,11,2.75,1.05,0.25,0,3,10,0.2,0.01,'INCH'),
(7,'HB-PC0001','Шаблон для карточек посетителей домашнего изготовления',8.5,11,3.125,1.875,0.375,0.5625,2,5,1.125,0.1875,'INCH');
UNLOCK TABLES; 

LOCK TABLES `creator_layouts` WRITE;
INSERT INTO `creator_layouts` VALUES
(1,'CODE39',1,'BIBBAR','библио-запись и штрих-код',0,1,'TR',7,'POINT',0,'L','title, author, itemcallnumber', '<opt></opt>', 'Labels'),
(2,'CODE39',1,'BAR','переменный',0,1,'TR',3,'POINT',0,'L','','','Labels');
UNLOCK TABLES;

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
