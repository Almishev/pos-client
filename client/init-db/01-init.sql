-- Supermarket POS Database Initialization
-- This file will be executed when the PostgreSQL container starts for the first time
-- IMPORTANT: This script waits for Hibernate to create tables before inserting data

-- Wait for tables to be created by Hibernate (Spring Boot)
-- This prevents "relation does not exist" errors
DO $$
DECLARE
    table_exists boolean;
    max_attempts integer := 30;
    attempt integer := 0;
BEGIN
    -- Wait for tbl_users table to be created by Hibernate
    LOOP
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name = 'tbl_users'
        ) INTO table_exists;
        
        IF table_exists THEN
            EXIT;
        END IF;
        
        attempt := attempt + 1;
        IF attempt >= max_attempts THEN
            RAISE EXCEPTION 'Timeout waiting for tables to be created by Hibernate';
        END IF;
        
        -- Wait 2 seconds before checking again
        PERFORM pg_sleep(2);
    END LOOP;
    
    RAISE NOTICE 'Tables are ready, proceeding with data insertion...';
END $$;

-- Create initial admin user
-- Password: 123456 (hashed with BCrypt)
-- Check if admin user already exists before inserting
DO $$
BEGIN
    -- Check if admin user already exists
    IF NOT EXISTS (
        SELECT 1 FROM tbl_users 
        WHERE user_id = 'admin001' OR email = 'admin@abv.bg'
    ) THEN
        INSERT INTO tbl_users (email, password, name, role, user_id, created_at, updated_at) 
        VALUES (
            'admin@abv.bg', 
            '$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa', 
            'Supermarket Admin', 
            'ROLE_ADMIN',
            'admin001',
            NOW(),
            NOW()
        );
        RAISE NOTICE 'Admin user created successfully';
    ELSE
        RAISE NOTICE 'Admin user already exists, skipping creation';
    END IF;
END $$;

-- Note: Categories, items, and customers can be added later through the web interface
-- This keeps the initial setup simple and clean

-- Final success message
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully!';
    RAISE NOTICE 'Admin user: admin@abv.bg / 123456';
END $$;