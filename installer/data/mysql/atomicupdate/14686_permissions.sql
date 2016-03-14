-- Insert permission
INSERT IGNORE INTO permissions (module_bit, code, description) VALUES
    (13, 'upload_general_files', 'Upload any file'),
    (13, 'upload_manage', 'Manage uploaded files');

-- Update user_permissions for current users (check count in uploaded_files)
-- Note 9 == edit_catalogue and 13 == tools
-- We do not insert if someone is superlibrarian, does not have edit_catalogue,
-- or already has all tools
INSERT IGNORE INTO user_permissions (borrowernumber, module_bit, code)
    SELECT borrowernumber, 13, 'upload_general_files'
    FROM borrowers bo
    WHERE flags<>1 AND flags & POW(2,13) = 0 AND
        ( flags & POW(2,9) > 0 OR (
            SELECT COUNT(*) FROM user_permissions
            WHERE borrowernumber=bo.borrowernumber AND module_bit=9 ) > 0 )
        AND ( SELECT COUNT(*) FROM uploaded_files ) > 0

# Copy-paste for RM use:
#    print "Upgrade to $DBversion done (Bug 14686 - New menu option and permission for file uploading)\n";
