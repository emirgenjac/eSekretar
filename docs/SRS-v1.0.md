# Softverska specifikacija zahtjeva (SRS)

| | |
| --- | --- |
| **Projekat** | eSekretar |
| **Klijent** | JU Studentski centar Zenica (Crkvice 50, Zenica) |
| **Verzija** | **1.4** (final F1 — bez obavezne potvrde klijenta na SRS) |
| **Datum** | 18.11.2026 |
| **Autor** | Emir Genjac (voditelj) |
| **Tim** | Emir Genjac, Emin Ahbabović, Adnan Jašarević |
| **Status** | F1 Analiza — spremno za tim review (A-06) i zatvaranje M1 |
| **YouTrack** | ESK / A-05 |
| **Metoda** | Waterfall + Change Request |

---

## 1. Uvod

### 1.1 Svrha dokumenta

Ovaj SRS definiše šta sistem **eSekretar** mora raditi (FR), pod kojim kvalitetom (NFR), ko ga koristi, procese i granice. Ulaz je u dizajn (F2) i implementaciju (F3).

**M1:** tim review SRS-a. **Potvrda klijenta na tekst SRS-a nije obavezna** (zahtjevi su prikupljeni na A-02 sastanku i ovdje ugrađeni).

### 1.2 Opseg proizvoda

Desktop aplikacija za evidenciju studenata u studentskom domu: lični podaci, prijave po akademskoj godini, sobe, smještaj, lista čekanja, mjesečne uplate, fotografije, izvještaji, uvoz Excela, backup/restore.

- **Primarni unos:** aplikacija.
- **Excel kao rezerva:** stari fajl arhiva; iz app-a periodični export `.xlsx` („Pregled kao Excel“) + backup baze. Bez paralelnog dnevnog unosa u Excel i app.
- **Export izvještaja:** za svaki relevantni izvještaj (uključujući ministarstvo i custom upite) korisnik bira **PDF** i/ili **`.xlsx`** — obje opcije su Must.

### 1.3 Definicije

| Pojam | Značenje |
| --- | --- |
| SRS | Softverska specifikacija zahtjeva |
| FR / NFR | Funkcionalni / nefunkcionalni zahtjev |
| MoSCoW | Must / Should / Could / Won’t |
| Korisnik | Prijavljeni nalog s punim pristupom (v1.0 bez podjele uloga) |
| JMBG | Jedinstveni matični broj građana |
| CR | Change Request |
| POI / iText | Apache POI (`.xlsx`) / iText (PDF) |
| AG | Akademska godina |
| UAT | User Acceptance Testing |

### 1.4 Reference

- YouTrack KB: opis projekta i zahtjevi
- `docs/youtrack/TASKOVI-SKRACENO.md`
- Primjer reda Excela (§8.2) — dovoljan za mapiranje; puni produkcijski Excel nije potreban (demo podaci = mock seed u F3)
- Kolone izvještaja ministarstva (§8.5)

### 1.5 Struktura dokumenta

§2 opšti opis · §3 prava · §4 procesi · §5 use case · §6–7 FR/NFR · §8 podaci · §9 arhitektura · §10 van opsega · §11 odluke · §12 M1 / CR

---

## 2. Opšti opis

### 2.1 Kontekst

Evidencija se danas vodi u Excelu (~220 studenata godišnje: prijem, lista čekanja, strani studenti). eSekretar centralizuje podatke u **MySQL**, UI na **bosanskom**, Windows PC sekretarijata.

### 2.2 Korisnici

| Klasa | Opis |
| --- | --- |
| Sekretarica | Jedini korisnik — puni pristup |
| Ministarstvo | Prima izvezene fajlove; bez logina |

**Odluka:** nema Must podjele ADMIN/SEKRETAR. Jedan tip naloga = sva prava. Druga uloga = Change Request ako zatreba.

### 2.3 Operativno okruženje

| Stavka | Zahtjev |
| --- | --- |
| OS | Windows 10 / 11 |
| Isporuka | `jpackage` s ugrađenom Javom |
| Baza | MySQL 8 |
| Korisnici | 1–3 tipično |
| Obim | ~300 aktivnih studenata / godina |

### 2.4 Ograničenja implementacije

Java 25 · JavaFX + FXML (+ AtlantaFX) · MySQL + JDBC + HikariCP + Flyway · iText + Apache POI · BCrypt · slojevi View → Controller → Service → DAO · ručni `AppContext` · package `ba.sczenica.esekretar` · Maven · GitHub Actions · YouTrack ESK

### 2.5 Zavisnosti

- Mapiranje Excela i ministarstva zatvoreno na osnovu A-02 + primjera (§8).
- Demo / test podaci: **mock seed** (F3), ne čekati puni produkcijski Excel.
- Početna cijena smještaja: **165 KM**.

---

## 3. Prava pristupa

- Samo **prijavljeni** pristup podacima.
- Svi nalozi: **isti, puni** skup prava.
- Upravljanje nalozima (FR-03) ostaje (drugi nalog, reset lozinke) — i dalje puni pristup.

Puni pristup uključuje: studente, smještaj, uplate, izvještaje (**PDF i Excel**), custom upite, dashboard, notifikacije, akademske godine, cijenu, korisnike, uvoz Excel, backup/restore, postavke, temu; (Could) audit.

---

## 4. Poslovni procesi

(Dijagram / detaljni UC tokovi: A-03 → `docs/`.)

### 4.1 Prijem

Unos studenta → prijava za aktivnu AG → po potrebi lista čekanja → zaduženje sobe.

### 4.2 Lista čekanja

Rang, status; primi / odbij / izmjena ranga; historija statusa.

### 4.3 Smještaj

Zaduženje · premještanje (transakcija) · razduženje (`datum_razduzenja`; sklanjanje s aktivne liste = sheet „razduženi“).  
Period boravka: **1.10. tekuće – 15.7. naredne**.

### 4.4 Uplate

Matrica mjeseci; **bez rata** (jedan iznos / mjesec). Plaća od dolaska do odlaska unutar 1.10–15.7.  
Mjeseci: **10–12, 1–7** (uklj. maj). Dug = obaveze − uplate (cijena AG).

### 4.5 Prenos u novu AG

Odabir studenata → nove prijave; **ne** prenosi ugovor ni uvjerenja; **kartica se prenosi**. Smještaj/uplate nove godine od nule.

### 4.6 Izvještavanje i rezerva

Predefinisani izvještaji + ministarstvo + „Pregled kao Excel“.  
Svaki: dugmad **Izvezi PDF** i **Izvezi Excel (.xlsx)**.  
Periodični `.xlsx` + DB backup = rezerva.

### 4.7 Uvoz Excel

Odabir `.xlsx` → pregled → validacija → uvoz u transakciji za AG.

---

## 5. Use case pregled

Detaljni tokovi: A-03. Ovdje ID ↔ FR.

| ID | Naziv | FR |
| --- | --- | --- |
| UC-01 | Prijava u sistem | FR-01 |
| UC-02 | Odjava | FR-01 |
| UC-03 | Promjena vlastite lozinke | FR-03 |
| UC-04 | Upravljanje korisnicima | FR-03 |
| UC-05 | Upravljanje akademskom godinom | FR-04 |
| UC-06 | Izmjena cijene smještaja | FR-04 |
| UC-07 | CRUD studenta | FR-05 |
| UC-08 | CRUD prijave | FR-06 |
| UC-09 | Upravljanje sobama | FR-07, FR-08 |
| UC-10 | Zaduženje / premještaj / razduženje | FR-09 |
| UC-11 | Lista čekanja | FR-10 |
| UC-12 | Strani studenti | FR-11 |
| UC-13 | Uplate / dug | FR-12 |
| UC-14 | Prenos u novu godinu | FR-13 |
| UC-15 | Pretraga / filter | FR-14 |
| UC-16 | Izvještaji + export PDF/XLSX | FR-15 |
| UC-17 | Custom upit + šablon | FR-16 |
| UC-18 | Dashboard | FR-17 |
| UC-19 | Notifikacije | FR-18 |
| UC-20 | Backup / restore | FR-19 |
| UC-21 | Postavke i tema | FR-20 |
| UC-22 | Uvoz Excel | FR-21 |
| UC-23 | Audit log (Could) | FR-22 |
| UC-24 | PDF kartica studenta (Could) | FR-23 |

Akter: **Korisnik**; sekundarno **Sistem** (notifikacije, auto-backup).

---

## 6. Funkcionalni zahtjevi

**Must** = v1.0.0 · **Could** = rezerva F3.

### 6.1 Must

#### FR-01 Prijava i odjava
Prijava imenom/lozinkom; BCrypt hash; odjava zatvara sesiju.  
**Prihvatanje:** login/logout OK; pogrešna lozinka odbijena; nema plain-text lozinke u bazi.

#### FR-02 Pristup nakon prijave
Prijavljeni = puni pristup (§3). Neprijavljeni = samo login. Bez Must uloga.  
**Prihvatanje:** nakon logina dostupni backup, uvoz, cijena, korisnici.

#### FR-03 Korisnici i lozinka
CRUD naloga; vlastita lozinka; novi nalozi = puni pristup.  
**Prihvatanje:** novi nalog radi; deaktivirani ne.

#### FR-04 Akademske godine i cijena
AG s periodom tipično 1.10–15.7; cijena prije početka AG (UO odobrava prije konkursa); vrijedi od početka te AG; historija (npr. 150 → 165); seed **165 KM**.  
**Prihvatanje:** nova AG 165; stara i dalje računa po staroj cijeni.

#### FR-05 Studenti
Prezime, ime, **ime roditelja**, JMBG, lična, spol (M/Ž), **adresa**, telefon, e-mail, **telefoni roditelja** (više brojeva), kanton (šifarnik), općina, fotografija (mandatorna po konkursu, **unos naknadno** OK uz upozorenje).  
**Prihvatanje:** polja se čuvaju; dupli JMBG odbijen; foto naknadno OK.

#### FR-06 Prijava po AG
**Fakultet:** editable ComboBox — predlošci (§8.4) **ili free unos**.  
Godina studija/ciklus (npr. III); **trajanje studija**; **godina upisa**; datum prijave (konkurs); broj ugovora; kartica (broj); napomena; ljekarsko/fakultetsko uvjerenje = **DA** kad dostavljena.  
**Prihvatanje:** free fakultet radi; ministarska polja dostupna.

#### FR-07 Sobe
Kapacitet, sprat, tip (muška/ženska), status.  
**Prihvatanje:** CRUD; nevalidan kapacitet odbijen.

#### FR-08 Pregled soba
Popunjenost, slobodna mjesta, stanari.  
**Prihvatanje:** brojke = aktivna zaduženja.

#### FR-09 Smještaj
Zaduženje / premještaj / razduženje; transakcije; kapacitet. Razduženi van aktivne liste.  
**Prihvatanje:** konzistentna historija; aktivni = `datum_razduzenja IS NULL`.

#### FR-10 Lista čekanja
Rang, primi, odbij, historija.  
**Prihvatanje:** „Primi“ → tok smještaja.

#### FR-11 Strani studenti
Država, pasoš, razmjena, period boravka.  
**Prihvatanje:** pretraga po pasošu.

#### FR-12 Uplate i dugovanja
Matrica; mjeseci 10–12, 1–7; ćelija npr. `165,00 KM`; **bez rata**; dug po cijeni AG; period od zaduženja do razduženja.  
**Prihvatanje:** maj u matrici; jedan iznos po mjesecu.

#### FR-13 Prenos
Bez ugovora/uvjerenja; kartica da; transakcija.  
**Prihvatanje:** nema poluupisanog stanja.

#### FR-14 Pretraga
Ime, prezime, JMBG, lična, pasoš, fakultet, soba, status, godina.  
**Prihvatanje:** &lt; 1 s za ~300 redova.

#### FR-15 Izvještaji i export
- Predefinisani: smješteni, sobe, lista čekanja, strani, uplate/dug, statistika.
- **Ministarstvo** — kolone §8.5.
- **Pregled kao Excel** — kolone sekretaričinog Excela + mjeseci; sheet **aktivni** + **razduženi**.
- Na svakom od navedenih: korisnik bira export u **PDF** **i** u **`.xlsx`** (oba formata dostupna, FileChooser). PDF = iText; Excel = POI.
- **Prihvatanje:** za isti izvještaj moguće snimiti i `.pdf` i `.xlsx`; ministarstvo s kolonama §8.5; Excel backup s dva sheeta.

#### FR-16 Custom upiti
Whitelist kolona/filtera; šabloni; export rezultata u **PDF** i **`.xlsx`**.  
**Prihvatanje:** nema SQL injection; šablon se ponovo pokreće.

#### FR-17 Dashboard
Grafikoni / KPI (popunjenost, dugovanja, lista čekanja — tačan set u F2 mockupu).  
**Prihvatanje:** učitava se za aktivnu AG.

#### FR-18 Notifikacije
Neplaćen prethodni mjesec; backup stariji od N dana (npr. 7); zvonce + toast.  
**Prihvatanje:** vidljivo nakon prijave.

#### FR-19 Backup / restore
mysqldump; restore s dvostrukom potvrdom; auto po intervalu.  
**Prihvatanje:** restore vraća poznati dataset.

#### FR-20 Postavke i tema
Svijetla/tamna bez restarta; ustanova, putanje, interval backup-a.  
**Prihvatanje:** tema odmah; postavke utiču na backup.

#### FR-21 Uvoz Excel
`.xlsx` → pregled → validacija → transakcija za AG (uklj. uplate). Mapiranje po §8.2.  
**Prihvatanje:** validan fajl (ili mock) uveze konzistentno; greške prijavljene.

### 6.2 Could

| ID | Opis |
| --- | --- |
| FR-22 | Audit log |
| FR-23 | PDF kartica studenta s fotografijom |

### 6.3 MoSCoW

Must: FR-01…FR-21 · Could: FR-22, FR-23 · ostalo = CR.

---

## 7. Nefunkcionalni zahtjevi

| ID | Kategorija | Specifikacija | MoSCoW |
| --- | --- | --- | --- |
| NFR-01 | Tehnologija | Java 25, JavaFX+FXML, MySQL 8, Maven, iText, POI, Flyway, HikariCP, JUnit 5 | Must |
| NFR-02 | Sigurnost | BCrypt; PreparedStatement; samo prijavljeni; tajne van Gita | Must |
| NFR-03 | UX | UI bosanski; validacija; jasne poruke | Must |
| NFR-04 | Performanse | ~300 redova &lt; 1 s; uvoz/izvoz/backup u pozadini | Must |
| NFR-05 | Pouzdanost | Transakcije (prenos, smještaj); backup | Must |
| NFR-06 | Održivost | Slojevi; DAO interfejsi; Flyway; testovi; CI | Must |
| NFR-07 | Isporuka | Windows 10/11; jpackage s Javom | Must |
| NFR-08 | Podaci | Jedna baza + foto; samo prijavljeni | Must |

---

## 8. Podaci i mapiranje

### 8.1 Entiteti (konceptualno)

korisnik · student (uklj. ime_roditelja, adresa, telefoni_roditelja) · kanton · fakultet (predlošci) · prijava (ugovor, kartica, godina/ciklus, trajanje, godina_upisa, uvjerenja) · akademska_godina · cijena_smjestaja · soba · smjestaj · lista_cekanja · uplata · postavka · notifikacija · (Could) audit_log  

ER: F2 (D-02).

### 8.2 Primjer reda Excela (kanonski za mapiranje)

Puni produkcijski Excel **nije potreban**. Ovaj primjer + mock seed u F3.

| Excel | Polje |
| --- | --- |
| Redni broj `66` | prikaz (nije PK) |
| `Genjac (Ime oca) Emir` | prezime + ime_roditelja + ime |
| Tel. roditelja (2 broja) | telefoni_roditelja |
| Kanton `ZDK` | kanton |
| Općina `Visoko` | opcina |
| Adresa | student.adresa (ministarstvo) |
| Spol `M` | spol |
| e-mail / telefon | student |
| Ugovor `09-130-820-385/26` | broj_ugovora |
| Fakultet `Politehnički fakultet` | fakultet (ComboBox + free) |
| Godina `III` | godina_studija_ciklus |
| Trajanje / godina upisa | prijava |
| JMBG / lična | student |
| Datum prijave `9.9.2026.` | datum_prijave |
| Soba `19` / zaduženje `5.10.2026.` | smještaj |
| Kartica `2691` | kartica |
| Uvjerenja `DA` / `DA` | uvjerenja |
| `10`/`11`: `165,00 KM` | uplata |
| Sheet razduženi | smještaj s razduženjem |

### 8.3 Poslovna pravila

1. Cijena po AG, prije početka godine.  
2. Fakultet = predlošci + free unos; kanton = šifarnik; općina = tekst.  
3. Ime roditelja posebno; Excel prikaz `Prezime (ImeOca) Ime`.  
4. Aktivni = bez razduženja; razduženi = drugi pregled/sheet.  
5. Prenos: bez ugovora/uvjerenja; kartica da.  
6. Uplate: bez rata; mjeseci 10..7 uklj. maj.  
7. Export: **PDF i .xlsx** za izvještaje; Excel backup s aktivni+razduženi.  
8. Foto naknadno OK.  
9. Adresa, trajanje studija, godina upisa za ministarstvo.

### 8.4 Seed fakulteta

1. Fakultet inženjerstva i prirodnih nauka  
2. Mašinski fakultet  
3. Filozofski fakultet  
4. Ekonomski fakultet  
5. Pravni fakultet  
6. Medicinski fakultet  
7. Politehnički fakultet  
8. Islamski pedagoški fakultet  

### 8.5 Izvještaj ministarstva

Ime · Prezime · Ime roditelja · Općina · Adresa · Fakultet · Godina studija/ciklus · Trajanje studija · Godina upisa · Broj ugovora · JMBG  

Export: **PDF** i **`.xlsx`** (oba).

---

## 9. Arhitektura (sažetak)

```
View (FXML/CSS) → Controller → Service → DAO → HikariCP → MySQL
                              ↘ PdfExporter / ExcelExporter / Importer / QueryBuilder
Flyway pri startu
```

Kontroler ne zove DAO. Detalji: F2.

---

## 10. Van opsega (v1.0.0)

- Web / mobilna app  
- Višejezičnost  
- API prema ministarstvu (samo fajlovi)  
- Paralelni dnevni Excel unos  
- Cloud kao obaveza  
- Podjela uloga ADMIN/SEKRETAR  
- Čekanje punog produkcijskog Excela za razvoj (koristi se mock seed)

---

## 11. Odluke (A-02) — zatvoreno

| # | Odluka |
| --- | --- |
| 1 | Kartica = broj (npr. 2691) |
| 2 | Datum prijave = predaja na konkurs |
| 3 | Maj uključiti u matricu |
| 4 | Uvjerenja = DA kad dostavljena |
| 5–6 | Kolone OK; sheet razduženi |
| 7–8 | Cijena prije AG; vrijedi od početka AG |
| 9 | Bez rata |
| 10 | Period 1.10–15.7; plaća od dolaska do odlaska |
| 11 | App = unos; Excel = backup |
| 12–14 | Samo sekretarica; bez Must uloga |
| 15 | Procesi / UC dijagram → A-03 |
| 16 | Uvoz Excel da |
| 17 | Pun Excel ne treba; primjer §8.2 + mock seed |
| 18 | Foto mandatorna, unos naknadno |
| 19 | Ministarstvo §8.5; export **PDF i Excel** |
| 20–21 | Primjer reda + 8 fakulteta + free unos |

**Preostalo van SRS (ne blokira M1):** A-03 detaljni UC u `docs/`; F2 mockupi/ER.

---

## 12. M1 i Change Request

### 12.1 Zatvaranje F1 (M1)

- [ ] Tim review SRS v1.4  
- [ ] YouTrack: A-04/A-05 Done; A-06 milestone; F1 Done  
- [ ] **Nije potrebna** potvrda klijenta na dokument SRS  

### 12.2 Change Request

1. Issue tipa Change Request  
2. Šta / zašto / ko / FR  
3. Odluka voditelja  
4. Novi taskovi; stari → Obsolete  

### 12.3 Historija verzija

| Verzija | Datum | Opis |
| --- | --- | --- |
| 1.0–1.3 | 18.11.2026 | Inicijalni SRS; odgovori klijenta; primjer reda; ministarstvo; fakulteti |
| 1.4 | 18.11.2026 | Export **PDF i Excel** eksplicitno; bez punog Excela (mock seed); bez obavezne potvrde klijenta na SRS; polish F1 |

---

## Prilog A — Isporuka v1.0.0 (Must)

- [ ] FR-01…FR-21 + NFR-01…NFR-08  
- [ ] Export **PDF** i **`.xlsx`** (izvještaji, ministarstvo, custom, Pregled kao Excel)  
- [ ] Uvoz Excel + backup/restore  
- [ ] Windows instalacija (jpackage) + uputstvo  
- [ ] GitHub Release v1.0.0  

## Prilog B — YouTrack

A-01…A-06 · D-01…D-08 · E-/M-/N-/Z- · T- · R- · O-  
`docs/youtrack/TASKOVI-SKRACENO.md`
