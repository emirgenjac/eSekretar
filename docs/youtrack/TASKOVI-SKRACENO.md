# eSekretar — skraćena lista za YouTrack (~60 taskova)

Ručni unos. Najprije napravi **6 epika faza** (F1–F6), pa taskove kao **subtask** odgovarajuće faze.  
Za F3 module možeš praviti i epike modula (INF, STU…), ali nije obavezno — dovoljno je Type=Task + polje **Faza** + tag FR.

**Polja na svakom issue-u:** Type, State=Open, Assignee, Due Date, MoSCoW, Faza, tagovi FR-xx po potrebi.

### Zašto YouTrack kaže M-01, a plan STU-01?

To su **dva nivoa istog posla**, ne dva različita plana:

| Nivo | Primjer | Gdje |
| --- | --- | --- |
| Veliki task (YouTrack) | **M-01** Studenti i prijave | ovaj fajl — jedan issue |
| Sitni koraci (checklist) | **STU-01** … **STU-18** | plan, sekcija 6 |

Kad radiš **M-01**, otvori u planu epic **STU** i idi redom STU-01, STU-02… dok M-01 ne bude gotov.  
Isto mapiranje:

| YouTrack (skraćeno) | Plan (detaljno) |
| --- | --- |
| E-01 | INF (+ dio osnove) |
| E-02 | CI |
| E-03 | AUT |
| E-04 | PST + NOT (okvir) |
| E-05 | CQ |
| E-06 | IMP + IZV-13 |
| M-01 | STU |
| M-02 | STR + PRT |
| M-03 | LC |
| M-04 | PRE |
| M-05 | DSH + NOT pravila (Emin) |
| N-01 | AKG |
| N-02 | SOB |
| N-03 | SMJ |
| N-04 | UPL |
| N-05 | IZV (osim IZV-13) |
| N-06 | BKP + NOT pravila (Adnan) |
| Z-01…Z-04 | REZ / AUD / KRT |

---

## Epici faza (6)

| Summary | Type | Assignee | Due | Faza |
| --- | --- | --- | --- | --- |
| F1 Analiza i specifikacija zahtjeva | Epic | Emir | 2026-11-19 | F1 Analiza |
| F2 Dizajn sistema | Epic | Emir | 2026-11-26 | F2 Dizajn |
| F3 Implementacija | Epic | Emir | 2026-12-19 | F3 Implementacija |
| F4 Testiranje | Epic | Emir | 2026-12-23 | F4 Testiranje |
| F5 Isporuka | Epic | Emir | 2026-12-28 | F5 Isporuka |
| F6 Održavanje | Epic | Emir | 2026-12-31 | F6 Održavanje |

Linkovi: F2 depends on F1 → F3 on F2 → … → F6 on F5.

---

## F1 Analiza (Due 19.11.) — 6 taskova

| ID | Summary | Assignee | Tag / MoSCoW |
| --- | --- | --- | --- |
| A-01 | YouTrack setup (polja, board, Gantt, KB Pravila rada) + GitHub repo (README, .gitignore, tim) | Emir | NFR, Must |
| A-02 | Sastanak s klijentom: obim, Excel, otvorena pitanja; anonimizirani Excel + primjer izvještaja ministarstva | Emir (+Adnan prikuplja fajlove) | FR-21, Must |
| A-03 | Poslovni procesi, uloge ADMIN/SEKRETAR, use case dijagram i opisi | Emin | FR-02, Must |
| A-04 | Napisati listu funkcionalnih (FR-01 do FR-23) i nefunkcionalnih (NFR-01 do NFR-08) zahtjeva sa MoSCoW prioritetom | Emir (+Adnan NFR) | Must |
| A-05 | SRS v1.0 (spajanje svega) | Emir | Must |
| A-06 | Review SRS-a i potvrda klijenta (M1) | Emir | milestone, Must |

---

## F2 Dizajn (Due 26.11.) — 8 taskova

| ID | Summary | Assignee | Tag |
| --- | --- | --- | --- |
| D-01 | Arhitektura, paketi, Git pravila, plan CI/CD | Emir | NFR |
| D-02 | ER dijagram + relacijska šema + V1/V2 SQL (seed: fakulteti, kantoni, sobe, cijena 165 KM) + view v_student_pregled | Adnan | NFR |
| D-03 | UML klasa (model, DAO, servisi) + dijagram stanja prijave | Emin | NFR |
| D-04 | Mockup: login, glavni prozor, custom upit, uvoz Excel, korisnici, postavke | Emir | NFR |
| D-05 | Mockup: studenti (sve Excel kolone), lista čekanja, prenos, dashboard | Emin | FR-05 |
| D-06 | Mockup: sobe, zaduženje, uplate (matrica kao Excel), cijena, izvještaji, backup | Adnan | FR-12 |
| D-07 | Format izvještaja za ministarstvo + plan testiranja po FR | Adnan / Emin | FR-15 |
| D-08 | Review dizajna (M2) | Emir | milestone |

---

## F3 Implementacija — Emir (Due po sedmici)

| ID | Summary | Due | Tag |
| --- | --- | --- | --- |
| E-01 | Maven kostur, paketi, HikariCP, Flyway, Main/Launcher, AppContext, main.fxml, CSS, Validator/BaseDao, Logback | 03.12. | NFR |
| E-02 | CI/CD: ci.yml, testovi, zaštita main, jpackage zip, release.yml; tag v0.1.0 | 10.12. | NFR |
| E-03 | Prijava, uloge, Session, login, korisnici (ADMIN), BCrypt + testovi | 10.12. | FR-01…03 |
| E-04 | Postavke, tema (svijetla/tamna), notifikacije (okvir: zvonce, toast) | 17.12. | FR-18, FR-20 |
| E-05 | Custom upiti (view, QueryBuilder, UI, šabloni, export) | 17.12. | FR-16 |
| E-06 | Uvoz postojećeg Excel-a + izvještaj "Pregled kao Excel" | 17.12. | FR-21, FR-15 |

---

## F3 Implementacija — Emin

| ID | Summary | Due | Tag |
| --- | --- | --- | --- |
| M-01 | Studenti i prijave: modeli/DAO/servisi, lista, forme (sve Excel kolone), fotografija, uvjerenja, demo podaci + testovi | 10.12. | FR-05, FR-06 |
| M-02 | Strani studenti + globalna pretraga | 10.12. | FR-11, FR-14 |
| M-03 | Lista čekanja (rang, primi, odbij, historija statusa) | 17.12. | FR-10 |
| M-04 | Prenos iz prethodne godine (čarobnjak) | 17.12. | FR-13 |
| M-05 | Dashboard (kartice + 4 grafikona) + pravila notifikacija (lista čekanja, strani, foto/uvjerenja) | 17.12. | FR-17, FR-18 |

---

## F3 Implementacija — Adnan

| ID | Summary | Due | Tag |
| --- | --- | --- | --- |
| N-01 | Akademske godine + cijena smještaja (165 KM, važi od) + UI | 03.12. | FR-04 |
| N-02 | Sobe: CRUD, pregled po spratovima, detalji, filteri + testovi | 10.12. | FR-07, FR-08 |
| N-03 | Smještaj: zaduženje, premještanje, razduženje + dijalozi | 10.12. | FR-09 |
| N-04 | Uplate: DAO/servis, dug po cijeni, dijalog, matrica kao Excel, dugovanja | 17.12. | FR-12 |
| N-05 | Izvještaji PDF/Excel (predefinisani) + export dugmad | 17.12. | FR-15 |
| N-06 | Backup/restore + pravila notifikacija (neplaćeno, backup) | 17.12. | FR-19, FR-18 |

---

## F3 Zajedničko / rezerva

| ID | Summary | Assignee | Due | Tag |
| --- | --- | --- | --- | --- |
| Z-01 | Integracija modula, feature freeze, tag v0.9.0 (M3) | Emir | 19.12. | milestone |
| Z-02 | Rezerva / odobreni Change Request-ovi | Emir | 19.12. | Should |
| Z-03 | (Could) Audit log | Emir | 19.12. | FR-22, Could |
| Z-04 | (Could) PDF kartica studenta | Emin | 19.12. | FR-23, Could |

---

## F4 Testiranje (Due 23.12.) — 6 taskova

| ID | Summary | Assignee |
| --- | --- | --- |
| T-01 | Automatski testovi zeleni u CI + sigurnosni smoke (uloge, SQL injection) | Emir |
| T-02 | Ručni + unakrsni test: platforma, auth, custom upiti, uvoz Excel | Emir |
| T-03 | Ručni + unakrsni test: studenti, lista čekanja, prenos, dashboard | Emin |
| T-04 | Ručni + unakrsni test: sobe, smještaj, uplate, izvještaji, backup; instalacija zip; probni uvoz Excel-a | Adnan |
| T-05 | UAT s klijentom + ispravke bugova | Emir |
| T-06 | Test izvještaj + tag v1.0.0-rc1 (M4) | Emin / Emir |

---

## F5 Isporuka (Due 28.12.) — 5 taskova

| ID | Summary | Assignee |
| --- | --- | --- |
| R-01 | Release v1.0.0 (pom, CHANGELOG, GitHub Release zip+JAR) (M5) | Emir |
| R-02 | Uputstvo za instalaciju + uvoz Excel-a | Adnan |
| R-03 | Korisničko uputstvo + finalni use case / opis aplikacije | Emin |
| R-04 | Dokumentacija: metoda (Waterfall + YouTrack), CI/CD, ER/UML usklađeni s kodom | Emir + Adnan |
| R-05 | Finalni PDF dokument + prezentacija i demo | Emin + Adnan |

---

## F6 Održavanje (Due 31.12.) — 3 taskova

| ID | Summary | Assignee |
| --- | --- | --- |
| O-01 | Praćenje bugova / v1.0.1 po potrebi | Emir |
| O-02 | Generalna proba prezentacije | Adnan |
| O-03 | Zatvaranje projekta (YouTrack Done/Obsolete, export) | Emir |

---

## Brojke

| Dio | Broj |
| --- | --- |
| Epici faza | 6 |
| F1–F2 | 14 |
| F3 (Emir/Emin/Adnan + rezerva) | 6+5+6+4 = 21 |
| F4–F6 | 14 |
| **Ukupno issue-a (epici + taskovi)** | **~55** |

Svi Must FR i dalje pokriveni; samo su sitni koraci spojeni u veće taskove.

---

## Redoslijed unosa u YouTrack

1. Napravi 6 epika F1–F6 (+ depends on lanac).
2. Unesi F1 (A-01…A-06), stavi Faza = F1 Analiza, subtask of F1.
3. Isto za F2.
4. Unesi F3 taskove (E/M/N/Z), Faza = F3 Implementacija, subtask of F3.
5. F4, F5, F6.
6. Na boardu prebaci sprint (F1 → F2 → …) da vidiš kartice.
