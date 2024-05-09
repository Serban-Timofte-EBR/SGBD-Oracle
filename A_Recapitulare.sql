-- 1) FUNCTII & PROCEDURI

-- Construiti functia Nume_complet care sa returneze numele complet al angajatului dat ca parametru. 
-- Tratati cazul în care angajatul indicat nu exista. Apelati functia.

CREATE OR REPLACE FUNCTION Nume_complet(p_id IN angajati.id_angajat%TYPE)
RETURN VARCHAR2
IS
    v_nume VARCHAR2(50);
BEGIN
    SELECT nume || ' ' || prenume INTO v_nume
    FROM angajati
    WHERE id_angajat = p_id;
    
    RETURN v_nume;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu id-ul ' || p_id);
        RETURN NULL;
END;
/

DECLARE
    v_nume_complet VARCHAR2(50);
BEGIN
    v_nume_complet := Nume_complet(1);
    DBMS_OUTPUT.PUT_LINE('Numele complet este: ' || v_nume_complet);
END;



-- Construiti procedura Dubleaza_salariu care sa dubleze salariul angajatilor din departamentul indicat drept parametru. 
-- Tratati cazurile în care departamentul indicat nu exista, dar si pe cel in care acesta exista, dar nu are angajati. Apelati procedura.

CREATE OR REPLACE PROCEDURE Dubleaza_salariu (p_id_dep IN departamente.id_departament%TYPE)
IS 
    v_exista_departament NUMBER;
    v_nr_angajati_dep NUMBER;
    
    e_dep_404 EXCEPTION;
    e_ang_0 EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_exista_departament
    FROM departamente
    WHERE id_departament = p_id_dep;
    
    IF v_exista_departament = 0 THEN
        RAISE e_dep_404;
    END IF;
    
    SELECT COUNT(*) INTO v_nr_angajati_dep
    FROM angajati
    WHERE id_departament = p_id_dep;
    
    IF v_nr_angajati_dep = 0 THEN
        RAISE e_ang_0;
    ELSE 
        UPDATE angajati
        SET salariul = salariul * 2
        WHERE id_departament = p_id_dep;
    END IF;
    
EXCEPTION
    WHEN e_dep_404 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista departamentul cerut');
    WHEN e_ang_0 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajati in depratamentul cerut');
END;
/
DECLARE
    CURSOR c_angajati_dep(id_dep departamente.id_departament%TYPE) IS
        SELECT salariul FROM angajati
        WHERE id_departament = id_dep;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Departamanetul 1: ');
    Dubleaza_salariul(1);
    
    DBMS_OUTPUT.PUT_LINE('Departamentul 120: ');
    Dubleaza_salariul(120);
    DBMS_OUTPUT.PUT_LINE('Depratamentul 60: ');
    DBMS_OUTPUT.PUT_LINE('Initial');
    FOR v_cursor IN c_angajati_dep(60) LOOP
        DBMS_OUTPUT.PUT_LINE(v_cursor.salariul);
    END LOOP;
    
    -- Dubleaza_salariul(60);
END;

-- Construiti procedura Valoare_comenzi care sa calculeze si sa afiseze valoarea fiecarei comenzi (identificate prin id și data) 
-- încheiate într-un an indicat ca parametru de intrare. Apelati procedura.

CREATE OR REPLACE PROCEDURE Valoare_comenzi(p_year IN NUMBER) 
IS
    CURSOR c_comenzi_an IS
        SELECT id_comanda, SUM(cantitate * pret) as valoarea
        FROM comenzi JOIN rand_comenzi USING (id_comanda)
        WHERE EXTRACT(YEAR FROM data) = p_year
        GROUP BY id_comanda;
    
    v_id comenzi.id_comanda%TYPE;
    v_val NUMBER;
    e_comenzi_0 EXCEPTION;
BEGIN
    OPEN c_comenzi_an;
    LOOP
        FETCH c_comenzi_an INTO v_id, v_val;
        EXIT WHEN c_comenzi_an%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Comanda ID: ' || v_id || ', Valoarea totala: ' || v_val);
    END LOOP;
    
    IF c_comenzi_an%ROWCOUNT = 0 THEN
        RAISE e_comenzi_0;
    END IF;
    
EXCEPTION
    WHEN e_comenzi_0 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista comenzi in anul ' || TO_CHAR(p_year));
END;
/

BEGIN
    Valoare_comenzi(2019);
    DBMS_OUTPUT.PUT_LINE(' ');
    Valoare_comenzi(2023);
END;


-- Construiti functia Calcul_vechime care sa returneze vechimea angajatului al carui id este dat ca parametru de intrare. 
-- Tratati cazul în care angajatul indicat nu exista.

CREATE OR REPLACE FUNCTION Calcul_vechime_functie(p_id angajati.id_angajat%TYPE) 
RETURN NUMBER
IS
    v_vechime NUMBER;
    v_angajati_counter NUMBER;
    
    e_ang_0 EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_angajati_counter
    FROM angajati
    WHERE id_angajat = p_id;
    
    IF v_angajati_counter = 0 THEN
        RAISE e_ang_0;
    END IF;
    
    SELECT ROUND((SYSDATE - data_angajare) / 365, 2) INTO v_vechime
    FROM angajati
    WHERE id_angajat = p_id;
    
    RETURN v_vechime;
    
EXCEPTION
    WHEN e_ang_0 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cu id-ul cerut ');
        RETURN NULL;
END;
/

        -- Apelati functia de mai sus în cadrul unei proceduri, Vechime_angajati, prin care se vor parcurge toti angajatii, 
        -- în scopul afisarii vechimii fiecaruia.

CREATE OR REPLACE PROCEDURE vechime_angajati_2 IS
    v_vechime NUMBER;
BEGIN
    FOR angajat IN (SELECT nume, id_angajat FROM angajati) LOOP
        v_vechime := Calcul_vechime_functie(angajat.id_angajat);
        DBMS_OUTPUT.PUT_LINE(angajat.nume || ': ' || v_vechime || ' ani');
    END LOOP;
END;
/

DECLARE 
    vechime NUMBER;
BEGIN
    vechime := Calcul_vechime_functie(1);
    DBMS_OUTPUT.PUT_LINE(vechime);
    
    vechime := Calcul_vechime_functie(100);
    DBMS_OUTPUT.PUT_LINE(vechime);
    
    DBMS_OUTPUT.PUT_LINE('Vechimea tuturor angajatilor');
    vechime_angajati_2;
END;


-- 2) Pachete 

-- 1. Construiti un pachet care sa contina:

-- o functie care returneaza numarul de comenzi încheiate de catre clientul al carui id este dat ca parametru. 
-- Tratati cazul în care nu exista clientul specificat;
-- o procedura care foloseste functia de mai sus pentru a returna primii 3 clienti cu cele mai multe comenzi încheiate.

-- Sa se apeleze procedura din cadrul pachetului.

CREATE OR REPLACE PACKAGE pachet1_sapt8 AS
    FUNCTION comenzi_client (p_id_client clienti.id_client%TYPE) RETURN NUMBER;
    PROCEDURE top_3_clienti;
END pachet1_sapt8;
/

CREATE OR REPLACE PACKAGE BODY pachet1_sapt8 AS
    FUNCTION comenzi_client (p_id_client clienti.id_client%TYPE) 
    RETURN NUMBER
    AS
        v_nr_comenzi NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_nr_comenzi
        FROM comenzi
        WHERE id_client = p_id_client;
        
        RETURN v_nr_comenzi;
    
    END comenzi_client;
    
    PROCEDURE top_3_clienti IS
        CURSOR c_clienti IS SELECT id_client 
                            FROM (SELECT id_client, comenzi_client(id_client) as nr
                                    FROM clienti
                                    ORDER BY nr DESC)
                            WHERE ROWNUM <= 3;
    BEGIN
        FOR v_client IN c_clienti LOOP
            DBMS_OUTPUT.PUT_LINE('Client ID: ' || v_client.id_client || ' Comenzi încheiate: ' || comenzi_client(v_client.id_client));
        END LOOP;
    END;
END pachet1_sapt8;
/

BEGIN
    pachet1_sapt8.top_3_clienti;
END;


-- Realizati un pachet de subprograme care sa contina:

-- o procedura  care sa adauge o înregistrare noua în tabela Functii. Informatiile ce trebuie adaugate sunt furnizate drept parametri procedurii. 
    -- Se trateaza cazul în care exista deja o functie cu codul introdus.
-- o  procedura care sa modifice denumirea unei functii. Codul functiei pentru care se face modificarea si noua denumire a functiei sunt parametrii 
    -- procedurii. Se trateaza cazul în care modificarea nu are loc din cauza precizarii unui cod care nu se regaseste în tabela.
-- o procedura care sa stearga o functie pe baza codului primit drept parametru. Se trateaza cazul în care codul furnizat nu exista.

-- Sa se apeleze subprogramele din cadrul pachetului.

CREATE OR REPLACE PACKAGE pachet2_sapt8 AS
    PROCEDURE adauga_functie (i_id_functie IN functii.id_functie%TYPE, denumire functii.denumire_functie%TYPE,
                                salariuMin IN functii.salariu_min%TYPE, salariuMax IN functii.salariu_max%TYPE);
    PROCEDURE modifica_den_functie (i_id_functie IN functii.id_functie%TYPE, denumireNoua functii.denumire_functie%TYPE);
    PROCEDURE sterge_functie (i_id_functie IN functii.id_functie%TYPE);
END pachet2_sapt8;
/

CREATE OR REPLACE PACKAGE BODY pachet2_sapt8 AS
    PROCEDURE adauga_functie (i_id_functie IN functii.id_functie%TYPE, denumire functii.denumire_functie%TYPE,
                                salariuMin IN functii.salariu_min%TYPE, salariuMax IN functii.salariu_max%TYPE) AS
        v_counter NUMBER;
        
        e_id_folosit EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_counter
        FROM FUNCTII
        WHERE id_functie = i_id_functie;
        
        IF v_counter > 0 THEN
            RAISE e_id_folosit;
        ELSE 
            INSERT INTO FUNCTII
            VALUES( i_id_functie, denumire, salariuMin, salariuMAx);
            
            DBMS_OUTPUT.PUT_LINE('Functie adaugata cu ID: ' || i_id_functie);
        END IF;
        
    EXCEPTION
        WHEN e_id_folosit THEN
            DBMS_OUTPUT.PUT_LINE('ID-ul este deja folosit!');
    END adauga_functie;
    
    PROCEDURE modifica_den_functie (i_id_functie IN functii.id_functie%TYPE, denumireNoua functii.denumire_functie%TYPE) AS
        v_counter NUMBER;
        
        e_id_404 EXCEPTION;
    BEGIN 
        SELECT COUNT(*) INTO v_counter
        FROM FUNCTII
        WHERE id_functie = i_id_functie;
        
        IF v_counter = 0 THEN
            RAISE e_id_404;
        ELSE 
            UPDATE FUNCTII
            SET denumire_functie = denumireNoua 
            WHERE id_functie = i_id_functie;
            
            DBMS_OUTPUT.PUT_LINE('Updated!');
        END IF;
        
    EXCEPTION
        WHEN e_id_404 THEN
            DBMS_OUTPUT.PUT_LINE('ID inexistent pentru update!');
    END modifica_den_functie;
    
    PROCEDURE sterge_functie (i_id_functie IN functii.id_functie%TYPE) AS
    v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM functii
      WHERE id_functie = i_id_functie;
    
      IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nu există o funcție cu ID ' || i_id_functie);
      ELSE
        DELETE FROM functii
        WHERE id_functie = i_id_functie;
    
        DBMS_OUTPUT.PUT_LINE('Funcția cu ID-ul ' || i_id_functie || ' a fost stearsa.');
      END IF;

    END sterge_functie;
END pachet2_sapt8;
/

BEGIN 
    pachet2_sapt8.adauga_functie(20, 'Lorem Ipsum', 1, 2);
    --pachet2_sapt8.modifica_den_functie(20, 'Lorem');
    --pachet2_sapt8.sterge_functie(20);
END;


-- Construiti un pachet care sa contina:

-- o procedura care returneaza numele, vechimea si venitul total (salariu + comision) pentru angajatul al carui id este dat ca parametru;
-- o procedura care mareste cu 2 salariul angajatului al carui id este dat ca parametru.
-- În ambele proceduri de mai sus, sa se verifice situatia în care angajatul indicat nu exista (invocând o exceptie în acest caz) 
    -- prin apelul unei functii private, creata în acest scop.

-- Sa se apeleze procedurile din cadrul pachetului.

CREATE OR REPLACE PACKAGE pachet3_sapt8 AS
    PROCEDURE detalii_angajat (id IN angajati.id_angajat%TYPE, v_nume OUT VARCHAR2, v_vechime OUT NUMBER, v_venit OUT NUMBER, v_valoarea_comenzi OUT NUMBER);
    PROCEDURE creste_salariul (id IN angajati.id_angajat%TYPE);
END pachet3_sapt8;
/

CREATE OR REPLACE PACKAGE BODY pachet3_sapt8 AS

    FUNCTION exista_angajat (id IN angajati.id_angajat%TYPE)
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
    END exista_angajat;
    
    
    
    FUNCTION calcul_vechime (id IN angajati.id_angajat%TYPE) 
    RETURN NUMBER
    IS
        v_vechime NUMBER;
    BEGIN
        SELECT ROUND((SYSDATE - data_angajare)/365, 2) as vechime
        INTO v_vechime
        FROM angajati
        WHERE id_angajat = id;
        
        RETURN v_vechime; 
    END calcul_vechime;
    
    
    
    FUNCTION calcul_valoare_comenzi (id IN angajati.id_angajat%TYPE) 
    RETURN NUMBER
    IS
        v_valoarea NUMBER;
    BEGIN
        SELECT SUM(rc.pret * rc.cantitate) as valoarea 
        INTO v_valoarea
        FROM rand_comenzi rc, comenzi com
        WHERE rc.id_comanda = com.id_comanda
        AND com.id_angajat = id;
        
        RETURN v_valoarea;
    END calcul_valoare_comenzi;



    PROCEDURE detalii_angajat (id IN angajati.id_angajat%TYPE, v_nume OUT VARCHAR2, v_vechime OUT NUMBER, v_venit OUT NUMBER, v_valoarea_comenzi OUT NUMBER) IS
        flag_ang BOOLEAN;
        
        e_ang_inexistent EXCEPTION;
    BEGIN
        flag_ang := exista_angajat(id);
        IF NOT flag_ang THEN
            RAISE e_ang_inexistent;
        ELSE 
            v_vechime := calcul_vechime(id);
            v_valoarea_comenzi := calcul_valoare_comenzi(id);
            
            SELECT CONCAT(nume, prenume) as nume_complet, salariul + comision * salariul as venit
            INTO v_nume, v_venit
            FROM angajati
            WHERE id_angajat = id;
        END IF;
    EXCEPTION
        WHEN e_ang_inexistent THEN
            DBMS_OUTPUT.PUT_LINE('Angajatul nu exista.');
    END detalii_angajat;
    
    PROCEDURE creste_salariul (id IN angajati.id_angajat%TYPE)
    IS
        flag_ang BOOLEAN;
        
        ang_404 EXCEPTION;
    BEGIN
        flag_ang := exista_angajat(id);
        
        IF NOT flag_ang THEN
            RAISE ang_404;
        ELSE 
            UPDATE angajati
            SET salariul = salariul + 2
            WHERE id_angajat = id;
            
            DBMS_OUTPUT.PUT_LINE('Salariul angajatului cu ID ' || id || ' a fost crescut.');
        END IF;
    EXCEPTION
        WHEN ang_404 THEN
            DBMS_OUTPUT.PUT_LINE('ID angajat invalid.');
    END creste_salariul;
    
END pachet3_sapt8;
/

DECLARE
    nume VARCHAR2(100);
    vechime NUMBER;
    venit NUMBER;
    valoarea NUMBER;
BEGIN
    pachet3_sapt8.detalii_angajat(100, nume, vechime, venit, valoarea);
    DBMS_OUTPUT.PUT_LINE('Nume: ' || nume || ', Vechime: ' || vechime || ', Venit: ' || venit || ', Valoarea: ' || valoarea);
    pachet3_sapt8.creste_salariul(1);
END;
/

-- Crearea unei noi functii 
CREATE OR REPLACE PROCEDURE new_job (
    p_job_id IN functii.id_functie%TYPE,
    p_denumire IN functii.denumire_functie%TYPE,
    p_sal_min IN functii.salariu_min%TYPE
) IS
BEGIN
    INSERT INTO FUNCTII 
    VALUES (p_job_id, p_denumire, p_sal_min, 2 * p_sal_min);
    COMMIT;
EXCEPTION 
    WHEN OTHERS THEN
        ROLLBACK;
END;
/

execute new_job('SY_ANAL', 'System Analyst', 6000);

-- Crearea unei noi functii 
CREATE OR REPLACE PROCEDURE new_job (
    p_job_id IN functii.id_functie%TYPE,
    p_denumire IN functii.denumire_functie%TYPE,
    p_sal_min IN functii.salariu_min%TYPE
) IS
BEGIN
    INSERT INTO FUNCTII 
    VALUES (p_job_id, p_denumire, p_sal_min, 2 * p_sal_min);
    COMMIT;
EXCEPTION 
    WHEN OTHERS THEN
        ROLLBACK;
END;
/

execute new_job('SY_ANAL', 'System Analyst', 6000);

SELECT * FROM functii;

CREATE OR REPLACE PROCEDURE add_job_hist(
    p_id_ang IN angajati.id_angajat%TYPE,
    p_new_id_function IN functii.id_functie%TYPE
) IS
    v_cur_ang angajati%ROWTYPE;
BEGIN
    SELECT * INTO v_cur_ang 
    FROM angajati
    WHERE id_angajat = p_id_ang;
    
    INSERT INTO istoric_functii
    VALUES (p_id_ang, v_cur_ang.data_angajare, SYSDATE, v_cur_ang.id_functie, v_cur_ang.id_departament);
    
    UPDATE angajati
    SET 
        data_angajare = SYSDATE,
        id_functie = p_new_id_function,
        salariul = (SELECT salariu_min FROM functii WHERE id_functie = p_new_id_function) + 500
    WHERE id_angajat = p_id_ang;
    COMMIT;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exista angajat cu ID-ul specificat.');
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('A aparut o eroare: ' || sqlerrm);
END;
/

SELECT
    *
FROM
    functii;
/

SELECT
    *
FROM
    istoric_functii;

SELECT
    *
FROM
    angajati
WHERE
    id_angajat = 106;
/

execute ADD_JOB_HIST(106, 20);


-- Sa se creeze un trigger, trg_pk_produs, asupra tabelei Produse, care sa adauge in campul cheie primara 
-- valoarea maxima existenta incrementata

CREATE OR REPLACE TRIGGER trg_pk_produs
BEFORE INSERT ON produse
FOR EACH ROW
DECLARE 
    new_id INT;
BEGIN
    SELECT MAX(id_produs) + 1 
    INTO new_id
    FROM produse;
    
    :NEW.id_produs := new_id;
END;
/

BEGIN
    INSERT INTO produse(denumire_produs, descriere, categorie, pret_lista, pret_min, stoc) 
    VALUES ('Nume Produs', 'Descriere Produs', 'Categorie Produs', 100, 90, 50);
END;

-- Sa se creeze un trigger, trg_update_prod_cascada, asupra tabelei Produse, prin care, 
-- la modificarea valorii id_produs din tabela parinte, aceasta sa se modifice automat si in 
-- inregistrarile corespondente din tabela copil

CREATE OR REPLACE TRIGGER trg_update_prod_cascada
AFTER UPDATE OF id_produs ON produse
FOR EACH ROW
BEGIN
    UPDATE rand_comenzi
    SET id_produs = :NEW.id_produs
    WHERE id_produs = :OLD.id_produs;
END;
/

BEGIN 
    UPDATE produse
    SET id_produs = 4000
    WHERE id_produs = 3106;
    --comanda 2380
END;

--Sa se creeze un declanşator, trg_stop_marire, care să împiedice mărirea salariului pentru 
-- angajații cu vechimea mai mare de 10 de ani

CREATE OR REPLACE TRIGGER trg_stop_marire
BEFORE UPDATE OF salariul ON angajati
FOR EACH ROW
WHEN (:OLD.data_angajare < ADD_MONTHS(SYSDATE, -120))
BEGIN
    IF :NEW.salariul > :OLD.salariul THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu se poate creste salariul angajatilor cu o vechime mai mare de 10 ani');
    END IF;
END;
/

BEGIN
    UPDATE angajati
    SET salariul = salariul + 1000
    WHERE id_angajat = 100;
END;

---Să se adauge în tabela Produse coloana Stoc. Să se introducă valoarea 2000 în coloana nou adăugată.
---Să se creeze un trigger, trg_verifica_stoc, care să nu permită comandarea unui produs în cantitate 
    -- mai mare decât stocul aferent.
---Totodată, pentru produsele comandate, prin trigger se va diminua stocul cu valoarea comandată.

CREATE OR REPLACE TRIGGER trg_verifica_stoc
BEFORE INSERT OR UPDATE OF cantitatea on rand_comenzi
FOR EACH ROW
DECLARE 
    v_stoc_disponibil NUMBER;
BEGIN
    SELECT stoc INTO v_stoc_disponibil
    FROM produse
    WHERE id_produs = :NEW.id_produs;
    
    IF :NEW.cantitatea > v_stoc_disponibil THEN
        RAISE_APPLICATION_ERROR(-20002, 'Cantitatea comandata este mai mare decat stocul disponibil.');
    ELSE
        IF INSERTING THEN
            UPDATE produse 
            SET stoc = stoc - :NEW.cantitatea
            WHERE id_produs = :NEW.id_produs;
        ELSIF UPDATING THEN
            UPDATE produse
            SET stoc = stoc + :OLD.cantitate - :NEW.cantitate
            WHERE id_produs = :NEW.id_produs;
        END IF;
    END IF;
END;
/

BEGIN
    INSERT INTO comenzi
    VALUES(1000, SYSDATE, 'online', 931, 4, 100);

    INSERT INTO rand_comenzi
    VALUES (1000, 3520, 44, 49);
END;

--Sa se creeze un declansator, trg_actualizeaza_istoric, prin care:
-- in momentul modificarii functiei unui angajat, se va adauga automat o noua inregistrare in tabela istoric_functii, astfel:
  ---daca angajatul nu si-a mai schimbat functia niciodata: data de inceput in functia schimbata va fi data angajarii, iar cea de sfarsit data curenta
  ---daca angajatul si-a mai schimbat functia: data de inceput pentru functia schimbata va fi ultima data de sfarsit pe o functie detinuta de angajatul in cauza
-- in momentul stergerii unui angajat, se vor sterge automat toate referirile la angajatul respectiv din tabela istoric_functii

CREATE OR REPLACE TRIGGER trg_actualizeaza_istoric
AFTER DELETE OR UPDATE ON angajati
FOR EACH ROW
DECLARE
    v_ultimul_sf DATE;
BEGIN
    IF UPDATING('ID_FUNCTIE') THEN
        SELECT MAX(data_sfarsit) INTO v_ultimul_sf
        FROM istoric_functii
        WHERE id_angajat = :OLD.id_angajat;
        
        IF v_ultimul_sf IS NULL THEN
            v_ultimul_sf := :OLD.data_angajare;
        END IF;
        
        INSERT INTO ISTORIC_FUNCTII
        VALUES (:OLD.id_angajat, v_ultimul_sf, SYSDATE, :OLD.id_functie, :OLD.id_departament);
    ELSIF DELETING THEN
        DELETE FROM ISTORIC_FUNCTII WHERE ID_ANGAJAT = :OLD.ID_ANGAJAT;
    END IF;
END;
/

UPDATE ANGAJATI
SET ID_FUNCTIE = 'IT_PROG'
WHERE ID_ANGAJAT = 101;

SELECT * FROM ISTORIC_FUNCTII WHERE ID_ANGAJAT = 101;

DELETE FROM ANGAJATI WHERE ID_ANGAJAT = 110;
