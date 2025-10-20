-- Supermarket POS Database Initialization
-- This file will be executed when the PostgreSQL container starts for the first time

-- Create initial admin user
-- Password: 123456 (hashed with BCrypt)
INSERT INTO tbl_users (email, password, name, role, user_id, created_at, updated_at) 
VALUES (
    'admin@supermarket.com', 
    '$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa', 
    'Supermarket Admin', 
    'ROLE_ADMIN',
    'admin001',
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO NOTHING;

-- Create initial categories
INSERT INTO tbl_category (name, description, created_at, updated_at) 
VALUES 
    ('Храна', 'Хранителни продукти', NOW(), NOW()),
    ('Напитки', 'Различни напитки', NOW(), NOW()),
    ('Козметика', 'Козметични продукти', NOW(), NOW()),
    ('Домакинство', 'Домакински продукти', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- Create sample items
INSERT INTO tbl_items (name, price, category_id, stock_quantity, barcode, created_at, updated_at) 
VALUES 
    ('Хляб', 2.50, 1, 100, '1234567890123', NOW(), NOW()),
    ('Мляко', 3.20, 1, 50, '1234567890124', NOW(), NOW()),
    ('Кока Кола', 2.80, 2, 200, '1234567890125', NOW(), NOW()),
    ('Вода', 1.50, 2, 150, '1234567890126', NOW(), NOW())
ON CONFLICT DO NOTHING;

-- Create sample customer
INSERT INTO tbl_customers (name, email, phone, address, created_at, updated_at) 
VALUES 
    ('Общ клиент', 'customer@general.com', '0000000000', 'Общ адрес', NOW(), NOW())
ON CONFLICT DO NOTHING;