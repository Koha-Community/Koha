-- For now I'm keeping this form of table as it's easier to edit. When we get
-- an interface, then we can then use the real form directly.
DROP TABLE IF EXISTS elasticsearch_mapping;
DROP TABLE IF EXISTS search_marc_to_field;
DROP TABLE IF EXISTS search_field;
DROP TABLE IF EXISTS search_marc_map;
CREATE TABLE `elasticsearch_mapping` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `indexname` varchar(255) NOT NULL,
  `mapping` varchar(255) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `facet` boolean DEFAULT FALSE,
  `suggestible` boolean DEFAULT FALSE,
  `sort` boolean DEFAULT NULL,
  `marc21` varchar(255) DEFAULT NULL,
  `unimarc` varchar(255) DEFAULT NULL,
  `normarc` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- This specifies the fields that will be stored in the search engine.
CREATE TABLE `search_field` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL COMMENT 'the name of the field as it will be stored in the search engine',
  `type` ENUM('string', 'date', 'number', 'boolean', 'sum') NOT NULL COMMENT 'what type of data this holds, relevant when storing it in the search engine',
  PRIMARY KEY (`id`),
  UNIQUE KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- This contains a MARC field specifier for a given index, marc type, and marc
-- field.
--
-- a note about the sort field:
-- * if all the entries for a mapping are 'null', nothing special is done with that mapping.
-- * if any of the entries are not null, then a __sort field is created in ES for this mapping. In this case:
--   * any mapping with sort == false WILL NOT get copied into a __sort field
--   * any mapping with sort == true or is null WILL get copied into a __sort field
--   * any sorts on the field name will be applied to $fieldname.'__sort' instead.
-- this means that we can have search for author that includes 1xx, 245$c, and 7xx, but the sort only applies to 1xx.
CREATE TABLE `search_marc_map` (
    id int(11) NOT NULL AUTO_INCREMENT,
    index_name ENUM('biblios','authorities') NOT NULL COMMENT 'what storage index this map is for',
    marc_type ENUM('marc21', 'unimarc', 'normarc') NOT NULL COMMENT 'what MARC type this map is for',
    marc_field VARCHAR(255) NOT NULL COMMENT 'the MARC specifier for this field',
    `facet` boolean DEFAULT FALSE COMMENT 'true if a facet field should be generated for this',
    `suggestible` boolean DEFAULT FALSE COMMENT 'true if this field can be used to generate suggestions for browse',
    `sort` boolean DEFAULT NULL COMMENT 'true/false creates special sort handling, null doesn''t',
    PRIMARY KEY(`id`),
    INDEX (`index_name`),
    UNIQUE KEY (index_name, marc_type, marc_field)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- This joins the two search tables together. We can have any combination:
-- one marc field could have many search fields (maybe you want one value
-- to go to 'author' and 'corporate-author) and many marc fields could go
-- to one search field (e.g. all the various author fields going into
-- 'author'.)
CREATE TABLE `search_marc_to_field` (
    search_marc_map_id int(11) NOT NULL,
    search_field_id int(11) NOT NULL,
    PRIMARY KEY(search_marc_map_id, search_field_id),
    FOREIGN KEY(search_marc_map_id) REFERENCES search_marc_map(id),
    FOREIGN KEY(search_field_id) REFERENCES search_field(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','llength',FALSE,FALSE,'','leader_/1-5',NULL,'leader_/1-5');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','rtype',FALSE,FALSE,'','leader_/6',NULL,'leader_/6');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','bib-level',FALSE,FALSE,'','leader_/7',NULL,'leader_/7');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','control-number',FALSE,FALSE,'','001',NULL,'001');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','date-time-last-modified',FALSE,FALSE,'','005','099d',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','microform-generation',FALSE,FALSE,'','007_/11',NULL,'007_/11');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','material-type',FALSE,FALSE,'','007',NULL,'007');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ff7-00',FALSE,FALSE,'','007_/1',NULL,'007_/1');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ff7-01',FALSE,FALSE,'','007_/2',NULL,'007_/2');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ff7-02',FALSE,FALSE,'','007_/3',NULL,'007_/3');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ff7-01-02',FALSE,FALSE,'','007_/1-2',NULL,'007_/1-2');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','date-entered-on-file',FALSE,FALSE,'','008_/1-5','099c','008_/1-5');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','pubdate',FALSE,FALSE,'','008_/7-10','100a_/9-12','008_/7-10');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','pl',FALSE,FALSE,'','008_/15-17',NULL,'008_/15-17');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ta',FALSE,FALSE,'','008_/22','100a_/17','008_/22');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ff8-23',FALSE,FALSE,'','008_/23',NULL,'008_/23');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ff8-29',FALSE,FALSE,'','008_/29','105a_/8','008_/29');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','lf',FALSE,FALSE,'','008_/33','105a_/11','008_/33');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','bio',FALSE,FALSE,'','008_/34','105a_/12','008_/34');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ln',FALSE,FALSE,'','008_/35-37','101a','008_/35-37');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','ctype',FALSE,FALSE,'','008_/24-27','105a_/4-7','008_/24-27');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','record-source',FALSE,FALSE,'','008_/39',NULL,'008_/39');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','lc-cardnumber',FALSE,FALSE,'','010','995j','010');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','lc-cardnumber',FALSE,FALSE,'','011',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','identifier-standard',FALSE,FALSE,'','010',NULL,'010');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','identifier-standard',FALSE,FALSE,'','011',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','bnb-card-number',FALSE,FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','bgf-number',FALSE,FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','number-db',FALSE,FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','number-natl-biblio',FALSE,FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','identifier-standard',FALSE,FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','number-legal-deposit',FALSE,FALSE,'','017',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','identifier-standard',FALSE,FALSE,'','017',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','identifier-standard',FALSE,FALSE,'','018',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','identifier-standard',FALSE,FALSE,'','020a','010az','020a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','isbn',FALSE,FALSE,'','020a','010az','020a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','identifier-standard',FALSE,FALSE,'','022a','011ayz','022a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','issn',FALSE,FALSE,'','022a','011ayz','022a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','author',TRUE,TRUE,'string','100a','200f','100a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','author',TRUE,TRUE,'string','110a','200g','110a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','author',TRUE,TRUE,'string','111a',NULL,'111a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `sort`,`type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','author',TRUE,TRUE,FALSE,'string','700a','700a','700a'); -- no sorting on the
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `sort`,`type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','author',FALSE,FALSE,FALSE,'string','245c','701','245c'); -- extra author fields
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,TRUE,'string','245a','200a','245a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,TRUE,'string','246','200c','246');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,TRUE,'string','247','200d','247');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,TRUE,'string','490a','200e','490a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,TRUE,'string','505t','200h',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,TRUE,'string','711t','200i','711t');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,TRUE,'string','700t','205','700t');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,TRUE,'string','710t','304a','710t');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','730','327a','730');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','740','327b','740');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','780','327c','780');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','785','327d','785');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','130','327e','130');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','210','327f','210');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','211','327g',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','212','327h',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','214','327i',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','222','328t','222');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string','240','410t','240');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'411t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'412t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'413t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'421t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'422t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'423t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'424t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'425t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'430t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'431t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'432t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'433t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'434t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'435t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'436t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'437t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'440t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'441t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'442t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'443t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'444t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'445t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'446t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'447t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'448t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'451t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'452t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'453t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'454t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'455t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'456t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'461t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'462t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'463t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'464t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'470t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'481t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'482t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','title',FALSE,FALSE,'string',NULL,'488t',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','600a','600a','600a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','600t','600','600t');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','610a','601','610a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','610t','602','610t');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','611','604','611');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','630n','605','630n');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','630r','606','630r');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','650a','607','650a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','650b',NULL,'650b');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','650c',NULL,'650c');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','650d',NULL,'650d');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','650v',NULL,'650v');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','650x',NULL,'650x');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','650y',NULL,'650y');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','650z',NULL,'650z');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','651','608','651');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','subject',TRUE,TRUE,'string','653a','610','653');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','local-classification',FALSE,TRUE,'','952o','995k','952o');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','local-classification',FALSE,FALSE,'',NULL,'686',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','Local-number',FALSE,FALSE,'string','999c','001','999c');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','itype',TRUE,FALSE,'string','942c','200b','942c');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','itype',TRUE,FALSE,'string','952y','995r','952y');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','acqdate',FALSE,FALSE,'date','952d','9955','952d');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','place',TRUE,FALSE,'string','260a','210a','260a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','publisher',TRUE,FALSE,'string','260b','210c','260b');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','copydate',TRUE,FALSE,'date','260c',NULL,'260c'); -- No copydate for unimarc? Seems strange.
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','homebranch',TRUE,FALSE,'string','952a','995b','952a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','holdingbranch',TRUE,FALSE,'string','952b','995c','952b');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','onloan',FALSE,FALSE,'boolean','952q','995n','952q');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','itemnumber',FALSE,FALSE,'number','9529','9959','9529');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','issues',FALSE,FALSE,'sum','952l',NULL,'952l'); -- Apparently not tracked in unimarc
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','1009','7009','1009');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','1109','7019','1109');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','1119','7029','1119');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','1309','7109','1309');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','2459','7119','2459');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','4009','7129','4409');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','4109','7169','4909');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','4409','7209','6009');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','4909','7219','6109');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6009','7229','6119');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6109','7309','6309');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6119','5009','6509');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6309','5019','6519');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6509','5039','6529');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6519','5109','6539');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6529','5129','6549');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6539','5139','6559');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6549','5149','6569');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6559','5159','6579');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6569','5169','6909');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6579','5179','7009');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','6909','5189','7109');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','7009','5199','7119');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','7109','5209','7309');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','7119','5309','8009');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','7309','5319','8109');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','7519','5329','8119');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','8009','5409','8309');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','8109','5419',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','8119','5459',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number','8309','5609',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6009',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6019',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6029',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6049',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6059',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6069',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6079',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6089',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6109',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6159',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6169',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6179',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6209',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','an',FALSE,FALSE,'number',NULL,'6219',NULL);
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('biblios','Host-Item-Number',FALSE,FALSE,'number','7739','4619','7739');

-- Authorities: incomplete
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Local-number',FALSE,FALSE,'string','001',NULL,'001');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','authtype',FALSE,FALSE,'','942a',NULL,'942a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Kind-of-record',FALSE,FALSE,'','008_/9',NULL,'008_/9');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Descriptive-cataloging-rules',FALSE,FALSE,'','008_/10',NULL,'008_/10');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Subject-heading-thesaurus',FALSE,FALSE,'','008_/11',NULL,'008_/11');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Heading-use-main-or-added-entry',FALSE,FALSE,'','008_/14',NULL,'008_/14');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Heading-use-subject-added-entry',FALSE,FALSE,'','008_/15',NULL,'008_/15');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Heading-use-series-added-entry',FALSE,FALSE,'','008_/16',NULL,'008_/16');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','LC-card-number',FALSE,FALSE,'','010az',NULL,'010az');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Record-source',FALSE,FALSE,'','040acd',NULL,'040acd');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Personal-name',FALSE,FALSE,'','100abcdefghjklmnopqrstvxyz',NULL,'100abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Personal-name-heading',FALSE,FALSE,'','100abcdefghjklmnopqrstvxyz',NULL,'100abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Heading',FALSE,FALSE,'','100abcdefghjklmnopqrstvxyz',NULL,'100abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Heading-main',FALSE,FALSE,'','100a',NULL,'100a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match',FALSE,FALSE,'','100abcdefghjklmnopqrstvxyz',NULL,'100abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match-heading',FALSE,FALSE,'','100abcdefghjklmnopqrstvxyz',NULL,'100abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Personal-name-see-from',FALSE,FALSE,'','400abcdefghjklmnopqrstvxyz',NULL,'400abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','See-from',FALSE,FALSE,'','400abcdefghjklmnopqrstvxyz',NULL,'400abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match',FALSE,FALSE,'','400abcdefghjklmnopqrstvxyz',NULL,'400abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match-heading-see-from',FALSE,FALSE,'','400abcdefghjklmnopqrstvxyz',NULL,'400abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Personal-name-see-also-from',FALSE,FALSE,'','500abcdefghjklmnopqrstvxyz',NULL,'500abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','See-also-from',FALSE,FALSE,'','500abcdefghjklmnopqrstvxyz',NULL,'500abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match',FALSE,FALSE,'','500abcdefghjklmnopqrstvxyz',NULL,'500abcdefghjklmnopqrstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Corporate-name-see-from',FALSE,FALSE,'','410abcdefghklmnoprstvxyz',NULL,'410abcdefghklmnoprstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','See-from',FALSE,FALSE,'','410abcdefghklmnoprstvxyz',NULL,'410abcdefghklmnoprstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match',FALSE,FALSE,'','410abcdefghklmnoprstvxyz',NULL,'410abcdefghklmnoprstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match-heading-see-from',FALSE,FALSE,'','410abcdefghklmnoprstvxyz',NULL,'410abcdefghklmnoprstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Corporate-name-see-also-from',FALSE,FALSE,'','510abcdefghklmnoprstvxyz',NULL,'510abcdefghklmnoprstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','See-also-from',FALSE,FALSE,'','510abcdefghklmnoprstvxyz',NULL,'510abcdefghklmnoprstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match',FALSE,FALSE,'','510abcdefghklmnoprstvxyz',NULL,'510abcdefghklmnoprstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Meeting-name',FALSE,FALSE,'','111acdefghjklnpqstvxyz',NULL,'111acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Meeting-name-heading',FALSE,FALSE,'','111acdefghjklnpqstvxyz',NULL,'111acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Heading',FALSE,FALSE,'','111acdefghjklnpqstvxyz',NULL,'111acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Heading-Main',FALSE,FALSE,'','111a',NULL,'111a');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match',FALSE,FALSE,'','111acdefghjklnpqstvxyz',NULL,'111acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match-heading',FALSE,FALSE,'','111acdefghjklnpqstvxyz',NULL,'111acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Meeting-name-see-from',FALSE,FALSE,'','411acdefghjklnpqstvxyz',NULL,'411acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','See-from',FALSE,FALSE,'','411acdefghjklnpqstvxyz',NULL,'411acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match',FALSE,FALSE,'','411acdefghjklnpqstvxyz',NULL,'411acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match-heading-see-from',FALSE,FALSE,'','411acdefghjklnpqstvxyz',NULL,'411acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Meeting-name-see-also-from',FALSE,FALSE,'','511acdefghjklnpqstvxyz',NULL,'511acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','See-also-from',FALSE,FALSE,'','511acdefghjklnpqstvxyz',NULL,'511acdefghjklnpqstvxyz');
INSERT INTO `elasticsearch_mapping` (`indexname`, `mapping`, `facet`, `suggestible`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('authorities','Match',FALSE,FALSE,'','511acdefghjklnpqstvxyz',NULL,'511acdefghjklnpqstvxyz');

-- temporary to convert into new table form
insert into search_marc_map(index_name, marc_type, marc_field, facet, suggestible, sort) select distinct indexname, 'marc21', marc21, facet, suggestible, sort from elasticsearch_mapping where marc21 is not null;
insert into search_marc_map(index_name, marc_type, marc_field, facet, suggestible, sort) select distinct indexname, 'unimarc', unimarc, facet, suggestible, sort from elasticsearch_mapping where unimarc is not null;
insert into search_marc_map(index_name, marc_type, marc_field, facet, suggestible, sort) select distinct indexname, 'normarc', normarc, facet, suggestible, sort from elasticsearch_mapping where normarc is not null;
insert into search_field (name, type) select distinct mapping, type from elasticsearch_mapping;

insert into search_marc_to_field(search_marc_map_id, search_field_id) select search_marc_map.id,search_field.id from search_field, search_marc_map, elasticsearch_mapping where elasticsearch_mapping.mapping=search_field.name AND elasticsearch_mapping.marc21=search_marc_map.marc_field AND search_marc_map.marc_type='marc21' AND indexname='biblios' AND index_name='biblios';
insert into search_marc_to_field(search_marc_map_id, search_field_id) select search_marc_map.id,search_field.id from search_field, search_marc_map, elasticsearch_mapping where elasticsearch_mapping.mapping=search_field.name AND elasticsearch_mapping.unimarc=search_marc_map.marc_field AND search_marc_map.marc_type='unimarc' AND indexname='biblios' AND index_name='biblios';
insert into search_marc_to_field(search_marc_map_id, search_field_id) select search_marc_map.id,search_field.id from search_field, search_marc_map, elasticsearch_mapping where elasticsearch_mapping.mapping=search_field.name AND elasticsearch_mapping.normarc=search_marc_map.marc_field AND search_marc_map.marc_type='normarc' AND indexname='biblios' AND index_name='biblios';

insert into search_marc_to_field(search_marc_map_id, search_field_id) select search_marc_map.id,search_field.id from search_field, search_marc_map, elasticsearch_mapping where elasticsearch_mapping.mapping=search_field.name AND elasticsearch_mapping.marc21=search_marc_map.marc_field AND search_marc_map.marc_type='marc21' AND indexname='authorities' AND index_name='authorities';
insert into search_marc_to_field(search_marc_map_id, search_field_id) select search_marc_map.id,search_field.id from search_field, search_marc_map, elasticsearch_mapping where elasticsearch_mapping.mapping=search_field.name AND elasticsearch_mapping.unimarc=search_marc_map.marc_field AND search_marc_map.marc_type='unimarc' AND indexname='authorities' AND index_name='authorities';
insert into search_marc_to_field(search_marc_map_id, search_field_id) select search_marc_map.id,search_field.id from search_field, search_marc_map, elasticsearch_mapping where elasticsearch_mapping.mapping=search_field.name AND elasticsearch_mapping.normarc=search_marc_map.marc_field AND search_marc_map.marc_type='normarc' AND indexname='authorities' AND index_name='authorities';

drop table elasticsearch_mapping;
