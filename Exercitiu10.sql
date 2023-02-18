--10. Definiti un trigger de tip LMD la nivel de comanda. Declansati trigger-ul.

--Problema: Din motive de securitate contractele semnate nu pot fi updatate
--si nici sterse. Exceptie de la regula se face in perioada de administratie (ziua de luni)
--sau daca utilizatorul este 'SYS', acesta avand permisiunea sa modifice oricand.

CREATE OR REPLACE TRIGGER securitate_contracte
BEFORE UPDATE OR DELETE ON SEMNEAZA_UN_CONTRACT
BEGIN
    IF UPPER(USER) = 'SYS' THEN
        RETURN;
    ELSIF UPPER(TRIM(TO_CHAR(SYSDATE, 'DAY', 'NLS_DATE_LANGUAGE = ROMANIAN'))) = 'LUNI' THEN
        RETURN;
    END IF;
    --nu a trecut validarile, oprim actiunea
    RAISE_APPLICATION_ERROR(-20020, 'Actiune blocata din motive de securitate, contactati administratorul bazei de date.');
END;
/

DELETE FROM SEMNEAZA_UN_CONTRACT;
DROP TRIGGER securitate_contracte;