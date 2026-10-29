--zadanie 1
CREATE TABLE movies AS
SELECT * FROM ztpd.movies;

--zadanie 2
DESC movies;

--zadanie 3
SELECT id, title
FROM movies
WHERE cover IS NULL;

--zadanie 4
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE cover IS NOT NULL;

--zadanie 5
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE cover IS NULL;

--zadanie 6
SELECT directory_name, directory_path
FROM all_directories
WHERE directory_name = 'TPD_DIR';

--zadanie 7
UPDATE movies
SET cover = EMPTY_BLOB(), mime_type = 'image/jpeg'
WHERE id = 66;

COMMIT;

--zadanie 8
SELECT id, title, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE id IN (65,66);

--zadanie 9
DECLARE
    plik BFILE;
    obraz BLOB;
BEGIN
    plik := BFILENAME('TPD_DIR', 'escape.jpg');

    SELECT cover INTO obraz
    FROM movies
    WHERE id = 66
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(plik, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADFROMFILE(obraz, plik, DBMS_LOB.GETLENGTH(plik));
    DBMS_LOB.FILECLOSE(plik);
    COMMIT;
END;
/

--zadanie 10
CREATE TABLE temp_covers (
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

--zadanie 11
INSERT INTO temp_covers VALUES (
    65,
    BFILENAME('TPD_DIR', 'eagles.jpg'),
    'image/jpeg'
);

COMMIT;

--zadanie 12
SELECT movie_id, DBMS_LOB.GETLENGTH(image) AS filesize
FROM temp_covers;

--zadanie 13
DECLARE
    plik BFILE;
    obraz BLOB;
    typ_mime VARCHAR2(50);
BEGIN
    SELECT image, mime_type INTO plik, typ_mime
    FROM temp_covers
    WHERE movie_id = 65;

    DBMS_LOB.CREATETEMPORARY(obraz, TRUE);
    DBMS_LOB.FILEOPEN(plik, DBMS_LOB.FILE_READONLY);
    DBMS_LOB.LOADFROMFILE(obraz, plik, DBMS_LOB.GETLENGTH(plik));
    DBMS_LOB.FILECLOSE(plik);

    UPDATE movies
    SET cover = obraz, mime_type = typ_mime
    WHERE id = 65;

    DBMS_LOB.FREETEMPORARY(obraz);
    COMMIT;
END;
/

--zadanie 14
SELECT id AS movie_id, DBMS_LOB.GETLENGTH(cover) AS filesize
FROM movies
WHERE id IN (65,66);

--zadanie 15
DROP TABLE movies;

--zadanie 16
CREATE TABLE dokumenty (
    id NUMBER(12) PRIMARY KEY,
    dokument CLOB
);

--zadanie 17
DECLARE
    tekst CLOB;
BEGIN
    DBMS_LOB.CREATETEMPORARY(tekst, TRUE);

    FOR i IN 1..10000 LOOP
        DBMS_LOB.WRITEAPPEND(tekst, LENGTH('Oto tekst. '), 'Oto tekst. ');
    END LOOP;

    INSERT INTO dokumenty VALUES (1, tekst);
    DBMS_LOB.FREETEMPORARY(tekst);
    COMMIT;
END;
/

--zadanie 18
-- a
SELECT * FROM dokumenty;

-- b
SELECT id, UPPER(dokument) FROM dokumenty;

-- c
SELECT id, LENGTH(dokument) AS rozmiar FROM dokumenty;

-- d
SELECT id, DBMS_LOB.GETLENGTH(dokument) AS rozmiar FROM dokumenty;

-- e
SELECT id, SUBSTR(dokument, 5, 1000) AS fragment FROM dokumenty;

-- f
SELECT id, DBMS_LOB.SUBSTR(dokument, 1000, 5) AS fragment FROM dokumenty;

--zadanie 19
INSERT INTO dokumenty VALUES (2, EMPTY_CLOB());

--zadanie 20
INSERT INTO dokumenty VALUES (3, NULL);

COMMIT;

--zadanie 21
SELECT * FROM dokumenty;
SELECT id, UPPER(dokument) FROM dokumenty;
SELECT id, LENGTH(dokument) AS rozmiar FROM dokumenty;
SELECT id, DBMS_LOB.GETLENGTH(dokument) AS rozmiar FROM dokumenty;
SELECT id, SUBSTR(dokument, 5, 1000) AS fragment FROM dokumenty;
SELECT id, DBMS_LOB.SUBSTR(dokument, 1000, 5) AS fragment FROM dokumenty;

--zadanie 22
SET SERVEROUTPUT ON;

DECLARE
    plik BFILE;
    tekst CLOB;
    ile NUMBER;
    poz_plik INTEGER := 1;
    poz_tekst INTEGER := 1;
    jezyk INTEGER := 0;
    ostrzezenie INTEGER;
BEGIN
    plik := BFILENAME('TPD_DIR', 'dokument.txt');

    SELECT dokument INTO tekst
    FROM dokumenty
    WHERE id = 2
    FOR UPDATE;

    DBMS_LOB.FILEOPEN(plik, DBMS_LOB.FILE_READONLY);
    ile := DBMS_LOB.GETLENGTH(plik);

    DBMS_LOB.LOADCLOBFROMFILE(
        tekst, plik, ile, poz_tekst, poz_plik, 0, jezyk, ostrzezenie
    );

    DBMS_LOB.FILECLOSE(plik);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Status kopiowania: ' || ostrzezenie);
END;
/

--zadanie 23
UPDATE dokumenty
SET dokument = TO_CLOB(BFILENAME('TPD_DIR', 'dokument.txt'))
WHERE id = 3;

COMMIT;

--zadanie 24
SELECT * FROM dokumenty;

--zadanie 25
SELECT id, DBMS_LOB.GETLENGTH(dokument) AS rozmiar
FROM dokumenty;

--zadanie 26
DROP TABLE dokumenty;
