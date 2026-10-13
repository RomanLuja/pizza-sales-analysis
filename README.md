# Pizzeria Sales Analysis

Midterm project of the *Data Analytics & Engineering* course · Author: Roman Luja · 06.10.2026 · [Українська версія](README.md) · [Deutsche Version](README-de.md)

## Task

The new owner of a pizzeria in New Jersey, Laura Martínez, took over the shop together with the register export for the whole of 2015. She has to make three decisions: build the shift schedule, choose which pizzas to drop from the menu, and pick the timing and type of a promotion. The dataset consists of 4 tables from Kaggle (*Pizza Place Sales*). The task is to answer 8 key questions, build an interactive dashboard and give recommendations backed by numbers.

## Data

- Tables: `orders` (21,350 rows), `order_details` (48,620), `pizzas` (96), `pizza_types` (32). Field descriptions: [docs/data_dictionary.md](docs/data_dictionary.md).
- Period: 01.01.2015–31.12.2015 (orders exist on 358 days).
- Data quality: 0 missing values, 0 duplicate keys, 0 orphaned relations, 0 orders without items. Revenue = price × quantity; a `JOIN` of all tables into `sales_lines` gives the same 48,620 rows with no loss.
- Integer problem in SQLite (division returns an integer): all shares and averages are calculated with `1.0 *` or `CAST ... AS REAL`.
- Number format in this document: decimals are separated by a dot, thousands by a comma.

## Key questions and answers

1. Overall figures → revenue \$817,860, 21,350 orders, 49,574 pizzas, average order value \$38.31, 2.3 pizzas per order → [sql/queries.sql](sql/queries.sql), Q1
2. Monthly trend → strongest month July (\$72,557.9), weakest October (\$64,027.6), difference 13.3% → Q2
3. Weekdays and hours → peak on Friday (70.8 orders per day), low on Sunday (50.5); peaks at 12–13 and 17–18 (45.5% of orders), quiet at 14–15 → Q3
4. Bestsellers and laggards → by revenue Thai Chicken (\$43,434), by quantity Classic Deluxe (2,453 pcs); weakest is Brie Carre (\$11,588.5; 490 pcs) → Q4
5. Categories and sizes → categories almost equal (Classic 26.9%, Supreme 25.5%, Chicken 24.0%, Veggie 23.7%); size L brings 45.9% of revenue, XL+XXL only 1.8% → Q5
6. Menu removal candidates → Brie Carre, Green Garden, Spinach Supreme, Mediterranean: \$56,182.5 together, 6.87% of revenue → Q6
7. Large orders → orders of 4+ pizzas: 18.2% of orders, 39.4% of revenue, average order value \$83.1 vs \$28.4 → Q7
8. Promotion → window Mon–Wed 14:00–16:00: 1,172 orders, \$45,550.3 revenue, +10% = +\$4,555 per year (before discount cost) → Q8

## Tools

SQL (SQLite) for the answers, Tableau Public for the interactive dashboard (filters by size, category and month), HTML/PDF for the presentation.

## Business recommendations

- **Shift schedule:** full staffing:
  - Mon–Thu: 12:00–14:00, 17:00–19:00
  - Fri: 12:00–14:00, 17:00–21:00
  - Sat: 17:00–21:00
  - Sun: 17:00–19:00

  At other times a minimal team is enough.
- **Menu:** a 6-week test without Brie Carre, Green Garden, Spinach Supreme and Mediterranean (6.9% of revenue). If revenue holds up, remove them for good; if many guests leave, reconsider.
- **Promotion:** Mon–Wed from 14:00 to 16:00 on Classic pizzas in size L (strongest category and size), and for groups of 4+ pizzas a bundle with a bonus. Test for 6 weeks first.

## Limitations and next steps

- Data covers only one year (2015) and only the register: there are no costs or salaries, so revenue is analysed, not profit.
- The data has no "company" flag, so the assumption about corporate customers cannot be verified.
- The effect of the promotion and of removing pizzas is an estimate. Next step: a 6-week test of the promotion and the menu, comparing revenue.

## Links

- Dashboard: https://public.tableau.com/views/pizza_dashboard_17912601498770/Pizzeria-Umsatzimberblick
- Presentation: [Ukrainian HTML](presentation/presentation-uk.html) · [Ukrainian PDF](presentation/presentation-uk.pdf) · [German HTML](presentation/presentation-de.html) · [German PDF](presentation/presentation-de.pdf)
- SQL: [sql/queries.sql](sql/queries.sql) (German comments), [sql/queries-uk.sql](sql/queries-uk.sql) (Ukrainian comments)
- Dataset: https://www.kaggle.com/datasets/mysarahmadbhat/pizza-place-sales
- Repository: https://github.com/RomanLuja/pizza-sales-analysis
