# eSekretar — opis projekta i zahtjevi

> YouTrack Knowledge Base: naslov članka **Opis projekta i zahtjevi**.  
> Project: **eSekretar**. Zalijepi sadržaj ispod u New article → Publish.

---

## 1. Opis projekta

**eSekretar** je desktop aplikacija za **JU Studentski centar Zenica** (Crkvice 50, Zenica).  
Cilj je zamijeniti zastarjeli Excel kojim sekretarica vodi oko **220 studenata** godišnje (redovni prijem, lista čekanja, strani studenti).

Aplikacija centralizuje lične podatke, prijave po akademskoj godini, sobe, smještaj, mjesečne uplate, fotografije i izvještaje za ministarstvo (PDF i Excel).

| Stavka | Vrijednost |
| --- | --- |
| Klijent | JU Studentski centar Zenica |
| Kontakt | Tehnička poslovna sekretarica |
| Tim | Emir Genjac (voditelj), Emin Ahbabović, Adnan Jašarević |
| Rok | 16.11.2026 – 31.12.2026 |
| Metoda | Waterfall sa kontrolom promjena (Change Request) |
| Tehnologije | Java 25, JavaFX + FXML, MySQL, Maven |

### Uloge

- **SEKRETAR:** studenti, prijave, sobe, smještaj, lista čekanja, uplate, prenos, akademske godine (cijenu samo vidi), izvještaji, custom upiti, dashboard, vlastita lozinka i tema.
- **ADMIN:** sve što i SEKRETAR, plus korisnici, promjena cijene smještaja, uvoz iz Excel-a, backup i restore, postavke ustanove i historija promjena (Could).

### MoSCoW

- **Must** — obavezno do isporuke v1.0.0  
- **Should** — po želji / budući Change Request  
- **Should** — ako stigne (FR-24 zaboravljena lozinka / mail)
- **Could** — ako ostane vremena (FR-22, FR-23)

---

## 2. Funkcionalni zahtjevi (FR)

### Must

| ID | Opis |
| --- | --- |
| FR-01 | Prijava e-mailom i lozinkom; lozinke hashirane BCrypt-om |
| FR-02 | Uloge ADMIN i SEKRETAR; meni i akcije zavise od uloge |
| FR-03 | Upravljanje korisnicima (ADMIN) i promjena vlastite lozinke |
| FR-04 | Akademske godine (aktivna godina, period smještaja) i cijena smještaja: trenutno 165 KM, mijenja se od izabranog datuma |
| FR-05 | Studenti: lični podaci (ime, prezime, JMBG, broj lične karte, spol, telefon, e-mail, telefon roditelja, kanton, općina) i obavezna fotografija (CRUD) |
| FR-06 | Podaci po akademskoj godini: fakultet, godina studija, datum prijave, broj ugovora, kartica, napomena, uvjerenja (ljekarsko i sa fakulteta) |
| FR-07 | Sobe (kapacitet, sprat, tip muška/ženska, status) |
| FR-08 | Pregled soba: popunjenost, slobodna mjesta, studenti po sobama |
| FR-09 | Smještaj: zaduženje sobe, premještanje, razduženje sobe (sa datumima) |
| FR-10 | Lista čekanja: rang lista, naknadni prijem, odbijanje, historija statusa |
| FR-11 | Strani studenti (država, pasoš, program razmjene, period boravka) |
| FR-12 | Mjesečne uplate u rasporedu kao u Excel-u; dugovanja po važećoj cijeni |
| FR-13 | Prenos studenata iz prethodne akademske godine |
| FR-14 | Pretraga i filtriranje |
| FR-15 | Predefinisani izvještaji (uključujući pregled kao stari Excel); export u PDF i Excel |
| FR-16 | Custom upiti (kolone i filteri); export u PDF i Excel; šabloni upita |
| FR-17 | Dashboard sa grafikonima |
| FR-18 | Notifikacije |
| FR-19 | Backup i restore baze |
| FR-20 | Podešavanja i tema (svijetla i tamna) |
| FR-21 | Uvoz postojećeg Excel-a (sve kolone, uključujući uplate po mjesecima) |

### Should

| ID | Opis |
| --- | --- |
| FR-24 | Zaboravljena lozinka: reset / privremena lozinka na e-mail sekretarice |

### Could

| ID | Opis |
| --- | --- |
| FR-22 | Historija promjena (audit log) |
| FR-23 | PDF kartica studenta sa fotografijom |

---

## 3. Nefunkcionalni zahtjevi (NFR)

| ID | Opis | MoSCoW |
| --- | --- | --- |
| NFR-01 | Java 25, JavaFX + FXML, MySQL, Maven, iText, Apache POI | Must |
| NFR-02 | Sigurnost: BCrypt, isključivo PreparedStatement, provjera uloge u servisima, lozinka baze van Gita | Must |
| NFR-03 | Upotrebljivost: UI na bosanskom, validacija formi, jasne poruke | Must |
| NFR-04 | Performanse: liste do ~300 studenata &lt; 1 s; duge operacije u pozadini | Must |
| NFR-05 | Pouzdanost: transakcije za prenos i smještaj, redovan backup | Must |
| NFR-06 | Održivost: slojevita arhitektura, DAO interfejsi, Flyway, testovi servisa, CI | Must |
| NFR-07 | Isporuka: Windows 10/11, paket sa uključenom Javom (jpackage) | Must |
| NFR-08 | Centralizacija i zaštita podataka: jedna baza (i fotografije), pristup samo prijavljenim korisnicima | Must |

---

## 4. Polazna tačka — Excel sekretarice

Kolone koje se danas vode mapiraju se u bazu (sažeto):

- Ime i prezime, telefoni, e-mail, kanton, općina, spol, JMBG, broj lične karte → **student**
- Fakultet, godina, broj ugovora, datum prijave, kartica, napomena, uvjerenja → **prijava**
- Soba, datum zaduženja, razduženje → **smještaj**
- Mjeseci 10, 11, 12, 1, 2, 3, 4, 6, 7 (uplaćeno) → **uplata**
- Cijena 165 KM (promjenjiva) → **cijena_smjestaja** (važi od datuma)

---

## 5. Faze (podsjetnik)

| Faza | Period |
| --- | --- |
| F1 Analiza | 16.–19.11.2026 |
| F2 Dizajn | 20.–26.11.2026 |
| F3 Implementacija | 27.11.–19.12.2026 |
| F4 Testiranje | 20.–23.12.2026 |
| F5 Isporuka | 24.–28.12.2026 |
| F6 Održavanje | 29.–31.12.2026 |

Izmjena zahtjeva usred rada ide kao issue tipa **Change Request**, ne vraćanjem na raniju fazu.
