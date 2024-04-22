CREATE OR REPLACE PACKAGE gestionare_comenzi AS

  FUNCTION numar_comenzi(client_id IN CLIENTI.ID_CLIENT%TYPE) RETURN NUMBER;
  PROCEDURE top_clienti_comenzi;

END gestionare_comenzi;
/

CREATE OR REPLACE PACKAGE BODY gestionare_comenzi AS

  FUNCTION numar_comenzi(client_id IN CLIENTI.ID_CLIENT%TYPE) RETURN NUMBER IS
    numar_comenzi_incheiate NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO numar_comenzi_incheiate
    FROM COMENZI
    WHERE ID_CLIENT = client_id;

    RETURN numar_comenzi_incheiate;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN 0; 
  END numar_comenzi;

  PROCEDURE top_clienti_comenzi IS
    CURSOR cur_clienti IS
      SELECT ID_CLIENT
      FROM (SELECT ID_CLIENT, numar_comenzi(ID_CLIENT) AS nr_comenzi
            FROM CLIENTI
            ORDER BY nr_comenzi DESC)
      WHERE ROWNUM <= 3;
    client_rec cur_clienti%ROWTYPE;
  BEGIN
    OPEN cur_clienti;
    LOOP
      FETCH cur_clienti INTO client_rec;
      EXIT WHEN cur_clienti%NOTFOUND;
      
      DBMS_OUTPUT.PUT_LINE('Client ID: ' || client_rec.ID_CLIENT || 
                           ' Comenzi încheiate: ' || numar_comenzi(client_rec.ID_CLIENT));
    END LOOP;
    CLOSE cur_clienti;
  END top_clienti_comenzi;

END gestionare_comenzi;
/

BEGIN
  gestionare_comenzi.top_clienti_comenzi;
END;
/

-- 2. Realizati un pachet de subprograme care sa contina:
-- o procedura  care sa adauge o înregistrare noua în tabela Functii. 
--  Informatiile ce trebuie adaugate sunt furnizate drept parametri procedurii. 
--  Se trateaza cazul în care exista deja o functie cu codul introdus.
-- o  procedura care sa modifice denumirea unei functii. 
--  Codul functiei pentru care se face modificarea si noua denumire a functiei sunt 
--  parametrii procedurii. Se trateaza cazul în care modificarea nu are loc din cauza 
--  precizarii unui cod care nu se regaseste în tabela.
-- o procedura care sa stearga o functie pe baza codului primit drept parametru. 
--  Se trateaza cazul în care codul furnizat nu exista.
--  Sa se apeleze subprogramele din cadrul pachetului.

CREATE OR REPLACE PACKAGE cerinta2 AS

    PROCEDURE adaugare_functii( i_id_functie IN FUNCTII.id_functie%TYPE,
                                denumire IN FUNCTII.denumire_functie%TYPE,
                                sal_min IN FUNCTII.salariu_min%TYPE,
                                sal_max IN FUNCTII.salariu_max%TYPE );
    PROCEDURE modifica_functie ( i_id_functie IN FUNCTII.id_functie%TYPE,
                                denumire IN FUNCTII.denumire_functie%TYPE );
    PROCEDURE delete_function ( i_id_functie IN FUNCTII.id_functie%TYPE );
    
END cerinta2;
/

CREATE OR REPLACE PACKAGE BODY cerinta2 AS 

    PROCEDURE adaugare_functii( i_id_functie IN FUNCTII.id_functie%TYPE,
                                    denumire IN FUNCTII.denumire_functie%TYPE,
                                    sal_min IN FUNCTII.salariu_min%TYPE,
                                    sal_max IN FUNCTII.salariu_max%TYPE )
    IS
        v_counter NUMBER;
        already_function EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_counter
        FROM FUNCTII
        WHERE id_functie = i_id_functie;
        
        IF v_counter > 0 THEN
            RAISE already_function;
        END IF;
        
        INSERT INTO FUNCTII
        VALUES(i_id_functie, denumire, sal_min, sal_max);
        
        DBMS_OUTPUT.PUT_LINE('Functia a fost inserata cu ID: ' || i_id_functie);
        
    EXCEPTION
        WHEN already_function THEN
            DBMS_OUTPUT.PUT_LINE('Already in use function id ( ' || i_id_functie || ' )');
    END;
    
    PROCEDURE modifica_functie ( i_id_functie IN FUNCTII.id_functie%TYPE,
                                denumire IN FUNCTII.denumire_functie%TYPE )
    IS
    BEGIN 
        UPDATE FUNCTII 
        SET denumire_functie = denumire
        WHERE id_functie = i_id_functie;
        DBMS_OUTPUT.PUT_LINE ('Functia ' || i_id_functie || ' are denumirea ' || denumire);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ID invalid: ' || i_id_functie);
    END;
    
    PROCEDURE delete_function(i_id_functie IN FUNCTII.id_functie%TYPE) IS
      v_count NUMBER;
    BEGIN
      SELECT COUNT(*)
      INTO v_count
      FROM FUNCTII
      WHERE id_functie = i_id_functie;
    
      IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nu există o funcție cu ID ' || i_id_functie);
      ELSE
        DELETE FROM FUNCTII
        WHERE id_functie = i_id_functie;
    
        DBMS_OUTPUT.PUT_LINE('Funcția cu ID-ul ' || i_id_functie || ' a fost ștearsă.');
      END IF;

    END;
END cerinta2;
/

BEGIN
    -- cerinta2.adaugare_functii(20, 'Lorem Ipsum', 1, 2);
    -- cerinta2.modifica_functie(20, 'Lorem');
    -- cerinta2.delete_function(20);
    cerinta2.adaugare_functii('AC_MGR', 'Lorem Ipsum', 1, 2);
END;

-- 3. Construiti un pachet care sa contina:
-- o procedura care returneaza numele, vechimea si venitul total (salariu + comision) 
    -- pentru angajatul al carui id este dat ca parametru;
-- o procedura care mareste cu 2 salariul angajatului al carui id este dat ca parametru.
    -- În ambele proceduri de mai sus, sa se verifice situatia în care angajatul 
    -- indicat nu exista (invocând o exceptie în acest caz) prin apelul unei functii private, creata în acest scop.
-- Sa se apeleze procedurile din cadrul pachetului.

CREATE OR REPLACE PACKAGE cerinta3 AS
    
    PROCEDURE detalii_angajat(ang_id IN ANGAJATI.id_angajat%TYPE);
    PROCEDURE creste_salariul(ang_id IN ANGAJATI.id_angajat%TYPE);

END cerinta3;
/

CREATE OR REPLACE PACKAGE BODY cerinta3 AS 

    FUNCTION angajat_exista(ang_id IN ANGAJATI.id_angajat%TYPE) RETURN BOOLEAN IS
        v_counter NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_counter FROM ANGAJATI WHERE id_angajat = ang_id;
        RETURN v_counter > 0;
    END angajat_exista;
    
    FUNCTION valoare_comenzi(ang_id IN ANGAJATI.id_angajat%TYPE) RETURN NUMBER 
    IS
        v_valoare_comenzi NUMBER;
    BEGIN
        SELECT SUM(rc.pret * rc.cantitate) as valoare_comenzi
        INTO v_valoare_comenzi
        FROM COMENZI c, RAND_COMENZI rc, ANGAJATI a
        WHERE a.id_angajat = c.id_angajat
        AND c.id_comanda = rc.id_comanda
        AND a.id_angajat = ang_id;  
        
        IF v_valoare_comenzi > 0 THEN
            RETURN v_valoare_comenzi;
        ELSE 
            RETURN 0;
        END IF;
    END valoare_comenzi;

    PROCEDURE detalii_angajat(ang_id IN ANGAJATI.id_angajat%TYPE) IS
        v_nume ANGAJATI.nume%TYPE;
        v_vechime NUMBER;
        v_venit_total NUMBER;
        v_val NUMBER;
        invalid_ang EXCEPTION;
    BEGIN
        IF NOT angajat_exista(ang_id) THEN
            RAISE invalid_ang;
        END IF;
        
        v_val := valoare_comenzi(ang_id);
        
        SELECT nume, ROUND((SYSDATE - data_angajare)/365,2), 
              (salariul + NVL(comision, 0) * v_val)
        INTO v_nume, v_vechime, v_venit_total
        FROM ANGAJATI
        WHERE id_angajat = ang_id;

        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume || ', Vechime: ' || v_vechime || ' ani, Venit total: ' || v_venit_total || ' lei');
    EXCEPTION
        WHEN invalid_ang THEN
            DBMS_OUTPUT.PUT_LINE('ID angajat invalid.');
    END detalii_angajat;

    PROCEDURE creste_salariul(ang_id IN ANGAJATI.id_angajat%TYPE) IS
        invalid_ang EXCEPTION;
    BEGIN
        IF NOT angajat_exista(ang_id) THEN
            RAISE invalid_ang;
        END IF;

        UPDATE ANGAJATI
        SET salariul = salariul + 2
        WHERE id_angajat = ang_id;

        DBMS_OUTPUT.PUT_LINE('Salariul angajatului cu ID ' || ang_id || ' a fost crescut.');
    EXCEPTION
        WHEN invalid_ang THEN
            DBMS_OUTPUT.PUT_LINE('ID angajat invalid.');
    END creste_salariul;

END cerinta3;
/

BEGIN
    cerinta3.detalii_angajat(100);
    -- cerinta3.creste_salariul(100);
    -- cerinta3.detalii_angajat(10);
    -- cerinta3.creste_salariul(10);
END;