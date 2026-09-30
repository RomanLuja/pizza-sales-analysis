-- ZWISCHENPROJEKT: UMSATZ EINER PIZZERIA

CREATE VIEW view_orders AS
SELECT
CAST(order_id AS INTEGER) AS order_id,
DATE(date) AS date,
TIME(time) AS time
FROM orders;

CREATE VIEW view_order_details AS
SELECT
order_details_id,
    	order_id,
    	CAST(pizza_id AS INTEGER) AS pizza_id,
    	quantity    
FROM order_details;

CREATE VIEW view_pizzas AS
SELECT
    	CAST(pizza_id AS INTEGER) AS pizza_id,
    	CAST(pizza_type_id AS INTEGER) AS pizza_type_id,
    	size,
   	 price
FROM pizzas;

CREATE VIEW view_pizza_types AS
SELECT
    	CAST(pizza_type_id AS INTEGER) AS pizza_type_id,
   	 name,
   	 category,
    	ingredients
FROM pizza_types;

-- Aufgabe 3.1 Kennzahlen des Jahres: Umsatz, Anzahl der Bestellungen, verkaufte Pizzen, durchschnittlicher Bestellwert, durchschnittliche Pizzen pro Bestellung. Pizzen unter Berücksichtigung von quantity zählen.

SELECT 
SUM(p.price * od.quantity) AS revenue,
COUNT(DISTINCT od.order_id) AS orders_cnt,
SUM(od.quantity) As pizzas_sold,
ROUND(SUM(p.price * od.quantity) / COUNT(DISTINCT order_id), 2) AS avg_check,
ROUND(SUM(od.quantity) / COUNT(DISTINCT od.order_id), 1)  AS avg_pizzas_per_order
FROM pizzas AS p
JOIN order_details AS od
 	ON p.pizza_id = od.pizza_id;

-- Fazit: 
Im Jahr 2015 erzielte die Pizzeria einen Umsatz von 817.860,05 $, bearbeitete 21.350 Bestellungen und verkaufte 49.574 Pizzen. Der durchschnittliche Bestellwert betrug 38,31 $, im Durchschnitt wurden 2 Pizzen pro Bestellung verkauft. 
Aufgabe 3.2  Entwicklung nach Monaten: Umsatz und Bestellungen. Welcher Monat ist am stärksten, welcher am schwächsten? ★ Veränderung zum Vormonat in Prozent.

WITH monthly AS (
    SELECT
        strftime('%m', vo.date) AS month,
        SUM(vp.price * vod.quantity)              AS revenue,
        COUNT(DISTINCT vod.order_id)             AS orders_cnt
    FROM view_orders AS vo
    JOIN view_order_details AS vod USING (order_id)
    JOIN view_pizzas AS vp USING (pizza_id)
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

Fazit:
Im Jahr 2015 schwankte der Umsatz. Der stärkste Monat war Juli mit 6.931.893,6, der schwächste Oktober mit 6.128.538,9. Das stärkste Umsatzwachstum gegenüber dem Vormonat wurde im November mit +9,9 % erreicht. 	

















Aufgabe 3.3 Auslastung nach Wochentagen und Uhrzeiten: Wann ist Stoßzeit, wann ist es ruhig? Wie viele Bestellungen gehen durchschnittlich an einem Montag, einem Dienstag usw. Ein?

-- Anzahl der Bestellungen für jeden Kalendertag 

WITH daily_orders AS (
    SELECT
        vo.date,
        strftime('%w', vo.date) AS weekday_num,
        COUNT(DISTINCT vo.order_id) AS orders_cnt
    FROM view_orders AS vo
    GROUP BY vo.date
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

-- Durchschnittliche Anzahl der Bestellungen pro Wochentag 

SELECT
    strftime('%H', vo.time) AS hour,
    COUNT(DISTINCT vo.order_id) AS orders_cnt
FROM view_orders AS vo
GROUP BY strftime('%H', vo.time)
ORDER BY orders_cnt DESC;


Fazit
Die durchschnittliche Anzahl der Bestellungen pro Tag unterscheidet sich je nach Wochentag. Am Freitag werden mit durchschnittlich 77,8 Bestellungen pro Freitag die meisten Bestellungen aufgegeben, am Sonntag mit 50,5 Bestellungen die wenigsten.
Im Tagesverlauf steigt die Zahl der Bestellungen ab 11:00 Uhr deutlich an: Um 11:00 Uhr wurden im gesamten Jahr 1.231 Bestellungen erfasst, und um 12:00 Uhr wird mit 2.520 Bestellungen der Höchstwert erreicht. Nach 12:00 Uhr geht die Nachfrage allmählich zurück, bleibt aber weiterhin hoch: Um 13:00 Uhr wurden 2.455 Bestellungen, um 17:00 Uhr 2.336 und um 18:00 Uhr nochmals 2.399 Bestellungen erfasst. Nach 18:00 Uhr nimmt die Anzahl der Bestellungen deutlich ab und liegt um 23:00 Uhr nur noch bei 28 Bestellungen im gesamten Jahr.
Aufgabe 3.4 Bestseller und Ladenhüter: Top 5 und letzte 5 Pizzen nach Umsatz und nach Menge (auf Ebene der Pizzasorte, alle Größen zusammen). Stimmen die Listen überein?
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


Fazit: Die Listen nach Umsatz und Verkaufsmenge stimmen teilweise überein. Bei den Top-5-Pizzen überschneiden sich 3 von 5 Pizzen: Classic Deluxe, Barbecue Chicken und Thai Chicken. Auch bei den letzten 5 Pizzen gibt es 3 gemeinsame Pizzen: Brie Carre, Mediterranean und Spinach Supreme. Somit gibt es einen deutlichen Zusammenhang zwischen Verkaufsmenge und Umsatz, aber die Listen sind nicht vollständig identisch. 

Aufgabe 3.5 Kategorien und Größen: Umsatzanteil jeder Kategorie und jeder Größe. Welche Größen verkaufen sich am besten?

-Umsatzanteil nach Kategorien 

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

-Umsatzanteil nach Pizzagröße 

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

Fazit:
Die Umsätze verteilen sich relativ gleichmäßig auf die vier Hauptkategorien. Den größten Umsatz erzielt die Kategorie Classic mit 26,9 %, gefolgt von Supreme mit 25,5 %, Chicken mit 24,0 % und Veggie mit 23,7 %.
Bei den Größen ist ein deutlicher Unterschied zu erkennen. L-Pizzen erzielen mit 45,9 % den höchsten Umsatzanteil, gefolgt von M mit 30,5 % und S mit 21,8 %. Die Größen XL und XXL spielen mit zusammen nur 1,8 % der Umsätze eine deutlich geringere Rolle.
Die Größe L wird somit mit großem Abstand am besten verkauft bzw. erzielt den größten Umsatzanteil.
Aufgabe 3.6 Kandidaten für die Streichung: Welche Pizzasorten (alle Größen zusammen) haben den kleinsten Umsatzanteil und die geringsten Verkäufe? Begründen Sie, welche 3–5 Positionen wegfallen können und wie viel Umsatz betroffen ist. ★ Kumulierter Umsatzanteil.
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

SELECT
    pizza_name,
    revenue,
    pizzas_sold,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER (),
        2
    ) AS revenue_share_pct,
    ROUND(
        100.0 * SUM(revenue) OVER (
            ORDER BY revenue ASC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / SUM(revenue) OVER (),
        2
    ) AS cumulative_share_pct
FROM pizza_sales
ORDER BY revenue ASC;

Fazit:
Die schwächsten Positionen nach Umsatz und Verkaufsmenge sind vor allem The Brie Carre Pizza, The Spinach Supreme Pizza und The Mediterranean Pizza. Zusammen erzielen diese drei Pizzen 42.226,75 $ Umsatz, was einem Anteil von 4,99 % des Gesamtumsatzes entspricht. Aufgrund der niedrigen Verkaufszahlen und des geringen Umsatzanteils können diese drei Pizzen als Kandidaten für eine Entfernung aus dem Menü betrachtet werden. 





Aufgabe 3.7 Große Bestellungen: Welcher Anteil der Bestellungen enthält 4 oder mehr Pizzen (Summe von quantity je Bestellung) und wie viel Umsatz bringen sie? Lohnt sich ein eigenes Angebot für Firmen?
 
WITH order_sales AS (
    SELECT
        od.order_id,
        SUM(od.quantity) AS pizzas_count,
        SUM(p.price * od.quantity) AS revenue
    FROM order_details AS od
    JOIN pizzas AS p
        ON od.pizza_id = p.pizza_id
    GROUP BY od.order_id
)

SELECT
    CASE
        WHEN pizzas_count >= 4 THEN '4+ Pizzen'
        ELSE '1–3 Pizzen'
    END AS order_group,
    COUNT(*) AS orders_cnt,
    SUM(revenue) AS revenue,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        1
    ) AS orders_share_pct,
    ROUND(
        100.0 * SUM(revenue) / SUM(SUM(revenue)) OVER (),
        1
    ) AS revenue_share_pct
FROM order_sales
GROUP BY
    CASE
        WHEN pizzas_count >= 4 THEN '4+ Pizzen'
        ELSE '1–3 Pizzen'
    END
ORDER BY pizzas_count;


Fazit:
Bestellungen mit 4 oder mehr Pizzen machen 18,2 % aller Bestellungen aus, generieren aber 39,4 % des Gesamtumsatzes. Damit haben Großbestellungen eine deutlich höhere Bedeutung für den Umsatz. Ein separates Angebot für Gruppen oder Firmen kann daher sinnvoll sein, insbesondere um diese Bestellungen gezielt zu fördern. 

Aufgabe 3.8 Aktion: An welchen Wochentagen und zu welchen Uhrzeiten lohnt sie sich? Schlagen Sie eine konkrete Aktion vor und schätzen Sie das Potenzial: Wie hoch ist der aktuelle Umsatz in diesem Zeitfenster und was brächte ein Plus von 10 %?

SELECT
    'Sonntag' AS weekday,
    '22:00' AS hour,
    'Classic' AS promo_category,
    'L' AS promo_size,

    ROUND(
        SUM(od.quantity * p.price),
        2
    ) AS current_revenue,

    ROUND(
        SUM(od.quantity * p.price) * 1.10,
        2
    ) AS revenue_after_10_pct,

    ROUND(
        SUM(od.quantity * p.price) * 0.10,
        2
    ) AS additional_revenue

FROM orders AS o

JOIN order_details AS od
    ON o.order_id = od.order_id

JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id

JOIN pizza_types AS pt
    ON p.pizza_type_id = pt.pizza_type_id

WHERE strftime('%w', o.date) = '0'       -- Sonntag
  AND strftime('%H', o.time) = '22'      -- 22:00 Uhr
  AND pt.category = 'Classic'            -- Aktionskategorie
  AND p.size = 'L';                      -- Aktionsgröße

Fazit:
Eine Aktion bietet sich am Sonntag um 22:00 Uhr an. Als Aktionsprodukt werden Classic-Pizzen in der Größe L vorgeschlagen, da Classic mit 26,9 % den höchsten Umsatzanteil der Kategorien und L mit 45,9 % den höchsten Umsatzanteil der Größen erzielt. Im gewählten Zeitfenster beträgt der aktuelle Umsatz 175,25 $. Bei einer Umsatzsteigerung von 10 % würde der Umsatz auf 192,78 $ steigen. Das entspricht einem zusätzlichen Umsatz von 17,53 $. 

Auswahl sales_lines für Tableau

SELECT
    o.order_id AS order_id,
    o.date AS order_date,
    o.time AS order_time,
    strftime('%m', o.date) AS month,

    CASE strftime('%w', o.date)
        WHEN '0' THEN 'Sonntag'
        WHEN '1' THEN 'Montag'
        WHEN '2' THEN 'Dienstag'
        WHEN '3' THEN 'Mittwoch'
        WHEN '4' THEN 'Donnerstag'
        WHEN '5' THEN 'Freitag'
        WHEN '6' THEN 'Samstag'
    END AS weekday,

    strftime('%H', o.time) AS hour,

    pt.name AS pizza_name,
    pt.category AS category,
    p.size AS size,
    p.price AS unit_price,
    od.quantity AS quantity,
    p.price * od.quantity AS revenue

FROM orders AS o
JOIN order_details AS od
    ON o.order_id = od.order_id
JOIN pizzas AS p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types AS pt
    ON p.pizza_type_id = pt.pizza_type_id;

Kontrolle: sales_lines muss genauso viele Zeilen haben wie order_details.

SELECT COUNT(*) AS sales_lines_count
FROM (
    SELECT
        o.order_id
    FROM orders AS o
    JOIN order_details AS od
        ON o.order_id = od.order_id
    JOIN pizzas AS p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types AS pt
        ON p.pizza_type_id = pt.pizza_type_id
);

Ergebnis: Die Anzahl der Zeilen in sales_lines entspricht der Anzahl der Zeilen in order_details.
sales_lines: 48.620 Zeilen
order_details: 48.620 Zeilen


