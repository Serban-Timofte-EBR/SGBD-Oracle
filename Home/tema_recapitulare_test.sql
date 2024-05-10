--Construiţi un pachet PL/SQL care să conţină:

    --** o procedură, afiseaza_angajat, care afiseaza numele și venitul total (salariu + comision) pentru angajatul al cărui id este dat ca parametru;

    --** o functie, val_comenzi_angajat, care returneaza valoarea comenzilor intermediate de angajatul al cărui id este dat ca parametru;

    --** o procedură, vechime_angajat, care returneaza printr-un parametru de iesire vechimea pentru angajatul al cărui id este dat ca parametru de intrare;

    --** o procedură, mareste_salariu, care mărește cu 100 salariul angajatului al cărui email este dat ca parametru;

    --** o procedură, mareste_salariu, care mărește si retine intr-o variabila salariul angajatului al cărui id este dat ca parametru, astfel:

--- daca angajatul a intermediat comenzi cu valoare totala de mai putin de 10000 atunci salariul sau creste cu 11 lei;

--- daca angajatul a intermediat comenzi cu valoare totala de mai mult de 10000 atunci salariul sau creste cu 18 lei.  

--În toate subprogramele de mai sus, să se verifice situația în care angajatul indicat nu există (invocând o excepție în acest caz).

CREATE OR REPLACE PACKAGE recapitulare_test AS
    PROCEDURE afiseaza_angajat (id IN angajati.id_angajat%TYPE);
    FUNCTION val_comenzi_angajat (id IN angajati.id_angajat%TYPE) RETURN NUMBER;
    PROCEDURE vechime_angajat (id IN angajati.id_angajat%TYPE, v_vechime OUT NUMBER);
END recapitulare_test;
/

CREATE OR REPLACE PACKAGE BODY recapitulare_test AS
    FUNCTION check_id_ang(id IN angajati.id_angajat%TYPE)
    RETURN BOOLEAN
    IS
        v_counter NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_counter
        FROM angajati
        WHERE id_angajat = id;
        
        IF v_counter > 0 THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
    END check_id_ang;

    PROCEDURE afiseaza_angajat (id IN angajati.id_angajat%TYPE) 
    IS
        v_counter NUMBER;
        v_nume VARCHAR2(100);
        v_venit_total NUMBER;
        
        e_ang_404 EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_counter
        FROM angajati
        WHERE id_angajat = id;
    
        IF v_counter = 0 THEN
            RAISE e_ang_404;
        END IF;
    
        SELECT nume || ' ' || prenume as numecomplet, salariul + NVL(comision * salariul, 0) as venit
        INTO v_nume, v_venit_total
        FROM angajati
        WHERE id_angajat = id;
        
        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume || ' - Venit Total: ' || v_venit_total);
        
    EXCEPTION
        WHEN e_ang_404 THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu ID: ' || id);
    END afiseaza_angajat;
    
    FUNCTION val_comenzi_angajat (id IN angajati.id_angajat%TYPE)
    RETURN NUMBER
    IS
        v_counter NUMBER;
        
        v_valoarea_comenzi NUMBER;
        
        e_ang_404 EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_counter
        FROM angajati
        WHERE id_angajat = id;
        
        
    
        IF v_counter = 0 THEN
            RAISE e_ang_404;
        END IF;
        
        SELECT SUM(rc.pret * rc.cantitate)
        INTO v_valoarea_comenzi
        FROM rand_comenzi rc, comenzi c
        WHERE c.id_comanda = rc.id_comanda
        AND c.id_angajat = id;
        
        RETURN v_valoarea_comenzi;
    EXCEPTION
        WHEN e_ang_404 THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu ID: ' || id);
    END val_comenzi_angajat;
    
    PROCEDURE vechime_angajat (id IN angajati.id_angajat%TYPE, v_vechime OUT NUMBER)
    IS
        v_flag BOOLEAN;
        
        e_ang_404 EXCEPTION;
    BEGIN
        v_flag := check_id_ang(id);
        
        IF NOT v_flag THEN
            RAISE e_ang_404;
        END IF;
        
        SELECT ROUND((SYSDATE - data_angajare) / 365, 2) INTO v_vechime
        FROM angajati
        WHERE id_angajat = id;
        
    EXCEPTION
        WHEN e_ang_404 THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu ID: ' || id);
    END;
END recapitulare_test;
/

DECLARE
    v_val_com_145 NUMBER;
    
    v_vechime NUMBER;
BEGIN
    recapitulare_test.afiseaza_angajat(1);
    recapitulare_test.afiseaza_angajat(145);
    
    v_val_com_145 := recapitulare_test.val_comenzi_angajat(100);
    DBMS_OUTPUT.PUT_LINE('Valoarea comenzilor angajatului 100: ' || v_val_com_145);
    v_val_com_145 := recapitulare_test.val_comenzi_angajat(145);
    DBMS_OUTPUT.PUT_LINE('Valoarea comenzilor angajatului 145: ' || v_val_com_145);
    
    recapitulare_test.vechime_angajat(100, v_vechime);
    DBMS_OUTPUT.PUT_LINE('Vechimea angajatului 100: ' || v_vechime);
    recapitulare_test.vechime_angajat(145, v_vechime);
    DBMS_OUTPUT.PUT_LINE('Vechimea angajatului 145: ' || v_vechime);
    recapitulare_test.vechime_angajat(1, v_vechime);
END;