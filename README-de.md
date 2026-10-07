# Analyse der Pizzeria-Verkäufe

Abschlussaufgabe des ersten Kursteils *Data Analytics & Engineering*.
Autor: Roman Luja · 06.10.2026

## Ausgangslage

Die neue Inhaberin einer Pizzeria in New Jersey, Laura Martínez, hat die Kassendaten für das gesamte Jahr 2015 übernommen. Im Januar muss sie drei Entscheidungen treffen:

1. **Schichtplan:** keine unnötigen Mitarbeitenden in ruhigen Stunden und keine Überlastung zu Stoßzeiten.
2. **Speisekarte:** welche Pizzen gestrichen werden, weil es zu viele Positionen gibt.
3. **Aktion:** wann und welche Aktion gestartet wird, um schwache Tage und Stunden zu beleben.

Ich habe 8 Kernfragen mit SQL (SQLite) beantwortet, ein Dashboard in Tableau Public gebaut und eine Präsentation mit Empfehlungen erstellt.

## Links

- Datensatz (Kaggle, Pizza Place Sales): https://www.kaggle.com/datasets/mysarahmadbhat/pizza-place-sales
- Dashboard auf Tableau Public: https://public.tableau.com/views/pizza_dashboard_17912601498770/Pizzeria-Umsatzimberblick
- Präsentation (HTML): [presentation/index.html](presentation/index.html)
- Präsentation (PDF): [presentation/presentation.pdf](presentation/presentation.pdf)
- Repository: https://github.com/RomanLuja/pizza-sales-analysis

## Kurzantworten auf die 8 Fragen

1. **Kennzahlen.** Der Jahresumsatz beträgt $817 860 bei 21 350 Bestellungen und 49 574 verkauften Pizzen. Der durchschnittliche Bestellwert liegt bei $38.3, pro Bestellung werden im Schnitt 2.3 Pizzen gekauft.
2. **Verlauf nach Monaten.** Der stärkste Monat ist Juli ($72 558, 1 935 Bestellungen), der schwächste Oktober ($64 028, 1 646 Bestellungen). Der Unterschied beträgt 13.3%.
3. **Wochentage und Stunden.** Dienstag bis Freitag bringen 59.8% der Bestellungen des Jahres; Spitzenreiter ist der Freitag (70.8 Bestellungen pro Tag), am wenigsten ist am Sonntag los (50.5). Die Stunden 12–13 und 17–18 Uhr liefern 45.5% der Bestellungen, ruhig ist es von 14 bis 16 Uhr und nach 21 Uhr.
4. **Bestseller und Ladenhüter.** Beim Umsatz führt Thai Chicken ($43 434), bei der Menge Classic Deluxe (2 453 Stück). Die Listen stimmen bei 3 von 5 Pizzen überein (Thai Chicken, Barbecue Chicken, Classic Deluxe); in beiden Rankings am schwächsten ist Brie Carre ($11 589, 490 Stück).
5. **Kategorien und Größen.** Die Kategorien sind fast gleich stark: Classic 26.9%, Supreme 25.5%, Chicken 24.0%, Veggie 23.7%. Bei den Größen bringt L 45.9% des Umsatzes, M 30.5%, S 21.8%, XL und XXL zusammen nur 1.8%.
6. **Kandidaten zum Streichen.** Brie Carre, Green Garden, Spinach Supreme und Mediterranean bringen zusammen $56 184, das sind 6.9% des Umsatzes. Beim Streichen entfallen 6 Zutaten, die sonst nirgends verwendet werden.
7. **Große Bestellungen.** Bestellungen mit 4 oder mehr Pizzen machen 18.2% aller Bestellungen aus (3 880), bringen aber $322 571, also 39.4% des Umsatzes. Ihr durchschnittlicher Bestellwert beträgt $83.1 gegenüber $28.4 bei den übrigen; ein eigenes Angebot für Gruppen ist daher sinnvoll.
8. **Aktion.** Das ruhige Zeitfenster ist Montag bis Donnerstag, 14:00–16:00 Uhr: Es bringt aktuell $62 568 Umsatz, ein Plus von 10% ergäbe rund $6 257 pro Jahr (vor den Kosten des Rabatts).

## Drei Empfehlungen für Laura

1. **Schichtplan.** Volle Schicht mittags (12–14 Uhr) und abends (17–19 Uhr), minimale Besetzung von 14 bis 16 Uhr und nach 21 Uhr. Freitags und donnerstags werden die meisten Mitarbeitenden gebraucht, weil dann die meisten Bestellungen eingehen.
2. **Speisekarte.** 4 Pizzen streichen (Brie Carre, Green Garden, Spinach Supreme, Mediterranean): Das sind 6.9% des Umsatzes ($56 184) und 6 einzigartige Zutaten. Mit Brie Carre beginnen. Das ist eine Obergrenze, weil ein Teil der Gäste auf andere Pizzen ausweicht.
3. **Aktion.** Von Montag bis Donnerstag, 14:00–16:00 Uhr, „zweite Pizza mit Rabatt“ anbieten und für Gruppen ab 4 Pizzen ein Set mit Bonus. Potenzial bei +10%: $6 257 pro Jahr; vor dem Start mit einem Test über 4–6 Wochen prüfen.

## Struktur des Repositories

```
pizza-sales-analysis/
├── README.md
├── data/                  # 4 Original-CSV-Dateien von Kaggle
├── sql/
│   └── queries.sql        # alle Abfragen mit Kommentaren
├── exports/
│   └── sales_lines.csv    # Auswahl für Tableau (48 620 Zeilen)
├── tableau/
│   └── pizza_dashboard.twbx
└── presentation/
    ├── presentation.pdf
    └── index.html
```

## Einschränkungen der Daten

Die Daten umfassen nur ein Jahr (2015), es gibt keine Kosten und Gehälter (analysiert wird der Umsatz, nicht der Gewinn), und die Effekte der Aktion und des Streichens von Pizzen sind Schätzungen, die in der Praxis geprüft werden müssen.
