VAR b NUMBER;

DECLARE

v_nr NUMBER(5,2);
v_nr2 v_nr%TYPE;
v_data DATE := SYSDATE;
v_data2 TIMESTAMP := SYSTIMESTAMP;
v_text VARCHAR(20) := ':a';

BEGIN

v_nr := 123.456;
DBMS_OUTPUT.PUT_LINE(v_nr);

v_nr2 := TRUNC(v_nr) + 100;
DBMS_OUTPUT.PUT_LINE(v_nr2);

DBMS_OUTPUT.PUT_LINE(to_char(v_data, 'DD-MM-YYYY, HH:MM:SS'));

DBMS_OUTPUT.PUT_LINE(v_data2);

DBMS_OUTPUT.PUT_LINE(v_text);


:b := length(v_text);
DBMS_OUTPUT.PUT_LINE(:b);

END;

PRINT b;

SELECT * FROM angajati 
WHERE id_angajat = :b + 100;

DECLARE 

v_nume VARCHAR(20);
v_sal_total NUMBER NOT NULL := 0;
v_date NUMBER;
v_id angajati.id_angajat%TYPE := id; -- v_id are acelasi tip ca id_angajat si este initializat cu valoarea id

BEGIN

SELECT nume, salariul + salariul * NVL(comision,0), (sysdate - data_angajare) / 365
INTO v_nume, v_sal_total, v_date
FROM angajati
WHERE id_angajat = v_id;

DBMS_OUTPUT.PUT_LINE(v_nume || ' are venitul ' || v_sal_total || ' si vechimea ' || round(v_date, 2) || ' ani.');

END;