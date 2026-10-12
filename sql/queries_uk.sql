-- Завдання 3.1 Загальні показники за рік: виручка, кількість замовлень, кількість проданих піц, середній чек,
-- середня кількість піц у замовленні. Кількість піц рахуйте з урахуванням quantity.

SELECT 
SUM(p.price * od.quantity) AS revenue,
COUNT(DISTINCT od.order_id) AS orders_cnt,
SUM(od.quantity) As pizzas_sold,
ROUND(SUM(p.price * od.quantity) / COUNT(DISTINCT order_id), 2) AS avg_check,
ROUND(CAST(SUM(od.quantity) AS REAL) / COUNT(DISTINCT od.order_id), 1)  AS avg_pizzas_per_order
FROM pizzas AS p
JOIN order_details AS od
 	ON p.pizza_id = od.pizza_id;

-- Висновок:
-- У 2015 році піцерія отримала $817 860.05 виручки з 21 350 замовлень і 49 574 проданих піц.
-- Одне замовлення в середньому приносило $38.31 і містило 2.3 піци.

-- Завдання 3.2 Динаміка по місяцях: виручка і кількість замовлень. Який місяць найсильніший, 
-- а який найслабший? 
-- ★ Зміна до попереднього місяця у відсотках.

WITH monthly AS (
    SELECT
        strftime('%m', o.date) AS month,
        SUM(p.price * od.quantity)              AS revenue,
        COUNT(DISTINCT od.order_id)             AS orders_cnt
    FROM orders AS o
    JOIN order_details AS od USING (order_id)
    JOIN pizzas AS p USING (pizza_id)
    GROUP BY month
)
SELECT
    month,
    revenue,
    orders_cnt,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
              / LAG(revenue) OVER (ORDER BY month),
        1
    ) AS revenue_change_pct,
    CASE
        WHEN revenue = (SELECT MAX(revenue) FROM monthly) THEN 'найсильніший місяць'
        WHEN revenue = (SELECT MIN(revenue) FROM monthly) THEN 'найслабший місяць'
        ELSE ' '
    END AS note
FROM monthly
ORDER BY month;

-- Висновок:
-- Найсильніший місяць — липень ($72 557.9), найслабший — жовтень ($64 027.6); різниця становить близько 13%.
-- Найбільше зростання до попереднього місяця було в листопаді (+9.9%), найбільший спад — у грудні (−8.1%).

-- Завдання 3.3 Навантаження за днями тижня та годинами: коли пік, а коли тихо? Скільки замовлень 
-- у середньому надходить за один понеділок, один вівторок і так далі?

-- Кількість замовлень за кожен календарний день 
WITH daily_orders AS (
    SELECT
        o.date,
        strftime('%w', o.date) AS weekday_num,
        COUNT(DISTINCT o.order_id) AS orders_cnt
    FROM orders AS o
    GROUP BY o.date
)
SELECT
    CASE weekday_num
        WHEN '0' THEN 'Неділя'
        WHEN '1' THEN 'Понеділок'
        WHEN '2' THEN 'Вівторок'
        WHEN '3' THEN 'Середа'
        WHEN '4' THEN 'Четвер'
        WHEN '5' THEN 'П’ятниця'
        WHEN '6' THEN 'Субота'
    END AS weekday,
    ROUND(AVG(orders_cnt), 1) AS avg_orders
FROM daily_orders
GROUP BY weekday_num
ORDER BY weekday_num;

-- Кількість замовлень за годинами (весь рік)
SELECT
    strftime('%H', o.time) AS hour,
    COUNT(DISTINCT o.order_id) AS orders_cnt
FROM orders AS o
GROUP BY strftime('%H', o.time)
ORDER BY orders_cnt DESC;

-- Висновок:
-- У п’ятницю надходить найбільше замовлень — у середньому 70.8 на день, у неділю найменше — 50.5.
-- Пікові години — обід (12:00: 2 520 замовлень за рік) і вечір (18:00: 2 399); 
-- о 14:00 і 15:00 тихіше (1 472 і 1 468 відповідно). Після 18:00 попит помітно знижується.
 
-- Завдання 3.4 Бестселери та аутсайдери: топ-5 і останні 5 піц за виручкою та за кількістю 
-- (на рівні назви піци, усі розміри разом). Чи збігаються ці списки?

WITH pizza_sales AS (
    SELECT
        pt.name AS pizza_name,
        SUM(p.price * od.quantity) AS revenue,
        SUM(od.quantity) AS pizzas_sold
    FROM order_details AS od
    JOIN pizzas AS p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types AS pt
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.name
)

SELECT * FROM (
    SELECT 'Топ-5 за виручкою' AS ranking, pizza_name, revenue, pizzas_sold
    FROM pizza_sales
    ORDER BY revenue DESC
    LIMIT 5
)

UNION ALL

SELECT * FROM (
    SELECT 'Останні 5 за виручкою' AS ranking, pizza_name, revenue, pizzas_sold
    FROM pizza_sales
    ORDER BY revenue ASC
    LIMIT 5
)

UNION ALL

SELECT * FROM (
    SELECT 'Топ-5 за кількістю' AS ranking, pizza_name, revenue, pizzas_sold
    FROM pizza_sales
    ORDER BY pizzas_sold DESC
    LIMIT 5
)

UNION ALL

SELECT * FROM (
    SELECT 'Останні 5 за кількістю' AS ranking, pizza_name, revenue, pizzas_sold
    FROM pizza_sales
    ORDER BY pizzas_sold ASC
    LIMIT 5
);

-- Висновок:
-- Списки збігаються лише частково: у топ-5 в обох списках Classic Deluxe, Barbecue Chicken 
-- і Thai Chicken, серед останніх п’яти — Brie Carre, Mediterranean і Spinach Supreme.

-- Завдання 3.5 Категорії та розміри: частка виручки кожної категорії та кожного розміру. 
-- Які розміри продаються найкраще?

-- Частка виручки за категоріями 

SELECT
    pt.category,
    SUM(p.price * od.quantity) AS revenue,
    ROUND(
        100.0 * SUM(p.price * od.quantity)
        / SUM(SUM(p.price * od.quantity)) OVER (),
        1
    ) AS revenue_share_pct
FROM order_details AS od
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- Частка виручки за розмірами піци 

SELECT
    p.size,
    SUM(p.price * od.quantity) AS revenue,
    ROUND(
        100.0 * SUM(p.price * od.quantity)
        / SUM(SUM(p.price * od.quantity)) OVER (),
        1
    ) AS revenue_share_pct
FROM order_details AS od
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY revenue DESC;

-- Висновок:
-- Чотири категорії близькі за часткою: Classic 26.9%, Supreme 25.5%, Chicken 24.0%, Veggie 23.7%.
-- Серед розмірів переважає L (45.9%), далі M (30.5%) і S (21.8%); XL і XXL разом лише 1.8%.

-- Завдання 3.6 Кандидати на вилучення з меню: які піци (на рівні назви, усі розміри разом) мають 
-- найменшу частку виручки й найменші продажі? Обґрунтуйте, які 3–5 позицій можна прибрати 
-- і скільки виручки це зачепить. ★ Накопичувальна частка виручки.

-- Виручка і продажі за видами піци (усі розміри разом)
WITH pizza_sales AS (
    SELECT
        pt.name                    AS pizza_name,
        SUM(p.price * od.quantity) AS revenue,
        SUM(od.quantity)           AS pizzas_sold
    FROM order_details AS od
    JOIN pizzas AS p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types AS pt
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.pizza_type_id, pt.name
    HAVING SUM(od.quantity) > 0              -- лише види з продажами
),

-- Частка виручки, накопичувальна частка та рейтинг (за зростанням виручки)
ranked AS (
    SELECT
        pizza_name,
        revenue,
        pizzas_sold,
        ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS revenue_share_pct,
        ROUND(
            100.0 * SUM(revenue) OVER (
                ORDER BY revenue ASC, pizza_name
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) / SUM(revenue) OVER (),
            2
        ) AS cumulative_share_pct,
        ROW_NUMBER() OVER (ORDER BY revenue ASC, pizza_name) AS rn_revenue
    FROM pizza_sales
),

-- Рішення: 4 найслабші види тестуємо
candidates AS (
    SELECT
        pizza_name, revenue, pizzas_sold, revenue_share_pct, cumulative_share_pct,
        CASE WHEN rn_revenue <= 4 THEN 'кандидат на тест' ELSE 'залишити' END AS decision
    FROM ranked
    WHERE rn_revenue <= 5                    -- 5-й рядок для порівняння
)

SELECT
    pizza_name, revenue, pizzas_sold, revenue_share_pct, cumulative_share_pct, decision,
    ROUND(SUM(revenue) OVER (PARTITION BY decision), 2) AS revenue_per_decision
FROM candidates
ORDER BY revenue ASC;

-- Висновок:
-- Чотири найслабші піци за виручкою — Brie Carre ($11 588.50; 490 шт.), Green Garden
-- ($13 955.75; 997 шт.), Spinach Supreme ($15 277.75; 950 шт.) і Mediterranean ($15 360.50; 934 шт.).
-- Разом вони дають $56 182.50, тобто 6.87% загальної виручки. Brie Carre найслабша і за виручкою, 
-- і за кількістю; Green Garden за кількістю трохи поза п’ятіркою найслабших, 
-- але відстань до Mediterranean і Spinach Supreme невелика. Оскільки є лише касові дані, 
-- остаточне вилучення не рекомендується, натомість — тест 6 тижнів.
 
-- Завдання 3.7 Великі замовлення: яка частка замовлень містить 4 і більше піц 
-- (сума quantity у замовленні) і скільки виручки вони дають? Чи варто робити окрему пропозицію для компаній?

-- Піци та виручка по кожному замовленню
WITH order_sales AS (
    SELECT
        od.order_id,
        SUM(od.quantity)           AS pizzas_count,
        SUM(p.price * od.quantity) AS revenue
    FROM order_details AS od
    JOIN pizzas AS p
        ON od.pizza_id = p.pizza_id
    GROUP BY od.order_id
)

-- Групування: 4+ піц проти 1–3 піц
SELECT
    CASE
        WHEN pizzas_count >= 4 THEN '4+ піци'
        ELSE '1–3 піци'
    END AS order_group,
    COUNT(*) AS orders_cnt,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS orders_share_pct,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_share_pct,
    ROUND(SUM(revenue) / COUNT(*), 1) AS avg_order_value
FROM order_sales
GROUP BY
    CASE
        WHEN pizzas_count >= 4 THEN '4+ піци'
        ELSE '1–3 піци'
    END
ORDER BY order_group;

-- Висновок:
-- Замовлення з 4 і більше піцами становлять 18.2% усіх замовлень (3 880 із 21 350), але приносять 
-- $322 570.90, тобто 39.4% загальної виручки. Їхній середній чек — $83.1 проти $28.4 у менших замовлень. 
-- Окрема пропозиція для груп і компаній може бути виправданою; 
-- чи є серед цих замовлень саме компанії, з касових даних не видно.

-- Завдання 3.8 Акція: у які дні тижня та години варто її запустити? Запропонуйте конкретну акцію 
-- та оцініть потенціал: яка зараз виручка в цьому часовому вікні і що дасть її зростання на 10%.

-- Основа для вибору вікна (теплова карта «день тижня × година»): замовлення о 14:00 і 15:00
-- за днями тижня, всього і в середньому за день
SELECT
    CASE strftime('%w', o.date)
        WHEN '0' THEN 'Неділя'
        WHEN '1' THEN 'Понеділок'
        WHEN '2' THEN 'Вівторок'
        WHEN '3' THEN 'Середа'
        WHEN '4' THEN 'Четвер'
        WHEN '5' THEN 'П’ятниця'
        WHEN '6' THEN 'Субота'
    END AS weekday,
    COUNT(DISTINCT o.order_id) AS orders_cnt,
    COUNT(DISTINCT o.date)     AS days_cnt,
    ROUND(1.0 * COUNT(DISTINCT o.order_id) / COUNT(DISTINCT o.date), 1) AS avg_orders_per_day
FROM orders AS o
WHERE strftime('%H', o.time) IN ('14','15')          -- 14:00-16:00
GROUP BY strftime('%w', o.date)
ORDER BY strftime('%w', o.date);

-- Потенціал акції: понеділок–середа, 14:00-16:00, акційний продукт Classic L (питання 3 і 5)
SELECT
    'Понеділок–середа' AS weekday,
    '14:00–16:00'      AS hour,
    COUNT(DISTINCT o.order_id) AS orders_cnt,

    -- Виручка всього часового вікна
    ROUND(SUM(od.quantity * p.price), 2)        AS current_revenue,
    ROUND(SUM(od.quantity * p.price) * 1.10, 2) AS revenue_after_10_pct,
    ROUND(SUM(od.quantity * p.price) * 0.10, 2) AS additional_revenue,

    -- Виручка акційного продукту Classic L у цьому ж вікні
    ROUND(SUM(CASE WHEN pt.category = 'Classic' AND p.size = 'L'
                   THEN od.quantity * p.price END), 2) AS classic_l_revenue,
    ROUND(100.0 * SUM(CASE WHEN pt.category = 'Classic' AND p.size = 'L'
                           THEN od.quantity * p.price END)
          / SUM(od.quantity * p.price), 1)              AS classic_l_share_pct

FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id

WHERE strftime('%w', o.date) IN ('1','2','3')        -- понеділок–середа
  AND strftime('%H', o.time) IN ('14','15');         -- 14:00-16:00

-- Висновок:
-- За тепловою картою з понеділка по середу о 14:00 і 15:00 найтихіше 
-- (182–210 замовлень на годину за рік проти 331–421 о 12:00 і 13:00). 
-- Як акцію пропонуємо піци Classic розміру L (частка виручки: Classic 26.9%, L 45.9%). 
-- Поточна виручка в цьому часовому вікні — $45 550.30; зростання на 10% дасть додатково 
-- $4 555.03 на рік (до витрат на знижку).
