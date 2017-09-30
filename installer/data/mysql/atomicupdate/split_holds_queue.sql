INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
('HoldsSplitQueue','nothing','nothing|branch|itemtype|branch_itemtype','In the staff client, split the holds view by the given criteria','Choice'),
('HoldsSplitQueueNumbering', 'actual', 'actual|virtual', 'If the holds queue is split, decide if the acual priorities should be displayed', 'Choice');
