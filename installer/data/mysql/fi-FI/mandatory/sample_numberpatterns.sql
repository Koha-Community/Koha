INSERT INTO subscription_numberpatterns
    (label, displayorder, description, numberingmethod,
    label1, add1, every1, whenmorethan1, setto1, numbering1,
    label2, add2, every2, whenmorethan2, setto2, numbering2,
    label3, add3, every3, whenmorethan3, setto3, numbering3)
VALUES
    ('Numero', 1, 'Yksinkertainen numerointi', 'Nro. {X}',
    'Numero', 1, 1, 99999, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL),

    ('Vuosikerta, numero, lehti', 2, 'Vuosikerta : Numero : Lehti', '{X} : {Y} : {Z}',
    'Vuosikerta', 1, 48, 99999, 1, NULL,
    'Numero', 1, 4, 12, 1, NULL,
    'Lehti', 1, 1, 4, 1, NULL),

    ('Vuosikerta, numero', 3, 'Vuosikerta : Numero', '{X} : {Y}',
    'Vuosikerta', 1, 12, 99999, 1, NULL,
    'Numero', 1, 1, 12, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL),

    ('Vuodenaika', 4, 'Vuodenaika Vuosi', '{X} {Y}',
    'Vuodenaika', 1, 1, 3, 0, 'season',
    'Vuosi', 1, 4, 99999, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL);
