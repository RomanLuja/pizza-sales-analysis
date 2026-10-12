-- Aufgabe 3.1 Kennzahlen des Jahres: Umsatz, Anzahl der Bestellungen, verkaufte Pizzen, durchschnittlicher
-- Bestellwert, durchschnittliche Pizzen pro Bestellung. Pizzen unter Berücksichtigung von quantity zählen.

SELECT 
SUM(p.price * od.quantity) AS revenue,
COUNT(DISTINCT od.order_id) AS orders_cnt,
SUM(od.quantity) As pizzas_sold,
ROUND(SUM(p.price * od.quantity) / COUNT(DISTINCT order_id), 2) AS avg_check,
ROUND(CAST(SUM(od.quantity) AS REAL) / COUNT(DISTINCT od.order_id), 1)  AS avg_pizzas_per_order
FROM pizzas AS p
JOIN order_details AS od
 	ON p.pizza_id = od.pizza_id;

-- Fazit:
-- 2015 erzielte die Pizzeria 817.860,05 $ Umsatz mit 21.350 Bestellungen und 49.574 verkauften Pizzen.
-- Eine Bestellung brachte im Schnitt 38,31 $ und enthielt 2,3 Pizzen.

-- Aufgabe 3.2  Entwicklung nach Monaten: Umsatz und Bestellungen. Welcher Monat ist am stärksten, 
-- welcher am schwächsten? 
-- ★ Veränderung zum Vormonat in Prozent.

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
        WHEN revenue = (SELECT MAX(revenue) FROM monthly) THEN 'stärkster Monat'
        WHEN revenue = (SELECT MIN(revenue) FROM monthly) THEN 'schwächster Monat'
        ELSE ' '
    END AS note
FROM monthly
ORDER BY month;

-- Fazit:
-- Der stärkste Monat war Juli (72.557,9 $), der schwächste Oktober (64.027,6 $); der Unterschied beträgt rund 13 %.
-- Das stärkste Wachstum zum Vormonat gab es im November (+9,9 %), den stärksten Rückgang im Dezember (−8,1 %).

-- Aufgabe 3.3 Auslastung nach Wochentagen und Uhrzeiten: Wann ist Stoßzeit, wann ist es ruhig? Wie viele Bestellungen gehen 
-- durchschnittlich an einem Montag, einem Dienstag usw. Ein?

-- Anzahl der Bestellungen für jeden Kalendertag 
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
        WHEN '0' THEN 'Sonntag'
        WHEN '1' THEN 'Montag'
        WHEN '2' THEN 'Dienstag'
        WHEN '3' THEN 'Mittwoch'
        WHEN '4' THEN 'Donnerstag'
        WHEN '5' THEN 'Freitag'
        WHEN '6' THEN 'Samstag'
    END AS weekday,
    ROUND(AVG(orders_cnt), 1) AS avg_orders
FROM daily_orders
GROUP BY weekday_num
ORDER BY weekday_num;

-- Anzahl der Bestellungen je Stunde (gesamtes Jahr)
SELECT
    strftime('%H', o.time) AS hour,
    COUNT(DISTINCT o.order_id) AS orders_cnt
FROM orders AS o
GROUP BY strftime('%H', o.time)
ORDER BY orders_cnt DESC;

-- Fazit:
-- Am Freitag gibt es mit durchschnittlich 70,8 Bestellungen pro Tag die meisten Bestellungen, 
-- am Sonntag mit 50,5 die wenigsten. Stoßzeiten sind mittags (12:00 Uhr: 2.520 Bestellungen im Jahr)
-- und abends (18:00 Uhr: 2.399); um 14:00 und 15:00 Uhr ist es ruhiger (1.472 bzw. 1.468). 
-- Nach 18:00 Uhr sinkt die Nachfrage deutlich.
 
-- Aufgabe 3.4 Bestseller und Ladenhüter: Top 5 und letzte 5 Pizzen nach Umsatz und nach Menge (auf Ebene der Pizzasorte, alle Größen zusammen). 
-- Stimmen die Listen überein?

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
    SELECT 'Top 5 Umsatz' AS ranking, pizza_name, revenue, pizzas_sold
    FROM pizza_sales
    ORDER BY revenue DESC
    LIMIT 5
)

UNION ALL

SELECT * FROM (
    SELECT 'Letzte 5 Umsatz' AS ranking, pizza_name, revenue, pizzas_sold
    FROM pizza_sales
    ORDER BY revenue ASC
    LIMIT 5
)

UNION ALL

SELECT * FROM (
    SELECT 'Top 5 Menge' AS ranking, pizza_name, revenue, pizzas_sold
    FROM pizza_sales
    ORDER BY pizzas_sold DESC
    LIMIT 5
)

UNION ALL

SELECT * FROM (
    SELECT 'Letzte 5 Menge' AS ranking, pizza_name, revenue, pizzas_sold
    FROM pizza_sales
    ORDER BY pizzas_sold ASC
    LIMIT 5
);

-- Fazit:
-- Die Listen stimmen nur teilweise überein: Bei den Top 5 sind Classic Deluxe, Barbecue Chicken und 
-- Thai Chicken in beiden Listen, bei den letzten 5 Brie Carre, Mediterranean und Spinach Supreme.

-- Aufgabe 3.5 Kategorien und Größen: Umsatzanteil jeder Kategorie und jeder Größe. Welche Größen verkaufen sich am besten?

-- Umsatzanteil nach Kategorien 

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

-- Umsatzanteil nach Pizzagröße 

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

-- Fazit:
-- Die vier Kategorien liegen nah beieinander: Classic 26,9 %, Supreme 25,5 %, Chicken 24,0 %, Veggie 23,7 %.
-- Bei den Größen dominiert L mit 45,9 %, gefolgt von M (30,5 %) und S (21,8 %); XL und XXL zusammen nur 1,8 %.
-- 
-- Aufgabe 3.6 Kandidaten für die Streichung: Welche Pizzasorten (alle Größen zusammen) haben den kleinsten
-- Umsatzanteil und die geringsten Verkäufe? Begründen Sie, welche 3–5 Positionen wegfallen können und 
-- wie viel Umsatz betroffen ist. ★ Kumulierter Umsatzanteil.

--Umsatz und Verkäufe je Pizzasorte (alle Größen zusammen)
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
    HAVING SUM(od.quantity) > 0              -- nur Sorten mit Verkäufen
),

-- Umsatzanteil, kumulierter Anteil und Rang (aufsteigend nach Umsatz)
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

-- Entscheidung: die 4 schwächsten Sorten werden getestet
candidates AS (
    SELECT
        pizza_name, revenue, pizzas_sold, revenue_share_pct, cumulative_share_pct,
        CASE WHEN rn_revenue <= 4 THEN 'Testkandidat' ELSE 'behalten' END AS decision
    FROM ranked
    WHERE rn_revenue <= 5                    -- 5. Zeile zum Vergleich
)

SELECT
    pizza_name, revenue, pizzas_sold, revenue_share_pct, cumulative_share_pct, decision,
    ROUND(SUM(revenue) OVER (PARTITION BY decision), 2) AS revenue_per_decision
FROM candidates
ORDER BY revenue ASC;

-- Fazit:
-- Die vier schwächsten Pizzen nach Umsatz sind Brie Carre (11.588,50 $; 490 Stück), Green Garden
-- (13.955,75 $; 997 Stück), Spinach Supreme (15.277,75 $; 950 Stück) und Mediterranean (15.360,50 $; 934 Stück).
-- Zusammen bringen sie 56.182,50 $, das sind 6,87 % des Gesamtumsatzes. Brie Carre ist bei Umsatz und Menge 
-- die schwächste Pizza; Green Garden liegt bei der Menge knapp außerhalb der fünf schwächsten, 
-- der Abstand zu Mediterranean und Spinach Supreme ist aber gering. Da nur Kassendaten vorliegen, 
-- wird kein endgültiges Streichen empfohlen, sondern ein Test von 6 Wochen.
 
-- Aufgabe 3.7 Große Bestellungen: Welcher Anteil der Bestellungen enthält 4 oder mehr Pizzen 
-- (Summe von quantity je Bestellung) und wie viel Umsatz bringen sie? Lohnt sich ein eigenes Angebot für Firmen?

-- Pizzen und Umsatz je Bestellung
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

-- Gruppierung: 4+ Pizzen gegenüber 1–3 Pizzen
SELECT
    CASE
        WHEN pizzas_count >= 4 THEN '4+ Pizzen'
        ELSE '1–3 Pizzen'
    END AS order_group,
    COUNT(*) AS orders_cnt,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS orders_share_pct,
    ROUND(100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (), 1) AS revenue_share_pct,
    ROUND(SUM(revenue) / COUNT(*), 1) AS avg_order_value
FROM order_sales
GROUP BY
    CASE
        WHEN pizzas_count >= 4 THEN '4+ Pizzen'
        ELSE '1–3 Pizzen'
    END
ORDER BY order_group;

-- Fazit:
-- Bestellungen mit 4 oder mehr Pizzen machen 18,2 % aller Bestellungen aus (3.880 von 21.350), bringen 
-- aber 322.570,90 $ und damit 39,4 % des Gesamtumsatzes. Ihr durchschnittlicher Bestellwert liegt bei 83,1 $ 
-- gegenüber 28,4 $ bei kleineren Bestellungen. Ein eigenes Angebot für Gruppen und Firmen kann sich daher lohnen; 
-- ob es sich bei diesen Bestellungen tatsächlich um Firmen handelt, lässt sich aus den Kassendaten nicht erkennen.

-- Aufgabe 3.8 Aktion: An welchen Wochentagen und zu welchen Uhrzeiten lohnt sie sich? Schlagen Sie eine konkrete
-- Aktion vor und schätzen Sie das Potenzial: Wie hoch ist der aktuelle Umsatz in diesem Zeitfenster und 
-- was brächte ein Plus von 10 %?

-- Basis für die Wahl des Zeitfensters (Heatmap Wochentag × Uhrzeit): Bestellungen um 14:00 und 15:00 Uhr
-- je Wochentag, gesamt und pro Tag
SELECT
    CASE strftime('%w', o.date)
        WHEN '0' THEN 'Sonntag'
        WHEN '1' THEN 'Montag'
        WHEN '2' THEN 'Dienstag'
        WHEN '3' THEN 'Mittwoch'
        WHEN '4' THEN 'Donnerstag'
        WHEN '5' THEN 'Freitag'
        WHEN '6' THEN 'Samstag'
    END AS weekday,
    COUNT(DISTINCT o.order_id) AS orders_cnt,
    COUNT(DISTINCT o.date)     AS days_cnt,
    ROUND(1.0 * COUNT(DISTINCT o.order_id) / COUNT(DISTINCT o.date), 1) AS avg_orders_per_day
FROM orders AS o
WHERE strftime('%H', o.time) IN ('14','15')          -- 14:00-16:00 Uhr
GROUP BY strftime('%w', o.date)
ORDER BY strftime('%w', o.date);

-- Aktionspotenzial: Montag bis Mittwoch, 14:00-16:00 Uhr, Aktionsprodukt Classic L (Aufgabe 3 und 5)
SELECT
    'Montag–Mittwoch' AS weekday,
    '14:00–16:00'     AS hour,
    COUNT(DISTINCT o.order_id) AS orders_cnt,

    -- Umsatz des gesamten Zeitfensters
    ROUND(SUM(od.quantity * p.price), 2)        AS current_revenue,
    ROUND(SUM(od.quantity * p.price) * 1.10, 2) AS revenue_after_10_pct,
    ROUND(SUM(od.quantity * p.price) * 0.10, 2) AS additional_revenue,

    -- Umsatz des Aktionsprodukts Classic L im selben Fenster
    ROUND(SUM(CASE WHEN pt.category = 'Classic' AND p.size = 'L'
                   THEN od.quantity * p.price END), 2) AS classic_l_revenue,
    ROUND(100.0 * SUM(CASE WHEN pt.category = 'Classic' AND p.size = 'L'
                           THEN od.quantity * p.price END)
          / SUM(od.quantity * p.price), 1)              AS classic_l_share_pct

FROM orders AS o
JOIN order_details AS od ON o.order_id = od.order_id
JOIN pizzas AS p ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id

WHERE strftime('%w', o.date) IN ('1','2','3')        -- Montag bis Mittwoch
  AND strftime('%H', o.time) IN ('14','15');         -- 14:00-16:00 Uhr

-- Fazit:
-- Laut Heatmap ist es von Montag bis Mittwoch um 14:00 und 15:00 Uhr am ruhigsten 
-- (182 bis 210 Bestellungen je Stunde im Jahr, gegenüber 331 bis 421 um 12:00 und 13:00 Uhr). 
-- Als Aktion werden Classic-Pizzen in Größe L vorgeschlagen (Classic 26,9 % und L 45,9 % Umsatzanteil). 
-- Der aktuelle Umsatz im Zeitfenster beträgt 45.550,30 $; ein Plus von 10 % bringt 4.555,03 $ zusätzlich 
-- pro Jahr (vor Kosten für den Rabatt).
