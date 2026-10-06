-- Digit-only POS login passwords (BCrypt).
-- Admin: 000000 | others: 111111, 222222, 333333, 444444 by email.
-- Run against billing_app (psql / pgAdmin). Safe to re-run.

UPDATE tbl_users
SET password = '$2b$10$IGLun.l.Tq9SyTF.KUKZLOZ5U3ZFps1AkzpN.1cdGfptoLuWchtQe',
    updated_at = NOW()
WHERE email = 'antonalmishev@abv.bg';

UPDATE tbl_users
SET password = '$2b$10$lkMnF2DHTz0J964faO/wIe8.Lik5pO01zy7VnmGCrefXmOA2LTgn.',
    updated_at = NOW()
WHERE email = 'petq@abv.bg';

UPDATE tbl_users
SET password = '$2b$10$Bql.3aTNhazzyUOT2yqV9.P2n1wZD.5xgfWJYVu10y8MzF2Po11Fa',
    updated_at = NOW()
WHERE email = 'kiro@abv.bg';

UPDATE tbl_users
SET password = '$2b$10$/JF0iVXtMokC0t4WIWEBDePsSIpisPSYltZmniIFAZBcZ//53Ws2O',
    updated_at = NOW()
WHERE email = 'test@abv.bg';

UPDATE tbl_users
SET password = '$2b$10$8wpRNLyAmQPW7wMLXsE/aOeCAQJZwOYMHoyWNy7ej6bDCnkwWZ.TW',
    updated_at = NOW()
WHERE email = 'x@test.com';

-- Seed admin (fresh installs) if present
UPDATE tbl_users
SET password = '$2b$10$IGLun.l.Tq9SyTF.KUKZLOZ5U3ZFps1AkzpN.1cdGfptoLuWchtQe',
    updated_at = NOW()
WHERE email IN ('admin@abv.com', 'admin@abv.bg');
