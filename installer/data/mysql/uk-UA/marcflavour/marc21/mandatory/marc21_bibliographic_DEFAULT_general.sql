-- На основі MARC21-структури англійською „DEFAULT“
-- Переклад/адаптація: Сергій Дубик (2011-2016), Ольга Баркова (2011)

-- Changes:
-- 2016.12.21: Add 083acmqyz268, 085abcfrstuvwyz68  and much more


-- DELETE FROM biblio_framework WHERE frameworkcode='';
-- INSERT INTO biblio_framework (frameworkcode, frameworktext) VALUES ('', '');
DELETE FROM marc_tag_structure WHERE frameworkcode='';
DELETE FROM marc_subfield_structure WHERE frameworkcode='';


INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '000', 1, '', 'Маркер запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '000', '@', 1, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, 0, '', '', 'marc21_leader.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '001', '', '', 'Контрольний номер', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '001', '@', 0, 0, 'Контрольне поле', 'Контрольне поле',       0, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '003', '', '', 'Належність контрольного номера', 'Належність контрольного номера', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '003', '@', 0, 0, 'Контрольне поле', 'Контрольне поле',       0, 0, '', '', 'marc21_orgcode.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '005', '', '', 'Дата коректування', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '005', '@', 0, 0, 'Контрольне поле', 'Контрольне поле',       0, 0, '', '', 'marc21_field_005.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '006', '', 1, 'Елементи даних фіксованої довжини — додаткові характеристики матеріалу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '006', '@', 0, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, -1, '', '', 'marc21_field_006.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '007', '', 1, 'Кодовані дані (фіз. опис)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '007', '@', 0, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, 0, '', '', 'marc21_field_007.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '008', 1, '', 'Кодовані дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '008', '@', 1, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, 0, '', '', 'marc21_field_008.pl', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '009', '', 1, 'Фіксовані поля фізичного опису для архівних колекцій (застаріле)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '009', '@', 0, 0, 'Контрольне поле сталої довжини', 'Контрольне поле сталої довжини', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '010', '', '', 'Контрольний номер запису в Бібліотеці Конгресу США', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '010', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', NULL, 0, '', '', NULL),
 ('', '', '010', 'a', 0, 0, 'Контрольний номер запису БК', '',          0, 0, 'biblioitems.lccn', '', '', 0, '', '', NULL),
 ('', '', '010', 'b', 0, 1, 'Контрольний номер запису NUCMC (Національний об’єднаний каталог рукописних зібрань)', '', 0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '010', 'z', 0, 1, 'Скасований/помилковий контрольний номер БК', '', 0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '011', '', '', 'Контрольний номер посилання Бібліотеки Конгресу (застаріле)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '011', 'a', 0, 1, 'Контрольний номер запису БК', '',          0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '013', '', 1, 'Патентна інформація', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '013', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', NULL, 0, '', '', NULL),
 ('', '', '013', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '013', 'a', 0, 0, 'Номер патент. док.', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '013', 'b', 0, 0, 'Код країни', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '013', 'c', 0, 0, 'Тип патенту', '',                          0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '013', 'd', 0, 1, 'Дата видачі(ррррммдд)', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '013', 'e', 0, 1, 'Статус патенту', '',                       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '013', 'f', 0, 1, 'Учасник створення', '',                    0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '015', '', 1, 'Номер в нац.бібліогр.', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '015', '2', 0, 1, 'Джерело номера', '',                       0, 0, '', '', NULL, 0, '', '', NULL),
 ('', '', '015', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '015', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '015', 'a', 0, 1, 'Номер в нац.бібліогр.', '',                0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '015', 'q', 0, 1, 'Qualifying information', '',                0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '015', 'z', 0, 1, 'Canceled/invalid national bibliography number', '',                0, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '016', '', 1, 'Контрольний номер національного бібліографічного агентства', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '016', '2', 0, 1, 'Організація-джерело контрольного номера', '', 0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '016', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '016', 'a', 0, 0, 'Контрольний номер запису', '',             0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '016', 'z', 0, 1, 'Скасований/помилковий контрольний номер', '', 0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '017', '', 1, 'Номер держ.реєстрації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '017', '2', 0, 1, 'Джерело номера', '',                       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '017', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '017', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '017', 'a', 0, 1, 'Номер держ.реєстрації', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '017', 'b', 0, 0, 'Організ. що присв.номер', '',              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '017', 'd', 0, 0, 'Дата реєстрації авторського права', '',    0, -6, '', '', NULL, 0, '', '', NULL),
 ('', '', '017', 'i', 0, 0, 'Пояснювальний текст/ввідні слова', '',     0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '018', '', '', 'Код плати за копіювання статті у відповідності до авторського права', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '018', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '018', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '018', 'a', 0, 0, 'Код копірайту', '',                        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '01e', '', 1, 'Помилка кодованого імені', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '01e', 'a', 0, 0, 'Помилка кодованого імені', '',             0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '020', '', 1, 'Індекс ISBN', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '020', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '020', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '020', 'a', 0, 0, 'ISBN', '',                                 0, 0, 'biblioitems.isbn', '', '', 0, '', '', NULL),
 ('', '', '020', 'c', 0, 0, 'Ціна, тираж', '',                          0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '020', 'z', 0, 1, 'Скасований/помилковий ISBN', '',           0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '022', '', 1, 'Індекс ISSN', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '022', '2', 0, 0, 'Source', 'Source',                         0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '022', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '022', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '022', 'a', 0, 0, 'ISSN', '',                                 0, 0, 'biblioitems.issn', '', '', 0, '', '', NULL),
 ('', '', '022', 'y', 0, 1, 'Помилк. ISSN', '',                         0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '022', 'z', 0, 1, 'Скасов. ISSN', '',                         0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '023', '', 1, 'Стандартний номер фільму [вилучено]', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '023', 'a', 0, 0, 'Стандартний номер фільму', '',             0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '024', '', 1, 'Інші станд. номери', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '024', '2', 0, 0, 'Джерело номера', '',                       0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '024', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '024', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '024', 'a', 0, 0, 'Стандартний номер', '',                    0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '024', 'b', 0, 0, 'Additional codes following the standard number (застаріло)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '024', 'c', 0, 1, 'Умови отрим.(ціна, тираж)', '',            0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '024', 'd', 0, 0, 'Додатк. коди', '',                         0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '024', 'z', 0, 1, 'Скасов./помилк. номер', '',                0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '025', '', 1, 'Номер закордонного придбання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '025', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '025', 'a', 0, 1, 'Номер закордонного придбання', '',         0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '026', '', 1, 'Фінгерпринт', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '026', '2', 0, 0, 'Використаний посібник', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '026', '5', 0, 0, 'Приналежність поля організації', '',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '026', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '026', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '026', 'a', 0, 0, 'Перша і друга групи символів', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '026', 'b', 0, 0, 'Третя і четверта групи символів', '',      0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '026', 'c', 0, 0, 'Дата (026)', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '026', 'd', 0, 1, 'Номер тому або частини', '',               0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '026', 'e', 0, 0, 'Фінгерпринт без розбивки на групи', '',    0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '027', '', 1, 'Стандартний номер технічного звіту (STRN)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '027', '2', 0, 0, 'Джерело номера', '',                       0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '027', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '027', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '027', 'a', 0, 0, 'Стандартний номер технічного звіту (STRN)', '', 0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '027', 'z', 0, 1, 'Скасований/помилковий номер технічного звіту', '', 0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '028', '', 1, 'Номер видавця', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '028', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '028', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '028', 'a', 0, 0, 'Номер видавця', '',                        0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '028', 'b', 0, 0, 'Джерело № видавця', '',                    0, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '029', '', 1, 'Контрольний номер для інших систем (OCLC)', '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '030', '', 1, 'Позначення CODEN', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '030', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '030', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '030', 'a', 0, 0, 'Діючий номер CODEN', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '030', 'z', 0, 1, 'Скасований/недійсний номер CODEN', '',     0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '031', '', 1, 'Музичний інципіт', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '031', '2', 0, 0, 'Код системи', '',                          0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'a', 0, 0, 'Порядковий номер твору у каталогізованій одиниці', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'b', 0, 0, 'Порядковий номер темпу у творі', '',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'c', 0, 0, 'Порядковий номер інципіта у темпі', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'd', 0, 1, 'Назва або заголовок інципіту', '',         0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'e', 0, 0, 'Найменування символу разспіву інципіту (вокал)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'g', 0, 0, 'Ключ', '',                                 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'm', 0, 0, 'Голос/інструмент', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'n', 0, 0, 'Позначення тональності', '',               0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'o', 0, 0, 'Позначення такту', '',                     0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'p', 0, 0, 'Музична нотація', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'q', 0, 0, 'Примітка', '',                             0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'r', 0, 0, 'Тональність', '',                          0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 's', 0, 1, 'Код перевірки правдивості', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 't', 0, 1, 'Літературний інципіт', '',                 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 0, -6, '', '', '', 1, '', '', NULL),
 ('', '', '031', 'y', 0, 1, 'Зв’язний текст', '',                       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '031', 'z', 0, 1, 'Примітка для ЕК', '',                      0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '032', '', 1, 'Номер поштової реєстрації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '032', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', NULL, 0, '', '', NULL),
 ('', '', '032', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '032', 'a', 0, 0, 'Номер поштової реєстрації', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '032', 'b', 0, 0, 'Джерело (агентство, яке присвоїло номер)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '033', '', 1, 'Дата/час і місце події', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '033', '3', 0, 0, 'Область застосування даних поля', '',      0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '033', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '033', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '033', 'a', 0, 1, 'Дата/час у форматі', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '033', 'b', 0, 1, 'Код географічної класифікації регіону', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '033', 'c', 0, 1, 'Код географічної класифікації області (частини регіону)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '034', '', 1, 'Кодовані картографічні математичні дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '034', '2', 0, 0, 'Source', 'Source',                         0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'a', 0, 0, 'Категорія масштабу a — лінійний, b — кутовий масштаб, z — масштаб іншого типу', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'b', 0, 1, 'Постійний лінійний горизонтальний масштаб', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'c', 0, 1, 'Постійний лінійний вертикальний масштаб', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'd', 0, 0, 'Координати — найзахідніша довгота', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'e', 0, 0, 'Координати — найсхідніша довгота', '',     0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'f', 0, 0, 'Координати — найпівнічніша довгота', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'g', 0, 0, 'Координати — найпівденніша довгота', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'h', 0, 1, 'Кутовий масштаб', '',                      0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'j', 0, 0, 'Схилення — північна границя', '',          0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'k', 0, 0, 'Схилення — південна границя', '',          0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'm', 0, 0, 'Пряме сходження — східна границя', '',     0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'n', 0, 0, 'Пряме сходження — західная границя', '',   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'p', 0, 0, 'Рівнодення', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'r', 0, 0, 'Distance from earth', 'Distance from earth', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 's', 0, 1, 'Широта G-контуруа', '',                    0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 't', 0, 1, 'Довгота G-контуру', '',                    0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'x', 0, 0, 'Beginning date', 'Beginning date',         0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'y', 0, 0, 'Ending date', 'Ending date',               0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '034', 'z', 0, 0, 'Name of extraterrestrial body', 'Name of extraterrestrial body', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '035', '', 1, 'Системний контрольний номер', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '035', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '035', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '035', 'a', 0, 0, 'Системний контрольний номер', '',          0, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '035', 'z', 0, 1, 'Анульов. контрольний номер', '',           0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '036', '', '', 'Первісний номер, присв. комп’ют. файлу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '036', '6', 0, 1, 'Елемент полів', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '036', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '036', 'a', 0, 0, 'Первісно присвоєний номер', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '036', 'b', 0, 1, 'Агентство, що надало номер', '',           0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '037', '', 1, 'Дані для комплектування', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '037', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '037', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '037', 'a', 0, 0, 'Номер за прейскурантом і т.ін', '',        0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '037', 'b', 0, 0, 'Продавець, розповсюджувач, видавець, виготовник', '', 0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '037', 'c', 0, 1, 'Умови отримання, ціна', '',                0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '037', 'f', 0, 1, 'Форма розповсюджуваного матеріалу', '',    0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '037', 'g', 0, 1, 'Додаткові характеристики матеріалу', '',   0, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '037', 'n', 0, 1, 'Примітка', '',                             0, -1, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '038', '', '', 'Установа, що надала права інтелектуальної власності на вміст запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '038', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '038', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '038', 'a', 0, 0, 'Код установи, що надала права інтелектуальної власності на вміст запису', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '039', '', '', 'Рівень бібліографічного контролю та кодування (застаріле)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '039', 'a', 0, 0, 'Level of rules in bibliographic description', 'Level of rules in bibliographic description', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '039', 'b', 0, 0, 'Level of effort used to assign nonsubject heading access points', 'Level of effort used to assign nonsubject heading access points', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '039', 'c', 0, 0, 'Level of effort used to assign subject headings', 'Level of effort used to assign subject headings', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '039', 'd', 0, 0, 'Level of effort used to assign classification', 'Level of effort used to assign classification', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '039', 'e', 0, 0, 'Number of fixed field character positions coded', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '040', '', '', 'Джерело каталогіз.', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '040', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '040', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '040', 'a', 0, 0, 'Служба первин.кат.', '',                   0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '040', 'b', 0, 0, 'Код мови каталог.', '',                    0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '040', 'c', 0, 0, 'Орг., що перетв.запис', '',                0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '040', 'd', 0, 1, 'Орг., що змін.запис', '',                  0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '040', 'e', 0, 0, 'Правила каталог.', '',                     0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '041', '', 1, 'Код мови видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '041', '2', 0, 0, 'Код мови оригіналу', '',                   0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('', '', '041', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '041', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '041', 'a', 0, 1, 'Код мови тексту', '',                      0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('', '', '041', 'b', 0, 1, 'Код мови передмови', '',                   0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('', '', '041', 'c', 0, 1, 'Languages of separate titles (VM) (застаріло); Languages of available translation  (SE) (застаріло)', '', 0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('', '', '041', 'd', 0, 1, 'Код мов.тексту спів./мов.', '',            0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('', '', '041', 'e', 0, 1, 'Код мов.лібрето', '',                      0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('', '', '041', 'f', 0, 1, 'Код мови змісту', '',                      0, -6, '', 'LANG', '', 0, '', '', NULL),
 ('', '', '041', 'g', 0, 1, 'Код мови супров.матер.', '',               0, -1, '', 'LANG', '', 0, '', '', NULL),
 ('', '', '041', 'h', 0, 1, 'Код мови оригіналу', '',                   0, -1, '', 'LANG', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '042', '', '', 'Код автентичності запису', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '042', 'a', 0, 0, 'Код автентичності', '',                    0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '043', '', '', 'Код географічного регіону', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '043', '2', 0, 1, 'Джерело локального коду', '',              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '043', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '043', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '043', 'a', 0, 1, 'Код географічного регіону', '',            0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '043', 'b', 0, 1, 'Локальний код географ. регіону', '',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '043', 'c', 0, 1, 'ISO code', 'ISO code',                     0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '044', '', '', 'Код країни публікації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '044', '2', 0, 1, 'Джерело локального коду', '',              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '044', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '044', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '044', 'a', 0, 1, 'Код країни публікації', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '044', 'b', 0, 1, 'Локальний код місця', '',                  0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '044', 'c', 0, 1, 'Код місця видання за ISO', '',             0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '045', '', '', 'Період часу, охоплений змістом документа', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '045', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '045', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '045', 'a', 0, 1, 'Код періода часу', '',                     0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '045', 'b', 0, 1, 'Форматоване позначення періода часу з н. е. по 9999 до н. е.', '', 0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '045', 'c', 0, 1, 'Форматоване позначення періода часу до 9999 до н.е.', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '046', '', 1, 'Спеціальні кодовані дати', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '046', '2', 0, 0, 'Джерело дати', '',                         0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'a', 0, 0, 'Тип коду дати', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'b', 0, 0, 'Дата 1 (дата до н.е.)', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'c', 0, 0, 'Дата 1 (дата н.е.)', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'd', 0, 0, 'Дата 2 (дата до н.е.)', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'e', 0, 0, 'Дата 2 (дата н.е.)', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'j', 0, 0, 'Зміна джерела дати', '',                   0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'k', 0, 0, 'Дата або початок діапазону дати створення (ресурсу)', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'l', 0, 0, 'Дата закінчення створення (ресурсу)', '',  0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'm', 0, 0, 'Beginning of date valid', 'Beginning of date valid', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '046', 'n', 0, 0, 'End of date valid', 'End of date valid',   0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '047', '', 1, 'Код форми муз.композиції', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '047', '2', 0, 0, 'Джерело коду', '',                         0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '047', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '047', 'a', 0, 1, 'Код форми муз.композиції', '',             0, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '048', '', 1, 'Код кіл-ті муз.інстр.або голосів', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '048', '2', 0, 0, 'Джерело коду', '',                         0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '048', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '048', 'a', 0, 1, 'Виконавець або ансамбль', '',              0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '048', 'b', 0, 1, 'Soloist', 'Soloist',                       0, -1, '', '', '', 0, '', '', NULL),
 ('', '', '048', 'c', 0, 1, 'Соліст', '',                               0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '049', '', '', 'Локальне зберігання (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '049', 'a', 0, 1, 'Holding library', 'Holding library',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'c', 0, 1, 'Copy statement', 'Copy statement',         0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'd', 0, 1, 'Definition of bibliographic subdivisions', 'Definition of bibliographic subdivisions', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'l', 0, 1, 'Local processing data', 'Local processing data', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'm', 0, 1, 'Missing elements', 'Missing elements',     0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'n', 0, 0, 'Notes about holdings', 'Notes about holdings', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'o', 0, 1, 'Local processing data', 'Local processing data', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'p', 0, 1, 'Secondary bibliographic subdivision', 'Secondary bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'q', 0, 1, 'Third bibliographic subdivision', 'Third bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'r', 0, 1, 'Fourth bibliographic subdivision', 'Fourth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 's', 0, 0, 'Fifth bibliographic subdivision', 'Fifth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 't', 0, 1, 'Sixth bibliographic subdivision', 'Sixth bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'u', 0, 1, 'Seventh bibliographic subdivision', 'Seventh bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'v', 0, 1, 'Primary bibliographic subdivision', 'Primary bibliographic subdivision', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '049', 'y', 0, 0, 'Inclusive dates of publication or coverage', 'Inclusive dates of publication or coverage', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '050', '', 1, 'Розстановочний код бібл. Конгресу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '050', '3', 0, 0, 'Область застосування даних поля', '',      0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '050', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '050', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '050', 'a', 0, 1, 'Класифікаційний індекс', '',               0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '050', 'b', 0, 0, 'Номер одиниці', '',                        0, 0, '', '', '', 0, '', '', NULL),
 ('', '', '050', 'd', 0, 0, 'Supplementary class number (MU) [OBSOLETE]', 'Supplementary class number (MU) [OBSOLETE]', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '051', '', 1, 'Відомості про копію, примірник, відтиск Бібліотеки Конгресу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '051', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '051', 'a', 0, 0, 'Класифікаційний номер', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '051', 'b', 0, 0, 'Номер об’єкту', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '051', 'c', 0, 0, 'Відомості про копії', '',                  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '052', '', 1, 'Код географічної класифікації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '052', '2', 0, 0, 'Джерело коду', '',                         0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '052', '6', 0, 0, 'Зв’язок', '',                              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '052', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '052', 'a', 0, 0, 'Код географічної класифікації регіону', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '052', 'b', 0, 1, 'Код географічної класифікації області регіону', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '052', 'c', 0, 1, 'Назва населеного пункту', '',              0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '052', 'd', 0, 1, 'Populated place name', 'Populated place name', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '055', '', 1, 'Шифр розміщення Національної бібліотеки Канади', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '055', '2', 0, 0, 'Source of call/class number', '',          0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '055', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '055', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '055', 'a', 0, 0, 'Класифікаційний номер', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '055', 'b', 0, 0, 'Номер об’єкту', '',                        0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '060', '', 1, 'Шифр розміщення Національної медичної бібліотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '060', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '060', 'a', 0, 1, 'Класифікаційний номер', '',              0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '060', 'b', 0, 0, 'Номер об’єкту', '',                      0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '061', '', 1, 'Відомості про примірник Національної медичної бібліотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '061', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '061', 'a', 0, 1, 'Класифікаційний номер', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '061', 'b', 0, 0, 'Номер об’єкту', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '061', 'c', 0, 0, 'Відомості про копії', '',                  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '066', '', '', 'Використовувані набори символів', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '066', 'a', 0, 0, 'Набір символів G0', '',                  0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '066', 'b', 0, 0, 'Набір символів G1', '',                  0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '066', 'c', 0, 1, 'Альтернативний набір символів', '',      0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '070', '', 1, 'Шифр розміщення Національної сільськогосподарської бібліотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '070', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '070', 'a', 0, 1, 'Класифікаційний номер', '',              0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '070', 'b', 0, 0, 'Номер об’єкту', '',                      0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '071', '', 1, 'Відомості про примірник Національної сільськогосподарської бібліотеки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '071', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '071', 'a', 0, 1, 'Класифікаційний номер', '',                0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '071', 'b', 0, 0, 'Номер об’єкту', '',                        0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '071', 'c', 0, 0, 'Відомості про копії', '',                  0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '072', '', 1, 'Код предметної/темат. категорії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '072', '2', 0, 0, 'Джерело коду', '',                       0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '072', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '072', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '072', 'a', 0, 0, 'Код предметної/темат. категорії', '',    0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '072', 'x', 0, 1, 'Код нижчестоящої предм./темат. категорії', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '074', '', 1, 'Номер GPO для одиниці опису', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '074', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '074', 'a', 0, 0, 'Номер об’єкту GPO', '',                  0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '074', 'z', 0, 1, 'Анульований/помилковий номер об’єкту GPO', '', 0, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '080', '', 1, 'Індекс УДК', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '080', '2', 0, 0, 'Ідентифікатор видання', '',              0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '080', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '080', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '080', 'a', 0, 0, 'Індекс УДК', '',                         0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '080', 'b', 0, 0, 'Номер одиниці', '',                      0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '080', 'x', 0, 0, 'Допоміж. ділення загал. характеру', '',  0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '082', '', 1, 'Індекс Дьюї', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '082', '2', 0, 0, 'Номер видання', '',                        0, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '082', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '082', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '082', 'a', 0, 1, 'Індекс Дьюї', '',                          0, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '082', 'b', 0, 0, 'Номер одиниці', '',                        0, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '083', '', 1, 'Additional Dewey Decimal Classification Number', '', '');
 INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '083', 'a', 0, 0, 'Classification number', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '083', 'c', 0, 0, 'Classification number--Ending number of span', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '083', 'm', 0, 0, 'Standard or optional designation', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '083', 'q', 0, 0, 'Assigning agency', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '083', 'y', 0, 0, 'Table sequence number for internal subarrangement or add table', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '083', 'z', 0, 0, 'Table identification', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '083', '2', 0, 0, 'Edition number', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '083', '6', 0, 0, 'Linkage', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '083', '8', 0, 0, 'Field link and sequence number', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '084', '', 1, 'Індекс ББК', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '084', '2', 0, 0, 'Джерело індексу', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '084', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '084', '8', 0, 1,'Зв’язок поля та його порядковий номер','',0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '084', 'a', 0, 1, 'Індекс ББК / індекс іншої класифікації', '',                         0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '084', 'b', 0, 0, 'Номер одиниці', '',                      0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '085', '', 1, 'Synthesized Classification Number Components', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '085', 'a', 0, 0, 'Number where instructions are found-single number or beginning number of span', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'b', 0, 0, 'Base number', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'c', 0, 0, 'Classification number-ending number of span', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'f', 0, 0, 'Facet designator', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'r', 0, 0, 'Root number', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 's', 0, 0, 'Digits added from classification number in schedule or external table', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 't', 0, 0, 'Digits added from internal subarrangement or add table', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'u', 0, 0, 'Number being analyzed', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'v', 0, 0, 'Number in internal subarrangement or add table where instructions are found', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'w', 0, 0, 'Table identification-Internal subarrangement or add table', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'y', 0, 0, 'Table sequence number for internal subarrangement or add table', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', 'z', 0, 0, 'Table identification', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', '6', 0, 0, 'Linkage', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '085', '8', 0, 0, 'Field link and sequence number', '',                    0, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '086', '', 1, 'Класифікаційний номер документа органу державної влади', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '086', '2', 0, 0, 'Джерело індексу', '',                    0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '086', '6', 0, 0, 'Зв’язок', '',                            0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '086', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '086', 'a', 0, 0, 'Класифікаційний номер/номер документа', '', 0, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '086', 'z', 0, 1, 'Скасований/помилковий класифікаційний номер/номер документа', '', 0, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '087', '', 1, 'Номер звіту (застаріле, CAN/MARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '087', 'a', 0, 0, 'Номер звіту (застаріле, CAN/MARC)', '',    0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '087', 'z', 0, 1, 'Анульований/помилковий номер звіту (застаріле, CAN/MARC)', '', 0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '088', '', 1, 'Номер звіту', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '088', '6', 0, 0, 'Зв’язок', '',                            0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '088', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '088', 'a', 0, 0, 'Номер звіту', '',                        0, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '088', 'z', 0, 1, 'Скасований/помилковий номер звіту', '',  0, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '091', '', '', 'Індекси/коди', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '091', 'a', 0, 0, 'Індекс ББК', '',                           0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '091', 'b', 0, 0, 'Індекс ТБК', '',                           0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '091', 'c', 0, 0, 'Код МКІ', '',                              0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '091', 'd', 0, 0, 'Індекс ДАСНТІ', '',                        0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '091', 'e', 0, 0, 'Індикатор цінності', '',                   0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '091', 'f', 0, 0, 'Пріоритет рубрики', '',                    0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '091', 'g', 0, 0, 'Пріоритет док-та', '',                     0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '091', 'i', 0, 0, 'Вікова адресація', '',                     0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '092', '', 1, 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', 'LOCALLY ASSIGNED DEWEY CALL NUMBER (OCLC)', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '092', '2', 0, 0, 'Edition number', 'Edition number',         0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '092', 'a', 0, 0, 'Класифікаційний номер', '',                0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '092', 'b', 0, 0, 'Номер об’єкту', '',                        0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '092', 'e', 0, 0, 'Feature heading', 'Feature heading',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '092', 'f', 0, 0, 'Filing suffix', 'Filing suffix',           0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '094', '', 1, 'Цілість', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '094', 'a', 0, 0, 'Цілість', '',                              0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '094', 'b', 0, 0, 'Дата отримання', '',                       0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '094', 'c', 0, 0, 'Дата списання', '',                        0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '094', 'd', 0, 0, 'Дата передачі', '',                        0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '096', '', 1, 'Локально присвоєний NLM-номер заявки (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '096', 'a', 0, 0, 'Класифікаційний номер', '',                0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '096', 'b', 0, 0, 'Номер об’єкту', '',                        0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '096', 'e', 0, 0, 'Feature heading', 'Feature heading',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '096', 'f', 0, 0, 'Filing suffix', 'Filing suffix',           0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '097', '', 1, 'Оператор', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '097', 'b', 0, 0, 'Оператор', '',                             0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '098', '', 1, 'Інші схеми класифікації (OCLC)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '098', 'a', 0, 0, 'Call number based on other classification scheme', 'Call number based on other classification scheme', 0, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '098', 'e', 0, 0, 'Feature heading', 'Feature heading',       0, -6, '', '', '', 0, '', '', NULL),
 ('', '', '098', 'f', 0, 0, 'Filing suffix', 'Filing suffix',           0, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '100', '', '', 'Автор', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '100', '4', 0, 0, 'Код відношення', '',                       1, 0, '', '', '', 0, '', '', NULL),
 ('', '', '100', '6', 0, 0, 'Зв’язок', '',                              1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('', 'PERSO_NAME', '100', 'a', 0, 0, 'Автор', '',                      1, 0, 'biblio.author', '', '', 0, '\'100b\',\'100c\',\'100q\',\'100d\',\'100e\',\'110a\',\'110b\',\'110c\',\'110d\',\'110e\',\'111a\',\'111e\',\'111c\',\'111d\',\'130a\',
 \'700a\',\'700b\',\'700c\',\'700q\',\'700d\',\'700e\',\'710a\',\'710b\',\'710c\',\'710d\',\'710e\',\'711a\',\'711e\',\'711c\',\'711d\',\'720a\',\'720e\',\'796a\',\'796b\',\'796c\',\'796q\',\'796d\',\'796e\',\'797a\',\'797b\',\'797c\',\'797d\',
 \'797e\',\'798a\',\'798e\',\'798c\',\'798d\',\'800a\',\'800b\',\'800c\',\'800q\',\'800d\',\'800e\',\'810a\',\'810b\',\'810c\',\'810d\',\'810e\',\'811a\',\'811e\',\'811c\',\'811d\',\'896a\',\'896b\',\'896c\',\'896q\',\'896d\',\'896e\',\'897a\',
 \'897b\',\'897c\',\'897d\',\'897e\',\'898a\',\'898e\',\'898c\',\'898d\',\'505r\'', '', NULL),
 ('', '', '100', 'b', 0, 0, 'Династ. номер', '',                        1, -1, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'c', 0, 0, 'Титул (звання)', '',                       1, -1, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'd', 0, 0, 'Дата', '',                                 1, 0, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'e', 0, 0, 'Роль осіб', '',                            1, 0, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'f', 0, 0, 'Дата публікації', '',                      1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'g', 0, 0, 'Інші відомості', '',                       1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'j', 0, 1, 'Приналежність невідомого автора до послідовників, учнів, прихильників, школі і т. ін.', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'k', 0, 1, 'Підзаголовок форми', '',                   1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'l', 0, 0, 'Мова роботи', '',                          1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'q', 0, 0, 'Повне ім’я', '',                           1, 0, '', '', '', 0, '', '', NULL),
 ('', '', '100', 't', 0, 0, 'Назва роботи', '',                         1, -6, '', '', '', 0, '', '', NULL),
 ('', '', '100', 'u', 0, 0, 'Доповнення', '',                           1, -6, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '110', '', '', 'Автор — організація', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '110', '4', 0, 1, 'Код відношення', '',                       1, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '110', '6', 0, 0, 'Зв’язок', '',                              1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '110', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, -6, '', '', '', NULL, '', '', NULL),
 ('', 'CORPO_NAME', '110', 'a', 0, 0, 'Організація/юрисдикція', '',     1, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'b', 0, 0, 'Підпорядкована одиниця', '',               1, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'c', 0, 0, 'Місце', '',                                1, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'd', 0, 0, 'Дата', '',                                 1, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'e', 0, 1, 'Термін відношення', '',                    1, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'f', 0, 0, 'Дата роботи', '',                          1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'g', 0, 0, 'Інша інформація', '',                      1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'k', 0, 1, 'Підзаголовок форми', '',                   1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'l', 0, 0, 'Мова роботи', '',                          1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'n', 0, 1, 'Номер', '',                                1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'p', 0, 1, 'Назва частини/розділу роботи', '',         1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 't', 0, 0, 'Назва роботи', '',                         1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '110', 'u', 0, 0, 'Додаткові відомості', '',                  1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '111', '', '', 'Автор-захід', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '111', '4', 0, 1, 'Код відношення', '',                     1, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', '6', 0, 0, 'Зв’язок', '',                            1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'MEETI_NAME', '111', 'a', 0, 0, 'Назва заходу', '',               1, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'b', 0, 0, 'Number [OBSOLETE]', 'Number [OBSOLETE]', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'c', 0, 0, 'Місце заходу', '',                       1, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'd', 0, 0, 'Дата заходу', '',                        1, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'e', 0, 0, 'Підпорядк.одиниця', '',                  1, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'f', 0, 0, 'Дата роботи', '',                        1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'g', 0, 0, 'Інша інформація', '',                    1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'j', 0, 1, 'Термін відношенння (роль)', '',          1, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'k', 0, 1, 'Підзаголовок форми', '',                 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'l', 0, 0, 'Мова роботи', '',                        1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'n', 0, 0, '№ частини/секції', '',                   1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'p', 0, 0, '№ частини/розділу', '',                  1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 't', 0, 0, 'Назва роботи', '',                       1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '111', 'u', 0, 0, 'Додаткові відомості', '',                1, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '130', '', '', 'Заголовок — уніфікована назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '130', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'UNIF_TITLE', '130', 'a', 0, 0, 'Уніфікована назва', '',          1, -1, NULL, NULL, '', NULL, '\'130o\',\'130m\',\'130r\',\'130s\',\'130d\',\'130k\',\'130n\',\'130p\',\'130g\',\'130l\',\'130f\',\'130h\',\'130t\'', '', NULL),
 ('', NULL, '130', 'd', 0, 1, 'Дата підписання договору', '',           1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'f', 0, 0, 'Дата публікації', '',                    1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'g', 0, 0, 'Інші відомості', '',                     1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'h', 0, 0, 'Фізичний носій', '',                     1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'k', 0, 1, 'Форма, вид, жанр', '',                   1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'l', 0, 0, 'Мова твору', '',                         1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'm', 0, 1, 'Засіб виконання музичного твору', '',    1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'n', 0, 1, 'Номер частини/розділу', '',              1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'o', 0, 0, 'Позначення аранжування', '',             1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'p', 0, 1, 'Назва частини/розділу', '',              1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 'r', 0, 0, 'Тональність', '',                        1, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 's', 0, 0, 'Версія, видання', '',                    1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '130', 't', 0, 0, 'Назва роботи', '',                       1, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '210', '', 1, 'Скорочена назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '210', '2', 0, 1, 'Джерело інформації', '',                 2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '210', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '210', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '210', 'a', 0, 0, 'Скорочена назва', '',                    2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '210', 'b', 0, 0, 'Ідентифікаційні ознаки', '',             2, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '211', '', 1, 'Скорочене найменування чи скорочена назва (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '211', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '211', 'a', 0, 0, 'Скорочене найменування чи скорочена назва', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '212', '', 1, 'Варіант доступної назви (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '212', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '212', 'a', 0, 0, 'Варіант доступної назви', '',            2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '214', '', 1, 'Розширена назва (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '214', '6', 0, 0, 'Елемент зв’язку', '',                    2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '214', 'a', 0, 0, 'Розширена назва', '',                    2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '222', '', 1, 'Ключова назва серіального видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '222', '6', 0, 0, 'Елемент зв’язку', '',                    2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '222', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '222', 'a', 0, 0, 'Ключова назва серіал. вид.', '',         2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '222', 'b', 0, 0, 'Ідентифікаційні ознаки', '',             2, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '240', '', '', 'Умовна назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '240', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'a', 0, 0, 'Умовна назва', '',                         2, -1, 'biblio.unititle', '', '', 0, '', '', NULL),
 ('', '', '240', 'd', 0, 1, 'Дата підписання договору', '',             2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'f', 0, 0, 'Дата публікації', '',                      2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'g', 0, 0, 'Інші відомості', '',                       2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'h', 0, 0, 'Фізич.носій (визнач. матеріалу)', '',      2, -1, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'k', 0, 1, 'Форма, вид, жанр', '',                     2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'l', 0, 0, 'Мова твору', '',                           2, -1, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'm', 0, 1, 'Засіб виконання музичного твору', '',      2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'n', 0, 1, '№ частини/розділу', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'o', 0, 0, 'Позначення аранжування', '',               2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'p', 0, 1, 'Назва частини/розділу', '',                2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '240', 'r', 0, 0, 'Тональність', '',                          2, -1, '', '', '', 0, '', '', NULL),
 ('', '', '240', 's', 0, 0, 'Версія, видання і т.ін.', '',              2, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '241', '', '', 'Ліцензована назва (застаріле)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '241', 'a', 0, 0, 'Ліцензована назва', '',                  2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '241', 'h', 0, 0, 'Фізичний носій', '',                     2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '242', '', 1, 'Переклад назви каталог. організацією', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '242', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '242', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '242', 'a', 0, 0, 'Переклад назви', '',                       2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '242', 'b', 0, 0, 'Продовж.пер.назви', '',                    2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '242', 'c', 0, 0, 'Відповідальність', '',                     2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '242', 'd', 0, 0, 'Designation of section (BK AM MP MU VM SE) [OBSOLETE]', 'Designation of section (BK AM MP MU VM SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '242', 'e', 0, 0, 'Name of part/section (BK AM MP MU VM SE) [OBSOLETE]', 'Name of part/section (BK AM MP MU VM SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '242', 'h', 0, 0, 'Фізичний носій (визнач. матеріалу)', '',   2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '242', 'n', 0, 1, 'Номер частини/розділу', '',                2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '242', 'p', 0, 1, 'Назва частини/розділу', '',                2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '242', 'y', 0, 0, 'Код мови перекладу', '',                   2, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '243', '', '', 'Узагальнююча назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '243', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'a', 0, 0, 'Узагальнююча назва', '',                   2, -1, '', '', '', 1, '', '', NULL),
 ('', '', '243', 'd', 0, 1, 'Дата підписання договору', '',             2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'f', 0, 0, 'Дата публікації', '',                      2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'g', 0, 0, 'Інші відомості', '',                       2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'h', 0, 0, 'Фізич. носій', '',                         2, -1, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'k', 0, 1, 'Форма, вид,  жанр', '',                    2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'l', 0, 0, 'Мова твору', '',                           2, -1, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'm', 0, 0, 'Засіб для вик. музич. твору', '',          2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'n', 0, 1, 'Номер частини/розділу', '',                2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'o', 0, 0, 'Від. про аранжировку муз. твору', '',      2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'p', 0, 1, 'Назва частини/розділу', '',                2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 'r', 0, 0, 'Музичний ключ', '',                        2, -6, '', '', '', 0, '', '', NULL),
 ('', '', '243', 's', 0, 0, 'Версія, видання', '',                      2, -1, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '245', 1, '', 'Назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '245', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'a', 0, 0, 'Назва', '',                                2, 0, 'biblio.title', '', '', 0, NULL, '', ''),
 ('', '', '245', 'b', 0, 0, 'Продовж. назви', '',                       2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'c', 0, 0, 'Відповідальність', '',                     2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'd', 0, 0, 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series: (SE) [OBSOLETE]', 2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'e', 0, 0, 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'f', 0, 0, 'Дати створення твору', '',                 2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'g', 0, 0, 'Дати створення осн. частини твору', '',    2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'h', 0, 0, 'Фізичний носій', '',                       2, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'k', 0, 1, 'Форма, вид, жанр', '',                     2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'n', 0, 1, 'Номер частини/розділу', '',                2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 'p', 0, 1, 'Назва частини/розділу', '',                2, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '245', 's', 0, 0, 'Версія', '',                               2, -6, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '246', '', 1, 'Інша форма назви', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '246', '5', 0, 0, 'Приналежність поля організації', '',       2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '246', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '246', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'a', 0, 0, 'Інша форма назви', '',                     2, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'b', 0, 0, 'Прод. інш. форми назви', '',               2, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'd', 0, 0, 'Designation of section/part/series (SE) [OBSOLETE]', 'Designation of section section/part/series (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'e', 0, 0, 'Name of part/section/series (SE) [OBSOLETE]', 'Name of part/section/series (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'f', 0, 0, 'Том, випуск і/або дата', '',               2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'g', 0, 0, 'Інша інформація', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'h', 0, 1, 'Фізичичний носій', '',                     2, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'i', 0, 1, 'Пояснювальний текст', '',                  2, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'n', 0, 1, 'Номер частини/розділу', '',                2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '246', 'p', 0, 1, 'Назва частини', '',                        2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '247', '', 1, 'Сформований заголовок', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '247', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '247', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'a', 0, 0, 'Заголовок', '',                            2, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'b', 0, 0, 'Remainder of title', 'Remainder of title', 2, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'd', 0, 0, 'Designation of section (SE) [OBSOLETE]', 'Designation of section (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'e', 0, 0, 'Name of part/section (SE) [OBSOLETE]', 'Name of part/section (SE) [OBSOLETE]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'f', 0, 0, 'Date or sequential designation', 'Date or sequential designation', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'g', 0, 0, 'Інші відомості', '',                       2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'h', 0, 0, 'Фізичний носій', '',                       2, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '247', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '250', '', '', 'Відомості про видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '250', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '250', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '250', 'a', 0, 0, 'Основні відомості про видання', '',        2, 0, 'biblioitems.editionstatement', '', '', NULL, '', '', NULL),
 ('', '', '250', 'b', 0, 0, 'Додаткові відомості про видання', '',      2, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '254', '', '', 'Представл. музичного твору', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '254', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '254', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '254', 'a', 0, 0, 'Представл. муз. твору', '',                2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '255', '', 1, 'Картогр. математичні дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '255', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '255', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '255', 'a', 0, 1, 'Картогр. матем. дані', '',                 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '255', 'b', 0, 0, 'Відомості про проекцію', '',               2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '255', 'c', 0, 0, 'Відомості про координати', '',             2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '255', 'd', 0, 0, 'Відомості про зону', '',                   2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '255', 'e', 0, 0, 'Відомості про рівнодення', '',             2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '255', 'f', 0, 0, 'Зовнішні коорд.пари G-кілець', '',         2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '255', 'g', 0, 0, 'Викл. коорд. пари G-кілець', '',           2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '256', '', '', 'Характ. комп’ютерного файлу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '256', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '256', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '256', 'a', 0, 0, 'Характ. комп’ютерного файлу', '',          2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '257', '', '', 'Країна виробник арх. фільмів', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '257', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '257', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '257', 'a', 0, 0, 'Країна виробник арх. фільмів', '',         2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '258', '', 1, 'Дані про філателістські об’єкти (одиниці)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '258', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '258', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '258', 'a', 0, 0, 'Issuing jurisdiction', 'Issuing jurisdiction', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '258', 'b', 0, 0, 'Denomination', 'Denomination',             2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '260', '', 1, 'Вихідні дані', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '260', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '260', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '260', 'a', 0, 1, 'Місце видання', '',                        2, 0, 'biblioitems.place', '', '', NULL, '', '', NULL),
 ('', '', '260', 'b', 0, 1, 'Видавництво', '',                          2, 0, 'biblioitems.publishercode', '', '', NULL, '', '', NULL),
 ('', '', '260', 'c', 0, 1, 'Дата видання', '',                         2, 0, 'biblio.copyrightdate', '', '', NULL, '', '', NULL),
 ('', '', '260', 'd', 0, 0, 'Plate or publishers number for music (Pre-AACR 2) (застаріле, CAN/MARC), (локальне, США)', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '260', 'e', 0, 0, 'Місце друкування', '',                     2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '260', 'f', 0, 0, 'Друкарня', '',                             2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '260', 'g', 0, 0, 'Дата друкування', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '260', 'k', 0, 0, 'Identification/manufacturer number [OBSOLETE, CAN/MARC]', 'Identification/manufacturer number [OBSOLETE, CAN/MARC]', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '260', 'l', 0, 0, 'Matrix and/or take number [OBSOLETE, CAN/MARC]', 'Matrix and/or take number [OBSOLETE, CAN/MARC]', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '261', '', '', 'Вихідні дані фільму (застаріле, Канада) (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '261', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '261', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '261', 'a', 0, 1, 'Producing company', 'Producing company',   2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '261', 'b', 0, 1, 'Releasing company (primary distributor)', 'Releasing company (primary distributor)', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '261', 'c', 0, 1, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '261', 'd', 0, 1, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '261', 'e', 0, 1, 'Contractual producer', 'Contractual producer', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '261', 'f', 0, 1, 'Place of production, release, etc.', 'Place of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '262', '', '', 'Вихідні дані звукозапису (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '262', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '262', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '262', 'a', 0, 0, 'Place of production, release, etc.', 'Place of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '262', 'b', 0, 0, 'Publisher or trade name', 'Publisher or trade name', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '262', 'c', 0, 0, 'Date of production, release, etc.', 'Date of production, release, etc.', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '262', 'k', 0, 0, 'Serial identification', 'Serial identification', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '262', 'l', 0, 0, 'Matrix and/or take number', 'Matrix and/or take number', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '263', '', '', 'Запланована дата публікації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '263', '6', 0, 0, 'Елемент зв’язку', '',                      2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '263', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '263', 'a', 0, 0, 'Запланована дата публікації', '',          2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '265', '', '', 'Джерело придбання / підписка на розсилання (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '265', '6', 0, 0, 'Елемент зв’язку (застаріле)', '',          2, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '265', 'a', 0, 1, 'Джерело придбання / підписка на розсилання (застаріле)', '', 2, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '270', '', 1, 'Адреса', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '270', '4', 0, 1, 'Код відношення', '',                     2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', '6', 0, 0, 'Елемент зв’язку', '',                    2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 2, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'a', 0, 1, 'Адреса', '',                             2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'b', 0, 0, 'City', 'City',                           2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'c', 0, 0, 'State or province', 'State or province', 2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'd', 0, 0, 'Country', 'Country',                     2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'e', 0, 0, 'Postal code', 'Postal code',             2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'f', 0, 0, 'Terms preceding attention name', 'Terms preceding attention name', 2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'g', 0, 0, 'Attention name', 'Attention name',       2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'h', 0, 0, 'Attention position', 'Attention position', 2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'i', 0, 0, 'Type of address', 'Type of address',     2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'j', 0, 1, 'Specialized telephone number', 'Specialized telephone number', 2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'k', 0, 1, 'Telephone number', 'Telephone number',   2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'l', 0, 1, 'Fax number', 'Fax number',               2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'm', 0, 1, 'Electronic mail address', 'Electronic mail address', 2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'n', 0, 1, 'TDD or TTY number', 'TDD or TTY number', 2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'p', 0, 1, 'Contact person', 'Contact person',       2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'q', 0, 1, 'Title of contact person', 'Title of contact person', 2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'r', 0, 1, 'Hours', 'Hours',                         2, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '270', 'z', 0, 1, 'Примітка для ЕК', '',                    2, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '300', '', 1, 'Фізичний опис', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '300', '3', 0, 0, 'Область застосування даних поля', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '300', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '300', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '300', 'a', 0, 1, 'Обсяг', '',                                3, 0, 'biblioitems.pages', '', '', NULL, '', '', NULL),
 ('', '', '300', 'b', 0, 0, 'Ілл./тип відтвор.', '',                    3, 0, 'biblioitems.illus', '', '', 0, '', '', NULL),
 ('', '', '300', 'c', 0, 1, 'Розміри', '',                              3, 0, 'biblioitems.size', '', '', NULL, '', '', NULL),
 ('', '', '300', 'd', 0, 0, 'Accompanying material [застаріло, CAN/MARC]', 'Accompanying material [OBSOLETE, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '300', 'e', 0, 0, 'Супров. мат-л', '',                        3, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '300', 'f', 0, 1, 'Тип одиниці', '',                          3, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '300', 'g', 0, 1, 'Розмір одиниці', '',                       3, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '300', 'k', 0, 0, 'Speed [Videodiscs, pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 'Speed [Videodiscs, pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '300', 'm', 0, 0, 'Identification/manufacturer number [pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 'Identification/manufacturer number [pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '300', 'n', 0, 0, 'Matrix and/or take number [Sound recordings, pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 'Matrix and/or take number [Sound recordings, pre-AACR2 records only] [OBSOLETE, CAN/MARC]', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '301', '', '', 'Фізичний опис фільму (застаріле, USMARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '301', 'a', 0, 0, 'Extent of item', 'Extent of item',         3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '301', 'b', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '301', 'c', 0, 0, 'Color characteristics', 'Color characteristics', 3, -6, '', '', NULL, NULL, '', '', NULL),
 ('', '', '301', 'd', 0, 0, 'Dimensions', 'Dimensions',                 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '301', 'e', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '301', 'f', 0, 0, 'Speed', 'Speed',                           3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '302', '', '', 'Кількість сторінок чи елементів (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '302', 'a', 0, 0, 'Кількість сторінок', '',                   3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '303', '', '', 'Одиниця виміру (застаріле, USMARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '303', 'a', 0, 0, 'Unit count', 'Unit count',                 3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '304', '', '', 'Лінійний розмір (застаріле, USMARC)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '304', 'a', 0, 0, 'Linear footage', 'Linear footage',         3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '305', '', '', 'Фізичні характеристики звукового запису (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '305', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '305', 'a', 0, 0, 'Extent', 'Extent',                         3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '305', 'b', 0, 0, 'Other physical details', 'Other physical details', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '305', 'c', 0, 0, 'Dimensions', 'Dimensions',                 3, -6, '', '', NULL, NULL, '', '', NULL),
 ('', '', '305', 'd', 0, 0, 'Microgroove or standard', 'Microgroove or standard', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '305', 'e', 0, 0, 'Stereophonic, monaural', 'Stereophonic, monaural', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '305', 'f', 0, 0, 'Number of tracks', 'Number of tracks',     3, -6, '', '', NULL, NULL, '', '', NULL),
 ('', '', '305', 'm', 0, 0, 'Serial identification', 'Serial identification', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '305', 'n', 0, 0, 'Matrix and/or take number', 'Matrix and/or take number', 3, -6, '', '', NULL, NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '306', '', '', 'Тривалість звукового запису', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '306', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '306', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '306', 'a', 0, 1, 'Тривалість звукового запису (ггххсс)', '', 3, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '307', '', 1, 'Години', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '307', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '307', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '307', 'a', 0, 0, 'Години', '',                               3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '307', 'b', 0, 0, 'Дод. інформація', '',                      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '308', '', 1, 'Фізичні характеристика фільму (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '308', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '308', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '308', 'a', 0, 0, 'Number of reels', 'Number of reels',       3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '308', 'b', 0, 0, 'Footage', 'Footage',                       3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '308', 'c', 0, 0, 'Sound characteristics', 'Sound characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '308', 'd', 0, 0, 'Color characteristics', 'Color characteristics', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '308', 'e', 0, 0, 'Width', 'Width',                           3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '308', 'f', 0, 0, 'Presentation format', 'Presentation format', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '310', '', '', 'Періодичність п.в.', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '310', '6', 0, 0, 'Елемент зв’язку', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '310', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '310', 'a', 0, 0, 'Періодичність п.в.', '',                 3, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '310', 'b', 0, 0, 'Дата введення період.', '',              3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '315', '', '', 'Частотність (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '315', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '315', 'a', 0, 1, 'Frequency', 'Frequency',                   3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '315', 'b', 0, 1, 'Dates of frequency', 'Dates of frequency', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '321', '', 1, 'Попередня періодичність', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '321', '6', 0, 0, 'Елемент зв’язку', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '321', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '321', 'a', 0, 0, 'Попередня періодичність', '',            3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '321', 'b', 0, 0, 'Дата існуючої періодичності', '',        3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '336', '', 1, 'Content Type', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '336', 'a', 0, 0, 'Content type term', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '336', 'b', 0, 0, 'Content type code', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '336', '0', 0, 0, 'Authority record control number or standard number', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '336', '2', 0, 0, 'Source', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '336', '3', 0, 0, 'Materials specified', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '336', '6', 0, 0, 'Linkage', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '336', '8', 0, 0, 'Field link and sequence number', '',      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '337', '', 1, 'Media Type', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '337', 'a', 0, 0, 'Media type term', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '337', 'b', 0, 0, 'Media type code', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '337', '0', 0, 0, 'Authority record control number or standard number', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '337', '2', 0, 0, 'Source', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '337', '3', 0, 0, 'Materials specified', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '337', '6', 0, 0, 'Linkage', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '337', '8', 0, 0, 'Field link and sequence number', '',      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '338', '', 1, 'Carrier Type', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '338', 'a', 0, 0, 'Carrier type term', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '338', 'b', 0, 0, 'Carrier type code', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '338', '0', 0, 0, 'Authority record control number or standard number', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '338', '2', 0, 0, 'Source', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '338', '3', 0, 0, 'Materials specified', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '338', '6', 0, 0, 'Linkage', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '338', '8', 0, 0, 'Field link and sequence number', '',      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '340', '', 1, 'Фізичний носій', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '340', '3', 0, 0, 'Область застосування даних поля', '',      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', 'a', 0, 1, 'Матер.основа', '',                         3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', 'b', 0, 1, 'Розміри', '',                              3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', 'c', 0, 1, 'Матеріал покриття', '',                    3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', 'd', 0, 1, 'Техніка запису', '',                       3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', 'e', 0, 1, 'Засіб кріплення', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', 'f', 0, 1, 'Production rate/ratio', 'Production rate/ratio', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', 'h', 0, 1, 'Location within medium', 'Location within medium', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '340', 'i', 0, 1, 'Technical specifications of medium', 'Technical specifications of medium', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '342', '', 1, 'Дані про геопросторову систему відліку', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '342', '2', 0, 0, 'Reference method used', 'Reference method used', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'a', 0, 1, 'Name', 'Name',                             3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'b', 0, 0, 'Coordinate or distance units', 'Coordinate or distance units', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'c', 0, 0, 'Latitude resolution', 'Latitude resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'd', 0, 0, 'Longitude resolution', 'Longitude resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'e', 0, 1, 'Standard parallel or oblique line latitude', 'Standard parallel or oblique line latitude', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'f', 0, 1, 'Oblique line longitude', 'Oblique line longitude', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'g', 0, 0, 'Longitude of central meridian or projection center', 'Longitude of central meridian or projection center', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'h', 0, 0, 'Latitude of projection origin or projection center', 'Latitude of projection origin or projection center', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'i', 0, 0, 'False easting', 'False easting',           3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'j', 0, 0, 'False northing', 'False northing',         3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'k', 0, 0, 'Scale factor', 'Scale factor',             3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'l', 0, 0, 'Height of perspective point above surface', 'Height of perspective point above surface', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'm', 0, 0, 'Azimuthal angle', 'Azimuthal angle',       3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'n', 0, 0, 'Azimuth measure point longitude or straight vertical longitude from pole', 'Azimuth measure point longitude or straight vertical longitude from pole', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'o', 0, 0, 'Landsat number and path number', 'Landsat number and path number', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'p', 0, 0, 'Zone identifier', 'Zone identifier',       3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'q', 0, 0, 'Ellipsoid name', 'Ellipsoid name',         3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'r', 0, 0, 'Semi-major axis', 'Semi-major axis',       3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 's', 0, 0, 'Denominator of flattening ratio', 'Denominator of flattening ratio', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 't', 0, 0, 'Vertical resolution', 'Vertical resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'u', 0, 0, 'Vertical encoding method', 'Vertical encoding method', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'v', 0, 0, 'Local planar, local, or other projection or grid description', 'Local planar, local, or other projection or grid description', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '342', 'w', 0, 0, 'Local planar or local georeference information', 'Local planar or local georeference information', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '343', '', 1, 'Дані про планарні координати', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '343', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'a', 0, 1, 'Planar coordinate encoding method', 'Planar coordinate encoding method', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'b', 0, 0, 'Planar distance units', 'Planar distance units', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'c', 0, 0, 'Abscissa resolution', 'Abscissa resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'd', 0, 0, 'Ordinate resolution', 'Ordinate resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'e', 0, 0, 'Distance resolution', 'Distance resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'f', 0, 0, 'Bearing resolution', 'Bearing resolution', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'g', 0, 0, 'Bearing unit', 'Bearing unit',             3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'h', 0, 0, 'Bearing reference direction', 'Bearing reference direction', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '343', 'i', 0, 0, 'Bearing reference meridian', 'Bearing reference meridian', 3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '344', '', 1, 'Sound Characteristics', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '344', '0', 0, 0, 'Authority record control number or standard number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', '2', 0, 0, 'Source', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', '3', 0, 0, 'Materials specified', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', '6', 0, 0, 'Linkage', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', '8', 0, 0, 'Field link and sequence number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', 'a', 0, 0, 'Type of recording', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', 'b', 0, 0, 'Recording medium', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', 'c', 0, 0, 'Playing speed', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', 'd', 0, 0, 'Groove characteristic', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', 'e', 0, 0, 'Track configuration', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', 'f', 0, 0, 'Tape configuration', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', 'g', 0, 0, 'Configuration of playback channels', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '344', 'h', 0, 0, 'Special playback characteristics', '',                      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '345', '', 1, 'Projection Characteristics of Moving Image', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '345', '0', 0, 0, 'Authority record control number or standard number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '345', '2', 0, 0, 'Source', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '345', '3', 0, 0, 'Materials specified', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '345', '6', 0, 0, 'Linkage', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '345', '8', 0, 0, 'Field link and sequence number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '345', 'a', 0, 0, 'Presentation format', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '345', 'b', 0, 0, 'Projection speed', '',                      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '346', '', 1, 'Video Characteristics', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '346', '0', 0, 0, 'Authority record control number or standard number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '346', '2', 0, 0, 'Source', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '346', '3', 0, 0, 'Materials specified', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '346', '6', 0, 0, 'Linkage', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '346', '8', 0, 0, 'Field link and sequence number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '346', 'a', 0, 0, 'Video format', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '346', 'b', 0, 0, 'Broadcast standard', '',                      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '347', '', 1, 'Digital File Characteristics', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '347', '0', 0, 0, 'Authority record control number or standard number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', '2', 0, 0, 'Source', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', '3', 0, 0, 'Materials specified', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', '6', 0, 0, 'Linkage', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', '8', 0, 0, 'Field link and sequence number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', 'a', 0, 0, 'File type', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', 'b', 0, 0, 'Encoding format', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', 'c', 0, 0, 'File size', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', 'd', 0, 0, 'Resolution', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', 'e', 0, 0, 'Regional encoding', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '347', 'f', 0, 0, 'Encoded bitrate', '',                      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '348', '', 1, 'Format of Notated Music', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '348', '0', 0, 0, 'Authority record control number or standard number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '348', '2', 0, 0, 'Source', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '348', '3', 0, 0, 'Materials specified', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '348', '6', 0, 0, 'Linkage', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '348', '8', 0, 0, 'Field link and sequence number', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '348', 'a', 0, 0, 'Format of notated music term', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '348', 'b', 0, 0, 'Format of notated music code', '',                      3, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '350', '', 1, 'Ціна (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '350', '6', 0, 0, 'Елемент зв’язку', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '350', 'a', 0, 1, 'Ціна', '',                               3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '350', 'b', 0, 1, 'Form of issue', 'Form of issue',         3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '351', '', 1, 'Організація та розміщення матеріалів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '351', '3', 0, 0, 'Область застосування даних поля', '',    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '351', '6', 0, 0, 'Елемент зв’язку', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '351', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '351', 'a', 0, 1, 'Organization', 'Organization',           3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '351', 'b', 0, 1, 'Arrangement', 'Arrangement',             3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '351', 'c', 0, 0, 'Hierarchical level', 'Hierarchical level', 3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '352', '', 1, 'Цифрове графічне представлення', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '352', '6', 0, 0, 'Елемент зв’язку', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', 'a', 0, 0, 'Direct reference method', 'Direct reference method', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', 'b', 0, 1, 'Object type', 'Object type',             3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', 'c', 0, 1, 'Object count', 'Object count',           3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', 'd', 0, 0, 'Row count', 'Row count',                 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', 'e', 0, 0, 'Column count', 'Column count',           3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', 'f', 0, 0, 'Vertical count', 'Vertical count',       3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', 'g', 0, 0, 'VPF topology level', 'VPF topology level', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '352', 'i', 0, 0, 'Indirect reference description', 'Indirect reference description', 3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '355', '', 1, 'Контроль у відповідності з класифікацією секретності', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '355', '6', 0, 0, 'Елемент зв’язку', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'a', 0, 0, 'Класифікація секретності', '',           3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'b', 0, 1, 'Операційні інструкції', '',              3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'c', 0, 1, 'Інформація про зовнішнє розповсюдження', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'd', 0, 0, 'Інформація про зменшення або зняття секретності', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'e', 0, 0, 'Класифікаційна система', '',             3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'f', 0, 0, 'Код країни створення класифікації', '',  3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'g', 0, 0, 'Дата зменшення ступеня секретності', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'h', 0, 0, 'Дата зняття секретності', '',            3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '355', 'j', 0, 1, 'Санкціонування', '',                     3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '357', '', '', 'Авторський контроль за розповсюдженням', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '357', '6', 0, 0, 'Елемент зв’язку', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '357', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '357', 'a', 0, 0, 'Термін, що позначає авторський контроль', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '357', 'b', 0, 1, 'Організація-створювач, відповідальна за контроль', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '357', 'c', 0, 1, 'Отримувачі матеріала, що мають дозвіл', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '357', 'g', 0, 0, 'Інші обмеження', '',                     3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '359', '', '', 'Ціна орендної плати (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '359', 'a', 0, 0, 'Ціна орендної плати', '',                3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '362', '', 1, 'Дати публікації чи номер тому', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '362', '6', 0, 0, 'Елемент зв’язку', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '362', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '362', 'a', 0, 0, 'Дати публ.або номер тому', '',           3, -1, 'biblioitems.volumedesc', NULL, '', NULL, '', '', NULL),
 ('', NULL, '362', 'z', 0, 0, 'Джерело відомостей', '',                 3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '363', '', 1, 'Normalized Date and Sequential Designation', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '363', '6', 0, 0, 'Linkage', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', '8', 0, 0, 'Field link and sequence number', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'a', 0, 0, 'First level of enumeration', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'b', 0, 0, 'Second level of enumeration', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'c', 0, 0, 'Third level of enumeration', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'd', 0, 0, 'Fourth level of enumeration', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'e', 0, 0, 'Fifth level of enumeration', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'f', 0, 0, 'Sixth level of enumeration', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'i', 0, 0, 'First level of chronology', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'j', 0, 0, 'Second level of chronology', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'k', 0, 0, 'Third level of chronology', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'l', 0, 0, 'Fourth level of chronology', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'm', 0, 0, 'Alternative numbering scheme, chronology', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'u', 0, 0, 'First level textual designation', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'v', 0, 0, 'First level of chronology, issuance', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'x', 0, 0, 'Nonpublic note', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '363', 'z', 0, 0, 'Public note', '',                    3, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '365', '', 1, 'Торговельна ціна', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '365', '2', 0, 0, 'Source of price type code', 'Source of price type code', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '365', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'a', 0, 0, 'Price type code', 'Price type code',       3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'b', 0, 0, 'Price amount', 'Price amount',             3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'c', 0, 0, 'Price type code', 'Price type code',       3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'd', 0, 0, 'Unit of pricing', 'Unit of pricing',       3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'e', 0, 0, 'Price note', 'Price note',                 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'f', 0, 0, 'Price effective from', 'Price effective from', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'g', 0, 0, 'Price effective until', 'Price effective until', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'h', 0, 0, 'Tax rate 1', 'Tax rate 1',                 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'i', 0, 0, 'Tax rate 2', 'Tax rate 2',                 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'j', 0, 0, 'ISO country code', 'ISO country code',     3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'k', 0, 0, 'MARC country code', 'MARC country code',   3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '365', 'm', 0, 0, 'Identification of pricing entity', 'Identification of pricing entity', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '366', '', 1, 'Інформація про наявність для придбання у видавця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '366', '2', 0, 0, 'Source of availability status code', 'Source of availability status code', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', '6', 0, 0, 'Елемент зв’язку', '',                      3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '366', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 3, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'a', 0, 0, 'Publishers compressed title identification', 'Publishers compressed title identification', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'b', 0, 0, 'Detailed date of publication', 'Detailed date of publication', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'c', 0, 0, 'Availability status code', 'Availability status code', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'd', 0, 0, 'Expected next availability date', 'Expected next availability date', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'e', 0, 0, 'Note', 'Note',                             3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'f', 0, 0, 'Publishers discount category', 'Publishers discount category', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'g', 0, 0, 'Date made out of print', 'Date made out of print', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'j', 0, 0, 'ISO country code', 'ISO country code',     3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'k', 0, 0, 'MARC country code', 'MARC country code',   3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '366', 'm', 0, 0, 'Identification of agency', 'Identification of agency', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '370', '', 1, 'Associated Place', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '370', '0', 0, 0, 'Authority record control number or standard number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', '2', 0, 0, 'Source of term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', 'c', 0, 0, 'Associated country', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', 'f', 0, 0, 'Other associated place', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', 'g', 0, 0, 'Place of origin of work', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', 's', 0, 0, 'Start period', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', 't', 0, 0, 'End period', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', 'u', 0, 0, 'Uniform Resource Identifier', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '370', 'v', 0, 0, 'Source of information', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '377', '', 1, 'Associated Language', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '377', '0', 0, 0, 'Authority record control number or standard number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '377', '2', 0, 0, 'Source', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '377', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '377', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '377', 'a', 0, 0, 'Language code', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '377', 'l', 0, 0, 'Language term', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '380', '', 1, 'Form of Work', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '380', '0', 0, 0, 'Record control number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '380', '2', 0, 0, 'Source of term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '380', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '380', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '380', 'a', 0, 0, 'Form of work', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '381', '', 1, 'Other Distinguishing Characteristics of Work or Expression', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '381', '0', 0, 0, 'Record control number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '381', '2', 0, 0, 'Source of term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '381', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '381', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '381', 'a', 0, 0, 'Other distinguishing characteristic', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '381', 'u', 0, 0, 'Uniform Resource Identifier', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '381', 'v', 0, 0, 'Source of information', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '382', '', 1, 'Medium of Performance', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '382', '0', 0, 0, 'Authority record control number or standard number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', '2', 0, 0, 'Source of term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', '3', 0, 0, 'Materials specified', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 'a', 0, 0, 'Medium of performance', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 'b', 0, 0, 'Soloist', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 'd', 0, 0, 'Doubling instrument', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 'e', 0, 0, 'Number of ensembles of the same type', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 'n', 0, 0, 'Number of performers of the same medium', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 'p', 0, 0, 'Alternative medium of performance', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 'r', 0, 0, 'Total number of individuals performing alongside ensembles', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 's', 0, 0, 'Total number of performers', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 't', 0, 0, 'Total number of ensembles', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '382', 'v', 0, 0, 'Note', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '383', '', 1, 'Numeric Designation of Musical Work', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '383', '2', 0, 0, 'Source', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '383', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '383', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '383', 'a', 0, 0, 'Serial number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '383', 'b', 0, 0, 'Opus number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '383', 'c', 0, 0, 'Thematic index number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '383', 'd', 0, 0, 'Thematic index code', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '383', 'e', 0, 0, 'Publisher associated with opus number', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '384', '', 1, 'Key', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '384', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '384', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '384', 'a', 0, 0, 'Key', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '385', '', 1, 'Audience Characteristics', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '385', '0', 0, 0, 'Authority record control number or standard number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '385', '2', 0, 0, 'Source', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '385', '3', 0, 0, 'Materials specified', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '385', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '385', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '385', 'a', 0, 0, 'Audience term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '385', 'b', 0, 0, 'Audience code', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '385', 'm', 0, 0, 'Demographic group term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '385', 'n', 0, 0, 'Demographic group code', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '386', '', 1, 'Creator/Contributor Characteristics', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '386', '0', 0, 0, 'Authority record control number or standard number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '386', '2', 0, 0, 'Source', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '386', '3', 0, 0, 'Materials specified', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '386', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '386', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '386', 'a', 0, 0, 'Creator/contributor term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '386', 'b', 0, 0, 'Creator/contributor code', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '386', 'm', 0, 0, 'Demographic group term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '386', 'n', 0, 0, 'Demographic group code', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '388', '', 1, 'Time Period of Creation', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '388', '0', 0, 0, 'Authority record control number or standard number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '388', '2', 0, 0, 'Source of term', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '388', '3', 0, 0, 'Materials specified', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '388', '6', 0, 0, 'Linkage', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '388', '8', 0, 0, 'Field link and sequence number', '', 3, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '388', 'a', 0, 0, 'Time period of creation term', '', 3, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '400', '', 1, 'Область серії / додаткова пошукова ознака — індивідуальне ім’я (застаріле, CAN/MARC), (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '400', '4', 0, 1, 'Код відношення', '',                       4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', '6', 0, 0, 'Елемент зв’язку', '',                      4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'a', 0, 0, 'Personal name', 'Personal name',           4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'b', 0, 0, 'Numeration', 'Numeration',                 4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'e', 0, 1, 'Термін відношенння (роль)', '',            4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'f', 0, 0, 'Дата публікації', '',                      4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'g', 0, 0, 'Інші відомості', '',                       4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'k', 0, 1, 'Підзаголовок форми', '',                   4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'l', 0, 0, 'Мова роботи', '',                          4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 't', 0, 0, 'Назва роботи', '',                         4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'u', 0, 0, 'Додаткові відомості', '',                  4, -6, '', '', '', 0, '', '', NULL),
 ('', '', '400', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '400', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '410', '', 1, 'Область серії / додаткова пошукова ознака — ім’я організації (застаріле, CAN/MARC), (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '410', '4', 0, 1, 'Код відношення', '',                       4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', '6', 0, 0, 'Елемент зв’язку', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',     4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'e', 0, 1, 'Термін відношенння (роль)', '',            4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'f', 0, 0, 'Дата публікації', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'g', 0, 0, 'Інші відомості', '',                       4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'k', 0, 1, 'Підзаголовок форми', '',                   4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'l', 0, 0, 'Мова роботи', '',                          4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 't', 0, 0, 'Назва роботи', '',                         4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'u', 0, 0, 'Додаткові відомості', '',                  4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '410', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '411', '', 1, 'Область серії / додаткова пошукова ознака — назва заходу (застаріле, CAN/MARC), (локальне, США)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '411', '4', 0, 1, 'Код відношення', '',                     4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', '6', 0, 0, 'Елемент зв’язку', '',                    4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'b', 0, 0, 'Number [OBSOLETE]', 'Number [OBSOLETE]', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'd', 0, 0, 'Date of meeting', 'Date of meeting',     4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit',   4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'f', 0, 0, 'Дата публікації', '',                    4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'g', 0, 0, 'Інші відомості', '',                     4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'k', 0, 1, 'Підзаголовок форми', '',                 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'l', 0, 0, 'Мова роботи', '',                        4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'p', 0, 1, 'Заголовок частини/розділу твору', '',    4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 't', 0, 0, 'Назва роботи', '',                       4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '411', 'u', 0, 0, 'Додаткові відомості', '',                4, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '411', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '411', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 4, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '440', '', 1, 'Серія', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '440', '6', 0, 0, 'Елемент зв’язку', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '440', '8', 0, 1, 'Зв’язок полів та номер послідовності', '', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', 'UNIF_TITLE', '440', 'a', 0, 0, 'Серія', '',                      4, 0, 'biblio.seriestitle', '', '', NULL, '\'440n\',\'440p\',\'490a\',\'830a\',\'830n\',\'830p\',\'899a\'', '', NULL),
 ('', '', '440', 'n', 0, 1, 'Номер частини', '',                        4, 0, 'biblioitems.number', '', '', NULL, '', '', NULL),
 ('', '', '440', 'p', 0, 1, 'Назва частини', '',                        4, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '440', 'v', 0, 0, '№ тому', '',                               4, 0, 'biblioitems.volume', '', '', NULL, '', '', NULL),
 ('', '', '440', 'x', 0, 0, 'ISSN серії', '',                           4, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '490', '', 1, 'Серія', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '490', '6', 0, 0, 'Елемент зв’язку', '',                      4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '490', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  4, -6, '', '', NULL, NULL, '', '', NULL),
 ('', '', '490', 'a', 0, 1, 'Назва серії', '',                          4, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '490', 'l', 0, 0, 'Library of Congress call number', 'Library of Congress call number', 4, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '490', 'v', 0, 1, '№ тому', '',                               4, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '490', 'x', 0, 0, 'ISSN серії', '',                           4, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '500', '', 1, 'Примітка', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '500', '3', 0, 0, 'Область застосування даних поля', '',      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '500', '5', 0, 0, 'Приналежність поля організації', '',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '500', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '500', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '500', 'a', 0, 0, 'Примітка', '',                             5, 0, 'biblio.notes', '', '', NULL, '', '', NULL),
 ('', '', '500', 'l', 0, 0, 'Library of Congress call number (SE) (застаріле)', 'Library of Congress call number (SE) [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '500', 'n', 0, 0, 'n (RLIN) (застаріле)', 'n (RLIN) [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '500', 'x', 0, 0, 'International Standard Serial Number (SE) (застаріле)', 'International Standard Serial Number (SE) [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '500', 'z', 0, 0, 'Source of note information (AM SE) (застаріле)', 'Source of note information (AM SE) [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '501', '', 1, 'Примітка ’з ...', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '501', '5', 0, 0, 'Організація, для якої застосовується поле', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '501', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '501', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '501', 'a', 0, 0, 'Примітка ’з …', '',                        5, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '502', '', 1, 'Примітка про дисертацію', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '502', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '502', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '502', 'a', 0, 0, 'Примітка про дисертацію', '',              5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '503', '', 1, 'Примітка про бібліографічну історію (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '503', '8', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '503', 'a', 0, 0, 'Примітка про бібліографічну історію', '',  5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '504', '', 1, 'Бібліографія', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '504', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '504', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '504', 'a', 0, 0, 'Бібліографія', '',                       5, 0, '', NULL, '', NULL, '', '', NULL),
 ('', NULL, '504', 'b', 0, 0, 'Number of references', 'Number of references', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '505', '', 1, 'Форматований зміст', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '505', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '505', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '505', 'a', 0, 0, 'Форматований зміст', '',                   5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '505', 'g', 0, 1, 'Інші відомості', '',                       5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '505', 'r', 0, 1, 'Statement of responsibility', 'Statement of responsibility', 5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '505', 't', 0, 1, 'Title', 'Title',                           5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '505', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, 0, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '506', '', 1, 'Примітка про обмеження доступу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '506', '2', 0, 0, 'Джерело терміну', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', '3', 0, 0, 'Область застосування даних поля', '',      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', '5', 0, 0, 'Приналежність поля організації', '',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', 'a', 0, 0, 'Terms governing access', 'Terms governing access', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', 'b', 0, 1, 'Jurisdiction', 'Jurisdiction',             5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', 'c', 0, 1, 'Physical access provisions', 'Physical access provisions', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', 'd', 0, 1, 'Authorized users', 'Authorized users',     5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', 'e', 0, 1, 'Authorization', 'Authorization',           5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', 'f', 0, 1, 'Standardized terminology for access restriction', 'Standardized terminology for access restriction', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '506', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '507', '', '', 'Примітка про масштаб для графічного матеріалу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '507', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '507', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '507', 'a', 0, 0, 'Representative fraction of scale note', 'Representative fraction of scale note', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '507', 'b', 0, 0, 'Remainder of scale note', 'Remainder of scale note', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '508', '', 1, 'Примітка про співвиконавців твору', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '508', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '508', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '508', 'a', 0, 0, 'Примітка про співвиконавців твору', '',    5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '509', '', '', 'Примітка у довільній формі', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '509', 'a', 0, 0, 'Примітка у довільній формі', '',           5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '510', '', 1, 'Примітка про посилання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '510', '3', 0, 0, 'Область застосування даних поля', '',      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '510', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '510', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '510', 'a', 0, 0, 'Примітка про посилання', '',               5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '510', 'b', 0, 0, 'Coverage of source', 'Coverage of source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '510', 'c', 0, 0, 'Location within source', 'Location within source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '510', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '511', '', 1, 'Інформація про виконавців', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '511', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '511', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '511', 'a', 0, 0, 'Інформація про виконавців', '',            5, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '512', '', 1, 'Примітка до попереднього та подальшого роздільника у каталозі (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '512', '6', 0, 0, 'Елемент зв’язку', '',                      -1, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '512', 'a', 0, 0, 'Примітка до попереднього та подальшого роздільника у каталозі', '', -1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '513', '', 1, 'Примітка про тип і хронологічний обсяг звіту', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '513', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '513', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '513', 'a', 0, 0, 'Type of report', 'Type of report',         5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '513', 'b', 0, 0, 'Period covered', 'Period covered',         5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '514', '', '', 'Примітка про якість даних', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '514', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'a', 0, 0, 'Attribute accuracy report', 'Attribute accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'b', 0, 1, 'Attribute accuracy value', 'Attribute accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'c', 0, 1, 'Attribute accuracy explanation', 'Attribute accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'd', 0, 0, 'Logical consistency report', 'Logical consistency report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'e', 0, 0, 'Completeness report', 'Completeness report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'f', 0, 0, 'Horizontal position accuracy report', 'Horizontal position accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'g', 0, 1, 'Horizontal position accuracy value', 'Horizontal position accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'h', 0, 1, 'Horizontal position accuracy explanation', 'Horizontal position accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'i', 0, 0, 'Vertical positional accuracy report', 'Vertical positional accuracy report', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'j', 0, 1, 'Vertical positional accuracy value', 'Vertical positional accuracy value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'k', 0, 1, 'Vertical positional accuracy explanation', 'Vertical positional accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'm', 0, 0, 'Cloud cover', 'Cloud cover',               5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '514', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL),
 ('', '', '514', 'z', 0, 1, 'Display note', 'Display note',             5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '515', '', 1, 'Примітка про особливості нумерації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '515', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '515', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '515', 'a', 0, 0, 'Примітка про особливості нумерації', '',   5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '515', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', -1, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '516', '', 1, 'Примітка про тип комп’ютерних файлу/даних', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '516', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '516', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '516', 'a', 0, 0, 'Примітка про тип комп’ютерних файлу/даних', '', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '517', '', '', 'Примітка про категорію фільму (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '517', 'a', 0, 0, 'Different formats', 'Different formats',   5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '517', 'b', 0, 1, 'Content descriptors', 'Content descriptors', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '517', 'c', 0, 1, 'Additional animation techniques', 'Additional animation techniques', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '518', '', 1, 'Примітка про дату/час і місце події', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '518', '3', 0, 0, 'Область застосування даних поля', '',      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '518', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '518', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '518', 'a', 0, 0, 'Date/time and place of an event note', 'Date/time and place of an event note', 5, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '520', '', 1, 'Анотація', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '520', '3', 0, 0, 'Область застосування даних поля', '',      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '520', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '520', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '520', 'a', 0, 0, 'Анотація', '',                             5, 0, 'biblio.abstract', '', '', NULL, '', '', NULL),
 ('', '', '520', 'b', 0, 0, 'Примітка, що містить розширену анотацію', '', 5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '520', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, 0, '', '', '', 1, '', '', NULL),
 ('', '', '520', 'z', 0, 0, 'Source of note information [OBSOLETE]', 'Source of note information [OBSOLETE]', 5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '521', '', 1, 'Примітка про цільове призначення', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '521', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '521', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '521', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '521', 'a', 0, 1, 'Примітка про цільове призначення', '',   5, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '521', 'b', 0, 0, 'Джерело, що визначає цільове призначення', '', 5, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '522', '', 1, 'Примітка про географічне охоплення', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '522', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '522', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '522', 'a', 0, 0, 'Примітка про географічне охоплення', '', 5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '523', '', '', 'Примітка про період часу у змісті (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '523', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '523', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '523', 'a', 0, 0, 'Примітка про період часу у змісті', '',  5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '524', '', 1, 'Примітка про форму посилання на матеріали, що описуються, якій надається перевага', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '524', '2', 0, 0, 'Source of schema used', 'Source of schema used', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '524', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '524', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '524', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '524', 'a', 0, 0, 'Примітка про форму посилання на матеріали, що описуються, якій надається перевага', '', 5, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '525', '', '', 'Примітка про додаток', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '525', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '525', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '525', 'a', 0, 0, 'Примітка про додаток', '',               5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '525', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '526', '', '', 'Інформаційна примітка про навчальну програму', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '526', '5', 0, 0, 'Приналежність поля організації', '',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '526', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '526', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '526', 'a', 0, 0, 'Program name', 'Program name',             5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '526', 'b', 0, 0, 'Interest level', 'Interest level',         5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '526', 'c', 0, 0, 'Reading level', 'Reading level',           5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '526', 'd', 0, 0, 'Title point value', 'Title point value',   5, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '526', 'i', 0, 0, 'Display text', 'Display text',             5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '526', 'x', 0, 1, 'Службова примітка', '',                    5, 6, '', '', '', NULL, '', '', NULL),
 ('', '', '526', 'z', 0, 1, 'Примітка для ЕК', '',                      5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '527', '', 1, 'Примітка про цензуру (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '527', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '527', 'a', 0, 0, 'Примітка про цензуру', '',               5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '530', '', 1, 'Примітка про додаткові форми', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '530', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '530', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '530', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '530', 'a', 0, 0, 'Примітка про додаткові форми', '',       5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '530', 'b', 0, 0, 'Availability source', 'Availability source', 5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '530', 'c', 0, 0, 'Availability conditions', 'Availability conditions', 5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '530', 'd', 0, 0, 'Order number', 'Order number',           5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '530', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -1, NULL, NULL, '', 1, '', '', NULL),
 ('', NULL, '530', 'z', 0, 0, 'Source of note information (AM CF VM SE) [OBSOLETE]', 'Source of note information (AM CF VM SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '533', '', 1, 'Примітка про копії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '533', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', '7', 0, 0, 'Fixed-length data elements of reproduction', 'Fixed-length data elements of reproduction', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', 'a', 0, 0, 'Тип копії', '',                          5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', 'b', 0, 1, 'Місце копіювання', '',                   5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', 'c', 0, 1, 'Організація, відпов. за копіюв.', '',    5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', 'd', 0, 0, 'Дата копіювання', '',                    5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', 'e', 0, 0, 'Фіз. опис копії', '',                    5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', 'f', 0, 1, 'Дані про серію', '',                     5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', 'm', 0, 1, 'Дати і поряд. познач.відтв.вип.', '',    5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '533', 'n', 0, 1, 'Примітка до копії', '',                  5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '534', '', 1, 'Примітка про оригінал', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '534', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'a', 0, 0, 'Заголовок на оригінал', '',              5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'b', 0, 0, 'Область видання', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'c', 0, 0, 'Вихідні дані оригіналу', '',             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'e', 0, 0, 'Фізичні характеристики оригіналу', '',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'f', 0, 0, 'Область серії оригіналу', '',            5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'k', 0, 1, 'Ключова назва оригіналу', '',            5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'l', 0, 0, 'Місце оригіналу', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'm', 0, 0, 'Спец.характеристики', '',                5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'n', 0, 1, 'Примітка про оригінал', '',              5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'p', 0, 0, 'Ввідні слова', '',                       5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 't', 0, 0, 'Область заголовку на оригінал', '',      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'x', 0, 1, 'ISSN', '',                               5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '534', 'z', 0, 1, 'ISBN', '',                               5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '535', '', 1, 'Приміт. про зберігання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '535', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '535', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '535', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '535', 'a', 0, 0, 'Сховище', '',                            5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '535', 'b', 0, 1, 'Поштова адреса', '',                     5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '535', 'c', 0, 1, 'Країна', '',                             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '535', 'd', 0, 1, 'Адреса телекомун.', '',                  5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '535', 'g', 0, 0, 'Код зберігання', '',                     5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '536', '', 1, 'Інформаційна примітка про фінансування', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '536', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', 'a', 0, 0, 'Text of note', 'Text of note',           5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', 'b', 0, 1, 'Contract number', 'Contract number',     5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', 'c', 0, 1, 'Grant number', 'Grant number',           5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', 'd', 0, 1, 'Undifferentiated number', 'Undifferentiated number', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', 'e', 0, 1, 'Program element number', 'Program element number', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', 'f', 0, 1, 'Project number', 'Project number',       5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', 'g', 0, 1, 'Task number', 'Task number',             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '536', 'h', 0, 1, 'Work unit number', 'Work unit number',   5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '537', '', '', 'Примітка про джерело дати (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '537', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '537', 'a', 0, 0, 'Примітка про джерело дати', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '538', '', 1, 'Примітка про системні особливості', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '538', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '538', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '538', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '538', 'a', 0, 0, 'Примітка про системні особливості', '',    5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '538', 'i', 0, 0, 'Display text', 'Display text',             5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '538', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -1, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '540', '', 1, 'Примітка про умови контролю за використанням і репродукцією', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '540', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '540', '5', 0, 0, 'Приналежність поля організації', '',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '540', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '540', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '540', 'a', 0, 0, 'Terms governing use and reproduction', 'Terms governing use and reproduction', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '540', 'b', 0, 0, 'Jurisdiction', 'Jurisdiction',             5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '540', 'c', 0, 0, 'Authorization', 'Authorization',           5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '540', 'd', 0, 0, 'Authorized users', 'Authorized users',     5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '540', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '541', '', 1, 'Примітка про безпосер. джер. компл.', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '541', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '541', '5', 0, 0, 'Приналежність поля організації', '',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '541', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '541', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'a', 0, 0, 'Отримано від/з', '',                       5, 1, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'b', 0, 0, 'Адреса', '',                               5, 1, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'c', 0, 0, 'Метод придбання', '',                      5, 1, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'd', 0, 0, 'Дата придбання', '',                       5, 1, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'e', 0, 0, 'Реєстраційний номер', '',                  5, 1, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'f', 0, 0, 'Власник', '',                              5, 1, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'h', 0, 0, 'Ціна покупки', '',                         5, 1, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'n', 0, 1, 'Кількість, обсяг', '',                     5, 1, '', '', '', NULL, '', '', NULL),
 ('', '', '541', 'o', 0, 1, 'Назва одиниці вимірювання', '',            5, 1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '542', '', 1, 'Information Relating to Copyright Status', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '542', 'a', 0, 0, 'Personal creator', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '542', 'b', 0, 0, 'Personal creator death date', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'c', 0, 0, 'Corporate creator', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'd', 0, 0, 'Copyright holder', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'e', 0, 0, 'Copyright holder contact information', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'f', 0, 0, 'Copyright statement', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'g', 0, 0, 'Copyright date', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'h', 0, 0, 'Copyright renewal date', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'i', 0, 0, 'Publication date', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'j', 0, 0, 'Creation date', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'k', 0, 0, 'Publisher', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'l', 0, 0, 'Copyright status', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'm', 0, 0, 'Publication status', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'n', 0, 0, 'Note', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'o', 0, 0, 'Research date', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'p', 0, 0, 'Country of publication or creation', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'q', 0, 0, 'Supplying agency', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'r', 0, 0, 'Jurisdiction of copyright assessment', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 's', 0, 0, 'Source of information', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', 'u', 0, 0, 'Uniform Resource Identifier', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', '3', 0, 0, 'Materials specified', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', '6', 0, 0, 'Linkage', '',    5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '542', '8', 0, 0, 'Field link and sequence number', '',    5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '543', '', 1, 'Примітка про супровідну інформацію (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '543', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '543', 'a', 0, 0, 'Примітка про супровідну інформацію', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '544', '', 1, 'Примітка про місцезнаходження інших архівних матеріалів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '544', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '544', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '544', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '544', 'a', 0, 1, 'Custodian', 'Custodian',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '544', 'b', 0, 1, 'Address', 'Address',                       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '544', 'c', 0, 1, 'Country', 'Country',                       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '544', 'd', 0, 1, 'Title', 'Title',                           5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '544', 'e', 0, 1, 'Provenance', 'Provenance',                 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '544', 'n', 0, 1, 'Note', 'Note',                             5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '545', '', 1, 'Біографічна чи історична довідка', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '545', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '545', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '545', 'a', 0, 0, 'Biographical or historical note', 'Biographical or historical note', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '545', 'b', 0, 0, 'Expansion', 'Expansion',                   5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '545', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '546', '', 1, 'Примітка про мову', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '546', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '546', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '546', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '546', 'a', 0, 0, 'Примітка про мову', '',                  5, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '546', 'b', 0, 1, 'Примітка про мову', '',                  5, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '546', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '547', '', 1, 'Довідка на попередній заголовок', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '547', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '547', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '547', 'a', 0, 0, 'Довідка на попередній заголовок', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '547', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '550', '', 1, 'Примітка про організацію, що видає', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '550', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '550', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '550', 'a', 0, 0, 'Примітка про організацію, що видає', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '550', 'z', 0, 0, 'Source of note information (SE) [OBSOLETE]', 'Source of note information (SE) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '552', '', 1, 'Інформаційна примітка про особливості та характерні ознаки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '552', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'a', 0, 0, 'Entity type label', 'Entity type label',   5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'b', 0, 0, 'Entity type definition and source', 'Entity type definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'c', 0, 0, 'Attribute label', 'Attribute label',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'd', 0, 0, 'Attribute definition and source', 'Attribute definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'e', 0, 1, 'Enumerated domain value', 'Enumerated domain value', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'f', 0, 1, 'Enumerated domain value definition and source', 'Enumerated domain value definition and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'g', 0, 0, 'Range domain minimum and maximum', 'Range domain minimum and maximum', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'h', 0, 0, 'Codeset name and source', 'Codeset name and source', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'i', 0, 0, 'Unrepresentable domain', 'Unrepresentable domain', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'j', 0, 0, 'Attribute units of measurement and resolution', 'Attribute units of measurement and resolution', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'k', 0, 0, 'Beginning date and ending date of attribute values', 'Beginning date and ending date of attribute values', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'l', 0, 0, 'Attribute value accuracy', 'Attribute value accuracy', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'm', 0, 0, 'Attribute value accuracy explanation', 'Attribute value accuracy explanation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'n', 0, 0, 'Attribute measurement frequency', 'Attribute measurement frequency', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'o', 0, 1, 'Entity and attribute overview', 'Entity and attribute overview', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'p', 0, 1, 'Entity and attribute detail citation', 'Entity and attribute detail citation', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '552', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -6, '', '', '', 1, '', '', NULL),
 ('', '', '552', 'z', 0, 1, 'Display note', 'Display note',             5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '555', '', 1, 'Примітка про кумулятивний покажчик / допоміжних покажчиках', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '555', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '555', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '555', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '555', 'a', 0, 0, 'Примітка про кумулятивний покажчик / допоміжних покажчиках', '', 5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '555', 'b', 0, 1, 'Джерело придбання', '',                  5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '555', 'c', 0, 0, 'Рівень контролю', '',                    5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '555', 'd', 0, 0, 'Бібліографічне посилання', '',           5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '555', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -1, NULL, NULL, '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '556', '', 1, 'Примітка про супровідну документацію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '556', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '556', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '556', 'a', 0, 0, 'Примітка про супровідну документацію', '', 5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '556', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '561', '', 1, 'Історія існування', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '561', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '561', '5', 0, 0, 'Приналежність поля організації', '',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '561', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '561', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '561', 'a', 0, 0, 'Історія (примітка)', '',                   5, 6, '', '', '', NULL, '', '', NULL),
 ('', '', '561', 'b', 0, 0, 'Time of collation [OBSOLETE]', 'Time of collation [OBSOLETE]', 5, 6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '562', '', 1, 'Примітка про ідентифікуючі ознаки копій чи версій архівних та рукописних матеріалів', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '562', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '562', '5', 0, 0, 'Institution to which field applies', '', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '562', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '562', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '562', 'a', 0, 1, 'Identifying markings', 'Identifying markings', 5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '562', 'b', 0, 1, 'Copy identification', 'Copy identification', 5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '562', 'c', 0, 1, 'Version identification', 'Version identification', 5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '562', 'd', 0, 1, 'Presentation format', 'Presentation format', 5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '562', 'e', 0, 1, 'Number of copies', 'Number of copies',   5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '563', '', 1, 'Інформація про оправу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '563', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '563', '5', 0, 0, 'Приналежність поля організації', '',     -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '563', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '563', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '563', 'a', 0, 0, 'Binding note', 'Binding note',           5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '563', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 5, -1, NULL, NULL, '', 1, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '565', '', 1, 'Примітка про характеристики блоків файлу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '565', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '565', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '565', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '565', 'a', 0, 0, 'Примітка про характеристики блоків файлу', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '565', 'b', 0, 1, 'Назва перемінної величини', '',          5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '565', 'c', 0, 1, 'Unit of analysis', 'Unit of analysis',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '565', 'd', 0, 1, 'Universe of data', 'Universe of data',   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '565', 'e', 0, 1, 'Filing scheme or code', 'Filing scheme or code', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '567', '', 1, 'Примітка про методологію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '567', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',     5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '567', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '567', 'a', 0, 0, 'Примітка про методологію', '',           5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '570', '', 1, 'Примітка про редактора (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '570', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '570', 'a', 0, 0, 'Примітка про редактора', '',             5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '570', 'z', 0, 0, 'Source of note information', 'Source of note information', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '580', '', 1, 'Примітка про зв’язок з іншими виданнями', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '580', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '580', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '580', 'a', 0, 0, 'Прим. про зв’язок з іншими виданнями', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '580', 'z', 0, 0, 'Source of note information (застаріле)', 'Source of note information [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '581', '', 1, 'Публікації про описуваний матеріал', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '581', '3', 0, 0, 'Область застосування даних поля', '',    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '581', '6', 0, 0, 'Елемент зв’язку', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '581', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '581', 'a', 0, 0, 'Назва публікації', '',                   5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '581', 'z', 0, 1, 'ISBN публікації', '',                    5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '582', '', 1, 'Примітка щодо пов’язаного комп’ютерного файлу (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '582', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '582', 'a', 0, 0, 'Примітка щодо пов’язаного комп’ютерного файлу', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '583', '', 1, 'Примітка про дії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '583', '2', 0, 0, 'Джерело терміну', '',                      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '583', '3', 0, 0, 'Область застосування даних поля', '',      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '583', '5', 0, 0, 'Приналежність поля організації', '',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '583', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '583', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'a', 0, 0, 'Дія', '',                                  5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'b', 0, 1, 'Ідентифікація дії', '',                    5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'c', 0, 1, 'Дата і час дії', '',                       5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'd', 0, 1, 'Період часу дії', '',                      5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'e', 0, 1, 'Умови під час дії', '',                    5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'f', 0, 1, 'Правила дії', '',                          5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'h', 0, 1, 'Відповідальна особа', '',                  5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'i', 0, 1, 'Метод виконання', '',                      5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'j', 0, 1, 'Місце дії', '',                            5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'k', 0, 1, 'Виконавець дії', '',                       5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'l', 0, 1, 'Стан матеріалу', '',                       5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'n', 0, 1, 'Кількість, обсяг', '',                     5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'o', 0, 1, 'Одиниці виміру', '',                       5, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'u', 0, 1, 'Уніфік. ідентифікатор ресурсу', '',        5, -1, '', '', '', 1, '', '', NULL),
 ('', '', '583', 'x', 0, 1, 'Службова примітка', '',                    5, 4, '', '', '', NULL, '', '', NULL),
 ('', '', '583', 'z', 0, 1, 'Відкрита примітка', '',                    5, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '584', '', 1, 'Примітка про акумуляцію та частоту використання', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '584', '3', 0, 0, 'Область застосування даних поля', '',      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '584', '5', 0, 0, 'Приналежність поля організації', '',       5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '584', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '584', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '584', 'a', 0, 1, 'Accumulation', 'Accumulation',             5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '584', 'b', 0, 1, 'Frequency of use', 'Frequency of use',     5, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '585', '', 1, 'Примітка про виставки', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '585', '3', 0, 0, 'Область застосування даних поля', '',      5, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '585', '5', -6, 0, 'Приналежність поля організації', '',      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '585', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '585', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '585', 'a', 0, 0, 'Примітка про виставки', '',                5, -1, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '586', '', 1, 'Примітка про нагороди', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '586', '3', 0, 0, 'Область застосування даних поля', '',      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '586', '6', 0, 0, 'Елемент зв’язку', '',                      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '586', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '586', 'a', 0, 0, 'Примітка про нагороди', '',                5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '588', '', 1, 'Source of Description Note', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '588', '5', 0, 0, 'Institution to which field applies', '',      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '588', '6', 0, 0, 'Linkage', '',                      5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '588', '8', 0, 1, 'Field link and sequence number', '', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '588', 'a', 0, 0, 'Source of description note', '',                5, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '590', '', 1, 'Примітка про автограф і колекцію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '590', '6', 0, 0, 'Елемент зв’язку (RLIN)', '',               5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '590', '8', 0, 1, 'Field link and sequence number (RLIN)', 'Field link and sequence number (RLIN)', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '590', 'a', 0, 0, 'Local note', 'Local note',                 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '590', 'b', 0, 0, 'Provenance (VM) [OBSOLETE]', 'Provenance (VM) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '590', 'c', 0, 0, 'Condition of individual reels (VM) [OBSOLETE]', 'Condition of individual reels (VM) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '590', 'd', 0, 0, 'Origin of safety copy (VM) (застаріло)', 'Origin of safety copy (VM) [OBSOLETE]', 5, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '600', '', 1, 'Персоналії', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '600', '2', 0, 0, 'Джерело рубрики', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '600', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', '4', 0, 1, 'Код відношення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'PERSO_NAME', '600', 'a', 0, 0, 'Персоналії', '',                 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'b', 0, 0, 'Нумерація', '',                            6, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'c', 0, 1, 'Титули', '',                               6, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'd', 0, 0, 'Дати життя', '',                           6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'e', 0, 1, 'Роль осіб', '',                            6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'f', 0, 0, 'Дата публікації', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'g', 0, 0, 'Інші відомості', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'h', 0, 0, 'Фізичний носій', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'j', 0, 1, 'Приналежність невідомого автора до послідовників, школи і т. ін.', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'k', 0, 1, 'Форма, вид, жанр', '',                     6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'l', 0, 0, 'Мова твору', '',                           6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'm', 0, 1, 'Засіб виконання музичного твору', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'n', 0, 1, 'Позначення і номер частини/розділу твору', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'o', 0, 0, 'Позначення аранжування', '',               6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'q', 0, 0, 'Більш повна форма імені', '',              6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'r', 0, 0, 'Тональність', '',                          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 's', 0, 0, 'Версія, видання', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 't', 0, 0, 'Назва твору', '',                          6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'u', 0, 0, 'Місце роботи, членство або адреса особи', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'v', 0, 1, 'Типове ділення', '',                       6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'x', 0, 1, 'Основне ділення', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'y', 0, 1, 'Хронологічне ділення', '',                 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '600', 'z', 0, 1, 'Географічне ділення', '',                  6, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '610', '', 1, 'Назва колективу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '610', '2', 0, 0, 'Джерело рубрики', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '610', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', '4', 0, 1, 'Код відношення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'CORPO_NAME', '610', 'a', 0, 0, 'Назва колективу', '',            6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'b', 0, 1, 'Структурний підрозділ', '',                6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'c', 0, 0, 'Місце проведення заходу', '',              6, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'd', 0, 1, 'Дата проведення заходу', '',               6, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'e', 0, 1, 'Роль колективу', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'f', 0, 0, 'Дата публікації', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'g', 0, 0, 'Інші відомості', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'h', 0, 0, 'Фізичний носій', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'k', 0, 1, 'Форма, вид, жанр', '',                     6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'l', 0, 0, 'Мова твору', '',                           6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'm', 0, 1, 'Засіб виконання музичного твору', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'n', 0, 1, 'Номер частини', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'o', 0, 0, 'Позначення аранжування', '',               6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'p', 0, 1, 'Назва частини', '',                        6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'r', 0, 0, 'Тональність', '',                          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 's', 0, 0, 'Версія, видання', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 't', 0, 0, 'Назва твору', '',                          6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'u', 0, 0, 'Місце роботи, членство або адреса особи', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'v', 0, 1, 'Типове ділення', '',                       6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'x', 0, 1, 'Основне ділення', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'y', 0, 1, 'Хронологічне ділення', '',                 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '610', 'z', 0, 1, 'Географічне ділення', '',                  6, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '611', '', 1, 'Назва заходу/тимчасового колективу/установи як дод. предметна пошукова ознака', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '611', '2', 0, 0, 'Джерело рубрики або терміну', '',        6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', '3', 0, 0, 'Область застосування даних поля', '',    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', '4', 0, 1, 'Код відношення', '',                     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', '6', 0, 0, 'Елемент зв’язку', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', '8', 0, 1, 'Зв’язок полів і номер послідовності', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'MEETI_NAME', '611', 'a', 0, 0, 'Назва заходу як початковий елемент вводу', '', 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'b', 0, 1, 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'c', 0, 0, 'Місце проведення заходу', '',            6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'd', 0, 0, 'Дата проведення заходу', '',             6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'e', 0, 0, 'Структурний підрозділ (підпорядк. одиниця)', '', 6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'f', 0, 0, 'Дата публікації', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'g', 0, 0, 'Інша інформація', '',                    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'h', 0, 0, 'Фізичний носій (позначення матеріалу)', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'j', 0, 1, 'Термін відношенння (роль)', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'k', 0, 1, 'Форма, вид, жанр і т. ін. твору', '',    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'l', 0, 0, 'Мова твору', '',                         6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'n', 0, 1, 'Позначення і номер частини/секції/заходу', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'p', 0, 1, 'Заголовок частини/розділу твору', '',    6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 's', 0, 0, 'Версія, видання і т. ін.', '',           6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 't', 0, 0, 'Назва твору', '',                        6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'u', 0, 0, 'Місцезнаходження або адреса', '',        6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'v', 0, 1, 'Типове ділення', '',                     6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'x', 0, 1, 'Основне ділення', '',                    6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'y', 0, 1, 'Хронологічне ділення', '',               6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '611', 'z', 0, 1, 'Географічне ділення', '',                6, -1, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '630', '', 1, 'Уніфікований заголовок (додатковий предм. запис)', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '630', '2', 0, 0, 'Джерело рубрики', '',                      6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', '4', 0, 1, 'Код відношення', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'UNIF_TITLE', '630', 'a', 0, 0, 'Уніфікований заголовок', '',     6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'd', 0, 1, 'Дата підписання договору', '',             6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'e', 0, 1, 'Термін відношенння (роль)', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '630', 'f', 0, 0, 'Дата публікації', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'g', 0, 0, 'Інші відомості', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'h', 0, 0, 'Фізичний носій', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'k', 0, 1, 'Форма, вид, жанр', '',                     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'l', 0, 0, 'Мова твору', '',                           6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'm', 0, 1, 'Засіб виконання музичного твору', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'n', 0, 1, 'Номер частини/розділу', '',                6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'o', 0, 0, 'Позначення аранжування', '',               6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'p', 0, 1, 'Назва частини/розділу', '',                6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'r', 0, 0, 'Тональность', '',                          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 's', 0, 0, 'Версія, видання', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 't', 0, 0, 'Назва твору', '',                          6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'v', 0, 1, 'Типове ділення', '',                       6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'x', 0, 1, 'Основне ділення', '',                      6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'y', 0, 1, 'Хронологічне ділення', '',                 6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '630', 'z', 0, 1, 'Географічне ділення', '',                  6, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '647', '', 1, 'Subject Added Entry-Named Event', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '647', '0', 0, 0, 'Authority record control number or standard number', '',                      6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', '2', 0, 0, 'Source of heading or term', '',                      6, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', '3', 0, 0, 'Materials specified', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', '6', 0, 0, 'Linkage', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', '8', 0, 1, 'Field link and sequence number', '',  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', 'a', 0, 0, 'Named event', '',               6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', 'c', 0, 0, 'Location of named event', '',               6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', 'd', 0, 1, 'Date of named event', '',             6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', 'g', 0, 0, 'Miscellaneous information', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', 'v', 0, 1, 'Form subdivision', '',                       6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', 'x', 0, 1, 'General subdivision', '',                      6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', 'y', 0, 1, 'Chronological subdivision', '',                 6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '647', 'z', 0, 1, 'Geographic subdivision', '',                  6, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '648', '', 1, 'Хронологічне поняття як додаткова предметна пошукова ознака', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '648', '2', 0, 0, 'Джерело рубрики чи терміну', '',           6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '648', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '648', '6', 0, 0, 'Зв’язок', '',                              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '648', '8', 0, 1, 'Зв’язок поля і його порядковий номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'CHRON_TERM', '648', 'a', 0, 0, 'Хронологічне поняття', '',       6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '648', 'v', 0, 1, 'Типове ділення', '',                       6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '648', 'x', 0, 1, 'Основне ділення', '',                      6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '648', 'y', 0, 1, 'Хронологічне ділення', '',                 6, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '648', 'z', 0, 1, 'Географічне ділення', '',                  6, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '650', '', 1, 'Тематичні рубрики', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '650', '2', 0, 0, 'Джерело рубрики', '',                      6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '650', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '650', '4', 0, 1, 'Код відношення', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '650', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '650', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  6, -6, '', '', '', 0, '', '', NULL),
 ('', 'TOPIC_TERM', '650', 'a', 0, 0, 'Основна рубрика', '',            6, 0, 'bibliosubject.subject', '', '', 0, '\'6003\',\'600a\',\'600b\',\'600c\',\'600d\',\'600e\',\'600f\',\'600g\',\'600h\',\'600k\',\'600l\',\'600m\',\'600n\',\'600o\',
 \'600p\',\'600r\',\'600s\',\'600t\',\'600u\',\'600x\',\'600z\',\'600y\',\'600v\',\'6103\',\'610a\',\'610b\',\'610c\',\'610d\',\'610e\',\'610f\',\'610g\',\'610h\',\'610k\',\'610l\',\'610m\',\'610n\',\'610o\',\'610p\',\'610r\',\'610s\',\'610t\',
 \'610u\',\'610x\',\'610z\',\'610y\',\'610v\',\'6113\',\'611a\',\'611b\',\'611c\',\'611d\',\'611e\',\'611f\',\'611g\',\'611h\',\'611k\',\'611l\',\'611m\',\'611n\',\'611o\',\'611p\',\'611r\',\'611s\',\'611t\',\'611u\',\'611x\',\'611z\',\'611y\',
 \'611v\',\'630a\',\'630b\',\'630c\',\'630d\',\'630e\',\'630f\',\'630g\',\'630h\',\'630k\',\'630l\',\'630m\',\'630n\',\'630o\',\'630p\',\'630r\',\'630s\',\'630t\',\'630x\',\'630z\',\'630y\',\'630v\',\'6483\',\'648a\',\'648x\',\'648z\',\'648y\',
 \'648v\',\'6503\',\'650b\',\'650c\',\'650d\',\'650e\',\'650x\',\'650z\',\'650y\',\'650v\',\'6513\',\'651a\',\'651b\',\'651c\',\'651d\',\'651e\',\'651x\',\'651z\',\'651y\',\'651v\',\'653a\',\'6543\',\'654a\',\'654b\',\'654x\',\'654z\',\'654y\',
 \'654v\',\'6553\',\'655a\',\'655b\',\'655x\',\'655z\',\'655y\',\'655v\',\'6563\',\'656a\',\'656k\',\'656x\',\'656z\',\'656y\',\'656v\',\'6573\',\'657a\',\'657x\',\'657z\',\'657y\',\'657v\',\'658a\',\'658b\',\'658c\',\'658d\',\'658v\'', '', NULL),
 ('', '', '650', 'b', 0, 0, 'Ін. геогр. рубрика', '',                   6, -1, '', '', '', 0, '', '', NULL),
 ('', '', '650', 'c', 0, 0, 'Місце події', '',                          6, -1, '', '', '', 0, '', '', NULL),
 ('', '', '650', 'd', 0, 0, 'Дати події', '',                           6, -1, '', '', '', 0, '', '', NULL),
 ('', '', '650', 'e', 0, 0, 'Термін відношення (роль)', '',             6, -1, '', '', '', 0, '', '', NULL),
 ('', '', '650', 'v', 0, 1, 'Типове ділення', '',                       6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '650', 'x', 0, 1, 'Основна підрубрика', '',                   6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '650', 'y', 0, 1, 'Хронологічна підрубрика', '',              6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '650', 'z', 0, 1, 'Географічна підрубрика', '',               6, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '651', '', 1, 'Додаткове предметне введення — географічна назва', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '651', '2', 0, 0, 'Код системи', '',                          6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '651', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '651', '4', 0, 1, 'Код відношення', '',                       6, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '651', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '651', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  6, -6, '', '', '', 0, NULL, '', ''),
 ('', 'GEOGR_NAME', '651', 'a', 0, 0, 'Географічна назва', '',          6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '651', 'b', 0, 1, 'Geographic name following place entry element (застаріло)', 'Geographic name following place entry element [OBSOLETE]', 6, -6, '', '', '', 0, NULL, '', ''),
 ('', '', '651', 'e', 0, 1, 'Роль, відношення', '',                     6, -1, '', '', '', 0, NULL, '', ''),
 ('', '', '651', 'v', 0, 1, 'Типове ділення', '',                       6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '651', 'x', 0, 1, 'Основні підзаголовки', '',                 6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '651', 'y', 0, 1, 'Хронологогічний підзаголовок', '',         6, 0, '', '', '', 0, NULL, '', ''),
 ('', '', '651', 'z', 0, 1, 'Географічний підзаголовок', '',            6, 0, '', '', '', 0, NULL, '', '');

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '652', '', 1, 'Додаткова предметна пошукова ознака — анульована географічна (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '652', 'a', 0, 0, 'Geographic name of place element', 'Geographic name of place element', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '652', 'x', 0, 1, 'Основне ділення', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '652', 'y', 0, 1, 'Хронологічне ділення', '',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '652', 'z', 0, 1, 'Географічне діленння', '',                 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '653', '', 1, 'Ключові слова', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '653', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '653', '8', 0, 1, 'Зв’язок полів і номер послідовності', '',  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '653', 'a', 0, 1, 'Ключові слова', '',                        6, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '654', '', 1, 'Додаткове предметне введення — фасетні тематичні терміни', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '654', '2', 0, 0, 'Джерело терміну', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '654', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '654', '4', 0, 1, 'Код відношення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '654', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '654', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'TOPIC_TERM', '654', 'a', 0, 1, 'Focus term', 'Focus term',       6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '654', 'b', 0, 1, 'Non-focus term', 'Non-focus term',         6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '654', 'c', 0, 1, 'Facet/hierarchy designation', 'Facet/hierarchy designation', 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '654', 'e', 0, 1, 'Термін відношенння (роль)', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '654', 'v', 0, 1, 'Типове ділення', '',                       6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '654', 'x', 0, 1, 'Основне ділення', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '654', 'y', 0, 1, 'Хронологічне ділення', '',                 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '654', 'z', 0, 1, 'Географічне діленння', '',                 6, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '655', '', 1, 'Термін індексування — жанр/форма', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '655', '2', 0, 0, 'Джерело терміну', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '655', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '655', '5', 0, 0, 'Приналежність поля організації', '',       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '655', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '655', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'GENRE/FORM', '655', 'a', 0, 0, 'Жанр/форма', '',                 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '655', 'b', 0, 1, 'Non-focus term', 'Non-focus term',         6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '655', 'c', 0, 1, 'Facet/hierarchy designation', 'Facet/hierarchy designation', 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '655', 'v', 0, 1, 'Типове ділення', '',                       6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '655', 'x', 0, 1, 'Основне ділення', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '655', 'y', 0, 1, 'Хронологічне ділення', '',                 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '655', 'z', 0, 1, 'Географічне діленння', '',                 6, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '656', '', 1, 'Термін індексування — професія', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '656', '2', 0, 0, 'Джерело терміну', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '656', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '656', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '656', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'TOPIC_TERM', '656', 'a', 0, 0, 'Occupation', 'Occupation',       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '656', 'k', 0, 0, 'Форма, вид, жанр', '',                     6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '656', 'v', 0, 1, 'Типове ділення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '656', 'x', 0, 1, 'Основне ділення', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '656', 'y', 0, 1, 'Хронологічне ділення', '',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '656', 'z', 0, 1, 'Географічне діленння', '',                 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '657', '', 1, 'Термін індексування — функція', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '657', '2', 0, 0, 'Джерело терміну', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '657', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '657', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '657', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'TOPIC_TERM', '657', 'a', 0, 0, 'Function', 'Function',           6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '657', 'v', 0, 1, 'Типове ділення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '657', 'x', 0, 1, 'Основне ділення', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '657', 'y', 0, 1, 'Хронологічне ділення', '',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '657', 'z', 0, 1, 'Географічне діленння', '',                 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '658', '', 1, 'Термін індексування — завдання навчального курсу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '658', '2', 0, 0, 'Джерело терміну', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '658', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '658', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'TOPIC_TERM', '658', 'a', 0, 0, 'Main curriculum objective', 'Main curriculum objective', 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '658', 'b', 0, 1, 'Subordinate curriculum objective', 'Subordinate curriculum objective', 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '658', 'c', 0, 0, 'Curriculum code', 'Curriculum code',       6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '658', 'd', 0, 0, 'Correlation factor', 'Correlation factor', 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '662', '', 1, 'Додаткове предметне введення — ієрархічна назва місця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '662', '2', 0, 0, 'Джерело терміну', '',                      6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '662', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '662', '4', 0, 1, 'Код відношення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '662', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '662', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'GEOGR_NAME', '662', 'a', 0, 1, 'Country or larger entity', 'Country or larger entity', 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '662', 'b', 0, 0, 'First-order political jurisdiction', 'First-order political jurisdiction', 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '662', 'c', 0, 1, 'Intermediate political jurisdiction', 'Intermediate political jurisdiction', 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '662', 'd', 0, 0, 'City', 'City',                             6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '662', 'e', 0, 1, 'Термін відношенння (роль)', '',            6, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '662', 'f', 0, 1, 'City subsection', 'City subsection',       6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '662', 'g', 0, 1, 'Other nonjurisdictional geographic region and feature', 'Other nonjurisdictional geographic region and feature', 6, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '662', 'h', 0, 1, 'Extraterrestrial area', 'Extraterrestrial area', 6, 0, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '690', '', 1, 'Локальна додаткова предметна пошукова ознака — тематичне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '690', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '690', '2', 0, 0, 'Джерело рубрики або терміну', '',          6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '690', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '690', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '690', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', 0, '', '', NULL),
 ('', 'TOPIC_TERM', '690', 'a', 0, 0, 'Topical term or geographic name as entry element', 'Topical term or geographic name as entry element', 6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '690', 'b', 0, 0, 'Topical term following geographic name as entry element', 'Topical term following geographic name as entry element', 6, -1, '', '', '', 0, '', '', NULL),
 ('', '', '690', 'c', 0, 0, 'Location of event', 'Location of event',   6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '690', 'd', 0, 0, 'Active dates', 'Active dates',             6, -1, '', '', '', 0, '', '', NULL),
 ('', '', '690', 'e', 0, 0, 'Термін відношенння (роль)', '',            6, -1, '', '', '', 0, '', '', NULL),
 ('', '', '690', 'v', 0, 1, 'Типове ділення', '',                       6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '690', 'x', 0, 1, 'Основне ділення', '',                      6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '690', 'y', 0, 1, 'Хронологічне ділення', '',                 6, 0, '', '', '', 0, '', '', NULL),
 ('', '', '690', 'z', 0, 1, 'Географічне діленння', '',                 6, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '691', '', 1, 'Локальна додаткова предметна пошукова ознака — географічне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '691', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '691', '2', 0, 0, 'Джерело рубрики або терміну', '',          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '691', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '691', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '691', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'GEOGR_NAME', '691', 'a', 0, 0, 'Geographic name', 'Geographic name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '691', 'b', 0, 1, 'Geographic name following place entry element (застаріло)', 'Geographic name following place entry element [OBSOLETE]', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '691', 'v', 0, 1, 'Типове ділення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '691', 'x', 0, 1, 'Основне ділення', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '691', 'y', 0, 1, 'Хронологічне ділення', '',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '691', 'z', 0, 1, 'Географічне діленння', '',                 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '696', '', 1, 'Локальна додаткова предметна пошукова ознака — власне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '696', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '696', '2', 0, 0, 'Джерело рубрики або терміну', '',          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', '4', 0, 1, 'Код відношення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'PERSO_NAME', '696', 'a', 0, 0, 'Personal name', 'Personal name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'b', 0, 0, 'Numeration', 'Numeration',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'e', 0, 1, 'Термін відношенння (роль)', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'f', 0, 0, 'Дата публікації', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'g', 0, 0, 'Інші відомості', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'h', 0, 0, 'Фізичний носій', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'k', 0, 1, 'Підзаголовок форми', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'l', 0, 0, 'Мова роботи', '',                          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'm', 0, 1, 'Засіб виконання музичного твору', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'o', 0, 0, 'Позначення аранжування', '',               6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'r', 0, 0, 'Тональність', '',                          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 's', 0, 0, 'Версія, видання і т. д.', '',              6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 't', 0, 0, 'Назва роботи', '',                         6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'u', 0, 0, 'Додаткові відомості', '',                  6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'v', 0, 1, 'Типове ділення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'x', 0, 1, 'Основне ділення', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'y', 0, 1, 'Хронологічне ділення', '',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '696', 'z', 0, 1, 'Географічне діленння', '',                 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '697', '', 1, 'Локальна додаткова предметна пошукова ознака — ім’я організації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '697', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '697', '2', 0, 0, 'Джерело рубрики або терміну', '',          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', '4', 0, 1, 'Код відношення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', 'CORPO_NAME', '697', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',     6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'e', 0, 1, 'Термін відношенння (роль)', '',            6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'f', 0, 0, 'Дата публікації', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'g', 0, 0, 'Інші відомості', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'h', 0, 0, 'Фізичний носій', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'k', 0, 1, 'Підзаголовок форми', '',                   6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'l', 0, 0, 'Мова роботи', '',                          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'm', 0, 1, 'Засіб виконання музичного твору', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'o', 0, 0, 'Позначення аранжування', '',               6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'r', 0, 0, 'Тональність', '',                          6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 's', 0, 0, 'Версія, видання і т. д.', '',              6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 't', 0, 0, 'Назва роботи', '',                         6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'u', 0, 0, 'Додаткові відомості', '',                  6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'v', 0, 1, 'Типове ділення', '',                       6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'x', 0, 1, 'Основне ділення', '',                      6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'y', 0, 1, 'Хронологічне ділення', '',                 6, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '697', 'z', 0, 1, 'Географічне діленння', '',                 6, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '698', '', 1, 'Локальна додаткова предметна пошукова ознака — назва заходу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '698', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '698', '2', 0, 0, 'Джерело рубрики або терміну', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', '4', 0, 1, 'Код відношення', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'MEETI_NAME', '698', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'b', 0, 1, 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', 'Number  (BK CF MP MU SE VM MX)  [OBSOLETE]', -1, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'd', 0, 0, 'Date of meeting', 'Date of meeting',       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit',     6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'f', 0, 0, 'Дата публікації', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'g', 0, 0, 'Інші відомості', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'h', 0, 0, 'Фізичний носій', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'k', 0, 1, 'Підзаголовок форми', '',                   6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'l', 0, 0, 'Мова роботи', '',                          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 's', 0, 0, 'Версія, видання і т. д.', '',              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 't', 0, 0, 'Назва роботи', '',                         6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'u', 0, 0, 'Додаткові відомості', '',                  6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'v', 0, 1, 'Типове ділення', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'x', 0, 1, 'Основне ділення', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'y', 0, 1, 'Хронологічне ділення', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '698', 'z', 0, 1, 'Географічне діленння', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '699', '', 1, 'Локальна додаткова предметна пошукова ознака — уніфікований заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '699', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     6, -6, '', '', '', 0, '', '', NULL),
 ('', '', '699', '2', 0, 0, 'Джерело рубрики або терміну', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', '3', 0, 0, 'Область застосування даних поля', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', '6', 0, 0, 'Елемент зв’язку', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'UNIF_TITLE', '699', 'a', 0, 0, 'Уніфікована назва', '',          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'd', 0, 1, 'Дата підписання договору', '',             6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'f', 0, 0, 'Дата публікації', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'g', 0, 0, 'Інші відомості', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'h', 0, 0, 'Фізичний носій', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'k', 0, 1, 'Підзаголовок форми', '',                   6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'l', 0, 0, 'Мова роботи', '',                          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'm', 0, 1, 'Засіб виконання музичного твору', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'o', 0, 0, 'Позначення аранжування', '',               6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'r', 0, 0, 'Тональність', '',                          6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 's', 0, 0, 'Версія, видання і т. д.', '',              6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 't', 0, 0, 'Назва роботи', '',                         6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'v', 0, 1, 'Типове ділення', '',                       6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'x', 0, 1, 'Основне ділення', '',                      6, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '699', 'y', 0, 1, 'Хронологічне ділення', '',                 6, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '700', '', 1, 'Інші автори', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '700', '3', 0, 0, 'Область застосування даних поля', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', '4', 0, 1, 'Код відношення', '',                       7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '700', '5', 0, 0, 'Приналежність поля організації', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', 'PERSO_NAME', '700', 'a', 0, 0, 'Інші автори', '',                7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'b', 0, 0, 'Династичний номер', '',                    7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'c', 0, 1, 'Титул (звання)', '',                       7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'd', 0, 0, 'Дата', '',                                 7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'e', 0, 1, 'Роль осіб', '',                            7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'f', 0, 0, 'Дата публікації', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'g', 0, 0, 'Інші відомості', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'k', 0, 1, 'Підзаголовок форми', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'l', 0, 0, 'Мова роботи', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'm', 0, 1, 'Засіб виконання музичного твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'o', 0, 0, 'Позначення аранжування', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'q', 0, 0, 'Повне ім’я', '',                           7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'r', 0, 0, 'Тональність', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 's', 0, 0, 'Версія, видання і т. д.', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 't', 0, 0, 'Назва твору', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'u', 0, 0, 'Доповнення', '',                           7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '700', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '705', '', 1, 'Додаткова пошукова ознака — індивідуальне ім’я (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '705', 'a', 0, 0, 'Personal name', 'Personal name',           7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'b', 0, 0, 'Numeration', 'Numeration',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'e', 0, 1, 'Термін відношенння (роль)', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'f', 0, 0, 'Дата публікації', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'g', 0, 0, 'Інші відомості', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'k', 0, 1, 'Підзаголовок форми', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'l', 0, 0, 'Мова роботи', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'm', 0, 1, 'Засіб виконання музичного твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'o', 0, 0, 'Позначення аранжування', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 'r', 0, 0, 'Тональність', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 's', 0, 0, 'Версія, видання і т. д.', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '705', 't', 0, 0, 'Назва роботи', '',                         7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '710', '', 1, 'Інші організації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '710', '3', 0, 0, 'Область застосування даних поля', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', '4', 0, 1, 'Код відношення', '',                       7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '710', '5', 0, 0, 'Приналежність поля організації', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', 'CORPO_NAME', '710', 'a', 0, 0, 'Організ./юрисдикція', '',        7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'b', 0, 1, 'Інші рівні', '',                           7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'c', 0, 0, 'Місце', '',                                7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'd', 0, 1, 'Дата', '',                                 7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'e', 0, 1, 'Роль колективу', '',                       7, 0, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'f', 0, 0, 'Дата публікації', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'g', 0, 0, 'Інша інформація', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'k', 0, 1, 'Підзаголовок форми', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'l', 0, 0, 'Мова роботи', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'm', 0, 1, 'Засіб виконання музичного твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'n', 0, 1, 'Номер', '',                                7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'o', 0, 0, 'Позначення аранжування', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'r', 0, 0, 'Тональність', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 's', 0, 0, 'Версія, видання і т. д.', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 't', 0, 0, 'Назва твору', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'u', 0, 0, 'Додаткові відомості', '',                  7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '710', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '711', '', 1, 'Інші заходи', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '711', '3', 0, 0, 'Область застосування даних поля', '',    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', '4', 0, 1, 'Код відношення', '',                     7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', '5', 0, 0, 'Приналежність поля організації', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', '6', 0, 0, 'Елемент зв’язку', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'MEETI_NAME', '711', 'a', 0, 0, 'Назва заходу', '',               7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'c', 0, 0, 'Місце заходу', '',                       7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'd', 0, 0, 'Дата заходу', '',                        7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'e', 0, 1, 'Підпорядк. одиниця', '',                 7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'f', 0, 0, 'Дата роботи', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'g', 0, 0, 'Інші відомості', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'h', 0, 0, 'Фізичний носій', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'j', 0, 1, 'Термін відношенння (роль)', '',          7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'k', 0, 1, 'Підзаголовок форми', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'l', 0, 0, 'Мова роботи', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'n', 0, 1, '№ частини/секції', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'p', 0, 1, '№ частини/розділу', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 's', 0, 0, 'Версія, видання і т. д.', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 't', 0, 0, 'Назва роботи', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'u', 0, 0, 'Додаткові відомості', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '711', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '715', '', 1, 'Додаткова пошукова ознака — ім’я організації (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '715', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     7, -6, '', '', '', 0, '', '', NULL),
 ('', '', '715', 'a', 0, 0, 'Corporate name or jurisdiction name', 'Corporate name or jurisdiction name', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'b', 0, 0, 'Subordinate unit', 'Subordinate unit',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'e', 0, 1, 'Термін відношенння (роль)', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'f', 0, 0, 'Дата публікації', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'g', 0, 0, 'Інші відомості', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'k', 0, 1, 'Підзаголовок форми', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'l', 0, 0, 'Мова роботи', '',                          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'r', 0, 0, 'Тональність', '',                          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 's', 0, 0, 'Версія, видання і т. д.', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 't', 0, 0, 'Назва роботи', '',                         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '715', 'u', 0, 0, 'Nonprinting information', 'Nonprinting information', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '720', '', 1, 'Додаткове введення — неконтрольоване ім’я/найменування', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '720', '4', 0, 1, 'Код відношення', '',                       7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '720', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '720', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '720', 'a', 0, 0, 'Name', 'Name',                             7, 0, '', NULL, '', NULL, '', '', NULL),
 ('', '', '720', 'e', 0, 1, 'Термін відношенння (роль)', '',            7, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '730', '', 1, 'Уніфікована назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '730', '3', 0, 0, 'Область застосування даних поля', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', '5', 0, 0, 'Приналежність поля організації', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', 'UNIF_TITLE', '730', 'a', 0, 0, 'Уніфікована назва', '',          7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'd', 0, 1, 'Дата підписання договору', '',             7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'f', 0, 0, 'Дата публікації', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'g', 0, 0, 'Інші відомості', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'k', 0, 1, 'Форма, вид, жанр', '',                     7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'l', 0, 0, 'Мова програмування', '',                   7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'm', 0, 1, 'Засіб виконання музичного твору', '',      7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'n', 0, 1, 'Номер частини твору', '',                  7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'o', 0, 0, 'Позначення аранжування', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'p', 0, 1, 'Назва частини/розділу', '',                7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'r', 0, 0, 'Тональність', '',                          7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 's', 0, 0, 'Версія, видання', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 't', 0, 0, 'Назва роботи', '',                         7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '730', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '740', '', 1, 'Зв’язана/аналіт. назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '740', '5', 0, 0, 'Приналежність поля організації', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '740', '6', 0, 0, 'Елемент зв’язку', 'Елемент зв’язку',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '740', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '740', 'a', 0, 0, 'Зв’язана/аналіт. назва', '',               7, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '740', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '740', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '740', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '751', '', 1, 'Added Entry-Geographic Name', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '751', '0', 0, 0, 'Authority record control number', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '751', '2', 0, 0, 'Source of heading or term', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '751', '3', 0, 0, 'Materials specified', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '751', '4', 0, 0, 'Relator code', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '751', '6', 0, 0, 'Linkage', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '751', '8', 0, 0, 'Field link and sequence number', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '751', 'a', 0, 0, 'Geographic name', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '751', 'e', 0, 0, 'Relator term', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '752', '', 1, 'Додаткове введення — ієрархічна назва місця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '752', '2', 0, 0, 'Джерело рубрики або терміну', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', 'a', 0, 0, 'Country or larger entity', 'Country or larger entity', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', 'b', 0, 0, 'First-order political jurisdiction', 'First-order political jurisdiction', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', 'c', 0, 1, 'Intermediate political jurisdiction', 'Intermediate political jurisdiction', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', 'd', 0, 0, 'City', 'City',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', 'f', 0, 1, 'City subsection', 'City subsection',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', 'g', 0, 1, 'Other nonjurisdictional geographic region and feature', 'Other nonjurisdictional geographic region and feature', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '752', 'h', 0, 1, 'Extraterrestrial area', 'Extraterrestrial area', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '753', '', 1, 'Системні характеристики доступу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '753', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '753', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '753', 'a', 0, 0, 'Марка і модель машини', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '753', 'b', 0, 0, 'Мова програмування', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '753', 'c', 0, 0, 'Операційна система', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '754', '', 1, 'Додаткове введення — таксономічна ідентифікація', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '754', '2', 0, 0, 'Source of taxonomic identification', 'Source of taxonomic identification', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '754', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '754', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '754', 'a', 0, 1, 'Taxonomic name', 'Taxonomic name',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '754', 'c', 0, 1, 'Taxonomic category', 'Taxonomic category', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '754', 'd', 0, 1, 'Common or alternative name', 'Common or alternative name', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '754', 'x', 0, 1, 'Non-public note', 'Non-public note',       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '754', 'z', 0, 1, 'Примітка для ЕК', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '755', '', 1, 'Додаткова пошукова ознака — фізичні характеристики (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '755', '2', 0, 0, 'Source of taxonomic identification', 'Source of taxonomic identification', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '755', '3', 0, 0, 'Область застосування даних поля', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '755', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '755', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '755', 'a', 0, 0, 'Access term', 'Access term',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '755', 'x', 0, 1, 'Основне ділення', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '755', 'y', 0, 1, 'Хронологічне ділення', '',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '755', 'z', 0, 1, 'Географічне діленння', '',                 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '760', '', 1, 'Пошукова ознака на основну серію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '760', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', '7', 0, 0, 'Control subfield', 'Control subfield',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'b', 0, 0, 'Edition', 'Edition',                       7, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'i', 0, 0, 'Display text', 'Display text',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'n', 0, 1, 'Note', 'Note',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 's', 0, 0, 'Уніфікована назва', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 't', 0, 0, 'Title', 'Title',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '760', 'y', 0, 0, 'CODEN designation', 'CODEN designation',   7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '762', '', 1, 'Пошукова ознака на підсерію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '762', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', '7', 0, 0, 'Control subfield', 'Control subfield',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'b', 0, 0, 'Edition', 'Edition',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'i', 0, 0, 'Display text', 'Display text',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'n', 0, 1, 'Note', 'Note',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 's', 0, 0, 'Уніфікована назва', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 't', 0, 0, 'Title', 'Title',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '762', 'y', 0, 0, 'CODEN designation', 'CODEN designation',   7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '765', '', 1, 'Пошукова ознака на мову оригіналу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '765', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', '7', 0, 0, 'Control subfield', 'Control subfield',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'b', 0, 0, 'Edition', 'Edition',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'i', 0, 0, 'Display text', 'Display text',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'n', 0, 1, 'Note', 'Note',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'q', 0, 0, 'Parallel title (BK SE)  [OBSOLETE]', 'Parallel title (BK SE)  [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'r', 0, 1, 'Report number', 'Report number',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 's', 0, 0, 'Уніфікована назва', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 't', 0, 0, 'Title', 'Title',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'y', 0, 0, 'CODEN designation', 'CODEN designation',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '765', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '767', '', 1, 'Пошукова ознака на переклад', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '767', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', '7', 0, 0, 'Control subfield', 'Control subfield',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'b', 0, 0, 'Edition', 'Edition',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'i', 0, 0, 'Display text', 'Display text',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'n', 0, 1, 'Note', 'Note',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'r', 0, 1, 'Report number', 'Report number',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 's', 0, 0, 'Уніфікована назва', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 't', 0, 0, 'Title', 'Title',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'y', 0, 0, 'CODEN designation', 'CODEN designation',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '767', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '770', '', 1, 'Пошукова ознака на додаток / спеціальний випуск', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '770', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', '7', 0, 0, 'Control subfield', 'Control subfield',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'a', 0, 0, 'Main entry heading', 'Main entry heading', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'b', 0, 0, 'Edition', 'Edition',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'c', 0, 0, 'Qualifying information', 'Qualifying information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'd', 0, 0, 'Place, publisher, and date of publication', 'Place, publisher, and date of publication', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'h', 0, 0, 'Physical description', 'Physical description', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'i', 0, 0, 'Display text', 'Display text',             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'n', 0, 1, 'Note', 'Note',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'o', 0, 1, 'Other item identifier', 'Other item identifier', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'r', 0, 1, 'Report number', 'Report number',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 's', 0, 0, 'Уніфікована назва', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 't', 0, 0, 'Title', 'Title',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'w', 0, 1, 'Record control number', 'Record control number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'y', 0, 0, 'CODEN designation', 'CODEN designation',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '770', 'z', 0, 1, 'International Standard Book Number', 'International Standard Book Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '772', '', 1, 'Пошукова ознака на осн. одиницю, до якої відн. додаток', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '772', '6', 0, 0, 'Зв’язок', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', '7', 0, 0, 'Контрольне поле', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'a', 0, 0, 'Заголовок / основна пошукова ознака на основну одиницю (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'b', 0, 0, 'Відомості про видання', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'c', 0, 0, 'Уточнююча інформація', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'd', 0, 0, 'Місце, видавництво і дата видання', '',    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'g', 0, 1, 'Відомості про зв’язок', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'h', 0, 0, 'Фізичний опис', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'i', 0, 0, 'Пояснювальний текст', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'k', 0, 1, 'Область серії із зв’язаного запису', '',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'm', 0, 0, 'Специфічні дані', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'n', 0, 1, 'Примітка', '',                             7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'r', 0, 1, 'Report number', 'Report number',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 's', 0, 0, 'Умовна або узагальнююча назва', '',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 't', 0, 0, 'Назва', '',                                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '',  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'x', 0, 0, 'ISSN', '',                                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'y', 0, 0, 'CODEN designation', 'CODEN designation',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '772', 'z', 0, 1, 'ISBN', '',                                 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '773', '', 1, 'Джерело інформації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '773', '3', 0, 0, 'Область застосування даних поля', '',    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', '7', 0, 0, 'Контрольне поле', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'a', 0, 0, 'Заголовок основного запису', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'd', 0, 0, 'Місце і дата видання', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'g', 0, 1, 'Інша інформація', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'h', 0, 0, 'Фізич .характ. зв’яз.один.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'i', 0, 0, 'Display text', 'Display text',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'k', 0, 1, 'Обл. серії із зв’яз.один.', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'm', 0, 0, 'Специфічні дані', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'o', 0, 1, 'Інші індекси', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'p', 0, 0, 'Abbreviated title', 'Abbreviated title', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'r', 0, 1, 'Report number', 'Report number',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 's', 0, 0, 'Уніфікована назва', '',                  7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 't', 0, 0, 'Назва джерела', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'w', 0, 1, 'Контр. № джерела', '',                   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '773', 'z', 0, 1, 'ISBN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '774', '', 1, 'Пошукова ознака на складову частину', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '774', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', '7', 0, 0, 'Контрольне поле', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'a', 0, 0, 'Заголовок основного бібліографічного запису на складову частину', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'c', 0, 0, 'Уточн. інформ.', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'd', 0, 0, 'Місце, видавець і дата вид.', '',        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'h', 0, 0, 'Фізичний опис', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'i', 0, 0, 'Display text', 'Display text',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'r', 0, 1, 'Номер звіту', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 's', 0, 0, 'Умовна або узагальнююча назва', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 't', 0, 0, 'Назва', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'u', 0, 0, 'Станд. номер тех. звіту', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'w', 0, 1, 'Контр. номер запису', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '774', 'z', 0, 1, 'ISBN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '775', '', 1, 'Бібл. опис на інше вид.', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '775', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', '7', 0, 1, 'Контрольне підполе', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'a', 0, 0, 'Загол. осн. бібл. запису', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'c', 0, 0, 'Уточн. інформ.', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'd', 0, 0, 'Місце, вид-во і дата вид.', '',          7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'e', 0, 0, 'Language code', 'Language code',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'f', 0, 0, 'Country code', 'Country code',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'g', 0, 1, 'Relationship information', 'Relationship information', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'h', 0, 0, 'Фізичний опис', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'i', 0, 0, 'Display text', 'Display text',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'k', 0, 1, 'Series data for related item', 'Series data for related item', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'm', 0, 0, 'Material-specific details', 'Material-specific details', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'r', 0, 1, 'Номер звіту', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 's', 0, 0, 'Умовна або узагальнююча назва', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 't', 0, 0, 'Назва', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'u', 0, 0, 'Станд.номер тех.звіту', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'w', 0, 1, 'Контрольний номер запису', '',           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '775', 'z', 0, 1, 'ISBN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '776', '', 1, 'Пошукова ознака на одиницю в іншій фізичній формі', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '776', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', '7', 0, 0, 'Контрольне поле', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'a', 0, 0, 'Заголовок / основна пошукова ознака на одиницю в іншій фізичній формі', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'c', 0, 0, 'Уточнююча інформація', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'd', 0, 0, 'Місце, видавець і дата видання', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'g', 0, 1, 'Відомості про зв’язок', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'h', 0, 0, 'Фізичний опис', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'i', 0, 0, 'Пояснювальний текст', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'm', 0, 0, 'Специфічні дані', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'r', 0, 1, 'Report number', 'Report number',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 's', 0, 0, 'Умовна або узагальнююча назва', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 't', 0, 0, 'Назва', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '776', 'z', 0, 1, 'ISBN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '777', '', 1, 'Пошукова ознака на одиницю, видану в одній обкладинці з опис.матеріалом', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '777', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', '7', 0, 0, 'Контрольне поле', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'a', 0, 0, 'Заголовок / основна пошукова ознака зв’язаного запису (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'c', 0, 0, 'Уточнююча інформація', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'd', 0, 0, 'Місце, видавець і дата видання', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'g', 0, 1, 'Відомості про зв’язок', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'h', 0, 0, 'Фізичний опис', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'i', 0, 0, 'Пояснювальний текст', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'm', 0, 0, 'Специфічні дані', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 's', 0, 0, 'Умовна або узагальнююча назва', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 't', 0, 0, 'Назва', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '777', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '777', 'z', 0, 1, 'ISBN', '',                                 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '780', '', 1, 'Пошукова ознака на попереднє видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '780', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', '7', 0, 0, 'Контрольне поле', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'a', 0, 0, 'Заголовок / основна пошукова ознака зв’язаного запису (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'c', 0, 0, 'Уточнююча інформація', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'd', 0, 0, 'Місце, видавець і дата видання', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'g', 0, 1, 'Відомості про зв’язок', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'h', 0, 0, 'Фізичний опис', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'i', 0, 0, 'Пояснювальний текст', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'm', 0, 0, 'Специфічні дані', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'r', 0, 1, 'Report number', 'Report number',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 's', 0, 0, 'Умовна або узагальнююча назва', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 't', 0, 0, 'Назва', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '780', 'z', 0, 1, 'ISBN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '785', '', 1, 'Пошукова ознака на наступне видання', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '785', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', '7', 0, 0, 'Контрольне поле', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'a', 0, 0, 'Заголовок / основна пошукова ознака зв’язаного запису (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'c', 0, 0, 'Уточнююча інформація', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'd', 0, 0, 'Місце, видавець і дата видання', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'g', 0, 1, 'Відомості про зв’язок', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'h', 0, 0, 'Фізичний опис', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'i', 0, 0, 'Пояснювальний текст', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'm', 0, 0, 'Специфічні дані', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'r', 0, 1, 'Report number', 'Report number',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 's', 0, 0, 'Умовна або узагальнююча назва', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 't', 0, 0, 'Назва', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '785', 'z', 0, 1, 'ISBN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '786', '', 1, 'Пошукова ознака на джерело даних', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '786', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', '7', 0, 0, 'Контрольне поле', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'a', 0, 0, 'Заголовок / основна пошукова ознака на джерело даних (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'c', 0, 0, 'Уточнююча інформація', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'd', 0, 0, 'Місце, видавець і дата видання', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'g', 0, 1, 'Відомості про зв’язок', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'h', 0, 0, 'Фізичний опис', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'i', 0, 0, 'Пояснювальний текст', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'j', 0, 0, 'Period of content', 'Period of content', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'm', 0, 0, 'Специфічні дані', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'p', 0, 0, 'Скорочена назва', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'r', 0, 1, 'Report number', 'Report number',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 's', 0, 0, 'Умовна або узагальнююча назва', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 't', 0, 0, 'Назва', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '786', 'v', 0, 0, 'Внесок джерела до змісту', '',             7, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', NULL, '786', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '786', 'z', 0, 1, 'ISBN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '787', '', 1, 'Пошукова ознака на одиницю, пов’язану з одиницею опису ін. відносинами', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '787', '6', 0, 0, 'Зв’язок', '',                            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', '7', 0, 0, 'Контрольне поле', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'a', 0, 0, 'Загол./Осн. пошукова ознака зв’язаного запису (автор)', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'b', 0, 0, 'Відомості про видання', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'c', 0, 0, 'Уточнююча інформація', '',               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'd', 0, 0, 'Місце, видавець і дата видання', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'g', 0, 1, 'Відомості про зв’язок', '',              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'h', 0, 0, 'Фізичний опис', '',                      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'i', 0, 0, 'Пояснювальний текст', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'k', 0, 1, 'Область серії із зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'm', 0, 0, 'Специфічні дані', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'n', 0, 1, 'Примітка', '',                           7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'o', 0, 1, 'Інші індекси, коди і т.ін.', '',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'q', 0, 0, 'Parallel title (BK SE) [OBSOLETE]', 'Parallel title (BK SE) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'r', 0, 1, 'Report number', 'Report number',         7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 's', 0, 0, 'Умовна або узагальнююча назва', '',      7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 't', 0, 0, 'Назва', '',                              7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'u', 0, 0, 'Standard Technical Report Number', 'Standard Technical Report Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'w', 0, 1, 'Контрольний номер зв’язаного запису', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'x', 0, 0, 'ISSN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'y', 0, 0, 'CODEN designation', 'CODEN designation', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '787', 'z', 0, 1, 'ISBN', '',                               7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '789', '', 1, 'Пошукова ознака на складову частину об’єкта', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '789', '%', 0, 0, '%', '%',                                   7, -6, '', '', '', 0, '', '', NULL),
 ('', '', '789', '2', 0, 1, 2, 2,                                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', '3', 0, 1, 3, 3,                                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', '4', 0, 1, 4, 4,                                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', '5', 0, 1, 5, 5,                                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', '6', 0, 0, 6, 6,                                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', '7', 0, 1, 7, 7,                                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', '8', 0, 1, 8, 8,                                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'a', 0, 1, 'a', 'a',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'b', 0, 1, 'b', 'b',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'c', 0, 1, 'c', 'c',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'd', 0, 1, 'd', 'd',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'e', 0, 1, 'e', 'e',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'f', 0, 1, 'f', 'f',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'g', 0, 1, 'g', 'g',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'h', 0, 1, 'h', 'h',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'i', 0, 1, 'i', 'i',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'j', 0, 1, 'j', 'j',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'k', 0, 1, 'k', 'k',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'l', 0, 1, 'l', 'l',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'm', 0, 1, 'm', 'm',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'n', 0, 1, 'n', 'n',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'o', 0, 1, 'o', 'o',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'p', 0, 1, 'p', 'p',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'q', 0, 1, 'q', 'q',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'r', 0, 1, 'r', 'r',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 's', 0, 1, 's', 's',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 't', 0, 1, 't', 't',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'u', 0, 1, 'u', 'u',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'v', 0, 1, 'v', 'v',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'w', 0, 1, 'w', 'w',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'x', 0, 1, 'x', 'x',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'y', 0, 1, 'y', 'y',                                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '789', 'z', 0, 1, 'z', 'z',                                   7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '796', '', 1, 'Локальна додаткова пошукова ознака — індивідуальне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '796', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     7, -6, '', '', '', 0, '', '', NULL),
 ('', '', '796', '3', 0, 0, 'Область застосування даних поля', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', '4', 0, 1, 'Код відношення', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', '5', 0, 0, 'Приналежність поля організації', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', 'PERSO_NAME', '796', 'a', 0, 0, 'Personal name', 'Personal name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'b', 0, 0, 'Numeration', 'Numeration',                 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'e', 0, 1, 'Термін відношенння (роль)', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'f', 0, 0, 'Дата публікації', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'g', 0, 0, 'Інші відомості', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'k', 0, 1, 'Підзаголовок форми', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'l', 0, 0, 'Мова роботи', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'm', 0, 1, 'Засіб виконання музичного твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'o', 0, 0, 'Позначення аранжування', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'r', 0, 0, 'Тональність', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 's', 0, 0, 'Версія, видання і т. д.', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 't', 0, 0, 'Назва роботи', '',                         7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'u', 0, 0, 'Додаткові відомості', '',                  7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '796', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '797', '', 1, 'Локальна додаткова пошукова ознака — ім’я організації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '797', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     7, -6, '', '', '', 0, '', '', NULL),
 ('', '', '797', '3', 0, 0, 'Область застосування даних поля', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', '4', 0, 1, 'Код відношення', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', '5', 0, 0, 'Приналежність поля організації', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', 'CORPO_NAME', '797', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',     7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'e', 0, 1, 'Термін відношенння (роль)', '',            7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'f', 0, 0, 'Дата публікації', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'g', 0, 0, 'Інші відомості', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'k', 0, 1, 'Підзаголовок форми', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'l', 0, 0, 'Мова роботи', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'm', 0, 1, 'Засіб виконання музичного твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'o', 0, 0, 'Позначення аранжування', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'r', 0, 0, 'Тональність', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 's', 0, 0, 'Версія, видання і т. д.', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 't', 0, 0, 'Назва роботи', '',                         7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'u', 0, 0, 'Додаткові відомості', '',                  7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '797', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '798', '', 1, 'Локальна додаткова пошукова ознака — назва заходу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '798', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     7, -5, '', '', '', 0, '', '', NULL),
 ('', NULL, '798', '3', 0, 0, 'Область застосування даних поля', '',    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', '4', 0, 1, 'Код відношення', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', '5', 0, 0, 'Приналежність поля організації', '',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', '6', 0, 0, 'Елемент зв’язку', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'MEETI_NAME', '798', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'd', 0, 0, 'Date of meeting', 'Date of meeting',     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit',   7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'f', 0, 0, 'Дата публікації', '',                    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'g', 0, 0, 'Інші відомості', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'h', 0, 0, 'Фізичний носій', '',                     7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'k', 0, 1, 'Підзаголовок форми', '',                 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'l', 0, 0, 'Мова роботи', '',                        7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'p', 0, 1, 'Заголовок частини/розділу твору', '',    7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 's', 0, 0, 'Версія, видання і т. д.', '',            7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 't', 0, 0, 'Назва роботи', '',                       7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'u', 0, 0, 'Додаткові відомості', '',                7, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '798', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '799', '', 1, 'Локальна додаткова пошукова ознака — уніфікований заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '799', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     7, -6, '', '', '', 0, '', '', NULL),
 ('', '', '799', '3', 0, 0, 'Область застосування даних поля', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', '5', 0, 0, 'Приналежність поля організації', '',       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', '6', 0, 0, 'Елемент зв’язку', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', 'UNIF_TITLE', '799', 'a', 0, 0, 'Уніфікована назва', '',          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'd', 0, 1, 'Дата підписання договору', '',             7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'f', 0, 0, 'Дата публікації', '',                      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'g', 0, 0, 'Інші відомості', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'h', 0, 0, 'Фізичний носій', '',                       7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'k', 0, 1, 'Підзаголовок форми', '',                   7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'l', 0, 0, 'Мова роботи', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'm', 0, 1, 'Засіб виконання музичного твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'o', 0, 0, 'Позначення аранжування', '',               7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'r', 0, 0, 'Тональність', '',                          7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 's', 0, 0, 'Версія, видання і т. д.', '',              7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 't', 0, 0, 'Назва роботи', '',                         7, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '799', 'x', 0, 0, 'International Standard Serial Number', 'International Standard Serial Number', 7, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '800', '', 1, 'Заголовок додаткового бібл.запису на серію — ім’я особи', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '800', '4', 0, 1, 'Код відношення', '',                       8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '800', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', 'PERSO_NAME', '800', 'a', 0, 0, 'Ім’я особи', '',                 8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'b', 0, 0, 'Нумерація', '',                            8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'c', 0, 1, 'Ідентифікуючі ознаки, що асоціюються з іменем особи', '', 8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'd', 0, 0, 'Дати, що стосуються імені', '',            8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'e', 0, 1, 'Термін відношення', '',                    8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'f', 0, 0, 'Дата публікації', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'h', 0, 0, 'Фізичний носій', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'j', 0, 1, 'Кваліфікатор атрибуції', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'l', 0, 0, 'Мова роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'm', 0, 1, 'Засіб для виконання муз. твору', '',       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'n', 0, 1, 'Номер частини/розділу роботи', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'o', 0, 0, 'Відомості про аранжування музичного твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'p', 0, 1, 'Назва частини/розділу роботи', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'q', 0, 0, 'Більш докладна форма імені', '',           8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'r', 0, 0, 'Музичний ключ', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 's', 0, 0, 'Версія', '',                               8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'u', 0, 0, 'Додаткові відомості', '',                  8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'v', 0, 0, 'Номер тому/послідовне позначення', '',     8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '800', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '810', '', 1, 'Заголовок додаткового бібл.запису на серію — назва організації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '810', '4', 0, 1, 'Код відношення', '',                       8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '810', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', 'CORPO_NAME', '810', 'a', 0, 0, 'Назва організації', '',          8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'b', 0, 1, 'Структурний підрозділ', '',                8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'c', 0, 0, 'Місце проведення', '',                     8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'd', 0, 1, 'Дата проведення заходу або підписання договору', '', 8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'e', 0, 1, 'Термін відношення', '',                    8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'f', 0, 0, 'Дата роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'h', 0, 0, 'Фізичний носій', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'l', 0, 0, 'Мова роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'm', 0, 1, 'Засіб для виконанняя муз. твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'n', 0, 1, 'Номер частини/розділу роботи', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'o', 0, 0, 'Відомості про аранжування музичного твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'p', 0, 1, 'Назва частини/розділу роботи', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'q', 0, 0, 'Більш докладна форма імені', '',           8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '810', 'r', 0, 0, 'Музичний ключ', '',                        8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 's', 0, 0, 'Версія', '',                               8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'u', 0, 0, 'Додаткові відомості', '',                  8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'v', 0, 0, 'Номер тому/послідовне позначення', '',     8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '810', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '811', '', 1, 'Заголовок додаткового бібл.запису на серію — назва заходу', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '811', '4', 0, 1, 'Код відношення', '',                       8, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'MEETI_NAME', '811', 'a', 0, 0, 'Назва заходу', '',               8, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'c', 0, 0, 'Місце проведення', '',                     8, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'd', 0, 1, 'Дата проведення заходу', '',               8, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'e', 0, 1, 'Структурний підррозділ', '',               8, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'f', 0, 0, 'Дата роботи', '',                          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'g', 0, 0, 'Інші відомості', '',                       8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'h', 0, 0, 'Фізичний носій', '',                       8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'j', 0, 1, 'Термін відношенння (роль)', '',            8, -1, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'l', 0, 0, 'Мова роботи', '',                          8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'm', 0, 1, 'Засіб для виконання муз. твору', '',       8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '811', 'n', 0, 1, 'Номер частини/розділу роботи', '',         8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'o', 0, 0, 'Відомості про аранжування музичного твору', '', 8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '811', 'p', 0, 1, 'Назва частини/розділу роботи', '',         8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'q', 0, 0, 'Більш докладна форма імені', '',           8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'r', 0, 0, 'Музичний ключ', '',                        8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '811', 's', 0, 0, 'Версія', '',                               8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 't', 0, 0, 'Назва роботи', '',                         8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'u', 0, 0, 'Додаткові відомості', '',                  8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'v', 0, 0, 'Номер тому/послідовне позначення', '',     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '811', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '830', '', 1, 'Заголовок додаткового бібл.запису на серію — уніфікована назва', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '830', '4', 0, 1, 'Код відношення', '',                       8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '830', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', 'UNIF_TITLE', '830', 'a', 0, 0, 'Уніфікована назва', '',          8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'd', 0, 1, 'Дата підписання договору', '',             8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'f', 0, 0, 'Дата роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'h', 0, 0, 'Фізичний носій', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'l', 0, 0, 'Мова роботи', '',                          8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'm', 0, 1, 'Засіб для виконання муз. твору', '',       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'n', 0, 1, 'Номер частини/розділу роботи', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'o', 0, 0, 'Відомості про аранжування музичного твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'p', 0, 1, 'Назва частини/розділу роботи', '',         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'q', 0, 0, 'Більш докладна форма імені', '',           8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '830', 'r', 0, 0, 'Музичний ключ', '',                        8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 's', 0, 0, 'Версія', '',                               8, -1, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'u', 0, 0, 'Додаткові відомості', '',                  8, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
 ('', '', '830', 'v', 0, 0, 'Номер тому/послідовне позначення', '',     8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '830', 'w', 0, 1, 'Bibliographic record control number', 'Bibliographic record control number', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '840', '', 1, 'Додаткова пошукова ознака на серію — назва (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '840', 'a', 0, 0, 'Title', 'Title',                           8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '840', 'h', 0, 1, 'Фізичний носій', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '840', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '841', '', '', 'Значення кодованих даних про фонди', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '841', 'a', 0, 0, 'Type of record', 'Type of record',         8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '841', 'b', 0, 0, 'Fixed-length data elements', 'Fixed-length data elements', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '841', 'e', 0, 0, 'Encoding level', 'Encoding level',         8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '842', '', '', 'Позначення текстової фізичної форми', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '842', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '842', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '842', 'a', 0, 0, 'Textual physical form designator', 'Textual physical form designator', 8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '843', '', 1, 'Примітка про репродукцію', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '843', '3', 0, 0, 'Область застосування даних поля', '',    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', '6', 0, 0, 'Елемент зв’язку', '',                    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', '7', 0, 0, 'Fixed-length data elements of reproduction', 'Fixed-length data elements of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', 'a', 0, 0, 'Type of reproduction', 'Type of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', 'b', 0, 1, 'Place of reproduction', 'Place of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', 'c', 0, 1, 'Agency responsible for reproduction', 'Agency responsible for reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', 'd', 0, 0, 'Date of reproduction', 'Date of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', 'e', 0, 1, 'Physical description of reproduction', 'Physical description of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', 'f', 0, 1, 'Series statement of reproduction', 'Series statement of reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', 'm', 0, 1, 'Dates of publication and/or sequential designation of issues reproduced', 'Dates of publication and/or sequential designation of issues reproduced', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '843', 'n', 0, 1, 'Note about reproduction', 'Note about reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '844', '', '', 'Назва одиниці', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '844', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '844', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '844', 'a', 0, 0, 'Назва одиниці', '',                        8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '845', '', 1, 'Умови контролю за використанням та репродукцією', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '845', '3', 0, 0, 'Область застосування даних поля', '',      8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '845', '5', 0, 0, 'Приналежність поля організації', '',       8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '845', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '845', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '845', 'a', 0, 0, 'Terms governing use and reproduction', 'Terms governing use and reproduction', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '845', 'b', 0, 0, 'Jurisdiction', 'Jurisdiction',             8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '845', 'c', 0, 0, 'Authorization', 'Authorization',           8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '845', 'd', 0, 0, 'Authorized users', 'Authorized users',     8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '850', '', 1, 'Організація-утримувач', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '850', '8', 0, 1, 'Зв’язок полів та номер послідовності', '', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '850', 'a', 0, 1, 'Назва організації', '',                    8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '850', 'b', 0, 0, 'Holdings (NR) (MU VM SE) [OBSOLETE]', 'Holdings (NR) (MU VM SE) [OBSOLETE]', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '850', 'd', 0, 0, 'Inclusive dates (NR) (MU VM SE) [OBSOLETE]', 'Inclusive dates (NR) (MU VM SE) [OBSOLETE]', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '850', 'e', 0, 0, 'Retention statement (NR) (CF MU VM SE) [OBSOLETE]', 'Retention statement (NR) (CF MU VM SE) [OBSOLETE]', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '851', '', 1, 'Місцезнаходження (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '851', '3', 0, 0, 'Область застосування даних поля', '',      8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '851', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '851', 'a', 0, 0, 'Name (custodian or owner)', 'Name (custodian or owner)', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '851', 'b', 0, 0, 'Institutional division', 'Institutional division', 8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '851', 'c', 0, 0, 'Street address', 'Street address',         8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '851', 'd', 0, 0, 'Country', 'Country',                       8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '851', 'e', 0, 0, 'Location of units', 'Location of units',   8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '851', 'f', 0, 0, 'Номер об’єкту', '',                        8, 5, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '851', 'g', 0, 0, 'Repository location code', 'Repository location code', 8, 5, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '852', '', 1, 'Місцезнаходження', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '852', '2', 0, 0, 'Джерело схеми розстановки', '',            8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', '3', 0, 0, 'Область застосування даних', '',           8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', '6', 0, 0, 'Зв’язок', '',                              8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', '8', 0, 1, 'Sequence number', 'Sequence number',       8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'a', 0, 0, 'Місцезнаходження', '',                     8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'b', 0, 1, 'Підрозділ', '',                            8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'c', 0, 1, 'Місцезнаходження на полиці', '',           8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'e', 0, 1, 'Адреса', '',                               8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'f', 0, 1, 'Кодовані дані', '',                        8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'g', 0, 1, 'Особливості розстановки', '',              8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'h', 0, 0, 'Класифік.частина індексу', '',             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'i', 0, 1, 'Розстановочна ознака', '',                 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'j', 0, 0, 'Шифр зберігання', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'k', 0, 0, 'Префікс шифру зберігання', '',             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'l', 0, 0, 'Розстановочна форма назви', '',            8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'm', 0, 0, 'Суфікс шифру зберігання', '',              8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'n', 0, 0, 'Код країни', '',                           8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'p', 0, 0, 'Інвентарний номер', '',                    8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'q', 0, 0, 'Фізич. особливості прим.', '',             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 's', 0, 1, 'Copyright article-fee code', 'Copyright article-fee code', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 't', 0, 0, 'Порядковий номер примірн.', '',            8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'u', 0, 1, 'Уніфікований визначник ресурсу (URI)', '', 8, 5, '', '', '', 1, '', '', NULL),
 ('', '', '852', 'x', 0, 0, 'Приміт., непризнач. корист.', '',          8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '852', 'z', 0, 1, 'Примітка для ЕК', '',                      8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '853', '', 1, 'Заголовки та модель — основна бібліографічна одиниця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '853', '3', 0, 0, 'Область застосування даних поля', '',      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'n', 0, 0, 'Pattern note', 'Pattern note',             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 't', 0, 0, 'Copy', 'Copy',                             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'w', 0, 0, 'Frequency', 'Frequency',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'x', 0, 0, 'Calendar change', 'Calendar change',       8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '853', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',     8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '854', '', 1, 'Заголовки та модель — додатковий матеріал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '854', '3', 0, 0, 'Область застосування даних поля', '',      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'n', 0, 0, 'Pattern note', 'Pattern note',             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 't', 0, 0, 'Copy', 'Copy',                             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'w', 0, 0, 'Frequency', 'Frequency',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'x', 0, 0, 'Calendar change', 'Calendar change',       8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '854', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',     8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '855', '', 1, 'Заголовки та модель — покажчики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '855', '3', 0, 0, 'Область застосування даних поля', '',      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'a', 0, 0, 'First level of enumeration', 'First level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'b', 0, 0, 'Second level of enumeration', 'Second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'c', 0, 0, 'Third level of enumeration', 'Third level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'd', 0, 0, 'Fourth level of enumeration', 'Fourth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'e', 0, 0, 'Fifth level of enumeration', 'Fifth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'f', 0, 0, 'Sixth level of enumeration', 'Sixth level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'g', 0, 0, 'Alternative numbering scheme, first level of enumeration', 'Alternative numbering scheme, first level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'h', 0, 0, 'Alternative numbering scheme, second level of enumeration', 'Alternative numbering scheme, second level of enumeration', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'i', 0, 0, 'First level of chronology', 'First level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'j', 0, 0, 'Second level of chronology', 'Second level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'k', 0, 0, 'Third level of chronology', 'Third level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'l', 0, 0, 'Fourth level of chronology', 'Fourth level of chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'm', 0, 0, 'Alternative numbering scheme, chronology', 'Alternative numbering scheme, chronology', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'n', 0, 0, 'Pattern note', 'Pattern note',             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'p', 0, 0, 'Number of pieces per issuance', 'Number of pieces per issuance', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 't', 0, 0, 'Copy', 'Copy',                             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'u', 0, 1, 'Bibliographic units per next higher level', 'Bibliographic units per next higher level', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'v', 0, 1, 'Numbering continuity', 'Numbering continuity', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'w', 0, 0, 'Frequency', 'Frequency',                   8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'x', 0, 0, 'Calendar change', 'Calendar change',       8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'y', 0, 1, 'Regularity pattern', 'Regularity pattern', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '855', 'z', 0, 1, 'Numbering scheme', 'Numbering scheme',     8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '856', '', 1, 'Електронна адреса документа', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '856', '2', 0, 0, 'Спосіб доступу', '',                       8, -6, '', '', '', 0, '', '', NULL),
 ('', '', '856', '3', 0, 0, 'Область застосування даних поля', '',      8, 0, '', '', '', 0, '', '', NULL),
 ('', '', '856', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', 0, '', '', NULL),
 ('', '', '856', '8', 0, 1, 'Зв’язок полів та номер послідовності', '', 8, -6, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'a', 0, 1, 'Ім’я сервера/домену', '',                  8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'b', 0, 1, 'Номер для доступу', '',                    8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'c', 0, 1, 'Інформація про стиснення', '',             8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'd', 0, 1, 'Шлях', '',                                 8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'f', 0, 1, 'Електронне ім’я', '',                      8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'h', 0, 0, 'Ім’я користувача', '',                     8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'i', 0, 0, 'Пароль', '',                               8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'j', 0, 0, 'Кількість біт у секунду', '',              8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'k', 0, 0, 'Пароль', '',                               8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'l', 0, 0, 'Вхід/початок сеансу', '',                  8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'm', 0, 1, 'Допомога', '',                             8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'n', 0, 0, 'Місцезнаходження серверу', '',             8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'o', 0, 0, 'Операційна система серверу', '',           8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'p', 0, 0, 'Порт', '',                                 8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'q', 0, 0, 'Тип електронного формату', '',             8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'r', 0, 1, 'Структура', '',                            8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 's', 0, 1, 'Розмір файлу', '',                         8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 't', 0, 1, 'Емуляція терміналу', '',                   8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'u', 0, 1, 'URL', '',                                  8, 0, 'biblioitems.url', '', '', 1, '', '', NULL),
 ('', '', '856', 'v', 0, 1, 'Години доступу до ресурсу', '',            8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'w', 0, 1, 'Контрольний номер запису', '',             8, -1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'x', 0, 1, 'Службова примітка', '',                    8, 1, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'y', 0, 1, 'Довідковий текст', '',                     8, 0, '', '', '', 0, '', '', NULL),
 ('', '', '856', 'z', 0, 1, 'Примітка для користувача', '',             8, 0, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '859', '', 1, 'Локальна контрольна інформація', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '859', 'b', 0, 0, 'Operators initials, OID (RLIN)', 'Operators initials, OID (RLIN)', 8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '859', 'c', 0, 0, 'Catalogers initials, CIN (RLIN)', 'Catalogers initials, CIN (RLIN)', 8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '859', 'd', 0, 0, 'TDC (RLIN)', 'TDC (RLIN)',                 8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '859', 'l', 0, 0, 'LIB (RLIN)', 'LIB (RLIN)',                 8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '859', 'p', 0, 0, 'PRI (RLIN)', 'PRI (RLIN)',                 8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '859', 'r', 0, 0, 'REG (RLIN)', 'REG (RLIN)',                 8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '859', 'v', 0, 0, 'VER (RLIN)', 'VER (RLIN)',                 8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '859', 'x', 0, 0, 'LDEL (RLIN)', 'LDEL (RLIN)',               8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '863', '', 1, 'Нумерація та хронологія — основна бібліографічна одиниця', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '864', '', 1, 'Нумерація та хронологія — додатковий матеріал', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '865', '', 1, 'Нумерація та хронологія — покажчики', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '866', '', 1, 'Текстовий опис фондів — основна бібліографічна одиниця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '866', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '866', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '866', 'a', 0, 0, 'Textual string', 'Textual string',         8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '866', 'x', 0, 1, 'Службова примітка', '',                    8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '866', 'z', 0, 1, 'Примітка для ЕК', '',                      8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '867', '', 1, 'Текстовий опис фондів — додатковий матеріал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '867', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '867', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '867', 'a', 0, 0, 'Textual string', 'Textual string',         8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '867', 'x', 0, 1, 'Службова примітка', '',                    8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '867', 'z', 0, 1, 'Примітка для ЕК', '',                      8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '868', '', 1, 'Текстовий опис фондів — покажчики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '868', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '868', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '868', 'a', 0, 0, 'Textual string', 'Textual string',         8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '868', 'x', 0, 1, 'Службова примітка', '',                    8, 5, '', '', '', 0, '', '', NULL),
 ('', '', '868', 'z', 0, 1, 'Примітка для ЕК', '',                      8, 5, '', '', '', 0, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '870', '', 1, 'Варіант індивідуального імені (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '870', '4', 0, 1, 'Код відношення', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'a', 0, 0, 'Personal name', 'Personal name',           8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'b', 0, 0, 'Numeration', 'Numeration',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'e', 0, 1, 'Термін відношенння (роль)', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'f', 0, 0, 'Дата публікації', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'l', 0, 0, 'Мова роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '870', 'u', 0, 0, 'Додаткові відомості', '',                  8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '871', '', 1, 'Варіант фірмового імені (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '871', '4', 0, 1, 'Код відношення', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',     8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'e', 0, 1, 'Термін відношенння (роль)', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'f', 0, 0, 'Дата публікації', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'l', 0, 0, 'Мова роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '871', 'u', 0, 0, 'Додаткові відомості', '',                  8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '872', '', 1, 'Варіант назви конференції чи заходу (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', NULL, '872', '4', 0, 1, 'Код відношення', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', '6', 0, 0, 'Елемент зв’язку', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'b', 0, 0, 'Number [OBSOLETE]', 'Number [OBSOLETE]', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'd', 0, 0, 'Date of meeting', 'Date of meeting',     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit',   8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'f', 0, 0, 'Дата публікації', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'g', 0, 0, 'Інші відомості', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '872', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', NULL, '872', 'k', 0, 1, 'Підзаголовок форми', '',                 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'l', 0, 0, 'Мова роботи', '',                        8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'p', 0, 1, 'Заголовок частини/розділу твору', '',    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 't', 0, 0, 'Назва роботи', '',                       8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '872', 'u', 0, 0, 'Додаткові відомості', '',                8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '873', '', 1, 'Варіант уніфікованого заголовку (застаріле)', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '873', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'a', 0, 0, 'Уніфікована назва', '',                    8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'd', 0, 1, 'Дата підписання договору', '',             8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'f', 0, 0, 'Дата публікації', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'h', 0, 0, 'Фізичний носій', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'j', 0, 0, 'Tag and sequence number', 'Tag and sequence number', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'l', 0, 0, 'Мова роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'm', 0, 1, 'Засіб виконання музичного твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'o', 0, 0, 'Позначення аранжування', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 'r', 0, 0, 'Тональність', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 's', 0, 0, 'Версія, видання і т. д.', '',              8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '873', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '876', '', 1, 'Інформація про примірник — основна бібліографічна одиниця', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '876', '3', 0, 0, 'Область застосування даних поля', '',      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', '8', 0, 1, 'Sequence number', 'Sequence number',       8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'c', 0, 1, 'Cost', 'Cost',                             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'd', 0, 1, 'Date acquired', 'Date acquired',           8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'h', 0, 1, 'Use restrictions', 'Use restrictions',     8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'j', 0, 1, 'Item status', 'Item status',               8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'p', 0, 1, 'Piece designation', 'Piece designation',   8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 't', 0, 0, 'Copy number', 'Copy number',               8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'x', 0, 1, 'Службова примітка', '',                    8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '876', 'z', 0, 1, 'Примітка для ЕК', '',                      8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '877', '', 1, 'Інформація про примірник — додатковий матеріал', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '877', '3', 0, 0, 'Область застосування даних поля', '',      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', '8', 0, 1, 'Sequence number', 'Sequence number',       8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'c', 0, 1, 'Cost', 'Cost',                             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'd', 0, 1, 'Date acquired', 'Date acquired',           8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'h', 0, 1, 'Use restrictions', 'Use restrictions',     8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'j', 0, 1, 'Item status', 'Item status',               8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'p', 0, 1, 'Piece designation', 'Piece designation',   8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 't', 0, 0, 'Copy number', 'Copy number',               8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'x', 0, 1, 'Службова примітка', '',                    8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '877', 'z', 0, 1, 'Примітка для ЕК', '',                      8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '878', '', 1, 'Інформація про примірник — покажчики', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '878', '3', 0, 0, 'Область застосування даних поля', '',      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', '6', 0, 0, 'Елемент зв’язку', '',                      8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', '8', 0, 1, 'Sequence number', 'Sequence number',       8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'a', 0, 0, 'Internal item number', 'Internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'b', 0, 1, 'Invalid or canceled internal item number', 'Invalid or canceled internal item number', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'c', 0, 1, 'Cost', 'Cost',                             8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'd', 0, 1, 'Date acquired', 'Date acquired',           8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'e', 0, 1, 'Source of acquisition', 'Source of acquisition', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'h', 0, 1, 'Use restrictions', 'Use restrictions',     8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'j', 0, 1, 'Item status', 'Item status',               8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'l', 0, 1, 'Temporary location', 'Temporary location', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'p', 0, 1, 'Piece designation', 'Piece designation',   8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'r', 0, 1, 'Invalid or canceled piece designation', 'Invalid or canceled piece designation', 8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 't', 0, 0, 'Copy number', 'Copy number',               8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'x', 0, 1, 'Службова примітка', '',                    8, 5, '', '', '', NULL, '', '', NULL),
 ('', '', '878', 'z', 0, 1, 'Примітка для ЕК', '',                      8, 5, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '880', '', 1, 'Альтернативне графічне зображення', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '880', '2', 0, 1, 2, 2,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', '3', 0, 1, 3, 3,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', '4', 0, 1, 4, 4,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', '5', 0, 1, 5, 5,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', '7', 0, 1, 7, 7,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', '8', 0, 1, 8, 8,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'a', 0, 1, 'a', 'a',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'b', 0, 1, 'b', 'b',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'c', 0, 1, 'c', 'c',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'd', 0, 1, 'd', 'd',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'e', 0, 1, 'e', 'e',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'f', 0, 1, 'f', 'f',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'g', 0, 1, 'g', 'g',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'h', 0, 1, 'h', 'h',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'i', 0, 1, 'i', 'i',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'j', 0, 1, 'j', 'j',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'k', 0, 1, 'k', 'k',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'l', 0, 1, 'l', 'l',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'm', 0, 1, 'm', 'm',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'n', 0, 1, 'n', 'n',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'o', 0, 1, 'o', 'o',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'p', 0, 1, 'p', 'p',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'q', 0, 1, 'q', 'q',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'r', 0, 1, 'r', 'r',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 's', 0, 1, 's', 's',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 't', 0, 1, 't', 't',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'u', 0, 1, 'u', 'u',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'v', 0, 1, 'v', 'v',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'w', 0, 1, 'w', 'w',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'x', 0, 1, 'x', 'x',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'y', 0, 1, 'y', 'y',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '880', 'z', 0, 1, 'z', 'z',                                   8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '882', '', 1, 'Replacement Record Information', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '882', '6', 0, 0, 'Linkage', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '882', '8', 0, 0, 'Field link and sequence number', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '882', 'a', 0, 0, 'Replacement title', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '882', 'i', 0, 0, 'Explanatory text', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '882', 'q', 0, 0, 'Replacement bibliographic record control number', '',                      8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '883', '', 1, 'Machine-generated Metadata Provenance', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '883', '0', 0, 0, 'Authority record control number or standard number', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '883', '8', 0, 0, 'Field link and sequence number', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '883', 'a', 0, 0, 'Generation process', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '883', 'c', 0, 0, 'Confidence value', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '883', 'd', 0, 0, 'Generation date', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '883', 'q', 0, 0, 'Generation agency', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '883', 'x', 0, 0, 'Validity end date', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '883', 'u', 0, 0, 'Uniform Resource Identifier', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '883', 'w', 0, 0, 'Bibliographic record control number', '',                      8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '884', '', 1, 'Description Conversion Information', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '884', 'a', 0, 0, 'Conversion process', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '884', 'g', 0, 0, 'Conversion date', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '884', 'k', 0, 0, 'Identifier of source metadata', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '884', 'q', 0, 0, 'Conversion agency', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '884', 'u', 0, 0, 'Uniform Resource Identifier', '',                      8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '885', '', 1, 'Matching Information', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '885', '0', 0, 0, 'Authority record control number or standard number', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', '2', 0, 0, 'Source', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', '5', 0, 0, 'Institution to which field applies', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', 'a', 0, 0, 'Matching information', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', 'b', 0, 0, 'Status of matching and its checking', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', 'c', 0, 0, 'Confidence value', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', 'd', 0, 0, 'Generation date', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', 'w', 0, 0, 'Record control number', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', 'x', 0, 0, 'Nonpublic note', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '885', 'z', 0, 0, 'Public note', '',                      8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '886', '', 1, 'Поле інформації про іноземний формат MARC', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '886', '0', 0, 1, 0, 0,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', '1', 0, 1, 1, 1,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', '2', 0, 1, 2, 2,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', '3', 0, 1, 3, 3,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', '4', 0, 1, 4, 4,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', '5', 0, 1, 5, 5,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', '6', 0, 1, 6, 6,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', '7', 0, 1, 7, 7,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', '8', 0, 1, 8, 8,                                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'a', 0, 1, 'a', 'a',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'b', 0, 1, 'b', 'b',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'c', 0, 1, 'c', 'c',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'd', 0, 1, 'd', 'd',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'e', 0, 1, 'e', 'e',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'f', 0, 1, 'f', 'f',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'g', 0, 1, 'g', 'g',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'h', 0, 1, 'h', 'h',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'i', 0, 1, 'i', 'i',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'j', 0, 1, 'j', 'j',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'k', 0, 1, 'k', 'k',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'l', 0, 1, 'l', 'l',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'm', 0, 1, 'm', 'm',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'n', 0, 1, 'n', 'n',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'o', 0, 1, 'o', 'o',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'p', 0, 1, 'p', 'p',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'q', 0, 1, 'q', 'q',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'r', 0, 1, 'r', 'r',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 's', 0, 1, 's', 's',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 't', 0, 1, 't', 't',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'u', 0, 1, 'u', 'u',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'v', 0, 1, 'v', 'v',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'w', 0, 1, 'w', 'w',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'x', 0, 1, 'x', 'x',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'y', 0, 1, 'y', 'y',                                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '886', 'z', 0, 1, 'z', 'z',                                   8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '887', '', 1, 'Поле не MARC-інформації', '', NULL);
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '887', '2', 0, 0, 'Source of data', 'Source of data',         8, 0, NULL, NULL, '', NULL, '', '', NULL),
 ('', '', '887', 'a', 0, 0, 'Content of non-MARC field', 'Content of non-MARC field', 8, 0, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '896', '', 1, 'Локальна додаткова пошукова ознака на серію — індивідуальне ім’я', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '896', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     8, -6, '', '', '', 0, '', '', NULL),
 ('', '', '896', '4', 0, 1, 'Код відношення', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', 'PERSO_NAME', '896', 'a', 0, 0, 'Personal name', 'Personal name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'b', 0, 0, 'Numeration', 'Numeration',                 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'c', 0, 1, 'Titles and other words associated with a name', 'Titles and other words associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'd', 0, 0, 'Dates associated with a name', 'Dates associated with a name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'e', 0, 1, 'Термін відношенння (роль)', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'f', 0, 0, 'Дата публікації', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'h', 0, 0, 'Фізичний носій', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'j', 0, 1, 'Attribution qualifier', 'Attribution qualifier', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'l', 0, 0, 'Мова роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'm', 0, 1, 'Засіб виконання музичного твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'o', 0, 0, 'Позначення аранжування', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'q', 0, 0, 'Fuller form of name', 'Fuller form of name', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'r', 0, 0, 'Тональність', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 's', 0, 0, 'Версія, видання і т. д.', '',              8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'u', 0, 0, 'Додаткові відомості', '',                  8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '896', 'v', 0, 0, 'Позначення та номер тому / порядкова нумерація', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '897', '', 1, 'Локальна додаткова пошукова ознака на серію — ім’я організації', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '897', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     8, -6, '', '', '', 0, '', '', NULL),
 ('', '', '897', '4', 0, 1, 'Код відношення', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', 'CORPO_NAME', '897', 'a', 0, 0, 'Corporate name or jurisdiction name as entry element', 'Corporate name or jurisdiction name as entry element', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'b', 0, 1, 'Subordinate unit', 'Subordinate unit',     8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'd', 0, 1, 'Date of meeting or treaty signing', 'Date of meeting or treaty signing', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'e', 0, 1, 'Термін відношенння (роль)', '',            8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'f', 0, 0, 'Дата публікації', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'h', 0, 0, 'Фізичний носій', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'l', 0, 0, 'Мова роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'm', 0, 1, 'Засіб виконання музичного твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'o', 0, 0, 'Позначення аранжування', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'r', 0, 0, 'Тональність', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 's', 0, 0, 'Версія, видання і т. д.', '',              8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'u', 0, 0, 'Додаткові відомості', '',                  8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '897', 'v', 0, 0, 'Позначення та номер тому / порядкова нумерація', '', 8, -6, '', '', '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '898', '', 1, 'Локальна додаткова пошукова ознака на серію — назва заходу', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '898', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     8, -6, '', '', '', 0, '', '', NULL),
 ('', NULL, '898', '4', 0, 1, 'Код відношення', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', '6', 0, 0, 'Елемент зв’язку', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', '8', 0, 1, 'Field link and sequence number', 'Field link and sequence number', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', 'MEETI_NAME', '898', 'a', 0, 0, 'Meeting name or jurisdiction name as entry element', 'Meeting name or jurisdiction name as entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'b', 0, 0, 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 'Number (BK CF MP MU SE VM MX) [OBSOLETE]', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'c', 0, 0, 'Location of meeting', 'Location of meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'd', 0, 0, 'Date of meeting', 'Date of meeting',     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'e', 0, 1, 'Subordinate unit', 'Subordinate unit',   8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'f', 0, 0, 'Дата публікації', '',                    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'g', 0, 0, 'Інші відомості', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'h', 0, 0, 'Фізичний носій', '',                     8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'k', 0, 1, 'Підзаголовок форми', '',                 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'l', 0, 0, 'Мова роботи', '',                        8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'n', 0, 1, 'Number of part/section/meeting', 'Number of part/section/meeting', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'p', 0, 1, 'Заголовок частини/розділу твору', '',    8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'q', 0, 0, 'Name of meeting following jurisdiction name entry element', 'Name of meeting following jurisdiction name entry element', 8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 's', 0, 0, 'Версія, видання і т. д.', '',            8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 't', 0, 0, 'Назва роботи', '',                       8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'u', 0, 0, 'Додаткові відомості', '',                8, -6, NULL, NULL, '', NULL, '', '', NULL),
 ('', NULL, '898', 'v', 0, 0, 'Позначення та номер тому / порядкова нумерація', '', 8, -6, NULL, NULL, '', NULL, '', '', NULL);

INSERT INTO marc_tag_structure  (frameworkcode, tagfield, mandatory, repeatable, liblibrarian, libopac, authorised_value) VALUES
 ('', '899', '', 1, 'Локальна додаткова пошукова ознака на серію — уніфікований заголовок', '', '');
INSERT INTO  marc_subfield_structure (frameworkcode, authtypecode, tagfield, tagsubfield, mandatory, repeatable, liblibrarian, libopac, tab, hidden, kohafield, authorised_value, value_builder, isurl, seealso, link, defaultvalue) VALUES
 ('', '', '899', '%', 0, 0, '% (RLIN)', '% (RLIN)',                     8, -6, '', '', '', 0, '', '', NULL),
 ('', '', '899', '6', 0, 0, 'Елемент зв’язку', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', '8', 0, 1, 'Зв’язок поля та його порядковий номер', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', 'UNIF_TITLE', '899', 'a', 0, 0, 'Уніфікована назва', '',          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'd', 0, 1, 'Дата підписання договору', '',             8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'f', 0, 0, 'Дата публікації', '',                      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'g', 0, 0, 'Інші відомості', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'h', 0, 0, 'Фізичний носій', '',                       8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'k', 0, 1, 'Підзаголовок форми', '',                   8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'l', 0, 0, 'Мова роботи', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'm', 0, 1, 'Засіб виконання музичного твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'n', 0, 1, 'Позначення та номер частини/розділу твору', '', 8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'o', 0, 0, 'Позначення аранжування', '',               8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'p', 0, 1, 'Заголовок частини/розділу твору', '',      8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'r', 0, 0, 'Тональність', '',                          8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 's', 0, 0, 'Версія, видання і т. д.', '',              8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 't', 0, 0, 'Назва роботи', '',                         8, -6, '', '', '', NULL, '', '', NULL),
 ('', '', '899', 'v', 0, 0, 'Позначення та номер тому / порядкове позначення', '', 8, 5, '', '', '', NULL, '', '', NULL);

-- Create the ACQ framework based on the default framework, fields 952 only
INSERT IGNORE INTO biblio_framework VALUES( 'ACQ', 'Acquisition framework' );
INSERT INTO marc_tag_structure(tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, frameworkcode)
SELECT tagfield, liblibrarian, libopac, repeatable, mandatory, authorised_value, 'ACQ' FROM marc_tag_structure WHERE tagfield='952' AND frameworkcode='';

INSERT INTO marc_subfield_structure(tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, frameworkcode, seealso, link, defaultvalue, maxlength)
SELECT tagfield, tagsubfield, liblibrarian, libopac, repeatable, mandatory, kohafield, tab, authorised_value, authtypecode, value_builder, isurl, hidden, 'ACQ', seealso, link, defaultvalue, maxlength FROM marc_subfield_structure WHERE tagfield='952' AND frameworkcode='';
