--Zadanie 5
CREATE DATABASE link DBLINKFILIA CONNECT TO
RBDN_STi IDENTIFIED BY start123 using 'baza11b';

CREATE PRIVATE SYNONYM wykladowcySiedziba FOR wykladowcy;
CREATE PRIVATE SYNONYM kursanciSiedziba   FOR kursanci;
CREATE PRIVATE SYNONYM rodzajeSiedziba    FOR rodzaje;
CREATE PRIVATE SYNONYM kursySiedziba      FOR kursy;

CREATE PRIVATE SYNONYM wykladowcyFilia FOR wykladowcy@filia_link;
CREATE PRIVATE SYNONYM kursanciFilia   FOR kursanci@filia_link;
CREATE PRIVATE SYNONYM rodzajeFilia    FOR rodzaje@filia_link;
CREATE PRIVATE SYNONYM kursyFilia      FOR kursy@filia_link;

--Zadanie 6
CREATE OR REPLACE VIEW kursanciAll AS
    SELECT imie, nazwisko FROM kursanciSiedziba
    UNION
    SELECT imie, nazwisko FROM kursanciFilia;

CREATE OR REPLACE VIEW wykladowcyAll AS
    SELECT imie, nazwisko FROM wykladowcySiedziba
    UNION
    SELECT imie, nazwisko FROM wykladowcyFilia;

--Zadanie 7
CREATE OR REPLACE VIEW kursyAll AS
    SELECT
        r.nazwa, w.imie, w.nazwisko, COUNT(u.kursant_id) AS liczba_uczestnikow
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON r.rodzaj_id = k.rodzaj_id
    JOIN wykladowcySiedziba w ON w.wykladowca_id = k.wykladowca_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY r.nazwa, w.imie, w.nazwisko, k.kurs_id
    UNION ALL

    SELECT
        r.nazwa, w.imie, w.nazwisko, COUNT(u.kursant_id) AS liczba_uczestnikow
    FROM kursyFilia k
    JOIN rodzajeFilia r ON r.rodzaj_id = k.rodzaj_id
    JOIN wykladowcyFilia w ON w.wykladowca_id = k.wykladowca_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY r.nazwa, w.imie, w.nazwisko, k.kurs_id;

--Zadanie 8
SELECT
    SUM(r.cena * kurs_siedziba.ile) AS przychod_lacznie
FROM (
    SELECT kurs_id, COUNT(*) AS ile
    FROM umowy
    GROUP BY kurs_id
) kurs_siedziba
JOIN kursySiedziba k ON k.kurs_id = kurs_siedziba.kurs_id
JOIN rodzajeSiedziba r ON r.rodzaj_id = k.rodzaj_id

UNION ALL

SELECT
    SUM(r.cena * kurs_filia.ile) AS przychod_lacznie
FROM (
    SELECT kurs_id, COUNT(*) AS ile
    FROM umowy
    WHERE kurs_id IN (SELECT kurs_id FROM kursyFilia)
    GROUP BY kurs_id
) kurs_filia
JOIN kursyFilia k ON k.kurs_id   = kurs_filia.kurs_id
JOIN rodzajeFilia r ON r.rodzaj_id = k.rodzaj_id;

--Zadanie 9
SELECT SUM(przychod) AS przychod_lacznie
FROM (
    SELECT r.cena * COUNT(u.umowa_id) AS przychod
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON r.rodzaj_id = k.rodzaj_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY k.kurs_id, r.cena

    UNION ALL

    SELECT r.cena * COUNT(u.umowa_id) AS przychod
    FROM kursyFilia k
    JOIN rodzajeFilia r ON r.rodzaj_id = k.rodzaj_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY k.kurs_id, r.cena
);

--Zadanie 10
SELECT
    kurs_id,
    nazwa_kursu,
    prowadzacy,
    przychod,
    koszt,
    (przychod - koszt) AS zysk_strata
FROM (
    SELECT
        k.kurs_id, r.nazwa, w.imie, w.nazwisko, r.cena * COUNT(u.umowa_id) AS przychod, w.stawka * r.godz AS koszt
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON r.rodzaj_id = k.rodzaj_id
    JOIN wykladowcySiedziba w ON w.wykladowca_id = k.wykladowca_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY k.kurs_id, r.nazwa, w.imie, w.nazwisko, r.cena, w.stawka, r.godz

    UNION ALL

    SELECT
        r.nazwa, w.imie, w.nazwisko, r.cena * COUNT(u.umowa_id) AS przychod, w.stawka * r.godz AS koszt
    FROM kursyFilia k
    JOIN rodzajeFilia r ON r.rodzaj_id = k.rodzaj_id
    JOIN wykladowcyFilia w ON w.wykladowca_id = k.wykladowca_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY k.kurs_id, r.nazwa, w.imie, w.nazwisko, r.cena, w.stawka, r.godz
)
ORDER BY zysk_strata DESC;

--Zadanie 11
SELECT SUM(przychod - koszt) AS laczny_zysk_strata
FROM (
    SELECT
        r.cena * COUNT(u.umowa_id) AS przychod, w.stawka * r.godz          AS koszt
    FROM kursySiedziba k
    JOIN rodzajeSiedziba r ON r.rodzaj_id = k.rodzaj_id
    JOIN wykladowcySiedziba w ON w.wykladowca_id = k.wykladowca_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY k.kurs_id, r.cena, w.stawka, r.godz

    UNION ALL

    SELECT
        r.cena * COUNT(u.umowa_id) AS przychod, w.stawka * r.godz AS koszt
    FROM kursyFilia k
    JOIN rodzajeFilia r ON r.rodzaj_id = k.rodzaj_id
    JOIN wykladowcyFilia w ON w.wykladowca_id = k.wykladowca_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY k.kurs_id, r.cena, w.stawka, r.godz
);
