--4. Implementati in Oracle diagrama conceptuala realizata:
--   definiti toate tabelele, implementand toate constrangerile de integritate
--   necesare (chei primare, chei externe etc).

DROP SEQUENCE generator_cod_persoana;
DROP SEQUENCE generator_cod_cont;
DROP SEQUENCE generator_cod_sediu;
DROP SEQUENCE generator_cod_locatie;
DROP SEQUENCE generator_cod_tara;
DROP SEQUENCE generator_cod_dobanda;
DROP SEQUENCE generator_cod_bancomat;
DROP SEQUENCE generator_cod_card;
DROP SEQUENCE generator_card_default_pin;

DROP TABLE TARA CASCADE CONSTRAINTS;
DROP TABLE LOCATIE CASCADE CONSTRAINTS;
DROP TABLE SEDIU CASCADE CONSTRAINTS;
DROP TABLE JOB CASCADE CONSTRAINTS;
DROP TABLE TIP_CONTRACT CASCADE CONSTRAINTS;
DROP TABLE DOBANDA CASCADE CONSTRAINTS;
DROP TABLE BANCOMAT CASCADE CONSTRAINTS;
DROP TABLE PERSOANA CASCADE CONSTRAINTS;
DROP TABLE CLIENT CASCADE CONSTRAINTS;
DROP TABLE ANGAJAT CASCADE CONSTRAINTS;
DROP TABLE CONT CASCADE CONSTRAINTS;
DROP TABLE CONT_ECONOMII CASCADE CONSTRAINTS;
DROP TABLE DEPOZIT_ECONOMII CASCADE CONSTRAINTS;
DROP TABLE CARD CASCADE CONSTRAINTS;
DROP TABLE ISTORIC CASCADE CONSTRAINTS;
DROP TABLE TRANZACTIE_EXTERNA CASCADE CONSTRAINTS;
DROP TABLE TRANZACTIE CASCADE CONSTRAINTS;
DROP TABLE SEMNEAZA_UN_CONTRACT CASCADE CONSTRAINTS;
DROP TABLE TRANSFER_TRIMIS CASCADE CONSTRAINTS;
DROP TABLE TRANSFER_PRIMIT CASCADE CONSTRAINTS;
DROP TABLE DEPOZIT CASCADE CONSTRAINTS;
DROP TABLE RETRAGERE CASCADE CONSTRAINTS;

CREATE SEQUENCE generator_cod_persoana NOCACHE;
CREATE SEQUENCE generator_cod_cont NOCACHE;
CREATE SEQUENCE generator_cod_sediu NOCACHE;
CREATE SEQUENCE generator_cod_locatie NOCACHE;
CREATE SEQUENCE generator_cod_tara NOCACHE;
CREATE SEQUENCE generator_cod_dobanda NOCACHE;
CREATE SEQUENCE generator_cod_bancomat NOCACHE;
CREATE SEQUENCE generator_cod_card NOCACHE;
CREATE SEQUENCE generator_card_default_pin MINVALUE 1000 MAXVALUE 9999 CYCLE NOCACHE;
    
CREATE TABLE TARA(
    cod_tara NUMBER(5) PRIMARY KEY,
    nume_tara VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE LOCATIE(
    cod_locatie NUMBER(5) PRIMARY KEY,
    cod_postal VARCHAR(15) NOT NULL,
    adresa VARCHAR(40) NOT NULL,
    oras VARCHAR(30) NOT NULL,
    cod_tara NUMBER(5) REFERENCES TARA(cod_tara) ON DELETE SET NULL
);

CREATE TABLE SEDIU(
    cod_sediu NUMBER(5) PRIMARY KEY,
    cod_locatie NUMBER(5) REFERENCES LOCATIE(cod_locatie) ON DELETE SET NULL
);

CREATE TABLE JOB(
    cod_job VARCHAR(25) PRIMARY KEY,
    denumire_job VARCHAR(25) NOT NULL,
    salariu_minim NUMBER(15, 2) NOT NULL CHECK(salariu_minim>0),
    salariu_maxim NUMBER(15, 2) NOT NULL CHECK(salariu_maxim>0)
);


CREATE TABLE TIP_CONTRACT(
    tip_contract VARCHAR(20) PRIMARY KEY,
    titlu_contract VARCHAR(40) NOT NULL,
    continut CLOB NOT NULL
);

CREATE TABLE DOBANDA(
    cod_dobanda NUMBER(5) PRIMARY KEY,
    procent NUMBER(3,2) CHECK (procent>0 AND procent<=1) NOT NULL,
    durata_luni NUMBER(3) NOT NULL
);


CREATE TABLE BANCOMAT(
    cod_bancomat NUMBER(5) PRIMARY KEY,
    cod_locatie NUMBER(5) REFERENCES LOCATIE(cod_locatie) ON DELETE SET NULL
);


CREATE TABLE PERSOANA(
    cod_persoana NUMBER(5) PRIMARY KEY,
    cnp VARCHAR(20) UNIQUE,
    nume VARCHAR(25) NOT NULL,
    prenume VARCHAR(25) NOT NULL,
    email VARCHAR(30) UNIQUE,
    data_nastere DATE NOT NULL,
    gen CHAR(1),
    cod_locatie NUMBER(5) REFERENCES LOCATIE(cod_locatie) ON DELETE SET NULL
);


CREATE TABLE CLIENT(
    cod_persoana NUMBER(5) PRIMARY KEY REFERENCES PERSOANA(cod_persoana),
    tag_utilizator VARCHAR(25) NOT NULL UNIQUE
);

CREATE TABLE ANGAJAT(
    cod_persoana NUMBER(5) PRIMARY KEY REFERENCES PERSOANA(cod_persoana),
    salariu NUMBER(15, 2) NOT NULL CHECK (salariu>0),
    cod_sediu NUMBER(5) REFERENCES SEDIU(cod_sediu) ON DELETE SET NULL,
    cod_job VARCHAR(25) REFERENCES JOB(cod_job) ON DELETE SET NULL
);

CREATE TABLE CONT(
    cod_cont NUMBER(5) PRIMARY KEY,
    cod_persoana NUMBER(5) NOT NULL REFERENCES CLIENT(cod_persoana) ON DELETE CASCADE,
    sold NUMBER(15, 2) DEFAULT 0 NOT NULL,
    IBAN VARCHAR(25) NOT NULL UNIQUE
);


CREATE TABLE CONT_ECONOMII(
    cod_cont NUMBER(5) PRIMARY KEY REFERENCES CONT(cod_cont) ON DELETE CASCADE,
    depozite_contor NUMBER(15) DEFAULT 0 NOT NULL
);


CREATE TABLE DEPOZIT_ECONOMII(
    cod_depozit_economii NUMBER(5),
    cod_cont NUMBER(5) REFERENCES CONT_ECONOMII(cod_cont) ON DELETE CASCADE,
    cod_dobanda NUMBER(5) REFERENCES DOBANDA(cod_dobanda) NOT NULL,
    data_start DATE NOT NULL,
    data_sfarsit DATE NOT NULL,
    valoare NUMBER(15, 2) CHECK (valoare >= 100),
    revendicat NUMBER(1) DEFAULT 0 CHECK (revendicat = 0 or revendicat = 1),
    PRIMARY KEY(cod_depozit_economii, cod_cont)
);


CREATE TABLE CARD(
    cod_card NUMBER(5) PRIMARY KEY,
    pin NUMBER(4) CHECK (pin>999) NOT NULL,
    tip VARCHAR(10) NOT NULL,
    card_number VARCHAR(20) NOT NULL UNIQUE,
    cod_cont NUMBER(5) REFERENCES CONT(cod_cont) ON DELETE SET NULL
);

CREATE TABLE ISTORIC(
    cod_cont NUMBER(5) PRIMARY KEY REFERENCES CONT(cod_cont) ON DELETE CASCADE,
    tranzactii_contor NUMBER(15) DEFAULT 0 NOT NULL 
);


CREATE TABLE TRANZACTIE_EXTERNA(
    cod_persoana NUMBER(5) REFERENCES PERSOANA(cod_persoana),
    cod_cont NUMBER(5) REFERENCES ISTORIC(cod_cont) ON DELETE CASCADE,
    valoare NUMBER(15, 2) NOT NULL,
    data_tranzactie DATE,
    mesaj_administrativ VARCHAR2(4000),
    PRIMARY KEY(cod_persoana, cod_cont, data_tranzactie)
);


CREATE TABLE TRANZACTIE(
    cod_tranzactie NUMBER(5),
    cod_cont NUMBER(5) REFERENCES ISTORIC(cod_cont) ON DELETE CASCADE,
    valoare NUMBER(15, 2) NOT NULL,
    data_tranzactie DATE NOT NULL,
    tip_tranzactie VARCHAR(20) NOT NULL,
    PRIMARY KEY(cod_tranzactie, cod_cont)
);


CREATE TABLE DEPOZIT(
    cod_tranzactie NUMBER(5),
    cod_cont NUMBER(5),
    cod_bancomat NUMBER(5) REFERENCES BANCOMAT(cod_bancomat) ON DELETE SET NULL,
    cod_card NUMBER(5) REFERENCES CARD(cod_card) ON DELETE SET NULL,
    PRIMARY KEY(cod_tranzactie, cod_cont),
    FOREIGN KEY(cod_tranzactie, cod_cont) REFERENCES TRANZACTIE(cod_tranzactie, cod_cont) ON DELETE CASCADE
);

CREATE TABLE RETRAGERE(
    cod_tranzactie NUMBER(5),
    cod_cont NUMBER(5),
    cod_bancomat NUMBER(5) REFERENCES BANCOMAT(cod_bancomat) ON DELETE SET NULL,
    cod_card NUMBER(5) REFERENCES CARD(cod_card) ON DELETE SET NULL,
    PRIMARY KEY(cod_tranzactie, cod_cont),
    FOREIGN KEY(cod_tranzactie, cod_cont) REFERENCES TRANZACTIE(cod_tranzactie, cod_cont) ON DELETE CASCADE
);

CREATE TABLE TRANSFER_PRIMIT(
    cod_tranzactie NUMBER(5),
    cod_cont NUMBER(5),
    cod_cont_sursa REFERENCES CONT(cod_cont) ON DELETE SET NULL,
    PRIMARY KEY(cod_tranzactie, cod_cont),
    FOREIGN KEY(cod_tranzactie, cod_cont) REFERENCES TRANZACTIE(cod_tranzactie, cod_cont) ON DELETE CASCADE
);

    
CREATE TABLE TRANSFER_TRIMIS(
    cod_tranzactie NUMBER(5),
    cod_cont NUMBER(5),
    cod_cont_destinatie REFERENCES CONT(cod_cont) ON DELETE SET NULL,
    PRIMARY KEY(cod_tranzactie, cod_cont),
    FOREIGN KEY(cod_tranzactie, cod_cont) REFERENCES TRANZACTIE(cod_tranzactie, cod_cont) ON DELETE CASCADE
);

CREATE TABLE SEMNEAZA_UN_CONTRACT(
    cod_angajat NUMBER(5) REFERENCES ANGAJAT(cod_persoana),
    cod_client NUMBER(5) REFERENCES CLIENT(cod_persoana),
    tip_contract VARCHAR(20) REFERENCES TIP_CONTRACT(tip_contract),
    cod_sediu NUMBER(5),
    PRIMARY KEY(cod_angajat, cod_client, tip_contract)
);

--cativa triggeri pentru a automatiza generarea cheilor primare
CREATE OR REPLACE TRIGGER genereaza_pk_tara
BEFORE INSERT ON tara
FOR EACH ROW
BEGIN
    IF :NEW.cod_tara IS NULL THEN
        :NEW.cod_tara := generator_cod_tara.nextval;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER genereaza_pk_locatie
BEFORE INSERT ON locatie
FOR EACH ROW
BEGIN
    IF :NEW.cod_locatie IS NULL THEN
        :NEW.cod_locatie := generator_cod_locatie.nextval;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER genereaza_pk_sediu
BEFORE INSERT ON sediu
FOR EACH ROW
BEGIN
    IF :NEW.cod_sediu IS NULL THEN
        :NEW.cod_sediu := generator_cod_sediu.nextval;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER genereaza_pk_dobanda
BEFORE INSERT ON dobanda
FOR EACH ROW
BEGIN
    IF :NEW.cod_dobanda IS NULL THEN
        :NEW.cod_dobanda := generator_cod_dobanda.nextval;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER genereaza_pk_bancomat
BEFORE INSERT ON bancomat
FOR EACH ROW
BEGIN
    IF :NEW.cod_bancomat IS NULL THEN
        :NEW.cod_bancomat := generator_cod_bancomat.nextval;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER genereaza_pk_persoana
BEFORE INSERT ON persoana
FOR EACH ROW
BEGIN
    IF :NEW.cod_persoana IS NULL THEN
        :NEW.cod_persoana := generator_cod_persoana.nextval;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER genereaza_pk_cont
BEFORE INSERT ON cont
FOR EACH ROW
BEGIN
    IF :NEW.cod_cont IS NULL THEN
        :NEW.cod_cont := generator_cod_cont.nextval;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER genereaza_pk_card
BEFORE INSERT ON card
FOR EACH ROW
BEGIN
    IF :NEW.cod_card IS NULL THEN
        :NEW.cod_card := generator_cod_card.nextval;
    END IF;
END;
/

CREATE OR REPLACE TRIGGER genereaza_pk_depozit_economii
BEFORE INSERT ON depozit_economii
FOR EACH ROW
BEGIN
    IF :NEW.cod_cont IS NULL THEN RAISE_APPLICATION_ERROR(-20001, 'O inserare de depozit de economii necesita un cont de economii in care sa se realizeze.');
    END IF;
    
    SELECT depozite_contor+1 INTO :NEW.cod_depozit_economii FROM CONT_ECONOMII c WHERE :NEW.cod_cont = c.cod_cont;
    UPDATE CONT_ECONOMII c SET depozite_contor = depozite_contor + 1 WHERE c.cod_cont = :NEW.cod_cont;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20002, 'Nu se poate insera un depozit pentru un cont inexistent');
    --nu poate da TOO_MANY_ROWS, se cauta dupa cheia primara
    WHEN OTHERS THEN
        RAISE;
END;
/

CREATE OR REPLACE TRIGGER actualizeaza_tranzactii_contor
AFTER INSERT ON tranzactie
FOR EACH ROW
BEGIN
    UPDATE ISTORIC i SET tranzactii_contor = tranzactii_contor + 1 WHERE i.cod_cont = :NEW.cod_cont;
END;
/

CREATE OR REPLACE TRIGGER insereaza_istoric_la_cont
AFTER INSERT ON cont
FOR EACH ROW
BEGIN
    INSERT INTO istoric(cod_cont) VALUES(:NEW.cod_cont);
END;
/

CREATE OR REPLACE TRIGGER insereaza_economii_la_cont
AFTER INSERT ON cont
FOR EACH ROW
BEGIN
    INSERT INTO cont_economii(cod_cont) VALUES(:NEW.cod_cont);
END;
/

CREATE OR REPLACE TRIGGER genereaza_pin_card
BEFORE INSERT ON card
FOR EACH ROW
BEGIN
    IF :NEW.pin IS NULL THEN
        :NEW.pin := generator_card_default_pin.nextval;
    END IF;
END;
/