-- На основі MARC21-структури англійською „Books, Booklets, Workbooks“
-- Переклад/адаптація: Сергій Дубик, Ольга Баркова (2011)

DELETE FROM biblio_framework WHERE frameworkcode='BKS';
INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('BKS', 'Книги (монографічні видання)');
DELETE FROM marc_tag_structure WHERE frameworkcode='BKS';
DELETE FROM marc_subfield_structure WHERE frameworkcode='BKS';


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '000', 1, '', 'Маркер запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '000', '@', 1, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, 0, '', '', 'marc21_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '001', '', '', 'Контрольний номер', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '001', '@', 0, 0, 'Контрольне поле', 'Контрольне поле',    0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '003', '', '', 'Належність контрольного номера', 'Належність контрольного номера', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '003', '@', 0, 0, 'Контрольне поле', 'Контрольне поле',    0, -6, '', '', 'marc21_orgcode.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '005', '', '', 'Дата коректування', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '005', '@', 0, 0, 'Контрольне поле', 'Контрольне поле',    0, -1, '', '', 'marc21_field_005.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '006', '', 1, 'Елементи даних фіксованої довжини — додаткові характеристики матеріалу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '006', '@', 0, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, -1, '', '', 'marc21_field_006.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '007', '', 1, 'Кодовані дані (фіз. опис)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '007', '@', 0, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, 0, '', '', 'marc21_field_007.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '008', 1, '', 'Кодовані дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '008', '@', 1, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, 0, '', '', 'marc21_field_008.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '009', '', 1, 'Фіксовані поля фізичного опису для архівних колекцій (застаріле)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '009', '@', 0, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '010', '', '', 'Контрольний номер запису в Бібліотеці Конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '010', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', NULL, 0, '', '', NULL),
 ('BKS', '', '010', 'a', 0, 0, 'Контрольний номер запису БК', '',       0, -6, 'biblioitems.lccn', '', '', 0, '', '', NULL),
 ('BKS', '', '010', 'b', 0, 1, 'Контрольний номер запису NUCMC (Національний об’єднаний каталог рукописних зібрань)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '010', 'z', 0, 1, 'Скасований/помилковий контрольний номер БК', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '011', '', '', 'Контрольний номер посилання Бібліотеки Конгресу (застаріле)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '011', 'a', 0, 1, 'Контрольний номер запису БК', '',       0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '013', '', 1, 'Патентна інформація', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '013', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', NULL, 0, '', '', NULL),
 ('BKS', '', '013', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '013', 'a', 0, 0, 'Номер патент. док.', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '013', 'b', 0, 0, 'Код країни', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '013', 'c', 0, 0, 'Тип патенту', '',                       0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '013', 'd', 0, 1, 'Дата видачі(ррррммдд)', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '013', 'e', 0, 1, 'Статус патенту', '',                    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '013', 'f', 0, 1, 'Учасник створення', '',                 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '015', '', 1, 'Номер в нац.бібліогр.', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '015', '2', 0, 1, 'Джерело номера', '',                    0, -6, '', '', NULL, 0, '', '', NULL),
 ('BKS', '', '015', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '015', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '015', 'a', 0, 1, 'Номер в нац.бібліогр.', '',             0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '016', '', 1, 'Контрольний номер національного бібліографічного агентства', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '016', '2', 0, 1, 'Організація-джерело контрольного номера', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '016', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '016', 'a', 0, 0, 'Контрольний номер запису', '',          0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '016', 'z', 0, 1, 'Скасований/помилковий контрольний номер', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '017', '', 1, 'Номер держ.реєстрації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '017', '2', 0, 1, 'Джерело номера', '',                    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '017', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '017', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '017', 'a', 0, 1, 'Номер держ.реєстрації', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '017', 'b', 0, 0, 'Організ. що присв.номер', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '017', 'd', 0, 0, 'Дата реєстрації авторського права', '', 0, -6, '', '', NULL, 0, '', '', NULL),
 ('BKS', '', '017', 'i', 0, 0, 'Пояснювальний текст/ввідні слова', '',  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '018', '', '', 'Код плати за копіювання статті у відповідності до авторського права', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '018', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '018', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '018', 'a', 0, 0, 'Код копірайту', '',                     0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '020', '', 1, 'Індекс ISBN', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '020', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '020', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '020', 'a', 0, 0, 'ISBN', '',                              0, 0, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('BKS', '', '020', 'c', 0, 0, 'Ціна, тираж', '',                       0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '020', 'z', 0, 1, 'Скасований/помилковий ISBN', '',        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '022', '', 1, 'Індекс ISSN', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '022', '2', 0, 0, 'Source', 'Source',                      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '022', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '022', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '022', 'a', 0, 0, 'ISSN', '',                              0, -6, 'biblioitems.issn', '', '', 0, '', '', NULL),
 ('BKS', '', '022', 'y', 0, 1, 'Помилк. ISSN', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '022', 'z', 0, 1, 'Скасов. ISSN', '',                      0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '023', '', 1, 'Стандартний номер фільму [вилучено]', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '023', 'a', 0, 0, 'Стандартний номер фільму', '',          0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '024', '', 1, 'Інші станд. номери', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '024', '2', 0, 0, 'Джерело номера', '',                    0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '024', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '024', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '024', 'a', 0, 0, 'Стандартний номер', '',                 0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '024', 'b', 0, 0, 'Additional codes following the standard number (застаріло)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '024', 'c', 0, 1, 'Умови отрим.(ціна, тираж)', '',         0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '024', 'd', 0, 0, 'Додатк. коди', '',                      0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '024', 'z', 0, 1, 'Скасов./помилк. номер', '',             0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '025', '', 1, 'Номер закордонного придбання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '025', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '025', 'a', 0, 1, 'Номер закордонного придбання', '',      0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '026', '', 1, 'Фінгерпринт', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '026', '2', 0, 0, 'Використаний посібник', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '026', '5', 0, 0, 'Приналежність поля організації', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '026', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '026', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '026', 'a', 0, 0, 'Перша і друга групи символів', '',      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '026', 'b', 0, 0, 'Третя і четверта групи символів', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '026', 'c', 0, 0, 'Дата (026)', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '026', 'd', 0, 1, 'Номер тому або частини', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '026', 'e', 0, 0, 'Фінгерпринт без розбивки на групи', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '027', '', 1, 'Стандартний номер технічного звіту (STRN)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '027', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '027', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '027', 'a', 0, 0, 'Стандартний номер технічного звіту (STRN)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '027', 'z', 0, 1, 'Скасований/помилковий номер технічного звіту', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '028', '', 1, 'Номер видавця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '028', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '028', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '028', 'a', 0, 0, 'Номер видавця', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '028', 'b', 0, 0, 'Джерело № видавця', '',                 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '029', '', 1, 'Контрольний номер для інших систем (OCLC)', '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '030', '', 1, 'Позначення CODEN', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '030', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '030', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '030', 'a', 0, 0, 'Діючий номер CODEN', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '030', 'z', 0, 1, 'Скасований/недійсний номер CODEN', '',  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '031', '', 1, 'Музичний інципіт', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '031', '2', 0, 0, 'Код системи', '',                       0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'a', 0, 0, 'Порядковий номер твору у каталогізованій одиниці', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'b', 0, 0, 'Порядковий номер темпу у творі', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'c', 0, 0, 'Порядковий номер інципіта у темпі', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'd', 0, 1, 'Назва або заголовок інципіту', '',      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'e', 0, 0, 'Найменування символу разспіву інципіту (вокал)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'g', 0, 0, 'Ключ', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'm', 0, 0, 'Голос/інструмент', '',                  0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'n', 0, 0, 'Позначення тональності', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'o', 0, 0, 'Позначення такту', '',                  0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'p', 0, 0, 'Музична нотація', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'q', 0, 0, 'Примітка', '',                          0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'r', 0, 0, 'Тональність', '',                       0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 's', 0, 1, 'Код перевірки правдивості', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 't', 0, 1, 'Літературний інципіт', '',              0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 0, -6, '', '', '', 1, '', '', NULL),
 ('BKS', '', '031', 'y', 0, 1, 'Зв’язний текст', '',                    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '031', 'z', 0, 1, 'Примітка для ЕК', '',                   0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '032', '', 1, 'Номер поштової реєстрації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '032', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', NULL, 0, '', '', NULL),
 ('BKS', '', '032', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '032', 'a', 0, 0, 'Номер поштової реєстрації', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '032', 'b', 0, 0, 'Джерело (агентство, яке присвоїло номер)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '033', '', 1, 'Дата/час і місце події', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '033', '3', 0, 0, 'Область застосування даних поля', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '033', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '033', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '033', 'a', 0, 1, 'Дата/час у форматі', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '033', 'b', 0, 1, 'Код географічної класифікації регіону', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '033', 'c', 0, 1, 'Код географічної класифікації області (частини регіону)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '034', '', 1, 'Кодовані картографічні математичні дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '034', '2', 0, 0, 'Source', 'Source',                      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'a', 0, 0, 'Категорія масштабу a — лінійний, b — кутовий масштаб, z — масштаб іншого типу', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'b', 0, 1, 'Постійний лінійний горизонтальний масштаб', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'c', 0, 1, 'Постійний лінійний вертикальний масштаб', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'd', 0, 0, 'Координати — найзахідніша довгота', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'e', 0, 0, 'Координати — найсхідніша довгота', '',  0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'f', 0, 0, 'Координати — найпівнічніша довгота', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'g', 0, 0, 'Координати — найпівденніша довгота', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'h', 0, 1, 'Кутовий масштаб', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'j', 0, 0, 'Схилення — північна границя', '',       0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'k', 0, 0, 'Схилення — південна границя', '',       0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'm', 0, 0, 'Пряме сходження — східна границя', '',  0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'n', 0, 0, 'Пряме сходження — західная границя', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'p', 0, 0, 'Рівнодення', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'r', 0, 0, 'Distance from earth', 'Distance from earth', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 's', 0, 1, 'Широта G-контуруа', '',                 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 't', 0, 1, 'Довгота G-контуру', '',                 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'x', 0, 0, 'Beginning date', 'Beginning date',      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'y', 0, 0, 'Ending date', 'Ending date',            0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '034', 'z', 0, 0, 'Name of extraterrestrial body', 'Name of extraterrestrial body', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '035', '', 1, 'Системний контрольний номер', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '035', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '035', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '035', 'a', 0, 0, 'Системний контрольний номер', '',       0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '035', 'z', 0, 1, 'Анульов. контрольний номер', '',        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '036', '', '', 'Первісний номер, присв. комп’ют. файлу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '036', '6', 0, 1, 'Елемент полів', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '036', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '036', 'a', 0, 0, 'Первісно присвоєний номер', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '036', 'b', 0, 1, 'Агентство, що надало номер', '',        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '037', '', 1, 'Дані для комплектування', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '037', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '037', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '037', 'a', 0, 0, 'Номер за прейскурантом і т.ін', '',     0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '037', 'b', 0, 0, 'Продавець, розповсюджувач, видавець, виготовник', '', 0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '037', 'c', 0, 1, 'Умови отримання, ціна', '',             0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '037', 'f', 0, 1, 'Форма розповсюджуваного матеріалу', '', 0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '037', 'g', 0, 1, 'Додаткові характеристики матеріалу', '', 0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '037', 'n', 0, 1, 'Примітка', '',                          0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '038', '', '', 'Установа, що надала права інтелектуальної власності на вміст запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '038', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '038', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '038', 'a', 0, 0, 'Код установи, що надала права інтелектуальної власності на вміст запису', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '039', '', '', 'Рівень бібліографічного контролю та кодування (застаріле)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '039', 'a', 0, 0, 'Level of rules in bibliographic description', 'Level of rules in bibliographic description', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '039', 'b', 0, 0, 'Level of effort used to assign nonsubject heading access points', 'Level of effort used to assign nonsubject heading access points', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '039', 'c', 0, 0, 'Level of effort used to assign subject headings', 'Level of effort used to assign subject headings', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '039', 'd', 0, 0, 'Level of effort used to assign classification', 'Level of effort used to assign classification', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '039', 'e', 0, 0, 'Number of fixed field character positions coded', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '040', '', '', 'Джерело каталогіз.', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '040', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '040', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '040', 'a', 0, 0, 'Служба первин.кат.', '',                0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '040', 'b', 0, 0, 'Код мови каталог.', '',                 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '040', 'c', 0, 0, 'Орг., що перетв.запис', '',             0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '040', 'd', 0, 1, 'Орг., що змін.запис', '',               0, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '040', 'e', 0, 0, 'Правила каталог.', '',                  0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '041', '', 1, 'Код мови видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '041', '2', 0, 0, 'Код мови оригіналу', '',                0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '041', 'a', 0, 1, 'Код мови тексту', '',                   0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', 'b', 0, 1, 'Код мови передмови', '',                0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', 'c', 0, 1, 'Languages of separate titles (VM) (застаріло); Languages of available translation  (SE) (застаріло)', '', 0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', 'd', 0, 1, 'Код мов.тексту спів./мов.', '',         0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', 'e', 0, 1, 'Код мов.лібрето', '',                   0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', 'f', 0, 1, 'Код мови змісту', '',                   0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', 'g', 0, 1, 'Код мови супров.матер.', '',            0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('BKS', '', '041', 'h', 0, 1, 'Код мови оригіналу', '',                0, -1, '', 'LANG', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '042', '', '', 'Код автентичності запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '042', 'a', 0, 0, 'Код автентичності', '',                 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '043', '', '', 'Код географічного регіону', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '043', '2', 0, 1, 'Джерело локального коду', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '043', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '043', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '043', 'a', 0, 1, 'Код географічного регіону', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '043', 'b', 0, 1, 'Локальний код географ. регіону', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '043', 'c', 0, 1, 'ISO code', 'ISO code',                  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '044', '', '', 'Код країни публікації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '044', '2', 0, 1, 'Джерело локального коду', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '044', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '044', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '044', 'a', 0, 1, 'Код країни публікації', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '044', 'b', 0, 1, 'Локальний код місця', '',               0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '044', 'c', 0, 1, 'Код місця видання за ISO', '',          0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '045', '', '', 'Період часу, охоплений змістом документа', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '045', '6', 1, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '045', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '045', 'a', 0, 1, 'Код періода часу', '',                  0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '045', 'b', 0, 1, 'Форматоване позначення періода часу з н. е. по 9999 до н. е.', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '045', 'c', 0, 1, 'Форматоване позначення періода часу до 9999 до н.е.', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '046', '', 1, 'Спеціальні кодовані дати', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '046', '2', 0, 0, 'Джерело дати', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'a', 0, 0, 'Тип коду дати', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'b', 0, 0, 'Дата 1 (дата до н.е.)', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'c', 0, 0, 'Дата 1 (дата н.е.)', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'd', 0, 0, 'Дата 2 (дата до н.е.)', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'e', 0, 0, 'Дата 2 (дата н.е.)', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'j', 0, 0, 'Зміна джерела дати', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'k', 0, 0, 'Дата або початок діапазону дати створення (ресурсу)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'l', 0, 0, 'Дата закінчення створення (ресурсу)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'm', 0, 0, 'Beginning of date valid', 'Beginning of date valid', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '046', 'n', 0, 0, 'End of date valid', 'End of date valid', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '047', '', 1, 'Код форми муз.композиції', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '047', '2', 0, 0, 'Джерело коду', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '047', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '047', 'a', 0, 1, 'Код форми муз.композиції', '',          0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '048', '', 1, 'Код кіл-ті муз.інстр.або голосів', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '048', '2', 0, 0, 'Джерело коду', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '048', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '048', 'a', 0, 1, 'Виконавець або ансамбль', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '048', 'b', 0, 1, 'Soloist', 'Soloist',                    0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '049', '', '', 'Локальне зберігання (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '049', 'a', 0, 1, 'Holding library', 'Holding library',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'c', 0, 1, 'Copy statement', 'Copy statement',      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'd', 0, 1, 'Definition of bibliographic subdivisions', 'Definition of bibliographic subdivisions', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'l', 0, 1, 'Local processing data', 'Local processing data', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'm', 0, 1, 'Missing elements', 'Missing elements',  0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'n', 0, 0, 'Notes about holdings', 'Notes about holdings', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'o', 0, 1, 'Local processing data', 'Local processing data', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'p', 0, 1, 'Secondary bibliographic subdivision', 'Secondary bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'q', 0, 1, 'Third bibliographic subdivision', 'Third bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'r', 0, 1, 'Fourth bibliographic subdivision', 'Fourth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 's', 0, 0, 'Fifth bibliographic subdivision', 'Fifth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 't', 0, 1, 'Sixth bibliographic subdivision', 'Sixth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'u', 0, 1, 'Seventh bibliographic subdivision', 'Seventh bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'v', 0, 1, 'Primary bibliographic subdivision', 'Primary bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '049', 'y', 0, 0, 'Inclusive dates of publication or coverage', 'Inclusive dates of publication or coverage', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '050', '', 1, 'Розстановочний код бібл. Конгресу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '050', '3', 0, 0, 'Область застосування даних поля', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '050', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '050', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '050', 'a', 0, 1, 'Класифікаційний індекс', '',            0, 0, '', '', '', 0, '', '', NULL),
 ('BKS', '', '050', 'b', 0, 0, 'Номер одиниці', '',                     0, 0, '', '', '', 0, '', '', NULL),
 ('BKS', '', '050', 'd', 0, 0, 'Supplementary class number (MU) [OBSOLETE]', 'Supplementary class number (MU) [OBSOLETE]', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '051', '', 1, 'Відомості про копію, примірник, відтиск Бібліотеки Конгресу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '051', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '051', 'a', 0, 0, 'Класифікаційний номер', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '051', 'b', 0, 0, 'Номер об’єкту', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '051', 'c', 0, 0, 'Відомості про копії', '',               0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '052', '', 1, 'Код географічної класифікації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '052', '2', 0, 0, 'Джерело коду', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '052', '6', 0, 0, 'Зв’язок', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '052', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '052', 'a', 0, 0, 'Код географічної класифікації регіону', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '052', 'b', 0, 1, 'Код географічної класифікації області регіону', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '052', 'c', 0, 1, 'Назва населеного пункту', '',           0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '052', 'd', 0, 1, 'Populated place name', 'Populated place name', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '055', '', 1, 'Шифр розміщення Національної бібліотеки Канади', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '055', '2', 0, 0, 'Source of call/class number', '',       0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '055', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '055', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '055', 'a', 0, 0, 'Класифікаційний номер', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '055', 'b', 0, 0, 'Номер об’єкту', '',                     0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '060', '', 1, 'Шифр розміщення Національної медичної бібліотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '060', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '060', 'a', 0, 1, 'Класифікаційний номер', '',           0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '060', 'b', 0, 0, 'Номер об’єкту', '',                   0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '061', '', 1, 'Відомості про примірник Національної медичної бібліотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '061', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '061', 'a', 0, 1, 'Класифікаційний номер', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '061', 'b', 0, 0, 'Номер об’єкту', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '061', 'c', 0, 0, 'Відомості про копії', '',               0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '066', '', '', 'Використовувані набори символів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '066', 'a', 0, 0, 'Набір символів G0', '',               0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '066', 'b', 0, 0, 'Набір символів G1', '',               0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '066', 'c', 0, 1, 'Альтернативний набір символів', '',   0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '070', '', 1, 'Шифр розміщення Національної сільськогосподарської бібліотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '070', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '070', 'a', 0, 1, 'Класифікаційний номер', '',           0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '070', 'b', 0, 0, 'Номер об’єкту', '',                   0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '071', '', 1, 'Відомості про примірник Національної сільськогосподарської бібліотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '071', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '071', 'a', 0, 1, 'Класифікаційний номер', '',             0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '071', 'b', 0, 0, 'Номер об’єкту', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '071', 'c', 0, 0, 'Відомості про копії', '',               0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '072', '', 1, 'Код предметної/темат. категорії', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '072', '2', 0, 0, 'Джерело коду', '',                    0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '072', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '072', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '072', 'a', 0, 0, 'Код предметної/темат. категорії', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '072', 'x', 0, 1, 'Код нижчестоящої предм./темат. категорії', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '074', '', 1, 'Номер GPO для одиниці опису', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '074', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '074', 'a', 0, 0, 'Номер об’єкту GPO', '',               0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '074', 'z', 0, 1, 'Анульований/помилковий номер об’єкту GPO', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '080', '', 1, 'Індекс УДК', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '080', '2', 0, 0, 'Ідентифікатор видання', '',           0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '080', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '080', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '080', 'a', 0, 0, 'Індекс УДК', '',                      0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '080', 'b', 0, 0, 'Номер одиниці', '',                   0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '080', 'x', 0, 0, 'Допоміж. ділення загал. характеру', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '082', '', 1, 'Індекс Дьюї', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '082', '2', 0, 0, 'Номер видання', '',                     0, 0, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '082', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    0, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '082', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '082', 'a', 0, 1, 'Індекс Дьюї', '',                       0, 0, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '082', 'b', 0, 0, 'Номер одиниці', '',                     0, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '084', '', 1, 'Індекс ББК', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '084', '2', 0, 0, 'Джерело індексу', '',                 0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '084', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '084', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '084', 'a', 0, 1, 'Індекс іншої класифікації / індекс ББК', '',                      0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '084', 'b', 0, 0, 'Номер одиниці', '',                   0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '086', '', 1, 'Класифікаційний номер документа органу державної влади', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '086', '2', 0, 0, 'Джерело індексу', '',                 0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '086', '6', 0, 0, 'Зв’язок', '',                         0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '086', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '086', 'a', 0, 0, 'Класифікаційний номер / номер документа', '', 0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '086', 'z', 0, 1, 'Скасований/помилковий класифікаційний номер/номер документа', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '087', '', 1, 'Номер звіту (застаріле, CAN/MARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '087', 'a', 0, 0, 'Номер звіту (застаріле, CAN/MARC)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '087', 'z', 0, 1, 'Анульований/помилковий номер звіту (застаріле, CAN/MARC)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '088', '', 1, 'Номер звіту', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '088', '6', 0, 0, 'Зв’язок', '',                         0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '088', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '088', 'a', 0, 0, 'Номер звіту', '',                     0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '088', 'z', 0, 1, 'Скасований/помилковий номер звіту', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '091', '', '', 'Індекси/коди', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '091', 'a', 0, 0, 'Індекс ББК', '',                        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '092', '', 1, 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '092', '2', 0, 0, 'Edition number', 'Edition number',      0, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '092', 'a', 0, 0, 'Класифікаційний номер', '',             0, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '092', 'b', 0, 0, 'Номер об’єкту', '',                     0, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '092', 'e', 0, 0, 'Feature heading', 'Feature heading',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '092', 'f', 0, 0, 'Filing suffix', 'Filing suffix',        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '096', '', 1, 'Локально присвоєний NLM-номер заявки (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '096', 'a', 0, 0, 'Класифікаційний номер', '',             0, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '096', 'b', 0, 0, 'Номер об’єкту', '',                     0, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '096', 'e', 0, 0, 'Feature heading', 'Feature heading',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '096', 'f', 0, 0, 'Filing suffix', 'Filing suffix',        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '098', '', 1, 'Інші схеми класифікації (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '098', 'a', 0, 0, 'Call number based on other classification scheme', 'Call number based on other classification scheme', 0, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '098', 'e', 0, 0, 'Feature heading', 'Feature heading',    0, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '098', 'f', 0, 0, 'Filing suffix', 'Filing suffix',        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '100', '', '', 'Автор', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '100', '4', 0, 0, 'Код відношення', '',                    1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', '6', 0, 0, 'Зв’язок', '',                           1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', 'PERSO_NAME', '100', 'a', 0, 0, 'Автор', '',                   1, 0, 'biblio.author', '', '', 0, '\'100b\',\'100c\',\'100q\',\'100d\',\'100e\',\'110a\',\'110b\',\'110c\',\'110d\',\'110e\',\'111a\',\'111e\',\'111c\',\'111d\',\'130a\',\'700a\',\'700b\',\'700c\',\'700q\',\'700d\',\'700e\',\'710a\',\'710b\',\'710c\',\'710d\',\'710e\',\'711a\',\'711e\',\'711c\',\'711d\',\'720a\',\'720e\',\'796a\',\'796b\',\'796c\',\'796q\',\'796d\',\'796e\',\'797a\',\'797b\',\'797c\',\'797d\',\'797e\',\'798a\',\'798e\',\'798c\',\'798d\',\'800a\',\'800b\',\'800c\',\'800q\',\'800d\',\'800e\',\'810a\',\'810b\',\'810c\',\'810d\',\'810e\',\'811a\',\'811e\',\'811c\',\'811d\',\'896a\',\'896b\',\'896c\',\'896q\',\'896d\',\'896e\',\'897a\',\'897b\',\'897c\',\'897d\',\'897e\',\'898a\',\'898e\',\'898c\',\'898d\',\'505r\'', '', NULL),
 ('BKS', '', '100', 'b', 0, 0, 'Династ. номер', '',                     1, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'c', 0, 0, 'Титул (звання)', '',                    1, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'd', 0, 0, 'Дата', '',                              1, 0, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'e', 0, 0, 'Роль осіб', '',                         1, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'f', 0, 0, 'Дата публікації', '',                   1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'g', 0, 0, 'Інші відомості', '',                    1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'j', 0, 1, 'Приналежність невідомого автора до послідовників, учнів, прихильників, школі і т. ін.', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'k', 0, 1, 'Підзаголовок форми', '',                1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'l', 0, 0, 'Мова роботи', '',                       1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'q', 0, 0, 'Повне ім’я', '',                        1, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 't', 0, 0, 'Назва роботи', '',                      1, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '100', 'u', 0, 0, 'Доповнення', '',                        1, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '110', '', '', 'Автор — організація', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '110', '4', 0, 1, 'Код відношення', '',                    1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', '6', 0, 0, 'Зв’язок', '',                           1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'CORPO_NAME', '110', 'a', 0, 0, 'Організація/юрисдикція', '',  1, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'b', 0, 0, 'Підпорядкована одиниця', '',            1, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'c', 0, 0, 'Місце', '',                             1, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'd', 0, 0, 'Дата', '',                              1, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'e', 0, 1, 'Термін відношення', '',                 1, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'f', 0, 0, 'Дата роботи', '',                       1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'g', 0, 0, 'Інша інформація', '',                   1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'k', 0, 1, 'Підзаголовок форми', '',                1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'l', 0, 0, 'Мова роботи', '',                       1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'n', 0, 1, 'Номер', '',                             1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'p', 0, 1, 'Назва частини/розділу роботи', '',      1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 't', 0, 0, 'Назва роботи', '',                      1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '110', 'u', 0, 0, 'Додаткові відомості', '',               1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '111', '', '', 'Автор-захід', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '111', '4', 0, 1, 'Код відношення', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', '6', 0, 0, 'Зв’язок', '',                         1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'MEETI_NAME', '111', 'a', 0, 0, 'Назва заходу', '',            1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'b', 0, 0, 'Number [OBSOLETE]', 'Number [OBSOLETE]', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'c', 0, 0, 'Місце заходу', '',                    1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'd', 0, 0, 'Дата заходу', '',                     1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'e', 0, 0, 'Підпорядк.одиниця', '',               1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'f', 0, 0, 'Дата роботи', '',                     1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'g', 0, 0, 'Інша інформація', '',                 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'j', 0, 1, 'Термін відношенння (роль)', '',       1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'k', 0, 1, 'Підзаголовок форми', '',              1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'l', 0, 0, 'Мова роботи', '',                     1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'n', 0, 0, '№ частини/секції', '',                1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'p', 0, 0, '№ частини/розділу', '',               1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 't', 0, 0, 'Назва роботи', '',                    1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '111', 'u', 0, 0, 'Додаткові відомості', '',             1, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '130', '', '', 'Заголовок — уніфікована назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '130', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'UNIF_TITLE', '130', 'a', 0, 0, 'Уніфікована назва', '',       1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'd', 0, 1, 'Дата підписання договору', '',        1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'f', 0, 0, 'Дата публікації', '',                 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'g', 0, 0, 'Інші відомості', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'h', 0, 0, 'Фізичний носій', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'k', 0, 1, 'Форма, вид, жанр', '',                1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'l', 0, 0, 'Мова твору', '',                      1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'm', 0, 1, 'Засіб виконання музичного твору', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'n', 0, 1, 'Номер частини/розділу', '',           1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'o', 0, 0, 'Позначення аранжування', '',          1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'p', 0, 1, 'Назва частини/розділу', '',           1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 'r', 0, 0, 'Тональність', '',                     1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 's', 0, 0, 'Версія, видання', '',                 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '130', 't', 0, 0, 'Назва роботи', '',                    1, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '210', '', 1, 'Скорочена назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '210', '2', 0, 1, 'Джерело інформації', '',              2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '210', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '210', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '210', 'a', 0, 0, 'Скорочена назва', '',                 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '210', 'b', 0, 0, 'Ідентифікаційні ознаки', '',          2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '211', '', 1, 'Скорочене найменування чи скорочена назва (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '211', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '211', 'a', 0, 0, 'Скорочене найменування чи скорочена назва', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '212', '', 1, 'Варіант доступної назви (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '212', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '212', 'a', 0, 0, 'Варіант доступної назви', '',         2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '214', '', 1, 'Розширена назва (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '214', '6', 0, 0, 'Елемент зв’язку', '',                 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '214', 'a', 0, 0, 'Розширена назва', '',                 2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '222', '', 1, 'Ключова назва серіального видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '222', '6', 0, 0, 'Елемент зв’язку', '',                 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '222', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '222', 'a', 0, 0, 'Ключова назва серіал. вид.', '',      2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '222', 'b', 0, 0, 'Ідентифікаційні ознаки', '',          2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '240', '', '', 'Умовна назва', '', 'Unititle');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '240', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'a', 0, 0, 'Умовна назва', '',                      2, -1, 'biblio.unititle', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'd', 0, 1, 'Дата підписання договору', '',          2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'f', 0, 0, 'Дата публікації', '',                   2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'g', 0, 0, 'Інші відомості', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'h', 0, 0, 'Фізич.носій (визнач. матеріалу)', '',   2, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'k', 0, 1, 'Форма, вид, жанр', '',                  2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'l', 0, 0, 'Мова твору', '',                        2, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'm', 0, 1, 'Засіб виконання музичного твору', '',   2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'n', 0, 1, '№ частини/розділу', '',                 2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'o', 0, 0, 'Позначення аранжування', '',            2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'p', 0, 1, 'Назва частини/розділу', '',             2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 'r', 0, 0, 'Тональність', '',                       2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '240', 's', 0, 0, 'Версія, видання і т.ін.', '',           2, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '241', '', '', 'Ліцензована назва (застаріле)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '241', 'a', 0, 0, 'Ліцензована назва', '',               2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '241', 'h', 0, 0, 'Фізичний носій', '',                  2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '242', '', 1, 'Переклад назви каталог. організацією', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '242', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '242', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '242', 'a', 0, 0, 'Переклад назви', '',                  2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '242', 'b', 0, 0, 'Продовж.пер.назви', '',               2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '242', 'c', 0, 0, 'Відповідальність', '',                2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '242', 'd', 0, 0, 'Designation of section (BK AM MP MU VM SE) [OBSOLETE]', 'Designation of section (BK AM MP MU VM SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '242', 'e', 0, 0, 'Name of part/section (BK AM MP MU VM SE) [OBSOLETE]', 'Name of part/section (BK AM MP MU VM SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '242', 'h', 0, 0, 'Фізичний носій (визнач. матеріалу)', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '242', 'n', 0, 1, 'Номер частини/розділу', '',           2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '242', 'p', 0, 1, 'Назва частини/розділу', '',           2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '242', 'y', 0, 0, 'Код мови перекладу', '',              2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '243', '', '', 'Узагальнююча назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '243', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'a', 0, 0, 'Узагальнююча назва', '',                2, -1, '', '', '', 1, '', '', NULL),
 ('BKS', '', '243', 'd', 0, 1, 'Дата підписання договору', '',          2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'f', 0, 0, 'Дата публікації', '',                   2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'g', 0, 0, 'Інші відомості', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'h', 0, 0, 'Фізич. носій', '',                      2, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'k', 0, 1, 'Форма, вид,  жанр', '',                 2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'l', 0, 0, 'Мова твору', '',                        2, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'm', 0, 0, 'Засіб для вик. музич. твору', '',       2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'n', 0, 1, 'Номер частини/розділу', '',             2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'o', 0, 0, 'Від. про аранжировку муз. твору', '',   2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'p', 0, 1, 'Назва частини/розділу', '',             2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 'r', 0, 0, 'Музичний ключ', '',                     2, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '243', 's', 0, 0, 'Версія, видання', '',                   2, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '245', 1, '', 'Назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '245', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'a', 0, 0, 'Назва', '',                             2, 0, 'biblio.title', '', '', NULL, '\'245b\',\'245f\',\'245g\',\'245k\',\'245n\',\'245p\',\'245s\',\'245h\',\'246i\',\'246a\',\'246b\',\'246f\',\'246g\',\'246n\',\'246p\',\'246h\',\'242a\',\'242b\',\'242n\',\'242p\',\'242h\'', '', NULL),
 ('BKS', '', '245', 'b', 0, 0, 'Продовж. назви', '',                    2, 0, 'bibliosubtitle.subtitle', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'c', 0, 0, 'Відповідальність', '',                  2, 0, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'd', 0, 0, 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series: (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'e', 0, 0, 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'f', 0, 0, 'Дати створення твору', '',              2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'g', 0, 0, 'Дати створення осн. частини твору', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'h', 0, 0, 'Фізичний носій', '',                    2, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'k', 0, 1, 'Форма, вид, жанр', '',                  2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'n', 0, 1, 'Номер частини/розділу', '',             2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 'p', 0, 1, 'Назва частини/розділу', '',             2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '245', 's', 0, 0, 'Версія', '',                            2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '246', '', 1, 'Інша форма назви', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '246', '5', 0, 0, 'Приналежність поля організації', '',    2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'a', 0, 0, 'Інша форма назви', '',                  2, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'b', 0, 0, 'Прод. інш. форми назви', '',            2, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'd', 0, 0, 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'e', 0, 0, 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'f', 0, 0, 'Том, випуск і/або дата', '',            2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'g', 0, 0, 'Інша інформація', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'h', 0, 1, 'Фізичичний носій', '',                  2, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'i', 0, 1, 'Пояснювальний текст', '',               2, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'n', 0, 1, 'Номер частини/розділу', '',             2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '246', 'p', 0, 1, 'Назва частини', '',                     2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '247', '', 1, 'Сформований заголовок', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '247', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'a', 0, 0, 'Заголовок', '',                         2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'b', 0, 0, 'Remainder of title', 'Remainder of title', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'd', 0, 0, 'Designation of section (SE) [OBSOLETE]', 'Designation of section (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'e', 0, 0, 'Name of part/section (SE) [OBSOLETE]', 'Name of part/section (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'f', 0, 0, 'Date or sequential designation', 'Date or sequential designation', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'g', 0, 0, 'Інші відомості', '',                    2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'h', 0, 0, 'Фізичний носій', '',                    2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '247', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '250', '', '', 'Відомості про видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '250', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '250', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '250', 'a', 0, 0, 'Основні відомості про видання', '',     2, 0, 'biblioitems.editionstatement', '', '', NULL, '', '', NULL),
 ('BKS', '', '250', 'b', 0, 0, 'Додаткові відомості про видання', '',   2, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '254', '', '', 'Представл. музичного твору', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '254', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '254', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '254', 'a', 0, 0, 'Представл. муз. твору', '',             2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '255', '', 1, 'Картогр. математичні дані', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '255', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '255', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '255', 'a', 0, 1, 'Картогр. матем. дані', '',              2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '255', 'b', 0, 0, 'Відомості про проекцію', '',            2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '255', 'c', 0, 0, 'Відомості про координати', '',          2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '255', 'd', 0, 0, 'Відомості про зону', '',                2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '255', 'e', 0, 0, 'Відомості про рівнодення', '',          2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '255', 'f', 0, 0, 'Зовнішні коорд.пари G-кілець', '',      2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '255', 'g', 0, 0, 'Викл. коорд. пари G-кілець', '',        2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '256', '', '', 'Характ. комп’ютерного файлу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '256', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '256', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '256', 'a', 0, 0, 'Характ. комп’ютерного файлу', '',       2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '257', '', '', 'Країна виробник арх. фільмів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '257', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '257', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '257', 'a', 0, 0, 'Країна виробник арх. фільмів', '',      2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '258', '', 1, 'Дані про філателістські об’єкти (одиниці)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '258', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '258', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '258', 'a', 0, 0, 'Issuing jurisdiction', 'Issuing jurisdiction', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '258', 'b', 0, 0, 'Denomination', 'Denomination',          2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '260', '', 1, 'Вихідні дані', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '260', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'a', 0, 1, 'Місце видання', '',                     2, 0, 'biblioitems.place', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'b', 0, 1, 'Видавництво', '',                       2, 0, 'biblioitems.publishercode', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'c', 0, 1, 'Дата видання', '',                      2, 0, 'biblio.copyrightdate', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'd', 0, 0, 'Plate or publishers number for music (Pre-AACR 2) (застаріле, CAN/MARC), (локальне, США)', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'e', 0, 0, 'Місце друкування', '',                  2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'f', 0, 0, 'Друкарня', '',                          2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'g', 0, 0, 'Дата друкування', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'k', 0, 0, 'Identification/manufacturer number [OBSOLETE, CAN/MARC]', 'Identification/manufacturer number [OBSOLETE, CAN/MARC]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '260', 'l', 0, 0, 'Matrix and/or take number [OBSOLETE, CAN/MARC]', 'Matrix and/or take number [OBSOLETE, CAN/MARC]', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '261', '', '', 'Вихідні дані фільму (застаріле, Канада) (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '261', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '261', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '261', 'a', 0, 1, 'Producing company', 'Producing company', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '261', 'b', 0, 1, 'Releasing company (primary distributor)', 'Releasing company (primary distributor)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '261', 'c', 0, 1, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '261', 'd', 0, 1, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '261', 'e', 0, 1, 'Contractual producer', 'Contractual producer', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '261', 'f', 0, 1, 'Place of production, release, etc.', 'Place of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '262', '', '', 'Вихідні дані звукозапису (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '262', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '262', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '262', 'a', 0, 0, 'Place of production, release, etc.', 'Place of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '262', 'b', 0, 0, 'Publisher or trade name', 'Publisher or trade name', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '262', 'c', 0, 0, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '262', 'k', 0, 0, 'Serial identification', 'Serial identification', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '262', 'l', 0, 0, 'Matrix and/or take number', 'Matrix and/or take number', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '263', '', '', 'Запланована дата публікації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '263', '6', 0, 0, 'Елемент зв’язку', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '263', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '263', 'a', 0, 0, 'Запланована дата публікації', '',       2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '265', '', '', 'Джерело придбання / підписка на розсилання (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '265', '6', 0, 0, 'Елемент зв’язку (застаріле)', '',       2, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '265', 'a', 0, 1, 'Джерело придбання / підписка на розсилання (застаріле)', '', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '270', '', 1, 'Адреса', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '270', '4', 0, 1, 'Код відношення', '',                  9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', '6', 0, 0, 'Елемент зв’язку', '',                 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'a', 0, 1, 'Адреса', '',                          9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'b', 0, 0, 'City', 'City',                        9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'c', 0, 0, 'State or province', 'State or province', 9, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'd', 0, 0, 'Country', 'Country',                  9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'e', 0, 0, 'Postal code', 'Postal code',          9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'f', 0, 0, 'Terms preceding attention name', 'Terms preceding attention name', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'g', 0, 0, 'Attention name', 'Attention name',    9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'h', 0, 0, 'Attention position', 'Attention position', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'i', 0, 0, 'Type of address', 'Type of address',  9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'j', 0, 1, 'Specialized telephone number', 'Specialized telephone number', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'k', 0, 1, 'Telephone number', 'Telephone number', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'l', 0, 1, 'Fax number', 'Fax number',            9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'm', 0, 1, 'Electronic mail address', 'Electronic mail address', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'n', 0, 1, 'TDD or TTY number', 'TDD or TTY number', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'p', 0, 1, 'Contact person', 'Contact person',    9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'q', 0, 1, 'Title of contact person', 'Title of contact person', 9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'r', 0, 1, 'Hours', 'Hours',                      9, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '270', 'z', 0, 1, 'Примітка для ЕК', '',                 9, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '300', '', 1, 'Фізичний опис', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '300', '3', 0, 0, 'Область застосування даних поля', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', '6', 0, 0, 'Елемент зв’язку', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'a', 0, 1, 'Обсяг', '',                             3, 0, 'biblioitems.pages', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'b', 0, 0, 'Ілл./тип відтвор.', '',                 3, 0, 'biblioitems.illus', '', '', 0, '', '', NULL),
 ('BKS', '', '300', 'c', 0, 1, 'Розміри', '',                           3, 0, 'biblioitems.size', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'd', 0, 0, 'Accompanying material [застаріло, CAN/MARC]', 'Accompanying material [OBSOLETE, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'e', 0, 0, 'Супров. мат-л', '',                     3, 0, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'f', 0, 1, 'Тип одиниці', '',                       3, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'g', 0, 1, 'Розмір одиниці', '',                    3, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'k', 0, 0, 'Speed [Videodiscs, pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 'Speed [Videodiscs, pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'm', 0, 0, 'Identification/manufacturer number [pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 'Identification/manufacturer number [pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '300', 'n', 0, 0, 'Matrix and/or take number [Sound recordings, pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 'Matrix and/or take number [Sound recordings, pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '301', '', '', 'Фізичний опис фільму (застаріле, USMARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '301', 'a', 0, 0, 'Extent of item', 'Extent of item',      3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '301', 'b', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '301', 'c', 0, 0, 'Color characteristics', 'Color characteristics', 3, -6, '', '', NULL, NULL, '', '', NULL),
 ('BKS', '', '301', 'd', 0, 0, 'Dimensions', 'Dimensions',              3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '301', 'e', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '301', 'f', 0, 0, 'Speed', 'Speed',                        3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '302', '', '', 'Кількість сторінок чи елементів (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '302', 'a', 0, 0, 'Кількість сторінок', '',                3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '303', '', '', 'Одиниця виміру (застаріле, USMARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '303', 'a', 0, 0, 'Unit count', 'Unit count',              3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '304', '', '', 'Лінійний розмір (застаріле, USMARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '304', 'a', 0, 0, 'Linear footage', 'Linear footage',      3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '305', '', '', 'Фізичні характеристики звукового запису (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '305', '6', 0, 0, 'Елемент зв’язку', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '305', 'a', 0, 0, 'Extent', 'Extent',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '305', 'b', 0, 0, 'Other physical details', 'Other physical details', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '305', 'c', 0, 0, 'Dimensions', 'Dimensions',              3, -6, '', '', NULL, NULL, '', '', NULL),
 ('BKS', '', '305', 'd', 0, 0, 'Microgroove or standard', 'Microgroove or standard', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '305', 'e', 0, 0, 'Stereophonic, monaural', 'Stereophonic, monaural', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '305', 'f', 0, 0, 'Number of tracks', 'Number of tracks',  3, -6, '', '', NULL, NULL, '', '', NULL),
 ('BKS', '', '305', 'm', 0, 0, 'Serial identification', 'Serial identification', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '305', 'n', 0, 0, 'Matrix and/or take number', 'Matrix and/or take number', 3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '306', '', '', 'Тривалість звукового запису', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '306', '6', 0, 0, 'Елемент зв’язку', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '306', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '306', 'a', 0, 1, 'Тривалість звукового запису (ггххсс)', '', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '307', '', 1, 'Години', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '307', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '307', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '307', 'a', 0, 0, 'Години', '',                            3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '307', 'b', 0, 0, 'Дод. інформація', '',                   3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '308', '', 1, 'Фізичні характеристика фільму (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '308', '6', 0, 0, 'Елемент зв’язку', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '308', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '308', 'a', 0, 0, 'Number of reels', 'Number of reels',    3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '308', 'b', 0, 0, 'Footage', 'Footage',                    3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '308', 'c', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '308', 'd', 0, 0, 'Color characteristics', 'Color characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '308', 'e', 0, 0, 'Width', 'Width',                        3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '308', 'f', 0, 0, 'Presentation format', 'Presentation format', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '310', '', '', 'Періодичність п.в.', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '310', '6', 0, 0, 'Елемент зв’язку', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '310', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '310', 'a', 0, 0, 'Періодичність п.в.', '',              3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '310', 'b', 0, 0, 'Дата введення період.', '',           3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '315', '', '', 'Частотність (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '315', '6', 0, 0, 'Елемент зв’язку', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '315', 'a', 0, 1, 'Frequency', 'Frequency',                3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '315', 'b', 0, 1, 'Dates of frequency', 'Dates of frequency', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '321', '', 1, 'Попередня періодичність', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '321', '6', 0, 0, 'Елемент зв’язку', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '321', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '321', 'a', 0, 0, 'Попередня періодичність', '',         3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '321', 'b', 0, 0, 'Дата існуючої періодичності', '',     3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '340', '', 1, 'Фізичний носій', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '340', '3', 0, 0, 'Область застосування даних поля', '',   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', '6', 0, 0, 'Елемент зв’язку', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', 'a', 0, 1, 'Матер.основа', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', 'b', 0, 1, 'Розміри', '',                           3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', 'c', 0, 1, 'Матеріал покриття', '',                 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', 'd', 0, 1, 'Техніка запису', '',                    3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', 'e', 0, 1, 'Засіб кріплення', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', 'f', 0, 1, 'Production rate/ratio', 'Production rate/ratio', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', 'h', 0, 1, 'Location within medium', 'Location within medium', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '340', 'i', 0, 1, 'Technical specifications of medium', 'Technical specifications of medium', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '342', '', 1, 'Дані про геопросторову систему відліку', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '342', '2', 0, 0, 'Reference method used', 'Reference method used', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', '6', 0, 0, 'Елемент зв’язку', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'a', 0, 1, 'Name', 'Name',                          3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'b', 0, 0, 'Coordinate or distance units', 'Coordinate or distance units', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'c', 0, 0, 'Latitude resolution', 'Latitude resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'd', 0, 0, 'Longitude resolution', 'Longitude resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'e', 0, 1, 'Standard parallel or oblique line latitude', 'Standard parallel or oblique line latitude', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'f', 0, 1, 'Oblique line longitude', 'Oblique line longitude', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'g', 0, 0, 'Longitude of central meridian or projection center', 'Longitude of central meridian or projection center', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'h', 0, 0, 'Latitude of projection origin or projection center', 'Latitude of projection origin or projection center', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'i', 0, 0, 'False easting', 'False easting',        3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'j', 0, 0, 'False northing', 'False northing',      3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'k', 0, 0, 'Scale factor', 'Scale factor',          3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'l', 0, 0, 'Height of perspective point above surface', 'Height of perspective point above surface', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'm', 0, 0, 'Azimuthal angle', 'Azimuthal angle',    3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'n', 0, 0, 'Azimuth measure point longitude or straight vertical longitude from pole', 'Azimuth measure point longitude or straight vertical longitude from pole', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'o', 0, 0, 'Landsat number and path number', 'Landsat number and path number', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'p', 0, 0, 'Zone identifier', 'Zone identifier',    3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'q', 0, 0, 'Ellipsoid name', 'Ellipsoid name',      3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'r', 0, 0, 'Semi-major axis', 'Semi-major axis',    3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 's', 0, 0, 'Denominator of flattening ratio', 'Denominator of flattening ratio', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 't', 0, 0, 'Vertical resolution', 'Vertical resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'u', 0, 0, 'Vertical encoding method', 'Vertical encoding method', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'v', 0, 0, 'Local planar, local, or other projection or grid description', 'Local planar, local, or other projection or grid description', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '342', 'w', 0, 0, 'Local planar or local georeference information', 'Local planar or local georeference information', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '343', '', 1, 'Дані про планарні координати', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '343', '6', 0, 0, 'Елемент зв’язку', '',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'a', 0, 1, 'Planar coordinate encoding method', 'Planar coordinate encoding method', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'b', 0, 0, 'Planar distance units', 'Planar distance units', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'c', 0, 0, 'Abscissa resolution', 'Abscissa resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'd', 0, 0, 'Ordinate resolution', 'Ordinate resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'e', 0, 0, 'Distance resolution', 'Distance resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'f', 0, 0, 'Bearing resolution', 'Bearing resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'g', 0, 0, 'Bearing unit', 'Bearing unit',          3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'h', 0, 0, 'Bearing reference direction', 'Bearing reference direction', 3, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '343', 'i', 0, 0, 'Bearing reference meridian', 'Bearing reference meridian', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '350', '', 1, 'Ціна (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '350', '6', 0, 0, 'Елемент зв’язку', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '350', 'a', 0, 1, 'Ціна', '',                            3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '350', 'b', 0, 1, 'Form of issue', 'Form of issue',      3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '351', '', 1, 'Організація та розміщення матеріалів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '351', '3', 0, 0, 'Область застосування даних поля', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '351', '6', 0, 0, 'Елемент зв’язку', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '351', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '351', 'a', 0, 1, 'Organization', 'Organization',        3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '351', 'b', 0, 1, 'Arrangement', 'Arrangement',          3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '351', 'c', 0, 0, 'Hierarchical level', 'Hierarchical level', 3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '352', '', 1, 'Цифрове графічне представлення', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '352', '6', 0, 0, 'Елемент зв’язку', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', 'a', 0, 0, 'Direct reference method', 'Direct reference method', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', 'b', 0, 1, 'Object type', 'Object type',          3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', 'c', 0, 1, 'Object count', 'Object count',        3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', 'd', 0, 0, 'Row count', 'Row count',              3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', 'e', 0, 0, 'Column count', 'Column count',        3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', 'f', 0, 0, 'Vertical count', 'Vertical count',    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', 'g', 0, 0, 'VPF topology level', 'VPF topology level', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '352', 'i', 0, 0, 'Indirect reference description', 'Indirect reference description', 3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '355', '', 1, 'Контроль у відповідності з класифікацією секретності', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '355', '6', 0, 0, 'Елемент зв’язку', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'a', 0, 0, 'Класифікація секретності', '',        3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'b', 0, 1, 'Операційні інструкції', '',           3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'c', 0, 1, 'Інформація про зовнішнє розповсюдження', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'd', 0, 0, 'Інформація про зменшення або зняття секретності', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'e', 0, 0, 'Класифікаційна система', '',          3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'f', 0, 0, 'Код країни створення класифікації', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'g', 0, 0, 'Дата зменшення ступеня секретності', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'h', 0, 0, 'Дата зняття секретності', '',         3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '355', 'j', 0, 1, 'Санкціонування', '',                  3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '357', '', '', 'Авторський контроль за розповсюдженням', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '357', '6', 0, 0, 'Елемент зв’язку', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '357', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '357', 'a', 0, 0, 'Термін, що позначає авторський контроль', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '357', 'b', 0, 1, 'Організація-створювач, відповідальна за контроль', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '357', 'c', 0, 1, 'Отримувачі матеріала, що мають дозвіл', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '357', 'g', 0, 0, 'Інші обмеження', '',                  3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '359', '', '', 'Ціна орендної плати (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '359', 'a', 0, 0, 'Ціна орендної плати', '',             3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '362', '', 1, 'Дати публікації чи номер тому', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '362', '6', 0, 0, 'Елемент зв’язку', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '362', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '362', 'a', 0, 0, 'Дати публ.або номер тому', '',        3, -6, 'biblioitems.volumedesc', NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '362', 'z', 0, 0, 'Джерело відомостей', '',              3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '365', '', 1, 'Торговельна ціна', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '365', '2', 0, 0, 'Source of price type code', 'Source of price type code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', '6', 0, 0, 'Елемент зв’язку', '',                   9, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 9, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'a', 0, 0, 'Price type code', 'Price type code',    9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'b', 0, 0, 'Price amount', 'Price amount',          9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'c', 0, 0, 'Price type code', 'Price type code',    9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'd', 0, 0, 'Unit of pricing', 'Unit of pricing',    9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'e', 0, 0, 'Price note', 'Price note',              9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'f', 0, 0, 'Price effective from', 'Price effective from', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'g', 0, 0, 'Price effective until', 'Price effective until', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'h', 0, 0, 'Tax rate 1', 'Tax rate 1',              9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'i', 0, 0, 'Tax rate 2', 'Tax rate 2',              9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'j', 0, 0, 'ISO country code', 'ISO country code',  9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'k', 0, 0, 'MARC country code', 'MARC country code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '365', 'm', 0, 0, 'Identification of pricing entity', 'Identification of pricing entity', 9, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '366', '', 1, 'Інформація про наявність для придбання у видавця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '366', '2', 0, 0, 'Source of availability status code', 'Source of availability status code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', '6', 0, 0, 'Елемент зв’язку', '',                   9, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 9, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'a', 0, 0, 'Publishers compressed title identification', 'Publishers compressed title identification', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'b', 0, 0, 'Detailed date of publication', 'Detailed date of publication', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'c', 0, 0, 'Availability status code', 'Availability status code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'd', 0, 0, 'Expected next availability date', 'Expected next availability date', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'e', 0, 0, 'Note', 'Note',                          9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'f', 0, 0, 'Publishers discount category', 'Publishers discount category', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'g', 0, 0, 'Date made out of print', 'Date made out of print', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'j', 0, 0, 'ISO country code', 'ISO country code',  9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'k', 0, 0, 'MARC country code', 'MARC country code', 9, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '366', 'm', 0, 0, 'Identification of agency', 'Identification of agency', 9, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '400', '', 1, 'Область серії / додаткова пошукова ознака — індивідуальне ім’я (застаріле, CAN/MARC), (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '400', '4', 0, 1, 'Код відношення', '',                    4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', '6', 0, 0, 'Елемент зв’язку', '',                   4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'a', 0, 0, 'Personal name', 'Personal name',        4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'b', 0, 0, 'Numeration', 'Numeration',              4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'e', 0, 1, 'Термін відношенння (роль)', '',         4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'f', 0, 0, 'Дата публікації', '',                   4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'g', 0, 0, 'Інші відомості', '',                    4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'k', 0, 1, 'Підзаголовок форми', '',                4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'l', 0, 0, 'Мова роботи', '',                       4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 't', 0, 0, 'Назва роботи', '',                      4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'u', 0, 0, 'Додаткові відомості', '',               4, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '400', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '400', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '410', '', 1, 'Область серії / додаткова пошукова ознака — ім’я організації (застаріле, CAN/MARC), (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '410', '4', 0, 1, 'Код відношення', '',                    4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', '6', 0, 0, 'Елемент зв’язку', '',                   4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',  4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'e', 0, 1, 'Термін відношенння (роль)', '',         4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'f', 0, 0, 'Дата публікації', '',                   4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'g', 0, 0, 'Інші відомості', '',                    4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'k', 0, 1, 'Підзаголовок форми', '',                4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'l', 0, 0, 'Мова роботи', '',                       4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 't', 0, 0, 'Назва роботи', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'u', 0, 0, 'Додаткові відомості', '',               4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '410', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '411', '', 1, 'Область серії / додаткова пошукова ознака — назва заходу (застаріле, CAN/MARC), (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '411', '4', 0, 1, 'Код відношення', '',                  4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', '6', 0, 0, 'Елемент зв’язку', '',                 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'b', 0, 0, 'Number [OBSOLETE]', 'Number [OBSOLETE]', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'd', 0, 0, 'Date of meeting', 'Date of meeting',  4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'f', 0, 0, 'Дата публікації', '',                 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'g', 0, 0, 'Інші відомості', '',                  4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'k', 0, 1, 'Підзаголовок форми', '',              4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'l', 0, 0, 'Мова роботи', '',                     4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'p', 0, 1, 'Заголовок частини/розділу твору', '', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 't', 0, 0, 'Назва роботи', '',                    4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '411', 'u', 0, 0, 'Додаткові відомості', '',             4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '411', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '411', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '440', '', 1, 'Серія', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '440', '6', 0, 0, 'Елемент зв’язку', '',                   4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '440', '8', 0, 1, 'Зв’язок полів та номер послідовності', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'UNIF_TITLE', '440', 'a', 0, 0, 'Серія', '',                   4, 0, 'biblio.seriestitle', '', '', NULL, '\'440n\',\'440p\',\'490a\',\'830a\',\'830n\',\'830p\',\'899a\'', '', NULL),
 ('BKS', '', '440', 'n', 0, 1, 'Номер частини', '',                     4, 0, 'biblioitems.number', '', '', NULL, '', '', NULL),
 ('BKS', '', '440', 'p', 0, 1, 'Назва частини', '',                     4, 0, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '440', 'v', 0, 0, '№ тому', '',                            4, 0, 'biblioitems.volume', '', '', NULL, '', '', NULL),
 ('BKS', '', '440', 'x', 0, 0, 'ISSN серії', '',                        4, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '490', '', 1, 'Серія', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '490', '6', 0, 0, 'Елемент зв’язку', '',                   4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '490', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 4, -6, '', '', NULL, NULL, '', '', NULL),
 ('BKS', '', '490', 'a', 0, 1, 'Назва серії', '',                       4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '490', 'l', 0, 0, 'Library of Congress call number', 'Library of Congress call number', 4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '490', 'v', 0, 1, '№ тому', '',                            4, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '490', 'x', 0, 0, 'ISSN серії', '',                        4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '500', '', 1, 'Примітка', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '500', '3', 0, 0, 'Область застосування даних поля', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '500', '5', 0, 0, 'Приналежність поля організації', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '500', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '500', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '500', 'a', 0, 0, 'Примітка', '',                          5, -1, 'biblio.notes', '', '', NULL, '', '', NULL),
 ('BKS', '', '500', 'l', 0, 0, 'Library of Congress call number (SE) (застаріле)', 'Library of Congress call number (SE) [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '500', 'n', 0, 0, 'n (RLIN) (застаріле)', 'n (RLIN) [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '500', 'x', 0, 0, 'International Standard Serial Number (SE) (застаріле)', 'International Standard Serial Number (SE) [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '500', 'z', 0, 0, 'Source of note information (AM SE) (застаріле)', 'Source of note information (AM SE) [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '501', '', 1, 'Примітка ’з ...', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '501', '5', 0, 0, 'Організація, для якої застосовується поле', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '501', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '501', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '501', 'a', 0, 0, 'Примітка ’з …', '',                     5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '502', '', 1, 'Примітка про дисертацію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '502', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '502', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '502', 'a', 0, 0, 'Примітка про дисертацію', '',           5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '503', '', 1, 'Примітка про бібліографічну історію (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '503', '8', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '503', 'a', 0, 0, 'Примітка про бібліографічну історію', '', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '504', '', 1, 'Бібліографія', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '504', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '504', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '504', 'a', 0, 0, 'Бібліографія', '',                    5, -6, '', NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '504', 'b', 0, 0, 'Number of references', 'Number of references', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '505', '', 1, 'Форматований зміст', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '505', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '505', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '505', 'a', 0, 0, 'Форматований зміст', '',                5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '505', 'g', 0, 1, 'Інші відомості', '',                    5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '505', 'r', 0, 1, 'Statement of responsibility', 'Statement of responsibility', 5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '505', 't', 0, 1, 'Title', 'Title',                        5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '505', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -1, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '506', '', 1, 'Примітка про обмеження доступу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '506', '2', 0, 0, 'Джерело терміну', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', '3', 0, 0, 'Область застосування даних поля', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', '5', 0, 0, 'Приналежність поля організації', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', 'a', 0, 0, 'Terms governing access', 'Terms governing access', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', 'b', 0, 1, 'Jurisdiction', 'Jurisdiction',          5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', 'c', 0, 1, 'Physical access provisions', 'Physical access provisions', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', 'd', 0, 1, 'Authorized users', 'Authorized users',  5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', 'e', 0, 1, 'Authorization', 'Authorization',        5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', 'f', 0, 1, 'Standardized terminology for access restriction', 'Standardized terminology for access restriction', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '506', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '507', '', '', 'Примітка про масштаб для графічного матеріалу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '507', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '507', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '507', 'a', 0, 0, 'Representative fraction of scale note', 'Representative fraction of scale note', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '507', 'b', 0, 0, 'Remainder of scale note', 'Remainder of scale note', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '508', '', 1, 'Примітка про співвиконавців твору', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '508', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '508', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '508', 'a', 0, 0, 'Примітка про співвиконавців твору', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '509', '', '', 'Примітка у довільній формі', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '509', 'a', 0, 0, 'Примітка у довільній формі', '',      5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '510', '', 1, 'Примітка про посилання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '510', '3', 0, 0, 'Область застосування даних поля', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '510', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '510', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '510', 'a', 0, 0, 'Примітка про посилання', '',            5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '510', 'b', 0, 0, 'Coverage of source', 'Coverage of source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '510', 'c', 0, 0, 'Location within source', 'Location within source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '510', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '511', '', 1, 'Інформація про виконавців', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '511', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '511', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '511', 'a', 0, 0, 'Інформація про виконавців', '',         5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '512', '', 1, 'Примітка до попереднього та подальшого роздільника у каталозі (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '512', '6', 0, 0, 'Елемент зв’язку', '',                   -1, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '512', 'a', 0, 0, 'Примітка до попереднього та подальшого роздільника у каталозі', '', -1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '513', '', 1, 'Примітка про тип і хронологічний обсяг звіту', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '513', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '513', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '513', 'a', 0, 0, 'Type of report', 'Type of report',      5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '513', 'b', 0, 0, 'Period covered', 'Period covered',      5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '514', '', '', 'Примітка про якість даних', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '514', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'a', 0, 0, 'Attribute accuracy report', 'Attribute accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'b', 0, 1, 'Attribute accuracy value', 'Attribute accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'c', 0, 1, 'Attribute accuracy explanation', 'Attribute accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'd', 0, 0, 'Logical consistency report', 'Logical consistency report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'e', 0, 0, 'Completeness report', 'Completeness report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'f', 0, 0, 'Horizontal position accuracy report', 'Horizontal position accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'g', 0, 1, 'Horizontal position accuracy value', 'Horizontal position accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'h', 0, 1, 'Horizontal position accuracy explanation', 'Horizontal position accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'i', 0, 0, 'Vertical positional accuracy report', 'Vertical positional accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'j', 0, 1, 'Vertical positional accuracy value', 'Vertical positional accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'k', 0, 1, 'Vertical positional accuracy explanation', 'Vertical positional accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'm', 0, 0, 'Cloud cover', 'Cloud cover',            5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '514', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL),
 ('BKS', '', '514', 'z', 0, 1, 'Display note', 'Display note',          5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '515', '', 1, 'Примітка про особливості нумерації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '515', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '515', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '515', 'a', 0, 0, 'Примітка про особливості нумерації', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '515', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', -1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '516', '', 1, 'Примітка про тип комп’ютерних файлу/даних', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '516', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '516', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '516', 'a', 0, 0, 'Примітка про тип комп’ютерних файлу/даних', '', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '517', '', '', 'Примітка про категорію фільму (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '517', 'a', 0, 0, 'Different formats', 'Different formats', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '517', 'b', 0, 1, 'Content descriptors', 'Content descriptors', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '517', 'c', 0, 1, 'Additional animation techniques', 'Additional animation techniques', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '518', '', 1, 'Примітка про дату/час і місце події', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '518', '3', 0, 0, 'Область застосування даних поля', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '518', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '518', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '518', 'a', 0, 0, 'Date/time and place of an event note', 'Date/time and place of an event note', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '520', '', 1, 'Анотація', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '520', '3', 0, 0, 'Область застосування даних поля', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '520', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '520', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '520', 'a', 0, 0, 'Анотація', '',                          5, -1, 'biblio.abstract', '', '', NULL, '', '', NULL),
 ('BKS', '', '520', 'b', 0, 0, 'Примітка, що містить розширену анотацію', '', 5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '520', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -1, '', '', '', 1, '', '', NULL),
 ('BKS', '', '520', 'z', 0, 0, 'Source of note information [OBSOLETE]', 'Source of note information [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '521', '', 1, 'Примітка про цільове призначення', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '521', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '521', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '521', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '521', 'a', 0, 1, 'Примітка про цільове призначення', '', 5, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '521', 'b', 0, 0, 'Джерело, що визначає цільове призначення', '', 5, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '522', '', 1, 'Примітка про географічне охоплення', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '522', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '522', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '522', 'a', 0, 0, 'Примітка про географічне охоплення', '', 5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '523', '', '', 'Примітка про період часу у змісті (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '523', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '523', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '523', 'a', 0, 0, 'Примітка про період часу у змісті', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '524', '', 1, 'Примітка про форму посилання на матеріали, що описуються, якій надається перевага', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '524', '2', 0, 0, 'Source of schema used', 'Source of schema used', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '524', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '524', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '524', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '524', 'a', 0, 0, 'Примітка про форму посилання на матеріали, що описуються, якій надається перевага', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '525', '', '', 'Примітка про додаток', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '525', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '525', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '525', 'a', 0, 0, 'Примітка про додаток', '',            5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '525', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '526', '', '', 'Інформаційна примітка про навчальну програму', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '526', '5', 0, 0, 'Приналежність поля організації', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', 'a', 0, 0, 'Program name', 'Program name',          5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', 'b', 0, 0, 'Interest level', 'Interest level',      5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', 'c', 0, 0, 'Reading level', 'Reading level',        5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', 'd', 0, 0, 'Title point value', 'Title point value', 5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', 'i', 0, 0, 'Display text', 'Display text',          5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', 'x', 0, 1, 'Службова примітка', '',                 5, 6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '526', 'z', 0, 1, 'Примітка для ЕК', '',                   5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '527', '', 1, 'Примітка про цензуру (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '527', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '527', 'a', 0, 0, 'Примітка про цензуру', '',            5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '530', '', 1, 'Примітка про додаткові форми', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '530', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '530', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '530', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '530', 'a', 0, 0, 'Примітка про додаткові форми', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '530', 'b', 0, 0, 'Availability source', 'Availability source', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '530', 'c', 0, 0, 'Availability conditions', 'Availability conditions', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '530', 'd', 0, 0, 'Order number', 'Order number',        5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '530', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, NULL, NULL, '', 1, '', '', NULL),
 ('BKS', NULL, '530', 'z', 0, 0, 'Source of note information (AM CF VM SE) [OBSOLETE]', 'Source of note information (AM CF VM SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '533', '', 1, 'Примітка про копії', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '533', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', '7', 0, 0, 'Fixed-length data elements of reproduction', 'Fixed-length data elements of reproduction', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', 'a', 0, 0, 'Тип копії', '',                       5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', 'b', 0, 1, 'Місце копіювання', '',                5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', 'c', 0, 1, 'Організація, відпов. за копіюв.', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', 'd', 0, 0, 'Дата копіювання', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', 'e', 0, 0, 'Фіз. опис копії', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', 'f', 0, 1, 'Дані про серію', '',                  5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', 'm', 0, 1, 'Дати і поряд. познач.відтв.вип.', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '533', 'n', 0, 1, 'Примітка до копії', '',               5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '534', '', 1, 'Примітка про оригінал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '534', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'a', 0, 0, 'Заголовок на оригінал', '',           5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'b', 0, 0, 'Область видання', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'c', 0, 0, 'Вихідні дані оригіналу', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'e', 0, 0, 'Фізичні характеристики оригіналу', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'f', 0, 0, 'Область серії оригіналу', '',         5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'k', 0, 1, 'Ключова назва оригіналу', '',         5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'l', 0, 0, 'Місце оригіналу', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'm', 0, 0, 'Спец.характеристики', '',             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'n', 0, 1, 'Примітка про оригінал', '',           5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'p', 0, 0, 'Ввідні слова', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 't', 0, 0, 'Область заголовку на оригінал', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'x', 0, 1, 'ISSN', '',                            5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '534', 'z', 0, 1, 'ISBN', '',                            5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '535', '', 1, 'Приміт. про зберігання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '535', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '535', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '535', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '535', 'a', 0, 0, 'Сховище', '',                         5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '535', 'b', 0, 1, 'Поштова адреса', '',                  5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '535', 'c', 0, 1, 'Країна', '',                          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '535', 'd', 0, 1, 'Адреса телекомун.', '',               5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '535', 'g', 0, 0, 'Код зберігання', '',                  5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '536', '', 1, 'Інформаційна примітка про фінансування', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '536', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', 'a', 0, 0, 'Text of note', 'Text of note',        5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', 'b', 0, 1, 'Contract number', 'Contract number',  5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', 'c', 0, 1, 'Grant number', 'Grant number',        5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', 'd', 0, 1, 'Undifferentiated number', 'Undifferentiated number', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', 'e', 0, 1, 'Program element number', 'Program element number', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', 'f', 0, 1, 'Project number', 'Project number',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', 'g', 0, 1, 'Task number', 'Task number',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '536', 'h', 0, 1, 'Work unit number', 'Work unit number', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '537', '', '', 'Примітка про джерело дати (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '537', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '537', 'a', 0, 0, 'Примітка про джерело дати', '',       5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '538', '', 1, 'Примітка про системні особливості', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '538', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '538', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '538', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '538', 'a', 0, 0, 'Примітка про системні особливості', '', 5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '538', 'i', 0, 0, 'Display text', 'Display text',          5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '538', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -1, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '540', '', 1, 'Примітка про умови контролю за використанням і репродукцією', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '540', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '540', '5', 0, 0, 'Приналежність поля організації', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '540', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '540', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '540', 'a', 0, 0, 'Terms governing use and reproduction', 'Terms governing use and reproduction', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '540', 'b', 0, 0, 'Jurisdiction', 'Jurisdiction',          5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '540', 'c', 0, 0, 'Authorization', 'Authorization',        5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '540', 'd', 0, 0, 'Authorized users', 'Authorized users',  5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '540', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '541', '', 1, 'Примітка про безпосер. джер. компл.', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '541', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '541', '5', 0, 0, 'Приналежність поля організації', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'a', 0, 0, 'Отримано від/з', '',                    5, 1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'b', 0, 0, 'Адреса', '',                            5, 1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'c', 0, 0, 'Метод придбання', '',                   5, 1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'd', 0, 0, 'Дата придбання', '',                    5, 1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'e', 0, 0, 'Реєстраційний номер', '',               5, 1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'f', 0, 0, 'Власник', '',                           5, 1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'h', 0, 0, 'Ціна покупки', '',                      5, 1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'n', 0, 1, 'Кількість, обсяг', '',                  5, 1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '541', 'o', 0, 1, 'Назва одиниці вимірювання', '',         5, 1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '543', '', 1, 'Примітка про супровідну інформацію (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '543', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '543', 'a', 0, 0, 'Примітка про супровідну інформацію', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '544', '', 1, 'Примітка про місцезнаходження інших архівних матеріалів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '544', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '544', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '544', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '544', 'a', 0, 1, 'Custodian', 'Custodian',                5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '544', 'b', 0, 1, 'Address', 'Address',                    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '544', 'c', 0, 1, 'Country', 'Country',                    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '544', 'd', 0, 1, 'Title', 'Title',                        5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '544', 'e', 0, 1, 'Provenance', 'Provenance',              5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '544', 'n', 0, 1, 'Note', 'Note',                          5, -6, '', '', '', NULL, '', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '545', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '545', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '545', 'a', 0, 0, 'Biographical or historical note', 'Biographical or historical note', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '545', 'b', 0, 0, 'Expansion', 'Expansion',                5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '545', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '546', '', 1, 'Примітка про мову', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '546', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '546', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '546', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '546', 'a', 0, 0, 'Примітка про мову', '',               5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '546', 'b', 0, 1, 'Примітка про мову', '',               5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '546', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '547', '', 1, 'Довідка на попередній заголовок', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '547', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '547', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '547', 'a', 0, 0, 'Довідка на попередній заголовок', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '547', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '550', '', 1, 'Примітка про організацію, що видає', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '550', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '550', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '550', 'a', 0, 0, 'Примітка про організацію, що видає', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '550', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '552', '', 1, 'Інформаційна примітка про особливості та характерні ознаки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '552', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'a', 0, 0, 'Entity type label', 'Entity type label', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'b', 0, 0, 'Entity type definition and source', 'Entity type definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'c', 0, 0, 'Attribute label', 'Attribute label',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'd', 0, 0, 'Attribute definition and source', 'Attribute definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'e', 0, 1, 'Enumerated domain value', 'Enumerated domain value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'f', 0, 1, 'Enumerated domain value definition and source', 'Enumerated domain value definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'g', 0, 0, 'Range domain minimum and maximum', 'Range domain minimum and maximum', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'h', 0, 0, 'Codeset name and source', 'Codeset name and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'i', 0, 0, 'Unrepresentable domain', 'Unrepresentable domain', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'j', 0, 0, 'Attribute units of measurement and resolution', 'Attribute units of measurement and resolution', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'k', 0, 0, 'Beginning date and ending date of attribute values', 'Beginning date and ending date of attribute values', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'l', 0, 0, 'Attribute value accuracy', 'Attribute value accuracy', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'm', 0, 0, 'Attribute value accuracy explanation', 'Attribute value accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'n', 0, 0, 'Attribute measurement frequency', 'Attribute measurement frequency', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'o', 0, 1, 'Entity and attribute overview', 'Entity and attribute overview', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'p', 0, 1, 'Entity and attribute detail citation', 'Entity and attribute detail citation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '552', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL),
 ('BKS', '', '552', 'z', 0, 1, 'Display note', 'Display note',          5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '555', '', 1, 'Примітка про кумулятивний покажчик / допоміжних покажчиках', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '555', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '555', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '555', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '555', 'a', 0, 0, 'Примітка про кумулятивний покажчик / допоміжних покажчиках', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '555', 'b', 0, 1, 'Джерело придбання', '',               5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '555', 'c', 0, 0, 'Рівень контролю', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '555', 'd', 0, 0, 'Бібліографічне посилання', '',        5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '555', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, NULL, NULL, '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '556', '', 1, 'Примітка про супровідну документацію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '556', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '556', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '556', 'a', 0, 0, 'Примітка про супровідну документацію', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '556', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '561', '', 1, 'Історія існування', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '561', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '561', '5', 0, 0, 'Приналежність поля організації', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '561', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '561', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '561', 'a', 0, 0, 'Історія (примітка)', '',                5, 6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '561', 'b', 0, 0, 'Time of collation [OBSOLETE]', 'Time of collation [OBSOLETE]', 5, 6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '562', '', 1, 'Примітка про ідентифікуючі ознаки копій чи версій архівних та рукописних матеріалів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '562', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '562', '5', 0, 0, 'Institution to which field applies', '', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '562', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '562', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '562', 'a', 0, 1, 'Identifying markings', 'Identifying markings', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '562', 'b', 0, 1, 'Copy identification', 'Copy identification', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '562', 'c', 0, 1, 'Version identification', 'Version identification', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '562', 'd', 0, 1, 'Presentation format', 'Presentation format', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '562', 'e', 0, 1, 'Number of copies', 'Number of copies', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '563', '', 1, 'Інформація про оправу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '563', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '563', '5', 0, 0, 'Приналежність поля організації', '',  -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '563', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '563', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '563', 'a', 0, 0, 'Binding note', 'Binding note',        5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '563', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, NULL, NULL, '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '565', '', 1, 'Примітка про характеристики блоків файлу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '565', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '565', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '565', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '565', 'a', 0, 0, 'Примітка про характеристики блоків файлу', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '565', 'b', 0, 1, 'Назва перемінної величини', '',       5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '565', 'c', 0, 1, 'Unit of analysis', 'Unit of analysis', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '565', 'd', 0, 1, 'Universe of data', 'Universe of data', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '565', 'e', 0, 1, 'Filing scheme or code', 'Filing scheme or code', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '567', '', 1, 'Примітка про методологію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '567', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',  5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '567', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '567', 'a', 0, 0, 'Примітка про методологію', '',        5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '570', '', 1, 'Примітка про редактора (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '570', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '570', 'a', 0, 0, 'Примітка про редактора', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '570', 'z', 0, 0, 'Source of note information', 'Source of note information', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '580', '', 1, 'Примітка про зв’язок з іншими виданнями', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '580', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '580', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '580', 'a', 0, 0, 'Прим. про зв’язок з іншими виданнями', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '580', 'z', 0, 0, 'Source of note information (застаріле)', 'Source of note information [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '581', '', 1, 'Публікації про описуваний матеріал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '581', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '581', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '581', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '581', 'a', 0, 0, 'Назва публікації', '',                5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '581', 'z', 0, 1, 'ISBN публікації', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '582', '', 1, 'Примітка щодо пов’язаного комп’ютерного файлу (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '582', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '582', 'a', 0, 0, 'Примітка щодо пов’язаного комп’ютерного файлу', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '583', '', 1, 'Примітка про дії', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '583', '2', 0, 0, 'Джерело терміну', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '583', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '583', '5', 0, 0, 'Приналежність поля організації', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'a', 0, 0, 'Дія', '',                               5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'b', 0, 1, 'Ідентифікація дії', '',                 5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'c', 0, 1, 'Дата і час дії', '',                    5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'd', 0, 1, 'Період часу дії', '',                   5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'e', 0, 1, 'Умови під час дії', '',                 5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'f', 0, 1, 'Правила дії', '',                       5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'h', 0, 1, 'Відповідальна особа', '',               5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'i', 0, 1, 'Метод виконання', '',                   5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'j', 0, 1, 'Місце дії', '',                         5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'k', 0, 1, 'Виконавець дії', '',                    5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'l', 0, 1, 'Стан матеріалу', '',                    5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'n', 0, 1, 'Кількість, обсяг', '',                  5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'o', 0, 1, 'Одиниці виміру', '',                    5, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'u', 0, 1, 'Уніфік. ідентифікатор ресурсу', '',     5, -1, '', '', '', 1, '', '', NULL),
 ('BKS', '', '583', 'x', 0, 1, 'Службова примітка', '',                 5, 4, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '583', 'z', 0, 1, 'Відкрита примітка', '',                 5, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '584', '', 1, 'Примітка про акумуляцію та частоту використання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '584', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '584', '5', 0, 0, 'Приналежність поля організації', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '584', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '584', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '584', 'a', 0, 1, 'Accumulation', 'Accumulation',          5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '584', 'b', 0, 1, 'Frequency of use', 'Frequency of use',  5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '585', '', 1, 'Примітка про виставки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '585', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '585', '5', -6, 0, 'Приналежність поля організації', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '585', '6', 0, 0, 'Елемент зв’язку', '',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '585', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '585', 'a', 0, 0, 'Примітка про виставки', '',             5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '586', '', 1, 'Примітка про нагороди', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '586', '3', 0, 0, 'Область застосування даних поля', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '586', '6', 0, 0, 'Елемент зв’язку', '',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '586', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '586', 'a', 0, 0, 'Примітка про нагороди', '',           5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '590', '', 1, 'Примітка про автограф і колекцію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '590', '6', 0, 0, 'Елемент зв’язку (RLIN)', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '590', '8', 0, 1, 'Field link and sequence number (RLIN)', 'Field link and sequence number (RLIN)', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '590', 'a', 0, 0, 'Local note', 'Local note',            5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '590', 'b', 0, 0, 'Provenance (VM) [OBSOLETE]', 'Provenance (VM) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '590', 'c', 0, 0, 'Condition of individual reels (VM) [OBSOLETE]', 'Condition of individual reels (VM) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '590', 'd', 0, 0, 'Origin of safety copy (VM) (застаріло)', 'Origin of safety copy (VM) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '600', '', 1, 'Персоналії', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '600', '2', 0, 0, 'Джерело рубрики', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'PERSO_NAME', '600', 'a', 0, 0, 'Персоналії', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'b', 0, 0, 'Нумерація', '',                         6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'c', 0, 1, 'Титули', '',                            6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'd', 0, 0, 'Дати життя', '',                        6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'e', 0, 1, 'Роль осіб', '',                         6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'f', 0, 0, 'Дата публікації', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'g', 0, 0, 'Інші відомості', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'h', 0, 0, 'Фізичний носій', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'j', 0, 1, 'Приналежність невідомого автора до послідовників, школи і т. ін.', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'k', 0, 1, 'Форма, вид, жанр', '',                  6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'l', 0, 0, 'Мова твору', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'm', 0, 1, 'Засіб виконання музичного твору', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'n', 0, 1, 'Позначення і номер частини/розділу твору', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'o', 0, 0, 'Позначення аранжування', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'q', 0, 0, 'Більш повна форма імені', '',           6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'r', 0, 0, 'Тональність', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 's', 0, 0, 'Версія, видання', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 't', 0, 0, 'Назва твору', '',                       6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'u', 0, 0, 'Місце роботи, членство або адреса особи', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'v', 0, 1, 'Типове ділення', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'x', 0, 1, 'Основне ділення', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'y', 0, 1, 'Хронологічне ділення', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '600', 'z', 0, 1, 'Географічне ділення', '',               6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '610', '', 1, 'Назва колективу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '610', '2', 0, 0, 'Джерело рубрики', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'CORPO_NAME', '610', 'a', 0, 0, 'Назва колективу', '',         6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'b', 0, 1, 'Структурний підрозділ', '',             6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'c', 0, 0, 'Місце проведення заходу', '',           6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'd', 0, 1, 'Дата проведення заходу', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'e', 0, 1, 'Роль колективу', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'f', 0, 0, 'Дата публікації', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'g', 0, 0, 'Інші відомості', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'h', 0, 0, 'Фізичний носій', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'k', 0, 1, 'Форма, вид, жанр', '',                  6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'l', 0, 0, 'Мова твору', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'm', 0, 1, 'Засіб виконання музичного твору', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'n', 0, 1, 'Номер частини', '',                     6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'o', 0, 0, 'Позначення аранжування', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'p', 0, 1, 'Назва частини', '',                     6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'r', 0, 0, 'Тональність', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 's', 0, 0, 'Версія, видання', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 't', 0, 0, 'Назва твору', '',                       6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'u', 0, 0, 'Місце роботи, членство або адреса особи', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'v', 0, 1, 'Типове ділення', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'x', 0, 1, 'Основне ділення', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'y', 0, 1, 'Хронологічне ділення', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '610', 'z', 0, 1, 'Географічне ділення', '',               6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '611', '', 1, 'Назва заходу/тимчасового колективу/установи як дод. предметна пошукова ознака', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '611', '2', 0, 0, 'Джерело рубрики або терміну', '',     6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', '3', 0, 0, 'Область застосування даних поля', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', '4', 0, 1, 'Код відношення', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', '6', 0, 0, 'Елемент зв’язку', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'MEETI_NAME', '611', 'a', 0, 0, 'Назва заходу як початковий елемент вводу', '', 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'b', 0, 1, 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'c', 0, 0, 'Місце проведення заходу', '',         6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'd', 0, 0, 'Дата проведення заходу', '',          6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'e', 0, 0, 'Структурний підрозділ (підпорядк. одиниця)', '', 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'f', 0, 0, 'Дата публікації', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'g', 0, 0, 'Інша інформація', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'h', 0, 0, 'Фізичний носій (позначення матеріалу)', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'j', 0, 1, 'Термін відношенння (роль)', '',       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'k', 0, 1, 'Форма, вид, жанр і т. ін. твору', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'l', 0, 0, 'Мова твору', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'n', 0, 1, 'Позначення і номер частини/секції/заходу', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'p', 0, 1, 'Заголовок частини/розділу твору', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 's', 0, 0, 'Версія, видання і т. ін.', '',        6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 't', 0, 0, 'Назва твору', '',                     6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'u', 0, 0, 'Місцезнаходження або адреса', '',     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'v', 0, 1, 'Типове ділення', '',                  6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'x', 0, 1, 'Основне ділення', '',                 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'y', 0, 1, 'Хронологічне ділення', '',            6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '611', 'z', 0, 1, 'Географічне ділення', '',             6, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '630', '', 1, 'Уніфікований заголовок (додатковий предм. запис)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '630', '2', 0, 0, 'Джерело рубрики', '',                 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', '3', 0, 0, 'Область застосування даних поля', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '630', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '630', '6', 0, 0, 'Елемент зв’язку', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'UNIF_TITLE', '630', 'a', 0, 0, 'Уніфікований заголовок', '',  6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'd', 0, 1, 'Дата підписання договору', '',        6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '630', 'e', 0, 1, 'Термін відношенння (роль)', '',         6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'f', 0, 0, 'Дата публікації', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'g', 0, 0, 'Інші відомості', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'h', 0, 0, 'Фізичний носій', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'k', 0, 1, 'Форма, вид, жанр', '',                6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'l', 0, 0, 'Мова твору', '',                      6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'm', 0, 1, 'Засіб виконання музичного твору', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'n', 0, 1, 'Номер частини/розділу', '',           6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'o', 0, 0, 'Позначення аранжування', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'p', 0, 1, 'Назва частини/розділу', '',           6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'r', 0, 0, 'Тональность', '',                     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 's', 0, 0, 'Версія, видання', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 't', 0, 0, 'Назва твору', '',                     6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'v', 0, 1, 'Типове ділення', '',                  6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'x', 0, 1, 'Основне ділення', '',                 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'y', 0, 1, 'Хронологічне ділення', '',            6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '630', 'z', 0, 1, 'Географічне ділення', '',             6, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '648', '', 1, 'Хронологічне поняття як додаткова предметна пошукова ознака', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '648', '2', 0, 0, 'Джерело рубрики чи терміну', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '648', '3', 0, 0, 'Область застосування даних поля', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '648', '6', 0, 0, 'Зв’язок', '',                         6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '648', '8', 0, 1, 'Зв’язок поля і його порядковий номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'CHRON_TERM', '648', 'a', 0, 0, 'Хронологічне поняття', '',    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '648', 'v', 0, 1, 'Типове ділення', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '648', 'x', 0, 1, 'Основне ділення', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '648', 'y', 0, 1, 'Хронологічне ділення', '',            6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '648', 'z', 0, 1, 'Географічне ділення', '',             6, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '650', '', 1, 'Тематичні рубрики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '650', '2', 0, 0, 'Джерело рубрики', '',                   6, 0, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '650', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', 'TOPIC_TERM', '650', 'a', 0, 0, 'Основна рубрика', '',         6, 0, 'bibliosubject.subject', '', '', 0, '\'6003\',\'600a\',\'600b\',\'600c\',\'600d\',\'600e\',\'600f\',\'600g\',\'600h\',\'600k\',\'600l\',\'600m\',\'600n\',\'600o\',\'600p\',\'600r\',\'600s\',\'600t\',\'600u\',\'600x\',\'600z\',\'600y\',\'600v\',\'6103\',\'610a\',\'610b\',\'610c\',\'610d\',\'610e\',\'610f\',\'610g\',\'610h\',\'610k\',\'610l\',\'610m\',\'610n\',\'610o\',\'610p\',\'610r\',\'610s\',\'610t\',\'610u\',\'610x\',\'610z\',\'610y\',\'610v\',\'6113\',\'611a\',\'611b\',\'611c\',\'611d\',\'611e\',\'611f\',\'611g\',\'611h\',\'611k\',\'611l\',\'611m\',\'611n\',\'611o\',\'611p\',\'611r\',\'611s\',\'611t\',\'611u\',\'611x\',\'611z\',\'611y\',\'611v\',\'630a\',\'630b\',\'630c\',\'630d\',\'630e\',\'630f\',\'630g\',\'630h\',\'630k\',\'630l\',\'630m\',\'630n\',\'630o\',\'630p\',\'630r\',\'630s\',\'630t\',\'630x\',\'630z\',\'630y\',\'630v\',\'6483\',\'648a\',\'648x\',\'648z\',\'648y\',\'648v\',\'6503\',\'650b\',\'650c\',\'650d\',\'650e\',\'650x\',\'650z\',\'650y\',\'650v\',\'6513\',\'651a\',\'651b\',\'651c\',\'651d\',\'651e\',\'651x\',\'651z\',\'651y\',\'651v\',\'653a\',\'6543\',\'654a\',\'654b\',\'654x\',\'654z\',\'654y\',\'654v\',\'6553\',\'655a\',\'655b\',\'655x\',\'655z\',\'655y\',\'655v\',\'6563\',\'656a\',\'656k\',\'656x\',\'656z\',\'656y\',\'656v\',\'6573\',\'657a\',\'657x\',\'657z\',\'657y\',\'657v\',\'658a\',\'658b\',\'658c\',\'658d\',\'658v\'', '', NULL),
 ('BKS', '', '650', 'b', 0, 0, 'Ін. геогр. рубрика', '',                6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', 'c', 0, 0, 'Місце події', '',                       6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', 'd', 0, 0, 'Дати події', '',                        6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', 'e', 0, 0, 'Термін відношення (роль)', '',          6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', 'v', 0, 1, 'Типове ділення', '',                    6, 0, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', 'x', 0, 1, 'Основна підрубрика', '',                6, 0, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', 'y', 0, 1, 'Хронологічна підрубрика', '',           6, 0, '', '', '', 0, '', '', NULL),
 ('BKS', '', '650', 'z', 0, 1, 'Географічна підрубрика', '',            6, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '651', '', 1, 'Географічна назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '651', '2', 0, 0, 'Код системи', '',                       6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'GEOGR_NAME', '651', 'a', 0, 0, 'Географічна назва', '',       6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', 'b', 0, 1, 'Geographic name following place entry element (застаріло)', 'Geographic name following place entry element [OBSOLETE]', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', 'e', 0, 1, 'Роль, відношення', '',                  6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', 'v', 0, 1, 'Типове ділення', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', 'x', 0, 1, 'Основні підзаголовки', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', 'y', 0, 1, 'Хронологогічний підзаголовок', '',      6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '651', 'z', 0, 1, 'Географічний підзаголовок', '',         6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '652', '', 1, 'Додаткова предметна пошукова ознака — анульована географічна (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '652', 'a', 0, 0, 'Geographic name of place element', 'Geographic name of place element', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '652', 'x', 0, 1, 'Основне ділення', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '652', 'y', 0, 1, 'Хронологічне ділення', '',              6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '652', 'z', 0, 1, 'Географічне діленння', '',              6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '653', '', 1, 'Ключові слова', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '653', '6', 0, 0, 'Елемент зв’язку', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '653', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '653', 'a', 0, 1, 'Ключові слова', '',                   6, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '654', '', 1, 'Додаткове предметне введення — фасетні тематичні терміни', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '654', '2', 0, 0, 'Джерело терміну', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'TOPIC_TERM', '654', 'a', 0, 1, 'Focus term', 'Focus term',    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', 'b', 0, 1, 'Non-focus term', 'Non-focus term',      6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', 'c', 0, 1, 'Facet/hierarchy designation', 'Facet/hierarchy designation', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', 'e', 0, 1, 'Термін відношенння (роль)', '',         6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', 'v', 0, 1, 'Типове ділення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', 'x', 0, 1, 'Основне ділення', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', 'y', 0, 1, 'Хронологічне ділення', '',              6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '654', 'z', 0, 1, 'Географічне діленння', '',              6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '655', '', 1, 'Покажчик предметних рубрик', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '655', '2', 0, 0, 'Джерело терміну', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', '5', 0, 0, 'Приналежність поля організації', '',    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'GENRE/FORM', '655', 'a', 0, 0, 'Жанр/форма', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', 'b', 0, 1, 'Non-focus term', 'Non-focus term',      6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', 'c', 0, 1, 'Facet/hierarchy designation', 'Facet/hierarchy designation', 6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', 'v', 0, 1, 'Типове ділення', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', 'x', 0, 1, 'Основне ділення', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', 'y', 0, 1, 'Хронологічне ділення', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '655', 'z', 0, 1, 'Географічне діленння', '',              6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '656', '', 1, 'Термін індексування — професія', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '656', '2', 0, 0, 'Джерело терміну', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '656', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '656', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '656', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'TOPIC_TERM', '656', 'a', 0, 0, 'Occupation', 'Occupation',    6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '656', 'k', 0, 0, 'Форма, вид, жанр', '',                  6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '656', 'v', 0, 1, 'Типове ділення', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '656', 'x', 0, 1, 'Основне ділення', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '656', 'y', 0, 1, 'Хронологічне ділення', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '656', 'z', 0, 1, 'Географічне діленння', '',              6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '657', '', 1, 'Термін індексування — функція', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '657', '2', 0, 0, 'Джерело терміну', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '657', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '657', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '657', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'TOPIC_TERM', '657', 'a', 0, 0, 'Function', 'Function',        6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '657', 'v', 0, 1, 'Типове ділення', '',                    6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '657', 'x', 0, 1, 'Основне ділення', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '657', 'y', 0, 1, 'Хронологічне ділення', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '657', 'z', 0, 1, 'Географічне діленння', '',              6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '658', '', 1, 'Термін індексування — завдання навчального курсу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '658', '2', 0, 0, 'Джерело терміну', '',                   6, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '658', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '658', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'TOPIC_TERM', '658', 'a', 0, 0, 'Main curriculum objective', 'Main curriculum objective', 6, 0, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '658', 'b', 0, 1, 'Subordinate curriculum objective', 'Subordinate curriculum objective', 6, 0, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '658', 'c', 0, 0, 'Curriculum code', 'Curriculum code',    6, 0, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '658', 'd', 0, 0, 'Correlation factor', 'Correlation factor', 6, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '662', '', 1, 'Додаткове предметне введення — ієрархічна назва місця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '662', '2', 0, 0, 'Джерело терміну', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'GEOGR_NAME', '662', 'a', 0, 1, 'Country or larger entity', 'Country or larger entity', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', 'b', 0, 0, 'First-order political jurisdiction', 'First-order political jurisdiction', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', 'c', 0, 1, 'Intermediate political jurisdiction', 'Intermediate political jurisdiction', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', 'd', 0, 0, 'City', 'City',                          6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', 'e', 0, 1, 'Термін відношенння (роль)', '',         6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', 'f', 0, 1, 'City subsection', 'City subsection',    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', 'g', 0, 1, 'Other nonjurisdictional geographic region and feature', 'Other nonjurisdictional geographic region and feature', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '662', 'h', 0, 1, 'Extraterrestrial area', 'Extraterrestrial area', 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '690', '', 1, 'Локальна додаткова предметна пошукова ознака — тематичне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '690', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', '2', 0, 0, 'Джерело рубрики або терміну', '',       6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', 'TOPIC_TERM', '690', 'a', 0, 0, 'Topical term or geographic name as entry element', 'Topical term or geographic name as entry element', 6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', 'b', 0, 0, 'Topical term following geographic name as entry element', 'Topical term following geographic name as entry element', 6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', 'c', 0, 0, 'Location of event', 'Location of event', 6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', 'd', 0, 0, 'Active dates', 'Active dates',          6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', 'e', 0, 0, 'Термін відношенння (роль)', '',         6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', 'v', 0, 1, 'Типове ділення', '',                    6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', 'x', 0, 1, 'Основне ділення', '',                   6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', 'y', 0, 1, 'Хронологічне ділення', '',              6, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '690', 'z', 0, 1, 'Географічне діленння', '',              6, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '691', '', 1, 'Локальна додаткова предметна пошукова ознака — географічне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '691', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '691', '2', 0, 0, 'Джерело рубрики або терміну', '',       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '691', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '691', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '691', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'GEOGR_NAME', '691', 'a', 0, 0, 'Geographic name', 'Geographic name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '691', 'b', 0, 1, 'Geographic name following place entry element (застаріло)', 'Geographic name following place entry element [OBSOLETE]', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '691', 'v', 0, 1, 'Типове ділення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '691', 'x', 0, 1, 'Основне ділення', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '691', 'y', 0, 1, 'Хронологічне ділення', '',              6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '691', 'z', 0, 1, 'Географічне діленння', '',              6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '696', '', 1, 'Локальна додаткова предметна пошукова ознака — власне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '696', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '696', '2', 0, 0, 'Джерело рубрики або терміну', '',       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'PERSO_NAME', '696', 'a', 0, 0, 'Personal name', 'Personal name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'b', 0, 0, 'Numeration', 'Numeration',              6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'e', 0, 1, 'Термін відношенння (роль)', '',         6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'f', 0, 0, 'Дата публікації', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'g', 0, 0, 'Інші відомості', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'h', 0, 0, 'Фізичний носій', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'k', 0, 1, 'Підзаголовок форми', '',                6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'l', 0, 0, 'Мова роботи', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'm', 0, 1, 'Засіб виконання музичного твору', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'o', 0, 0, 'Позначення аранжування', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'r', 0, 0, 'Тональність', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 's', 0, 0, 'Версія, видання і т. д.', '',           6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 't', 0, 0, 'Назва роботи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'u', 0, 0, 'Додаткові відомості', '',               6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'v', 0, 1, 'Типове ділення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'x', 0, 1, 'Основне ділення', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'y', 0, 1, 'Хронологічне ділення', '',              6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '696', 'z', 0, 1, 'Географічне діленння', '',              6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '697', '', 1, 'Локальна додаткова предметна пошукова ознака — ім’я організації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '697', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '697', '2', 0, 0, 'Джерело рубрики або терміну', '',       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', '3', 0, 0, 'Область застосування даних поля', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', '4', 0, 1, 'Код відношення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', '6', 0, 0, 'Елемент зв’язку', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'CORPO_NAME', '697', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',  6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'e', 0, 1, 'Термін відношенння (роль)', '',         6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'f', 0, 0, 'Дата публікації', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'g', 0, 0, 'Інші відомості', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'h', 0, 0, 'Фізичний носій', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'k', 0, 1, 'Підзаголовок форми', '',                6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'l', 0, 0, 'Мова роботи', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'm', 0, 1, 'Засіб виконання музичного твору', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'o', 0, 0, 'Позначення аранжування', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'r', 0, 0, 'Тональність', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 's', 0, 0, 'Версія, видання і т. д.', '',           6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 't', 0, 0, 'Назва роботи', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'u', 0, 0, 'Додаткові відомості', '',               6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'v', 0, 1, 'Типове ділення', '',                    6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'x', 0, 1, 'Основне ділення', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'y', 0, 1, 'Хронологічне ділення', '',              6, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '697', 'z', 0, 1, 'Географічне діленння', '',              6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '698', '', 1, 'Локальна додаткова предметна пошукова ознака — назва заходу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '698', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', NULL, '698', '2', 0, 0, 'Джерело рубрики або терміну', '',     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', '3', 0, 0, 'Область застосування даних поля', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', '4', 0, 1, 'Код відношення', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', '6', 0, 0, 'Елемент зв’язку', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'MEETI_NAME', '698', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'b', 0, 1, 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'd', 0, 0, 'Date of meeting', 'Date of meeting',  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'f', 0, 0, 'Дата публікації', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'g', 0, 0, 'Інші відомості', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'h', 0, 0, 'Фізичний носій', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'k', 0, 1, 'Підзаголовок форми', '',              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'l', 0, 0, 'Мова роботи', '',                     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'p', 0, 1, 'Заголовок частини/розділу твору', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 's', 0, 0, 'Версія, видання і т. д.', '',         6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 't', 0, 0, 'Назва роботи', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'u', 0, 0, 'Додаткові відомості', '',             6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'v', 0, 1, 'Типове ділення', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'x', 0, 1, 'Основне ділення', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'y', 0, 1, 'Хронологічне ділення', '',            6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '698', 'z', 0, 1, 'Географічне діленння', '',            6, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '699', '', 1, 'Локальна додаткова предметна пошукова ознака — уніфікований заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '699', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  6, -6, '', '', '', 0, '', '', NULL),
 ('BKS', NULL, '699', '2', 0, 0, 'Джерело рубрики або терміну', '',     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', '3', 0, 0, 'Область застосування даних поля', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', '6', 0, 0, 'Елемент зв’язку', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'UNIF_TITLE', '699', 'a', 0, 0, 'Уніфікована назва', '',       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'd', 0, 1, 'Дата підписання договору', '',        6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'f', 0, 0, 'Дата публікації', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'g', 0, 0, 'Інші відомості', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'h', 0, 0, 'Фізичний носій', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'k', 0, 1, 'Підзаголовок форми', '',              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'l', 0, 0, 'Мова роботи', '',                     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'm', 0, 1, 'Засіб виконання музичного твору', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'o', 0, 0, 'Позначення аранжування', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'p', 0, 1, 'Заголовок частини/розділу твору', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'r', 0, 0, 'Тональність', '',                     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 's', 0, 0, 'Версія, видання і т. д.', '',         6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 't', 0, 0, 'Назва роботи', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'v', 0, 1, 'Типове ділення', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'x', 0, 1, 'Основне ділення', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '699', 'y', 0, 1, 'Хронологічне ділення', '',            6, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '700', '', 1, 'Інші автори', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '700', '3', 0, 0, 'Область застосування даних поля', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', '4', 0, 1, 'Код відношення', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', '5', 0, 0, 'Приналежність поля організації', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'PERSO_NAME', '700', 'a', 0, 0, 'Інші автори', '',             7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'b', 0, 0, 'Династичний номер', '',                 7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'c', 0, 1, 'Титул (звання)', '',                    7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'd', 0, 0, 'Дата', '',                              7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'e', 0, 1, 'Роль осіб', '',                         7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'f', 0, 0, 'Дата публікації', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'g', 0, 0, 'Інші відомості', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'h', 0, 0, 'Фізичний носій', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'k', 0, 1, 'Підзаголовок форми', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'l', 0, 0, 'Мова роботи', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'm', 0, 1, 'Засіб виконання музичного твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'o', 0, 0, 'Позначення аранжування', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'q', 0, 0, 'Повне ім’я', '',                        7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'r', 0, 0, 'Тональність', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 's', 0, 0, 'Версія, видання і т. д.', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 't', 0, 0, 'Назва твору', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'u', 0, 0, 'Доповнення', '',                        7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '700', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '705', '', 1, 'Додаткова пошукова ознака — індивідуальне ім’я (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '705', 'a', 0, 0, 'Personal name', 'Personal name',        7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'b', 0, 0, 'Numeration', 'Numeration',              7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'e', 0, 1, 'Термін відношенння (роль)', '',         7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'f', 0, 0, 'Дата публікації', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'g', 0, 0, 'Інші відомості', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'h', 0, 0, 'Фізичний носій', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'k', 0, 1, 'Підзаголовок форми', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'l', 0, 0, 'Мова роботи', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'm', 0, 1, 'Засіб виконання музичного твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'o', 0, 0, 'Позначення аранжування', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 'r', 0, 0, 'Тональність', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 's', 0, 0, 'Версія, видання і т. д.', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '705', 't', 0, 0, 'Назва роботи', '',                      7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '710', '', 1, 'Інші організації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '710', '3', 0, 0, 'Область застосування даних поля', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', '4', 0, 1, 'Код відношення', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', '5', 0, 0, 'Приналежність поля організації', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', '6', 0, 0, 'Елемент зв’язку', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'CORPO_NAME', '710', 'a', 0, 0, 'Організ./юрисдикція', '',     7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'b', 0, 1, 'Інші рівні', '',                        7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'c', 0, 0, 'Місце', '',                             7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'd', 0, 1, 'Дата', '',                              7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'e', 0, 1, 'Роль колективу', '',                    7, -1, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'f', 0, 0, 'Дата публікації', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'g', 0, 0, 'Інша інформація', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'h', 0, 0, 'Фізичний носій', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'k', 0, 1, 'Підзаголовок форми', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'l', 0, 0, 'Мова роботи', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'm', 0, 1, 'Засіб виконання музичного твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'n', 0, 1, 'Номер', '',                             7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'o', 0, 0, 'Позначення аранжування', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'r', 0, 0, 'Тональність', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 's', 0, 0, 'Версія, видання і т. д.', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 't', 0, 0, 'Назва твору', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'u', 0, 0, 'Додаткові відомості', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '710', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '711', '', 1, 'Інші заходи', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '711', '3', 0, 0, 'Область застосування даних поля', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', '4', 0, 1, 'Код відношення', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', '5', 0, 0, 'Приналежність поля організації', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'MEETI_NAME', '711', 'a', 0, 0, 'Назва заходу', '',            7, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'c', 0, 0, 'Місце заходу', '',                    7, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'd', 0, 0, 'Дата заходу', '',                     7, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'e', 0, 1, 'Підпорядк. одиниця', '',              7, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'f', 0, 0, 'Дата роботи', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'g', 0, 0, 'Інші відомості', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'h', 0, 0, 'Фізичний носій', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'j', 0, 1, 'Термін відношенння (роль)', '',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'k', 0, 1, 'Підзаголовок форми', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'l', 0, 0, 'Мова роботи', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'n', 0, 1, '№ частини/секції', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'p', 0, 1, '№ частини/розділу', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 's', 0, 0, 'Версія, видання і т. д.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 't', 0, 0, 'Назва роботи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'u', 0, 0, 'Додаткові відомості', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '711', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '715', '', 1, 'Додаткова пошукова ознака — ім’я організації (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '715', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  7, -6, '', '', '', 0, '', '', NULL),
 ('BKS', NULL, '715', 'a', 0, 0, 'Corporate name or jurisdiction name', 'Corporate name or jurisdiction name', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'b', 0, 0, 'Subordinate unit', 'Subordinate unit', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'e', 0, 1, 'Термін відношенння (роль)', '',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'f', 0, 0, 'Дата публікації', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'g', 0, 0, 'Інші відомості', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'h', 0, 0, 'Фізичний носій', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'k', 0, 1, 'Підзаголовок форми', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'l', 0, 0, 'Мова роботи', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'p', 0, 1, 'Заголовок частини/розділу твору', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'r', 0, 0, 'Тональність', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 's', 0, 0, 'Версія, видання і т. д.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 't', 0, 0, 'Назва роботи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '715', 'u', 0, 0, 'Nonprinting information', 'Nonprinting information', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '720', '', 1, 'Додаткове введення — неконтрольоване ім’я/найменування', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '720', '4', 0, 1, 'Код відношення', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '720', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '720', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '720', 'a', 0, 0, 'Name', 'Name',                        7, -1, '', NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '720', 'e', 0, 1, 'Термін відношенння (роль)', '',       7, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '730', '', 1, 'Уніфікована назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '730', '3', 0, 0, 'Область застосування даних поля', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', '5', 0, 0, 'Приналежність поля організації', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', '6', 0, 0, 'Елемент зв’язку', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'UNIF_TITLE', '730', 'a', 0, 0, 'Уніфікована назва', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'd', 0, 1, 'Дата підписання договору', '',          7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'f', 0, 0, 'Дата публікації', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'g', 0, 0, 'Інші відомості', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'h', 0, 0, 'Фізичний носій', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'k', 0, 1, 'Форма, вид, жанр', '',                  7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'l', 0, 0, 'Мова програмування', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'm', 0, 1, 'Засіб виконання музичного твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'n', 0, 1, 'Номер частини твору', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'o', 0, 0, 'Позначення аранжування', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'p', 0, 1, 'Назва частини/розділу', '',             7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'r', 0, 0, 'Тональність', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 's', 0, 0, 'Версія, видання', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 't', 0, 0, 'Назва роботи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '730', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '740', '', 1, 'Зв’язана/аналіт. назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '740', '5', 0, 0, 'Приналежність поля організації', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '740', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '740', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '740', 'a', 0, 0, 'Зв’язана/аналіт. назва', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '740', 'h', 0, 0, 'Фізичний носій', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '740', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '740', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '752', '', 1, 'Додаткове введення — ієрархічна назва місця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '752', '2', 0, 0, 'Джерело рубрики або терміну', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', 'a', 0, 0, 'Country or larger entity', 'Country or larger entity', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', 'b', 0, 0, 'First-order political jurisdiction', 'First-order political jurisdiction', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', 'c', 0, 1, 'Intermediate political jurisdiction', 'Intermediate political jurisdiction', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', 'd', 0, 0, 'City', 'City',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', 'f', 0, 1, 'City subsection', 'City subsection',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', 'g', 0, 1, 'Other nonjurisdictional geographic region and feature', 'Other nonjurisdictional geographic region and feature', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '752', 'h', 0, 1, 'Extraterrestrial area', 'Extraterrestrial area', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '753', '', 1, 'Системні характеристики доступу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '753', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '753', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '753', 'a', 0, 0, 'Марка і модель машини', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '753', 'b', 0, 0, 'Мова програмування', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '753', 'c', 0, 0, 'Операційна система', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '754', '', 1, 'Додаткове введення — таксономічна ідентифікація', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '754', '2', 0, 0, 'Source of taxonomic identification', 'Source of taxonomic identification', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '754', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '754', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '754', 'a', 0, 1, 'Taxonomic name', 'Taxonomic name',    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '754', 'c', 0, 1, 'Taxonomic category', 'Taxonomic category', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '754', 'd', 0, 1, 'Common or alternative name', 'Common or alternative name', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '754', 'x', 0, 1, 'Non-public note', 'Non-public note',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '754', 'z', 0, 1, 'Примітка для ЕК', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '755', '', 1, 'Додаткова пошукова ознака — фізичні характеристики (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '755', '2', 0, 0, 'Source of taxonomic identification', 'Source of taxonomic identification', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '755', '3', 0, 0, 'Область застосування даних поля', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '755', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '755', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '755', 'a', 0, 0, 'Access term', 'Access term',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '755', 'x', 0, 1, 'Основне ділення', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '755', 'y', 0, 1, 'Хронологічне ділення', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '755', 'z', 0, 1, 'Географічне діленння', '',              7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '760', '', 1, 'Пошукова ознака на основну серію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '760', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'b', 0, 0, 'Edition', 'Edition',                  7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'i', 0, 0, 'Display text', 'Display text',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'n', 0, 1, 'Note', 'Note',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 's', 0, 0, 'Уніфікована назва', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 't', 0, 0, 'Title', 'Title',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '760', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '762', '', 1, 'Пошукова ознака на підсерію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '762', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'b', 0, 0, 'Edition', 'Edition',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'i', 0, 0, 'Display text', 'Display text',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'n', 0, 1, 'Note', 'Note',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 's', 0, 0, 'Уніфікована назва', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 't', 0, 0, 'Title', 'Title',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '762', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '765', '', 1, 'Пошукова ознака на мову оригіналу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '765', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'b', 0, 0, 'Edition', 'Edition',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'i', 0, 0, 'Display text', 'Display text',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'n', 0, 1, 'Note', 'Note',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'q', 0, 0, 'Parallel title (BK SE)  [OBSOLETE]', 'Parallel title (BK SE)  [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 's', 0, 0, 'Уніфікована назва', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 't', 0, 0, 'Title', 'Title',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '765', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '767', '', 1, 'Пошукова ознака на переклад', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '767', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'b', 0, 0, 'Edition', 'Edition',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'i', 0, 0, 'Display text', 'Display text',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'n', 0, 1, 'Note', 'Note',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 's', 0, 0, 'Уніфікована назва', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 't', 0, 0, 'Title', 'Title',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '767', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '770', '', 1, 'Пошукова ознака на додаток / спеціальний випуск', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '770', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', '7', 0, 0, 'Control subfield', 'Control subfield', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'b', 0, 0, 'Edition', 'Edition',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'i', 0, 0, 'Display text', 'Display text',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'n', 0, 1, 'Note', 'Note',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 's', 0, 0, 'Уніфікована назва', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 't', 0, 0, 'Title', 'Title',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '770', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '772', '', 1, 'Пошукова ознака на осн. одиницю, до якої відн. додаток', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '772', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'a', 0, 0, 'Заголовок / основна пошукова ознака на основну одиницю (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'c', 0, 0, 'Уточнююча інформація', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'd', 0, 0, 'Місце, видавництво і дата видання', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'g', 0, 1, 'Відомості про зв’язок', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'i', 0, 0, 'Пояснювальний текст', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'm', 0, 0, 'Специфічні дані', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '772', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '773', '', 1, 'Джерело інформації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '773', '3', 0, 0, 'Область застосування даних поля', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'a', 0, 0, 'Заголовок основного запису', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'd', 0, 0, 'Місце і дата видання', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'g', 0, 1, 'Інша інформація', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'h', 0, 0, 'Фізич .характ. зв’яз.один.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'i', 0, 0, 'Display text', 'Display text',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'k', 0, 1, 'Обл. серії із зв’яз.один.', '',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'm', 0, 0, 'Специфічні дані', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'o', 0, 1, 'Інші індекси', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'p', 0, 0, 'Abbreviated title', 'Abbreviated title', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 's', 0, 0, 'Уніфікована назва', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 't', 0, 0, 'Назва джерела', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'w', 0, 1, 'Контр. № джерела', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '773', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '774', '', 1, 'Пошукова ознака на складову частину', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '774', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'a', 0, 0, 'Заголовок основного бібліографічного запису на складову частину', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'c', 0, 0, 'Уточн. інформ.', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'd', 0, 0, 'Місце, видавець і дата вид.', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'i', 0, 0, 'Display text', 'Display text',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'r', 0, 1, 'Номер звіту', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'u', 0, 0, 'Станд. номер тех. звіту', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'w', 0, 1, 'Контр. номер запису', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '774', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '775', '', 1, 'Бібл. опис на інше вид.', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '775', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', '7', 0, 1, 'Контрольне підполе', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'a', 0, 0, 'Загол. осн. бібл. запису', '',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'c', 0, 0, 'Уточн. інформ.', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'd', 0, 0, 'Місце, вид-во і дата вид.', '',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'e', 0, 0, 'Language code', 'Language code',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'f', 0, 0, 'Country code', 'Country code',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'i', 0, 0, 'Display text', 'Display text',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'r', 0, 1, 'Номер звіту', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'u', 0, 0, 'Станд.номер тех.звіту', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'w', 0, 1, 'Контрольний номер запису', '',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '775', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '776', '', 1, 'Пошукова ознака на одиницю в іншій фізичній формі', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '776', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'a', 0, 0, 'Заголовок / основна пошукова ознака на одиницю в іншій фізичній формі', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'c', 0, 0, 'Уточнююча інформація', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'd', 0, 0, 'Місце, видавець і дата видання', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'g', 0, 1, 'Відомості про зв’язок', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'i', 0, 0, 'Пояснювальний текст', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'm', 0, 0, 'Специфічні дані', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '776', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '777', '', 1, 'Пошукова ознака на одиницю, видану в одній обкладинці з опис.матеріалом', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '777', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'a', 0, 0, 'Заголовок / основна пошукова ознака зв’язаного запису (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'c', 0, 0, 'Уточнююча інформація', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'd', 0, 0, 'Місце, видавець і дата видання', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'g', 0, 1, 'Відомості про зв’язок', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'i', 0, 0, 'Пояснювальний текст', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'm', 0, 0, 'Специфічні дані', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '777', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '780', '', 1, 'Пошукова ознака на попереднє видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '780', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'a', 0, 0, 'Заголовок / основна пошукова ознака зв’язаного запису (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'c', 0, 0, 'Уточнююча інформація', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'd', 0, 0, 'Місце, видавець і дата видання', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'g', 0, 1, 'Відомості про зв’язок', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'i', 0, 0, 'Пояснювальний текст', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'm', 0, 0, 'Специфічні дані', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '780', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '785', '', 1, 'Пошукова ознака на наступне видання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '785', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'a', 0, 0, 'Заголовок / основна пошукова ознака зв’язаного запису (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'c', 0, 0, 'Уточнююча інформація', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'd', 0, 0, 'Місце, видавець і дата видання', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'g', 0, 1, 'Відомості про зв’язок', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'i', 0, 0, 'Пояснювальний текст', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'm', 0, 0, 'Специфічні дані', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '785', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '786', '', 1, 'Пошукова ознака на джерело даних', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '786', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'a', 0, 0, 'Заголовок / основна пошукова ознака на джерело даних (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'c', 0, 0, 'Уточнююча інформація', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'd', 0, 0, 'Місце, видавець і дата видання', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'g', 0, 1, 'Відомості про зв’язок', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'i', 0, 0, 'Пояснювальний текст', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'j', 0, 0, 'Period of content', 'Period of content', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'm', 0, 0, 'Специфічні дані', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'p', 0, 0, 'Скорочена назва', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '786', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '787', '', 1, 'Пошукова ознака на одиницю, пов’язану з одиницею опису ін. відносинами', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '787', '6', 0, 0, 'Зв’язок', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', '7', 0, 0, 'Контрольне поле', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'a', 0, 0, 'Загол./Осн. пошукова ознака зв’язаного запису (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'b', 0, 0, 'Відомості про видання', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'c', 0, 0, 'Уточнююча інформація', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'd', 0, 0, 'Місце, видавець і дата видання', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'g', 0, 1, 'Відомості про зв’язок', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'h', 0, 0, 'Фізичний опис', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'i', 0, 0, 'Пояснювальний текст', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'm', 0, 0, 'Специфічні дані', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'n', 0, 1, 'Примітка', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'r', 0, 1, 'Report number', 'Report number',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 's', 0, 0, 'Умовна або узагальнююча назва', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 't', 0, 0, 'Назва', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'x', 0, 0, 'ISSN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '787', 'z', 0, 1, 'ISBN', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '789', '', 1, 'Пошукова ознака на складову частину об’єкта', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '789', '%', 0, 0, '%', '%',                                7, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '789', '2', 0, 1, 2, 2,                                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', '3', 0, 1, 3, 3,                                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', '4', 0, 1, 4, 4,                                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', '5', 0, 1, 5, 5,                                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', '6', 0, 0, 6, 6,                                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', '7', 0, 1, 7, 7,                                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', '8', 0, 1, 8, 8,                                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'a', 0, 1, 'a', 'a',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'b', 0, 1, 'b', 'b',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'c', 0, 1, 'c', 'c',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'd', 0, 1, 'd', 'd',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'e', 0, 1, 'e', 'e',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'f', 0, 1, 'f', 'f',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'g', 0, 1, 'g', 'g',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'h', 0, 1, 'h', 'h',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'i', 0, 1, 'i', 'i',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'j', 0, 1, 'j', 'j',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'k', 0, 1, 'k', 'k',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'l', 0, 1, 'l', 'l',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'm', 0, 1, 'm', 'm',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'n', 0, 1, 'n', 'n',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'o', 0, 1, 'o', 'o',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'p', 0, 1, 'p', 'p',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'q', 0, 1, 'q', 'q',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'r', 0, 1, 'r', 'r',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 's', 0, 1, 's', 's',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 't', 0, 1, 't', 't',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'u', 0, 1, 'u', 'u',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'v', 0, 1, 'v', 'v',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'w', 0, 1, 'w', 'w',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'x', 0, 1, 'x', 'x',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'y', 0, 1, 'y', 'y',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '789', 'z', 0, 1, 'z', 'z',                                7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '796', '', 1, 'Локальна додаткова пошукова ознака — індивідуальне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '796', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  7, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '796', '3', 0, 0, 'Область застосування даних поля', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', '4', 0, 1, 'Код відношення', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', '5', 0, 0, 'Приналежність поля організації', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', '6', 0, 0, 'Елемент зв’язку', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'PERSO_NAME', '796', 'a', 0, 0, 'Personal name', 'Personal name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'b', 0, 0, 'Numeration', 'Numeration',              7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'e', 0, 1, 'Термін відношенння (роль)', '',         7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'f', 0, 0, 'Дата публікації', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'g', 0, 0, 'Інші відомості', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'h', 0, 0, 'Фізичний носій', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'k', 0, 1, 'Підзаголовок форми', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'l', 0, 0, 'Мова роботи', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'm', 0, 1, 'Засіб виконання музичного твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'o', 0, 0, 'Позначення аранжування', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'r', 0, 0, 'Тональність', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 's', 0, 0, 'Версія, видання і т. д.', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 't', 0, 0, 'Назва роботи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'u', 0, 0, 'Додаткові відомості', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '796', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '797', '', 1, 'Локальна додаткова пошукова ознака — ім’я організації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '797', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  7, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '797', '3', 0, 0, 'Область застосування даних поля', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', '4', 0, 1, 'Код відношення', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', '5', 0, 0, 'Приналежність поля організації', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', '6', 0, 0, 'Елемент зв’язку', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'CORPO_NAME', '797', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',  7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'e', 0, 1, 'Термін відношенння (роль)', '',         7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'f', 0, 0, 'Дата публікації', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'g', 0, 0, 'Інші відомості', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'h', 0, 0, 'Фізичний носій', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'k', 0, 1, 'Підзаголовок форми', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'l', 0, 0, 'Мова роботи', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'm', 0, 1, 'Засіб виконання музичного твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'o', 0, 0, 'Позначення аранжування', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'r', 0, 0, 'Тональність', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 's', 0, 0, 'Версія, видання і т. д.', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 't', 0, 0, 'Назва роботи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'u', 0, 0, 'Додаткові відомості', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '797', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '798', '', 1, 'Локальна додаткова пошукова ознака — назва заходу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '798', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  7, -5, '', '', '', 0, '', '', NULL),
 ('BKS', NULL, '798', '3', 0, 0, 'Область застосування даних поля', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', '4', 0, 1, 'Код відношення', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', '5', 0, 0, 'Приналежність поля організації', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', '6', 0, 0, 'Елемент зв’язку', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'MEETI_NAME', '798', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'd', 0, 0, 'Date of meeting', 'Date of meeting',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'f', 0, 0, 'Дата публікації', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'g', 0, 0, 'Інші відомості', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'h', 0, 0, 'Фізичний носій', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'k', 0, 1, 'Підзаголовок форми', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'l', 0, 0, 'Мова роботи', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'p', 0, 1, 'Заголовок частини/розділу твору', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 's', 0, 0, 'Версія, видання і т. д.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 't', 0, 0, 'Назва роботи', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'u', 0, 0, 'Додаткові відомості', '',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '798', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '799', '', 1, 'Локальна додаткова пошукова ознака — уніфікований заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '799', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  7, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '799', '3', 0, 0, 'Область застосування даних поля', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', '5', 0, 0, 'Приналежність поля організації', '',    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', '6', 0, 0, 'Елемент зв’язку', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'UNIF_TITLE', '799', 'a', 0, 0, 'Уніфікована назва', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'd', 0, 1, 'Дата підписання договору', '',          7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'f', 0, 0, 'Дата публікації', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'g', 0, 0, 'Інші відомості', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'h', 0, 0, 'Фізичний носій', '',                    7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'k', 0, 1, 'Підзаголовок форми', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'l', 0, 0, 'Мова роботи', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'm', 0, 1, 'Засіб виконання музичного твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'o', 0, 0, 'Позначення аранжування', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'r', 0, 0, 'Тональність', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 's', 0, 0, 'Версія, видання і т. д.', '',           7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 't', 0, 0, 'Назва роботи', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '799', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '800', '', 1, 'Заголовок додаткового бібл.запису на серію — ім’я особи', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '800', '4', 0, 1, 'Код відношення', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'PERSO_NAME', '800', 'a', 0, 0, 'Ім’я особи', '',              8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'b', 0, 0, 'Нумерація', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'c', 0, 1, 'Ідентифікуючі ознаки, що асоціюються з іменем особи', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'd', 0, 0, 'Дати, що стосуються імені', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'e', 0, 1, 'Термін відношення', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'f', 0, 0, 'Дата публікації', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'h', 0, 0, 'Фізичний носій', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'j', 0, 1, 'Кваліфікатор атрибуції', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'm', 0, 1, 'Засіб для виконання муз. твору', '',    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'n', 0, 1, 'Номер частини/розділу роботи', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'o', 0, 0, 'Відомості про аранжування музичного твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'p', 0, 1, 'Назва частини/розділу роботи', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'q', 0, 0, 'Більш докладна форма імені', '',        8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'r', 0, 0, 'Музичний ключ', '',                     8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 's', 0, 0, 'Версія', '',                            8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'u', 0, 0, 'Додаткові відомості', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '800', 'v', 0, 0, 'Номер тому/послідовне позначення', '',  8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '800', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '810', '', 1, 'Заголовок додаткового бібл.запису на серію — назва організації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '810', '4', 0, 1, 'Код відношення', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'CORPO_NAME', '810', 'a', 0, 0, 'Назва організації', '',       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'b', 0, 1, 'Структурний підрозділ', '',             8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'c', 0, 0, 'Місце проведення', '',                  8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'd', 0, 1, 'Дата проведення заходу або підписання договору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'e', 0, 1, 'Термін відношення', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'f', 0, 0, 'Дата роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'h', 0, 0, 'Фізичний носій', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'm', 0, 1, 'Засіб для виконанняя муз. твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'n', 0, 1, 'Номер частини/розділу роботи', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'o', 0, 0, 'Відомості про аранжування музичного твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'p', 0, 1, 'Назва частини/розділу роботи', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'r', 0, 0, 'Музичний ключ', '',                     8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 's', 0, 0, 'Версія', '',                            8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'u', 0, 0, 'Додаткові відомості', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '810', 'v', 0, 0, 'Номер тому/послідовне позначення', '',  8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '810', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '811', '', 1, 'Заголовок додаткового бібл.запису на серію — назва заходу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '811', '4', 0, 1, 'Код відношення', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', '6', 0, 0, 'Елемент зв’язку', '',                 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'MEETI_NAME', '811', 'a', 0, 0, 'Назва заходу', '',            8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'c', 0, 0, 'Місце проведення', '',                8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'd', 0, 1, 'Дата проведення заходу', '',          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'e', 0, 1, 'Структурний підррозділ', '',          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'f', 0, 0, 'Дата роботи', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'g', 0, 0, 'Інші відомості', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'h', 0, 0, 'Фізичний носій', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'j', 0, 1, 'Термін відношенння (роль)', '',       8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'k', 0, 1, 'Підзаголовок форми', '',              8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'l', 0, 0, 'Мова роботи', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'n', 0, 1, 'Номер частини/розділу роботи', '',    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'p', 0, 1, 'Назва частини/розділу роботи', '',    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'q', 0, 0, 'Більш докладна форма імені', '',      8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 's', 0, 0, 'Версія', '',                          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 't', 0, 0, 'Назва роботи', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'u', 0, 0, 'Додаткові відомості', '',             8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'v', 0, 0, 'Номер тому/послідовне позначення', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '811', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '830', '', 1, 'Заголовок додаткового бібл.запису на серію — уніфікована назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '830', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'UNIF_TITLE', '830', 'a', 0, 0, 'Уніфікована назва', '',       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'd', 0, 1, 'Дата підписання договору', '',          8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'f', 0, 0, 'Дата роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'h', 0, 0, 'Фізичний носій', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'm', 0, 1, 'Засіб для виконання муз. твору', '',    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'n', 0, 1, 'Номер частини/розділу роботи', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'o', 0, 0, 'Відомості про аранжування музичного твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'p', 0, 1, 'Назва частини/розділу роботи', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'r', 0, 0, 'Музичний ключ', '',                     8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 's', 0, 0, 'Версія', '',                            8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '830', 'v', 0, 0, 'Номер тому/послідовне позначення', '',  8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '830', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '840', '', 1, 'Додаткова пошукова ознака на серію — назва (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '840', 'a', 0, 0, 'Title', 'Title',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '840', 'h', 0, 1, 'Фізичний носій', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '840', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '841', '', '', 'Значення кодованих даних про фонди', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '841', 'a', 0, 0, 'Type of record', 'Type of record',    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '841', 'b', 0, 0, 'Fixed-length data elements', 'Fixed-length data elements', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '841', 'e', 0, 0, 'Encoding level', 'Encoding level',    8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '842', '', '', 'Позначення текстової фізичної форми', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '842', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '842', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '842', 'a', 0, 0, 'Textual physical form designator', 'Textual physical form designator', 8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '843', '', 1, 'Примітка про репродукцію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '843', '3', 0, 0, 'Область застосування даних поля', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', '6', 0, 0, 'Елемент зв’язку', '',                 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', '7', 0, 0, 'Fixed-length data elements of reproduction', 'Fixed-length data elements of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', 'a', 0, 0, 'Type of reproduction', 'Type of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', 'b', 0, 1, 'Place of reproduction', 'Place of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', 'c', 0, 1, 'Agency responsible for reproduction', 'Agency responsible for reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', 'd', 0, 0, 'Date of reproduction', 'Date of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', 'e', 0, 1, 'Physical description of reproduction', 'Physical description of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', 'f', 0, 1, 'Series statement of reproduction', 'Series statement of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', 'm', 0, 1, 'Dates of publication and/or sequential designation of issues reproduced', 'Dates of publication and/or sequential designation of issues reproduced', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '843', 'n', 0, 1, 'Note about reproduction', 'Note about reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '844', '', '', 'Назва одиниці', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '844', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '844', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '844', 'a', 0, 0, 'Назва одиниці', '',                     8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '845', '', 1, 'Умови контролю за використанням та репродукцією', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '845', '3', 0, 0, 'Область застосування даних поля', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '845', '5', 0, 0, 'Приналежність поля організації', '',  8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '845', '6', 0, 0, 'Елемент зв’язку', '',                 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '845', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '845', 'a', 0, 0, 'Terms governing use and reproduction', 'Terms governing use and reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '845', 'b', 0, 0, 'Jurisdiction', 'Jurisdiction',        8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '845', 'c', 0, 0, 'Authorization', 'Authorization',      8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '845', 'd', 0, 0, 'Authorized users', 'Authorized users', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '850', '', 1, 'Організація-утримувач', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '850', '8', 0, 1, 'Зв’язок полів та номер послідовності', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '850', 'a', 0, 1, 'Назва організації', '',               8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '850', 'b', 0, 0, 'Holdings (NR) (MU VM SE) [OBSOLETE]', 'Holdings (NR) (MU VM SE) [OBSOLETE]', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '850', 'd', 0, 0, 'Inclusive dates (NR) (MU VM SE) [OBSOLETE]', 'Inclusive dates (NR) (MU VM SE) [OBSOLETE]', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '850', 'e', 0, 0, 'Retention statement (NR) (CF MU VM SE) [OBSOLETE]', 'Retention statement (NR) (CF MU VM SE) [OBSOLETE]', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '851', '', 1, 'Місцезнаходження (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '851', '3', 0, 0, 'Область застосування даних поля', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '851', '6', 0, 0, 'Елемент зв’язку', '',                 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '851', 'a', 0, 0, 'Name (custodian or owner)', 'Name (custodian or owner)', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '851', 'b', 0, 0, 'Institutional division', 'Institutional division', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '851', 'c', 0, 0, 'Street address', 'Street address',    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '851', 'd', 0, 0, 'Country', 'Country',                  8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '851', 'e', 0, 0, 'Location of units', 'Location of units', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '851', 'f', 0, 0, 'Номер об’єкту', '',                   8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '851', 'g', 0, 0, 'Repository location code', 'Repository location code', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '852', '', 1, 'Місцезнаходження', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '852', '2', 0, 0, 'Джерело схеми розстановки', '',         8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', '3', 0, 0, 'Область застосування даних', '',        8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', '6', 0, 0, 'Зв’язок', '',                           8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', '8', 0, 1, 'Sequence number', 'Sequence number',    8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'a', 0, 0, 'Місцезнаходження', '',                  8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'b', 0, 1, 'Підрозділ', '',                         8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'c', 0, 1, 'Місцезнаходження на полиці', '',        8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'e', 0, 1, 'Адреса', '',                            8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'f', 0, 1, 'Кодовані дані', '',                     8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'g', 0, 1, 'Особливості розстановки', '',           8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'h', 0, 0, 'Класифік.частина індексу', '',          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'i', 0, 1, 'Розстановочна ознака', '',              8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'j', 0, 0, 'Шифр зберігання', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'k', 0, 0, 'Префікс шифру зберігання', '',          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'l', 0, 0, 'Розстановочна форма назви', '',         8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'm', 0, 0, 'Суфікс шифру зберігання', '',           8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'n', 0, 0, 'Код країни', '',                        8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'p', 0, 0, 'Інвентарний номер', '',                 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'q', 0, 0, 'Фізич. особливості прим.', '',          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 's', 0, 1, 'Copyright article-fee code', 'Copyright article-fee code', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 't', 0, 0, 'Порядковий номер примірн.', '',         8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 8, 5, '', '', '', 1, '', '', NULL),
 ('BKS', '', '852', 'x', 0, 0, 'Приміт., непризнач. корист.', '',       8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '852', 'z', 0, 1, 'Примітка для ЕК', '',                   8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '853', '', 1, 'Заголовки та модель — основна бібліографічна одиниця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '853', '3', 0, 0, 'Область застосування даних поля', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'n', 0, 0, 'Pattern note', 'Pattern note',          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 't', 0, 0, 'Copy', 'Copy',                          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'w', 0, 0, 'Frequency', 'Frequency',                8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'x', 0, 0, 'Calendar change', 'Calendar change',    8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '853', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',  8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '854', '', 1, 'Заголовки та модель — додатковий матеріал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '854', '3', 0, 0, 'Область застосування даних поля', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'n', 0, 0, 'Pattern note', 'Pattern note',          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 't', 0, 0, 'Copy', 'Copy',                          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'w', 0, 0, 'Frequency', 'Frequency',                8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'x', 0, 0, 'Calendar change', 'Calendar change',    8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '854', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',  8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '855', '', 1, 'Заголовки та модель — покажчики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '855', '3', 0, 0, 'Область застосування даних поля', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'n', 0, 0, 'Pattern note', 'Pattern note',          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 't', 0, 0, 'Copy', 'Copy',                          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'w', 0, 0, 'Frequency', 'Frequency',                8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'x', 0, 0, 'Calendar change', 'Calendar change',    8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '855', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',  8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '856', '', 1, 'Електронна адреса документа', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '856', '2', 0, 0, 'Спосіб доступу', '',                    8, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', '3', 0, 0, 'Область застосування даних поля', '',   8, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', '8', 0, 1, 'Зв’язок полів та номер послідовності', '', 8, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'a', 0, 1, 'Ім’я сервера/домену', '',               8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'b', 0, 1, 'Номер для доступу', '',                 8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'c', 0, 1, 'Інформація про стиснення', '',          8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'd', 0, 1, 'Шлях', '',                              8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'f', 0, 1, 'Електронне ім’я', '',                   8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'h', 0, 0, 'Ім’я користувача', '',                  8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'i', 0, 0, 'Пароль', '',                            8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'j', 0, 0, 'Кількість біт у секунду', '',           8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'k', 0, 0, 'Пароль', '',                            8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'l', 0, 0, 'Вхід/початок сеансу', '',               8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'm', 0, 1, 'Допомога', '',                          8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'n', 0, 0, 'Місцезнаходження серверу', '',          8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'o', 0, 0, 'Операційна система серверу', '',        8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'p', 0, 0, 'Порт', '',                              8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'q', 0, 0, 'Тип електронного формату', '',          8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'r', 0, 1, 'Структура', '',                         8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 's', 0, 1, 'Розмір файлу', '',                      8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 't', 0, 1, 'Емуляція терміналу', '',                8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'u', 0, 1, 'URL', '',                               8, -1, 'biblioitems.url', '', '', 1, '', '', NULL),
 ('BKS', '', '856', 'v', 0, 1, 'Години доступу до ресурсу', '',         8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'w', 0, 1, 'Контрольний номер запису', '',          8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'x', 0, 1, 'Службова примітка', '',                 8, 1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'y', 0, 1, 'Довідковий текст', '',                  8, -1, '', '', '', 0, '', '', NULL),
 ('BKS', '', '856', 'z', 0, 1, 'Примітка для користувача', '',          8, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '859', '', 1, 'Локальна контрольна інформація', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '859', 'b', 0, 0, 'Operators initials, OID (RLIN)', 'Operators initials, OID (RLIN)', 8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '859', 'c', 0, 0, 'Catalogers initials, CIN (RLIN)', 'Catalogers initials, CIN (RLIN)', 8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '859', 'd', 0, 0, 'TDC (RLIN)', 'TDC (RLIN)',              8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '859', 'l', 0, 0, 'LIB (RLIN)', 'LIB (RLIN)',              8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '859', 'p', 0, 0, 'PRI (RLIN)', 'PRI (RLIN)',              8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '859', 'r', 0, 0, 'REG (RLIN)', 'REG (RLIN)',              8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '859', 'v', 0, 0, 'VER (RLIN)', 'VER (RLIN)',              8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '859', 'x', 0, 0, 'LDEL (RLIN)', 'LDEL (RLIN)',            8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '863', '', 1, 'Нумерація та хронологія — основна бібліографічна одиниця', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '864', '', 1, 'Нумерація та хронологія — додатковий матеріал', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '865', '', 1, 'Нумерація та хронологія — покажчики', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '866', '', 1, 'Текстовий опис фондів — основна бібліографічна одиниця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '866', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '866', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '866', 'a', 0, 0, 'Textual string', 'Textual string',      8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '866', 'x', 0, 1, 'Службова примітка', '',                 8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '866', 'z', 0, 1, 'Примітка для ЕК', '',                   8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '867', '', 1, 'Текстовий опис фондів — додатковий матеріал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '867', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '867', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '867', 'a', 0, 0, 'Textual string', 'Textual string',      8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '867', 'x', 0, 1, 'Службова примітка', '',                 8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '867', 'z', 0, 1, 'Примітка для ЕК', '',                   8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '868', '', 1, 'Текстовий опис фондів — покажчики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '868', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '868', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '868', 'a', 0, 0, 'Textual string', 'Textual string',      8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '868', 'x', 0, 1, 'Службова примітка', '',                 8, 5, '', '', '', 0, '', '', NULL),
 ('BKS', '', '868', 'z', 0, 1, 'Примітка для ЕК', '',                   8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '870', '', 1, 'Варіант індивідуального імені (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '870', '4', 0, 1, 'Код відношення', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'a', 0, 0, 'Personal name', 'Personal name',        8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'b', 0, 0, 'Numeration', 'Numeration',              8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'e', 0, 1, 'Термін відношенння (роль)', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'f', 0, 0, 'Дата публікації', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '870', 'u', 0, 0, 'Додаткові відомості', '',               8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '871', '', 1, 'Варіант фірмового імені (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '871', '4', 0, 1, 'Код відношення', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',  8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'e', 0, 1, 'Термін відношенння (роль)', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'f', 0, 0, 'Дата публікації', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '871', 'u', 0, 0, 'Додаткові відомості', '',               8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '872', '', 1, 'Варіант назви конференції чи заходу (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '872', '4', 0, 1, 'Код відношення', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', '6', 0, 0, 'Елемент зв’язку', '',                 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'b', 0, 0, 'Number [OBSOLETE]', 'Number [OBSOLETE]', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'd', 0, 0, 'Date of meeting', 'Date of meeting',  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'f', 0, 0, 'Дата публікації', '',                 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'g', 0, 0, 'Інші відомості', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', '', '872', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'k', 0, 1, 'Підзаголовок форми', '',              8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'l', 0, 0, 'Мова роботи', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'p', 0, 1, 'Заголовок частини/розділу твору', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 't', 0, 0, 'Назва роботи', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '872', 'u', 0, 0, 'Додаткові відомості', '',             8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '873', '', 1, 'Варіант уніфікованого заголовку (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '873', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'a', 0, 0, 'Уніфікована назва', '',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'd', 0, 1, 'Дата підписання договору', '',          8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'f', 0, 0, 'Дата публікації', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'h', 0, 0, 'Фізичний носій', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'm', 0, 1, 'Засіб виконання музичного твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'o', 0, 0, 'Позначення аранжування', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 'r', 0, 0, 'Тональність', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 's', 0, 0, 'Версія, видання і т. д.', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '873', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '876', '', 1, 'Інформація про примірник — основна бібліографічна одиниця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '876', '3', 0, 0, 'Область застосування даних поля', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', '8', 0, 1, 'Sequence number', 'Sequence number',    8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'c', 0, 1, 'Cost', 'Cost',                          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'd', 0, 1, 'Date acquired', 'Date acquired',        8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'h', 0, 1, 'Use restrictions', 'Use restrictions',  8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'j', 0, 1, 'Item status', 'Item status',            8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'p', 0, 1, 'Piece designation', 'Piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 't', 0, 0, 'Copy number', 'Copy number',            8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'x', 0, 1, 'Службова примітка', '',                 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '876', 'z', 0, 1, 'Примітка для ЕК', '',                   8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '877', '', 1, 'Інформація про примірник — додатковий матеріал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '877', '3', 0, 0, 'Область застосування даних поля', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', '8', 0, 1, 'Sequence number', 'Sequence number',    8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'c', 0, 1, 'Cost', 'Cost',                          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'd', 0, 1, 'Date acquired', 'Date acquired',        8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'h', 0, 1, 'Use restrictions', 'Use restrictions',  8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'j', 0, 1, 'Item status', 'Item status',            8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'p', 0, 1, 'Piece designation', 'Piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 't', 0, 0, 'Copy number', 'Copy number',            8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'x', 0, 1, 'Службова примітка', '',                 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '877', 'z', 0, 1, 'Примітка для ЕК', '',                   8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '878', '', 1, 'Інформація про примірник — покажчики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '878', '3', 0, 0, 'Область застосування даних поля', '',   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', '6', 0, 0, 'Елемент зв’язку', '',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', '8', 0, 1, 'Sequence number', 'Sequence number',    8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'c', 0, 1, 'Cost', 'Cost',                          8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'd', 0, 1, 'Date acquired', 'Date acquired',        8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'h', 0, 1, 'Use restrictions', 'Use restrictions',  8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'j', 0, 1, 'Item status', 'Item status',            8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'p', 0, 1, 'Piece designation', 'Piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 't', 0, 0, 'Copy number', 'Copy number',            8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'x', 0, 1, 'Службова примітка', '',                 8, 5, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '878', 'z', 0, 1, 'Примітка для ЕК', '',                   8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '880', '', 1, 'Альтернативне графічне зображення', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '880', '2', 0, 1, 2, 2,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', '3', 0, 1, 3, 3,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', '4', 0, 1, 4, 4,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', '5', 0, 1, 5, 5,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', '7', 0, 1, 7, 7,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', '8', 0, 1, 8, 8,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'a', 0, 1, 'a', 'a',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'b', 0, 1, 'b', 'b',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'c', 0, 1, 'c', 'c',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'd', 0, 1, 'd', 'd',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'e', 0, 1, 'e', 'e',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'f', 0, 1, 'f', 'f',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'g', 0, 1, 'g', 'g',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'h', 0, 1, 'h', 'h',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'i', 0, 1, 'i', 'i',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'j', 0, 1, 'j', 'j',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'k', 0, 1, 'k', 'k',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'l', 0, 1, 'l', 'l',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'm', 0, 1, 'm', 'm',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'n', 0, 1, 'n', 'n',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'o', 0, 1, 'o', 'o',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'p', 0, 1, 'p', 'p',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'q', 0, 1, 'q', 'q',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'r', 0, 1, 'r', 'r',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 's', 0, 1, 's', 's',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 't', 0, 1, 't', 't',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'u', 0, 1, 'u', 'u',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'v', 0, 1, 'v', 'v',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'w', 0, 1, 'w', 'w',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'x', 0, 1, 'x', 'x',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'y', 0, 1, 'y', 'y',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '880', 'z', 0, 1, 'z', 'z',                                8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '886', '', 1, 'Поле інформації про іноземний формат MARC', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '886', '0', 0, 1, 0, 0,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', '1', 0, 1, 1, 1,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', '2', 0, 1, 2, 2,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', '3', 0, 1, 3, 3,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', '4', 0, 1, 4, 4,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', '5', 0, 1, 5, 5,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', '6', 0, 1, 6, 6,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', '7', 0, 1, 7, 7,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', '8', 0, 1, 8, 8,                                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'a', 0, 1, 'a', 'a',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'b', 0, 1, 'b', 'b',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'c', 0, 1, 'c', 'c',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'd', 0, 1, 'd', 'd',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'e', 0, 1, 'e', 'e',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'f', 0, 1, 'f', 'f',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'g', 0, 1, 'g', 'g',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'h', 0, 1, 'h', 'h',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'i', 0, 1, 'i', 'i',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'j', 0, 1, 'j', 'j',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'k', 0, 1, 'k', 'k',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'l', 0, 1, 'l', 'l',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'm', 0, 1, 'm', 'm',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'n', 0, 1, 'n', 'n',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'o', 0, 1, 'o', 'o',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'p', 0, 1, 'p', 'p',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'q', 0, 1, 'q', 'q',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'r', 0, 1, 'r', 'r',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 's', 0, 1, 's', 's',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 't', 0, 1, 't', 't',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'u', 0, 1, 'u', 'u',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'v', 0, 1, 'v', 'v',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'w', 0, 1, 'w', 'w',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'x', 0, 1, 'x', 'x',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'y', 0, 1, 'y', 'y',                                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '886', 'z', 0, 1, 'z', 'z',                                8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '887', '', 1, 'Поле не MARC-інформації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', NULL, '887', '2', 0, 0, 'Source of data', 'Source of data',    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '887', 'a', 0, 0, 'Content of non-MARC field', 'Content of non-MARC field', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '896', '', 1, 'Локальна додаткова пошукова ознака на серію — індивідуальне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '896', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  8, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '896', '4', 0, 1, 'Код відношення', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'PERSO_NAME', '896', 'a', 0, 0, 'Personal name', 'Personal name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'b', 0, 0, 'Numeration', 'Numeration',              8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'e', 0, 1, 'Термін відношенння (роль)', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'f', 0, 0, 'Дата публікації', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'h', 0, 0, 'Фізичний носій', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'm', 0, 1, 'Засіб виконання музичного твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'o', 0, 0, 'Позначення аранжування', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'r', 0, 0, 'Тональність', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 's', 0, 0, 'Версія, видання і т. д.', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'u', 0, 0, 'Додаткові відомості', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '896', 'v', 0, 0, 'Позначення та номер тому / порядкова нумерація', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '897', '', 1, 'Локальна додаткова пошукова ознака на серію — ім’я організації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '897', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  8, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '897', '4', 0, 1, 'Код відношення', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'CORPO_NAME', '897', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',  8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'e', 0, 1, 'Термін відношенння (роль)', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'f', 0, 0, 'Дата публікації', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'h', 0, 0, 'Фізичний носій', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'm', 0, 1, 'Засіб виконання музичного твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'o', 0, 0, 'Позначення аранжування', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'r', 0, 0, 'Тональність', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 's', 0, 0, 'Версія, видання і т. д.', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'u', 0, 0, 'Додаткові відомості', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '897', 'v', 0, 0, 'Позначення та номер тому / порядкова нумерація', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '898', '', 1, 'Локальна додаткова пошукова ознака на серію — назва заходу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '898', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  8, -6, '', '', '', 0, '', '', NULL),
 ('BKS', NULL, '898', '4', 0, 1, 'Код відношення', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', '6', 0, 0, 'Елемент зв’язку', '',                 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', 'MEETI_NAME', '898', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'd', 0, 0, 'Date of meeting', 'Date of meeting',  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'f', 0, 0, 'Дата публікації', '',                 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'g', 0, 0, 'Інші відомості', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'h', 0, 0, 'Фізичний носій', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'k', 0, 1, 'Підзаголовок форми', '',              8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'l', 0, 0, 'Мова роботи', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'p', 0, 1, 'Заголовок частини/розділу твору', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 's', 0, 0, 'Версія, видання і т. д.', '',         8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 't', 0, 0, 'Назва роботи', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'u', 0, 0, 'Додаткові відомості', '',             8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('BKS', NULL, '898', 'v', 0, 0, 'Позначення та номер тому / порядкова нумерація', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('BKS', '899', '', 1, 'Локальна додаткова пошукова ознака на серію — уніфікований заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('BKS', '', '899', '%', 0, 0, '% (RLIN)', '% (RLIN)',                  8, -6, '', '', '', 0, '', '', NULL),
 ('BKS', '', '899', '6', 0, 0, 'Елемент зв’язку', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', 'UNIF_TITLE', '899', 'a', 0, 0, 'Уніфікована назва', '',       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'd', 0, 1, 'Дата підписання договору', '',          8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'f', 0, 0, 'Дата публікації', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'g', 0, 0, 'Інші відомості', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'h', 0, 0, 'Фізичний носій', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'k', 0, 1, 'Підзаголовок форми', '',                8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'l', 0, 0, 'Мова роботи', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'm', 0, 1, 'Засіб виконання музичного твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'o', 0, 0, 'Позначення аранжування', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'p', 0, 1, 'Заголовок частини/розділу твору', '',   8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'r', 0, 0, 'Тональність', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 's', 0, 0, 'Версія, видання і т. д.', '',           8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 't', 0, 0, 'Назва роботи', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('BKS', '', '899', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 8, 5, '', '', '', NULL, '', '', NULL);
