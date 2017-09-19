ALTER TABLE borrowers MODIFY COLUMN login_attempts int(4) AFTER lang;
ALTER TABLE deletedborrowers MODIFY COLUMN login_attempts int(4) AFTER lang;
