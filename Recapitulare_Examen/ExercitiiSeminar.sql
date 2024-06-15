-- 1. Construiți un bloc PL/SQL prin care să se mărească salariul angajatului citit de la tastatură, urmând pașii:
-- se preiau informații despre angajatul respectiv
-- se incrementează cu 100 valoarea variabilei în care a fost memorat salariul
-- se modifica salariul angajatului
-- se preia salariul final, după modificare și se afișează

DECLARE
    ang_id NUMBER := &id;
    angajat angajati%ROWTYPE;
    salariul_nou angajati.salariul%TYPE;
BEGIN 
    SELECT * INTO angajat
    FROM Angajati
    WHERE id_angajat = ang_id;
    
    angajat.salariul := angajat.salariul + 100;
    
    UPDATE Angajati
    SET salariul = angajat.salariul
    WHERE id_angajat = ang_id;
    
    SELECT salariul INTO salariul_nou
    FROM Angajati
    WHERE id_angajat = ang_id;
    
    DBMS_OUTPUT.PUT_LINE('Noul salariu este: ' || salariul_nou);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Angajatul nu exista!');
END;

-- 2. Construiți un bloc PL/SQL prin care să se adauge un produs nou în tabela Produse, astfel:
-- valoarea coloanei id_produs va fi calculată ca fiind maximul valorilor existente, incrementat cu 1
-- valorile coloanelor denumire_produs și descriere vor fi citite de la tastatură prin variabile de substituție
-- restul valorilor pot rămâne NULL

DECLARE 
    prod_id produse.id_produs%TYPE;
    
    denumire produse.denumire_produs%TYPE := '&denumire';
    descriere produse.descriere%TYPE := '&descriere';
    
BEGIN
    SELECT MAX(id_produs) + 1 INTO prod_id
    FROM produse;
    
    INSERT INTO Produse(id_produs, denumire_produs, descriere)
    VALUES (prod_id, denumire, descriere);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;

-- 1. Într-un bloc PL/SQL să se modifice salariul angajatului citit de la tastatură 
-- în funcție de numărul de comenzi pe care acesta le-a intermediat. Urmați pașii:
    -- inițial, se vor afișa numele și salariul angajatului citit de la tastatură
    -- se va calcula și se va afișa numărul de comenzi intermediate de angajatul respectiv
    -- în cazul în care acesta este între 3 și 7, salariul angajatului va crește cu 10%
    -- în cazul în care acesta este mai mare decât 7, salariul angajatului va crește cu 20%
    -- altfel, salariul angajatului rămâne nemodificat
    -- se va opera modificarea salariului la nivelul tabelei
    -- la final, se va afișa salariul nou al angajatului respectiv
    
CREATE OR REPLACE FUNCTION calculNrComenzi (ang_id IN comenzi.id_angajat%TYPE)
RETURN NUMBER
IS
    v_counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_counter
    FROM Comenzi
    WHERE id_angajat = ang_id;
    
    RETURN v_counter;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN -1;
END;
/

DECLARE
    ang_id angajati.id_angajat%TYPE := &id;
    
    v_nrComenzi NUMBER;
    angajat angajati%ROWTYPE;
    v_crestere NUMBER := 0;
    
BEGIN
    SELECT * INTO angajat
    FROM angajati
    WHERE id_angajat = ang_id;
    DBMS_OUTPUT.PUT_LINE('Angajat - Nume: ' || angajat.nume || ' - Salariul: ' || angajat.salariul);
    
    v_nrComenzi := calculNrComenzi(ang_id);
    DBMS_OUTPUT.PUT_LINE('Angajatul a intermediat: ' || v_nrComenzi || ' comenzi');
    
    CASE
        WHEN v_nrComenzi BETWEEN 3 AND 7 THEN v_crestere := 0.1;
        WHEN v_nrComenzi > 7 THEN v_crestere := 0.2;
    END CASE;
    
    angajat.salariul := angajat.salariul + angajat.salariul * v_crestere;
    
    UPDATE Angajati
    SET salariul = angajat.salariul
    WHERE id_angajat = ang_id;
    
    DBMS_OUTPUT.PUT_LINE('Noul salariu este: ' || angajat.salariul);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista un angajat cu ID: ' || ang_id);
END;

--  Printr-un bloc PL/SQL, să se atribuie comision angajaților din departamentul 
    -- al cărui id este citit de la tastatură. 
-- Să se afișeze numărul de modificări totale efectuate.

DECLARE
    dep_id departamente.id_departament%TYPE := &id;
    v_counter NUMBER;
    
    CURSOR angajati_departament(dep_id IN departamente.id_departament%TYPE) 
    IS 
        SELECT id_angajat FROM Angajati
        WHERE id_departament = dep_id;
BEGIN
    SELECT COUNT(*) INTO v_counter
    FROM Departamente
    WHERE id_departament = dep_id;
    
    IF v_counter = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu exista departamentul cerut');
    END IF;

    FOR ang IN angajati_departament(dep_id) LOOP
        UPDATE Angajati
        SET comision = 0.1
        WHERE id_angajat = ang.id_angajat;
    END LOOP;
END;

-- Construiți un bloc PL/SQL prin care să se afișeze informații despre angajații din orașul Toronto.
DECLARE
    CURSOR ang_toronto IS SELECT id_angajat, prenume, nume, email, telefon, salariul 
                            FROM angajati ang, departamente dep, locatii loc
                            WHERE ang.id_departament = dep.id_departament
                            AND dep.id_locatie = loc.id_locatie
                            AND LOWER(loc.oras) LIKE '%toronto%';
                            
    TYPE ang_detalii IS RECORD (
        id NUMBER,
        prenume VARCHAR2(50),
        nume VARCHAR2(50),
        email VARCHAR2(25),
        telefon VARCHAR2(20),
        salariul NUMBER
    );
    
    raport_angajat ang_detalii;
BEGIN
    OPEN ang_toronto;
    LOOP
        FETCH ang_toronto INTO raport_angajat;
        EXIT WHEN ang_toronto%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('ID: ' || raport_angajat.id);
        DBMS_OUTPUT.PUT_LINE('Prenume: ' || raport_angajat.prenume);
        DBMS_OUTPUT.PUT_LINE('Nume: ' || raport_angajat.nume);
        DBMS_OUTPUT.PUT_LINE('Email: ' || raport_angajat.email);
        DBMS_OUTPUT.PUT_LINE('Telefon: ' || raport_angajat.telefon);
        DBMS_OUTPUT.PUT_LINE('Salariu: ' || raport_angajat.salariul);
        DBMS_OUTPUT.PUT_LINE('-----------------------------');
    END LOOP;
    
    CLOSE ang_toronto;
END;

-- Construiți un bloc PL/SQL prin care să se afișeze primele 3 comenzi care au cele mai multe produse comandate.
DECLARE
    CURSOR top3_comenzi IS SELECT com.id_comanda, com.data, COUNT(rc.id_produs) As nrProduse
                            FROM comenzi com, rand_comenzi rc
                            WHERE com.id_comanda = rc.id_comanda
                            GROUP BY com.id_comanda, com.data
                            ORDER BY nrProduse DESC
                            FETCH FIRST 3 ROWS ONLY;
BEGIN
    FOR cm IN top3_comenzi LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || cm.id_comanda || ' Data: ' || cm.data
            || ' Numar Produse: ' || cm.nrProduse);
    END LOOP;
END;

-- Construiți un bloc PL/SQL prin care să se afișeze informații despre angajați, 
    -- precum și numărul de comenzi intermediate de fiecare.
    
CREATE OR REPLACE FUNCTION calculareNumarComenzi(ang_id IN NUMBER) 
RETURN NUMBER
IS
    v_counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_counter
    FROM comenzi
    WHERE id_angajat = ang_id;
    
    RETURN v_counter;
END;
/

DECLARE
    v_nrCom NUMBER;
    CURSOR angs IS SELECT * FROM angajati;
BEGIN
    FOR ang IN angs LOOP
        v_nrCom := calculareNumarComenzi(ang.id_angajat);
        DBMS_OUTPUT.PUT_LINE('ID: ' || ang.id_angajat || ' Nr. Com.: ' || v_nrCom);
    END LOOP;
END;

-- Construiți un bloc PL/SQL prin care să se afișeze, pentru fiecare departament, 
    -- valoarea totală a salariilor plătite angajaților.
    
DECLARE
    CURSOR salarii_dep IS SELECT id_departament, SUM(salariul) AS salTotal
                            FROM angajati
                            GROUP BY id_departament;
BEGIN
    FOR info IN salarii_dep LOOP
        DBMS_OUTPUT.PUT_LINE('ID Departament: ' || NVL(TO_CHAR(info.id_departament), 'Departamentul dubios din DB-ul meu cu id NULL') 
            || ' - salariul mediu: ' || info.salTotal );
    END LOOP;
END;


-- Construiți un bloc PL/SQL prin care să se afișeze informații despre angajați, 
    -- precum și numărul de comenzi intermediate de fiecare.
    
CREATE OR REPLACE FUNCTION calculareNumarComenzi(ang_id IN NUMBER) 
RETURN NUMBER
IS
    v_counter NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_counter
    FROM comenzi
    WHERE id_angajat = ang_id;
    
    RETURN v_counter;
END;
/

DECLARE
    v_nrCom NUMBER;
    CURSOR angs IS SELECT * FROM angajati;
BEGIN
    FOR ang IN angs LOOP
        v_nrCom := calculareNumarComenzi(ang.id_angajat);
        DBMS_OUTPUT.PUT_LINE('ID: ' || ang.id_angajat || ' Nr. Com.: ' || v_nrCom);
    END LOOP;
END;

-- Construiți un bloc PL/SQL prin care să se afișeze pentru fiecare departament (id și nume) 
    -- informații despre angajații aferenți (id, nume, salariu). 
-- Să se afișeze la nivelul fiecărui departament și salariul total plătit.

DECLARE
    CURSOR angajatiDinDep(dep_id IN NUMBER) IS
        SELECT * FROM Angajati
        WHERE id_departament = dep_id;
    
    CURSOR departs IS
        SELECT id_departament, denumire_departament
        FROM departamente;
    
    v_salariiDep NUMBER;
BEGIN
    FOR dep IN departs LOOP
        DBMS_OUTPUT.PUT_LINE(dep.denumire_departament);
        v_salariiDep := 0;
        FOR ang IN angajatiDinDep(dep.id_departament) LOOP
            DBMS_OUTPUT.PUT_LINE(CHR(9) || ang.prenume || ' ' || ang.nume);
            v_salariiDep := v_salariiDep + ang.salariul;
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('Total salarii ' || dep.denumire_departament || ': ' || v_salariiDep);
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    END LOOP;
END;

-- Creaţi un bloc PL/SQL pentru a selecta codul și data de încheiere a comenzilor încheiate 
-- într-un an introdus de la tastatură (prin comandă SELECT simplă, fără să utilizați un cursor explicit).
DECLARE
    year NUMBER := &year;
    v_id NUMBER;
    dataS DATE;
BEGIN
    SELECT id_comanda, data INTO v_id, dataS
    FROM comenzi
    WHERE EXTRACT(YEAR FROM data) = year;
    
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ' - Data: ' || dataS);
    
EXCEPTION
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Atenţie! In anul ' || year || ' s-au încheiat mai multe comenzi!');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Atenţie! In anul ' || year || ' nu s-au încheiat comenzi!');
END;

-- Creaţi un bloc PL/SQL prin care se dublează preţul produsului (pret_lista) al cărui cod este 
-- citit de la tastatură. În cazul în care acesta nu există (comanda UPDATE nu realizează nicio modificare) 
-- se va invoca o excepție. Tratați excepția prin afișarea unui mesaj.

DECLARE
    prod_id NUMBER := &prodID;
    
    e_prod_404 EXCEPTION;
BEGIN
    UPDATE Produse
    SET pret_lista = pret_lista * 2
    WHERE id_produs = prod_id;
    
    IF SQL%NOTFOUND THEN
        RAISE e_prod_404;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Pretul a fost dublat!');
    
EXCEPTION
    WHEN e_prod_404 THEN
        DBMS_OUTPUT.PUT_LINE('Nu s-a efectuat nicio modificare');
END;

-- Într-un bloc PL/SQL citiți de la tastatură identificatorul unui produs. 
    -- Afișați denumirea produsului care are acel cod. De asemenea, calculați cantitatea totală comandată 
    -- din acel produs.
-- afișați denumirea produsului;
-- dacă produsul nu există, tratați excepția cu o rutină de tratare corespunzătoare;
-- dacă produsul nu a fost comandat, invocați o excepție, care se va trata corespunzător;
-- dacă produsul există și a fost comandat, afișați cantitatea totală comandată;
-- tratați orice altă excepție cu o rutină de tratare corespunzătoare.

CREATE OR REPLACE FUNCTION calculCantitatea(prodID IN NUMBER)
RETURN NUMBER
IS
    v_cantitatea NUMBER := 0;
BEGIN
    SELECT COUNT(cantitate) INTO v_cantitatea
    FROM rand_comenzi
    WHERE id_produs = prodID;
    
    RETURN v_cantitatea;
END;
/

DECLARE
    prodID NUMBER := &id;
    
    prod_den produse.denumire_produs%TYPE;
    v_cantitatea NUMBER;
    
    e_comanda_404 EXCEPTION;
BEGIN
    SELECT denumire_produs INTO prod_den
    FROM produse
    WHERE id_produs = prodID;
    
    DBMS_OUTPUT.PUT_LINE('Denumirea produsului: ' || prod_den);
    
    v_cantitatea := calculCantitatea(prodID);
    
    IF v_cantitatea = 0 THEN
        RAISE e_comanda_404;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Cantitatea: ' || v_cantitatea);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Produsul nu exista!');
    WHEN e_comanda_404 THEN
        DBMS_OUTPUT.PUT_LINE('Produsul nu a fost comandat');
END;

-- Într-un bloc PL/SQL utilizați un cursor parametrizat pentru a prelua numele, salariul și 
    -- vechimea angajaților dintr-un departament furnizat drept parametru.
-- deschideți cursorul prin indicarea ca parametru a unei variabile de substituție, 
    -- a cărei valoare să fie citită de la tastatură;
-- parcurgeți cursorul și afișați informațiile solicitate pentru acei angajați care fac 
    -- parte din departamentul indicat;
-- afișați numărul total de angajați parcurși;
-- în cazul în care nu există departamentul indicat, se va invoca o excepție, care se va trata corespunzător;
-- în cazul în care nu există angajați în departamentul indicat, se va invoca o excepție, 
    -- care se va trata corespunzător.
    
DECLARE
    CURSOR angajDepart (depID IN departamente.id_departament%TYPE) IS
        SELECT nume, salariul, ROUND((SYSDATE - data_angajare) / 365, 2) as vec
        FROM angajati
        WHERE id_departament = depID;
    
    idDep NUMBER := &idDep;
    
    v_counter NUMBER := 0;
    v_counter_dep NUMBER;
    depGol EXCEPTION;
    dep404 EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_counter_dep
    FROM departamente
    WHERE id_departament = idDep;
    
    IF v_counter_dep = 0 THEN
        RAISE dep404;
    END IF;

    FOR ang IN angajDepart(idDep) LOOP
        DBMS_OUTPUT.PUT_LINE('Nume: ' || ang.nume || ' Salariul: ' || ang.salariul || ' Vechime: ' || ang.vec);
        v_counter := v_counter + 1;
    END LOOP;
    
    IF v_counter = 0 THEN
        RAISE depGol;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Numar angajati: ' || v_counter);
    END IF;

EXCEPTION
    WHEN dep404 THEN
        DBMS_OUTPUT.PUT_LINE('Departamentul nu exista!');
    WHEN depGol THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajati in departamentul cerut!');
END;

--1. Intr-un bloc PL/SQL, folosind un cursor explicit, afisati informatii despre primii 5 salariati angajati 
-- (se va realiza filtrarea in functie de campul Data_Angajare).

DECLARE
    CURSOR angSortData IS 
        SELECT * FROM angajati
        ORDER BY data_angajare ASC
        FETCH FIRST 5 ROWS ONLY;
BEGIN
    FOR ang IN angSortData LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || ang.id_angajat || ' Nume: ' || ang.nume || 
        ' Data angajare: ' || ang.data_angajare);
    END LOOP;
END;


--2. Intr-un bloc PL/SQL, folosind un cursor explicit, selectati numele, functia, 
    -- data angajarii si vechimea salariatilor din tabela Angajati. 
--Parcurgeti fiecare rand al cursorului si, in cazul in care data angajarii depaseste 01-AUG-2016, 
    -- afisati informatiile preluate.
    
DECLARE
    CURSOR angs IS 
        SELECT ang.nume, fct.denumire_functie, ang.data_angajare, ROUND((SYSDATE - ang.data_angajare) / 365, 2) as vechime
        FROM angajati ang, functii fct
        WHERE ang.id_functie = fct.id_functie
        AND ang.data_angajare > TO_DATE('01-08-2016', 'DD-MM-YYYY');
        
    v_nume VARCHAR2(50);
    v_denFCT VARCHAR2(50);
    v_data DATE;
    v_vech NUMBER;
BEGIN
    OPEN angs;
    LOOP
        FETCH angs INTO v_nume, v_denFCT, v_data, v_vech;
        EXIT WHEN angs%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Nume: ' || v_nume || ' Functie: ' || v_denFCT ||
            ' Data: ' || v_data || ' Vechime: ' || v_vech);
            
    END LOOP;
END;

--3. Intr-un bloc PL/SQL, utilizand un cursor de tipul FOR-UPDATE, 
-- afisati numarul de comenzi intermediate de fiecare angajat si, 
-- in functie de acesta, modificati procentul comisionului primit, astfel:

	--daca numarul de comenzi date este mai mic de 6, atunci comisionul devine 0.6

	--daca numarul comenzilor este intre 6 si 10, atunci comisionul devine 0.7

	--altfel, comisionul devine 0.8
    
DECLARE
    CURSOR comAng IS 
        SELECT ang.id_angajat, comision, COUNT(com.id_angajat) as nrCom
        FROM angajati ang, comenzi com
        WHERE ang.id_angajat = com.id_angajat
        GROUP BY ang.id_angajat, comision;
        -- FOR UPDATE OF comision;
    
    v_comision NUMBER;
BEGIN
    FOR ang IN comAng LOOP
        DBMS_OUTPUT.PUT_LINE('ID: ' || ang.id_angajat || ' - Nr. com: ' || ang.nrCom);
        
        v_comision := 0;
        
        CASE
            WHEN ang.nrCom < 6 THEN v_comision := 0.6;
            WHEN ang.nrCom BETWEEN 6 AND 10 THEN v_comision := 0.7;
            ELSE v_comision := 0.8;
        END CASE;
        
        UPDATE angajati
        SET comision = v_comision
        WHERE id_angajat = ang.id_angajat;
        
    END LOOP;
END;

--4. Sa se construiasca un bloc PL/SQL prin care sa se dubleze salariul angajatilor care au incheiat 
    -- comenzi in anul 2009 si sa se pastreze numele lor intr-o tabela indexata. 
    -- Sa se afiseze valorile elementelor colectiei.
    
DECLARE
    CURSOR ang2009 IS 
        SELECT ang.id_angajat FROM angajati ang, comenzi com
        WHERE ang.id_angajat = com.id_angajat
        AND EXTRACT(YEAR FROM com.data) = 2009;
BEGIN
    FOR ang IN ang2009 LOOP
        UPDATE angajati
        SET salariul = salariul * 2
        WHERE id_angajat = ang.id_angajat;
        
        DBMS_OUTPUT.PUT_LINE('=> Update!');
    END LOOP;
END;


--5. Sa se construiasca un bloc PL/SQL prin care sa se calculeze si sa se memoreze intr-o tabela 
-- indexata salariul mediu al fiecarui departament. Afisati valorile elementelor colectiei.

DECLARE
    TYPE rec IS RECORD (
        denumire departamente.denumire_departament%TYPE,
        salMediu NUMBER
    );
    
    TYPE tip IS TABLE OF rec INDEX BY PLS_INTEGER;
    depSal tip;
BEGIN
    SELECT dep.denumire_departament, AVG(ang.salariul)
    BULK COLLECT INTO depSal
    FROM departamente dep, angajati ang
    WHERE dep.id_departament = ang.id_departament
    GROUP BY dep.denumire_departament;
    
    FOR i IN depSal.FIRST .. depSal.LAST LOOP
        DBMS_OUTPUT.PUT_LINE(depSal(i).denumire || '     -     ' || depSal(i).salMediu);
    END LOOP;
END;

-- Sa se construiasca un bloc PL/SQL prin care sa se calculeze si sa se memoreze 
-- intr-o tabela indexata: pentru fiecare client (nume_client) valoarea totala a comenzilor efectuate.
-- Sa se afiseze si numarul de elemente ale colectiei, dar si valorile elementelor acesteia.
DECLARE
    TYPE rec IS RECORD (
        nume angajati.nume%TYPE,
        valCom NUMBER
    );
    
    TYPE tip IS TABLE OF rec INDEX BY PLS_INTEGER;
    angValCom tip;
    
    CURSOR angVal IS 
        SELECT ang.nume, SUM(rc.pret * rc.cantitate) as val
        FROM angajati ang, comenzi com, rand_comenzi rc
        WHERE ang.id_angajat = com.id_angajat
        AND com.id_comanda = rc.id_comanda
        GROUP BY ang.nume;
BEGIN
    OPEN angVal;
    FETCH angVal BULK COLLECT INTO angValCom;
    CLOSE angVal;
    
    FOR i IN angValCom.FIRST .. angValCom.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Nume: ' || angValCom(i).nume || ' Valoarea comenzi: ' || angValCom(i).valCom);
    END LOOP;
END;

--1. Construiti functia Nume_complet care sa returneze numele complet al angajatului dat ca parametru. 
    -- Tratati cazul în care angajatul indicat nu exista. Apelati functia.
    
CREATE OR REPLACE FUNCTION Nume_complet (ang_id IN angajati.id_angajat%TYPE)
RETURN VARCHAR2
IS
    v_nume_complet VARCHAR2(50);
BEGIN
    SELECT nume || ' ' || prenume INTO v_nume_complet
    FROM angajati
    WHERE id_angajat = ang_id;
    
    RETURN v_nume_complet;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Nu exista angajatul cu ID: ' || ang_id;
END;
/

DECLARE
    nume VARCHAR2(50);
BEGIN
    nume := Nume_complet(115);
    DBMS_OUTPUT.PUT_LINE(nume);
    
    nume := Nume_complet(100);
    DBMS_OUTPUT.PUT_LINE(nume);
    
    nume := Nume_complet(50);
    DBMS_OUTPUT.PUT_LINE(nume);
END;


--2. Construiti procedura Dubleaza_salariu care sa dubleze salariul angajatilor din departamentul indicat 
-- drept parametru. Tratati cazurile în care departamentul indicat nu exista, 
-- dar si pe cel in care acesta exista, dar nu are angajati. Apelati procedura.

CREATE OR REPLACE PROCEDURE Dubleaza_salariu (dep_id IN angajati.id_departament%TYPE)
IS
    CURSOR angDep IS 
        SELECT * FROM angajati
        WHERE id_departament = dep_id;
    
    v_counter_angDep NUMBER := 0;
    v_flag NUMBER;
    
    dep404 EXCEPTION;
    depGol EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_flag
    FROM departamente
    WHERE id_departament = dep_id;
    
    IF v_flag = 0 THEN
        RAISE dep404;
    END IF;
    
    FOR ang in angDep LOOP
        UPDATE angajati
        SET salariul = salariul * 2
        WHERE id_angajat = ang.id_angajat;
        
        v_counter_angDep := v_counter_angDep + 1;
    END LOOP;
    
    IF v_counter_angDep = 0 THEN
        RAISE depGol;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Au fost actualizate ' || v_counter_angDep || ' salarii!');
    
EXCEPTION
    WHEN dep404 THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista departamentul cu ID: ' || dep_id);
    WHEN depGol THEN
        DBMS_OUTPUT.PUT_LINE('Departamentul nu are angajati!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/ 

BEGIN
    Dubleaza_salariu(70);
    Dubleaza_salariu(50);
    Dubleaza_salariu(1);
END;

--3. Construiti procedura Valoare_comenzi care sa calculeze si sa afiseze valoarea fiecarei comenzi 
-- (identificate prin id și data) încheiate într-un an indicat ca parametru de intrare. Apelati procedura.

CREATE OR REPLACE PROCEDURE Valoare_comenzi (year IN NUMBER)
IS
    CURSOR comenzi IS
        SELECT id_comanda, data FROM comenzi
        WHERE EXTRACT(YEAR FROM data) = year;
    
    valCom NUMBER;
    v_counter NUMBER := 0;
    
    com404 EXCEPTION;
BEGIN
    FOR com IN comenzi LOOP
        valCom := 0;
        
        SELECT SUM(pret * cantitate) INTO valCom
        FROM rand_comenzi
        WHERE id_comanda = com.id_comanda;
        
        DBMS_OUTPUT.PUT_LINE('ID: ' || com.id_comanda || ' - Data: ' || com.data
            || ' - Valoare: ' || valCom);
        DBMS_OUTPUT.PUT_LINE('');
        
        v_counter := v_counter + 1;
    END LOOP;
    
    IF v_counter = 0 THEN
        RAISE com404;
    END IF;
    
EXCEPTION
    WHEN com404 THEN
       DBMS_OUTPUT.PUT_LINE('Nu sunt comenzi plasate in acest an'); 
END;
/

BEGIN
    Valoare_comenzi(2009);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------');
    Valoare_comenzi(2020);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------');
    Valoare_comenzi(2025);
END;

--4. Construiti functia Calcul_vechime care sa returneze vechimea angajatului al carui id 
-- este dat ca parametru de intrare. Tratati cazul în care angajatul indicat nu exista.

CREATE OR REPLACE FUNCTION Calcul_vechimeRec(angID angajati.id_angajat%TYPE) 
RETURN NUMBER
IS
    v_vec NUMBER := 0;
BEGIN
    SELECT ROUND((SYSDATE - data_angajare) / 365, 2) INTO v_vec
    FROM angajati
    WHERE id_angajat = angID;
    
    RETURN v_vec;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

DECLARE
    vechime NUMBER;
BEGIN
    vechime := Calcul_vechimeRec(100);
    DBMS_OUTPUT.PUT_LINE(vechime);
    vechime := Calcul_vechimeRec(1);
    DBMS_OUTPUT.PUT_LINE(vechime);
END;

--4. Construiti functia Calcul_vechime care sa returneze vechimea angajatului al carui id 
-- este dat ca parametru de intrare. Tratati cazul în care angajatul indicat nu exista.

CREATE OR REPLACE FUNCTION Calcul_vechimeRec(angID angajati.id_angajat%TYPE) 
RETURN NUMBER
IS
    v_vec NUMBER := 0;
BEGIN
    SELECT ROUND((SYSDATE - data_angajare) / 365, 2) INTO v_vec
    FROM angajati
    WHERE id_angajat = angID;
    
    RETURN v_vec;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

DECLARE
    vechime NUMBER;
    CURSOR angs IS SELECT id_angajat FROM angajati;
BEGIN
    FOR ang IN angs LOOP
        vechime := Calcul_vechimeRec(ang.id_angajat);
        DBMS_OUTPUT.PUT_LINE('ID Angajat: ' || ang.id_angajat || ' - Vechime: ' || vechime);
    END LOOP;
END;

