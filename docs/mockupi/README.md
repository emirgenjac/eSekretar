# Mockupi D-04 (ESK-16) — Emir

Wireframe ekrani: **HTML** (interaktivno u browseru) + **PNG** (za PR / dokumentaciju).

| Ekran | HTML | PNG |
| --- | --- | --- |
| Login | `01-login.html` | `01-login.png` |
| Glavni prozor | `02-glavni-prozor.html` | `02-glavni-prozor.png` |
| Custom upit | `03-custom-upit.html` | `03-custom-upit.png` |
| Uvoz Excel | `04-uvoz-excel.html` | `04-uvoz-excel.png` |
| Korisnici | `05-korisnici.html` | `05-korisnici.png` |
| Postavke | `06-postavke.html` | `06-postavke.png` |

UI: bosanski. Jedan tip naloga (puni pristup).

---

# Mockupi D-06 (ESK-18) — Adnan

Smještaj i finansije. Isti okvir i `stil.css` kao D-04; dodaci (bedževi, sobe, matrica, dijalozi) su u `stil-d06.css`.
Fajlovi imaju prefiks `D06-` da se ne miješaju s D-04/D-05.

| Ekran | HTML | PNG | FR |
| --- | --- | --- | --- |
| Sobe po spratovima | `D06-01-sobe-pregled.html` | `D06-01-sobe-pregled.png` | FR-07, FR-08 |
| Detalji sobe | `D06-02-soba-detalji.html` | `D06-02-soba-detalji.png` | FR-08, FR-09 |
| Zaduženje (dijalog) | `D06-03-zaduzenje.html` | `D06-03-zaduzenje.png` | FR-09 |
| Razduženje (dijalog, validacija) | `D06-04-razduzenje.html` | `D06-04-razduzenje.png` | FR-09, NFR-03 |
| Matrica uplata kao Excel | `D06-05-uplate-matrica.html` | `D06-05-uplate-matrica.png` | FR-12 |
| Unos uplate + kartica dugovanja | `D06-06-unos-uplate.html` | `D06-06-unos-uplate.png` | FR-12 |
| Dugovanja | `D06-07-dugovanja.html` | `D06-07-dugovanja.png` | FR-12, FR-18 |
| Akademske godine i cijena | `D06-08-cijena-smjestaja.html` | `D06-08-cijena-smjestaja.png` | FR-04 |
| Izvještaji (primjer: ministarstvo) | `D06-09-izvjestaji.html` | `D06-09-izvjestaji.png` | FR-15 |
| Backup / restore | `D06-10-backup.html` | `D06-10-backup.png` | FR-19 |
| Restore — druga potvrda | `D06-11-restore-potvrda.html` | `D06-11-restore-potvrda.png` | FR-19 |

Pravila prikazana na ekranima:

- **Sobe:** zauzeto = aktivna zaduženja (`datum_razduzenja IS NULL`); zaduženje nudi samo primljene bez smještaja, spol = tip sobe; premještaj = jedna transakcija.
- **Uplate:** mjeseci X–XII i I–VII (uključen maj), jedan iznos po mjesecu, bez rata; dug = cijena AG × dospjeli mjeseci od zaduženja − uplate.
- **Cijena:** unosi se za AG u pripremi (odluka UO); aktivna i zatvorena AG se ne mijenjaju (150 → 165).
- **Izvještaji:** svaki ima Izvezi PDF i Izvezi Excel (.xlsx); ministarstvo = kolone SRS §8.5 (format zaglavlja = D-07).
- **Backup:** folder, interval i upozorenje su u Postavkama (D-04); restore traži dvostruku potvrdu (upis „VRATI“).

Otvoreno za review (D-08):

1. Djelimičan mjesec (dolazak u toku mjeseca, jul do 15.7.): mockup računa puni mjesec, iznos se može ručno promijeniti.
2. Nazivi polja (soba, smjestaj, uplata, cijena_smjestaja) uskladiti s ER modelom iz D-02.
