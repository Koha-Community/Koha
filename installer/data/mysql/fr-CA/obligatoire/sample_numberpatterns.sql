INSERT INTO subscription_numberpatterns
    (label, displayorder, description, numberingmethod,
    label1, add1, every1, whenmorethan1, setto1, numbering1,
    label2, add2, every2, whenmorethan2, setto2, numbering2,
    label3, add3, every3, whenmorethan3, setto3, numbering3)
VALUES
    ('Numéro', 1, 'Numérotation simple', 'No.{X}',
    'Numéro', 1, 1, 99999, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL),

    ('Volume, Numéro, Fascicule', 2, 'Volume Numéro Fascicule 1', 'Vol.{X}, No.{Y}, Fasc.{Z}',
    'Volume', 1, 48, 99999, 1, NULL,
    'Numéro', 1, 4, 12, 1, NULL,
    'Fascicule', 1, 1, 4, 1, NULL),

    ('Volume, Numéro', 3, 'Volume Numéro 1', 'Vol.{X}, No.{Y}',
    'Volume', 1, 12, 99999, 1, NULL,
    'Numéro', 1, 1, 12, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL),

    ('Saisonnier', 4, 'Saison Année', '{X} {Y}',
    'Saison', 1, 1, 3, 0, 'season',
    'Year', 1, 4, 99999, 1, NULL,
    NULL, NULL, NULL, NULL, NULL, NULL);
