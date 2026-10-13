# Umsatzanalyse einer Pizzeria

Zwischenprojekt im Kurs *Data Analytics & Engineering* · Autor: Roman Luja · 06.10.2026 · [Українська версія](README.md) · [English version](README-en.md)

## Aufgabe

Die neue Besitzerin einer Pizzeria in New Jersey, Laura Martínez, hat mit dem Laden den Kassenexport für das gesamte Jahr 2015 übernommen. Sie muss drei Entscheidungen treffen: den Schichtplan erstellen, Pizzen für die Streichung aus der Speisekarte auswählen und Zeitpunkt und Art einer Aktion festlegen. Der Datensatz besteht aus 4 Tabellen von Kaggle (*Pizza Place Sales*). Aufgabe: 8 Schlüsselfragen beantworten, ein interaktives Dashboard bauen und Empfehlungen mit Zahlen geben.

## Daten

- Tabellen: `orders` (21.350 Zeilen), `order_details` (48.620), `pizzas` (96), `pizza_types` (32). Feldbeschreibung: [docs/data_dictionary.md](docs/data_dictionary.md).
- Zeitraum: 01.01.2015–31.12.2015 (Bestellungen an 358 Tagen).
- Datenqualität: 0 fehlende Werte, 0 doppelte Schlüssel, 0 verwaiste Verknüpfungen, 0 Bestellungen ohne Positionen. Umsatz = Preis × Menge; der `JOIN` aller Tabellen zu `sales_lines` ergibt dieselben 48.620 Zeilen ohne Verlust.
- Ganzzahlproblem in SQLite (Division liefert eine ganze Zahl): alle Anteile und Durchschnitte werden mit `1.0 *` oder `CAST ... AS REAL` berechnet.

## Schlüsselfragen und Antworten

1. Gesamtkennzahlen → Umsatz \$817.860, 21.350 Bestellungen, 49.574 Pizzen, durchschnittlicher Bestellwert \$38,31, 2,3 Pizzen pro Bestellung → [sql/queries.sql](sql/queries.sql), Q1
2. Entwicklung nach Monaten → stärkster Monat Juli (\$72.557,9), schwächster Oktober (\$64.027,6), Unterschied 13,3 % → Q2
3. Wochentage und Uhrzeiten → Maximum am Freitag (70,8 Bestellungen pro Tag), Minimum am Sonntag (50,5); Spitzen 12–13 und 17–18 Uhr (45,5 % der Bestellungen), ruhig um 14–15 Uhr → Q3
4. Bestseller und Ladenhüter → nach Umsatz Thai Chicken (\$43.434), nach Menge Classic Deluxe (2.453 Stück); am schwächsten Brie Carre (\$11.588,5; 490 Stück) → Q4
5. Kategorien und Größen → Kategorien fast gleich (Classic 26,9 %, Supreme 25,5 %, Chicken 24,0 %, Veggie 23,7 %); Größe L bringt 45,9 % des Umsatzes, XL+XXL nur 1,8 % → Q5
6. Kandidaten zur Streichung → Brie Carre, Green Garden, Spinach Supreme, Mediterranean: zusammen \$56.182,5, 6,87 % des Umsatzes → Q6
7. Große Bestellungen → Bestellungen ab 4 Pizzen: 18,2 % der Bestellungen, 39,4 % des Umsatzes, Bestellwert \$83,1 gegenüber \$28,4 → Q7
8. Aktion → Zeitfenster Mo–Mi 14:00–16:00: 1.172 Bestellungen, \$45.550,3 Umsatz, +10 % = +\$4.555 pro Jahr (vor Rabattkosten) → Q8

## Werkzeuge

SQL (SQLite) für die Antworten, Tableau Public für das interaktive Dashboard (Filter nach Größe, Kategorie und Monat), HTML/PDF für die Präsentation.

## Empfehlungen für das Geschäft

- **Schichtplan:** volle Besetzung:
  - Mo–Do: 12:00–14:00, 17:00–19:00
  - Fr: 12:00–14:00, 17:00–21:00
  - Sa: 17:00–21:00
  - So: 17:00–19:00

  Zu den übrigen Zeiten reicht eine Minimalbesetzung.
- **Speisekarte:** 6 Wochen Test ohne Brie Carre, Green Garden, Spinach Supreme und Mediterranean (6,9 % des Umsatzes). Bleibt der Umsatz stabil, endgültig streichen; wandern viele Gäste ab, die Entscheidung überdenken.
- **Aktion:** Mo–Mi von 14:00 bis 16:00 auf Classic-Pizzen in Größe L (stärkste Kategorie und Größe), für Gruppen ab 4 Pizzen ein Set mit Bonus. Vorher 6 Wochen testen.

## Einschränkungen und nächste Schritte

- Daten nur für ein Jahr (2015) und nur aus der Kasse: keine Kosten und Gehälter, es wird der Umsatz analysiert, nicht der Gewinn.
- Ein Merkmal »Firma« fehlt in den Daten, die Annahme über Firmenkunden lässt sich daher nicht prüfen.
- Die Wirkung von Aktion und Streichung ist eine Schätzung. Nächster Schritt: 6-wöchiger Test von Aktion und Speisekarte mit Umsatzvergleich.

## Links

- Dashboard: https://public.tableau.com/views/pizza_dashboard_17912601498770/Pizzeria-Umsatzimberblick
- Präsentation: [Ukrainisch HTML](presentation/presentation-uk.html) · [Ukrainisch PDF](presentation/presentation-uk.pdf) · [Deutsch HTML](presentation/presentation-de.html) · [Deutsch PDF](presentation/presentation-de.pdf)
- SQL: [sql/queries.sql](sql/queries.sql) (deutsche Kommentare), [sql/queries-uk.sql](sql/queries-uk.sql) (ukrainisch)
- Datensatz: https://www.kaggle.com/datasets/mysarahmadbhat/pizza-place-sales
- Repository: https://github.com/RomanLuja/pizza-sales-analysis
