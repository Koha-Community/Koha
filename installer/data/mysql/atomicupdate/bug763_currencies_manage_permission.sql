INSERT INTO permissions (module_bit, code, description) VALUES (11, 'currencies_manage', 'Manage currencies and exchange rates');

INSERT INTO user_permissions (borrowernumber, module_bit, code)
  SELECT borrowernumber, 11, 'currencies_manage' FROM borrowers WHERE flags & (1 << 3) OR borrowernumber IN
  (SELECT borrowernumber FROM user_permissions WHERE code = 'parameters_remaining_permissions');

-- Bug 7651: Add new permission currencies_manage and update staff users
