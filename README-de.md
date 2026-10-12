# Analyse der Pizzeria-Verkäufe

Abschlussaufgabe des ersten Kursteils *Data Analytics & Engineering*.
Autor: Roman Luja · 06.10.2026 · [Українська версія](README.md)

## Ausgangslage

Die neue Inhaberin einer Pizzeria in New Jersey hat sich als Datenanalyst an mich gewandt. Hier ist ihre E-Mail:

> **Von:** Laura Martínez, Inhaberin der Pizzeria
> **Betreff:** Daten für das Jahr – ich brauche Ihre Hilfe
>
> Guten Tag!
>
> Ende des Jahres habe ich in New Jersey eine Pizzeria vom bisherigen Inhaber gekauft. Zusammen mit dem Laden habe ich einen Export aus der Kasse für das gesamte Jahr 2015 erhalten: jede Bestellung, Datum und Uhrzeit, welche Pizzen und wie viele. Mit diesen Tabellen komme ich selbst nicht zurecht.
> Im Januar muss ich drei Entscheidungen treffen:
>
> * wie ich den Schichtplan gestalte, damit ich in ruhigen Stunden keine unnötigen Leute beschäftige und zur Stoßzeit nicht überlastet bin;
> * welche Pizzen ich von der Speisekarte nehme – es gibt zu viele Positionen, und ein Teil der Zutaten verdirbt;
> * wann und welche Aktion ich starte, um schwache Tage und Stunden zu beleben.
>
> Bitte bereiten Sie eine kurze Präsentation mit einem interaktiven Dashboard vor, damit ich selbst mit den Filtern spielen kann. Am wichtigsten sind mir konkrete Empfehlungen mit Zahlen.
> Vielen Dank! Laura

Was ich gemacht habe: 8 Kernfragen mit SQL (SQLite) beantwortet, ein interaktives Dashboard in Tableau Public gebaut (Filter nach Größe, Kategorie und Monat) und eine Präsentation mit drei Empfehlungen samt Zahlen erstellt.

## Links

- Datensatz (Kaggle, Pizza Place Sales): https://www.kaggle.com/datasets/mysarahmadbhat/pizza-place-sales
- Dashboard auf Tableau Public: https://public.tableau.com/views/pizza_dashboard_17912601498770/Pizzeria-Umsatzimberblick
- Präsentation, Deutsch (HTML): [presentation/presentation-de.html](presentation/presentation-de.html)
- Präsentation, Deutsch (PDF): [presentation/presentation-de.pdf](presentation/presentation-de.pdf)
- Präsentation, Ukrainisch (HTML): [presentation/presentation-uk.html](presentation/presentation-uk.html)
- Präsentation, Ukrainisch (PDF): [presentation/presentation-uk.pdf](presentation/presentation-uk.pdf)
- SQL-Abfragen: [sql/queries.sql](sql/queries.sql) (deutsche Kommentare), [sql/queries-uk.sql](sql/queries-uk.sql) (ukrainisch)
- Repository: https://github.com/RomanLuja/pizza-sales-analysis

## Daten

4 verknüpfte Tabellen von Kaggle: `orders` (21 350 Zeilen), `order_details` (48 620), `pizzas` (96), `pizza_types` (32). Qualitätsprüfungen: 0 fehlende Werte, 0 doppelte Schlüssel, 0 verwaiste Verknüpfungen, 0 Bestellungen ohne Positionen. Umsatz = Preis × Menge.

## Kurzantworten auf die 8 Fragen

1. **Kennzahlen des Jahres.** Der Jahresumsatz beträgt $817 860, mit 21 350 Bestellungen und 49 574 verkauften Pizzen. Der durchschnittliche Bestellwert liegt bei $38.31, pro Bestellung werden im Schnitt 2.3 Pizzen verkauft.
2. **Entwicklung nach Monaten.** Der stärkste Monat ist der Juli ($72 557.9, 1 935 Bestellungen), der schwächste der Oktober ($64 027.6, 1 646 Bestellungen). Der Unterschied beträgt 13.3%. Das stärkste Wachstum zum Vormonat gab es im November (+9.9%), den stärksten Rückgang im Dezember (−8.1%).
3. **Wochentage und Uhrzeiten.** Durchschnittlich pro Tag: Freitag 70.8 Bestellungen (Maximum), Donnerstag 62.3, Samstag 60.7, Montag und Mittwoch je 58.2, Dienstag 57.2, Sonntag 50.5 (Minimum). Die Stoßzeiten liegen mittags (12:00 Uhr: 2 520 Bestellungen im Jahr) und abends (18:00 Uhr: 2 399); die Stunden 12–13 und 17–18 Uhr bringen 45.5% der Bestellungen. Ruhiger ist es um 14:00 und 15:00 Uhr (1 472 bzw. 1 468) sowie spät abends.
4. **Bestseller und Ladenhüter.** Beim Umsatz liegt Thai Chicken vorn ($43 434), bei der Menge Classic Deluxe (2 453 Stück). Die Top 5 stimmen bei 3 von 5 Pizzen überein (Thai Chicken, Barbecue Chicken, Classic Deluxe), die letzten 5 ebenfalls bei 3 (Brie Carre, Mediterranean, Spinach Supreme). Brie Carre ist bei Umsatz ($11 588.5) und Menge (490 Stück) die schwächste Pizza.
5. **Kategorien und Größen.** Die Kategorien liegen nah beieinander: Classic 26.9%, Supreme 25.5%, Chicken 24.0%, Veggie 23.7%. Bei den Größen bringt L 45.9% des Umsatzes, M 30.5%, S 21.8%, XL und XXL zusammen nur 1.8%.
6. **Kandidaten für die Streichung.** Brie Carre, Green Garden, Spinach Supreme und Mediterranean bringen zusammen $56 182.5, das sind 6.87% des Umsatzes. Brie Carre ist bei Umsatz und Menge die schwächste Pizza. Green Garden liegt bei der Menge (997 Stück) knapp außerhalb der fünf schwächsten, der Abstand zu Mediterranean und Spinach Supreme (934 und 950 Stück) ist aber gering. Da nur Kassendaten vorliegen, wird ein Test von 6 Wochen ohne diese Pizzen empfohlen statt einer endgültigen Streichung.
7. **Große Bestellungen.** Bestellungen mit 4 oder mehr Pizzen machen 18.2% aus (3 880 von 21 350), bringen aber $322 570.9, also 39.4% des Umsatzes. Ihr durchschnittlicher Bestellwert liegt bei $83.1 gegenüber $28.4 bei den übrigen, daher kann ein eigenes Angebot für Gruppen und Firmen sinnvoll sein. Ob es sich dabei tatsächlich um Firmen handelt, zeigen die Kassendaten nicht.
8. **Aktion.** Das ruhige Zeitfenster ist Montag bis Mittwoch, 14:00–16:00 Uhr (1 172 Bestellungen im Jahr). Es bringt derzeit $45 550.3 Umsatz, ein Plus von 10% ergibt $4 555 pro Jahr (vor Kosten des Rabatts). Als Aktion eignen sich Classic-Pizzen in Größe L: Classic ist die stärkste Kategorie (26.9%), L die stärkste Größe (45.9%); im Zeitfenster bringen sie $3 605.25 (7.9% des Umsatzes im Fenster).

## Drei Empfehlungen für Laura

1. **Schichtplan.** Volle Schicht mittags (12–14 Uhr) und abends (17–19 Uhr), minimale Besetzung von 14 bis 16 Uhr und spät abends. Am meisten Personal wird freitags (70.8 Bestellungen pro Tag) und donnerstags (62.3) gebraucht, am wenigsten sonntags (50.5).
2. **Speisekarte.** Vier Pizzen (Brie Carre, Green Garden, Spinach Supreme, Mediterranean) 6 Wochen lang testweise von der Karte nehmen: Das sind 6.9% des Umsatzes ($56 182.5) und 6 Zutaten, die sonst nirgends verwendet werden. Bleibt der Umsatz stabil, endgültig streichen; wechseln die Gäste stark ab, die Entscheidung überdenken.
3. **Aktion.** Montag bis Mittwoch von 14:00 bis 16:00 Uhr eine Aktion auf Classic-Pizzen in Größe L starten, für Gruppen ab 4 Pizzen ein Set mit Bonus. Der Umsatz im Zeitfenster beträgt derzeit $45 550.3, das Potenzial von +10% sind $4 555 pro Jahr (vor Kosten des Rabatts); vor dem Start mit einem Test über 6 Wochen prüfen.

## Struktur des Repositorys

```
pizza-sales-analysis/
├── README.md
├── README-de.md
├── data/                      # 4 CSV-Quelldateien von Kaggle
├── sql/
│   ├── queries.sql            # alle Abfragen mit Kommentaren (deutsche Version)
│   └── queries-uk.sql         # ukrainische Version
├── exports/
│   └── sales_lines.csv        # Auswahl für Tableau (48 620 Zeilen)
├── tableau/
│   └── pizza_dashboard.twbx
└── presentation/
    ├── presentation-uk.html   # Ukrainisch, mit interaktivem Dashboard
    ├── presentation-de.html   # Deutsch
    ├── presentation-uk.pdf
    └── presentation-de.pdf
```

## Einschränkungen der Daten

Die Daten umfassen nur ein Jahr (2015) und stammen nur aus der Kasse: Es gibt keine Kosten und Gehälter (betrachtet wird der Umsatz, nicht der Gewinn). In den Daten gibt es kein Merkmal „Firma“, daher lässt sich die Annahme über Firmenkunden nicht prüfen. Der Effekt von Aktion und Streichung ist eine Schätzung, die in der Praxis geprüft werden muss.
