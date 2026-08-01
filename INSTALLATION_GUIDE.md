# Инсталация на POS системата (Linux)

Това е **офиставният пакет** за магазински сървър (`pos-client`).  
Работи на **Linux Mint 20+ / Ubuntu 20.04+** с Docker.

| Компонент | Порт | Адрес |
|-----------|------|--------|
| Frontend (UI) | **3001** | http://SERVER_IP:3001 |
| Backend (API) | **8087** | http://SERVER_IP:8087/api/v1.0 |
| PostgreSQL | **5433** (на хоста) | само локално / Docker мрежа |

**Admin вход след инсталация:** `admin@abv.com` / `123456`  
(сменете паролата веднага след първия вход)

---

## 1. Изисквания

- Обикновен потребител (**не root**)
- Минимум **4 GB RAM** (препоръчително 8 GB)
- **20 GB** свободно място
- Интернет (първоначално — теглене на Docker образи)
- Препоръчително: **статичен LAN IP** на сървъра

Нужни команди (инсталират се при нужда):

```bash
sudo apt update
sudo apt install -y git curl openssl ca-certificates
```

---

## 2. Изтегляне

```bash
git clone https://github.com/Almishev/pos-client.git
cd pos-client
chmod +x *.sh
```

Уверете се, че сте в папката с файловете `install.sh` и `docker-compose.client.yml`.

---

## 3. Инсталация (две стъпки)

### Стъпка A — Docker

```bash
./install.sh
```

Скриптът инсталира `docker.io` + `docker-compose`, добавя потребителя в група `docker` и **спира**.

**Задължително:** излезте от сесията и влезте отново (или рестартирайте), за да важат правата за Docker.

### Стъпка B — старт на системата

```bash
cd ~/pos-client   # или пътят, където клонирахте
./install.sh
```

Това:

1. Създава `.env` от `env.example` (ако липсва)
2. Генерира по-сигурни `JWT_SECRET_KEY` и `SPRING_DATASOURCE_PASSWORD`
3. Тегли образите `antonalmishev/supermarket-pos-backend` и `…-frontend`
4. Стартира Postgres + backend + frontend

Отворете: **http://localhost:3001**

---

## 4. Ежедневна работа

```bash
./start.sh      # старт
./stop.sh       # стоп
./restart.sh    # рестарт
./status.sh     # статус
```

Логове:

```bash
docker-compose -f docker-compose.client.yml logs -f
# или на по-нови системи:
docker compose -f docker-compose.client.yml logs -f
```

---

## 5. Достъп от други компютри (каси)

По подразбиране UI вика API на `http://localhost:8087` — работи **само на сървъра**.

За каси в LAN:

```bash
./switch-network.sh
```

Скриптът записва `VITE_API_BASE_URL` и `ALLOWED_ORIGINS` в `.env` (браузерът не може да ползва Docker името `backend`).

После:

```bash
./restart.sh
hostname -I    # покажете IP на касите
```

На касата отворете: `http://SERVER_IP:3001`

### Firewall (на сървъра)

```bash
sudo ufw allow 3001/tcp
sudo ufw allow 8087/tcp
sudo ufw enable
sudo ufw status
```

В `.env` добавете произхода на UI в CORS, например:

```env
ALLOWED_ORIGINS=http://localhost:3001,http://192.168.80.101:3001
VITE_API_BASE_URL=http://192.168.80.101:8087/api/v1.0
BACKEND_URL=http://192.168.80.101:8087
SERVER_IP=192.168.80.101
```

След промяна на `.env`: `./restart.sh`

---

## 6. Автостарт при boot (systemd)

Файлът `pos-system.service` **не** се включва сам. Настройте го ръчно:

```bash
# 1) Сложете проекта на стабилен път (пример)
sudo mkdir -p /opt/pos-client
sudo cp -a ~/pos-client/. /opt/pos-client/
cd /opt/pos-client

# 2) Редактирайте WorkingDirectory в service файла, ако е различен
nano pos-system.service

# 3) Инсталирайте услугата
sudo cp pos-system.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pos-system
sudo systemctl start pos-system
sudo systemctl status pos-system
```

---

## 7. Backup и възстановяване

```bash
# Backup
docker exec pos-shop-db pg_dump -U user1 billing_app > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore (внимание: презаписва данни)
docker exec -i pos-shop-db psql -U user1 billing_app < backup_YYYYMMDD_HHMMSS.sql
```

Пазете и файла **`.env`** (пароли, JWT, IP настройки).

---

## 8. Обновяване на образите

```bash
./stop.sh
docker-compose -f docker-compose.client.yml pull
./start.sh
```

---

## 9. След инсталация (магазински чеклист)

1. Вход: `admin@abv.com` / `123456` → сменете паролата  
2. Създайте касиерски потребител  
3. Добавете категории и артикули (цени в **евро**)  
4. Регистрирайте **фискално устройство** (или тестово ACTIVE устройство)  
5. Стартирайте **работен ден** преди продажби  
6. Настройте LAN достъп (`switch-network.sh`), ако има втори компютър  

---

## 10. Чести проблеми

| Симптом | Какво да направите |
|---------|-------------------|
| `permission denied` за docker | Logout/login след първия `install.sh`; не ползвайте root |
| UI се отваря, login гърми от каса | Пускане на `./switch-network.sh` + firewall + `ALLOWED_ORIGINS` |
| Backend „not healthy“ | Изчакайте 1–2 мин; `./status.sh` и `logs` |
| Няма admin | Init SQL се изпълнява **само при празен** Postgres volume; при нужда вижте `CUSTOMIZE_ADMIN.md` |
| Стар volume / стара парола | Смяна на DB парола в `.env` без нов volume чупи връзката — дръжте същата парола или пресъздайте volume (губи данни) |

```bash
./status.sh
docker-compose -f docker-compose.client.yml ps
docker-compose -f docker-compose.client.yml logs --tail=100
./restart.sh
```

---

## 11. Архитектура накратко

- **Frontend** — React, порт 3001  
- **Backend** — Spring Boot, порт 8087, контекст `/api/v1.0`  
- **DB** — PostgreSQL 15 в Docker, хост порт 5433  

Образи: Docker Hub `antonalmishev/supermarket-pos-backend:latest` и `…-frontend:latest`.

---

**Официален пакет:** https://github.com/Almishev/pos-client  
**Admin:** `admin@abv.com` / `123456`
