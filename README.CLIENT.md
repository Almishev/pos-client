# Supermarket POS System - Client Installation

Complete POS (Point of Sale) system for supermarkets with modern web interface.

## 🚀 Quick Installation

### Prerequisites
- **Linux Mint 20+** (Ubuntu 20.04+ based)
- **4GB RAM minimum**
- **Internet connection** (for initial download)

### One-Command Installation

```bash
# Download and run installer
wget https://your-domain.com/install.sh
chmod +x install.sh
./install.sh
```

### Manual Installation

1. **Install Docker:**
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
# Log out and log back in
```

2. **Download POS System:**
```bash
wget https://your-domain.com/supermarket-pos.zip
unzip supermarket-pos.zip
cd supermarket-pos
```

3. **Start the system:**
```bash
chmod +x *.sh
./install.sh
```

## 🌐 Access the System

After installation, open your web browser and go to:
**http://localhost:3001**

### Default Login Credentials
- **Email:** `admin@supermarket.com`
- **Password:** `123456`

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
```

### Database Issues
```bash
# Check database logs
docker-compose -f docker-compose.client.yml logs postgres

# Restart database
docker-compose -f docker-compose.client.yml restart postgres
```

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

## 📝 License

This software is proprietary and licensed for use by authorized customers only.

---

**Supermarket POS System v1.0**  
*Professional Point of Sale Solution*
