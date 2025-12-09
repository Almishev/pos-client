# 🚀 Бърз старт - Supermarket POS System

## 📋 За клиентите на Linux Mint

### 1. Инсталация (една команда)
```bash
# Клонирайте и инсталирайте
git clone https://github.com/your-repo/supermarket-pos.git
cd supermarket-pos/client-package
chmod +x *.sh
./install.sh
```

### 2. Следващи стъпки
1. **Излезте и влезте отново** в системата (за docker групата)
2. **Стартирайте отново**: `./install.sh`
3. **Отворете браузъра**: http://localhost:3001
4. **Влезте с**: admin@abv.bg / 123456

### 3. Управление на системата
```bash
./start.sh    # Стартиране
./stop.sh     # Спиране
./restart.sh  # Рестартиране
./status.sh   # Проверка на състоянието
```

### 4. Достъп от мрежата
- **Локално**: http://localhost:3001
- **От други компютри**: http://[SERVER_IP]:3001

Намерете IP адреса:
```bash
hostname -I
```

### 5. Настройка на firewall
```bash
sudo ufw allow 3001
sudo ufw allow 8087
sudo ufw enable
```

## 🔐 Сигурност

- ✅ **Автоматично генерирани пароли** - Системата създава сигурни пароли автоматично
- ✅ **Environment variables** - Всички чувствителни данни са в .env файл
- ✅ **Git-safe** - .env файловете не се комитират
- ✅ **Без хардкодирани секрети** - Всички credentials са конфигурируеми

## ⚠️ Важни бележки

1. **Сменете паролата** след първото влизане
2. **Запазете .env файла** - съдържа важни пароли
3. **Регулярни backup-и** - използвайте `./backup.sh` (ако съществува)
4. **Обновяване**: `./stop.sh && docker-compose pull && ./start.sh`

## 🆘 При проблеми

```bash
# Проверете състоянието
./status.sh

# Проверете логите
docker-compose -f docker-compose.client.yml logs

# Рестартирайте системата
./restart.sh
```

## 📞 Поддръжка

- **Email**: support@supermarket-pos.com
- **Phone**: +359 XXX XXX XXX
- **Documentation**: https://docs.supermarket-pos.com

---

**🎉 Готово! Вашата POS система е готова за използване!**
