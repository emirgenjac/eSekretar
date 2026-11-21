-- =====================================================================
-- eSekretar - pogledi (Flyway repeatable migracija: izvršava se ponovo
-- kad se sadržaj fajla promijeni)
-- ESK-14 / D-02
--
-- v_obracun_prijave  : obaveza, uplaćeno i dug po prijavi (FR-12)
-- v_student_pregled  : jedan red po prijavi = kolone Excela sekretarice
--                      + mjeseci 10..7 + dug (FR-15 "Pregled kao Excel",
--                      FR-16 custom upiti nad whitelistom kolona)
--
-- Pravilo obračuna (pretpostavka, potvrditi za N-04):
--   * mjesec ulazi u obavezu ako je student bio zadužen bar jedan dan
--     u tom mjesecu, unutar perioda AG (npr. 1.10.-15.7.);
--   * obaveza po mjesecu = cijena AG (bez rata, bez dijela mjeseca);
--   * "do danas" = mjeseci koji su počeli najkasnije danas (uklj. tekući);
--   * "dospjelo" = samo završeni mjeseci (bez tekućeg), za dashboard
--     "dug za prethodni mjesec" i notifikaciju (FR-17, FR-18);
--   * neplacen_prethodni_mjesec = student je bio zadužen u prethodnom
--     mjesecu, a za taj mjesec nema uplate.
-- =====================================================================

CREATE OR REPLACE VIEW v_obracun_prijave AS
SELECT
    p.id                                               AS prijava_id,
    p.akademska_godina_id                              AS akademska_godina_id,
    c.iznos                                            AS cijena,
    COALESCE(mo.mjeseci_ukupno, 0)                     AS mjeseci_ukupno,
    COALESCE(mo.mjeseci_do_danas, 0)                   AS mjeseci_do_danas,
    COALESCE(mo.mjeseci_ukupno, 0) * COALESCE(c.iznos, 0)   AS obaveza_ukupno,
    COALESCE(mo.mjeseci_do_danas, 0) * COALESCE(c.iznos, 0) AS obaveza_do_danas,
    COALESCE(u.uplaceno, 0)                            AS uplaceno,
    COALESCE(mo.mjeseci_do_danas, 0) * COALESCE(c.iznos, 0)
        - COALESCE(u.uplaceno, 0)                      AS dug,
    COALESCE(mo.mjeseci_dospjeli, 0)                   AS mjeseci_dospjeli,
    COALESCE(mo.mjeseci_dospjeli, 0) * COALESCE(c.iznos, 0)
        - COALESCE(u.uplaceno, 0)                      AS dug_dospjeli,
    (COALESCE(mo.zaduzen_prethodni_mjesec, 0) = 1
        AND NOT EXISTS (SELECT 1 FROM uplata up
                        WHERE up.prijava_id = p.id
                          AND up.mjesec = MONTH(CURDATE() - INTERVAL 1 MONTH)))
                                                       AS neplacen_prethodni_mjesec
FROM prijava p
LEFT JOIN cijena_smjestaja c
       ON c.akademska_godina_id = p.akademska_godina_id
LEFT JOIN (
    SELECT prijava_id, SUM(iznos) AS uplaceno
    FROM uplata
    GROUP BY prijava_id
) u ON u.prijava_id = p.id
LEFT JOIN (
    SELECT
        s.prijava_id,
        COUNT(DISTINCT m.mjesec) AS mjeseci_ukupno,
        COUNT(DISTINCT CASE
            WHEN DATE_ADD(MAKEDATE(YEAR(ag.datum_od) + (m.mjesec < 10), 1), INTERVAL m.mjesec - 1 MONTH) <= CURDATE()
            THEN m.mjesec END)   AS mjeseci_do_danas,
        COUNT(DISTINCT CASE
            WHEN LAST_DAY(DATE_ADD(MAKEDATE(YEAR(ag.datum_od) + (m.mjesec < 10), 1), INTERVAL m.mjesec - 1 MONTH)) < CURDATE()
            THEN m.mjesec END)   AS mjeseci_dospjeli,
        MAX(DATE_ADD(MAKEDATE(YEAR(ag.datum_od) + (m.mjesec < 10), 1), INTERVAL m.mjesec - 1 MONTH)
            = DATE_FORMAT(CURDATE() - INTERVAL 1 MONTH, '%Y-%m-01'))
                                 AS zaduzen_prethodni_mjesec
    FROM smjestaj s
    JOIN prijava p2          ON p2.id = s.prijava_id
    JOIN akademska_godina ag ON ag.id = p2.akademska_godina_id
    JOIN (
        SELECT 10 AS mjesec UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL
        SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
        SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
    ) m
      -- početak mjeseca <= kraj boravka  I  kraj mjeseca >= početak boravka
      ON  DATE_ADD(MAKEDATE(YEAR(ag.datum_od) + (m.mjesec < 10), 1), INTERVAL m.mjesec - 1 MONTH)
              <= LEAST(COALESCE(s.datum_razduzenja, ag.datum_do), ag.datum_do)
      AND LAST_DAY(DATE_ADD(MAKEDATE(YEAR(ag.datum_od) + (m.mjesec < 10), 1), INTERVAL m.mjesec - 1 MONTH))
              >= GREATEST(s.datum_zaduzenja, ag.datum_od)
    GROUP BY s.prijava_id
) mo ON mo.prijava_id = p.id;


CREATE OR REPLACE VIEW v_student_pregled AS
SELECT
    -- identifikacija i filteri
    p.id                        AS prijava_id,
    st.id                       AS student_id,
    p.akademska_godina_id       AS akademska_godina_id,
    ag.naziv                    AS akademska_godina,
    p.status                    AS status_prijave,
    CASE
        WHEN ls.id IS NULL                 THEN 'BEZ_SMJESTAJA'
        WHEN ls.datum_razduzenja IS NULL   THEN 'AKTIVAN'
        ELSE 'RAZDUZEN'
    END                         AS stanje_smjestaja,

    -- lični podaci (Excel: "Prezime (Ime roditelja) Ime")
    CONCAT(st.prezime,
           IF(st.ime_roditelja IS NULL OR st.ime_roditelja = '', '', CONCAT(' (', st.ime_roditelja, ')')),
           ' ', st.ime)         AS puno_ime,
    st.prezime                  AS prezime,
    st.ime                      AS ime,
    st.ime_roditelja            AS ime_roditelja,
    tr.telefoni_roditelja       AS telefoni_roditelja,
    k.sifra                     AS kanton_sifra,
    k.naziv                     AS kanton,
    st.opcina                   AS opcina,
    st.adresa                   AS adresa,
    st.spol                     AS spol,
    st.email                    AS email,
    st.telefon                  AS telefon,
    st.jmbg                     AS jmbg,
    st.broj_licne               AS broj_licne,
    st.strani                   AS strani,
    st.drzava                   AS drzava,
    st.broj_pasosa              AS broj_pasosa,

    -- prijava za AG
    p.broj_ugovora              AS broj_ugovora,
    p.fakultet                  AS fakultet,
    p.godina_studija_ciklus     AS godina_studija_ciklus,
    p.trajanje_studija          AS trajanje_studija,
    p.godina_upisa              AS godina_upisa,
    p.datum_prijave             AS datum_prijave,
    p.broj_kartice              AS broj_kartice,
    p.ljekarsko_uvjerenje       AS ljekarsko_uvjerenje,
    p.fakultetsko_uvjerenje     AS fakultetsko_uvjerenje,

    -- smještaj (trenutni, ili posljednji ako je razdužen)
    so.broj                     AS soba,
    so.sprat                    AS sprat,
    ls.datum_zaduzenja          AS datum_zaduzenja,
    ls.datum_razduzenja         AS datum_razduzenja,

    -- uplate po mjesecima AG (10..12, 1..7)
    up.uplata_10, up.uplata_11, up.uplata_12,
    up.uplata_01, up.uplata_02, up.uplata_03, up.uplata_04,
    up.uplata_05, up.uplata_06, up.uplata_07,

    -- obračun
    ob.cijena                   AS cijena,
    ob.mjeseci_do_danas         AS mjeseci_obaveze,
    ob.obaveza_do_danas         AS obaveza,
    ob.uplaceno                 AS uplaceno,
    ob.dug                      AS dug,
    ob.dug_dospjeli             AS dug_dospjeli,
    ob.neplacen_prethodni_mjesec AS neplacen_prethodni_mjesec
FROM prijava p
JOIN student st           ON st.id = p.student_id
JOIN akademska_godina ag  ON ag.id = p.akademska_godina_id
LEFT JOIN kanton k        ON k.id = st.kanton_id
LEFT JOIN (
    SELECT student_id,
           GROUP_CONCAT(broj ORDER BY redoslijed, id SEPARATOR ', ') AS telefoni_roditelja
    FROM student_telefon_roditelja
    GROUP BY student_id
) tr ON tr.student_id = st.id
LEFT JOIN (
    SELECT s.*,
           ROW_NUMBER() OVER (PARTITION BY s.prijava_id
                              ORDER BY (s.datum_razduzenja IS NULL) DESC,
                                       s.datum_zaduzenja DESC, s.id DESC) AS rn
    FROM smjestaj s
) ls ON ls.prijava_id = p.id AND ls.rn = 1
LEFT JOIN soba so         ON so.id = ls.soba_id
LEFT JOIN (
    SELECT prijava_id,
           SUM(CASE WHEN mjesec = 10 THEN iznos END) AS uplata_10,
           SUM(CASE WHEN mjesec = 11 THEN iznos END) AS uplata_11,
           SUM(CASE WHEN mjesec = 12 THEN iznos END) AS uplata_12,
           SUM(CASE WHEN mjesec = 1  THEN iznos END) AS uplata_01,
           SUM(CASE WHEN mjesec = 2  THEN iznos END) AS uplata_02,
           SUM(CASE WHEN mjesec = 3  THEN iznos END) AS uplata_03,
           SUM(CASE WHEN mjesec = 4  THEN iznos END) AS uplata_04,
           SUM(CASE WHEN mjesec = 5  THEN iznos END) AS uplata_05,
           SUM(CASE WHEN mjesec = 6  THEN iznos END) AS uplata_06,
           SUM(CASE WHEN mjesec = 7  THEN iznos END) AS uplata_07
    FROM uplata
    GROUP BY prijava_id
) up ON up.prijava_id = p.id
JOIN v_obracun_prijave ob ON ob.prijava_id = p.id;
