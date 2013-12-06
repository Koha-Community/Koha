INSERT INTO subscription_frequencies
    (description, unit, unitsperissue, issuesperunit, displayorder)
VALUES
    ('2/day', 'day', 1, 2, 1),
    ('1/day', 'day', 1, 1, 2),
    ('3/week', 'week', 1, 3, 3),
    ('1/week', 'week', 1, 1, 4),
    ('1/2 weeks', 'week', 2, 1, 5),
    ('1/3 weeks', 'week', 3, 1, 6),
    ('1/month', 'month', 1, 1, 7),
    ('1/2 months', 'month', 2, 1, 8),
    ('1/3 months', 'month', 3, 1, 9),
    ('2/year', 'month', 6, 1, 10),
    ('1/year', 'year', 1, 1, 11),
    ('1/2 year', 'year', 2, 1, 12),
    ('Irregular', NULL, 1, 1, 13);
