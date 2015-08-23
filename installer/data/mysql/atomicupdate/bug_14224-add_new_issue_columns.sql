ALTER IGNORE TABLE issues ADD `note` mediumtext default NULL AFTER `onsite_checkout`;
ALTER IGNORE TABLE issues ADD `notedate` datetime default NULL AFTER `note`;
ALTER IGNORE TABLE old_issues ADD `note` mediumtext default NULL AFTER `onsite_checkout`;
ALTER IGNORE TABLE old_issues ADD `notedate` datetime default NULL AFTER `note`;
