#!/bin/bash

echo "=========================================="
echo "  Fiscal Report Issue Diagnostics"
echo "=========================================="
echo ""

echo "=== Step 1: Check Orders ==="
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT 
    order_id, 
    cashier_username, 
    total_amount, 
    created_at::date as order_date,
    created_at::time as order_time
FROM tbl_orders 
ORDER BY created_at DESC 
LIMIT 10;
" 2>/dev/null

echo ""
echo "=== Step 2: Check Cash Drawer Sessions ==="
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT 
    session_id,
    cashier_username,
    device_serial_number,
    session_start_time::date as session_date,
    session_start_time::time as start_time,
    CASE WHEN session_end_time IS NULL THEN 'ACTIVE' ELSE 'CLOSED' END as status
FROM tbl_cash_drawer_sessions 
ORDER BY session_start_time DESC 
LIMIT 5;
" 2>/dev/null

echo ""
echo "=== Step 3: Check Users ==="
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT 
    user_id,
    email,
    name,
    role
FROM tbl_users 
WHERE role IN ('ROLE_USER', 'ROLE_ADMIN');
" 2>/dev/null

echo ""
echo "=== Step 4: Check Fiscal Reports ==="
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT 
    id,
    report_type,
    report_date,
    cashier_name,
    total_sales,
    total_receipts,
    generated_at::timestamp as generated_time
FROM tbl_fiscal_reports 
ORDER BY generated_at DESC 
LIMIT 5;
" 2>/dev/null

echo ""
echo "=== Step 5: Test Query (What report would find) ==="
echo "Testing query for cashier 'pet@abv.bg' today:"
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT 
    COUNT(*) as orders_count,
    COALESCE(SUM(total_amount), 0) as total_sales
FROM tbl_orders 
WHERE LOWER(TRIM(cashier_username)) = LOWER(TRIM('pet@abv.bg'))
AND created_at >= CURRENT_DATE;
" 2>/dev/null

echo ""
echo "Testing query for cashier 'admin@abv.bg' today:"
docker exec pos-shop-db psql -U user1 -d billing_app -c "
SELECT 
    COUNT(*) as orders_count,
    COALESCE(SUM(total_amount), 0) as total_sales
FROM tbl_orders 
WHERE LOWER(TRIM(cashier_username)) = LOWER(TRIM('admin@abv.bg'))
AND created_at >= CURRENT_DATE;
" 2>/dev/null

echo ""
echo "=========================================="
echo "  Analysis"
echo "=========================================="
echo ""
echo "Проблем: Отчетът показва нули, защото:"
echo ""
echo "1. Проверете дали касиерът е правилно логнат"
echo "   - Касиерът трябва да е логнат като: pet@abv.bg"
echo "   - НЕ като: admin@abv.bg"
echo ""
echo "2. Проверете дали поръчките са направени от правилния потребител"
echo "   - Поръчките трябва да имат cashier_username = 'pet@abv.bg'"
echo "   - Ако имат cashier_username = 'admin@abv.bg', значи са направени от admin"
echo ""
echo "3. Решение:"
echo "   - Касиерът трябва да се логне като: pet@abv.bg"
echo "   - Да направи нови продажби"
echo "   - Да генерира отчет отново"
echo ""
echo "=========================================="

