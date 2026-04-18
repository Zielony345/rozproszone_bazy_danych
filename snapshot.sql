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



--zadanie 1
CREATE MATERIALIZED VIEW rep_wykladowcy
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS 
SELECT wykladowca_id,imie, nazwisko, stawka
FROM wykladowca@filia_link;
--zadanie 2
CREATE MATERIALIZED VIEW mv_kursanci
BUILD IMMEDIATE
REFRESH COMPLETE ON COMMIT
AS
SELECT *FROM kursanci;
--zadanie 3

CREATE MATERIALIZED VIEW rep_przychod_podatek
BUILD IMMEDIATE
REFRESH COMPLETE
ON DEMAND
AS
SELECT
    nazwa, imie, nazwisko, przychod, ROUND(przychod * 0.19, 2)  AS podatek_19proc, ROUND(przychod * 1.19, 2)  AS przychod_brutto
FROM (
    SELECT
        r.nazwa, w.imie, w.nazwisko, r.cena * COUNT(u.umowa_id) AS przychod
    FROM kursy k
    JOIN rodzaje r ON r.rodzaj_id = k.rodzaj_id
    JOIN wykladowcy w ON w.wykladowca_id = k.wykladowca_id
    LEFT JOIN umowy u  ON u.kurs_id = k.kurs_id
    GROUP BY k.kurs_id, r.nazwa, w.imie, w.nazwisko, r.cena

    UNION ALL

    SELECT
        r.nazwa AS nazwa_kursu, w.imie, w.nazwisko, r.cena * COUNT(u.umowa_id) AS przychod
    FROM kursy@filia_link k
    JOIN rodzaje@filia_link r ON r.rodzaj_id = k.rodzaj_id
    JOIN wykladowcy@filia_link w ON w.wykladowca_id = k.wykladowca_id
    LEFT JOIN umowy u ON u.kurs_id = k.kurs_id
    GROUP BY k.kurs_id, r.nazwa, w.imie, w.nazwisko, r.cena
);

--Zadanie 4
Migawka z zadanie 3 może działać wyłącznie w trybie DEMOND.

--==================================================

--Zadanie 1
CREATE MATERIALIZED VIEW REP_wykladowcy
REFRESH COMPLETE ON DEMAND
AS 
SELECT * FROM wykladowcy@filia_link;

--Zadanie 2
INSERT INTO wykladowcy (wykladowca_id, imie, nazwisko, stawka)
VALUES (200, 'ADAM', 'NOWY', 110);

COMMIT;

--Zadanie 3
SELECT * FROM REP_wykladowcy;

--Zadanie 4
BEGIN
   DBMS_MVIEW.REFRESH('REP_wykladowcy', 'C');
END;

--Zadanie 5
SELECT * FROM REP_wykladowcy;

--Zadanie 6
CREATE MATERIALIZED VIEW REP_godz_wykladowcy_godziny
REFRESH COMPLETE
START WITH LAST_DAY(SYSDATE)
NEXT SYSDATE + 1/24
AS
SELECT 
    w.imie, w.nazwisko, SUM(r.godz) as suma_godzin
FROM wykladowcy@filia_link w
JOIN kursy@filia_link k ON w.wykladowca_id = k.wykladowca_id
JOIN rodzaje@filia_link r ON k.rodzaj_id = r.rodzaj_id
GROUP BY w.imie, w.nazwisko;

--Zadanie 7
CREATE MATERIALIZED VIEW REP_kursy
REFRESH COMPLETE
START WITH SYSDATE
NEXT SYSDATE + 7
AS
SELECT 
    r.nazwa AS nazwa_kursu, w.imie, w.nazwisko, r.godz, r.cena
FROM kursy@filia_link k
JOIN rodzaje@filia_link r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy@filia_link w ON k.wykladowca_id = w.wykladowca_id;

--Zadanie 8
CREATE OR REPLACE VIEW V_WSZYSTKIE_KURSY AS

SELECT nazwa_kursu, imie, nazwisko, godz, cena, 'FILIA' as lokalizacja
FROM REP_kursy
UNION ALL

SELECT 
    r.nazwa, w.imie, w.nazwisko, r.godz, r.cena, 'SIEDZIBA' as lokalizacja
FROM kursy k
JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
JOIN wykladowcy w ON k.wykladowca_id = w.wykladowca_id;

--informacje o migawkach 
SELECT owner, mview_name, last_refresh_date, next_refresh_date, refresh_method
FROM USER_MVIEWS;

--==================================================

--Zadanie 1
--baza11a
CREATE MATERIALIZED VIEW LOG ON kursanci WITH PRIMARY KEY;

--baza11b
CREATE MATERIALIZED VIEW MV_kursanci_fast
REFRESH FAST ON DEMAND
AS 
SELECT * FROM kursanci@siedziba_link;

--Zadanie 2
CREATE MATERIALIZED VIEW MV_kursanci_commit
REFRESH FAST ON COMMIT
AS 
SELECT * FROM kursanci;

--Zadanie 3
CREATE MATERIALIZED VIEW REP_TOTAL_REVENUE
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    SUM(r.cena) AS przychod_brutto,
    SUM(r.cena) * 0.19 AS podatek_19_procent,
    SUM(r.cena) * 0.81 AS przychod_netto
FROM umowy u
JOIN kursy k ON u.kurs_id = k.kurs_id
JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id;

Migawke z punktu 3 zapisać w trybie fast  z odśweżaniem on commit pod warunkiem spełnienia wymogów:
- wszystkie tabele muszą mieć klucz główny
- nie mogą zawierać funkcji analitycznych ani niektórych typów podzapytań.
