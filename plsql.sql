-- ====ZADANIE 1====

DECLARE
    v_kursanci    NUMBER;
    v_kursy       NUMBER;
    v_wykladowcy  NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_kursanci   FROM kursanci;
    SELECT COUNT(*) INTO v_kursy      FROM kursy;
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
    INTO   v_wartosc
    FROM   umowy u
    JOIN   kursy   k ON u.kurs_id    = k.kurs_id
    JOIN   rodzaje r ON k.rodzaj_id  = r.rodzaj_id
    WHERE  u.miasto = 'BYDGOSZCZ';

    DBMS_OUTPUT.PUT_LINE('Łączna wartość umów dla BYDGOSZCZY: ' || v_wartosc || ' zł');
END;
/