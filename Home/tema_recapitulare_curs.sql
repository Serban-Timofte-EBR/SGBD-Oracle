SET SERVEROUTPUT ON;

CREATE OR REPLACE PACKAGE pac_pac AS
    PROCEDURE afiseaza_ang_din_departament (p_dep IN departamente.id_departament%TYPE, p_rezultat IN OUT SYS_REFCURSOR);
    PROCEDURE afiseaza_functii_anterioare (p_ang IN angajati.id_angajat%TYPE, p_rezultat IN OUT SYS_REFCURSOR);
    PROCEDURE modifica_salariu_angajat (p_ang IN angajati.id_angajat%TYPE, p_salariu_nou IN angajati.salariul%TYPE);
    PROCEDURE modifica_functie_angajat (p_ang IN angajati.id_angajat%TYPE, p_functie_noua IN angajati.id_functie%TYPE,
                                        p_salariu_nou  IN angajati.salariul%TYPE := NULL, p_dep_nou IN angajati.id_departament%TYPE := NULL );
END pac_pac;
/

CREATE OR REPLACE PACKAGE BODY pac_pac 
AS
    -- Returneaza toti angajatii din departamentul furnizat ca parametru
    PROCEDURE afiseaza_ang_din_departament (p_dep IN departamente.id_departament%TYPE, p_rezultat IN OUT SYS_REFCURSOR)
    IS
        v_counter NUMBER;
        
        e_dep_404 EXCEPTION;
    BEGIN
        SELECT COUNT(*) 
        INTO v_counter
        FROM departamente 
        WHERE id_departament = p_dep;
        
        IF v_counter = 0 THEN
            RAISE e_dep_404;
        END IF; 
        
        OPEN p_rezultat FOR
            SELECT *
            FROM angajati
            WHERE id_departament = p_dep;
            
    EXCEPTION
        WHEN e_dep_404 THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista departamentul cerut');
    END;
    
    -- returneaza toate functiile detinute de un angajat furnizat ca parametru (din istoric_functii)
    PROCEDURE afiseaza_functii_anterioare (p_ang IN angajati.id_angajat%TYPE, p_rezultat IN OUT SYS_REFCURSOR)
    IS
        v_counter NUMBER;
        v_counter2 NUMBER;
        
        e_ang_404 EXCEPTION;
        e_dep_gol EXCEPTION;
    BEGIN 
        SELECT COUNT(*) INTO v_counter
        FROM angajati
        WHERE id_angajat = p_ang;
        
        IF v_counter = 0 THEN
            RAISE e_ang_404;
        END IF;
        
        SELECT COUNT(*) INTO v_counter2
        FROM istoric_functii
        WHERE id_angajat = p_ang;
        
        IF v_counter2 = 0 THEN
            RAISE e_dep_gol;
        END IF;
        
        OPEN p_rezultat FOR
            SELECT * 
            FROM istoric_functii
            WHERE id_angajat = p_ang;
        
    EXCEPTION
        WHEN e_ang_404 THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cu ID: ' || p_ang);
        WHEN e_dep_gol THEN
            DBMS_OUTPUT.PUT_LINE('Angajatul nu si-a schimbat functia - ID: ' || p_ang);
    END afiseaza_functii_anterioare;
    
    -- Modifica salariul unui angajat furnizat ca parametru
    PROCEDURE modifica_salariu_angajat (p_ang IN angajati.id_angajat%TYPE, p_salariu_nou IN angajati.salariul%TYPE)
    IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Actualizam angajatul cu ID: ' || p_ang);
    
        UPDATE angajati
        SET salariul = p_salariu_nou
        WHERE id_angajat = p_ang;
        
        IF SQL%NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cu ID: ' || p_ang);
        END IF;
    END modifica_salariu_angajat;
    
    -- modifica functia unui angajat furnizat ca parametru
    PROCEDURE modifica_functie_angajat (p_ang IN angajati.id_angajat%TYPE, p_functie_noua IN angajati.id_functie%TYPE,
                                        p_salariu_nou  IN angajati.salariul%TYPE := NULL, p_dep_nou IN angajati.id_departament%TYPE := NULL )
    AS
        v_counter NUMBER;
        
        e_ang_404 EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_counter
        FROM angajati
        WHERE id_angajat = p_ang;
        
        IF v_counter = 0 THEN
            RAISE e_ang_404;
        END IF;
        
        INSERT INTO functii 
        VALUES (p_functie_noua, 'Functie noua', 1000, 99999);
        
        INSERT INTO departamente
        VALUES(p_dep_nou, 'Departament nou', 100, 1700);
        
        UPDATE angajati 
        SET id_functie = p_functie_noua,
            salariul = p_salariu_nou,
            id_departament = p_dep_nou
        WHERE id_angajat = p_ang;
        
    EXCEPTION
        WHEN e_ang_404 THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cu ID: ' || p_ang);
    END modifica_functie_angajat;
END pac_pac;
/


DECLARE
    v_cursor SYS_REFCURSOR;
    v_rec angajati%ROWTYPE;
    v_rec_istoric_functii istoric_functii%ROWTYPE;
BEGIN
    pac_pac.afiseaza_ang_din_departament(10, v_cursor);
    
    LOOP
        FETCH v_cursor INTO v_rec;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_rec.id_angajat || ' - NUME: ' || v_rec.nume );
    END LOOP;

    pac_pac.afiseaza_ang_din_departament(1, v_cursor);
    
    LOOP
        FETCH v_cursor INTO v_rec;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_rec.id_angajat || ' - NUME: ' || v_rec.nume );
    END LOOP;
    
    pac_pac.afiseaza_functii_anterioare(101, v_cursor);
    
    LOOP
        FETCH v_cursor INTO v_rec_istoric_functii;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('ID FUNCTIE: ' || v_rec_istoric_functii.id_functie);
    END LOOP;
    
    pac_pac.afiseaza_functii_anterioare(100, v_cursor);
    pac_pac.afiseaza_functii_anterioare(10, v_cursor);
    
    pac_pac.modifica_salariu_angajat(145, 10000);
    pac_pac.modifica_salariu_angajat(90, 10000);
    
    pac_pac.modifica_functie_angajat(189, 231, 3600, 231);
END;