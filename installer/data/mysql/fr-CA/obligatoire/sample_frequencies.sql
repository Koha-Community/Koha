INSERT INTO subscription_frequencies
    (description, unit, unitsperissue, issuesperunit, displayorder)
VALUES
    ('2/jour', 'day', 1, 2, 1),
    ('1/jour', 'day', 1, 1, 2),
    ('3/semaine', 'week', 1, 3, 3),
    ('1/semaine', 'week', 1, 1, 4),
    ('1/2 semaines', 'week', 2, 1, 5),
    ('1/3 semaines', 'week', 3, 1, 6),
    ('1/mois', 'month', 1, 1, 7),
    ('1/2 mois', 'month', 2, 1, 8),
    ('1/3 mois', 'month', 3, 1, 9),
    ('2/an', 'month', 6, 1, 10),
    ('1/an', 'year', 1, 1, 11),
    ('1/2 ans', 'year', 2, 1, 12),
    ('Irrégulier', NULL, 1, 1, 13);
