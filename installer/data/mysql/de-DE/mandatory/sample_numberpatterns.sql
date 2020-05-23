INSERT INTO subscription_numberpatterns
    (label, displayorder, description, numberingmethod,
    label1, add1, every1, whenmorethan1, setto1, numbering1,
    label2, add2, every2, whenmorethan2, setto2, numbering2,
    label3, add3, every3, whenmorethan3, setto3, numbering3)
VALUES
    ('Nummer', 1, 'Fortlaufende Nummerierung', 'Nr. {X}',
    'Nummer', 1, 1, 99999, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL),

    ('Band, Nummer, Heft', 2, 'Band X, Nummer Y, Heft Z', 'Bd. {X}, Nr. {Y}, H. {Z}',
    'Band', 1, 48, 99999, 1, NULL,
    'Nummer', 1, 4, 12, 1, NULL,
    'Heft', 1, 1, 4, 1, NULL),

    ('Jg., Heft', 3, 'Jg. X, H. Y', 'Jg. {X}, H. {Y}',
    'Jg.', 1, 12, 99999, 1, NULL,
    'Heft', 1, 1, 12, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL),

    ('Saisonal', 4, ' Saison Jahr', '{X} {Y}',
    'Saison', 1, 1, 3, 0, 'season',
    'Jahr', 1, 4, 99999, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL);
