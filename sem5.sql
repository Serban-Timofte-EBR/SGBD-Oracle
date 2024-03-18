set serveroutput on;
-- Sa se afiseze informatii despre comenzile incheiate intr-un an citit de la tastatura
-- Fara cursori expliciti, chiar daca avem mai multe comenzi intr-un an
DECLARE 
    v_id comenzi.id_comanda%TYPE;
    v_data comenzi.data%TYPE;
    v_an NUMBER(4) := &an;
    
    prea_multe EXCEPTION;
    PRAGMA EXCEPTION_INIT(prea_multe, -01422);
BEGIN
    -- functioneaza daca am doar o comanda intr-un an
    select id_comanda, data
    into v_id, v_data
    from comenzi
    where extract(year from data) = v_an;
    
    dbms_output.put_line('Comanda: ' || v_id || ' ' || v_data);
EXCEPTION
    when NO_DATA_FOUND then 
        dbms_output.put_line('Nu exista comenzi in anul ' || v_an);
--    when TOO_MANY_ROWS then 
--        dbms_output.put_line('Prea multe comenzi in anul ' || v_an);
    when prea_multe then
        dbms_output.put_line('Prea multe comenzi in anul ' || v_an);
        for v in (select id_comanda, data
                  into v_id, v_data
                  from comenzi
                  where extract(year from data) = v_an
                  ) LOOP
            dbms_output.put_line('Comanda: ' || v_id || ' ' || v_data);
        end loop;
END;

-- Sa se dubleze pretul produselor al carui id este citit de la tastatura
DECLARE 
    v_id produse.id_produs%TYPE := &id;
    nu_exista_produsul EXCEPTION;
    
BEGIN
    update produse
    set pret_lista = pret_lista * 2
    where id_produs = v_id;
    
    --daca nu s-a facut un update
    if SQL%NOTFOUND THEN
        RAISE nu_exista_produsul;   --se opreste executia si se muta in exeption
    else
        dbms_output.put_line('S-a produs update-ul');

EXCEPTION
    when nu_exista_produsul then
        dbms_output.put_line('Nu exista produsul');

END;

-- Într-un bloc PL/SQL citiți de la tastatură identificatorul unui produs. 
-- Afișați denumirea produsului care are acel cod. De asemenea, calculați cantitatea 
-- totală comandată din acel produs.

DECLARE
    v_prod_id produse.id_produs%TYPE := &id;
    v_denumire produse.denumire_produs%TYPE;
    v_cantitate NUMBER;
    produs_necomandat EXCEPTION;
BEGIN
    select denumire_produs
    into v_denumire
    from produse 
    where id_produs = v_prod_id;
    
    dbms_output.put_line('Produs ' || v_denumire);
    
    select sum(cantitate)
    into v_cantitate
    from rand_comenzi
    where id_produs = v_prod_id;
    
    if v_cantitate is NULL then
        raise produs_necomandat;
    else 
        dbms_output.put_line('Cantitate ' || v_cantitate);
    end if;
    
EXCEPTION
    when NO_DATA_FOUND then
        dbms_output.put_line('Produsul nu exista');
    when produs_necomandat then
        dbms_output.put_line('Produsul nu a fost comandat');
    when OTHERS then
        dbms_output.put_line(SQLERRM);
END; 

-- 4. Într-un bloc PL/SQL utilizați un cursor parametrizat pentru a prelua numele, 
-- salariul și vechimea angajaților dintr-un departament furnizat drept parametru.
DECLARE
    v_id departamente.id_departament%TYPE := &id;
    v_counter NUMBER;
    CURSOR c_angajat (id_param angajati.id_departament%TYPE) is (
                        select nume, salariul, ROUND((SYSDATE - data_angajare) / 365, 2)
                        from angajati
                        where id_departament = id_param);
    v_cursor c_angajat%ROWTYPE;
    
    nu_exista_dep EXCEPTION;
    nu_are_angajati EXCEPTION;
BEGIN
    BEGIN
        select COUNT(id_departament) into v_counter
        from departamente where id_departament = v_id;
    
        if v_counter = 1 then
            open c_angajat(v_id);
    
            loop
                fetch c_angajat into v_cursor;
                exit when c_angajat%NOTFOUND;
                dbms_output.put_line('Angajat ' || v_cursor.nume);
            end loop;
            if c_angajat%ROWCOUNT = 0 then
                raise nu_are_angajati;
            end if;
            dbms_output.put_line('TOTAL: ' || c_angajat%ROWCOUNT);
            close c_angajat;
        else
            RAISE nu_exista_dep;
        end if;
    END;
EXCEPTION
    when nu_exista_dep then
        dbms_output.put_line('nu exista departamentul');
    when nu_are_angajati then
            dbms_output.put_line('nu exista departamentul cu angajati');

END;