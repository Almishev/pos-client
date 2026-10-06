# Supermarket POS System - Client Installation

Complete POS (Point of Sale) system for supermarkets with modern web interface.

## 🚀 Quick Installation

### System Requirements
- **OS:** Linux Mint 20+ (Ubuntu 20.04+ based)
- **RAM:** 4GB minimum (8GB recommended)
- **Storage:** 20GB free space
- **Network:** Ethernet connection recommended
- **User:** Regular user account (not root)

### Server Setup
- **CPU:** Dual-core minimum (Quad-core recommended)
- **RAM:** 8GB recommended for multiple users
- **Storage:** SSD recommended for better performance
- **Network:** Static IP address recommended

### Installation

```bash
# Clone the repository
git clone https://github.com/Almishev/pos-client.git
cd pos-client

# Make scripts executable
chmod +x *.sh

# Run the installer (creates .env; may generate DB/JWT secrets)
./install.sh
```

Follow the **two-step** install (logout/login after Docker is installed), then run `./install.sh` again.

Full guide (Bulgarian): see **[INSTALLATION_GUIDE.md](./INSTALLATION_GUIDE.md)** and **[QUICK_START.md](./QUICK_START.md)**.

### Default Login Credentials
- **Email:** `admin@abv.com`
- **Password:** `123456`

### 🔧 Environment Configuration

The system automatically creates a `.env` file with secure passwords during installation. You can customize the configuration by editing the `.env` file:

```bash
# Edit environment variables
nano .env
```

**Important environment variables:**
- `SPRING_DATASOURCE_PASSWORD` - Database password (auto-generated)
- `JWT_SECRET_KEY` - JWT secret key (auto-generated)
- `VITE_API_BASE_URL` - Browser → API URL (`http://localhost:8087/api/v1.0` or `http://SERVER_IP:8087/api/v1.0`)
- `ALLOWED_ORIGINS` - CORS origins for the UI (include every shop PC URL)
- `AWS_ACCESS_KEY` / `AWS_SECRET_KEY` - optional S3
- `RAZORPAY_KEY_ID` / `RAZORPAY_KEY_SECRET` - optional payments

For other PCs in the shop: `./switch-network.sh` then `./restart.sh`.

**Security Note:** The `.env` file contains sensitive information and is automatically ignored by git. Never commit this file to version control.

## 🎯 Features

- **Modern Web Interface** - Responsive design for any device
- **Inventory Management** - Track products, categories, and stock
- **Sales Processing** - Complete POS functionality
- **Customer Management** - Store customer information
- **Reports & Analytics** - Sales reports and statistics
- **Barcode Scanning** - Support for barcode scanners
- **Multi-user Support** - Role-based access (Admin/User)
- **Offline Capability** - Works without internet connection

## 🔧 Management Commands

```bash
# Start the system
./start.sh

# Stop the system
./stop.sh

# Restart the system
./restart.sh

# Check status
./status.sh

# View logs
docker-compose -f docker-compose.client.yml logs
```

## 📊 System Architecture

The system consists of three main components:

1. **Frontend** (React.js)
   - Port: 3001
   - Modern web interface
   - Real-time updates

2. **Backend** (Spring Boot)
   - Port: 8087
   - REST API
   - Business logic

3. **Database** (PostgreSQL)
   - Port: 5433
   - Data storage
   - Automatic backups

## 🔒 Security Features

- **JWT Authentication** - Secure token-based authentication
- **Role-based Access** - Admin and User roles
- **Data Encryption** - Passwords and sensitive data encrypted
- **Network Isolation** - Docker network security

## 📱 Supported Devices

- **Desktop Computers** - Full functionality
- **Tablets** - Touch-optimized interface
- **Mobile Phones** - Responsive design
- **Barcode Scanners** - USB and Bluetooth support

## 🛠️ Troubleshooting

### Installation Issues

#### **"Docker group does not exist" Error**
```bash
# Clean APT cache and reinstall
sudo apt clean
sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl start docker
sudo usermod -aG docker $USER
# Log out and log back in
```

#### **"Permission denied" Error**
```bash
# Make sure you're not running as root
whoami
# Should show your username, not 'root'

# If you ran as root, switch to regular user
su - your_username
```

#### **"APT cache corrupted" Error**
```bash
# Clean and fix APT cache
sudo apt clean
sudo apt update --fix-missing
sudo apt install -f
```

### System Won't Start
```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check logs
./status.sh
```

### Can't Access Web Interface
```bash
# Check if services are running
docker-compose -f docker-compose.client.yml ps

# Check port availability
netstat -tlnp | grep :3001

# Check if Docker is running
docker info
```

### Database Issues
```bash
# Check database logs
docker-compose -f docker-compose.client.yml logs postgres

# Restart database
docker-compose -f docker-compose.client.yml restart postgres
```

### Common Solutions

#### **If installation fails on first run:**
1. Log out and log back in
2. Run `./install.sh` again

#### **If images fail to download:**
1. Check internet connection
2. Try: `docker-compose -f docker-compose.client.yml pull`

#### **If services won't start:**
1. Check logs: `docker-compose -f docker-compose.client.yml logs`
2. Restart: `./restart.sh`

## 📞 Support

For technical support, please contact:
- **Email:** support@supermarket-pos.com
- **Phone:** +359 XXX XXX XXX
- **Documentation:** https://docs.supermarket-pos.com

## 🔄 Updates

To update the system:
```bash
# Stop the system
./stop.sh

# Pull latest images
docker-compose -f docker-compose.client.yml pull

# Start the system
./start.sh
```

## 💾 Backup & Maintenance

Full PostgreSQL dump (`.sql.gz`). **Does not delete** live DB data. Admin only.

### From the UI
**Reports → Export data → Database backup**
- **Backup локално** — writes to the configured local/USB path
- **Backup в AWS** — uploads to S3 and keeps a local copy
- List / download existing local files

### Automatic schedule
- Nightly local backup at **03:00**
- If the PC was off at 03:00, a **catch-up** backup runs on next backend start
- Files older than **30 days** are pruned (`BACKUP_RETENTION_DAYS`)

### Where files are stored

| Setup | Config | Example |
|-------|--------|---------|
| Docker (shop server) | `BACKUP_HOST_PATH` in `.env` (host mount) | `E:/shop-backups` or `/mnt/external/pos-backups` |
| Local Spring (no Docker) | `BACKUP_LOCAL_DIR` / default in `application.properties` | `E:/shop-backups` |

Docker compose mounts `${BACKUP_HOST_PATH}` → `/app/archives/db-backups` and sets `BACKUP_LOCAL_DIR=/app/archives/db-backups` inside the container.

```env
BACKUP_RETENTION_DAYS=30
BACKUP_SCHEDULE_ENABLED=true
BACKUP_HOST_PATH=E:/shop-backups
```

The disk must be plugged in / mounted before 03:00. If Windows changes the USB drive letter, update `.env` and recreate the backend container. Keep a copy of **`.env`** with the backups (passwords, JWT, IPs). On each successful DB backup the backend also copies the shop `.env` to the backup folder as `pos-client.env` (Docker mounts `./.env` read-only into the container).

### Restore (disaster recovery — overwrites DB)

1. **Stop the backend** (do not let Hibernate create empty tables first).
2. Recreate an empty database:
```sql
-- connect to database "postgres", not billing_app
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'billing_app' AND pid <> pg_backend_pid();

DROP DATABASE IF EXISTS billing_app;
CREATE DATABASE billing_app OWNER user1;
```
3. Restore **before** starting the app:
```bash
# Docker
gunzip -c /path/to/backup_YYYYMMDD_HHMMSS.sql.gz | docker exec -i pos-shop-db psql -U user1 billing_app

# Local PostgreSQL (after decompressing .gz to .sql)
psql -h localhost -U user1 -d billing_app -f backup_YYYYMMDD_HHMMSS.sql
```
4. Start backend / frontend and log in.

### Manual CLI dump
```bash
docker exec pos-shop-db pg_dump -U user1 billing_app > backup_$(date +%Y%m%d_%H%M%S).sql
docker exec -i pos-shop-db psql -U user1 billing_app < backup_file.sql
```

### System Maintenance
```bash
# Check system status
./status.sh

# View logs
docker-compose -f docker-compose.client.yml logs

# Clean up old Docker images
docker system prune -a
```

## 🚀 Automatic Startup

Automatic boot is **optional**. Edit `WorkingDirectory` in `pos-system.service` (default `/opt/pos-client`), then:

```bash
sudo cp pos-system.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pos-system
sudo systemctl start pos-system
```

See [INSTALLATION_GUIDE.md](./INSTALLATION_GUIDE.md) section 6.

## 📝 License

This software is proprietary and licensed for use by authorized customers only.

---

**Supermarket POS System v1.0**  
*Professional Point of Sale Solution*
