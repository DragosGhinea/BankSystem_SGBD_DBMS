--12. Definiti un trigger de tip LDD. Declansati trigger-ul.

--Problema: Faceti un trigger care sa protejeze schema conceputa.
--Daca utilizatorul este 'SYS', acesta poate sa faca ce modificari vrea.
--Aceasta regula se aplica doar pentru tabelele si secventele create
--la exercitiul 4

CREATE OR REPLACE TRIGGER protejeaza_structura
BEFORE ALTER OR DROP OR CREATE ON SCHEMA
BEGIN
    IF UPPER(USER) = 'SYS' THEN
        RETURN;
    END IF;
    
    IF UPPER(SYS.DICTIONARY_OBJ_TYPE) = 'SEQUENCE' THEN
        IF UPPER(SYS.DICTIONARY_OBJ_NAME) NOT IN ('GENERATOR_COD_CONT', 'GENERATOR_COD_SEDIU', 'GENERATOR_COD_LOCATIE', 'GENERATOR_COD_TARA',
                                                    'GENERATOR_COD_DOBANDA', 'GENERATOR_COD_BANCOMAT', 'GENERATOR_COD_CARD', 'GENERATOR_COD_DEFAULT_PIN')
        THEN
            RETURN;
        END IF;
    ELSIF UPPER(SYS.DICTIONARY_OBJ_TYPE) = 'TABLE' THEN
        IF UPPER(SYS.DICTIONARY_OBJ_NAME) NOT IN ('TARA', 'LOCATIE', 'SEDIU', 'JOB', 'TIP_CONTRACT', 'DOBANDA', 'BANCOMAT', 'PERSOANA', 'CLIENT', 'ANGAJAT', 'CONT',
                                                    'CONT_ECONOMII', 'DEPOZIT_ECONOMII', 'CARD', 'ISTORIC', 'TRANZACTIE_EXTERNA', 'TRANZACTIE', 'SEMNEAZA_UN_CONTRACT',
                                                    'TRANSFER_TRIMIS', 'TRANSFER_PRIMIT', 'DEPOZIT', 'RETRAGERE')
        THEN
            RETURN;
        END IF;
    ELSE
        RETURN;
    END IF;
    RAISE_APPLICATION_ERROR(-20030, 'Nu puteti face modificari structurale, contactati administratorul.');
END;
/

DROP TABLE TARA;
DROP SEQUENCE generator_cod_cont;
CREATE TABLE TEST(id NUMBER(1));
DROP TABLE TEST;

DROP TRIGGER protejeaza_structura;