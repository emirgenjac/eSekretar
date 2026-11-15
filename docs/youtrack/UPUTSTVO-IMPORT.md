# Uvoz eSekretar taskova u YouTrack (korak po korak)

CSV je u formatu **YouTrack Google Sheets advanced import**. YouTrack ne uvozi CSV direktno: CSV → Google Sheets → YouTrack.

Fajl: [`esekretar-youtrack-import.csv`](esekretar-youtrack-import.csv)  
Generisanje ponovo: `node generate-import.mjs`

---

## 0. Prije uvoza (jednom)

### 0.1 Loginovi članova tima

U CSV-u su placeholder loginovi:

| Ime | Placeholder u CSV |
| --- | --- |
| Emir Genjac | `emir.genjac` |
| Emin Ahbabović | `emin.ahbabovic` |
| Adnan Jašarević | `adnan.jasarevic` |

1. U YouTrack-u otvori profil svakog člana i prepiši tačan **login**.
2. Otvori `generate-import.mjs`, izmijeni objekat `U` na vrhu, pa pokreni `node generate-import.mjs`.
3. Ili u Excelu / Sheets-u zamijeni sva tri logina Find & Replace.

Ako login ne postoji, YouTrack **kreira novog korisnika** (i može ga zabraniti ako nema licence). Bolje da logini već postoje.

### 0.2 Projekat ESK (opcionalno unaprijed)

Možeš unaprijed napraviti projekat `eSekretar` (ključ `ESK`) ili pustiti YouTrack da kreira projekat iz sheet imena.

Preporučena polja (uvoz ih može i sam kreirati iz kolona CSV-a):

- **Type** (enum): Epic, Task, Bug, Change Request
- **State** (state): Open, In Progress, Code Review, Done, Obsolete
- **MoSCoW** (enum): Must, Should, Could
- **Due Date** (date)
- **Faza** (enum): F1 Analiza, F2 Dizajn, F3 Implementacija, F4 Testiranje, F5 Isporuka, F6 Održavanje
- **Zahtjev** (enum multi): FR-01 … FR-23, NFR

Issue tipovi linkova (već postoje u YouTrack-u): `subtask of` / `parent for`, `depends on` / `is required for`.

---

## 1. Ubaci CSV u Google Sheets

1. Otvori [Google Sheets](https://sheets.google.com) → **Blank spreadsheet**.
2. **File → Import → Upload** → izaberi `esekretar-youtrack-import.csv`.
3. Import location: **Replace current sheet** (ili Create new sheet).
4. Separator: **Comma**.
5. Klik **Import data**.
6. Preimenuj sheet u npr. `eSekretar` (ovo ime YouTrack može koristiti za projekat).
7. Provjeri prvi red kolona:
   `$type$ | ID | Summary | Description | Type (enum) | Assignee (user) | State (state) | MoSCoW (enum) | Due Date | Faza (enum) | Zahtjev (enum multi)`
8. **Share → Anyone with the link → Viewer** (obavezno, inače YouTrack ne može čitati sheet).

---

## 2. Napravi Google API key

1. Otvori [Google Cloud Console](https://console.cloud.google.com/).
2. Napravi (ili izaberi) projekat.
3. **APIs & Services → Enable APIs**:
   - Google Sheets API
   - Google Drive API
4. **Credentials → Create credentials → API key**.
5. Kopiraj ključ (možeš ga ograničiti na Sheets + Drive API).

Detalji: [Import from Google Sheets](https://www.jetbrains.com/help/youtrack/cloud/import-from-google-sheets.html)

---

## 3. Pokreni uvoz u YouTrack

1. YouTrack → **Administration → Integrations → Imports**.
2. **New import → Google Sheets**.
3. **Spreadsheet URL**: javni link na sheet.
4. **API key**: ključ iz koraka 2.
5. **Next** → mapiraj sheet na postojeći projekat `ESK` **ili** Create new project.
6. **Start import**.
7. Sačekaj kraj; ako padne, **Download import log** i ispravi greške.

Šta se dešava:

- Svaki red `$type$=issue` → novi issue (ID iz CSV-a je **privremeni** import ID, YouTrack daje `ESK-1`, `ESK-2`…).
- Red `$type$=link` odmah ispod issue-a → veza: `Summary` je tip linka (`subtask of` ili `depends on`), a `ID` je import ID ciljnog issue-a.
- Hijerarhija: F1…F6 epici → moduli (INF, STU, …) subtask od F3 → taskovi subtask od modula/faze.
- Lanac: F2 depends on F1, F3 on F2, … F6 on F5.

---

## 4. Poslije uvoza (10–15 min)

### 4.1 Tagovi `FR-xx` i `milestone`

Kolona `Zahtjev` je custom polje (enum multi), ne YouTrack tag. Za tagove iz plana:

1. Issues → filter npr. `Zahtjev: FR-05`.
2. Označi sve → **Apply command** → `tag FR-05`.
3. Milestone taskovi (A-13, D-20, REZ-02, T-15, R-02): `tag milestone`.

### 4.2 Board "eSekretar Waterfall"

1. Agile boards → New board → Scrum → projekat ESK.
2. Kolone: Open, In Progress, Code Review, Done.
3. Swimlanes po Assignee.
4. U **Board behavior** uključi **Link sprints to values for custom field** → polje **Faza**.  
   YouTrack napravi sprint po svakoj vrijednosti Faze (F1…F6).
5. Po želji ručno postavi datume sprintova iz plana (F1: 16.–19.11. … F6: 29.–31.12.).

### 4.3 Gantt

1. Gantt Charts → New chart → projekat ESK, start `2026-11-16`.
2. U Advanced Settings **ne** biraj Estimation.
3. Razvuci trake epika F1–F6 po datumima; `depends on` veze već postoje iz CSV-a.

### 4.4 Knowledge Base

Napravi članak **Pravila rada** (Definition of Done, Git pravila, šablon Change Request) — to je task A-01.

### 4.5 VCS

Project settings → VCS Integrations → `emirgenjac/eSekretar`. Commit poruke: `ESK-57 ...`.

---

## 5. Provjera da je uvoz OK

- Broj issue-a ≈ broj iz `import-stats.json` (polje `issues`).
- Epici F1–F6 postoje i međusobno zavise.
- Npr. `INF-01` je subtask od `INF`, a `INF` subtask od `F3`.
- Assignee se poklapa sa timom.
- Due Date i Faza su popunjeni.

Ako treba ponoviti uvoz: obriši import konfiguraciju (i po potrebi projekat) ili uvozi u **novi** projekat da ne dupliraš.

---

## 6. Šta CSV sadrži

| Entitet | Primjer ID |
| --- | --- |
| Epici faza | F1 … F6 |
| Epici modula | INF, CI, AUT, AKG, STU, STR, SOB, SMJ, LC, UPL, PRE, PRT, IZV, CQ, DSH, NOT, BKP, PST, IMP, AUD, KRT, REZ |
| Analiza / dizajn | A-01…A-13, D-01…D-20 |
| Implementacija | INF-01…, STU-01…, IMP-01… |
| Test / isporuka / održavanje | T-01…T-15, R-01…R-12, O-01…O-04 |

MoSCoW: skoro sve **Must**; AUD i KRT su **Could**.
