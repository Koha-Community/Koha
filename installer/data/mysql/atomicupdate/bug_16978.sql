INSERT IGNORE INTO `permissions`
    (module_bit, code,             description) VALUES
    (16,         'delete_reports', 'Delete SQL reports');

INSERT IGNORE INTO user_permissions
    (borrowernumber,      module_bit,code)
    SELECT borrowernumber,module_bit,'delete_reports'
        FROM user_permissions
        WHERE module_bit=16 AND code='create_reports';
