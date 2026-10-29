--zadanie 1
CREATE OR REPLACE TYPE samochod AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2)
);
/
CREATE TABLE samochody OF samochod;
INSERT INTO samochody VALUES (
    samochod('FIAT', 'BRAVA', 60000,
    TO_DATE('30-11-1999', 'DD-MM-YYYY'), 25000)
);
INSERT INTO samochody VALUES (
    samochod('FORD', 'MONDEO', 80000,
    TO_DATE('10-05-1997', 'DD-MM-YYYY'), 45000)
);
INSERT INTO samochody VALUES (
    samochod('MAZDA', '323', 12000,
    TO_DATE('22-09-2000', 'DD-MM-YYYY'), 52000)
);
COMMIT;
SELECT * FROM samochody;

--zadanie 2
ALTER TYPE samochod
ADD MEMBER FUNCTION wartosc RETURN NUMBER CASCADE;
CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek NUMBER;
    BEGIN
        wiek := TRUNC(MONTHS_BETWEEN(SYSDATE, data_produkcji)/12);
        RETURN GREATEST(0, cena * (1 - 0.1 * wiek));
    END wartosc;
END;
/
SELECT s.marka, s.cena, s.wartosc() AS wartosc FROM samochody s;

--zadanie 3
ALTER TYPE samochod
ADD MAP MEMBER FUNCTION porownaj RETURN NUMBER CASCADE;
CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
        wiek NUMBER;
    BEGIN
        wiek := TRUNC(MONTHS_BETWEEN(SYSDATE, data_produkcji)/12);
        RETURN GREATEST(0, cena * (1 - 0.1 * wiek));
    END wartosc;
    MAP MEMBER FUNCTION porownaj RETURN NUMBER IS
        wiek NUMBER;
    BEGIN
        wiek := TRUNC(MONTHS_BETWEEN(SYSDATE, data_produkcji)/12);
        RETURN wiek + kilometry/10000;
    END porownaj;
END;
/
SELECT * FROM samochody s ORDER BY VALUE(s);
SELECT s.marka, TRUNC(MONTHS_BETWEEN(SYSDATE,s.data_produkcji)/12) AS wiek,
       s.kilometry, s.porownaj() AS wiek_z_przebiegiem
FROM samochody s ORDER BY VALUE(s);

--zadanie 4
CREATE TABLE wlasciciele (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    auto samochod
);
INSERT INTO wlasciciele VALUES ('JAN','KOWALSKI',
    samochod('FIAT','SEICENTO',30000,TO_DATE('02-12-2001','DD-MM-YYYY'),19500));
INSERT INTO wlasciciele VALUES ('ADAM','NOWAK',
    samochod('OPEL','ASTRA',34000,TO_DATE('01-06-2009','DD-MM-YYYY'),33700));
COMMIT;
DESC wlasciciele;
SELECT w.imie,w.nazwisko,w.auto.marka AS marka,w.auto.model AS model,
       w.auto.kilometry AS kilometry,w.auto.data_produkcji AS data_produkcji,
       w.auto.cena AS cena
FROM wlasciciele w;

--zadanie 5
DROP TABLE wlasciciele;

--zadanie 6
CREATE OR REPLACE TYPE wlasciciel AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
);
/
CREATE TABLE wlasciciele OF wlasciciel;
INSERT INTO wlasciciele VALUES (wlasciciel('JAN','KOWALSKI'));
INSERT INTO wlasciciele VALUES (wlasciciel('ADAM','NOWAK'));
COMMIT;
SELECT * FROM wlasciciele;

--zadanie 7
ALTER TYPE samochod
ADD ATTRIBUTE (ref_wlasciciel REF wlasciciel)
CASCADE;
SELECT attr_name, attr_type_name, attr_type_mod
FROM user_type_attrs WHERE type_name = 'SAMOCHOD' ORDER BY attr_no;

--zadanie 8
DELETE FROM samochody;
COMMIT;
SELECT * FROM samochody;

--zadanie 9
ALTER TABLE samochody
ADD (SCOPE FOR (ref_wlasciciel) IS wlasciciele);

--zadanie 10
INSERT INTO samochody
SELECT samochod('FIAT','BRAVA',60000,TO_DATE('30-11-1999','DD-MM-YYYY'),25000,REF(w))
FROM wlasciciele w WHERE w.imie='JAN' AND w.nazwisko='KOWALSKI';
INSERT INTO samochody
SELECT samochod('FORD','MONDEO',80000,TO_DATE('10-05-1997','DD-MM-YYYY'),45000,REF(w))
FROM wlasciciele w WHERE w.imie='ADAM' AND w.nazwisko='NOWAK';
INSERT INTO samochody
SELECT samochod('MAZDA','323',12000,TO_DATE('22-09-2000','DD-MM-YYYY'),52000,REF(w))
FROM wlasciciele w WHERE w.imie='JAN' AND w.nazwisko='KOWALSKI';
COMMIT;
SELECT s.marka,s.model,s.kilometry,s.cena,w.imie,w.nazwisko
FROM samochody s JOIN wlasciciele w ON s.ref_wlasciciel=REF(w);

--zadanie 11
DECLARE
    TYPE t_przedmioty IS VARRAY(10) OF VARCHAR2(20);
    moje_przedmioty t_przedmioty := t_przedmioty();
BEGIN
    moje_przedmioty.EXTEND(3);
    moje_przedmioty(1):='MATEMATYKA';
    moje_przedmioty(2):='INFORMATYKA';
    moje_przedmioty(3):='BAZY DANYCH';
    DBMS_OUTPUT.PUT_LINE('Przed usunieciem:');
    FOR i IN 1..moje_przedmioty.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    moje_przedmioty.TRIM(1);
    DBMS_OUTPUT.PUT_LINE('Po TRIM:');
    FOR i IN 1..moje_przedmioty.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(moje_przedmioty(i));
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('LIMIT='||moje_przedmioty.LIMIT||', COUNT='||moje_przedmioty.COUNT);
    moje_przedmioty.DELETE();
    DBMS_OUTPUT.PUT_LINE('Po DELETE: COUNT='||moje_przedmioty.COUNT);
END;
/

--zadanie 12
DECLARE
    TYPE t_ksiazki IS VARRAY(10) OF VARCHAR2(100);
    ksiazki t_ksiazki := t_ksiazki('Hobbit','Wiedzmin','Lalka');
BEGIN
    ksiazki.EXTEND;
    ksiazki(4):='Pan Tadeusz';
    DBMS_OUTPUT.PUT_LINE('Po rozszerzeniu:');
    FOR i IN 1..ksiazki.COUNT LOOP DBMS_OUTPUT.PUT_LINE(ksiazki(i)); END LOOP;
    ksiazki.TRIM(1); -- usuwamy ostatni element (VARRAY)
    ksiazki.EXTEND;
    ksiazki(4):='Dziady';
    DBMS_OUTPUT.PUT_LINE('Po usunieciu i wstawieniu nowej:');
    FOR i IN 1..ksiazki.COUNT LOOP DBMS_OUTPUT.PUT_LINE(ksiazki(i)); END LOOP;
END;
/

--zadanie 13
DECLARE
    TYPE t_wykladowcy IS TABLE OF VARCHAR2(30);
    wykladowcy t_wykladowcy := t_wykladowcy('MORZY','WOJCIECHOWSKI');
BEGIN
    wykladowcy.EXTEND(3);
    wykladowcy(3):='WYKLADOWCA_3';
    wykladowcy(4):='WYKLADOWCA_4';
    wykladowcy(5):='WYKLADOWCA_5';
    wykladowcy.DELETE(3);
    wykladowcy(3):='ZAKRZEWICZ';
    DBMS_OUTPUT.PUT_LINE('Wykladowcy:');
    FOR i IN 1..wykladowcy.LAST LOOP
        IF wykladowcy.EXISTS(i) THEN DBMS_OUTPUT.PUT_LINE(i||': '||wykladowcy(i)); END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('COUNT='||wykladowcy.COUNT);
END;
/

--zadanie 14
DECLARE
    TYPE t_miesiace IS TABLE OF VARCHAR2(20);
    miesiace t_miesiace := t_miesiace(
        'STYCZEN','LUTY','MARZEC','KWIECIEN','MAJ','CZERWIEC',
        'LIPIEC','SIERPIEN','WRZESIEN','PAZDZIERNIK','LISTOPAD','GRUDZIEN');
BEGIN
    miesiace.DELETE(2);
    miesiace.DELETE(5);
    DBMS_OUTPUT.PUT_LINE('Miesiace po usunieciu LUTY i MAJ:');
    FOR i IN 1..miesiace.LAST LOOP
        IF miesiace.EXISTS(i) THEN DBMS_OUTPUT.PUT_LINE(miesiace(i)); END IF;
    END LOOP;
END;
/

--zadanie 15
--varray
CREATE OR REPLACE TYPE jezyki_obce AS VARRAY(10) OF VARCHAR2(20);
/
CREATE OR REPLACE TYPE stypendium AS OBJECT (
    nazwa VARCHAR2(50),
    kraj VARCHAR2(30),
    jezyki jezyki_obce
);
/
CREATE TABLE stypendia OF stypendium;
INSERT INTO stypendia VALUES
    (stypendium('SOKRATES','FRANCJA',jezyki_obce('ANGIELSKI','FRANCUSKI','NIEMIECKI')));
INSERT INTO stypendia VALUES
    (stypendium('ERASMUS','NIEMCY',jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI')));
SELECT * FROM stypendia;
SELECT s.nazwa,s.jezyki FROM stypendia s;
UPDATE stypendia s
SET s.jezyki=jezyki_obce('ANGIELSKI','NIEMIECKI','HISZPANSKI','FRANCUSKI')
WHERE s.nazwa='ERASMUS';
COMMIT;
SELECT * FROM stypendia;

--tabela zagniezdzona
CREATE OR REPLACE TYPE lista_egzaminow AS TABLE OF VARCHAR2(30);
/
CREATE OR REPLACE TYPE semestr AS OBJECT (
    numer NUMBER,
    egzaminy lista_egzaminow
);
/
CREATE TABLE semestry OF semestr
NESTED TABLE egzaminy STORE AS tab_egzaminy;
INSERT INTO semestry VALUES (semestr(1,lista_egzaminow('MATEMATYKA','LOGIKA','ALGEBRA')));
INSERT INTO semestry VALUES (semestr(2,lista_egzaminow('BAZY DANYCH','SYSTEMY OPERACYJNE')));
SELECT s.numer,e.COLUMN_VALUE AS egzamin FROM semestry s, TABLE(s.egzaminy) e;
INSERT INTO TABLE(SELECT s.egzaminy FROM semestry s WHERE s.numer=2)
VALUES ('METODY NUMERYCZNE');
UPDATE TABLE(SELECT s.egzaminy FROM semestry s WHERE s.numer=2) e
SET e.COLUMN_VALUE='SYSTEMY ROZPROSZONE'
WHERE e.COLUMN_VALUE='SYSTEMY OPERACYJNE';
DELETE FROM TABLE(SELECT s.egzaminy FROM semestry s WHERE s.numer=2) e
WHERE e.COLUMN_VALUE='BAZY DANYCH';
COMMIT;
SELECT s.numer,e.COLUMN_VALUE AS egzamin FROM semestry s, TABLE(s.egzaminy) e;

--zadanie 16
CREATE OR REPLACE TYPE koszyk_produktow AS TABLE OF VARCHAR2(50);
/
CREATE TABLE zakupy (
    id_zakupu NUMBER PRIMARY KEY,
    klient VARCHAR2(50),
    koszyk koszyk_produktow
) NESTED TABLE koszyk STORE AS tab_koszyk_produktow;
INSERT INTO zakupy VALUES (1,'JAN',koszyk_produktow('CHLEB','MLEKO','SER'));
INSERT INTO zakupy VALUES (2,'ADAM',koszyk_produktow('CHLEB','MASLO'));
INSERT INTO zakupy VALUES (3,'OLA',koszyk_produktow('RYZ','WODA'));
SELECT z.id_zakupu,z.klient,p.COLUMN_VALUE AS produkt
FROM zakupy z, TABLE(z.koszyk) p ORDER BY z.id_zakupu;
DELETE FROM zakupy z
WHERE EXISTS (SELECT 1 FROM TABLE(z.koszyk) p WHERE p.COLUMN_VALUE='MLEKO');
COMMIT;
SELECT z.id_zakupu,z.klient,p.COLUMN_VALUE AS produkt
FROM zakupy z, TABLE(z.koszyk) p ORDER BY z.id_zakupu;

--zadanie 17
CREATE OR REPLACE TYPE instrument AS OBJECT (
    nazwa VARCHAR2(20),
    dzwiek VARCHAR2(30),
    MEMBER FUNCTION graj RETURN VARCHAR2
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY instrument AS
    MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN RETURN dzwiek; END graj;
END;
/
CREATE OR REPLACE TYPE instrument_dety UNDER instrument (
    material VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2,
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY instrument_dety AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN RETURN 'dmucham: '||dzwiek; END graj;
    MEMBER FUNCTION graj(glosnosc VARCHAR2) RETURN VARCHAR2 IS
    BEGIN RETURN glosnosc||': '||dzwiek; END graj;
END;
/
CREATE OR REPLACE TYPE instrument_klawiszowy UNDER instrument (
    producent VARCHAR2(20),
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY instrument_klawiszowy AS
    OVERRIDING MEMBER FUNCTION graj RETURN VARCHAR2 IS
    BEGIN RETURN 'stukam w klawisze: '||dzwiek; END graj;
END;
/
DECLARE
    tamburyn instrument := instrument('tamburyn','brzdek-brzdek');
    trabka instrument_dety := instrument_dety('trabka','tra-ta-ta','metalowa');
    fortepian instrument_klawiszowy := instrument_klawiszowy('fortepian','ping-ping','steinway');
BEGIN
    DBMS_OUTPUT.PUT_LINE(tamburyn.graj());
    DBMS_OUTPUT.PUT_LINE(trabka.graj());
    DBMS_OUTPUT.PUT_LINE(trabka.graj('glosno'));
    DBMS_OUTPUT.PUT_LINE(fortepian.graj());
END;
/

--zadanie 18
CREATE OR REPLACE TYPE istota AS OBJECT (
    nazwa VARCHAR2(20),
    NOT INSTANTIABLE MEMBER FUNCTION poluj(ofiara VARCHAR2) RETURN VARCHAR2
) NOT INSTANTIABLE NOT FINAL;
/
CREATE OR REPLACE TYPE lew UNDER istota (
    liczba_nog NUMBER,
    OVERRIDING MEMBER FUNCTION poluj(ofiara VARCHAR2) RETURN VARCHAR2
);
/
CREATE OR REPLACE TYPE BODY lew AS
    OVERRIDING MEMBER FUNCTION poluj(ofiara VARCHAR2) RETURN VARCHAR2 IS
    BEGIN RETURN 'upolowana ofiara: '||ofiara; END poluj;
END;
/
DECLARE
    krol_lew lew := lew('LEW',4);
BEGIN
    DBMS_OUTPUT.PUT_LINE(krol_lew.poluj('antylopa'));
END;
/

--zadanie 19
DECLARE
    tamburyn instrument;
    cymbalki instrument;
    trabka instrument_dety;
    saksofon instrument_dety;
BEGIN
    tamburyn := instrument('tamburyn','brzdek-brzdek');
    cymbalki := instrument_dety('cymbalki','ding-ding','metalowe');
    trabka := instrument_dety('trabka','tra-ta-ta','metalowa');
    saksofon := instrument_dety('saksofon','tra-taaaa','mosiezny');
    DBMS_OUTPUT.PUT_LINE('Tamburyn: '||tamburyn.graj());
    DBMS_OUTPUT.PUT_LINE('Cymbalki jako INSTRUMENT: '||cymbalki.graj());
    DBMS_OUTPUT.PUT_LINE('Trabka: '||trabka.graj());
    DBMS_OUTPUT.PUT_LINE('Saksofon: '||saksofon.graj());
END;
/

--zadanie 20
CREATE TABLE instrumenty OF instrument;
INSERT INTO instrumenty VALUES (instrument('tamburyn','brzdek-brzdek'));
INSERT INTO instrumenty VALUES (instrument_dety('trabka','tra-ta-ta','metalowa'));
INSERT INTO instrumenty VALUES (instrument_klawiszowy('fortepian','ping-ping','steinway'));
COMMIT;
SELECT i.nazwa,i.graj() AS odglos FROM instrumenty i;