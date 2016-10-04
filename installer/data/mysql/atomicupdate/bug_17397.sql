ALTER TABLE `messages`
ADD `manager_id` int(11) NULL,
ADD FOREIGN KEY (`manager_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL;
