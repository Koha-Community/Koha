INSERT INTO subscription_frequencies
    (description, unit, unitsperissue, issuesperunit, displayorder)
VALUES
    ('2/Tag', 'day', 1, 2, 1),
    ('1/Tag', 'day', 1, 1, 2),
    ('3/Woche', 'week', 1, 3, 3),
    ('1/Woche', 'week', 1, 1, 4),
    ('1/2 Wochen', 'week', 2, 1, 5),
    ('1/3 Wochen', 'week', 3, 1, 6),
    ('1/Monat', 'month', 1, 1, 7),
    ('1/2 Monate', 'month', 2, 1, 8),
    ('1/3 Monate', 'month', 3, 1, 9),
    ('2/Jahr', 'month', 6, 1, 10),
    ('1/Jahr', 'year', 1, 1, 11),
    ('1/2 Jahre', 'year', 2, 1, 12),
    ('Unregelmäßig', NULL, 1, 1, 13);
