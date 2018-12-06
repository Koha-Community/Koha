UPDATE permissions SET code = "manage_didyoumean" WHERE code = "manage_didyouean";
UPDATE user_permissions SET code = "manage_didyoumean" WHERE code = "manage_didyouean";

-- Bug 21961 - Fix typo in manage_didyoumean permission
