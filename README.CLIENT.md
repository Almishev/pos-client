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
git clone https://github.com/your-repo/supermarket-pos.git
cd supermarket-pos/client-package

# Make scripts executable
chmod +x *.sh

# Run the installer (automatically creates .env with secure passwords)
./install.sh
```

### 🔐 Security Features
- **Automatic password generation** - Secure passwords are generated automatically
- **Environment variables** - All sensitive data is stored in .env file
- **No hardcoded secrets** - All credentials are configurable
- **Git-safe** - .env files are automatically ignored by git

### Installation Process

The installation is a **two-step process**:

#### **Step 1: First Run**
```bash
./install.sh
```
- Installs Docker and Docker Compose using standard Ubuntu/Mint packages
- Adds your user to the docker group
- **IMPORTANT:** You must log out and log back in after this step

#### **Step 2: Second Run**
```bash
./install.sh
```
- Downloads the POS system images from Docker Hub
- Starts all services
- System is ready to use!

### Why Two Steps?

This approach ensures:
- ✅ **Reliable installation** using standard system packages
- ✅ **Proper permissions** for Docker access
- ✅ **No corrupted files** from APT cache issues
- ✅ **Clean separation** between system setup and application deployment

## 🌐 Access the System

### Local Access
After installation, open your web browser and go to:
**http://localhost:3001**

### Network Access (from other computers)
To access from other computers in your network:
**http://[SERVER_IP]:3001**

Where `[SERVER_IP]` is the IP address of your server computer.

#### Finding Server IP Address
```bash
# Find server IP address
ip addr show | grep inet
# or
hostname -I
```

#### Firewall Configuration
```bash
# Allow access to POS system ports
sudo ufw allow 3001
sudo ufw allow 8087
sudo ufw enable
```

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
- `AWS_ACCESS_KEY` - AWS S3 access key (if using file upload)
- `AWS_SECRET_KEY` - AWS S3 secret key (if using file upload)
- `RAZORPAY_KEY_ID` - Razorpay key (if using payments)
- `RAZORPAY_KEY_SECRET` - Razorpay secret (if using payments)

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

### Database Backup
```bash
# Create backup
docker exec pos-shop-db pg_dump -U user1 billing_app > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
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

The system will start automatically when the server boots up:

```bash
# Create systemd service for automatic startup
sudo cp pos-system.service /etc/systemd/system/
sudo systemctl enable pos-system
sudo systemctl start pos-system
```

## 📝 License

This software is proprietary and licensed for use by authorized customers only.

---

**Supermarket POS System v1.0**  
*Professional Point of Sale Solution*
