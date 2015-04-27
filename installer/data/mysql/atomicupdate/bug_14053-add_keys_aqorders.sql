ALTER IGNORE TABLE `aqorders`
    ADD KEY `parent_ordernumber` (`parent_ordernumber`),
    ADD KEY `orderstatus` (`orderstatus`)
;