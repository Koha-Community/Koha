CREATE TABLE library_groups (
    id INT(11) NOT NULL auto_increment,    -- unique id for each group
    parent_id INT(11) NULL DEFAULT NULL,   -- if this is a child group, the id of the parent group
    branchcode VARCHAR(10) NULL DEFAULT NULL, -- The branchcode of a branch belonging to the parent group
    title VARCHAR(100) NULL DEFAULT NULL,     -- Short description of the goup
    description TEXT NULL DEFAULT NULL,    -- Longer explanation of the group, if necessary
    created_on DATETIME NOT NULL,          -- Date and time of creation
    updated_on DATETIME NULL DEFAULT NULL, -- Date and time of last
    PRIMARY KEY id ( id ),
    FOREIGN KEY (parent_id) REFERENCES library_groups(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (branchcode) REFERENCES branches(branchcode) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
