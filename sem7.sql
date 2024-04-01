set serveroutput on;

--1. Construiti functia Nume_complet care sa returneze numele complet al angajatului dat ca parametru. 
-- Tratati cazul în care angajatul indicat nu exista. Apelati functia.

create or replace function get_nume(p_id IN angajati.id_angajat%TYPE)
RETURN VARCHAR2
IS
    v_nume VARCHAR2(40);
BEGIN
    select nume || ' ' || prenume into v_nume
    from angajati
    where id_angajat = p_id;
    return v_nume;
EXCEPTION
    when NO_DATA_FOUND then 
        RETURN NULL;
END;
/

DECLARE
    v_nume VARCHAR2(40);
BEGIN
    v_nume := get_nume(100);
    if v_nume IS NULL then
        dbms_output.put_line('Angajatul nu exista');
    else 
        dbms_output.put_line(v_nume);
    end if;
END;
/

--2. Construiti procedura Dubleaza_salariu care sa dubleze salariul angajatilor din departamentul 
-- indicat drept parametru. Tratati cazurile în care departamentul indicat nu exista, dar si pe cel 
-- in care acesta exista, dar nu are angajati. Apelati procedura.

CREATE OR REPLACE PROCEDURE dubleaza_salariul (dep_id IN departamente.id_departament%TYPE)
IS
    v_exista_departament NUMBER;
    v_angajati NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_exista_departament
    FROM departamente
    WHERE id_departament = dep_id;
    
    IF v_exista_departament = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Departamentul specificat nu exista.');
    ELSE
        UPDATE angajati
        SET salariul = salariul * 2
        WHERE id_departament = dep_id
        RETURNING COUNT(*) INTO v_angajati;
        
        IF v_angajati = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Departamentul nu are angajati.');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_angajati || ' angajati au avut salariul dublat.');
        END IF;
    END IF;
END;
/

BEGIN
    dubleaza_salariul(130);
END;
/

--3. Construiti procedura Valoare_comenzi care sa calculeze si sa afiseze valoarea fiecarei comenzi 
--(identificate prin id și data) încheiate într-un an indicat ca parametru de intrare. Apelati procedura.

CREATE OR REPLACE PROCEDURE valoare_comenzi(c_year IN NUMBER)
IS
    CURSOR c_comenzi IS SELECT id_comanda, SUM(pret * cantitate) as val 
                        FROM comenzi JOIN rand_comenzi USING (id_comanda)
                        WHERE EXTRACT(YEAR FROM data) = c_year
                        GROUP BY id_comanda;
    
    v_id_comanda comenzi.id_comanda%TYPE;
    v_val_totala NUMBER;
    
BEGIN
    OPEN c_comenzi;
    LOOP
        FETCH c_comenzi INTO v_id_comanda, v_val_totala;
        EXIT WHEN c_comenzi%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Comanda ID: ' || v_id_comanda || ', Valoarea totala: ' || v_val_totala);
    END LOOP;
    
    IF c_comenzi%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista comenzi in anul ' || TO_CHAR(c_year));
    END IF;
END;
/

BEGIN
    valoare_comenzi(2020);
END;
/

--4. Construiti functia Calcul_vechime care sa returneze vechimea angajatului al carui id este dat 
-- ca parametru de intrare. Tratati cazul în care angajatul indicat nu exista.

CREATE OR REPLACE PROCEDURE calcul_vechime(ang_id IN angajati.id_angajat%TYPE)
IS
    v_vechime NUMBER;
BEGIN
    SELECT ROUND((SYSDATE - data_angajare) / 365,2) INTO v_vechime
    FROM angajati
    WHERE id_angajat = ang_id;
    
    DBMS_OUTPUT.PUT_LINE('Vechimea angajatului este: ' || v_vechime || ' ani.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu ID-ul specificat.');
END;
/

BEGIN
    calcul_vechime(100);
END;


--5. Apelati functia de mai sus în cadrul unei proceduri, Vechime_angajati, prin care 
-- se vor parcurge toti angajatii, în scopul afisarii vechimii fiecaruia.

CREATE OR REPLACE PROCEDURE calcul_vechime(ang_id IN angajati.id_angajat%TYPE)
IS
    v_vechime NUMBER;
BEGIN
    SELECT ROUND((SYSDATE - data_angajare) / 365,2) INTO v_vechime
    FROM angajati
    WHERE id_angajat = ang_id;
    
    DBMS_OUTPUT.PUT_LINE('Vechimea angajatului este: ' || v_vechime || ' ani.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu ID-ul specificat.');
END;
/


CREATE OR REPLACE PROCEDURE vechime_angajati IS
BEGIN
    FOR angajat IN (SELECT id_angajat FROM angajati)
    LOOP
        calcul_vechime(angajat.id_angajat);
    END LOOP;
END;
/

BEGIN
    vechime_angajati;
END;
