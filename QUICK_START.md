# Бърз старт — POS на Linux

За магазински сървър (Linux Mint / Ubuntu). Подробности: [INSTALLATION_GUIDE.md](./INSTALLATION_GUIDE.md)

## Инсталация

```bash
sudo apt update && sudo apt install -y git curl openssl
git clone https://github.com/Almishev/pos-client.git
cd pos-client
chmod +x *.sh
./install.sh
# → излезте и влезте отново
./install.sh
```

Отворете **http://localhost:3001**  
Вход: **admin@abv.com** / **123456**

## Управление

```bash
./start.sh
./stop.sh
./restart.sh
./status.sh
```

## Други компютри в магазина

```bash
./switch-network.sh
./restart.sh
hostname -I
```

На касата: `http://SERVER_IP:3001`  
Firewall: `sudo ufw allow 3001 && sudo ufw allow 8087`

## Backup

От UI: **Отчети → Backup на базата** (локално / AWS). Нощен backup в **03:00**, пазене **30 дни**.

По подразбиране файловете са в `archives/db-backups/`. За флашка/външен диск в `.env`:
```
BACKUP_HOST_PATH=E:/POS-backups
# Linux: BACKUP_HOST_PATH=/mnt/external/pos-backups
```
Дискът трябва да е монтиран преди 03:00; след промяна на пътя — restart на backend.

Или ръчно:
```bash
docker exec pos-shop-db pg_dump -U user1 billing_app > backup_$(date +%Y%m%d).sql
```

Restore от `.sql.gz`:
```bash
gunzip -c archives/db-backups/backup_....sql.gz | docker exec -i pos-shop-db psql -U user1 billing_app
# или от пътя в BACKUP_HOST_PATH
```

Пазете и файла `.env`.
