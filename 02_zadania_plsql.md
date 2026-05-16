# Zadania PL/SQL do wykonania

## Kontekst

Pracujemy na danych uczelni prowadzącej kursy w siedzibie oraz w filii.

Siedziba posiada między innymi tabele:

- `kursanci`,
- `wykladowcy`,
- `rodzaje`,
- `kursy`,
- `umowy`.

Filia posiada tabele:

- `kursanci`,
- `wykladowcy`,
- `rodzaje`,
- `kursy`.

Tabela `umowy` znajduje się w siedzibie i jest centralnym rejestrem zapisów na kursy.

Dane lokalne dotyczą miasta `BYDGOSZCZ`, a dane filii dotyczą miasta `SZCZECIN`.

W zadaniach związanych z filią można korzystać z wcześniej przygotowanych migawek, np.:

- `mv_kursanci_filia`,
- `mv_kursy_filia`,
- `mv_rodzaje_filia`,
- `mv_wykladowcy_filia`.

Jeżeli w Twoim środowisku migawki mają inne nazwy, dostosuj nazwy w zapytaniach.

Przed rozpoczęciem pracy włącz wyświetlanie wyników:

```sql
SET SERVEROUTPUT ON;
```

---

# Zadanie 1. Pierwszy blok PL/SQL

Napisz blok PL/SQL, który wyświetli:

- liczbę kursantów w siedzibie,
- liczbę kursów w siedzibie,
- liczbę wykładowców w siedzibie.

Wymagania:

- użyj zmiennych,
- użyj `SELECT COUNT(*) INTO ...`,
- użyj `DBMS_OUTPUT.PUT_LINE`.

Przykład wyniku:

```text
Liczba kursantów: 85
Liczba kursów: 8
Liczba wykładowców: 19
```

---

# Zadanie 2. Łączna wartość umów dla Bydgoszczy

Napisz blok PL/SQL, który policzy łączną wartość wszystkich umów z miasta `BYDGOSZCZ`.

Wartość jednej umowy oznacza cenę kursu, na który zapisany jest kursant.

Należy połączyć tabele:

```text
umowy -> kursy -> rodzaje
```

Wymagania:

- wynik zapisz do zmiennej,
- użyj `SUM`,
- wypisz wynik przez `DBMS_OUTPUT.PUT_LINE`.

Przykład wyniku:

```text
Łączna wartość umów dla BYDGOSZCZY: 95000 zł
```

---

# Zadanie 3. Ocena liczby umów dla miasta

Napisz blok PL/SQL, który policzy liczbę umów dla miasta zapisanego w zmiennej, np.:

```sql
v_miasto := 'BYDGOSZCZ';
```

Następnie wypisz jeden z komunikatów:

- jeśli liczba umów = 0: `Brak umów dla miasta`,
- jeśli liczba umów < 50: `Mała liczba umów`,
- jeśli liczba umów od 50 do 100: `Średnia liczba umów`,
- jeśli liczba umów > 100: `Duża liczba umów`.

Wymagania:

- użyj `IF`,
- użyj `ELSIF`,
- użyj `ELSE`.

---

# Zadanie 4. Lista kursów w siedzibie

Napisz blok PL/SQL, który wypisze listę kursów dostępnych w siedzibie.

Dla każdego kursu wyświetl:

- ID kursu,
- nazwę rodzaju kursu,
- liczbę godzin,
- cenę,
- imię i nazwisko wykładowcy.

Wymagania:

- użyj pętli `FOR r IN (SELECT ...) LOOP`,
- połącz tabele `kursy`, `rodzaje`, `wykladowcy`.

Przykład wyniku:

```text
Kurs 1: Oracle, 30h, 1200 zł, prowadzący: Jan Kowalski
```

---

# Zadanie 5. Procedura raportująca umowy dla miasta

Napisz procedurę:

```sql
raport_umow_miasto(p_miasto IN VARCHAR2)
```

Procedura ma wypisać:

- nazwę miasta,
- liczbę umów,
- łączną wartość umów,
- średnią wartość jednej umowy.

Przykład uruchomienia:

```sql
BEGIN
  raport_umow_miasto('BYDGOSZCZ');
END;
/
```

Przykład wyniku:

```text
Raport dla miasta: BYDGOSZCZ
Liczba umów: 85
Łączna wartość umów: 95000 zł
Średnia wartość umowy: 1117.65 zł
```

Uwaga: podstawowa wersja tej procedury może działać poprawnie tylko dla danych lokalnych, czyli dla `BYDGOSZCZ`.

---

# Zadanie 6. Funkcja zwracająca cenę kursu

Napisz funkcję:

```sql
wartosc_kursu(p_kurs_id IN NUMBER)
RETURN NUMBER
```

Funkcja ma zwrócić cenę kursu na podstawie `kurs_id`.

Należy połączyć:

```text
kursy -> rodzaje
```

Przykład użycia:

```sql
DECLARE
  v_cena NUMBER;
BEGIN
  v_cena := wartosc_kursu(1);
  DBMS_OUTPUT.PUT_LINE('Cena kursu: ' || v_cena);
END;
/
```

Wariant podstawowy:

- jeśli kurs istnieje, funkcja zwraca cenę.

Wariant rozszerzony:

- jeśli kurs nie istnieje, funkcja zwraca `0` albo zgłasza własny błąd.

---

# Zadanie 7. Obsługa wyjątków: wyszukiwanie kursanta

Napisz procedurę:

```sql
pokaz_kursanta(p_kursant_id IN NUMBER)
```

Procedura ma wypisać imię i nazwisko kursanta z siedziby.

Jeśli kursant nie istnieje, procedura ma wypisać:

```text
Nie znaleziono kursanta o ID: ...
```

Wymagania:

- użyj `SELECT ... INTO`,
- obsłuż wyjątek `NO_DATA_FOUND`.

Wariant dodatkowy:

Napisz drugą procedurę, która wyszukuje kursanta po nazwisku. Obsłuż sytuację, gdy zapytanie zwróci więcej niż jeden wiersz.

---

# Zadanie 8. Kursor jawny: szczegółowy raport umów

Napisz blok PL/SQL z kursorem jawnym, który wygeneruje szczegółowy raport umów dla `BYDGOSZCZ`.

Dla każdej umowy wyświetl:

- ID umowy,
- imię i nazwisko kursanta,
- nazwę kursu,
- cenę kursu.

Wymagania:

- użyj kursora jawnego,
- użyj `OPEN`,
- użyj `FETCH`,
- użyj `EXIT WHEN ...%NOTFOUND`,
- użyj `CLOSE`.

Przykład wyniku:

```text
Umowa 1 | Jan Kowalski | Oracle | 1200 zł
```

---

# Zadanie 9. Raport umów ze Szczecina

Napisz procedurę:

```sql
raport_umow_szczecin
```

Procedura ma wypisać szczegółowy raport umów z miasta `SZCZECIN`.

Dane o umowach są w siedzibie, ale dane kursantów i kursów pochodzą z filii.

Możesz użyć:

- migawek danych filii, np. `mv_kursanci_filia`,
- albo database linka, np. `kursanci@filia`.

Raport powinien zawierać:

- ID umowy,
- imię i nazwisko kursanta,
- nazwę kursu,
- cenę kursu,
- miasto.

Przykład wyniku:

```text
Umowa 101 | Adam Nowicki | Python | 1000 zł | SZCZECIN
```

---

# Zadanie 10. Raport całej uczelni

Napisz procedurę:

```sql
raport_uczelni
```

Procedura ma wygenerować zbiorczy raport dla całej uczelni.

Raport powinien zawierać dane osobno dla:

- `BYDGOSZCZ`,
- `SZCZECIN`.

Dla każdego miasta wypisz:

- liczbę umów,
- łączną wartość umów,
- najdroższy kurs,
- najpopularniejszy kurs.

Na końcu wypisz podsumowanie:

- liczba wszystkich umów,
- łączna wartość wszystkich umów.

Przykład struktury wyniku:

```text
RAPORT UCZELNI

Miasto: BYDGOSZCZ
Liczba umów: ...
Łączna wartość umów: ...
Najdroższy kurs: ...
Najpopularniejszy kurs: ...

Miasto: SZCZECIN
Liczba umów: ...
Łączna wartość umów: ...
Najdroższy kurs: ...
Najpopularniejszy kurs: ...

PODSUMOWANIE
Liczba wszystkich umów: ...
Łączna wartość wszystkich umów: ...
```

Wymagania:

- dla Bydgoszczy korzystaj z danych lokalnych,
- dla Szczecina korzystaj z danych filii przez migawki albo database link,
- użyj procedury,
- użyj zmiennych,
- użyj zapytań agregujących.

Wariant ambitniejszy:

Zamiast tylko wypisywać raport przez `DBMS_OUTPUT`, utwórz tabelę `raporty_uczelni` i zapisuj do niej wyniki.
