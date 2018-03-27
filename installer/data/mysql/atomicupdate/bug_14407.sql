INSERT IGNORE INTO systempreferences
    ( `variable`, `value`, `options`, `explanation`, `type` )
VALUES
('SelfCheckAllowByIPRanges','',NULL,'(Leave blank if not used. Use ranges or simple ip addresses separated by spaces, like <code>192.168.1.1 192.168.0.0/24</code>.)','Short');
