-- --1. Intr-un bloc PL/SQL, folosind un cursor explicit, afisati informatii despre
-- primii 5 salariati angajati (se va realiza filtrarea in functie de campul Data_Angajare).

declare
    cursor c_salariati is
        SELECT ID_ANGAJAT, NUME, DATA_ANGAJARE from ANGAJATI
        order by DATA_ANGAJARE
        fetch first 5 rows only;
BEGIN
    for v_sal in c_salariati loop
        DBMS_OUTPUT.PUT_LINE('Salariatul : ' || v_sal.NUME || ' cu data angajare: ' || v_sal.DATA_ANGAJARE);
    end loop;
end;
/

declare
    cursor c_ang is SELECT a.NUME, f.DENUMIRE_FUNCTIE , a.DATA_ANGAJARE, ROUND((SYSDATE - a.DATA_ANGAJARE) / 365, 2) as Vechime
                    FROM ANGAJATI a, FUNCTII f
                    where a.ID_FUNCTIE = f.ID_FUNCTIE
                    order by a.DATA_ANGAJARE;
begin
    for v_ang in c_ang loop
        if v_ang.DATA_ANGAJARE > TO_DATE('2016-08-01', 'YYYY-MM-DD') then
            DBMS_OUTPUT.PUT_LINE('Angajatul ' || v_ang.NUME || ' are data de angajare ' || v_ang.DATA_ANGAJARE);
        end if;
    end loop;
end;
/

--3. Intr-un bloc PL/SQL, utilizand un cursor de tipul FOR-UPDATE, afisati numarul de comenzi
-- intermediate de fiecare angajat si, in functie de acesta, modificati procentul comisionului
-- primit, astfel:

	--daca numarul de comenzi date este mai mic de 6, atunci comisionul devine 0.6

	--daca numarul comenzilor este intre 6 si 10, atunci comisionul devine 0.7

	--altfel, comisionul devine 0.8

DECLARE
    cursor c_angajati is select ID_ANGAJAT, COMISION, COUNT(ID_COMANDA) as totalComenzi
                            from ANGAJATI join COMENZI using (id_angajat)
                            GROUP BY ID_ANGAJAT, COMISION;
    v_comision NUMBER;
begin
    for v_ang in c_angajati loop
        if v_ang.totalComenzi < 6 then
            v_comision := 0.6;
        elsif v_ang.totalComenzi < 10 then
            v_comision := 0.7;
        else
            v_comision := 0.8;
        end if;

        update ANGAJATI
        set COMISION = v_comision
        where ID_ANGAJAT = v_ang.ID_ANGAJAT;
     end loop;
end;
/

--4. Sa se construiasca un bloc PL/SQL prin care sa se dubleze salariul angajatilor care au
-- incheiat comenzi in anul 2009 si sa se pastreze numele lor intr-o tabela indexata.
-- Sa se afiseze valorile elementelor colectiei.

declare
    cursor c_ang is SELECT distinct ID_ANGAJAT
                        from ANGAJATI join COMENZI using (ID_ANGAJAT)
                        where extract(year from DATA) = 2009;
begin
    for v_ang in c_ang loop
        update ANGAJATI
        set SALARIUL = SALARIUL * 2
        where ID_ANGAJAT = v_ang.ID_ANGAJAT;
    end loop;
end;
/

declare
    TYPE tip is TABLE OF VARCHAR2(1200) INDEX BY PLS_INTEGER;
    t tip;
begin
    Update ANGAJATI
    set SALARIUL = SALARIUL * 2
    where ID_ANGAJAT in
          (select ID_ANGAJAT from COMENZI where extract(year from data) = 2009)
    Returning nume BULK COLLECT INTO t;

    for i in t.first .. t.LAST loop
        DBMS_OUTPUT.PUT_LINE(t(i));
    end loop;
end;
/

--6. Sa se construiasca un bloc PL/SQL prin care sa se calculeze si sa se memoreze
-- intr-o tabela indexata: pentru fiecare client (nume_client) valoarea totala a
-- comenzilor efectuate.

declare
    TYPE rec is RECORD
    (
        nume clienti.nume_client%TYPE,
        valTotal NUMBER
    );

    TYPE tip is TABLE OF rec index by pls_integer;
    t tip;
begin
    SELECT DISTINCT NUME_CLIENT, SUM(PRET*CANTITATE)
    BULK COLLECT into t
    FROM clienti join comenzi using (id_client)
                join RAND_COMENZI using (id_comanda)
    group by NUME_CLIENT;

    for i in t.first .. t.LAST loop
        DBMS_OUTPUT.PUT_LINE(t(i).nume || ' ' || t(i).valTotal);
    end loop;
end;
/