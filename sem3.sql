-- varsta < 18 este evaluata ca NULL si merge pe ramura else
DECLARE
    varsta NUMBER;
BEGIN
    IF varsta < 18
        THEN DBMS_OUTPUT.PUT_LINE('Copil');
        ELSE DBMS_OUTPUT.PUT_LINE('Adult');
    END IF;
END;


DECLARE
    v_angajat_id NUMBER;
    v_nume angajati.nume%TYPE;
    v_numar_comenzi NUMBER;
    v_salariu NUMBER;
BEGIN
    v_angajat_id := &id;

    SELECT nume, salariul INTO v_nume, v_salariu
    FROM angajati
    WHERE id_angajat = v_angajat_id;

    DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume);
    DBMS_OUTPUT.PUT_LINE('Salariu initial: ' || v_salariu);

    SELECT COUNT(id_comanda) INTO v_numar_comenzi
    FROM comenzi WHERE id_angajat = v_angajat_id;

    DBMS_OUTPUT.PUT_LINE('Numar comenzi intermediate: ' || v_numar_comenzi);

    IF v_numar_comenzi BETWEEN 3 AND 7 THEN
        v_salariu := v_salariu * 1.1; 
    ELSIF v_numar_comenzi > 7 THEN
        v_salariu := v_salariu * 1.2; 
    END IF;

    -- CASE
        -- WHEN v_numar_comenzi BETWEEN 3 AND 7 THEN v_salariu := v_salariu * 1.1;
        -- WHEN v_numar_comenzi > 7 THEN v_salariu := v_salariu * 1.2;
        -- ELSE NULL;
    -- END CASE;

    UPDATE angajati
    SET salariul = v_salariu
    WHERE id_angajat = v_angajat_id;

    DBMS_OUTPUT.PUT_LINE('Salariu nou: ' || v_salariu);
END;

--  2. Într-un bloc PL/SQL să se parcurgă toți angajații cu id_angajat de la 100 la 120, afișând numele, salariul și vechimea.
DECLARE
    v_nume angajati.nume%TYPE;
    v_salariu angajati.salariul%TYPE;
    v_vechime NUMBER(4,2);
BEGIN
    FOR i IN 100 .. 120 LOOP
        SELECT nume, salariul, (SYSDATE - data_angajare) / 365 INTO v_nume, v_salariu, v_vechime
        FROM angajati
        WHERE id_angajat = i;

        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume);
        DBMS_OUTPUT.PUT_LINE('Salariu: ' || v_salariu);
        DBMS_OUTPUT.PUT_LINE('Vechime: ' || v_vechime || ' years');
    END LOOP;
END;


-- 3. Într-un bloc PL/SQL să se parcurgă toți angajații, folosind pe rând structurile: FOR-LOOP, WHILE-LOOP, LOOP-EXIT WHEN
DECLARE
    v_nume angajati.nume%TYPE;
    v_salariu angajati.salariul%TYPE;
    v_vechime NUMBER(4,2);
    v_index NUMBER := 100;
BEGIN
    WHILE v_index <= 120 LOOP
        SELECT nume, salariul, (SYSDATE - data_angajare) / 365 INTO v_nume, v_salariu, v_vechime
        FROM angajati
        WHERE id_angajat = v_index;

        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume);
        DBMS_OUTPUT.PUT_LINE('Salariu: ' || v_salariu);
        DBMS_OUTPUT.PUT_LINE('Vechime: ' || v_vechime || ' years');
        
        v_index := v_index + 1;
    END LOOP;
END;

DECLARE
    v_nume angajati.nume%TYPE;
    v_salariu angajati.salariul%TYPE;
    v_vechime NUMBER(4,2);
    v_index NUMBER := 100;
BEGIN
    LOOP
        SELECT nume, salariul, (SYSDATE - data_angajare) / 365 INTO v_nume, v_salariu, v_vechime
        FROM angajati
        WHERE id_angajat = v_index;

        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume);
        DBMS_OUTPUT.PUT_LINE('Salariu: ' || v_salariu);
        DBMS_OUTPUT.PUT_LINE('Vechime: ' || v_vechime || ' years');
        
        v_index := v_index + 1;
        
        EXIT WHEN v_index = 120;
    END LOOP;
END;

-- 5. Parcurgerea tuturor angajatilor
DECLARE
    v_nume angajati.nume%TYPE;
    v_salariu angajati.salariul%TYPE;
    v_vechime NUMBER(4,2);
    v_min NUMBER;
    v_max NUMBER;
BEGIN
    SELECT MIN(id_angajat), MAX(id_angajat) INTO v_min, v_max
    FROM angajati;
    
    FOR i IN v_min .. v_max LOOP
        SELECT nume, salariul, (SYSDATE - data_angajare) / 365 INTO v_nume, v_salariu, v_vechime
        FROM angajati
        WHERE id_angajat = i;

        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume);
        DBMS_OUTPUT.PUT_LINE('Salariu: ' || v_salariu);
        DBMS_OUTPUT.PUT_LINE('Vechime: ' || v_vechime || ' years');
    END LOOP;
END;

-- 5.1 Parcurgerea tuturor angajatilor
DECLARE
    v_nume angajati.nume%TYPE;
    v_salariu angajati.salariul%TYPE;
    v_vechime NUMBER(4,2);
    v_min NUMBER;
    v_max NUMBER;
BEGIN
    SELECT MIN(id_angajat), MAX(id_angajat) INTO v_min, v_max
    FROM angajati;
    
    WHILE v_min <= v_max LOOP
        SELECT nume, salariul, (SYSDATE - data_angajare) / 365 INTO v_nume, v_salariu, v_vechime
        FROM angajati
        WHERE id_angajat = v_min;

        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume);
        DBMS_OUTPUT.PUT_LINE('Salariu: ' || v_salariu);
        DBMS_OUTPUT.PUT_LINE('Vechime: ' || v_vechime || ' years');
        
        v_min := v_min + 1;
    END LOOP;
END;

-- 5. Parcurgerea tuturor angajatilor
DECLARE
    v_nume angajati.nume%TYPE;
    v_salariu angajati.salariul%TYPE;
    v_vechime NUMBER(4,2);
    v_min NUMBER;
    v_max NUMBER;
BEGIN
    SELECT MIN(id_angajat), MAX(id_angajat) INTO v_min, v_max
    FROM angajati;
    
    LOOP
        SELECT nume, salariul, (SYSDATE - data_angajare) / 365 INTO v_nume, v_salariu, v_vechime
        FROM angajati
        WHERE id_angajat = v_min;

        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume);
        DBMS_OUTPUT.PUT_LINE('Salariu: ' || v_salariu);
        DBMS_OUTPUT.PUT_LINE('Vechime: ' || v_vechime || ' years');
        
        v_min := v_min + 1;
        
        EXIT WHEN v_min = v_max;
    END LOOP;
END;

-- 4. Printr-o comandă SQL simplă, să se șteargă angajatul cu id_angajat 150
DELETE FROM angajati WHERE id_angajat = 150;

-- 5. Printr-o comandă SQL simplă, să se afișeze numele utilizatorului curent și data sistemului (utilizând USER și SYSDATE)
SELECT USER AS "Nume Utilizator", SYSDATE as "Data" FROM DUAL;

DECLARE
    v_nume angajati.nume%TYPE;
    v_salariu angajati.salariul%TYPE;
    v_vechime NUMBER(4,2);
    v_nr NUMBER;
    v_min NUMBER;
    v_max NUMBER;
BEGIN
    SELECT MIN(id_angajat), MAX(id_angajat) INTO v_min, v_max
    FROM angajati;
    
    FOR i IN v_min .. v_max LOOP
        SELECT COUNT(id_angajat) INTO v_nr
        FROM angajati 
        WHERE id_angajat = i;
        
        IF v_nr = 0 THEN 
            DBMS_OUTPUT.PUT_LINE('Nu exista');
        
        ELSE
            SELECT nume, salariul, (SYSDATE - data_angajare) / 365 INTO v_nume, v_salariu, v_vechime
            FROM angajati
            WHERE id_angajat = i;

            DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume);
            DBMS_OUTPUT.PUT_LINE('Salariu: ' || v_salariu);
            DBMS_OUTPUT.PUT_LINE('Vechime: ' || v_vechime || ' years');
        
        END IF;
    END LOOP;
END;