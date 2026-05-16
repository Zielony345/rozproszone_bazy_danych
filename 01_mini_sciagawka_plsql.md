# Mini-ściągawka PL/SQL dla studentów

## 1. Czym jest PL/SQL?

**PL/SQL** to proceduralne rozszerzenie języka SQL w bazie Oracle.

SQL pozwala pobierać i modyfikować dane, np.:

```sql
SELECT *
FROM kursanci;
```

PL/SQL pozwala pisać logikę wykonywaną po stronie bazy danych, np.:

- zmienne,
- instrukcje warunkowe,
- pętle,
- kursory,
- procedury,
- funkcje,
- obsługę wyjątków,
- automatyzację raportów i operacji na danych.

W uproszczeniu:

```text
SQL = zapytania do danych
PL/SQL = programowanie w bazie danych
```

---

## 2. Włączenie wypisywania wyników

W wielu narzędziach Oracle przed użyciem `DBMS_OUTPUT.PUT_LINE` należy włączyć wyświetlanie wyników:

```sql
SET SERVEROUTPUT ON;
```

---

## 3. Blok anonimowy

Blok anonimowy to najprostszy program PL/SQL. Jest wykonywany od razu, ale nie zostaje zapisany w bazie.

```sql
DECLARE
  v_liczba NUMBER;
BEGIN
  v_liczba := 10;

  DBMS_OUTPUT.PUT_LINE('Wartość zmiennej: ' || v_liczba);
END;
/
```

Znaczenie części:

- `DECLARE` — miejsce na deklarację zmiennych,
- `BEGIN` — początek części wykonywalnej,
- `END;` — koniec bloku,
- `/` — uruchomienie bloku w narzędziu Oracle.

---

## 4. Zmienne

Zmienna to miejsce na przechowanie wartości.

```sql
DECLARE
  v_miasto VARCHAR2(30);
  v_liczba NUMBER;
BEGIN
  v_miasto := 'BYDGOSZCZ';
  v_liczba := 5;

  DBMS_OUTPUT.PUT_LINE(v_miasto || ': ' || v_liczba);
END;
/
```

Najczęściej używane typy:

```sql
NUMBER          -- liczba
VARCHAR2(100)  -- tekst
DATE            -- data
```

Dobra praktyka: zmienne często zaczynamy od `v_`, np. `v_liczba_umow`.

---

## 5. Przypisanie wartości

W PL/SQL do przypisania wartości służy operator:

```sql
:=
```

Przykład:

```sql
v_miasto := 'BYDGOSZCZ';
v_liczba := 10;
```

---

## 6. SELECT ... INTO

W PL/SQL wynik zapytania można zapisać do zmiennej za pomocą `INTO`.

```sql
DECLARE
  v_liczba NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_liczba
  FROM kursanci;

  DBMS_OUTPUT.PUT_LINE('Liczba kursantów: ' || v_liczba);
END;
/
```

Ważne:

`SELECT ... INTO` musi zwrócić dokładnie jeden wiersz.

Możliwe błędy:

- `NO_DATA_FOUND` — zapytanie nie zwróciło żadnego wiersza,
- `TOO_MANY_ROWS` — zapytanie zwróciło więcej niż jeden wiersz.

---

## 7. DBMS_OUTPUT.PUT_LINE

Służy do wypisywania tekstu na ekran.

```sql
DBMS_OUTPUT.PUT_LINE('Witaj świecie');
```

Łączenie tekstu i zmiennych:

```sql
DBMS_OUTPUT.PUT_LINE('Liczba umów: ' || v_liczba_umow);
```

Operator `||` oznacza łączenie tekstu.

---

## 8. Instrukcja warunkowa IF

Pozwala wykonać różne instrukcje w zależności od warunku.

```sql
IF v_liczba_umow = 0 THEN
  DBMS_OUTPUT.PUT_LINE('Brak umów');
ELSIF v_liczba_umow < 50 THEN
  DBMS_OUTPUT.PUT_LINE('Mała liczba umów');
ELSE
  DBMS_OUTPUT.PUT_LINE('Duża liczba umów');
END IF;
```

---

## 9. Pętla po wyniku zapytania

Pętla `FOR ... IN SELECT` pozwala przejść po wielu rekordach.

```sql
BEGIN
  FOR r IN (
    SELECT imie, nazwisko
    FROM kursanci
  ) LOOP
    DBMS_OUTPUT.PUT_LINE(r.imie || ' ' || r.nazwisko);
  END LOOP;
END;
/
```

`r` oznacza aktualny rekord z wyniku zapytania.

---

## 10. Kursor

Kursor pozwala przechodzić po wyniku zapytania wiersz po wierszu.

### Prosty kursor w pętli

```sql
FOR r IN (
  SELECT imie, nazwisko
  FROM kursanci
) LOOP
  DBMS_OUTPUT.PUT_LINE(r.imie || ' ' || r.nazwisko);
END LOOP;
```

### Kursor jawny

```sql
DECLARE
  CURSOR c_kursanci IS
    SELECT imie, nazwisko
    FROM kursanci;

  v_kursant c_kursanci%ROWTYPE;
BEGIN
  OPEN c_kursanci;

  LOOP
    FETCH c_kursanci INTO v_kursant;
    EXIT WHEN c_kursanci%NOTFOUND;

    DBMS_OUTPUT.PUT_LINE(v_kursant.imie || ' ' || v_kursant.nazwisko);
  END LOOP;

  CLOSE c_kursanci;
END;
/
```

Znaczenie:

- `CURSOR` — deklaracja kursora,
- `OPEN` — otwarcie kursora,
- `FETCH` — pobranie kolejnego wiersza,
- `%NOTFOUND` — informacja, że nie ma już danych,
- `CLOSE` — zamknięcie kursora.

---

## 11. %TYPE

`%TYPE` pozwala utworzyć zmienną o takim samym typie jak kolumna w tabeli.

```sql
DECLARE
  v_imie kursanci.imie%TYPE;
BEGIN
  SELECT imie
  INTO v_imie
  FROM kursanci
  WHERE kursant_id = 1;
END;
/
```

Zaleta: jeśli typ kolumny w tabeli się zmieni, zmienna automatycznie się dopasuje.

---

## 12. %ROWTYPE

`%ROWTYPE` pozwala utworzyć zmienną przechowującą cały wiersz tabeli albo kursora.

```sql
DECLARE
  v_kursant kursanci%ROWTYPE;
BEGIN
  SELECT *
  INTO v_kursant
  FROM kursanci
  WHERE kursant_id = 1;

  DBMS_OUTPUT.PUT_LINE(v_kursant.imie || ' ' || v_kursant.nazwisko);
END;
/
```

---

## 13. Procedura

Procedura to zapisany w bazie fragment programu, który można uruchamiać wiele razy.

```sql
CREATE OR REPLACE PROCEDURE pokaz_miasto(
  p_miasto IN VARCHAR2
)
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Miasto: ' || p_miasto);
END;
/
```

Uruchomienie:

```sql
BEGIN
  pokaz_miasto('BYDGOSZCZ');
END;
/
```

Procedura zwykle coś wykonuje: generuje raport, zapisuje dane, aktualizuje rekordy.

---

## 14. Funkcja

Funkcja jest podobna do procedury, ale musi zwrócić wartość przez `RETURN`.

```sql
CREATE OR REPLACE FUNCTION policz_umowy(
  p_miasto IN VARCHAR2
)
RETURN NUMBER
AS
  v_liczba NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO v_liczba
  FROM umowy
  WHERE miasto = p_miasto;

  RETURN v_liczba;
END;
/
```

Wywołanie:

```sql
SELECT policz_umowy('BYDGOSZCZ')
FROM dual;
```

W skrócie:

```text
Procedura coś robi.
Funkcja coś zwraca.
```

---

## 15. Wyjątki

Wyjątek to sytuacja błędna lub nietypowa.

```sql
DECLARE
  v_imie kursanci.imie%TYPE;
BEGIN
  SELECT imie
  INTO v_imie
  FROM kursanci
  WHERE kursant_id = 999999;

  DBMS_OUTPUT.PUT_LINE(v_imie);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Nie znaleziono kursanta.');
END;
/
```

Najczęstsze wyjątki:

- `NO_DATA_FOUND` — brak wyniku dla `SELECT ... INTO`,
- `TOO_MANY_ROWS` — zbyt wiele wyników dla `SELECT ... INTO`,
- `ZERO_DIVIDE` — dzielenie przez zero,
- `OTHERS` — każdy inny błąd.

---

## 16. RAISE_APPLICATION_ERROR

Pozwala zgłosić własny błąd z własnym komunikatem.

```sql
RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono kursu.');
```

Zakres numerów własnych błędów:

```text
-20000 do -20999
```

---

## 17. COMMIT i ROLLBACK

Jeżeli PL/SQL wykonuje operacje zmieniające dane, np.:

```sql
INSERT
UPDATE
DELETE
```

zmiany można zatwierdzić:

```sql
COMMIT;
```

albo wycofać:

```sql
ROLLBACK;
```

---

## 18. CREATE OR REPLACE

Tworzy obiekt, a jeśli już istnieje, nadpisuje go.

```sql
CREATE OR REPLACE PROCEDURE pokaz_test
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Test');
END;
/
```

---

## 19. DUAL

`DUAL` to techniczna tabela Oracle używana wtedy, gdy chcemy coś wywołać bez korzystania z realnej tabeli.

```sql
SELECT SYSDATE
FROM dual;
```

Przykład z funkcją:

```sql
SELECT policz_umowy('BYDGOSZCZ')
FROM dual;
```

---

## 20. Database link

Database link to łącznik do innej bazy danych Oracle.

Przykład:

```sql
SELECT *
FROM kursanci@filia;
```

Znaczenie:

- `kursanci` — tabela w zdalnej bazie,
- `@filia` — nazwa łącznika bazodanowego.

---

## 21. Migawka / materialized view

Migawka to lokalna kopia wyniku zapytania.

Przykład:

```sql
CREATE MATERIALIZED VIEW mv_kursanci_filia
AS
SELECT *
FROM kursanci@filia;
```

Odświeżenie migawki:

```sql
EXEC DBMS_MVIEW.REFRESH('MV_KURSANCI_FILIA', 'C');
```

`C` oznacza pełne odświeżenie, czyli `complete refresh`.

---

## 22. Kontekst naszych danych

Pracujemy na danych uczelni prowadzącej kursy w siedzibie i filii.

Najważniejsze tabele:

- `kursanci` — osoby zapisujące się na kursy,
- `wykladowcy` — prowadzący kursy,
- `rodzaje` — typy kursów,
- `kursy` — konkretne uruchomione kursy,
- `umowy` — zapisy kursantów na kursy.

Siedziba przechowuje centralną tabelę `umowy`.

Część danych jest lokalna, a część pochodzi z filii. Dlatego w niektórych zadaniach trzeba użyć:

- lokalnych tabel,
- migawek danych filii,
- albo database linka.

---

## 23. Najważniejsza myśl

```text
PL/SQL pozwala budować logikę wokół danych:
raportować, sprawdzać warunki, obsługiwać błędy,
automatyzować operacje i łączyć dane lokalne ze zdalnymi.
```
