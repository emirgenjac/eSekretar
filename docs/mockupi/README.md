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

---

# Mockupi D-05 (ESK-17) — Emin

Studenti, lista čekanja, prenos i dashboard. Isti okvir kao D-04 i D-06 (`stil.css` + `stil-d06.css`), a ono čega tamo nema je u `stil-d05.css`.
Fajlovi imaju prefiks `D05-`. Nazivi polja i statusa su iz ER modela (D-02) i dijagrama stanja prijave (D-03).

| Ekran | HTML | PNG | FR |
| --- | --- | --- | --- |
| Lista studenata, sve kolone Excela | `D05-01-studenti-lista.html` | `D05-01-studenti-lista.png` | FR-05, FR-14 |
| Novi student (validacija, dupli JMBG) | `D05-02-student-novi.html` | `D05-02-student-novi.png` | FR-05, FR-11, NFR-03 |
| Prijava za AG + historija statusa | `D05-03-prijava-ag.html` | `D05-03-prijava-ag.png` | FR-06, FR-10 |
| Lista čekanja | `D05-04-lista-cekanja.html` | `D05-04-lista-cekanja.png` | FR-10 |
| Primi sa liste (dijalog) | `D05-05-primi-dijalog.html` | `D05-05-primi-dijalog.png` | FR-10, FR-09 |
| Odbij prijavu (dijalog, validacija) | `D05-06-odbij-dijalog.html` | `D05-06-odbij-dijalog.png` | FR-10, NFR-03 |
| Prenos u novu AG, odabir | `D05-07-prenos-odabir.html` | `D05-07-prenos-odabir.png` | FR-13 |
| Prenos, potvrda | `D05-08-prenos-potvrda.html` | `D05-08-prenos-potvrda.png` | FR-13, NFR-05 |
| Dashboard | `D05-09-dashboard.html` | `D05-09-dashboard.png` | FR-17, FR-18 |

`D05-01` je snimljen kao široko otvoren prozor (2520 px) da se vide sve kolone. U aplikaciji tabela ima horizontalni scroll, a R.br. i ime ostaju fiksni.

Pravila prikazana na ekranima:

- **Studenti:** kolone i redoslijed kao Excel sekretarice (SRS §8.2, `v_student_pregled`); aktivni = bez razduženja, razduženi su poseban tab; dupli JMBG odbijen; JMBG ili pasoš obavezan; foto se može dodati kasnije uz upozorenje.
- **Prijava:** fakultet = editable ComboBox (8 prijedloga ili slobodan unos); uvjerenja „DA“ kad su dostavljena; status se mijenja samo akcijama i svaka promjena ide u historiju.
- **Lista čekanja:** rang = bodovi opadajuće, pa datum prijave rastuće; „Primi“ = prijem + zaduženje sobe u jednoj transakciji (`primljen_naknadno`); „Odbij“ traži razlog; odbijen → primljen nije dozvoljen.
- **Prenos:** nove prijave u ciljnoj AG sa statusom „prijavljen“ i vezom na staru; kartica se prenosi, ugovor i uvjerenja ne; soba i uplate kreću od nule; sve u jednoj transakciji.
- **Dashboard (konačan set za FR-17):** popunjenost, slobodna mjesta M/Ž, lista čekanja, dospjeli dug (`dug_dospjeli`, samo završeni mjeseci); popunjenost po spratu, prijave po statusu, uplate po mjesecima (obaveza / uplaćeno), prvih 5 s liste čekanja, notifikacije. Sve za aktivnu AG.

Otvoreno za review (D-08):

1. Prenos: mockup prenosi i fakultet, trajanje i godinu upisa (da se ne kucaju ponovo). SRS izričito navodi samo karticu, pa treba potvrditi.
2. Bodovi za rang: aplikacija ih samo upisuje, ne računa. Ako komisija ima formulu, to je posebna stavka (CR).
3. Godina studija se poslije prenosa ne povećava automatski, sekretarica je provjerava.
