UPDATE permissions SET description = 'Manage budgets' WHERE code = 'period_manage';
UPDATE permissions SET description = 'Manage funds' WHERE code = 'budget_manage';
UPDATE permissions SET description = 'Modify funds (can''t create lines, but can modify existing ones)' WHERE code = 'budget_modify';
UPDATE permissions SET description = 'Manage baskets and order lines' WHERE code = 'order_manage';
UPDATE permissions SET description = 'Manage all baskets and order lines, regardless of restrictions on them' WHERE code = 'order_manage_all';
UPDATE permissions SET description = 'Manage basket groups' WHERE code = 'group_manage';
UPDATE permissions SET description = 'Receive orders and manage shipments' WHERE code = 'order_receive';
UPDATE permissions SET description = 'Add and delete funds (but can''t modify funds)' WHERE code = 'budget_add_del';
UPDATE permissions SET description = 'Manage all funds' WHERE code = 'budget_manage_all';

/* Bug 3849: Rephrase acquisition permissions to be more clear */
