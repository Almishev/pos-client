# 🔧 Customizing Admin User for Each Client

## Quick Guide

### For Each New Client:

1. **Edit the SQL file** before deployment:
   ```bash
   nano init-db/01-init.sql
   ```

2. **Find this section** (around line 37):
   ```sql
   INSERT INTO tbl_users (email, password, name, role, user_id, created_at, updated_at) 
   VALUES (
       'admin@abv.com',  -- ← Change this
       '$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa', 
       'Supermarket Admin',       -- ← Change this
       'ROLE_ADMIN',
       'admin001',               -- ← Change this
       NOW(),
       NOW()
   ) ON CONFLICT (user_id) DO NOTHING;
   ```

3. **Replace with client's data**:
   ```sql
   INSERT INTO tbl_users (email, password, name, role, user_id, created_at, updated_at) 
   VALUES (
       'admin@client-store.com',     -- Client's email
       '$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa', 
       'Client Store Admin',         -- Client's name
       'ROLE_ADMIN',
       'admin_client_001',          -- Unique ID
       NOW(),
       NOW()
   ) ON CONFLICT (user_id) DO NOTHING;
   ```

**Note**: The script now only creates the admin user. Categories, items, and customers can be added later through the web interface.

4. **Deploy to client**:
   ```bash
   git clone https://github.com/Almishev/pos-client.git
   cd pos-client
   ./install.sh
   ```

## Examples

### Example 1: Petar's Store
```sql
INSERT INTO tbl_users (email, password, name, role, user_id, created_at, updated_at) 
VALUES (
    'admin@petar-store.com', 
    '$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa', 
    'Петър Админ', 
    'ROLE_ADMIN',
    'admin_petar_001',
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO NOTHING;
```

### Example 2: Maria's Supermarket
```sql
INSERT INTO tbl_users (email, password, name, role, user_id, created_at, updated_at) 
VALUES (
    'admin@maria-supermarket.com', 
    '$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa', 
    'Мария Админ', 
    'ROLE_ADMIN',
    'admin_maria_001',
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO NOTHING;
```

## Important Notes

- **Password**: Always keep the same hash `$2a$10$EQscBVYmdrjfRz1bHJWUcu4gwBHmEuO6eAcRWxYjkpCxpOI9wFIwa` (password: `123456`)
- **user_id**: Must be unique for each client
- **Email**: Should be client's business email
- **Name**: Should be client's real name

## Alternative: Create Admin After Installation

If you prefer to create admin users after installation:

1. **Install system** with default admin
2. **Login** with `admin@abv.com` / `123456`
3. **Go to "Manage Users"** in the web interface
4. **Create new admin** through the UI
5. **Delete default admin** (optional)

## Troubleshooting

### If admin creation fails:
1. Check database logs: `docker-compose -f docker-compose.client.yml logs postgres`
2. Verify script ran: Look for "Database initialization completed successfully!" in logs
3. Test login: Try `admin@abv.com` / `123456`

### If you need to change password:
1. Generate new hash using backend endpoint: `POST /api/v1.0/encode`
2. Update the hash in SQL file
3. Redeploy system

---
**Remember**: Each client gets their own isolated POS system with their own admin user! 🎯
