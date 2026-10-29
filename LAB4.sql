--cwiczenie 1

--zadanie 1A
INSERT INTO user_sdo_geom_metadata (table_name, column_name, diminfo, srid)
VALUES (
    'FIGURY',
    'KSZTALT',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 0, 10, 0.01),
        MDSYS.SDO_DIM_ELEMENT('Y', 0, 10, 0.01)
    ),
    NULL
);

COMMIT;

SELECT * FROM user_sdo_geom_metadata WHERE table_name = 'FIGURY';

--zadanie 1B
SELECT MDSYS.SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0)
FROM dual;

--zadanie 1C
CREATE INDEX figury_ind ON figury(ksztalt)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

--zadanie 1D
SELECT f.id
FROM figury f
WHERE SDO_FILTER(
    f.ksztalt,
    MDSYS.SDO_GEOMETRY(2001, NULL, MDSYS.SDO_POINT_TYPE(3,3,NULL), NULL, NULL)
) = 'TRUE';

-- SDO_FILTER sprawdza prostokaty otaczajace, wiec moze podac za duzo wynikow

--zadanie 1E
SELECT f.id
FROM figury f
WHERE SDO_RELATE(
    f.ksztalt,
    MDSYS.SDO_GEOMETRY(2001, NULL, MDSYS.SDO_POINT_TYPE(3,3,NULL), NULL, NULL),
    'mask=ANYINTERACT'
) = 'TRUE';


--cwiczenie 2

-- warstwy w Map View dodajemy przez SELECT * FROM nazwa_tabeli
-- sprawdz najpierw: DESC major_cities; DESC country_boundaries;
-- w ponizszych zapytaniach przyjeto kolumne geometrii GEOM

--zadanie 2A
SELECT m.city_name AS miasto,
       SDO_NN_DISTANCE(1) AS odl
FROM major_cities m,
     (SELECT geom FROM major_cities WHERE city_name = 'Warsaw') w
WHERE m.city_name <> 'Warsaw'
AND SDO_NN(m.geom, w.geom, 'sdo_num_res=10 unit=KM', 1) = 'TRUE'
ORDER BY odl
FETCH FIRST 9 ROWS ONLY;

--zadanie 2B
SELECT m.city_name AS miasto
FROM major_cities m,
     (SELECT geom FROM major_cities WHERE city_name = 'Warsaw') w
WHERE m.city_name <> 'Warsaw'
AND SDO_WITHIN_DISTANCE(m.geom, w.geom, 'distance=100 unit=KM') = 'TRUE';

--zadanie 2C
SELECT p.cntry_name AS kraj, m.city_name AS miasto
FROM country_boundaries p, major_cities m
WHERE p.cntry_name = 'Slovakia'
AND SDO_RELATE(m.geom, p.geom, 'mask=INSIDE+COVEREDBY') = 'TRUE';

--zadanie 2D
SELECT p.cntry_name AS panstwo,
       SDO_GEOM.SDO_DISTANCE(p.geom, pol.geom, 0.05, 'unit=KM') AS odl
FROM country_boundaries p,
     (SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland') pol
WHERE p.cntry_name <> 'Poland'
AND SDO_RELATE(p.geom, pol.geom, 'mask=ANYINTERACT') = 'FALSE'
ORDER BY odl;


--cwiczenie 3

--zadanie 3A
SELECT p.cntry_name,
       SDO_GEOM.SDO_LENGTH(
           SDO_GEOM.SDO_INTERSECTION(p.geom, pol.geom, 0.05),
           0.05, 'unit=KM'
       ) AS odleglosc
FROM country_boundaries p,
     (SELECT geom FROM country_boundaries WHERE cntry_name = 'Poland') pol
WHERE p.cntry_name <> 'Poland'
AND SDO_RELATE(p.geom, pol.geom, 'mask=TOUCH') = 'TRUE';

--zadanie 3B
SELECT cntry_name
FROM country_boundaries
ORDER BY SDO_GEOM.SDO_AREA(geom, 0.05, 'unit=SQ_KM') DESC
FETCH FIRST 1 ROW ONLY;

--zadanie 3C
SELECT SDO_GEOM.SDO_AREA(SDO_AGGR_MBR(m.geom), 0.05, 'unit=SQ_KM') AS sq_km
FROM major_cities m
WHERE m.city_name IN ('Warsaw', 'Lodz');

--zadanie 3D
SELECT g.ksztalt.sdo_gtype AS gtype
FROM (
    SELECT SDO_GEOM.SDO_UNION(p.geom, m.geom, 0.05) AS ksztalt
    FROM country_boundaries p, major_cities m
    WHERE p.cntry_name = 'Poland'
    AND m.city_name = 'Prague'
) g;

--zadanie 3E
SELECT miasto, kraj
FROM (
    SELECT m.city_name AS miasto,
           p.cntry_name AS kraj,
           ROW_NUMBER() OVER (
               ORDER BY SDO_GEOM.SDO_DISTANCE(
                   m.geom, SDO_GEOM.SDO_CENTROID(p.geom, 0.05), 0.05, 'unit=KM'
               )
           ) AS nr
    FROM major_cities m, country_boundaries p
    WHERE SDO_RELATE(m.geom, p.geom, 'mask=INSIDE+COVEREDBY') = 'TRUE'
)
WHERE nr = 1;

--zadanie 3F
SELECT r.name,
       SDO_GEOM.SDO_LENGTH(
           SDO_GEOM.SDO_INTERSECTION(r.geom, p.geom, 0.05),
           0.05, 'unit=KM'
       ) AS dlugosc
FROM rivers r, country_boundaries p
WHERE p.cntry_name = 'Poland'
AND SDO_RELATE(r.geom, p.geom, 'mask=ANYINTERACT') = 'TRUE';
