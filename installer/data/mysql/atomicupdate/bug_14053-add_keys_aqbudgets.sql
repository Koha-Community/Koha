ALTER IGNORE TABLE `aqbudgets`
    ADD KEY `budget_parent_id` (`budget_parent_id`),
    ADD KEY `budget_code` (`budget_code`),
    ADD KEY `budget_branchcode` (`budget_branchcode`),
    ADD KEY `budget_period_id` (`budget_period_id`),
    ADD KEY `budget_owner_id` (`budget_owner_id`)
;