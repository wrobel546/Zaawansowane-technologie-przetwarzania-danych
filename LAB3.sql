--cwiczenie 1

--zadanie A
CREATE TABLE figury (
    id NUMBER(1) PRIMARY KEY,
    ksztalt MDSYS.SDO_GEOMETRY
);

--zadanie B

--figura 1 - kolo
INSERT INTO figury VALUES (
    1,
    MDSYS.SDO_GEOMETRY(
        2003,
        NULL,
        NULL,
        MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,4),
        MDSYS.SDO_ORDINATE_ARRAY(3,5, 5,7, 7,5)
    )
);

--figura 2 - prostokat
INSERT INTO figury VALUES (
    2,
    MDSYS.SDO_GEOMETRY(
        2003,
        NULL,
        NULL,
        MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3),
        MDSYS.SDO_ORDINATE_ARRAY(1,1, 5,5)
    )
);

--figura 3 - linia z lukiem
INSERT INTO figury VALUES (
    3,
    MDSYS.SDO_GEOMETRY(
        2002,
        NULL,
        NULL,
        MDSYS.SDO_ELEM_INFO_ARRAY(1,4,2, 1,2,1, 5,2,2),
        MDSYS.SDO_ORDINATE_ARRAY(3,2, 6,2, 7,3, 8,2, 7,1)
    )
);

SELECT * FROM figury;

--Map View: View -> Map View -> Add geometry layer
--nazwa warstwy: FIGURY
--zapytanie: SELECT * FROM figury
--etykieta: ID

--zadanie C
--zly wielokat - nie jest zamkniety
INSERT INTO figury VALUES (
    4,
    MDSYS.SDO_GEOMETRY(
        2003,
        NULL,
        NULL,
        MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,1),
        MDSYS.SDO_ORDINATE_ARRAY(6,6, 7,6, 7,7, 6,7)
    )
);

--zadanie D
SELECT id,
       SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005) AS val
FROM figury
ORDER BY id;

--zadanie E
DELETE FROM figury
WHERE SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005) <> 'TRUE';

SELECT id,
       SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt, 0.005) AS val
FROM figury
ORDER BY id;

--zadanie F
COMMIT;
