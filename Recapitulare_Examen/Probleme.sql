-- Creează o funcție care primește ca parametru ID_CLIENT și returnează numele clientului 
-- (PRENUME_CLIENT și NUME_CLIENT concatenat) din tabelul CLIENTI
CREATE OR REPLACE FUNCTION getDenumireClient(p_id IN clienti.id_client%TYPE)
RETURN VARCHAR2
IS
    v_prenume clienti.prenume_client%TYPE;
    v_nume clienti.nume_client%TYPE;
BEGIN
    SELECT prenume_client, nume_client INTO v_prenume, v_nume
    FROM clienti
    WHERE id_client = p_id;
    
    RETURN v_prenume || ' ' || v_nume;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Nu exista clientul cu id-ul cerut';
END;
/

DECLARE
    v_nume VARCHAR2(50);
BEGIN
    v_nume := getDenumireClient(240);
    DBMS_OUTPUT.PUT_LINE(v_nume);
END;

-- Creează o procedură care actualizează SALARIU unui angajat identificat prin ID_ANGAJAT. 
-- Procedura ar trebui să includă tratarea excepțiilor pentru cazul în care ID_ANGAJAT nu există în tabelul ANGAJATI.

CREATE OR REPLACE PROCEDURE actualizareSalariul(p_id angajati.id_angajat%TYPE)
IS
    v_counter NUMBER;
    
    e_ang_404 EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_counter
    FROM angajati
    WHERE id_angajat = p_id;
    
    IF v_counter > 0 THEN
        UPDATE angajati
        SET salariul = salariul + 1000
        WHERE id_angajat = p_id;
    ELSE
        RAISE e_ang_404;
    END IF; 
        
EXCEPTION
    WHEN e_ang_404 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu ID-ul ' || p_id);
END;
/

BEGIN 
    actualizareSalariul(1);
    actualizareSalariul(117);
END;


-- Creează un cursor care selectează toate departamentele și calculează salariul mediu pentru fiecare departament.
SET SERVEROUTPUT ON;
DECLARE
    CURSOR departament_salariulMediu IS SELECT id_departament, ROUND(AVG(salariul), 2) as salMed
                                        FROM Angajati
                                        GROUP BY id_departament;
    v_denumire VARCHAR2(50);
BEGIN
    FOR info IN departament_salariulMediu LOOP
        IF info.id_departament > 0 THEN
            SELECT denumire_departament INTO v_denumire
            FROM departamente
            WHERE id_departament = info.id_departament;
            
            DBMS_OUTPUT.PUT_LINE('Departamentul: ' || v_denumire || ' are salariul mediu de ' || info.salMed);
        END IF;
    END LOOP;
END;

