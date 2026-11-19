-- =====================================================================
-- eSekretar - V1 inicijalna šema baze (MySQL 8)
-- ESK-14 / D-02
--
-- Konvencije:
--   * imena tabela i kolona: snake_case, jednina, bosanski bez dijakritika
--   * PK: id BIGINT AUTO_INCREMENT
--   * novac: DECIMAL(8,2) (KM)
--   * svi tekstovi: utf8mb4, hrvatska/bosanska kolacija (č, ć, dž, đ, š, ž)
--   * pravila koja zahtijevaju više redova (kapacitet sobe, prelazi
--     statusa) provjerava servisni sloj u transakciji
-- =====================================================================

-- ---------------------------------------------------------------------
-- Korisnici aplikacije (FR-01..FR-03, FR-24). Prijava e-mailom i
-- lozinkom (SRS v1.8). Bez uloga: svi nalozi imaju puni pristup
-- (SRS §2.2, §3).
-- ---------------------------------------------------------------------
CREATE TABLE korisnik (
    id                        BIGINT       NOT NULL AUTO_INCREMENT,
    email                     VARCHAR(150) NOT NULL COMMENT 'identifikator za prijavu',
    prikazno_ime              VARCHAR(150) NOT NULL,
    lozinka_hash              CHAR(60)     NOT NULL COMMENT 'BCrypt',
    aktivan                   BOOLEAN      NOT NULL DEFAULT TRUE,
    mora_promijeniti_lozinku  BOOLEAN      NOT NULL DEFAULT FALSE COMMENT 'nakon reseta ili privremene lozinke',
    privremena_lozinka_do     DATETIME     NULL COMMENT 'FR-24: rok važenja privremene lozinke',
    neuspjesne_prijave        INT          NOT NULL DEFAULT 0,
    zakljucan_do              DATETIME     NULL,
    tema                      ENUM('SVIJETLA','TAMNA') NOT NULL DEFAULT 'SVIJETLA',
    posljednja_prijava        DATETIME     NULL,
    kreirano                  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    izmijenjeno               DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_korisnik_email (email),
    CONSTRAINT ck_korisnik_email CHECK (email LIKE '%_@_%._%'),
    CONSTRAINT ck_korisnik_neuspjesne CHECK (neuspjesne_prijave >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Akademska godina (FR-04). Tačno jedna može biti aktivna:
-- aktivna_kljuc je 1 za aktivnu i NULL za ostale, a UNIQUE dozvoljava
-- više NULL vrijednosti.
-- ---------------------------------------------------------------------
CREATE TABLE akademska_godina (
    id              BIGINT      NOT NULL AUTO_INCREMENT,
    naziv           VARCHAR(9)  NOT NULL COMMENT 'npr. 2026/2027',
    datum_od        DATE        NOT NULL COMMENT 'tipično 1.10.',
    datum_do        DATE        NOT NULL COMMENT 'tipično 15.7. naredne godine',
    aktivna         BOOLEAN     NOT NULL DEFAULT FALSE,
    aktivna_kljuc   TINYINT     GENERATED ALWAYS AS (IF(aktivna, 1, NULL)) VIRTUAL,
    kreirano        DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_akademska_godina_naziv (naziv),
    UNIQUE KEY uk_akademska_godina_aktivna (aktivna_kljuc),
    CONSTRAINT ck_akademska_godina_period CHECK (datum_do > datum_od)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Cijena smještaja po akademskoj godini (FR-04, SRS §8.3 pravilo 1).
-- Jedna cijena po AG, vrijedi od početka te AG. Historija = cijene
-- prethodnih godina (npr. 150 -> 165).
-- ---------------------------------------------------------------------
CREATE TABLE cijena_smjestaja (
    id                    BIGINT        NOT NULL AUTO_INCREMENT,
    akademska_godina_id   BIGINT        NOT NULL,
    iznos                 DECIMAL(8,2)  NOT NULL COMMENT 'mjesečni iznos u KM',
    datum_odluke          DATE          NULL COMMENT 'odluka UO',
    napomena              VARCHAR(255)  NULL,
    korisnik_id           BIGINT        NULL COMMENT 'ko je unio/izmijenio',
    kreirano              DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    izmijenjeno           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_cijena_smjestaja_ag (akademska_godina_id),
    CONSTRAINT fk_cijena_smjestaja_ag FOREIGN KEY (akademska_godina_id)
        REFERENCES akademska_godina (id),
    CONSTRAINT fk_cijena_smjestaja_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnik (id) ON DELETE SET NULL,
    CONSTRAINT ck_cijena_smjestaja_iznos CHECK (iznos > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Šifarnici
-- ---------------------------------------------------------------------
CREATE TABLE kanton (
    id        BIGINT       NOT NULL AUTO_INCREMENT,
    sifra     VARCHAR(10)  NOT NULL COMMENT 'npr. ZDK',
    naziv     VARCHAR(100) NOT NULL,
    redoslijed INT         NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_kanton_sifra (sifra),
    UNIQUE KEY uk_kanton_naziv (naziv)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- Fakultet je samo lista prijedloga za editable ComboBox (FR-06).
-- Prijava čuva naziv fakulteta kao tekst, pa je slobodan unos moguć.
CREATE TABLE fakultet (
    id         BIGINT       NOT NULL AUTO_INCREMENT,
    naziv      VARCHAR(150) NOT NULL,
    aktivan    BOOLEAN      NOT NULL DEFAULT TRUE,
    redoslijed INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    UNIQUE KEY uk_fakultet_naziv (naziv)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Student (FR-05, FR-11). Domaći student ima JMBG, strani pasoš.
-- ---------------------------------------------------------------------
CREATE TABLE student (
    id                BIGINT        NOT NULL AUTO_INCREMENT,
    ime               VARCHAR(100)  NOT NULL,
    prezime           VARCHAR(100)  NOT NULL,
    ime_roditelja     VARCHAR(100)  NULL,
    jmbg              CHAR(13)      NULL,
    broj_licne        VARCHAR(20)   NULL,
    spol              ENUM('M','Z') NOT NULL,
    adresa            VARCHAR(255)  NULL,
    opcina            VARCHAR(100)  NULL COMMENT 'slobodan tekst (SRS §8.3)',
    kanton_id         BIGINT        NULL,
    telefon           VARCHAR(30)   NULL,
    email             VARCHAR(150)  NULL,
    strani            BOOLEAN       NOT NULL DEFAULT FALSE,
    drzava            VARCHAR(100)  NULL COMMENT 'strani student',
    broj_pasosa       VARCHAR(30)   NULL COMMENT 'strani student',
    program_razmjene  VARCHAR(150)  NULL COMMENT 'strani student',
    boravak_od        DATE          NULL COMMENT 'strani student',
    boravak_do        DATE          NULL COMMENT 'strani student',
    napomena          VARCHAR(1000) NULL,
    kreirano          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    izmijenjeno       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_student_jmbg (jmbg),
    UNIQUE KEY uk_student_broj_pasosa (broj_pasosa),
    KEY ix_student_prezime_ime (prezime, ime),
    KEY ix_student_broj_licne (broj_licne),
    KEY ix_student_kanton (kanton_id),
    CONSTRAINT fk_student_kanton FOREIGN KEY (kanton_id)
        REFERENCES kanton (id),
    CONSTRAINT ck_student_jmbg_format CHECK (jmbg IS NULL OR jmbg REGEXP '^[0-9]{13}$'),
    CONSTRAINT ck_student_identifikacija CHECK (jmbg IS NOT NULL OR broj_pasosa IS NOT NULL),
    CONSTRAINT ck_student_boravak CHECK (boravak_do IS NULL OR boravak_od IS NULL OR boravak_do >= boravak_od)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- Više brojeva telefona roditelja po studentu (FR-05).
CREATE TABLE student_telefon_roditelja (
    id          BIGINT       NOT NULL AUTO_INCREMENT,
    student_id  BIGINT       NOT NULL,
    broj        VARCHAR(30)  NOT NULL,
    opis        VARCHAR(50)  NULL COMMENT 'npr. otac, majka',
    redoslijed  INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY ix_student_telefon_roditelja_student (student_id),
    CONSTRAINT fk_student_telefon_roditelja_student FOREIGN KEY (student_id)
        REFERENCES student (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- Fotografija u bazi (NFR-08), odvojeno od studenta da liste ne
-- učitavaju BLOB. Unos naknadno je dozvoljen (red ne mora postojati).
CREATE TABLE student_fotografija (
    student_id   BIGINT       NOT NULL,
    slika        MEDIUMBLOB   NOT NULL COMMENT 'do 16 MB; aplikacija skalira prije snimanja',
    mime_tip     VARCHAR(50)  NOT NULL DEFAULT 'image/jpeg',
    izmijenjeno  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id),
    CONSTRAINT fk_student_fotografija_student FOREIGN KEY (student_id)
        REFERENCES student (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Prijava studenta za akademsku godinu (FR-06, FR-10, FR-13).
-- Lista čekanja nije posebna tabela: to su prijave sa statusom
-- LISTA_CEKANJA, rang = bodovi DESC, datum_prijave ASC.
-- ---------------------------------------------------------------------
CREATE TABLE prijava (
    id                      BIGINT        NOT NULL AUTO_INCREMENT,
    student_id              BIGINT        NOT NULL,
    akademska_godina_id     BIGINT        NOT NULL,
    status                  ENUM('PRIJAVLJEN','LISTA_CEKANJA','PRIMLJEN','ODBIJEN','ISELJEN')
                                          NOT NULL DEFAULT 'PRIJAVLJEN',
    fakultet                VARCHAR(150)  NULL COMMENT 'tekst: prijedlog iz tabele fakultet ili slobodan unos',
    godina_studija_ciklus   VARCHAR(20)   NULL COMMENT 'npr. III',
    trajanje_studija        TINYINT       NULL COMMENT 'u godinama (ministarstvo)',
    godina_upisa            SMALLINT      NULL COMMENT 'npr. 2024 (ministarstvo)',
    datum_prijave           DATE          NULL COMMENT 'predaja na konkurs',
    broj_ugovora            VARCHAR(50)   NULL COMMENT 'npr. 09-130-820-385/26',
    broj_kartice            VARCHAR(20)   NULL COMMENT 'prenosi se u novu AG',
    ljekarsko_uvjerenje     BOOLEAN       NOT NULL DEFAULT FALSE COMMENT 'DA kad dostavljeno',
    fakultetsko_uvjerenje   BOOLEAN       NOT NULL DEFAULT FALSE COMMENT 'DA kad dostavljeno',
    bodovi                  DECIMAL(6,2)  NULL COMMENT 'za rang liste čekanja',
    primljen_naknadno       BOOLEAN       NOT NULL DEFAULT FALSE COMMENT 'primljen sa liste čekanja',
    razlog_odbijanja        VARCHAR(500)  NULL,
    prethodna_prijava_id    BIGINT        NULL COMMENT 'izvor prenosa iz prethodne AG',
    napomena                VARCHAR(1000) NULL,
    kreirano                DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    izmijenjeno             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_prijava_student_ag (student_id, akademska_godina_id),
    UNIQUE KEY uk_prijava_ag_broj_ugovora (akademska_godina_id, broj_ugovora),
    KEY ix_prijava_ag_status (akademska_godina_id, status),
    KEY ix_prijava_fakultet (fakultet),
    KEY ix_prijava_prethodna (prethodna_prijava_id),
    CONSTRAINT fk_prijava_student FOREIGN KEY (student_id)
        REFERENCES student (id) ON DELETE CASCADE,
    CONSTRAINT fk_prijava_ag FOREIGN KEY (akademska_godina_id)
        REFERENCES akademska_godina (id),
    CONSTRAINT fk_prijava_prethodna FOREIGN KEY (prethodna_prijava_id)
        REFERENCES prijava (id) ON DELETE SET NULL,
    CONSTRAINT ck_prijava_trajanje CHECK (trajanje_studija IS NULL OR trajanje_studija BETWEEN 1 AND 8),
    CONSTRAINT ck_prijava_godina_upisa CHECK (godina_upisa IS NULL OR godina_upisa BETWEEN 1990 AND 2100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- Historija statusa prijave (FR-10).
CREATE TABLE prijava_status_historija (
    id            BIGINT        NOT NULL AUTO_INCREMENT,
    prijava_id    BIGINT        NOT NULL,
    stari_status  ENUM('PRIJAVLJEN','LISTA_CEKANJA','PRIMLJEN','ODBIJEN','ISELJEN') NULL,
    novi_status   ENUM('PRIJAVLJEN','LISTA_CEKANJA','PRIMLJEN','ODBIJEN','ISELJEN') NOT NULL,
    napomena      VARCHAR(500)  NULL,
    korisnik_id   BIGINT        NULL,
    kreirano      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY ix_prijava_status_historija_prijava (prijava_id, kreirano),
    CONSTRAINT fk_prijava_status_historija_prijava FOREIGN KEY (prijava_id)
        REFERENCES prijava (id) ON DELETE CASCADE,
    CONSTRAINT fk_prijava_status_historija_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnik (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Sobe (FR-07, FR-08)
-- ---------------------------------------------------------------------
CREATE TABLE soba (
    id         BIGINT       NOT NULL AUTO_INCREMENT,
    broj       VARCHAR(10)  NOT NULL COMMENT 'npr. 19',
    sprat      TINYINT      NOT NULL,
    kapacitet  TINYINT      NOT NULL,
    tip        ENUM('MUSKA','ZENSKA') NOT NULL,
    status     ENUM('AKTIVNA','NEAKTIVNA','RENOVIRANJE') NOT NULL DEFAULT 'AKTIVNA',
    napomena   VARCHAR(500) NULL,
    kreirano   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    izmijenjeno DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_soba_broj (broj),
    KEY ix_soba_sprat (sprat),
    CONSTRAINT ck_soba_kapacitet CHECK (kapacitet BETWEEN 1 AND 10),
    CONSTRAINT ck_soba_sprat CHECK (sprat BETWEEN -1 AND 20)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Smještaj = zaduženje sobe za prijavu (FR-09). Premještaj zatvara
-- stari red (datum_razduzenja, razlog PREMJESTAJ) i otvara novi u
-- istoj transakciji. Aktivan = datum_razduzenja IS NULL; najviše jedan
-- aktivan red po prijavi (uk_smjestaj_aktivan). Kapacitet sobe
-- provjerava servis (SELECT ... FOR UPDATE na sobi).
-- ---------------------------------------------------------------------
CREATE TABLE smjestaj (
    id                  BIGINT       NOT NULL AUTO_INCREMENT,
    prijava_id          BIGINT       NOT NULL,
    soba_id             BIGINT       NOT NULL,
    datum_zaduzenja     DATE         NOT NULL,
    datum_razduzenja    DATE         NULL,
    razlog_razduzenja   ENUM('PREMJESTAJ','ISELJENJE','KRAJ_GODINE','OSTALO') NULL,
    napomena            VARCHAR(500) NULL,
    korisnik_id         BIGINT       NULL,
    aktivna_prijava_id  BIGINT       GENERATED ALWAYS AS (IF(datum_razduzenja IS NULL, prijava_id, NULL)) VIRTUAL,
    kreirano            DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    izmijenjeno         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_smjestaj_aktivan (aktivna_prijava_id),
    KEY ix_smjestaj_prijava (prijava_id),
    KEY ix_smjestaj_soba_aktivan (soba_id, datum_razduzenja),
    CONSTRAINT fk_smjestaj_prijava FOREIGN KEY (prijava_id)
        REFERENCES prijava (id),
    CONSTRAINT fk_smjestaj_soba FOREIGN KEY (soba_id)
        REFERENCES soba (id),
    CONSTRAINT fk_smjestaj_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnik (id) ON DELETE SET NULL,
    CONSTRAINT ck_smjestaj_datumi CHECK (datum_razduzenja IS NULL OR datum_razduzenja >= datum_zaduzenja),
    CONSTRAINT ck_smjestaj_razlog CHECK ((datum_razduzenja IS NULL) = (razlog_razduzenja IS NULL))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Uplata (FR-12). Bez rata: jedan iznos po mjesecu po prijavi.
-- Mjesec 10..12 pripada prvoj, 1..7 drugoj kalendarskoj godini AG.
-- Avgust i septembar nisu obračunski mjeseci.
-- ---------------------------------------------------------------------
CREATE TABLE uplata (
    id            BIGINT        NOT NULL AUTO_INCREMENT,
    prijava_id    BIGINT        NOT NULL,
    mjesec        TINYINT       NOT NULL COMMENT '10,11,12,1..7',
    iznos         DECIMAL(8,2)  NOT NULL,
    datum_uplate  DATE          NOT NULL,
    napomena      VARCHAR(500)  NULL,
    korisnik_id   BIGINT        NULL,
    kreirano      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    izmijenjeno   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_uplata_prijava_mjesec (prijava_id, mjesec),
    KEY ix_uplata_datum (datum_uplate),
    CONSTRAINT fk_uplata_prijava FOREIGN KEY (prijava_id)
        REFERENCES prijava (id),
    CONSTRAINT fk_uplata_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnik (id) ON DELETE SET NULL,
    CONSTRAINT ck_uplata_mjesec CHECK (mjesec BETWEEN 1 AND 12 AND mjesec NOT IN (8, 9)),
    CONSTRAINT ck_uplata_iznos CHECK (iznos > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Postavke (FR-20), ključ-vrijednost. Tema je po korisniku (korisnik.tema).
-- ---------------------------------------------------------------------
CREATE TABLE postavka (
    kljuc        VARCHAR(100)  NOT NULL,
    vrijednost   VARCHAR(1000) NULL,
    opis         VARCHAR(255)  NULL,
    izmijenjeno  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (kljuc)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Notifikacije (FR-18)
-- ---------------------------------------------------------------------
CREATE TABLE notifikacija (
    id              BIGINT        NOT NULL AUTO_INCREMENT,
    tip             VARCHAR(50)   NOT NULL COMMENT 'npr. NEPLACEN_MJESEC, BACKUP_ZASTARIO',
    naslov          VARCHAR(200)  NOT NULL,
    poruka          VARCHAR(1000) NULL,
    referenca_tip   VARCHAR(50)   NULL COMMENT 'npr. PRIJAVA, SOBA',
    referenca_id    BIGINT        NULL,
    procitana       BOOLEAN       NOT NULL DEFAULT FALSE,
    kreirano        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY ix_notifikacija_procitana (procitana, kreirano),
    KEY ix_notifikacija_tip_referenca (tip, referenca_tip, referenca_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Šabloni custom upita (FR-16). Definicija je JSON nad whitelistom
-- kolona pogleda v_student_pregled (docs/dizajn/ER-model.md §6).
-- ---------------------------------------------------------------------
CREATE TABLE upit_sablon (
    id           BIGINT        NOT NULL AUTO_INCREMENT,
    naziv        VARCHAR(150)  NOT NULL,
    opis         VARCHAR(500)  NULL,
    definicija   JSON          NOT NULL,
    korisnik_id  BIGINT        NULL,
    kreirano     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    izmijenjeno  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_upit_sablon_naziv (naziv),
    CONSTRAINT fk_upit_sablon_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnik (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;

-- ---------------------------------------------------------------------
-- Evidencija backup-a (FR-19; notifikacija "backup stariji od N dana")
-- ---------------------------------------------------------------------
CREATE TABLE backup_zapis (
    id              BIGINT        NOT NULL AUTO_INCREMENT,
    tip             ENUM('RUCNI','AUTOMATSKI','RESTORE') NOT NULL,
    putanja         VARCHAR(500)  NOT NULL,
    velicina_bajta  BIGINT        NULL,
    uspjesno        BOOLEAN       NOT NULL,
    poruka          VARCHAR(1000) NULL,
    korisnik_id     BIGINT        NULL,
    kreirano        DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY ix_backup_zapis_kreirano (uspjesno, kreirano),
    CONSTRAINT fk_backup_zapis_korisnik FOREIGN KEY (korisnik_id)
        REFERENCES korisnik (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hr_0900_ai_ci;
