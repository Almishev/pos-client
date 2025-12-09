# Решение на проблем: Отчетът показва нули

## Проблем

Касиерът прави продажби, но когато генерира отчет (Z-отчет), показва само нули.

## Причина

Отчетът търси поръчки по `cashier_username` поле. Ако поръчките са направени от друг потребител (например admin), отчетът няма да ги намери.

## Диагностика

Изпълнете диагностичния скрипт:
```bash
cd /home/anton/supermarket-pos/client
./check-report-issue.sh
```

Това ще покаже:
- Кои поръчки има в базата данни
- С какъв `cashier_username` са записани
- Кои cash drawer sessions има
- Какво точно търси отчетът

## Решение

### Стъпка 1: Уверете се, че касиерът е правилно логнат

1. Касиерът трябва да се логне като: `pet@abv.bg`
2. **НЕ** като: `admin@abv.bg`

### Стъпка 2: Започнете работен ден

1. Касиерът трябва да отиде в "Контрол на касата"
2. Да започне работен ден с:
   - Начална сума
   - Избрано фискално устройство

### Стъпка 3: Направете продажби

1. Касиерът трябва да направи продажби **след** като е започнал работен ден
2. Поръчките ще се записват с `cashier_username = 'pet@abv.bg'`

### Стъпка 4: Генерирайте отчет

1. Касиерът трябва да генерира Z-отчет (Shift Report)
2. Отчетът ще намери поръчките, защото `cashier_username` ще съвпада

## Проверка

След като касиерът направи продажби, проверете:

```bash
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT 
    order_id, 
    cashier_username, 
    total_amount, 
    created_at
FROM tbl_orders 
ORDER BY created_at DESC 
LIMIT 5;
"
```

Трябва да видите поръчки с `cashier_username = 'pet@abv.bg'`.

## Важно

- **Поръчките направени от admin няма да се покажат в касиерския отчет**
- **Касиерът трябва да е правилно логнат при правене на продажби**
- **Трябва да има активна cash drawer session**

## Ако проблемът продължава

1. Проверете логовете на backend:
   ```bash
   docker logs pos-shop-backend --tail 50 | grep -i "shift report\|cashier"
   ```

2. Проверете дали поръчките се записват правилно:
   ```bash
   docker exec pos-shop-db psql -U user1 -d billing_app -c "
   SELECT COUNT(*) FROM tbl_orders WHERE cashier_username = 'pet@abv.bg';
   "
   ```

3. Проверете cash drawer sessions:
   ```bash
   docker exec pos-shop-db psql -U user1 -d billing_app -c "
   SELECT * FROM tbl_cash_drawer_sessions ORDER BY session_start_time DESC LIMIT 3;
   "
   ```

---

**Важно:** Отчетът търси поръчки по `cashier_username`. Ако поръчките са направени от друг потребител, няма да се намерят!

