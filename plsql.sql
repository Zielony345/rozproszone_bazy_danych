-- ====ZADANIE 1====

DECLARE
    v_kursanci    NUMBER;
    v_kursy       NUMBER;
    v_wykladowcy  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_kursanci FROM kursanci;
    SELECT COUNT(*) INTO v_kursy FROM kursy;
    SELECT COUNT(*) INTO v_wykladowcy FROM wykladowcy;

    DBMS_OUTPUT.PUT_LINE('Liczba kursantów: '    || v_kursanci);
    DBMS_OUTPUT.PUT_LINE('Liczba kursów: '       || v_kursy);
    DBMS_OUTPUT.PUT_LINE('Liczba wykładowców: '  || v_wykladowcy);
END;
/


-- ====ZADANIE 2====

DECLARE
    v_wartosc  NUMBER;
BEGIN
    SELECT SUM(r.cena)
    INTO v_wartosc
    FROM umowy u
    JOIN kursy k ON u.kurs_id = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id  = r.rodzaj_id
    WHERE u.miasto = 'BYDGOSZCZ';

    DBMS_OUTPUT.PUT_LINE('Łączna wartość umów dla BYDGOSZCZY: ' || v_wartosc || ' zł');
END;
/

-- ====ZADANIE 3====
DECLARE
    v_miasto  VARCHAR2(20) := 'BYDGOSZCZ';
    v_liczba  NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO   v_liczba
    FROM   umowy
    WHERE  miasto = v_miasto;

    DBMS_OUTPUT.PUT_LINE('Miasto: ' || v_miasto || ', liczba umów: ' || v_liczba);

    IF v_liczba = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Brak umów dla miasta');
    ELSIF v_liczba < 50 THEN
        DBMS_OUTPUT.PUT_LINE('Mała liczba umów');
    ELSIF v_liczba <= 100 THEN
        DBMS_OUTPUT.PUT_LINE('Średnia liczba umów');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Duża liczba umów');
    END IF;
END;
/

-- ====ZADANIE 4====
BEGIN
    FOR r IN (
        SELECT k.kurs_id,
               ro.nazwa,
               ro.godz,
               ro.cena,
               w.imie,
               w.nazwisko
        FROM kursy k
        JOIN rodzajero ON k.rodzaj_id = ro.rodzaj_id
        JOIN wykladowcy w  ON k.wykladowca_id = w.wykladowca_id
        ORDER BY k.kurs_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Kurs ' || r.kurs_id || ': '
            || r.nazwa  || ', '
            || r.godz   || 'h, '
            || r.cena   || ' zł, prowadzący: '
            || r.imie   || ' ' || r.nazwisko
        );
    END LOOP;
END;
/

-- ====ZADANIE 5====

CREATE OR REPLACE PROCEDURE raport_umow_miasto(p_miasto IN VARCHAR2) IS
    v_liczba   NUMBER;
    v_suma     NUMBER;
    v_srednia  NUMBER;
BEGIN
    SELECT COUNT(*),
           SUM(r.cena),
           AVG(r.cena)
    INTO   v_liczba,
           v_suma,
           v_srednia
    FROM umowy      u
    JOIN kursy k ON u.kurs_id   = k.kurs_id
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE u.miasto = p_miasto;

    DBMS_OUTPUT.PUT_LINE('Raport dla miasta: ' || p_miasto);
    DBMS_OUTPUT.PUT_LINE('Liczba umów: '             || v_liczba);
    DBMS_OUTPUT.PUT_LINE('Łączna wartość umów: '     || v_suma    || ' zł');
    DBMS_OUTPUT.PUT_LINE('Średnia wartość umowy: '   || ROUND(v_srednia, 2) || ' zł');
END;
/

-- ====ZADANIE 6====
CREATE OR REPLACE FUNCTION wartosc_kursu(p_kurs_id IN NUMBER)
RETURN NUMBER IS
    v_cena NUMBER;
BEGIN
    SELECT r.cena
    INTO v_cena
    FROM kursy   k
    JOIN rodzaje r ON k.rodzaj_id = r.rodzaj_id
    WHERE k.kurs_id = p_kurs_id;

    RETURN v_cena;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Kurs o ID ' || p_kurs_id || ' nie istnieje.');
        RETURN 0;
END;
/

-- ====ZADANIE 7====
CREATE OR REPLACE PROCEDURE pokaz_kursanta(p_kursant_id IN NUMBER) IS
    v_imie     VARCHAR2(20);
    v_nazwisko VARCHAR2(30);
BEGIN
    SELECT imie, nazwisko
    INTO   v_imie, v_nazwisko
    FROM   kursanci
    WHERE  kursant_id = p_kursant_id;

    DBMS_OUTPUT.PUT_LINE('Kursant: ' || v_imie || ' ' || v_nazwisko);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta o ID: ' || p_kursant_id);
END;
/
--uzycie 
BEGIN
    pokaz_kursanta(1);    -- istnieje
    pokaz_kursanta(999);  -- nie istnieje
END;
/

-- ====ZADANIE 8====
DECLARE
    -- definicja kursora z pełnym zapytaniem
    CURSOR c_umowy IS
        SELECT u.umowa_id,
               k.imie        AS k_imie,
               k.nazwisko    AS k_nazwisko,
               r.nazwa       AS kurs_nazwa,
               r.cena        AS kurs_cena
        FROM   umowy      u
        JOIN   kursanci   k  ON u.kursant_id = k.kursant_id
        JOIN   kursy      ku ON u.kurs_id    = ku.kurs_id
        JOIN   rodzaje    r  ON ku.rodzaj_id = r.rodzaj_id
        WHERE  u.miasto = 'BYDGOSZCZ'
        ORDER BY u.umowa_id;

    -- rekord dopasowany do struktury kursora
    v_wiersz c_umowy%ROWTYPE;

BEGIN
    OPEN c_umowy;

    LOOP
        FETCH c_umowy INTO v_wiersz;
        EXIT WHEN c_umowy%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(
            'Umowa ' || v_wiersz.umowa_id    || ' | '
            || v_wiersz.k_imie    || ' ' || v_wiersz.k_nazwisko || ' | '
            || v_wiersz.kurs_nazwa || ' | '
            || v_wiersz.kurs_cena  || ' zł'
        );
    END LOOP;

    CLOSE c_umowy;

    -- %ROWCOUNT dostępny po zamknięciu - ile wierszy przetworzono
    DBMS_OUTPUT.PUT_LINE('--- Łącznie umów: ' || c_umowy%ROWCOUNT);
END;
/

---- ====ZADANIE 9====
-- Tworzenie database link 
-- CREATE DATABASE LINK filia
--   CONNECT TO user_filia IDENTIFIED BY haslo
--   USING 'nazwa_uslugi_filia';

CREATE OR REPLACE PROCEDURE raport_umow_szczecin IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== RAPORT UMÓW: SZCZECIN ===');

    FOR r IN (
        SELECT u.umowa_id,
               k.imie        AS k_imie,
               k.nazwisko    AS k_nazwisko,
               ro.nazwa      AS kurs_nazwa,
               ro.cena       AS kurs_cena,
               u.miasto
        FROM   umowy                 u
        JOIN   kursanci@filia        k  ON u.kursant_id = k.kursant_id
        JOIN   kursy@filia           ku ON u.kurs_id    = ku.kurs_id
        JOIN   rodzaje@filia         ro ON ku.rodzaj_id = ro.rodzaj_id
        WHERE  u.miasto = 'SZCZECIN'
        ORDER BY u.umowa_id
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Umowa ' || r.umowa_id   || ' | '
            || r.k_imie   || ' ' || r.k_nazwisko || ' | '
            || r.kurs_nazwa || ' | '
            || r.kurs_cena  || ' zł | '
            || r.miasto
        );
    END LOOP;
END;
/

---- ====ZADANIE 10====
CREATE OR REPLACE PROCEDURE raport_uczelni IS

    -- zmienne dla Bydgoszczy
    v_bydg_liczba    NUMBER;
    v_bydg_suma      NUMBER;
    v_bydg_najdrozszy  VARCHAR2(30);
    v_bydg_popularny   VARCHAR2(30);

    -- zmienne dla Szczecina
    v_szcz_liczba    NUMBER;
    v_szcz_suma      NUMBER;
    v_szcz_najdrozszy  VARCHAR2(30);
    v_szcz_popularny   VARCHAR2(30);

    -- podsumowanie
    v_total_liczba   NUMBER;
    v_total_suma     NUMBER;

BEGIN
    -- ============================================================
    -- BYDGOSZCZ — dane lokalne
    -- ============================================================
    SELECT COUNT(*), SUM(r.cena)
    INTO   v_bydg_liczba, v_bydg_suma
    FROM   umowy      u
    JOIN   kursy      k  ON u.kurs_id   = k.kurs_id
    JOIN   rodzaje    r  ON k.rodzaj_id = r.rodzaj_id
    WHERE  u.miasto = 'BYDGOSZCZ';

    -- najdroższy kurs w Bydgoszczy
    SELECT r.nazwa
    INTO   v_bydg_najdrozszy
    FROM   rodzaje r
    WHERE  r.cena = (
               SELECT MAX(r2.cena)
               FROM   umowy   u
               JOIN   kursy   k  ON u.kurs_id   = k.kurs_id
               JOIN   rodzaje r2 ON k.rodzaj_id = r2.rodzaj_id
               WHERE  u.miasto = 'BYDGOSZCZ'
           )
    AND ROWNUM = 1;

    -- najpopularniejszy kurs w Bydgoszczy (najwięcej umów)
    SELECT r.nazwa
    INTO   v_bydg_popularny
    FROM   umowy      u
    JOIN   kursy      k  ON u.kurs_id   = k.kurs_id
    JOIN   rodzaje    r  ON k.rodzaj_id = r.rodzaj_id
    WHERE  u.miasto = 'BYDGOSZCZ'
    GROUP BY r.nazwa
    HAVING COUNT(*) = (
               SELECT MAX(COUNT(*))
               FROM   umowy   u2
               JOIN   kursy   k2 ON u2.kurs_id   = k2.kurs_id
               JOIN   rodzaje r2 ON k2.rodzaj_id = r2.rodzaj_id
               WHERE  u2.miasto = 'BYDGOSZCZ'
               GROUP BY r2.nazwa
           )
    AND ROWNUM = 1;

    -- ============================================================
    -- SZCZECIN — dane przez migawki filii
    -- ============================================================
    SELECT COUNT(*), SUM(r.cena)
    INTO   v_szcz_liczba, v_szcz_suma
    FROM   umowy               u
    JOIN   mv_kursy_filia      k  ON u.kurs_id   = k.kurs_id
    JOIN   mv_rodzaje_filia    r  ON k.rodzaj_id = r.rodzaj_id
    WHERE  u.miasto = 'SZCZECIN';

    -- najdroższy kurs w Szczecinie
    SELECT r.nazwa
    INTO   v_szcz_najdrozszy
    FROM   mv_rodzaje_filia r
    WHERE  r.cena = (
               SELECT MAX(r2.cena)
               FROM   umowy            u
               JOIN   mv_kursy_filia   k  ON u.kurs_id   = k.kurs_id
               JOIN   mv_rodzaje_filia r2 ON k.rodzaj_id = r2.rodzaj_id
               WHERE  u.miasto = 'SZCZECIN'
           )
    AND ROWNUM = 1;

    -- najpopularniejszy kurs w Szczecinie
    SELECT r.nazwa
    INTO   v_szcz_popularny
    FROM   umowy               u
    JOIN   mv_kursy_filia      k  ON u.kurs_id   = k.kurs_id
    JOIN   mv_rodzaje_filia    r  ON k.rodzaj_id = r.rodzaj_id
    WHERE  u.miasto = 'SZCZECIN'
    GROUP BY r.nazwa
    HAVING COUNT(*) = (
               SELECT MAX(COUNT(*))
               FROM   umowy            u2
               JOIN   mv_kursy_filia   k2 ON u2.kurs_id   = k2.kurs_id
               JOIN   mv_rodzaje_filia r2 ON k2.rodzaj_id = r2.rodzaj_id
               WHERE  u2.miasto = 'SZCZECIN'
               GROUP BY r2.nazwa
           )
    AND ROWNUM = 1;

    -- ============================================================
    -- PODSUMOWANIE
    -- ============================================================
    v_total_liczba := v_bydg_liczba + v_szcz_liczba;
    v_total_suma   := v_bydg_suma   + v_szcz_suma;

    -- ============================================================
    -- WYDRUK
    -- ============================================================
    DBMS_OUTPUT.PUT_LINE('========== RAPORT UCZELNI ==========');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Miasto: BYDGOSZCZ');
    DBMS_OUTPUT.PUT_LINE('  Liczba umów:           ' || v_bydg_liczba);
    DBMS_OUTPUT.PUT_LINE('  Łączna wartość umów:   ' || v_bydg_suma  || ' zł');
    DBMS_OUTPUT.PUT_LINE('  Najdroższy kurs:       ' || v_bydg_najdrozszy);
    DBMS_OUTPUT.PUT_LINE('  Najpopularniejszy kurs:' || v_bydg_popularny);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Miasto: SZCZECIN');
    DBMS_OUTPUT.PUT_LINE('  Liczba umów:           ' || v_szcz_liczba);
    DBMS_OUTPUT.PUT_LINE('  Łączna wartość umów:   ' || v_szcz_suma  || ' zł');
    DBMS_OUTPUT.PUT_LINE('  Najdroższy kurs:       ' || v_szcz_najdrozszy);
    DBMS_OUTPUT.PUT_LINE('  Najpopularniejszy kurs:' || v_szcz_popularny);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========== PODSUMOWANIE ==========');
    DBMS_OUTPUT.PUT_LINE('  Liczba wszystkich umów:       ' || v_total_liczba);
    DBMS_OUTPUT.PUT_LINE('  Łączna wartość wszystkich umów: ' || v_total_suma || ' zł');
    DBMS_OUTPUT.PUT_LINE('==================================');
END;
/