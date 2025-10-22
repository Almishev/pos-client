# Database Initialization Script

## Overview
This directory contains the SQL script that initializes the Supermarket POS database with default data.

## Files
- `01-init.sql` - Main initialization script

## How It Works

### Problem Solved
The original script had timing issues where it tried to insert data before Hibernate (Spring Boot ORM) created the database tables, causing "relation does not exist" errors.

### Solution Implemented
The updated script includes:

1. **Table Existence Check**: Waits for Hibernate to create the `tbl_users` table before proceeding
2. **Timeout Protection**: Maximum 30 attempts (60 seconds) to prevent infinite waiting
3. **Safe Insertions**: Each INSERT statement is wrapped in conditional blocks that check for table existence
4. **Column Validation**: Checks for correct column structure before inserting data
5. **Error Handling**: Graceful handling of missing tables or columns

### Script Flow
```
1. Wait for tbl_users table to be created by Hibernate
2. Insert admin user (admin@abv.com / 123456)
3. Display success message
```

**Note**: Categories, items, and customers are not inserted automatically. They can be added later through the web interface for a cleaner initial setup.

## Customization for Different Clients

### To create a custom admin for a specific client:

1. **Edit the admin user section** in `01-init.sql`:
```sql
INSERT INTO tbl_users (email, password, name, role, user_id, created_at, updated_at) 
VALUES (
    'admin@client-store.com',  -- Change email
    '$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa',  -- Keep password hash
    'Client Store Admin',      -- Change name
    'ROLE_ADMIN',
    'admin_client_001',        -- Change user_id
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO NOTHING;
```

2. **Add sample data later** (optional):
   - Categories, items, and customers can be added through the web interface
   - This keeps the initial setup simple and clean

## Password Information
- **Default Password**: `123456`
- **Hash**: `$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa`
- **Algorithm**: BCrypt with strength 10

## Troubleshooting

### If the script fails:
1. Check PostgreSQL logs: `docker-compose -f docker-compose.client.yml logs postgres`
2. Verify tables exist: Connect to database and run `\dt`
3. Check if admin user was created: `SELECT * FROM tbl_users;`

### Common Issues:
- **"Timeout waiting for tables"**: Backend is taking too long to start
- **"Table does not exist"**: Hibernate hasn't created tables yet
- **"Admin user not created"**: Check if tbl_users table exists and has correct structure

## Testing
To test the script manually:
```bash
# Connect to database
docker exec -it pos-shop-db psql -U user1 -d billing_app

# Run the script
\i /docker-entrypoint-initdb.d/01-init.sql
```

## Notes
- The script is executed automatically when PostgreSQL container starts for the first time
- It only runs once (PostgreSQL remembers that initialization is complete)
- To re-run: Delete the database volume and restart containers
