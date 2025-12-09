# Решение на проблем: Поръчки с грешен cashier_username

## Проблем

Когато работите като admin, а след това като касиер от същия браузър, поръчките се записват с `cashier_username = 'admin@abv.bg'` вместо `'pet@abv.bg'`.

## Причина

При смяна на потребител в същия браузър, старият JWT token може да остане в браузъра или да се използва кеширан token. Това води до това, че поръчките се записват с неправилния `cashier_username`.

## Решение (вече приложено)

Направих следните промени:

1. **По-надеждно изчистване на localStorage при login:**
   - Изчистване на всички възможни auth ключове
   - Малка забавяне за да гарантираме изчистването
   - Принудително обновяване на страницата

2. **По-надеждно изчистване при logout:**
   - Изчистване на всички възможни auth ключове
   - Принудителна навигация с `replace: true`

## Как да тествате

### Стъпка 1: Рестартирайте frontend

```bash
cd /home/anton/supermarket-pos/client
docker-compose restart frontend
```

Или за пълно rebuild:

```bash
docker-compose down
docker-compose up -d --build frontend
```

### Стъпка 2: Тестване

1. **Отворете браузър в инкогнито режим** (за да избегнете кеш проблеми)
2. **Логнете се като admin:**
   - Email: `admin@abv.bg`
   - Password: `123456`
3. **Направете тестова поръчка** (не е задължително да я завършите)
4. **Logout-нете се** (кликнете на logout)
5. **Логнете се като касиер:**
   - Email: `pet@abv.bg`
   - Password: `123456`
6. **Започнете работен ден** (Cash Drawer Session)
7. **Направете продажба**
8. **Проверете в базата данни:**

```bash
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT order_id, cashier_username, total_amount, created_at 
FROM tbl_orders 
ORDER BY created_at DESC 
LIMIT 3;
"
```

Трябва да видите поръчка с `cashier_username = 'pet@abv.bg'`.

## Алтернативно решение (ако проблемът продължава)

Ако проблемът продължава след рестарт, опитайте:

1. **Изчистете browser cache:**
   - Chrome: Ctrl+Shift+Delete → Clear browsing data
   - Firefox: Ctrl+Shift+Delete → Clear recent history
   - Или използвайте инкогнито режим

2. **Hard refresh на страницата:**
   - Chrome/Firefox: Ctrl+Shift+R
   - Или Ctrl+F5

3. **Проверете дали token се обновява:**
   - Отворете Developer Tools (F12)
   - Отидете в Application/Storage → Local Storage
   - Проверете дали `token` се обновява при login

## Проверка

След като касиерът направи продажба, проверете:

```bash
# Проверка на последните поръчки
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT order_id, cashier_username, total_amount, created_at 
FROM tbl_orders 
ORDER BY created_at DESC 
LIMIT 5;
"

# Проверка на cashier_username за днес
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT cashier_username, COUNT(*) as orders_count, SUM(total_amount) as total_sales
FROM tbl_orders 
WHERE created_at >= CURRENT_DATE
GROUP BY cashier_username;
"
```

Трябва да видите поръчки с правилния `cashier_username`.

## Важно

- **Винаги logout-вайте се преди смяна на потребител**
- **Използвайте инкогнито режим за тестване** (за да избегнете кеш проблеми)
- **Проверявайте cashier_username в базата данни** след продажби

---

**След рестарт на frontend, проблемът трябва да е решен!**

