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

От UI: **Отчети → Backup на базата** (локално / AWS). Файлове: `archives/db-backups/`.

Или ръчно:
```bash
docker exec pos-shop-db pg_dump -U user1 billing_app > backup_$(date +%Y%m%d).sql
```

Restore от `.sql.gz`:
```bash
gunzip -c archives/db-backups/backup_....sql.gz | docker exec -i pos-shop-db psql -U user1 billing_app
```

Пазете и файла `.env`.
