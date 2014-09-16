DROP TABLE IF EXISTS elasticsearch_mapping;
CREATE TABLE `elasticsearch_mapping` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mapping` varchar(255) DEFAULT NULL,
  `type` varchar(255) NOT NULL,
  `facet` boolean DEFAULT FALSE,
  `marc21` varchar(255) DEFAULT NULL,
  `unimarc` varchar(255) DEFAULT NULL,
  `normarc` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=126 DEFAULT CHARSET=utf8;



INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('llength',FALSE,'','leader_/1-5',NULL,'leader_/1-5');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('rtype',FALSE,'','leader_/6',NULL,'leader_/6');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('bib-level',FALSE,'','leader_/7',NULL,'leader_/7');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('control-number',FALSE,'','001',NULL,'001');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('local-number',FALSE,'',NULL,'001',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('date-time-last-modified',FALSE,'','005','099d',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('microform-generation',FALSE,'','007_/11',NULL,'007_/11');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('material-type',FALSE,'','007','200b','007');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ff7-00',FALSE,'','007_/1',NULL,'007_/1');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ff7-01',FALSE,'','007_/2',NULL,'007_/2');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ff7-02',FALSE,'','007_/3',NULL,'007_/3');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ff7-01-02',FALSE,'','007_/1-2',NULL,'007_/1-2');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('date-entered-on-file',FALSE,'','008_/1-5','099c','008_/1-5');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('pubdate',FALSE,'','008_/7-10','100a_/9-12','008_/7-10');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('pl',FALSE,'','008_/15-17','210a','008_/15-17');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ta',FALSE,'','008_/22','100a_/17','008_/22');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ff8-23',FALSE,'','008_/23',NULL,'008_/23');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ff8-29',FALSE,'','008_/29','105a_/8','008_/29');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('lf',FALSE,'','008_/33','105a_/11','008_/33');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('bio',FALSE,'','008_/34','105a_/12','008_/34');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ln',FALSE,'','008_/35-37','101a','008_/35-37');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('ctype',FALSE,'','008_/24-27','105a_/4-7','008_/24-27');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('record-source',FALSE,'','008_/39','995c','008_/39');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('lc-cardnumber',FALSE,'','010','995j','010');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('lc-cardnumber',FALSE,'','011',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('identifier-standard',FALSE,'','010',NULL,'010');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('identifier-standard',FALSE,'','011',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('bnb-card-number',FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('bgf-number',FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('number-db',FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('number-natl-biblio',FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('identifier-standard',FALSE,'','015',NULL,'015');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('number-legal-deposit',FALSE,'','017',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('identifier-standard',FALSE,'','017',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('identifier-standard',FALSE,'','018',NULL,NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('identifier-standard',FALSE,'','020a','010az','020a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('isbn',FALSE,'','020a','010az','020a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('identifier-standard',FALSE,'','022a','011ayz','022a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('issn',FALSE,'','022a','011ayz','022a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('author',TRUE,'string','100a','200f','100a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('author',TRUE,'string','110a','200g','110a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('author',TRUE,'string','111a',NULL,'111a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('author',TRUE,'string','700a','700a','700a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('author',FALSE,'string','245c','701','245c');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','245a','200a','245a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','246','200c','246');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','247','200d','247');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','490','200e','490a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','505t','200h',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','711t','200i','711t');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','700t','205','700t');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','710t','304a','710t');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','730','327a','730');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','740','327b','740');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','780','327c','780');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','785','327d','785');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','130','327e','130');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','210','327f','210');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','211','327g',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','212','327h',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','214','327i',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','222','328t','222');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string','240','410t','240');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'411t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'412t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'413t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'421t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'422t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'423t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'424t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'425t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'430t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'431t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'432t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'433t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'434t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'435t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'436t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'437t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'440t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'441t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'442t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'443t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'444t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'445t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'446t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'447t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'448t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'451t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'452t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'453t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'454t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'455t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'456t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'461t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'462t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'463t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'464t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'470t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'481t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'482t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('title',FALSE,'string',NULL,'488t',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','600a','600a','600a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','600t','600','600t');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','610a','601','610a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','610t','602','610t');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','611','604','611');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','630n','605','630n');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','630r','606','630r');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','650a','607','650a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','650b',NULL,'650b');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','650c',NULL,'650c');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','650d',NULL,'650d');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','650v',NULL,'650v');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','650x',NULL,'650x');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','650y',NULL,'650y');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','650z',NULL,'650z');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','651','608','651');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('subject',TRUE,'string','653a','610','653');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('local-classification',FALSE,'','952o','995k','952o');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('local-classification',FALSE,'',NULL,'686',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('local-number',FALSE,'','999c','001','999c');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('local-number',FALSE,'',NULL,'0909',NULL);
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('itype',TRUE,'string','942c','200b','942c');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('itype',TRUE,'string','952y','995r','952y');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('acqdate',FALSE,'date','952d','9955','952y');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('place',TRUE,'string','260a','210a','260a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('publisher',TRUE,'string','260b','210c','260b');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('copydate',TRUE,'date','260c',NULL,'260c'); -- No copydate for unimarc? Seems strange.
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('homebranch',TRUE,'string','952a','995b','952a');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('holdingbranch',TRUE,'string','952b','995c','952b');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('onloan',FALSE,'boolean','952q','995n','952q');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('itemnumber',FALSE,'number','9529','9959','9529');
INSERT INTO `elasticsearch_mapping` (`mapping`, `facet`, `type`, `marc21`, `unimarc`, `normarc`) VALUES ('issues',FALSE,'sum','952l',NULL,'952l'); -- Apparently not tracked in unimarc
