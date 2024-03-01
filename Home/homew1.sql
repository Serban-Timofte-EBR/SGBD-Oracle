set serveroutput on;
-- 1. Construiți un bloc PL/SQL prin care să se mărească salariul angajatului citit de la tastatură, urmând pașii:
-- se preiau informații despre angajatul respectiv
-- se incrementează cu 100 valoarea variabilei în care a fost memorat salariul
-- se modifica salariul angajatului
-- se preia salariul final, după modificare și se afișează

DECLARE
    ang_id angajati.id_angajat%TYPE := &id;
    ang_nume angajati.nume%TYPE;
    ang_salariu angajati.salariul%TYPE;
    ang_venit number;
BEGIN
    select nume, salariul, salariul + salariul * NVL(comision, 0)
    into ang_nume, ang_salariu, ang_venit
    from angajati
    where id_angajat = ang_id;
    
    dbms_output.put_line(ang_nume || ' are salariul ' || ang_salariu);
    
    update angajati
    set salariul = salariul + 100
    where id_angajat = ang_id;
    
    select nume, salariul, salariul + salariul * NVL(comision, 0)
    into ang_nume, ang_salariu, ang_venit
    from angajati
    where id_angajat = ang_id;
    
    dbms_output.put_line('Dupa update, ' || ang_nume || ' are salariul ' || ang_salariu);
END;

-- 2. Construiți un bloc PL/SQL prin care să se adauge un produs nou în tabela Produse, astfel:
-- valoarea coloanei id_produs va fi calculată ca fiind maximul valorilor existente, incrementat cu 1
-- valorile coloanelor denumire_produs și descriere vor fi citite de la tastatură prin variabile de substituție
-- restul valorilor pot rămâne NULL

DECLARE
    prod_id produse.id_produs%TYPE;
    prod_den produse.denumire_produs%TYPE := '&den';
    prod_des produse.descriere%TYPE := '&des';
    
    prod_den_check produse.denumire_produs%TYPE;
BEGIN
    select max(id_produs) + 1
    into prod_id
    from produse;
    
    dbms_output.put_line(prod_id);
    
    insert into produse(id_produs, denumire_produs, descriere)
    values(prod_id, prod_den, prod_des);
    
    select denumire_produs
    into prod_den_check
    from produse
    where id_produs =  prod_id;
    
    dbms_output.put_line('Noul produs este ' || prod_den_check);
    
END;