# 🚀 Supermarket POS System - Installation Guide

## Quick Start for Clients

### Step 1: Download the System
```bash
git clone https://github.com/Almishev/pos-client.git
cd pos-client
```

### Step 2: First Installation Run
```bash
chmod +x *.sh
./install.sh
```

**What happens:**
- ✅ Installs Docker and Docker Compose
- ✅ Sets up proper permissions
- ⚠️ **You MUST log out and log back in**

### Step 3: Second Installation Run
```bash
./install.sh
```

**What happens:**
- ✅ Downloads POS system images
- ✅ Starts all services
- ✅ System is ready!

### Step 4: Access Your POS System
- Open browser: **http://localhost:3001**
- Login: `admin@abv.com` / `123456`

## Daily Usage

### Starting the System
```bash
cd pos-client
./start.sh
```

### Stopping the System
```bash
./stop.sh
```

### Checking Status
```bash
./status.sh
```

## Automatic Startup

The system will start automatically when you turn on your computer!

## Troubleshooting

### If installation fails:
1. Make sure you're not running as root
2. Log out and log back in after first run
3. Try again: `./install.sh`

### If system won't start:
```bash
./status.sh
./restart.sh
```

### For more help:
- Check `README.CLIENT.md` for detailed instructions
- Contact your system administrator

---
**Need help?** Contact: support@supermarket-pos.com
