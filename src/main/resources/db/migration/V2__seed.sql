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
-- Sobe - PRIVREMENI raspored dok ne stigne stvarni spisak soba doma
-- (broj, sprat, kapacitet, tip). Zamijeniti prije merge-a ESK-14.
-- ---------------------------------------------------------------------
INSERT INTO soba (broj, sprat, kapacitet, tip) VALUES
    ('1', 1, 3, 'MUSKA'),  ('2', 1, 3, 'MUSKA'),  ('3', 1, 3, 'MUSKA'),  ('4', 1, 3, 'MUSKA'),  ('5', 1, 3, 'MUSKA'),
    ('6', 1, 3, 'MUSKA'),  ('7', 1, 3, 'MUSKA'),  ('8', 1, 3, 'MUSKA'),  ('9', 1, 3, 'MUSKA'),  ('10', 1, 3, 'MUSKA'),
    ('11', 2, 3, 'MUSKA'), ('12', 2, 3, 'MUSKA'), ('13', 2, 3, 'MUSKA'), ('14', 2, 3, 'MUSKA'), ('15', 2, 3, 'MUSKA'),
    ('16', 2, 3, 'MUSKA'), ('17', 2, 3, 'MUSKA'), ('18', 2, 3, 'MUSKA'), ('19', 2, 3, 'MUSKA'), ('20', 2, 3, 'MUSKA'),
    ('21', 3, 3, 'ZENSKA'), ('22', 3, 3, 'ZENSKA'), ('23', 3, 3, 'ZENSKA'), ('24', 3, 3, 'ZENSKA'), ('25', 3, 3, 'ZENSKA'),
    ('26', 3, 3, 'ZENSKA'), ('27', 3, 3, 'ZENSKA'), ('28', 3, 3, 'ZENSKA'), ('29', 3, 3, 'ZENSKA'), ('30', 3, 3, 'ZENSKA');

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
