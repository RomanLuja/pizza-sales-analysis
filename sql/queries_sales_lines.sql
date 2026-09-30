-- Auswahl sales_lines für Tableau

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
