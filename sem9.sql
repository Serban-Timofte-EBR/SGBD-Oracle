set serveroutput on
--1
CREATE OR REPLACE PROCEDURE new_job (
    p_id_functie       functii.id_functie%TYPE,
    p_denumire_functie functii.denumire_functie%TYPE,
    p_sal_min          functii.salariu_min%TYPE
) IS
BEGIN
    INSERT INTO functii VALUES (
        p_id_functie,
        p_denumire_functie,
        p_sal_min,
        p_sal_min * 2
    );

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
/

execute new_job('SY_ANAL', 'System Analyst', 6000);

SELECT
    *
FROM
    functii;

--2
CREATE OR REPLACE PROCEDURE add_job_hist (
    p_id_angj        angajati.id_angajat%TYPE,
    p_new_id_functie functii.id_functie%TYPE
) IS
    v_cur_angj angajati%rowtype;
BEGIN
    -- Retrieve employee information
    SELECT
        *
    INTO v_cur_angj
    FROM
        angajati
    WHERE
        id_angajat = p_id_angj;

    INSERT INTO istoric_functii (
        id_angajat,
        data_inceput,
        data_sfarsit,
        id_functie,S
        id_departament
    ) VALUES (
        p_id_angj,
        v_cur_angj.data_angajare,
        sysdate,
        v_cur_angj.id_functie,
        v_cur_angj.id_departament
    );

    UPDATE angajati
    SET
        data_angajare = sysdate,
        id_functie = p_new_id_functie,
        salariul = (
            SELECT
                salariu_min + 500
            FROM
                functii
            WHERE
                id_functie = p_new_id_functie
        )
    WHERE
        id_angajat = p_id_angj;

    COMMIT;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nu exist� angajat cu ID-ul specificat.');
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('A ap�rut o eroare: ' || sqlerrm);
END;
/

execute ADD_JOB_HIST(106,'SY_ANAL');

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

CREATE OR REPLACE PROCEDURE upd_jobsal (
    p_id_functie functii.id_functie%TYPE,
    p_min        functii.salariu_min%TYPE,
    p_max        functii.salariu_max%TYPE
) IS
    v_ok  NUMBER;
    ex EXCEPTION;
    v_min functii.salariu_min%TYPE;
BEGIN
    SELECT
        1
    INTO v_ok
    FROM
        functii
    WHERE
        id_functie = p_id_functie;

    SELECT
        salariu_min
    INTO v_min
    FROM
        functii
    WHERE
        id_functie = p_id_functie;

    IF v_min > p_max THEN
        RAISE ex;
    END IF;
    UPDATE functii
    SET
        salariu_min = p_min,
        salariu_max = p_max
    WHERE
        id_functie = p_id_functie;

    COMMIT;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('ERR: functie does not exist!');
    WHEN ex THEN
        dbms_output.put_line('ERR: max sal < the previous');
    WHEN OTHERS THEN
        ROLLBACK;
END;
/

execute UPD_JOBSAL('SY_ANAL', 7000, 140);
/
execute UPD_JOBSAL('SY_ANAL', 7000, 14000);
/

SELECT
    *
FROM
    functii;
--4
ALTER TABLE angajati ADD exceed_avgsal VARCHAR2(3) DEFAULT 'NO';

SELECT
    *
FROM
    angajati;
/

CREATE OR REPLACE FUNCTION get_job_avgsal (
    p_id_functie functii.id_functie%TYPE
) RETURN NUMBER IS
    v_ok  NUMBER;
    v_min NUMBER;
    v_max NUMBER;
BEGIN
    SELECT
        1
    INTO v_ok
    FROM
        functii
    WHERE
        id_functie = p_id_functie;

    SELECT
        salariu_min,
        salariu_max
    INTO
        v_min,
        v_max
    FROM
        functii
    WHERE
        id_functie = p_id_functie;

    RETURN ( v_min + v_max ) / 2;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('ERR: functie does not exist!');
END;
/

SELECT
    get_job_avgsal('SY_ANAL')
FROM
    dual;
/

CREATE OR REPLACE PROCEDURE check_avgsal IS

    CURSOR c_emp IS
    SELECT
        *
    FROM
        angajati
    FOR UPDATE OF exceed_avgsal;

    v_err_num NUMBER;
    v_err_msg VARCHAR2(4000);
BEGIN
    FOR rec IN c_emp LOOP
        BEGIN
            IF ( rec.salariul > get_job_avgsal(rec.id_functie) ) THEN
                UPDATE angajati
                SET
                    exceed_avgsal = 'YES'
                WHERE
                    CURRENT OF c_emp;

            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                IF sqlcode = -54 THEN
                    v_err_num := sqlcode;
                    v_err_msg := sqlerrm;
                    dbms_output.put_line('Record locked: ' || v_err_msg);
                ELSE
                    RAISE;
                END IF;
        END;
    END LOOP;

    COMMIT;
END;
/

execute check_avgsal;
/

SELECT
    a.id_angajat                 AS "Employee ID",
    get_job_avgsal(a.id_functie) AS "Average Salary",
    a.salariul                   AS "Employee Salary",
    a.exceed_avgsal              AS "EXCEED_AVGSAL"
FROM
    angajati a;
/

--5

CREATE OR REPLACE FUNCTION get_years_service (
    p_emp_id IN angajati.id_angajat%TYPE
) RETURN NUMBER IS
    v_years_service NUMBER;
    v_hire_date     DATE;
BEGIN
    SELECT
        data_angajare
    INTO v_hire_date
    FROM
        angajati
    WHERE
        id_angajat = p_emp_id;

    v_years_service := trunc(months_between(sysdate, v_hire_date) / 12);
    RETURN v_years_service;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Invalid employee ID');
        RETURN NULL;
END;
/


DECLARE
    v_years_service_for_999 NUMBER;
BEGIN
    v_years_service_for_999 := get_years_service(999);
    dbms_output.put_line('Years of service for employee 999: ' || v_years_service_for_999);
END;
/


DECLARE
    v_years_service_for_106 NUMBER;
BEGIN
    v_years_service_for_106 := get_years_service(106);
    dbms_output.put_line('Years of service for employee 106: ' || v_years_service_for_106);
END;
/

SELECT
    *
FROM
    istoric_functii
WHERE
    id_angajat = 106;

SELECT
    *
FROM
    angajati
WHERE
    id_angajat = 106;

--6

CREATE OR REPLACE FUNCTION get_job_count (
    p_emp_id IN angajati.id_angajat%TYPE
) RETURN NUMBER IS
    v_job_count NUMBER := 0;
    TYPE job_id_array IS
        TABLE OF functii.id_functie%TYPE;
    v_jobs      job_id_array;
BEGIN
   
    SELECT DISTINCT
        j.id_functie
    BULK COLLECT
    INTO v_jobs
    FROM
             istoric_functii j
        JOIN angajati a ON j.id_angajat = a.id_angajat
    WHERE
            a.id_angajat = p_emp_id
        AND j.id_functie != a.id_functie;

   
    v_job_count := v_jobs.count + 1;
    RETURN v_job_count;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Invalid employee ID');
        RETURN NULL;
END;
/

DECLARE
    v_job_count_for_176 NUMBER;
BEGIN
    v_job_count_for_176 := GET_JOB_COUNT(176);
    DBMS_OUTPUT.PUT_LINE('Number of different jobs for employee 176: ' || v_job_count_for_176);
END;
/

select * from angajati where id_angajat = 176;

select * from istoric_functii where id_angajat = 176;

