-- 2 tipuri de variabile:
--     -  locale in blocurile in PL/SQl
--     -  non - PL/SQL 
--             - globale (bind = de legatura)
--             - de substitutie

-- CHAR (10) - mereu se aloca 10B
-- VARCHAR2 (10) - se aloca cat se introduce, dar avem dimensiune maxima de 10B

-- IN BIG LINES: Preluam date cu interogari si le stochez in variabile

-- Atributul %TYPE -> pentru a prelua tipul de data dintr-o tabela -> ne asigura faptul ca putem stoca rezultatul unei interogari intr-o variabila
-- %TYPE NU PREIA RESTRICTIILE
-- CONSTANT -> trebuie initializata la declarare

-- Atributul %ROWTYPE
-- v_compusa produse%ROWTYPE
-- v_compusa va avea id_prod, den, pret ( considerand ca acestea sunt produse )

-- VAR NON PL
    -- Legaturi intre blocuri PL si alte instructiuni
    -- Definita in afara blocului
    -- :nume_var -> referinta var globale in cadrul unui bloc SQL
    
set serveroutput on

ACCEPT a PROMPT 'Introdu valoarea'  -- custom text in prompt

-- variabile globale (nu pune comentarii pe linia variabilei globale)
VAR b NUMBER    

--Bloc 1
-- putem folosi functii single row, dar NU de grup
DECLARE
    v_nr number(5,2) := 123.456;
    v_data date := sysdate;  
    v_data2 TIMESTAMP := systimestamp;
    
    --Sir de caractere citit de la tastarura
    v_text varchar2(20) := '&a';    --citeste de la tastatura prin var de substitutie
    
    
BEGIN
    dbms_output.put_line(v_nr);     -- cast by default TO CHAR
    dbms_output.put_line(to_char(v_data, 'DD-MM-YYYY, HH:Mi:SS'));  --to display to a specific model
    dbms_output.put_line(v_data2);
    dbms_output.put_line(v_text);
    dbms_output.put_line(LENGTH(v_text));
    
    --Stocam informatie in var globala
    :b := TRUNC(v_nr);
    dbms_output.put_line(:b);
END;

-- Trebuie selectata si rulata cu run script pentru a merge
SELECT * 
FROM angajati
WHERE id_angajat = :b;