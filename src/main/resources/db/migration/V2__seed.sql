-- =====================================================================
-- eSekretar - V2 početni podaci (seed)
-- ESK-14 / D-02
-- Demo studenti/prijave NISU ovdje: mock seed ide uz F3 (SRS §2.5).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Početni nalog: e-mail admin@sczenica.ba, lozinka admin
-- (BCrypt, $2a$, cost 12). Pri prvoj prijavi aplikacija traži promjenu
-- lozinke; e-mail se mijenja na ekranu Korisnici.
-- ---------------------------------------------------------------------
INSERT INTO korisnik (email, prikazno_ime, lozinka_hash, mora_promijeniti_lozinku)
VALUES ('admin@sczenica.ba', 'Administrator',
        '$2a$12$9tYcNqaqVVLSd9YpbJMVV.Tzdkgi3JsiXSqLtneK4FvG5xNu5ep.y', TRUE);

-- ---------------------------------------------------------------------
-- Kantoni FBiH + RS i Brčko distrikt (šifarnik, SRS §8.3).
-- Strani studenti nemaju kanton (NULL).
-- ---------------------------------------------------------------------
INSERT INTO kanton (sifra, naziv, redoslijed) VALUES
    ('USK', 'Unsko-sanski kanton',                1),
    ('PK',  'Posavski kanton',                    2),
    ('TK',  'Tuzlanski kanton',                   3),
    ('ZDK', 'Zeničko-dobojski kanton',            4),
    ('BPK', 'Bosansko-podrinjski kanton Goražde', 5),
    ('SBK', 'Srednjobosanski kanton',             6),
    ('HNK', 'Hercegovačko-neretvanski kanton',    7),
    ('ZHK', 'Zapadnohercegovački kanton',         8),
    ('KS',  'Kanton Sarajevo',                    9),
    ('K10', 'Kanton 10',                         10),
    ('RS',  'Republika Srpska',                  11),
    ('BD',  'Brčko distrikt BiH',                12);

-- ---------------------------------------------------------------------
-- Fakulteti - prijedlozi za ComboBox (SRS §8.4)
-- ---------------------------------------------------------------------
INSERT INTO fakultet (naziv, redoslijed) VALUES
    ('Fakultet inženjerstva i prirodnih nauka', 1),
    ('Mašinski fakultet',                       2),
    ('Filozofski fakultet',                     3),
    ('Ekonomski fakultet',                      4),
    ('Pravni fakultet',                         5),
    ('Medicinski fakultet',                     6),
    ('Politehnički fakultet',                   7),
    ('Islamski pedagoški fakultet',             8);

-- ---------------------------------------------------------------------
-- Aktivna akademska godina i cijena 165 KM (FR-04, SRS §2.5)
-- ---------------------------------------------------------------------
INSERT INTO akademska_godina (naziv, datum_od, datum_do, aktivna)
VALUES ('2026/2027', '2026-10-01', '2027-07-15', TRUE);

INSERT INTO cijena_smjestaja (akademska_godina_id, iznos, napomena, korisnik_id)
SELECT ag.id, 165.00, 'Početna cijena (SRS)', k.id
FROM akademska_godina ag
CROSS JOIN korisnik k
WHERE ag.naziv = '2026/2027' AND k.email = 'admin@sczenica.ba';

-- ---------------------------------------------------------------------
-- Sobe - mock raspored: 4 nivoa (prizemlje + 3 sprata), brojevi i
-- kapaciteti kao na mockupu D-06 (pregled soba). Stvarne sobe se
-- unose ili ispravljaju na ekranu Sobe (N-02).
-- Sprat 0 = prizemlje.
-- ---------------------------------------------------------------------
INSERT INTO soba (broj, sprat, kapacitet, tip, status) VALUES
    -- prizemlje, muške
    ('1', 0, 3, 'MUSKA', 'AKTIVNA'),  ('2', 0, 3, 'MUSKA', 'AKTIVNA'),  ('3', 0, 2, 'MUSKA', 'AKTIVNA'),  ('4', 0, 3, 'MUSKA', 'AKTIVNA'),
    ('5', 0, 3, 'MUSKA', 'AKTIVNA'),  ('6', 0, 2, 'MUSKA', 'AKTIVNA'),  ('7', 0, 3, 'MUSKA', 'AKTIVNA'),  ('8', 0, 3, 'MUSKA', 'AKTIVNA'),
    -- 1. sprat, muške
    ('10', 1, 3, 'MUSKA', 'AKTIVNA'), ('11', 1, 3, 'MUSKA', 'AKTIVNA'), ('12', 1, 2, 'MUSKA', 'AKTIVNA'), ('13', 1, 3, 'MUSKA', 'AKTIVNA'),
    ('14', 1, 3, 'MUSKA', 'AKTIVNA'), ('15', 1, 2, 'MUSKA', 'AKTIVNA'), ('16', 1, 3, 'MUSKA', 'AKTIVNA'), ('17', 1, 3, 'MUSKA', 'AKTIVNA'),
    ('18', 1, 2, 'MUSKA', 'AKTIVNA'), ('19', 1, 3, 'MUSKA', 'AKTIVNA'),
    -- 2. sprat, ženske
    ('20', 2, 3, 'ZENSKA', 'AKTIVNA'), ('21', 2, 2, 'ZENSKA', 'AKTIVNA'), ('22', 2, 3, 'ZENSKA', 'AKTIVNA'), ('23', 2, 3, 'ZENSKA', 'AKTIVNA'),
    ('24', 2, 2, 'ZENSKA', 'AKTIVNA'), ('25', 2, 3, 'ZENSKA', 'AKTIVNA'), ('26', 2, 3, 'ZENSKA', 'AKTIVNA'), ('27', 2, 3, 'ZENSKA', 'NEAKTIVNA'),
    ('28', 2, 3, 'ZENSKA', 'AKTIVNA'), ('29', 2, 3, 'ZENSKA', 'AKTIVNA'),
    -- 3. sprat, ženske
    ('30', 3, 3, 'ZENSKA', 'AKTIVNA'), ('31', 3, 3, 'ZENSKA', 'AKTIVNA'), ('32', 3, 2, 'ZENSKA', 'AKTIVNA'), ('33', 3, 3, 'ZENSKA', 'AKTIVNA'),
    ('34', 3, 3, 'ZENSKA', 'AKTIVNA'), ('35', 3, 2, 'ZENSKA', 'AKTIVNA'), ('36', 3, 3, 'ZENSKA', 'AKTIVNA'), ('37', 3, 3, 'ZENSKA', 'AKTIVNA'),
    ('38', 3, 2, 'ZENSKA', 'AKTIVNA'), ('39', 3, 3, 'ZENSKA', 'AKTIVNA');

-- ---------------------------------------------------------------------
-- Postavke (FR-20, FR-24). Putanje i SMTP postavlja korisnik u
-- aplikaciji. SMTP lozinka NIJE u bazi: ide u config.properties (van Gita).
-- ---------------------------------------------------------------------
INSERT INTO postavka (kljuc, vrijednost, opis) VALUES
    ('ustanova.naziv',             'JU Studentski centar Zenica', 'Naziv u zaglavlju izvještaja'),
    ('ustanova.adresa',            'Crkvice 50, Zenica',          'Adresa u zaglavlju izvještaja'),
    ('backup.mysqldump_putanja',   NULL,                          'Putanja do mysqldump.exe'),
    ('backup.folder',              NULL,                          'Folder za backup fajlove'),
    ('backup.interval_dana',       '7',                           'Automatski backup svakih N dana'),
    ('notifikacija.backup_dana',   '7',                           'Upozorenje ako je posljednji backup stariji od N dana'),
    ('reset.email_primalac',       NULL,                          'FR-24: e-mail sekretarice na koji ide privremena lozinka'),
    ('reset.privremena_sati',      '24',                          'FR-24: koliko sati važi privremena lozinka'),
    ('smtp.host',                  NULL,                          'SMTP server za slanje e-maila'),
    ('smtp.port',                  '587',                         'SMTP port'),
    ('smtp.korisnik',              NULL,                          'SMTP korisničko ime (lozinka u config.properties)'),
    ('smtp.posiljalac',            NULL,                          'Adresa pošiljaoca (From)'),
    ('smtp.starttls',              'true',                        'STARTTLS uključen');
