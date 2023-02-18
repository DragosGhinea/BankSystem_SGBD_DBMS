--11. Definiti un trigger LMD la nivel de linie. Declansati trigger-ul.

--Problema: Vrem sa automatizam cat de cat depozitele de economii.
--INSERT
--Cand un depozit de economii este inserat, daca nu contine data_start, se va considera a fi SYSDATE.
--Daca nu contine nici data_sfarsit, aceasta va fi calculata automat pe baza dobanzii.
--UPDATE
--Cand un depozit este revendicat (coloana revendicat e updatata de la 0 la 1) atunci vom adauga
--in contul asociat valoarea depozitului + profitul obtinut. Daca se incearca o revendicare
--inainte de data_sfarsit, se va arunca o eroare. Daca se va incerca trecerea de la revendicat
--la nerevendicat se va arunca alta eroare. Daca se schimba codul dobanzii, data_start si data_sfarsit
--vor fi reactualizate
--DELETE
--Daca un depozit nerevendicat este sters, valoarea acestuia va fi adaugata in contul asociat

--cerinta propusa are nevoie si de before si de after, ma doare sufletu
--sa o schimb asa ca puteti lua in considerare doar triggerul de before
--dar pentru utilitate le voi implementa pe ambele

CREATE OR REPLACE TRIGGER auto_depozite_economii_before
BEFORE INSERT OR UPDATE ON DEPOZIT_ECONOMII
FOR EACH ROW
DECLARE
    aux_luni DOBANDA.durata_luni%TYPE;
BEGIN
    IF INSERTING THEN
        IF :NEW.data_start IS NULL THEN
            :NEW.data_start := SYSDATE;
        END IF;
        
        IF :NEW.data_sfarsit IS NULL THEN
            BEGIN
                SELECT durata_luni INTO aux_luni FROM DOBANDA WHERE DOBANDA.cod_dobanda = :NEW.cod_dobanda;
                :NEW.data_sfarsit := ADD_MONTHS(SYSDATE, aux_luni);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN --inseamna ca nu exista dobanda, se va ocupa foreign key-ul
                    dbms_output.put_line('[DEBUG TRIGGER auto_depozite_economii_before] A intrat pe NO_DATA_FOUND (1)');
            END;
        END IF;
    ELSE
        IF :OLD.revendicat = 1 AND :NEW.revendicat = 0 THEN
            RAISE_APPLICATION_ERROR(-20023, 'Nu se poate trece de la revendicat la nerevendicat.');
        END IF;
        
        IF :OLD.cod_dobanda != :NEW.cod_dobanda THEN
            BEGIN
                
                SELECT durata_luni INTO aux_luni FROM DOBANDA WHERE DOBANDA.cod_dobanda = :NEW.cod_dobanda;
                :NEW.data_start := SYSDATE;
                :NEW.data_sfarsit := ADD_MONTHS(SYSDATE, aux_luni);
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    dbms_output.put_line('[DEBUG TRIGGER auto_depozite_economii_before] A intrat pe NO_DATA_FOUND (2)');
                    RETURN; --nu exista dobanda, nu are rost sa facem verificari extra, se ocupa foreign key-ul
            END;
        END IF;
        IF :OLD.revendicat = 0 AND :NEW.revendicat = 1 AND SYSDATE < :NEW.data_sfarsit THEN
            RAISE_APPLICATION_ERROR(-20022, 'Nu se poate revendica inainte de termen.');
        END IF;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER auto_depozite_economii_after
AFTER DELETE OR UPDATE ON DEPOZIT_ECONOMII
FOR EACH ROW
BEGIN
    IF UPDATING THEN
        IF :OLD.revendicat = 0 AND :NEW.revendicat = 1 THEN
            UPDATE CONT SET sold = sold + :NEW.valoare + :NEW.valoare*(SELECT procent FROM DOBANDA WHERE DOBANDA.cod_dobanda = :NEW.cod_dobanda);
        END IF;
    ELSE
        IF :OLD.revendicat = 0 THEN
            UPDATE CONT SET sold = sold + :OLD.valoare;
        END IF;
    END IF;
END;
/

--cod_dobanda nu exista
INSERT INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, valoare) VALUES(1, -1, 100);

--inserare normala
INSERT INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, valoare) VALUES(1, 1, 100);
--dupa un insert, ultimu element va avea acelasi cod_depozit_economii cu numarul de depozite create in total
SELECT * FROM DEPOZIT_ECONOMII WHERE cod_cont = 1 AND cod_depozit_economii = (SELECT depozite_contor FROM CONT_ECONOMII WHERE cod_cont = 1);

--update de revendicare inainte de termen pe insertul facut anterior
UPDATE DEPOZIT_ECONOMII SET revendicat = 1 WHERE cod_cont = 1 AND cod_depozit_economii = (SELECT depozite_contor FROM CONT_ECONOMII WHERE cod_cont = 1);

--update de la revendicat la nerevendicat
SELECT * FROM DEPOZIT_ECONOMII WHERE cod_cont = 1;
UPDATE DEPOZIT_ECONOMII SET revendicat = 0 WHERE cod_cont = 1 AND cod_depozit_economii = 1;

--revendicare bani + profit
SELECT * FROM CONT WHERE cod_cont = 1; --3200.2 sold
UPDATE DEPOZIT_ECONOMII SET revendicat = 1 WHERE cod_cont = 1 AND cod_depozit_economii = 3; --depozit de 1000, sold de 4500.2 dupa

--revendicare bani fara profit
DELETE FROM DEPOZIT_ECONOMII WHERE cod_cont = 1 AND cod_depozit_economii = 3;
SELECT * FROM CONT WHERE cod_cont = 1; --sold de 4200.2 de la 3200

ROLLBACK;
DROP TRIGGER auto_depozite_economii_before;
DROP TRIGGER auto_depozite_economii_after;