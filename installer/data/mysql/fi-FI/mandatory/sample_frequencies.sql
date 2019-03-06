INSERT INTO subscription_frequencies
    (description, unit, unitsperissue, issuesperunit, displayorder)
VALUES
    ('2/päivä', 'day', 1, 2, 1),
    ('1/päivä', 'day', 1, 1, 2),
    ('3/viikko', 'week', 1, 3, 3),
    ('1/viikko', 'week', 1, 1, 4),
    ('1/2 viikkoa', 'week', 2, 1, 5),
    ('1/3 viikkoa', 'week', 3, 1, 6),
    ('1/kuukausi', 'month', 1, 1, 7),
    ('1/2 kuukautta', 'month', 2, 1, 8),
    ('1/3 kuukautta', 'month', 3, 1, 9),
    ('2/vuosi', 'month', 6, 1, 10),
    ('1/vuosi', 'year', 1, 1, 11),
    ('1/2 vuotta', 'year', 2, 1, 12),
    ('Epäsäännöllinen', NULL, 1, 1, 13);
