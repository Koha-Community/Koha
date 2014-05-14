INSERT INTO subscription_frequencies
    (description, unit, unitsperissue, issuesperunit, displayorder)
VALUES
    ('2 al giorno', 'day', 1, 2, 1),
    ('ogni giorno', 'day', 1, 1, 2),
    ('3 alla sett.', 'week', 1, 3, 3),
    ('ogni sett.', 'week', 1, 1, 4),
    ('1 ogni 2 sett.', 'week', 2, 1, 5),
    ('1 ogni 3 sett.', 'week', 3, 1, 6),
    ('ogni mese', 'month', 1, 1, 7),
    ('1 ogni 2 mesi', 'month', 2, 1, 8),
    ('1 ogni 3 mesi', 'month', 3, 1, 9),
    ('2 all\'anno', 'month', 6, 1, 10),
    ('ogni anno', 'year', 1, 1, 11),
    ('1 ogni 2 anni', 'year', 2, 1, 12),
    ('Irregular', NULL, 1, 1, 13);
