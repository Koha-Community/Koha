INSERT INTO permissions (module_bit, code, description) VALUES (11, 'suggestions_manage', 'Manage purchase suggestions');

INSERT INTO user_permissions (borrowernumber, module_bit, code)
  SELECT borrowernumber, 11, 'suggestions_manage' FROM borrowers WHERE flags & (1 << 2);

-- Bug 19911: Add new permission suggestions_manage and update staff users
