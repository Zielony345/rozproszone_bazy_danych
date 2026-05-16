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