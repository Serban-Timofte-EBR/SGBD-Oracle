--Printr-un bloc PL/SQL, să se atribuie comision angajaților din departamentul al cărui id 
--este citit de la tastatură. Să se afișeze numărul de modificări totale efectuate.     => Cursor Implicit
set SERVEROUTPUT on

DECLARE
    v_id angajati.id_departament%TYPE := &id;
BEGIN 
    UPDATE angajati
    SET comision = 0.1
    WHERE id_departament = v_id;
    
    -- testam daca update nu a gasit nici o valaorea
    IF SQL%NOTFOUND THEN
        dbms_output.put_line('Nu s-au efectuat modificari');
    ELSE 
        dbms_output.put_line('S-au efectuat ' || SQL%ROWCOUNT || ' modificari');
    END IF;
END;

-- Construiți un bloc PL/SQL prin care să se afișeze informații despre angajații din orașul Toronto. 
-- => mai multe inregistrari => mai multi cursori

DECLARE
    CURSOR c_angajati_toronto IS SELECT id_angajat, nume
                                --FROM angajati a, departamente d, locatii l
                                --WHERE a.id_departament = d.id_departament
                                --AND d.id_locatie = l.id_locatie
                                FROM angajati JOIN departamente USING(id_departament)
                                    JOIN locatii USING(id_locatie)
                                WHERE lower(oras) LIKE '%toronto%';
    v_cursor c_angajati_toronto%ROWTYPE;   --are id_angajat, nume
BEGIN 
    OPEN c_angajati_toronto;    -- se deschidecursorul si se executa selectul
    
    LOOP
        FETCH c_angajati_toronto INTO v_cursor;
        EXIT WHEN c_angajati_toronto%NOTFOUND;
        dbms_output.put_line(v_cursor.nume);
    END LOOP;
    
    -- fara open si close
    -- FOR v_cursor IN c_angajati_toronto LOOP
    --    dbms_output.put_line(v_cursor.nume);
    -- END LOOP;
            
    CLOSE c_angajati_toronto; 
END;

-- Construiți un bloc PL/SQL prin care să se afișeze primele 3 comenzi care au cele mai multe produse comandate.
DECLARE
    CURSOR cursor_comenzi IS SELECT id_comanda, data, COUNT(id_produs) nr_produse
                             FROM comenzi JOIN rand_comenzi USING(id_comanda)
                             GROUP BY id_comanda, data
                             ORDER BY COUNT(id_produs) DESC
                             FETCH FIRST 3 ROWS ONLY;
    v_cursor cursor_comenzi%ROWTYPE;
BEGIN 
    FOR v_cursor IN cursor_comenzi LOOP
        dbms_output.put_line('Comanda ' || v_cursor.id_comanda || ' are ' || v_cursor.nr_produse || ' produse');
    END LOOP;
END;


-- Construiți un bloc PL/SQL prin care să se afișeze, pentru fiecare departament, 
-- valoarea totală a salariilor plătite angajaților.

DECLARE
    CURSOR c IS SELECT d.id_departament, SUM(a.salariul) salariulTotal
                FROM angajati a, departamente d
                WHERE a.id_departament = d.id_departament
                GROUP BY d.id_departament;
    v c%ROWTYPE;
BEGIN
    FOR v IN c LOOP
        dbms_output.put_line(v.id_departament || ' ' || v.salariulTotal);
    END LOOP;
END;

-- Construiți un bloc PL/SQL prin care să se afișeze informații despre angajați, 
-- precum și numărul de comenzi intermediate de fiecare.

DECLARE
    CURSOR c IS SELECT id_angajat, nume, COUNT(id_comanda) nr_com
                FROM angajati JOIN comenzi USING(id_angajat)
                GROUP BY id_angajat, nume;
    v c%ROWTYPE;
BEGIN 
    FOR v IN c LOOP
        dbms_output.put_line('NUME: ' || v.nume || ' are ' || v.nr_com || ' comenzi');
    END LOOP;
END;

-- Construiți un bloc PL/SQL prin care să se afișeze pentru fiecare departament (id și nume) 
-- informații despre angajații aferenți (id, nume, salariu). Să se afișeze la nivelul fiecărui departament 
-- și salariul total plătit.
DECLARE 
    CURSOR d IS SELECT id_departament, denumire_departament, SUM(salariul) salariulDep
                FROM departamente JOIN angajati USING(id_departament)
                WHERE id_departament IN (SELECT id_departament FROM angajati);
    
    CURSOR a (p NUMBER) IS SELECT id_angajat, nume, salariul FROM angajati
                           WHERE id_departament = p;

    suma NUMBER := 0;

BEGIN
    FOR v IN d LOOP
        dbms_output.put_line(v.id_departament || ' - ' || v.denumire_departament);
        FOR w in a (v.id_departament) LOOP
            dbms_output.put_line(w.id_angajat || ' - ' || w.nume);
            suma := suma + w.salariul;
        END LOOP;
        dbms_output.put_line('Salariul total: ' || suma);
    END LOOP;
END;