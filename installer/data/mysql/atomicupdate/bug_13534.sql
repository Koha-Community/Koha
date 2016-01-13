ALTER TABLE tags_all MODIFY COLUMN borrowernumber INT(11);
ALTER TABLE tags_all drop FOREIGN KEY tags_borrowers_fk_1;
ALTER TABLE tags_all ADD CONSTRAINT `tags_borrowers_fk_1` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE tags_approval DROP FOREIGN KEY tags_approval_borrowers_fk_1;
ALTER TABLE tags_approval ADD CONSTRAINT `tags_approval_borrowers_fk_1` FOREIGN KEY (`approved_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE;
