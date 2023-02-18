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


--5. Adaugati informatii coerente in tabelele create
--   (minim 5  nregistrari pentru fiecare entitate independenta;
--    minim 10  nregistrari pentru tabela asociativa).

INSERT ALL
    INTO TARA(nume_tara) VALUES('Romania')
    INTO TARA(nume_tara) VALUES('Olanda')
    INTO TARA(nume_tara) VALUES('Bulgaria')
    INTO TARA(nume_tara) VALUES('Spania')
    INTO TARA(nume_tara) VALUES('Rusia')
    INTO TARA(nume_tara) VALUES('Elvetia')
    INTO TARA(nume_tara) VALUES('Finlanda')
    INTO TARA(nume_tara) VALUES('Suedia')
    INTO TARA(nume_tara) VALUES('Grecia')
    INTO TARA(nume_tara) VALUES('Japonia')
SELECT 1 FROM DUAL;



INSERT ALL
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('2270', 'Str Artar Nr 12', 'Bucuresti', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('11199', 'Str Macin Nr 22', 'Cluj', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('22222', 'Str Green Nr 1', 'Amsterdam', 2)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('93123', 'Str Goodfellow Nr 5', 'Haga', 2)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('6677', 'Str Bujha Nr 9', 'Sofia', 3)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('9221', 'Str Ehia Nr 29', 'Vidin', 3)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('1122', 'Str Ernesto Nr 8 Bl A2 Sc 1 Et 3 Ap 10', 'Madrid', 4)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('8890', 'Str Ruski Nr 10 Bl F3 Sc 2 Et 1 Ap 4', 'Moscova', 5)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('1000', 'Str Kijrsi Nr 9 Bl C2 Sc 1 Et 2 Ap 7', 'Moscova', 5)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('3216', 'Str Etiop Nr 12 Bl A1 Sc 4 Et 5 Ap 32', 'Geneva', 6)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('2839', 'Str Yaht Nr 89', 'Atena', 9)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('1909', 'Str Kohli Nr 54', 'Corfu', 9)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('5750', 'Str Juim Nr 72 Bl D3 Sc 2 Et 1 Ap 2', 'Tokyo', 10)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('2111', 'Str Fukushi Nr 78 Bl B3 Sc 3 Et 4 Ap 22', 'Hokkaido', 10)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('233111', 'Str Iancului Nr 122', 'Suceava', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('28765', 'Str Armeni Nr 36', 'Drobeta-Turnu-Severin', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('8955', 'Str Maresal Nr 81', 'Targu-Jiu', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('29464', 'Str Stoica Nr 77', 'Sibiu', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('6894', 'Str Plopilor Nr 90', 'Brasov', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('46948', 'Str Cicero Nr 25', 'Drobeta-Turnu-Severin', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('44766', 'Str Titeica Nr 17', 'Sibiu', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('40099', 'Str Sadoveanu Nr 89', 'Bucuresti', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('10200', 'Str Alias Nr 98', 'Cluj', 1)
    INTO LOCATIE(cod_postal, adresa, oras, cod_tara) VALUES('100229', 'Str Mesterului Nr 4', 'Bucuresti', 1)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO SEDIU(cod_locatie) VALUES(1)
    INTO SEDIU(cod_locatie) VALUES(2)
    INTO SEDIU(cod_locatie) VALUES(4)
    INTO SEDIU(cod_locatie) VALUES(5)
    INTO SEDIU(cod_locatie) VALUES(6)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO JOB VALUES('MANAGER', 'Manager', 4000, 12000)
    INTO JOB VALUES('ADMIN', 'Administrator', 2000, 8000)
    INTO JOB VALUES('MOD', 'Moderator', 1500, 4000)
    INTO JOB VALUES('CASIER', 'Casier', 1300, 2000)
    INTO JOB VALUES('OP_CALL', 'Operator CallCenter', 1500, 3000)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO TIP_CONTRACT VALUES('TERMS', 'Termini si Conditii', 'Sa fii cuminte, sa nu faci evaziune fiscala, sa nu faci tranzactii dubioase, sa respecti regulile de bun simt si angajatii cu care interactionezi... etc etc')
    INTO TIP_CONTRACT VALUES('PRIVACY', 'Politica de Confidentialitate', 'Nu spunem, nu facem, nu transmitem decat daca te prinde ANAF-ul, ai tag de utilizator, numele nu se comunica public, totu privat si sigur... etc etc')
    INTO TIP_CONTRACT VALUES('ETHIC', 'Politica de Etica BUSINESS', 'Daca vinzi produse fa-o legal, daca te da cineva in judecata noi nu ne bagam, birocratie birocratie etc etc')
    INTO TIP_CONTRACT VALUES('ECONOMII', 'Politica de Economii', 'Ajuta sistemul sa aiba o cantitate constanta de bani si primeste o dobanda pentru buna ta vointa, etc etc...')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO DOBANDA(procent, durata_luni) VALUES(0.1, 3)
    INTO DOBANDA(procent, durata_luni) VALUES(0.3, 6)
    INTO DOBANDA(procent, durata_luni) VALUES(0.7, 12)
    INTO DOBANDA(procent, durata_luni) VALUES(0.15, 24)
    INTO DOBANDA(procent, durata_luni) VALUES(0.35, 48)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO BANCOMAT(cod_locatie) VALUES(1)
    INTO BANCOMAT(cod_locatie) VALUES(2)
    INTO BANCOMAT(cod_locatie) VALUES(4)
    INTO BANCOMAT(cod_locatie) VALUES(5)
    INTO BANCOMAT(cod_locatie) VALUES(6)
    INTO BANCOMAT(cod_locatie) VALUES(11)
    INTO BANCOMAT(cod_locatie) VALUES(12)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('2870816526255', 'Pintenaru', 'Melissa', 'melissa.p@gmail.com', TO_DATE('16-08-1987', 'DD-MM-YYYY'), 'f', 7)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1990426180155', 'Iliescu', 'Gabriel-Bogdan', 'bogdan.i@gmail.com', TO_DATE('26-04-1999', 'DD-MM-YYYY'), 'm', 8)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('2940315119504', 'Zahar', 'Andreea', 'andreea23@yahoo.ro', TO_DATE('15-03-1994', 'DD-MM-YYYY'), 'f', 9)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1990721328881', 'Grigorescu', 'Ciprian-Eduard', 'grigorescu.ciprian@gmail.com', TO_DATE('21-07-1999', 'DD-MM-YYYY'), 'm', 15)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('2870212037355', 'Funar', 'Diana', 'diana1.funar@yahoo.com', TO_DATE('12-02-1987', 'DD-MM-YYYY'), 'f', 16)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('2911002010206', 'Sala', 'Veronica', 'veronica.sala3@gmail.com', TO_DATE('02-03-1991', 'DD-MM-YYYY'), 'f', 17)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1951217161961', 'Stelian', 'Albert', 'albert.steliian@yahoo.com', TO_DATE('17-12-1995', 'DD-MM-YYYY'), 'm', 18)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1930309011068', 'Aurelian', 'Octavian-Dumitru', 'd-octavian.aurelian@gmail.com', TO_DATE('09-03-1993', 'DD-MM-YYYY'), 'm', 19)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('5020916348569', 'Dacian', 'Mihai', 'dacian.mihai@yahoo.ro', TO_DATE('16-09-2002', 'DD-MM-YYYY'), 'm', 20)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1960513234172', 'Dalca', 'Costache', 'costache_dalca@gmail.com', TO_DATE('13-05-1996', 'DD-MM-YYYY'), 'm', 21)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('5031014179484', 'Balan', 'Alex', 'a.balan8@yahoo.com', TO_DATE('14-10-2003', 'DD-MM-YYYY'), 'm', 22)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('2881202027415', 'Cojocaru', 'Mihaela', 'miha.cojo@yahoo.com', TO_DATE('02-12-1988', 'DD-MM-YYYY'), 'f', 23)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1900527165080', 'Lupu', 'Emil', 'emilll.lup@gmail.com', TO_DATE('27-05-1990', 'DD-MM-YYYY'), 'm', 24)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('2941012172179', 'Iliescu', 'Roxana', 'roxi.iliescu@yahoo.com', TO_DATE('12-10-1994', 'DD-MM-YYYY'), 'f', 8)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1890528306731', 'Grigorescu', 'Marian', 'grigorescu.marian@yahoo.com', TO_DATE('28-05-1989', 'DD-MM-YYYY'), 'm', 24)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1950122298018', 'Adam', 'Ioan', 'adam.ioan6@gmail.com', TO_DATE('22-01-1995', 'DD-MM-YYYY'), 'm', 16)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1900414346266', 'Balan', 'Adelin', 'balan.adelin@yahoo.com', TO_DATE('14-04-1990', 'DD-MM-YYYY'), 'm', 10)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('5020413517471', 'Dionisie', 'David', 'david.dion@gmail.com', TO_DATE('13-04-2002', 'DD-MM-YYYY'), 'm', 13)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('5010911340845', 'Simion', 'Marian-Eduard', 'marian_ed.simion@gmail.com', TO_DATE('11-09-2001', 'DD-MM-YYYY'), 'm', 14)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('2870426288591', 'Mosida', 'Anisoara', 'ani.mosida0@yahoo.ro', TO_DATE('26-04-2001', 'DD-MM-YYYY'), 'f', 9)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('2910903121802', 'Alexandrescu', 'Andra-Maria', 'andra.alexandrescu4@gmail.com', TO_DATE('03-09-1991', 'DD-MM-YYYY'), 'f', 15)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('5001217466275', 'Anastasescu', 'Radu', 'radu.anastas7@yahoo.com', TO_DATE('17-12-2000', 'DD-MM-YYYY'), 'm', 21)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1880608200140', 'Ungur', 'Beniamin', 'beniamin.ungur@gmail.com', TO_DATE('08-06-1988', 'DD-MM-YYYY'), 'm', 20)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('1940509282540', 'Petran', 'Bogdan-Teodor', 'bogdan.t0@yahoo.ro', TO_DATE('09-05-1994', 'DD-MM-YYYY'), 'm', 18)
    INTO PERSOANA(cnp, nume, prenume, email, data_nastere, gen, cod_locatie) VALUES('5021224054511', 'Ionescu', 'Ion', 'ion.ion8@yahoo.com', TO_DATE('24-12-2002', 'DD-MM-YYYY'), 'm', 17)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO CLIENT VALUES (1, 'melis2_')
    INTO CLIENT VALUES (2, 'bogdiG')
    INTO CLIENT VALUES (3, 'deeutza')
    INTO CLIENT VALUES (4, 'ediCipri')
    INTO CLIENT VALUES (5, 'dianaF_')
    INTO CLIENT VALUES (6, 'veronica.v')
    INTO CLIENT VALUES (7, 'albertoo')
    INTO CLIENT VALUES (8, 'octiDumitru')
    INTO CLIENT VALUES (9, 'mihaita')
    INTO CLIENT VALUES (10, 'Costache')
    INTO CLIENT VALUES (11, 'aleX_')
    INTO CLIENT VALUES (12, 'Miha24')
    INTO CLIENT VALUES (13, 'EmilLu')
    INTO CLIENT VALUES (14, 'RoxiI')
    INTO CLIENT VALUES (15, 'MariG_')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO ANGAJAT VALUES(16, 100000, NULL, 'MANAGER')
    INTO ANGAJAT VALUES(17, 6000, 1, 'ADMIN')
    INTO ANGAJAT VALUES(18, 7500, 2, 'ADMIN')
    INTO ANGAJAT VALUES(19, 2900, 1, 'MOD')
    INTO ANGAJAT VALUES(20, 3000, 3, 'MOD')
    INTO ANGAJAT VALUES(21, 1500, 1, 'CASIER')
    INTO ANGAJAT VALUES(22, 1700, 2, 'CASIER')
    INTO ANGAJAT VALUES(23, 1620, 3, 'CASIER')
    INTO ANGAJAT VALUES(24, 2000, NULL, 'OP_CALL')
    INTO ANGAJAT VALUES(25, 2100, NULL, 'OP_CALL')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 1, 'TERMS', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 2, 'TERMS', 1)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 3, 'TERMS', 1)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 4, 'TERMS', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 5, 'TERMS', 2)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 6, 'TERMS', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 7, 'TERMS', 2)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 8, 'TERMS', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 9, 'TERMS', 3)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 10, 'TERMS', 4)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 11, 'TERMS', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 12, 'TERMS', 5)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 13, 'TERMS', 5)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 14, 'TERMS', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 15, 'TERMS', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 1, 'PRIVACY', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 2, 'PRIVACY', 1)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 3, 'PRIVACY', 1)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 4, 'PRIVACY', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 5, 'PRIVACY', 2)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 6, 'PRIVACY', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 7, 'PRIVACY', 2)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 8, 'PRIVACY', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 9, 'PRIVACY', 3)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 10, 'PRIVACY', 4)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 11, 'PRIVACY', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 12, 'PRIVACY', 5)
    INTO SEMNEAZA_UN_CONTRACT VALUES(16, 13, 'PRIVACY', 5)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 14, 'PRIVACY', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 15, 'PRIVACY', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 1, 'ETHIC', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 2, 'ETHIC', 1)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 4, 'ETHIC', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 9, 'ETHIC', 3)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 10, 'ETHIC', 4)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 12, 'ETHIC', 5)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 15, 'ETHIC', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 2, 'ECONOMII', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 3, 'ECONOMII', 1)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 4, 'ECONOMII', NULL)
    INTO SEMNEAZA_UN_CONTRACT VALUES(17, 9, 'ECONOMII', 3)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 10, 'ECONOMII', 4)
    INTO SEMNEAZA_UN_CONTRACT VALUES(19, 11, 'ECONOMII', 5)
    INTO SEMNEAZA_UN_CONTRACT VALUES(18, 14, 'ECONOMII', NULL)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO CONT(cod_persoana, sold, iban) VALUES(1, 3200.20, 'RO80RZBR8845968383338826')
    INTO CONT(cod_persoana, sold, iban) VALUES(2, 1000.2, 'RO93PORL7529645415765354')
    INTO CONT(cod_persoana, sold, iban) VALUES(3, 20.32, 'RO43PORL9543945186522245')
    INTO CONT(cod_persoana, sold, iban) VALUES(1, 100200.2, 'RO48PORL5146774785878989')
    INTO CONT(cod_persoana, sold, iban) VALUES(5, 39580.01, 'RO42RZBR7724779358767381')
    INTO CONT(cod_persoana, sold, iban) VALUES(6, 3339, 'RO37PORL3841381829398764')
    INTO CONT(cod_persoana, sold, iban) VALUES(7, 2981.44, 'RO31RZBR1288422343628368')
    INTO CONT(cod_persoana, sold, iban) VALUES(8, 1050.67, 'RO13PORL2734191267583753')
    INTO CONT(cod_persoana, sold, iban) VALUES(9, 18900.3, 'RO58PORL5263537759453949')
    INTO CONT(cod_persoana, sold, iban) VALUES(10, 36711.2, 'RO26RZBR6125587281719456')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO CARD(tip, card_number, cod_cont) VALUES('visa', '4532962746090018', 1)
    INTO CARD(tip, card_number, cod_cont) VALUES('visa', '4801769871971639', 1)
    INTO CARD(tip, card_number, cod_cont) VALUES('visa', '4929249181139042', 1)
    INTO CARD(tip, card_number, cod_cont) VALUES('visa', '4539763856109249', 3)
    INTO CARD(tip, card_number, cod_cont) VALUES('visa', '4202142181423458', 3)
    INTO CARD(tip, card_number, cod_cont) VALUES('visa', '4929647287465379', 5)
    INTO CARD(tip, card_number, cod_cont) VALUES('visa', '4292894190135140', 6)
    INTO CARD(tip, card_number, cod_cont) VALUES('visa', '4556357158099097', 7)
    INTO CARD(tip, card_number, cod_cont) VALUES('mastercard', '5233771702998802', 2)
    INTO CARD(tip, card_number, cod_cont) VALUES('mastercard', '5196701739892160', 4)
    INTO CARD(tip, card_number, cod_cont) VALUES('mastercard', '5395006293149810', 8)
    INTO CARD(tip, card_number, cod_cont) VALUES('mastercard', '5336340664664640', 8)
    INTO CARD(tip, card_number, cod_cont) VALUES('mastercard', '5273043537498908', 9)
    INTO CARD(tip, card_number, cod_cont) VALUES('mastercard', '5528612483101600', 10)
    INTO CARD(tip, card_number, cod_cont) VALUES('mastercard', '5491696102956307', 10)
SELECT 1 FROM DUAL;

INSERT ALL
    INTO TRANZACTIE_EXTERNA VALUES(21, 2, 200, TO_DATE('03-01-2022', 'DD-MM-YYYY'), 'Depozit realizat la sediu.')
    INTO TRANZACTIE_EXTERNA VALUES(21, 3, 300, TO_DATE('12-04-2022', 'DD-MM-YYYY'), 'Depozit realizat la sediu.')
    INTO TRANZACTIE_EXTERNA VALUES(22, 1, -200, TO_DATE('06-05-2022', 'DD-MM-YYYY'), 'Retragere realizata la sediu.')
    INTO TRANZACTIE_EXTERNA VALUES(18, 1, 100, TO_DATE('09-02-2022', 'DD-MM-YYYY'), 'Reparare tranzactie fantoma.')
    INTO TRANZACTIE_EXTERNA VALUES(23, 4, 900, TO_DATE('23-03-2022', 'DD-MM-YYYY'), 'Depozit realizat la sediu.')
    INTO TRANZACTIE_EXTERNA VALUES(17, 6, 2000, TO_DATE('21-03-2022', 'DD-MM-YYYY'), 'Transfer de bani din contul sters.')
    INTO TRANZACTIE_EXTERNA VALUES(18, 7, -3200, TO_DATE('11-07-2022', 'DD-MM-YYYY'), 'Repararea unei erori de sistem.')
    INTO TRANZACTIE_EXTERNA VALUES(23, 7, -100, TO_DATE('14-06-2022', 'DD-MM-YYYY'), 'Retragere realizata la sediu.')
    INTO TRANZACTIE_EXTERNA VALUES(21, 8, 400, TO_DATE('02-08-2022', 'DD-MM-YYYY'), 'Repararea unei erori de sistem.')
    INTO TRANZACTIE_EXTERNA VALUES(18, 10, 600, TO_DATE('01-01-2022', 'DD-MM-YYYY'), 'Repararea unei erori de sistem.')
SELECT 1 FROM DUAL;

INSERT ALL
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(1, 1, TO_DATE('19-01-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('19-01-2022', 'DD-MM-YYYY'),3), 300, 1)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(1, 1, TO_DATE('08-05-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('08-05-2022', 'DD-MM-YYYY'),3), 210, 0)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(1, 2, TO_DATE('25-03-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('25-03-2022', 'DD-MM-YYYY'),6), 1000, 0)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(4, 1, TO_DATE('16-05-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('16-05-2022', 'DD-MM-YYYY'),3), 520, 0)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(4, 3, TO_DATE('21-02-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('21-02-2022', 'DD-MM-YYYY'),12), 3000, 0)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(4, 5, TO_DATE('14-04-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('14-04-2022', 'DD-MM-YYYY'),48), 400, 0)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(5, 4, TO_DATE('02-03-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('02-03-2022', 'DD-MM-YYYY'),24), 1200, 0)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(6, 2, TO_DATE('19-03-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('19-03-2022', 'DD-MM-YYYY'),6), 1000, 0)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(7, 1, TO_DATE('24-01-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('24-01-2022', 'DD-MM-YYYY'),3), 600, 1)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(8, 1, TO_DATE('07-02-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('07-02-2022', 'DD-MM-YYYY'),3), 700, 1)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(9, 5, TO_DATE('05-04-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('05-04-2022', 'DD-MM-YYYY'),48), 3100, 0)
    INTO DEPOZIT_ECONOMII(cod_cont, cod_dobanda, data_start, data_sfarsit, valoare, revendicat) VALUES(10, 1, TO_DATE('18-04-2022', 'DD-MM-YYYY'), ADD_MONTHS(TO_DATE('18-04-2022', 'DD-MM-YYYY'),3), 2200, 0)
SELECT 1 FROM DUAL;

--inserarea tranzactiilor manual, as fi folosit functiile predifinite (care apar la ceritna 14) de depozit_bani,retragere_bani,transfer_bani
--dar am vrut sa aiba date diferite
--un trigger va creste automat tranzactii_contor din ISTORIC
INSERT ALL
    INTO TRANZACTIE VALUES(1, 1, 300, TO_DATE('03-05-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(1, 1, 1, 1)
    
    INTO TRANZACTIE VALUES(2, 1, 500, TO_DATE('12-01-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(2, 1, 4, 2)
    
    INTO TRANZACTIE VALUES(3, 1, 200, TO_DATE('24-04-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(3, 1, 3, 2)
    
    INTO TRANZACTIE VALUES(1, 2, 467, TO_DATE('15-02-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(1, 2, 3, 9)
    
    INTO TRANZACTIE VALUES(1, 3, 1200, TO_DATE('07-08-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(1, 3, 2, 4)
    
    INTO TRANZACTIE VALUES(1, 4, 1800, TO_DATE('09-03-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(1, 4, 4, 10)
    
    INTO TRANZACTIE VALUES(1, 5, 1200, TO_DATE('09-01-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(1, 5, 5, 6)
    
    INTO TRANZACTIE VALUES(1, 6, 800, TO_DATE('16-04-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(1, 6, 2, 7)
    
    INTO TRANZACTIE VALUES(2, 5, 1200, TO_DATE('09-01-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(2, 5, 5, 6)
    
    INTO TRANZACTIE VALUES(1, 8, 1100, TO_DATE('15-02-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(1, 8, 6, 12)
    
    INTO TRANZACTIE VALUES(1, 9, 2100, TO_DATE('09-01-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(1, 9, 1, 13)
    
    INTO TRANZACTIE VALUES(2, 9, 100, TO_DATE('09-01-2022', 'DD-MM-YYYY'), 'depozit')
    INTO DEPOZIT VALUES(2, 9, 2, 13)
    
    INTO TRANZACTIE VALUES(4, 1, 200, TO_DATE('18-05-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(4, 1, 2, 1)
    
    INTO TRANZACTIE VALUES(5, 1, 400, TO_DATE('17-01-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(5, 1, 1, 2)
    
    INTO TRANZACTIE VALUES(6, 1, 150, TO_DATE('28-04-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(6, 1, 4, 2)
    
    INTO TRANZACTIE VALUES(2, 2, 200, TO_DATE('11-09-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(2, 2, 5, 9)
    
    INTO TRANZACTIE VALUES(2, 3, 10, TO_DATE('09-05-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(2, 3, 7, 4)
    
    INTO TRANZACTIE VALUES(2, 4, 30, TO_DATE('11-07-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(2, 4, 3, 10)
    
    INTO TRANZACTIE VALUES(3, 5, 70, TO_DATE('05-06-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(3, 5, 2, 6)
    
    INTO TRANZACTIE VALUES(2, 6, 800, TO_DATE('11-03-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(2, 6, 6, 7)
    
    INTO TRANZACTIE VALUES(4, 5, 1200, TO_DATE('27-01-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(4, 5, 5, 6)
    
    INTO TRANZACTIE VALUES(2, 8, 60, TO_DATE('24-02-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(2, 8, 2, 12)
    
    INTO TRANZACTIE VALUES(3, 9, 1300, TO_DATE('07-02-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(3, 9, 1, 13)
    
    INTO TRANZACTIE VALUES(4, 9, 50, TO_DATE('11-03-2022', 'DD-MM-YYYY'), 'retragere')
    INTO RETRAGERE VALUES(4, 9, 2, 13)
    
    
    INTO TRANZACTIE VALUES(7, 1, 50, TO_DATE('16-03-2022', 'DD-MM-YYYY'), 'transfer_trimis')
    INTO TRANSFER_TRIMIS VALUES(7, 1, 2)
    INTO TRANZACTIE VALUES(3, 2, 50, TO_DATE('16-03-2022', 'DD-MM-YYYY'), 'transfer_primit')
    INTO TRANSFER_PRIMIT VALUES(3, 2, 1)
    
    INTO TRANZACTIE VALUES(3, 4, 6000, TO_DATE('21-02-2022', 'DD-MM-YYYY'), 'transfer_trimis')
    INTO TRANSFER_TRIMIS VALUES(3, 4, 3)
    INTO TRANZACTIE VALUES(3, 3, 6000, TO_DATE('21-02-2022', 'DD-MM-YYYY'), 'transfer_primit')
    INTO TRANSFER_PRIMIT VALUES(3, 3, 4)
    
    INTO TRANZACTIE VALUES(1, 10, 2100, TO_DATE('01-04-2022', 'DD-MM-YYYY'), 'transfer_trimis')
    INTO TRANSFER_TRIMIS VALUES(1, 10, 3)
    INTO TRANZACTIE VALUES(4, 3, 2100, TO_DATE('01-04-2022', 'DD-MM-YYYY'), 'transfer_primit')
    INTO TRANSFER_PRIMIT VALUES(4, 3, 10)
    
    INTO TRANZACTIE VALUES(3, 6, 900, TO_DATE('09-05-2022', 'DD-MM-YYYY'), 'transfer_trimis')
    INTO TRANSFER_TRIMIS VALUES(3, 6, 7)
    INTO TRANZACTIE VALUES(1, 7, 900, TO_DATE('09-05-2022', 'DD-MM-YYYY'), 'transfer_primit')
    INTO TRANSFER_PRIMIT VALUES(1, 7, 6)
    
    INTO TRANZACTIE VALUES(4, 4, 250, TO_DATE('09-03-2022', 'DD-MM-YYYY'), 'transfer_trimis')
    INTO TRANSFER_TRIMIS VALUES(4, 4, 8)
    INTO TRANZACTIE VALUES(3, 8, 250, TO_DATE('09-03-2022', 'DD-MM-YYYY'), 'transfer_primit')
    INTO TRANSFER_PRIMIT VALUES(3, 8, 4)
SELECT 1 FROM DUAL;


--6. Formulati in limbaj natural o problema pe care sa o rezolvati folosind
--   un subprogram stocat independent care sa utilizeze doua tipuri diferite
--   de colectii studiate. Apelati subprogramul.

--Problema:
--Manager-ul vrea sa incerce o noua strategie de marketing.
--El vrea sa motiveze persoanele inactive sa foloseasca serviciile bancii mai mult asa ca
--acesta propune trimiterea de mail-uri cu oferte in functie de activitatea clientilor.
--Activitatea utilizatorului va fi un total de puncte, calculat astfel:
--  - 1 punct pentru fiecare depozit/retragere/transfer_trimis
--  - 5 puncte pentru fiecare card detinut
--  - 2 puncte * numarul de luni pe care este facut un depozit de economii
--Faceti o procedura si afisati email-ul, username-ul si punctajul clientilor pentru a
--oferi manager-ului informatii despre activitatea utilizatorilor.
--Procedura poate sa primeasca ca parametru un numar pozitiv reprezentand un prag superior,
--urmand sa se afiseze doar clientii cu punctajul mai mic sau egal cu cel dat ca parametru.


CREATE OR REPLACE PROCEDURE activitate_utilizatori(activ_max PLS_INTEGER DEFAULT -1)
AS
    TYPE t_info_user IS RECORD(
        email PERSOANA.email%TYPE,
        username CLIENT.tag_utilizator%TYPE,
        punctaj PLS_INTEGER DEFAULT 0
    );
    
    TYPE t_idx IS TABLE OF t_info_user INDEX BY PLS_INTEGER;
    v_useri t_idx;
    v_index_user PLS_INTEGER;
    
    TYPE t_punctaj IS RECORD(
        cod_persoana PERSOANA.cod_persoana%TYPE,
        punctaj PLS_INTEGER
    );
    
    TYPE t_imb_punctaj IS TABLE OF t_punctaj;
    v_adaos_punctaj t_imb_punctaj; --nu are rost sa initializam, folosim bulk collect
    
    TYPE t_info_user_cu_cod IS RECORD(
        cod_persoana PERSOANA.cod_persoana%TYPE,
        email PERSOANA.email%TYPE,
        username CLIENT.tag_utilizator%TYPE
    );
    
    TYPE t_vector_info_user IS VARRAY(2000) OF t_info_user_cu_cod; --suntem o banca mica, ne ajunge maxim 2000, marim la nevoie
    v_aux_1 t_vector_info_user; --nu are rost sa initializam, folosim bulk collect
BEGIN
    --ne abtinem din a folosi un ciclu cursor, doar de dragul de a folosi un vector
    SELECT p.cod_persoana, email, tag_utilizator BULK COLLECT INTO v_aux_1 FROM PERSOANA p, CLIENT c WHERE p.cod_persoana = c.cod_persoana;
    
    IF v_aux_1.count = 0 THEN --nu exista utilizatori, nu are rost sa facem calcule
        dbms_output.put_line('Nu exista utilizatori care sa aiba activitate.');
        RETURN;
    END IF;

    FOR i IN 1..v_aux_1.count LOOP
        v_useri(v_aux_1(i).cod_persoana).email := v_aux_1(i).email;
        v_useri(v_aux_1(i).cod_persoana).username := v_aux_1(i).username;
    END LOOP;
    
    --calculam punctele din depozite/retrageri/transferuri trimise si stocam in v_adaos_punctaj
    WITH
    tranzactiiPerCont AS (SELECT cod_cont, COUNT(cod_tranzactie) tranzactii
                          FROM TRANZACTIE WHERE DECODE(lower(tip_tranzactie), 'depozit', 1, 'retragere', 1, 'transfer_trimis', 1, 0) = 1
                          GROUP BY cod_cont)
    SELECT c.cod_persoana, SUM(tranzactii) BULK COLLECT INTO v_adaos_punctaj FROM CONT c, tranzactiiPerCont
    WHERE c.cod_cont = tranzactiiPerCont.cod_cont GROUP BY c.cod_persoana;
    

    --fiind inserat cu bulk collect, stiu ca este dens
    FOR i IN 1..v_adaos_punctaj.count LOOP
        v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
        IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
            v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
        END IF;
    END LOOP;

    
    --calculam punctele pentru carduri detinute
    WITH
    carduriPerCont AS (SELECT cod_cont, COUNT(cod_card) carduri FROM CARD GROUP BY cod_cont)
    SELECT c.cod_persoana, SUM(carduri)*5 BULK COLLECT INTO v_adaos_punctaj FROM CONT c, carduriPerCont
    WHERE c.cod_cont = carduriPerCont.cod_cont GROUP BY c.cod_persoana;
    
    --acum va trebui sa verificam si daca exista persoana in lista
    --daca nu exista inseamna ca a fost scoasa pentru ca limita a fost depasita
    --la un pas anterior
    FOR i IN 1..v_adaos_punctaj.count LOOP
        IF NOT v_useri.exists(v_adaos_punctaj(i).cod_persoana) THEN
            CONTINUE;
        END IF;
        
        v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
        IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
            v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
        END IF;
    END LOOP;
    
    --schimbam din with in join pe 3 tabele
    SELECT c.cod_persoana, SUM(durata_luni)*2 BULK COLLECT INTO v_adaos_punctaj 
    FROM DEPOZIT_ECONOMII dE, DOBANDA d, CONT c WHERE c.cod_cont = dE.cod_cont AND dE.cod_dobanda = d.cod_dobanda GROUP BY c.cod_persoana;
    
    --neschimbat fata de for-ul anterior
    FOR i IN 1..v_adaos_punctaj.count LOOP
        IF NOT v_useri.exists(v_adaos_punctaj(i).cod_persoana) THEN
            CONTINUE;
        END IF;
        
        v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
        IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
            v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
        END IF;
    END LOOP;
    
    IF v_useri.first IS NULL THEN
        dbms_output.put_line('Nu exista utilizatori care sa aiba activitate.');
        RETURN;
    END IF;
    
    dbms_output.put_line('=========== Puncte de activitate =============');
    v_index_user := v_useri.first;
    WHILE v_index_user IS NOT NULL LOOP
        dbms_output.put_line('> ' || v_useri(v_index_user).username || ' (' || v_useri(v_index_user).email || ') - ' || v_useri(v_index_user).punctaj);
        v_index_user := v_useri.next(v_index_user);
    END LOOP;
END;
/

EXECUTE activitate_utilizatori;
--lipsesc melis2_ si mihaita
EXECUTE activitate_utilizatori(100);


--7. Formulati in limbaj natural o problema pe care sa o rezolvati
--   folosind un subprogram stocat independent care sa utilizeze
--   2 tipuri diferite de cursoare studiate, unul dintre acestea fiind
--cursor parametrizat. Apelati subprogramul.


--Problema:
--Dorim sa afisam informatii despre un client anume, al carui tag de utilizator se da ca parametru:
--Informatii personale: nume, prenume, email, gen
--Informatii despre conturile asociate persoanei: iban, sold, carduri daca exista
--Pentru carduri se va afisa tipul si numarul si toate tranzactiile efectuate cu acel card (data, tip_tranzactie, suma)

CREATE OR REPLACE PROCEDURE info_client(tag_utilizator CLIENT.tag_utilizator%TYPE)
AS
    CURSOR personal_client(p_tag_utilizator CLIENT.tag_utilizator%TYPE) IS SELECT p.cod_persoana, nume, prenume, email, gen
        FROM PERSOANA p, CLIENT c WHERE p.cod_persoana = c.cod_persoana AND c.tag_utilizator = p_tag_utilizator;
    
    CURSOR conturi(cod_client PERSOANA.cod_persoana%TYPE) IS SELECT cod_cont, iban, sold,
                CURSOR(SELECT cod_card, tip, card_number FROM CARD WHERE CARD.cod_cont = CONT.cod_cont)
            FROM CONT WHERE cod_persoana = cod_client;
            
    CURSOR tranzactii_cu_card(p_cod_card CARD.cod_card%TYPE, p_cod_cont CONT.cod_cont%TYPE) IS
        WITH tranzactii AS (
                (SELECT cod_tranzactie FROM DEPOZIT d WHERE d.cod_cont = cod_cont AND d.cod_card = p_cod_card)
                UNION ALL
                (SELECT cod_tranzactie FROM RETRAGERE r WHERE r.cod_cont = cod_cont AND r.cod_card = p_cod_card)
            )
        SELECT data_tranzactie, tip_tranzactie, valoare FROM TRANZACTIE t
        WHERE t.cod_cont = p_cod_cont AND t.cod_tranzactie IN (SELECT * FROM tranzactii);
    
    TYPE t_personal_info IS RECORD(
        cod_persoana PERSOANA.cod_persoana%TYPE,
        nume PERSOANA.nume%TYPE,
        prenume PERSOANA.prenume%TYPE,
        email PERSOANA.email%TYPE,
        gen PERSOANA.gen%TYPE
    );
    
    v_personal_info t_personal_info;
    
    v_cod_cont CONT.cod_cont%TYPE;
    v_iban CONT.iban%TYPE;
    v_sold CONT.sold%TYPE;
    carduri SYS_REFCURSOR;
    
    v_cod_card CARD.cod_card%TYPE;
    v_tip CARD.tip%TYPE;
    v_card_number CARD.card_number%TYPE;
    
    v_verifica BOOLEAN;
BEGIN
    OPEN personal_client(tag_utilizator);
    FETCH personal_client INTO v_personal_info;
    IF personal_client%ROWCOUNT = 0 THEN
        CLOSE personal_client;
        RAISE_APPLICATION_ERROR(-20008, 'Nu s-a gasit persoana cu tag-ul ' || tag_utilizator);
    END IF;
    CLOSE personal_client;
    
    --a trecut de primul cursor, avem date in v_personal_info
    dbms_output.put_line('=========== Info Client ===========');
    dbms_output.put_line('> Nume: ' || v_personal_info.nume);
    dbms_output.put_line('> Prenume: ' || v_personal_info.prenume);
    dbms_output.put_line('> Email: ' || v_personal_info.email);
    dbms_output.put_line('> Gen: ' || UPPER(v_personal_info.gen));
    dbms_output.new_line;
    OPEN conturi(v_personal_info.cod_persoana);
    LOOP
        FETCH conturi INTO v_cod_cont, v_iban, v_sold, carduri;
        EXIT WHEN conturi%NOTFOUND;
        
        dbms_output.put_line('-=-=-=- Cont Info -=-=-=-');
        dbms_output.put_line('>> IBAN: ' || v_iban);
        dbms_output.put_line('>> SOLD: ' || v_sold);
        dbms_output.new_line;
        
        LOOP
            FETCH carduri INTO v_cod_card, v_tip, v_card_number;
            EXIT WHEN carduri%NOTFOUND;
            dbms_output.put_line('----- Card Info -----');
            dbms_output.put_line('>>> Card Number: ' || v_card_number);
            dbms_output.put_line('>>> Tip: ' || v_tip);
            dbms_output.put_line('>>> Tranzactii: ');
            v_verifica := FALSE;
            FOR v_tranzactie_info IN tranzactii_cu_card(v_cod_card, v_cod_cont) LOOP
                dbms_output.put_line(' - Tranzactie (' || v_tranzactie_info.tip_tranzactie || ') efectuata pe ' || v_tranzactie_info.data_tranzactie || ' in valoare de ' || v_tranzactie_info.valoare);
                v_verifica := TRUE;
            END LOOP;
            IF NOT v_verifica THEN
                dbms_output.put_line('>>>> Nu are tranzactii efectuate cu acest card');
            END IF;
            dbms_output.new_line;
        END LOOP;
        IF carduri%ROWCOUNT = 0 THEN
            dbms_output.put_line('Clientul nu are carduri.');
        END IF;
        CLOSE carduri;
    END LOOP;
    
    IF conturi%ROWCOUNT = 0 THEN
        dbms_output.put_line('Clientul nu are conturi.');
    END IF;
    CLOSE conturi;
END;
/

EXECUTE info_client('UnUserInexistent_');
EXECUTE info_client('melis2_');



--8. Formulati in limbaj natural o problema pe care sa o rezolvati folosind un
--   subprogram stocat independent de tip functie care sa utilizeze intr-o singura
--   comanda SQL 3 dintre tabelele definite. Definiti minim 2 exceptii.
--   Apelati subprogramul astfel incat sa evidentiati toate cazurile tratate.

--Problema:
--PIN-urile cardurilor se uita constant, manager-ul ne-a cerut o metoda de a le recupera
--dupa mai multe criterii.
--1. PIN-ul poate fi cerut de un client, care isi va confirma
--identitatea cu CNP-ul (in mod normal am folosi hash-ul parolei, dar nu avem in model
--deci ne adaptam si presupunem ca CNP-urile se afla la fel de greu ca parolele)
--2. PIN-ul poate fi cerut de un angajat, care se identifica tot cu CNP-ul sau, doar daca
--este admin sau manager.
--Din motive de securitate, daca angajatul lucreaza online ii permitem sa ceara pin-ul
--doar daca are domiciliul in Romania, in caz contrar, se considera ca nu are privilegii.

CREATE OR REPLACE FUNCTION cere_pin(cine_cere PERSOANA.cod_persoana%TYPE, p_card_number CARD.card_number%TYPE, p_cnp PERSOANA.cnp%TYPE)
RETURN CARD.pin%TYPE
AS
    cnp_gresit_angajat EXCEPTION;
    cnp_gresit_client EXCEPTION;
    nu_detine_cont EXCEPTION; --are cnp-ul, are cardul, dar nu e detinatorul
    fara_privilegii EXCEPTION; --este angajat, dar nu este admin sau manager
    card_anonim EXCEPTION; --cardul exista dar nu e asociat unui cont, doar angajatii pot face rost de pin
    card_negasit EXCEPTION;
    PRAGMA EXCEPTION_INIT(card_negasit, -20010);
    
    v_cod_tara TARA.cod_tara%TYPE;
    v_cod_tara2 TARA.cod_tara%TYPE;
    v_cod_persoana PERSOANA.cod_persoana%TYPE;
    v_cod_cont CONT.cod_cont%TYPE;
    v_pin CARD.pin%TYPE;
    
    v_cod_sediu SEDIU.cod_sediu%TYPE;
    v_cnp PERSOANA.cnp%TYPE;
    v_aux PLS_INTEGER;
    v_aux2 PLS_INTEGER;
BEGIN
    GOTO inceput;
    <<verificare_angajat>>
    --folosim count ca sa nu dea NO_DATA_FOUND
    --COUNT() poate da doar 0 sau 1 in acest caz pentru ca avem cine_cere cheie primara
    SELECT MAX(a.cod_sediu), MAX(l.cod_tara), MAX(p.cnp), COUNT(a.cod_persoana), MAX(DECODE(UPPER(a.cod_job), 'MANAGER', 1, 'ADMIN', 1, 0))
    INTO v_cod_sediu, v_cod_tara2, v_cnp, v_aux, v_aux2
    FROM ANGAJAT a, PERSOANA p, LOCATIE l
    WHERE p.cod_persoana = cine_cere AND a.cod_persoana = cine_cere AND p.cod_locatie = l.cod_locatie;
    
    IF v_aux = 0 THEN --nu exista angajatul
        IF v_cod_cont IS NULL THEN --cardul este anonim
            RAISE card_anonim;
        ELSE --angajatul nu exista dar un proprietar are daca a ajuns aici
            RAISE nu_detine_cont;
        END IF;
    ELSIF v_aux2 = 0 OR (v_cod_sediu IS NULL AND v_cod_tara2 != v_cod_tara) THEN --angajatul exista, dar nu este admin sau manager valid
        RAISE fara_privilegii;
    ELSIF v_cnp != p_cnp THEN --e angajat cu privilegii, dar n-a trecut validarea identitatii
        RAISE cnp_gresit_angajat;
    ELSE --in sfarsit a trecut si el toate validarile
        RETURN v_pin;
    END IF;
    
    <<inceput>>
    SELECT cod_tara INTO v_cod_tara FROM TARA WHERE lower(nume_tara) LIKE 'romania';
    
    BEGIN
        SELECT cod_cont, pin INTO v_cod_cont, v_pin FROM CARD WHERE card_number LIKE p_card_number;
        IF v_cod_cont IS NULL THEN
            --este un card anonim, verificam daca este angajat valid, altfel erori
            
            --acolo va da fie eroare fie return
            GOTO verificare_angajat;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20010, 'Cardul introdus nu exista.');
    END;
    
    --daca a ajuns aici, card-ul are un cont asociat
    BEGIN
        --luam persoana care detine contul
        SELECT p.cod_persoana, cnp INTO v_cod_persoana, v_cnp FROM PERSOANA p, CONT c WHERE p.cod_persoana = c.cod_persoana AND c.cod_cont = v_cod_cont;
        
        IF v_cod_persoana != cine_cere THEN
            GOTO verificare_angajat;
        ELSIF v_cnp != p_cnp THEN
            RAISE cnp_gresit_client;
        END IF;
    EXCEPTION
        --nu ar trebui sa se intample datorita cheilor externe, stiind ca v_cod_cont este nenul.
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20011, 'Detinatorul cardului este definit dar cumva nu exista');
    END;
    RETURN v_pin;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20012, 'Romania nu se afla in lista tarilor, reparati.');
    WHEN cnp_gresit_angajat THEN
        RAISE_APPLICATION_ERROR(-20013, 'Validarea identificarii angajatului a esuat.');
    WHEN cnp_gresit_client THEN
        RAISE_APPLICATION_ERROR(-20014, 'Validarea identificarii clientului a esuat.');
    WHEN nu_detine_cont THEN
        RAISE_APPLICATION_ERROR(-20015, 'Persoana nu este angajat si nici nu detine contul asociat cardului introdus.');
    WHEN fara_privilegii THEN
        RAISE_APPLICATION_ERROR(-20016, 'Angajatul nu are privilegiile necesare de a obtine PIN-ul acestui card.');
    WHEN card_anonim THEN
        RAISE_APPLICATION_ERROR(-20017, 'Cardul este anonim, iar utilizatorul nu este un angajat.');
    WHEN card_negasit THEN
        RAISE_APPLICATION_ERROR(-20018, 'Numarul introdus nu corespunde niciunui card.');

    WHEN OTHERS THEN
        RAISE;
END;
/

--clientul 1 cere pin-ul pentru cardul sau, folosind cnp-ul corect si numarul de card corect
SELECT cere_pin(1, '4532962746090018', '2870816526255') pin FROM DUAL;

--clientul 1 cere pentru cardul sau, dar cnp-ul este gresit
SELECT cere_pin(1, '4532962746090018', '2870816526256') pin FROM DUAL;

--clientul 1 cere pentru cardul sau, dar numarul de card este gresit
SELECT cere_pin(1, '4532962746090019', '2870816526255') pin FROM DUAL;

--clientul 1 cere pentru cardul altui client
SELECT cere_pin(1, '5336340664664640', '2870816526255') pin FROM DUAL;

--managerul (id 16) cere pentru cardul clientul 1, cu toate datele corecte
SELECT cere_pin(16, '4532962746090018', '1950122298018') pin FROM DUAL;

--managerul (id 16) cere pentru cardul clientul 1, cu cnp-ul gresit
SELECT cere_pin(16, '4532962746090018', '1950122298011') pin FROM DUAL;

--casierul cu id-ul 21 incearca sa obtina pin-ul cardului clientului 1
SELECT cere_pin(21, '4532962746090018', '1950122298018') pin FROM DUAL;

COMMIT;

--pentru a testa card_anonim, facem un card anonim, cel cu cod_number-ul: 5491696102956307
UPDATE CARD SET cod_cont = NULL WHERE card_number LIKE '5491696102956307';

--clientul apeleaza cardul anonim
SELECT cere_pin(1, '5491696102956307', '2870816526255') pin FROM DUAL;

--managerul apeleaza cardul anonim
SELECT cere_pin(16, '5491696102956307', '1950122298018') pin FROM DUAL;

--sa testam si eroarea care "invalideaza" intreaga functie, inexistenta Romaniei
UPDATE TARA SET nume_tara = 'Romania2' WHERE lower(nume_tara) = 'romania';

--clientul 1, cardul sau, date corecte
SELECT cere_pin(1, '4532962746090018', '2870816526255') pin FROM DUAL;

ROLLBACK;



--9. Formulati in limbaj natural o problema pe care sa o rezolvati folosind
--   un subprogram stocat independent de tip procedura care sa utilizeze
--   intr-o singura comanda SQL 5 dintre tabelele definite. Tratati toate
--   exceptiile care pot aparea, incluzand exceptiile NO_DATA_FOUND si
--   TOO_MANY_ROWS. Apelati subprogramul astfel incat sa evidentiati toate
--   cazurile tratate.

--Problema:
--Managerul doreste sa faca iar modificari...
--De data asta are nevoie de informatii despre sediile bancii.
--Dandu-se un nume de tara dorim sa obtinem statistici.
--Daca nu avem sediu in tara respectiva, vrem sa stim cate persoane inregistrate
--locuiesc acolo si diverse detalii despre acestea.
--Daca avem un sediu, vrem sa stim detalii despre contractele semnate la acel sediu.
--Daca avem mai multe sedii, vrem sa stim detalii despre angajatii
--care lucreaza fizic in tara respectiva.


--alternativa ex9 select 1
--SELECT nume, prenume, a.cod_job, cl.tag_utilizator, COUNT(c.cod_persoana) nrConturi, l.oras
--FROM PERSOANA p, LOCATIE l, ANGAJAT a, CLIENT cl, CONT c
--WHERE p.cod_persoana = a.cod_persoana(+) AND cl.cod_persoana(+) = p.cod_persoana
--AND c.cod_persoana(+) = p.cod_persoana AND p.cod_locatie = l.cod_locatie AND l.cod_tara = 1
--GROUP BY p.cod_persoana, nume, prenume, a.cod_job, cl.tag_utilizator, l.oras;

CREATE OR REPLACE PROCEDURE statistici_sedii(p_nume_tara TARA.nume_tara%TYPE)
AS
    v_cod_tara TARA.cod_tara%TYPE;
    tara_inexistenta EXCEPTION;
    v_cod_sediu SEDIU.cod_sediu%TYPE;
    
    v_aux PLS_INTEGER;
BEGIN
    BEGIN
        SELECT cod_tara INTO v_cod_tara FROM TARA WHERE nume_tara = p_nume_tara;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE tara_inexistenta;
        --nu poate da TOO_MANY_ROWS, am pus UNIQUE pe nume_tara
    END;
    
    SELECT cod_sediu INTO v_cod_sediu FROM SEDIU s, LOCATIE l WHERE s.cod_locatie = l.cod_locatie AND l.cod_tara = v_cod_tara;
    dbms_output.put_line('Un sediu gasit in tara ' || INITCAP(p_nume_tara));
    dbms_output.put_line('La sediul din aceasta tara au fost semnate urmatoarele contracte: ');
    FOR v_detalii_contract IN (SELECT p1.nume angajat_nume, p1.prenume angajat_prenume, a.cod_job, p2.nume client_nume, p2.prenume client_prenume, c.tag_utilizator tag_client, c2.titlu_contract
        FROM SEMNEAZA_UN_CONTRACT s, ANGAJAT a, CLIENT c, TIP_CONTRACT c2, PERSOANA p1, PERSOANA p2
        WHERE s.cod_client = c.cod_persoana AND s.cod_angajat = a.cod_persoana AND s.tip_contract = c2.tip_contract
        AND p1.cod_persoana = a.cod_persoana AND p2.cod_persoana = c.cod_persoana AND s.cod_sediu = v_cod_sediu)
    LOOP
        dbms_output.put_line('> Contract de ''' || v_detalii_contract.titlu_contract || ''' pentru clientul ' || v_detalii_contract.client_nume || ' ' || v_detalii_contract.client_prenume
            || '(' || v_detalii_contract.tag_client || ') semnat de angajatul ' || v_detalii_contract.angajat_nume || ' ' || v_detalii_contract.angajat_prenume
            || '(' || v_detalii_contract.cod_job || ')'
        );
    END LOOP;
    
EXCEPTION
    WHEN tara_inexistenta THEN
        dbms_output.put_line('Oops, tara introdusa nu se afla in baza de date.');
    WHEN NO_DATA_FOUND THEN
        dbms_output.put_line('> Nu s-a gasit niciun sediu in tara ' || INITCAP(p_nume_tara));
        dbms_output.put_line('In aceasta tara avem inregistrati utilizatorii: ');
        --daca nu considerati ca aceasta este o singura instructiune
        --care contine 5 tabele pentru ca sunt subcereri
        --aveti <<alternativa ex9 select 1>> mai sus care e doar join-uri
        --si returneaza acelasi lucru
        v_aux := 0;
        FOR v_detalii_persoana IN (SELECT nume, prenume,
            (SELECT cod_job FROM ANGAJAT a WHERE a.cod_persoana(+) = p.cod_persoana) cod_job,
            (SELECT tag_utilizator FROM CLIENT cl WHERE cl.cod_persoana(+) = p.cod_persoana) tag_utilizator,
            (SELECT COUNT(cod_cont) FROM CONT c WHERE c.cod_persoana = p.cod_persoana) nrConturi,
            l.oras
            FROM PERSOANA p, LOCATIE l WHERE p.cod_locatie = l.cod_locatie AND l.cod_tara = v_cod_tara)
        LOOP
            dbms_output.put('>> ' || v_detalii_persoana.nume || ' ' || v_detalii_persoana.prenume || ' ');
            IF v_detalii_persoana.tag_utilizator IS NOT NULL THEN
                dbms_output.put('este client (cu tag-ul ''' || v_detalii_persoana.tag_utilizator ||  '''), ');
            END IF;
            IF v_detalii_persoana.cod_job IS NOT NULL THEN
                dbms_output.put('este angajat (avand job-ul cu codul ''' || v_detalii_persoana.cod_job || '''), ');
            END IF;
            dbms_output.put('are ' || v_detalii_persoana.nrConturi || ' conturi si este din orasul ' || v_detalii_persoana.oras);
            dbms_output.new_line;
            v_aux := v_aux + 1;
        END LOOP;
        IF v_aux = 0 THEN
            dbms_output.put_line('Nu exista utilizatori inregistrati in aceasta tara.');
        ELSE
            dbms_output.put_line('Un total de ' || v_aux || ' utilizatori inregistrati in aceasta tara.');
        END IF;
    WHEN TOO_MANY_ROWS THEN
        dbms_output.put_line('> In tara ' || INITCAP(p_nume_tara) || ' exista mai multe sedii.');
        dbms_output.put_line('Activitatea angajatilor care lucreaza fizic in aceasta tara: ');
        v_aux := 0;
        FOR v_detalii_angajat IN (
            SELECT nume, prenume, denumire_job,
                (SELECT COUNT(cod_persoana) FROM TRANZACTIE_EXTERNA t WHERE t.cod_persoana = a.cod_persoana) nrTranzactiiExterne,
                (SELECT COUNT(cod_angajat) FROM SEMNEAZA_UN_CONTRACT sc WHERE sc.cod_angajat = a.cod_persoana) nrContracte
            FROM ANGAJAT a, PERSOANA p, JOB j, SEDIU s, LOCATIE l
            WHERE p.cod_persoana = a.cod_persoana AND j.cod_job = a.cod_job
            AND a.cod_sediu = s.cod_sediu AND s.cod_locatie = l.cod_locatie
            AND l.cod_tara = v_cod_tara)
        LOOP
            dbms_output.put_line('> Angajatul ' || v_detalii_angajat.nume || ' ' || v_detalii_angajat.prenume || ' este ' || v_detalii_angajat.denumire_job
                || ', a efectuat ' || v_detalii_angajat.nrTranzactiiExterne || ' tranzactii externe si a semnat ' || v_detalii_angajat.nrContracte || ' contracte.'
            );
            v_aux := 1;
        END LOOP;
        IF v_aux = 0 THEN
            dbms_output.put_line('Nu exista angajati in aceasta tara.');
        END IF;
END;
/

EXECUTE statistici_sedii('TaraInexistenta');
EXECUTE statistici_sedii('Japonia');
EXECUTE statistici_sedii('Olanda');
EXECUTE statistici_sedii('Romania');


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

--13. Definiti un pachet care sa detina toate obiectele definite in cadrul proiectului

CREATE OR REPLACE PACKAGE cerinte_proiect
AS
    --ex6
    PROCEDURE activitate_utilizatori(activ_max PLS_INTEGER DEFAULT -1);
    --ex7
    PROCEDURE info_client(tag_utilizator CLIENT.tag_utilizator%TYPE);
    --ex8
    FUNCTION cere_pin(cine_cere PERSOANA.cod_persoana%TYPE, p_card_number CARD.card_number%TYPE, p_cnp PERSOANA.cnp%TYPE) RETURN CARD.pin%TYPE;
    --ex9
    PROCEDURE statistici_sedii(p_nume_tara TARA.nume_tara%TYPE);
END cerinte_proiect;
/


CREATE OR REPLACE PACKAGE BODY cerinte_proiect
AS
    PROCEDURE activitate_utilizatori(activ_max PLS_INTEGER DEFAULT -1)
    AS
        TYPE t_info_user IS RECORD(
            email PERSOANA.email%TYPE,
            username CLIENT.tag_utilizator%TYPE,
            punctaj PLS_INTEGER DEFAULT 0
        );
        
        TYPE t_idx IS TABLE OF t_info_user INDEX BY PLS_INTEGER;
        v_useri t_idx;
        v_index_user PLS_INTEGER;
        
        TYPE t_punctaj IS RECORD(
            cod_persoana PERSOANA.cod_persoana%TYPE,
            punctaj PLS_INTEGER
        );
        
        TYPE t_imb_punctaj IS TABLE OF t_punctaj;
        v_adaos_punctaj t_imb_punctaj; --nu are rost sa initializam, folosim bulk collect
        
        TYPE t_info_user_cu_cod IS RECORD(
            cod_persoana PERSOANA.cod_persoana%TYPE,
            email PERSOANA.email%TYPE,
            username CLIENT.tag_utilizator%TYPE
        );
        
        TYPE t_vector_info_user IS VARRAY(2000) OF t_info_user_cu_cod; --suntem o banca mica, ne ajunge maxim 2000, marim la nevoie
        v_aux_1 t_vector_info_user; --nu are rost sa initializam, folosim bulk collect
    BEGIN
        --ne abtinem din a folosi un ciclu cursor, doar de dragul de a folosi un vector
        SELECT p.cod_persoana, email, tag_utilizator BULK COLLECT INTO v_aux_1 FROM PERSOANA p, CLIENT c WHERE p.cod_persoana = c.cod_persoana;
        
        IF v_aux_1.count = 0 THEN --nu exista utilizatori, nu are rost sa facem calcule
            dbms_output.put_line('Nu exista utilizatori care sa aiba activitate.');
            RETURN;
        END IF;
    
        FOR i IN 1..v_aux_1.count LOOP
            v_useri(v_aux_1(i).cod_persoana).email := v_aux_1(i).email;
            v_useri(v_aux_1(i).cod_persoana).username := v_aux_1(i).username;
        END LOOP;
        
        --calculam punctele din depozite/retrageri/transferuri trimise si stocam in v_adaos_punctaj
        WITH
        tranzactiiPerCont AS (SELECT cod_cont, COUNT(cod_tranzactie) tranzactii
                              FROM TRANZACTIE WHERE DECODE(lower(tip_tranzactie), 'depozit', 1, 'retragere', 1, 'transfer_trimis', 1, 0) = 1
                              GROUP BY cod_cont)
        SELECT c.cod_persoana, SUM(tranzactii) BULK COLLECT INTO v_adaos_punctaj FROM CONT c, tranzactiiPerCont
        WHERE c.cod_cont = tranzactiiPerCont.cod_cont GROUP BY c.cod_persoana;
        
    
        --fiind inserat cu bulk collect, stiu ca este dens
        FOR i IN 1..v_adaos_punctaj.count LOOP
            v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
            IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
                v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
            END IF;
        END LOOP;
    
        
        --calculam punctele pentru carduri detinute
        WITH
        carduriPerCont AS (SELECT cod_cont, COUNT(cod_card) carduri FROM CARD GROUP BY cod_cont)
        SELECT c.cod_persoana, SUM(carduri)*5 BULK COLLECT INTO v_adaos_punctaj FROM CONT c, carduriPerCont
        WHERE c.cod_cont = carduriPerCont.cod_cont GROUP BY c.cod_persoana;
        
        --acum va trebui sa verificam si daca exista persoana in lista
        --daca nu exista inseamna ca a fost scoasa pentru ca limita a fost depasita
        --la un pas anterior
        FOR i IN 1..v_adaos_punctaj.count LOOP
            IF NOT v_useri.exists(v_adaos_punctaj(i).cod_persoana) THEN
                CONTINUE;
            END IF;
            
            v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
            IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
                v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
            END IF;
        END LOOP;
        
        --schimbam din with in join pe 3 tabele
        SELECT c.cod_persoana, SUM(durata_luni)*2 BULK COLLECT INTO v_adaos_punctaj 
        FROM DEPOZIT_ECONOMII dE, DOBANDA d, CONT c WHERE c.cod_cont = dE.cod_cont AND dE.cod_dobanda = d.cod_dobanda GROUP BY c.cod_persoana;
        
        --neschimbat fata de for-ul anterior
        FOR i IN 1..v_adaos_punctaj.count LOOP
            IF NOT v_useri.exists(v_adaos_punctaj(i).cod_persoana) THEN
                CONTINUE;
            END IF;
            
            v_useri(v_adaos_punctaj(i).cod_persoana).punctaj := v_useri(v_adaos_punctaj(i).cod_persoana).punctaj + v_adaos_punctaj(i).punctaj;
            IF activ_max != -1 AND v_useri(v_adaos_punctaj(i).cod_persoana).punctaj>activ_max THEN
                v_useri.delete(v_adaos_punctaj(i).cod_persoana); --pragul superior s-a depasit, nu ne mai intereseaza utilizatorul
            END IF;
        END LOOP;
        
        IF v_useri.first IS NULL THEN
            dbms_output.put_line('Nu exista utilizatori care sa aiba activitate.');
            RETURN;
        END IF;
        
        dbms_output.put_line('=========== Puncte de activitate =============');
        v_index_user := v_useri.first;
        WHILE v_index_user IS NOT NULL LOOP
            dbms_output.put_line('> ' || v_useri(v_index_user).username || ' (' || v_useri(v_index_user).email || ') - ' || v_useri(v_index_user).punctaj);
            v_index_user := v_useri.next(v_index_user);
        END LOOP;
    END;

    PROCEDURE info_client(tag_utilizator CLIENT.tag_utilizator%TYPE)
    AS
        CURSOR personal_client(p_tag_utilizator CLIENT.tag_utilizator%TYPE) IS SELECT p.cod_persoana, nume, prenume, email, gen
            FROM PERSOANA p, CLIENT c WHERE p.cod_persoana = c.cod_persoana AND c.tag_utilizator = p_tag_utilizator;
        
        CURSOR conturi(cod_client PERSOANA.cod_persoana%TYPE) IS SELECT cod_cont, iban, sold,
                    CURSOR(SELECT cod_card, tip, card_number FROM CARD WHERE CARD.cod_cont = CONT.cod_cont)
                FROM CONT WHERE cod_persoana = cod_client;
                
        CURSOR tranzactii_cu_card(p_cod_card CARD.cod_card%TYPE, p_cod_cont CONT.cod_cont%TYPE) IS
            WITH tranzactii AS (
                    (SELECT cod_tranzactie FROM DEPOZIT d WHERE d.cod_cont = cod_cont AND d.cod_card = p_cod_card)
                    UNION ALL
                    (SELECT cod_tranzactie FROM RETRAGERE r WHERE r.cod_cont = cod_cont AND r.cod_card = p_cod_card)
                )
            SELECT data_tranzactie, tip_tranzactie, valoare FROM TRANZACTIE t
            WHERE t.cod_cont = p_cod_cont AND t.cod_tranzactie IN (SELECT * FROM tranzactii);
        
        TYPE t_personal_info IS RECORD(
            cod_persoana PERSOANA.cod_persoana%TYPE,
            nume PERSOANA.nume%TYPE,
            prenume PERSOANA.prenume%TYPE,
            email PERSOANA.email%TYPE,
            gen PERSOANA.gen%TYPE
        );
        
        v_personal_info t_personal_info;
        
        v_cod_cont CONT.cod_cont%TYPE;
        v_iban CONT.iban%TYPE;
        v_sold CONT.sold%TYPE;
        carduri SYS_REFCURSOR;
        
        v_cod_card CARD.cod_card%TYPE;
        v_tip CARD.tip%TYPE;
        v_card_number CARD.card_number%TYPE;
        
        v_verifica BOOLEAN;
    BEGIN
        OPEN personal_client(tag_utilizator);
        FETCH personal_client INTO v_personal_info;
        IF personal_client%ROWCOUNT = 0 THEN
            CLOSE personal_client;
            RAISE_APPLICATION_ERROR(-20008, 'Nu s-a gasit persoana cu tag-ul ' || tag_utilizator);
        END IF;
        CLOSE personal_client;
        
        --a trecut de primul cursor, avem date in v_personal_info
        dbms_output.put_line('=========== Info Client ===========');
        dbms_output.put_line('> Nume: ' || v_personal_info.nume);
        dbms_output.put_line('> Prenume: ' || v_personal_info.prenume);
        dbms_output.put_line('> Email: ' || v_personal_info.email);
        dbms_output.put_line('> Gen: ' || UPPER(v_personal_info.gen));
        dbms_output.new_line;
        OPEN conturi(v_personal_info.cod_persoana);
        LOOP
            FETCH conturi INTO v_cod_cont, v_iban, v_sold, carduri;
            EXIT WHEN conturi%NOTFOUND;
            
            dbms_output.put_line('-=-=-=- Cont Info -=-=-=-');
            dbms_output.put_line('>> IBAN: ' || v_iban);
            dbms_output.put_line('>> SOLD: ' || v_sold);
            dbms_output.new_line;
            
            LOOP
                FETCH carduri INTO v_cod_card, v_tip, v_card_number;
                EXIT WHEN carduri%NOTFOUND;
                dbms_output.put_line('----- Card Info -----');
                dbms_output.put_line('>>> Card Number: ' || v_card_number);
                dbms_output.put_line('>>> Tip: ' || v_tip);
                dbms_output.put_line('>>> Tranzactii: ');
                v_verifica := FALSE;
                FOR v_tranzactie_info IN tranzactii_cu_card(v_cod_card, v_cod_cont) LOOP
                    dbms_output.put_line(' - Tranzactie (' || v_tranzactie_info.tip_tranzactie || ') efectuata pe ' || v_tranzactie_info.data_tranzactie || ' in valoare de ' || v_tranzactie_info.valoare);
                    v_verifica := TRUE;
                END LOOP;
                IF NOT v_verifica THEN
                    dbms_output.put_line('>>>> Nu are tranzactii efectuate cu acest card');
                END IF;
                dbms_output.new_line;
            END LOOP;
            IF carduri%ROWCOUNT = 0 THEN
                dbms_output.put_line('Clientul nu are carduri.');
            END IF;
            CLOSE carduri;
        END LOOP;
        
        IF conturi%ROWCOUNT = 0 THEN
            dbms_output.put_line('Clientul nu are conturi.');
        END IF;
        CLOSE conturi;
    END;

    FUNCTION cere_pin(cine_cere PERSOANA.cod_persoana%TYPE, p_card_number CARD.card_number%TYPE, p_cnp PERSOANA.cnp%TYPE) RETURN CARD.pin%TYPE
    AS
        cnp_gresit_angajat EXCEPTION;
        cnp_gresit_client EXCEPTION;
        nu_detine_cont EXCEPTION; --are cnp-ul, are cardul, dar nu e detinatorul
        fara_privilegii EXCEPTION; --este angajat, dar nu este admin sau manager
        card_anonim EXCEPTION; --cardul exista dar nu e asociat unui cont, doar angajatii pot face rost de pin
        card_negasit EXCEPTION;
        PRAGMA EXCEPTION_INIT(card_negasit, -20010);
        
        v_cod_tara TARA.cod_tara%TYPE;
        v_cod_tara2 TARA.cod_tara%TYPE;
        v_cod_persoana PERSOANA.cod_persoana%TYPE;
        v_cod_cont CONT.cod_cont%TYPE;
        v_pin CARD.pin%TYPE;
        
        v_cod_sediu SEDIU.cod_sediu%TYPE;
        v_cnp PERSOANA.cnp%TYPE;
        v_aux PLS_INTEGER;
        v_aux2 PLS_INTEGER;
    BEGIN
        GOTO inceput;
        <<verificare_angajat>>
        --folosim count ca sa nu dea NO_DATA_FOUND
        --COUNT() poate da doar 0 sau 1 in acest caz pentru ca avem cine_cere cheie primara
        SELECT MAX(a.cod_sediu), MAX(l.cod_tara), MAX(p.cnp), COUNT(a.cod_persoana), MAX(DECODE(UPPER(a.cod_job), 'MANAGER', 1, 'ADMIN', 1, 0))
        INTO v_cod_sediu, v_cod_tara2, v_cnp, v_aux, v_aux2
        FROM ANGAJAT a, PERSOANA p, LOCATIE l
        WHERE p.cod_persoana = cine_cere AND a.cod_persoana = cine_cere AND p.cod_locatie = l.cod_locatie;
        
        IF v_aux = 0 THEN --nu exista angajatul
            IF v_cod_cont IS NULL THEN --cardul este anonim
                RAISE card_anonim;
            ELSE --angajatul nu exista dar un proprietar are daca a ajuns aici
                RAISE nu_detine_cont;
            END IF;
        ELSIF v_aux2 = 0 OR (v_cod_sediu IS NULL AND v_cod_tara2 != v_cod_tara) THEN --angajatul exista, dar nu este admin sau manager valid
            RAISE fara_privilegii;
        ELSIF v_cnp != p_cnp THEN --e angajat cu privilegii, dar n-a trecut validarea identitatii
            RAISE cnp_gresit_angajat;
        ELSE --in sfarsit a trecut si el toate validarile
            RETURN v_pin;
        END IF;
        
        <<inceput>>
        SELECT cod_tara INTO v_cod_tara FROM TARA WHERE lower(nume_tara) LIKE 'romania';
        
        BEGIN
            SELECT cod_cont, pin INTO v_cod_cont, v_pin FROM CARD WHERE card_number LIKE p_card_number;
            IF v_cod_cont IS NULL THEN
                --este un card anonim, verificam daca este angajat valid, altfel erori
                
                --acolo va da fie eroare fie return
                GOTO verificare_angajat;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20010, 'Cardul introdus nu exista.');
        END;
        
        --daca a ajuns aici, card-ul are un cont asociat
        BEGIN
            --luam persoana care detine contul
            SELECT p.cod_persoana, cnp INTO v_cod_persoana, v_cnp FROM PERSOANA p, CONT c WHERE p.cod_persoana = c.cod_persoana AND c.cod_cont = v_cod_cont;
            
            IF v_cod_persoana != cine_cere THEN
                GOTO verificare_angajat;
            ELSIF v_cnp != p_cnp THEN
                RAISE cnp_gresit_client;
            END IF;
        EXCEPTION
            --nu ar trebui sa se intample datorita cheilor externe, stiind ca v_cod_cont este nenul.
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20011, 'Detinatorul cardului este definit dar cumva nu exista');
        END;
        RETURN v_pin;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20012, 'Romania nu se afla in lista tarilor, reparati.');
        WHEN cnp_gresit_angajat THEN
            RAISE_APPLICATION_ERROR(-20013, 'Validarea identificarii angajatului a esuat.');
        WHEN cnp_gresit_client THEN
            RAISE_APPLICATION_ERROR(-20014, 'Validarea identificarii clientului a esuat.');
        WHEN nu_detine_cont THEN
            RAISE_APPLICATION_ERROR(-20015, 'Persoana nu este angajat si nici nu detine contul asociat cardului introdus.');
        WHEN fara_privilegii THEN
            RAISE_APPLICATION_ERROR(-20016, 'Angajatul nu are privilegiile necesare de a obtine PIN-ul acestui card.');
        WHEN card_anonim THEN
            RAISE_APPLICATION_ERROR(-20017, 'Cardul este anonim, iar utilizatorul nu este un angajat.');
        WHEN card_negasit THEN
            RAISE_APPLICATION_ERROR(-20018, 'Numarul introdus nu corespunde niciunui card.');
    
        WHEN OTHERS THEN
            RAISE;
    END;

    PROCEDURE statistici_sedii(p_nume_tara TARA.nume_tara%TYPE)
    AS
        v_cod_tara TARA.cod_tara%TYPE;
        tara_inexistenta EXCEPTION;
        v_cod_sediu SEDIU.cod_sediu%TYPE;
        
        v_aux PLS_INTEGER;
    BEGIN
        BEGIN
            SELECT cod_tara INTO v_cod_tara FROM TARA WHERE nume_tara = p_nume_tara;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE tara_inexistenta;
            --nu poate da TOO_MANY_ROWS, am pus UNIQUE pe nume_tara
        END;
        
        SELECT cod_sediu INTO v_cod_sediu FROM SEDIU s, LOCATIE l WHERE s.cod_locatie = l.cod_locatie AND l.cod_tara = v_cod_tara;
        dbms_output.put_line('Un sediu gasit in tara ' || INITCAP(p_nume_tara));
        dbms_output.put_line('La sediul din aceasta tara au fost semnate urmatoarele contracte: ');
        FOR v_detalii_contract IN (SELECT p1.nume angajat_nume, p1.prenume angajat_prenume, a.cod_job, p2.nume client_nume, p2.prenume client_prenume, c.tag_utilizator tag_client, c2.titlu_contract
            FROM SEMNEAZA_UN_CONTRACT s, ANGAJAT a, CLIENT c, TIP_CONTRACT c2, PERSOANA p1, PERSOANA p2
            WHERE s.cod_client = c.cod_persoana AND s.cod_angajat = a.cod_persoana AND s.tip_contract = c2.tip_contract
            AND p1.cod_persoana = a.cod_persoana AND p2.cod_persoana = c.cod_persoana AND s.cod_sediu = v_cod_sediu)
        LOOP
            dbms_output.put_line('> Contract de ''' || v_detalii_contract.titlu_contract || ''' pentru clientul ' || v_detalii_contract.client_nume || ' ' || v_detalii_contract.client_prenume
                || '(' || v_detalii_contract.tag_client || ') semnat de angajatul ' || v_detalii_contract.angajat_nume || ' ' || v_detalii_contract.angajat_prenume
                || '(' || v_detalii_contract.cod_job || ')'
            );
        END LOOP;
        
    EXCEPTION
        WHEN tara_inexistenta THEN
            dbms_output.put_line('Oops, tara introdusa nu se afla in baza de date.');
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('> Nu s-a gasit niciun sediu in tara ' || INITCAP(p_nume_tara));
            dbms_output.put_line('In aceasta tara avem inregistrati utilizatorii: ');
            --daca nu considerati ca aceasta este o singura instructiune
            --care contine 5 tabele pentru ca sunt subcereri
            --aveti <<alternativa ex9 select 1>> mai sus care e doar join-uri
            --si returneaza acelasi lucru
            v_aux := 0;
            FOR v_detalii_persoana IN (SELECT nume, prenume,
                (SELECT cod_job FROM ANGAJAT a WHERE a.cod_persoana(+) = p.cod_persoana) cod_job,
                (SELECT tag_utilizator FROM CLIENT cl WHERE cl.cod_persoana(+) = p.cod_persoana) tag_utilizator,
                (SELECT COUNT(cod_cont) FROM CONT c WHERE c.cod_persoana = p.cod_persoana) nrConturi,
                l.oras
                FROM PERSOANA p, LOCATIE l WHERE p.cod_locatie = l.cod_locatie AND l.cod_tara = v_cod_tara)
            LOOP
                dbms_output.put('>> ' || v_detalii_persoana.nume || ' ' || v_detalii_persoana.prenume || ' ');
                IF v_detalii_persoana.tag_utilizator IS NOT NULL THEN
                    dbms_output.put('este client (cu tag-ul ''' || v_detalii_persoana.tag_utilizator ||  '''), ');
                END IF;
                IF v_detalii_persoana.cod_job IS NOT NULL THEN
                    dbms_output.put('este angajat (avand job-ul cu codul ''' || v_detalii_persoana.cod_job || '''), ');
                END IF;
                dbms_output.put('are ' || v_detalii_persoana.nrConturi || ' conturi si este din orasul ' || v_detalii_persoana.oras);
                dbms_output.new_line;
                v_aux := v_aux + 1;
            END LOOP;
            IF v_aux = 0 THEN
                dbms_output.put_line('Nu exista utilizatori inregistrati in aceasta tara.');
            ELSE
                dbms_output.put_line('Un total de ' || v_aux || ' utilizatori inregistrati in aceasta tara.');
            END IF;
        WHEN TOO_MANY_ROWS THEN
            dbms_output.put_line('> In tara ' || INITCAP(p_nume_tara) || ' exista mai multe sedii.');
            dbms_output.put_line('Activitatea angajatilor care lucreaza fizic in aceasta tara: ');
            v_aux := 0;
            FOR v_detalii_angajat IN (
                SELECT nume, prenume, denumire_job,
                    (SELECT COUNT(cod_persoana) FROM TRANZACTIE_EXTERNA t WHERE t.cod_persoana = a.cod_persoana) nrTranzactiiExterne,
                    (SELECT COUNT(cod_angajat) FROM SEMNEAZA_UN_CONTRACT sc WHERE sc.cod_angajat = a.cod_persoana) nrContracte
                FROM ANGAJAT a, PERSOANA p, JOB j, SEDIU s, LOCATIE l
                WHERE p.cod_persoana = a.cod_persoana AND j.cod_job = a.cod_job
                AND a.cod_sediu = s.cod_sediu AND s.cod_locatie = l.cod_locatie
                AND l.cod_tara = v_cod_tara)
            LOOP
                dbms_output.put_line('> Angajatul ' || v_detalii_angajat.nume || ' ' || v_detalii_angajat.prenume || ' este ' || v_detalii_angajat.denumire_job
                    || ', a efectuat ' || v_detalii_angajat.nrTranzactiiExterne || ' tranzactii externe si a semnat ' || v_detalii_angajat.nrContracte || ' contracte.'
                );
                v_aux := 1;
            END LOOP;
            IF v_aux = 0 THEN
                dbms_output.put_line('Nu exista angajati in aceasta tara.');
            END IF;
    END;

END cerinte_proiect;
/

EXECUTE cerinte_proiect.activitate_utilizatori;
--lipsesc melis2_ si mihaita
EXECUTE cerinte_proiect.activitate_utilizatori(100);

EXECUTE cerinte_proiect.info_client('UnUserInexistent_');
EXECUTE cerinte_proiect.info_client('melis2_');

--clientul 1 cere pin-ul pentru cardul sau, folosind cnp-ul corect si numarul de card corect
SELECT cerinte_proiect.cere_pin(1, '4532962746090018', '2870816526255') pin FROM DUAL;
--clientul 1 cere pentru cardul sau, dar cnp-ul este gresit
SELECT cerinte_proiect.cere_pin(1, '4532962746090018', '2870816526256') pin FROM DUAL;
--managerul (id 16) cere pentru cardul clientul 1, cu toate datele corecte
SELECT cerinte_proiect.cere_pin(16, '4532962746090018', '1950122298018') pin FROM DUAL;

EXECUTE cerinte_proiect.statistici_sedii('TaraInexistenta');
EXECUTE cerinte_proiect.statistici_sedii('Japonia');
EXECUTE cerinte_proiect.statistici_sedii('Olanda');
EXECUTE cerinte_proiect.statistici_sedii('Romania');



--14. Definiti un pachet care sa includa tipuri de date complexe si obiecte necesare
--    unui flux de actiuni integrate, specifice bazei de date definite (minim 2
--    tipuri de date, minim 2 functii, minim 2 proceduri)

CREATE OR REPLACE PACKAGE utilitati_bancare
AS
    card_negasit EXCEPTION; 
    cont_negasit EXCEPTION;
    persoana_negasita EXCEPTION;
    insuficienti_bani EXCEPTION;
    ambiguitate EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(card_negasit, -20101);
    PRAGMA EXCEPTION_INIT(cont_negasit, -20102);
    PRAGMA EXCEPTION_INIT(persoana_negasita, -20103);
    PRAGMA EXCEPTION_INIT(insuficienti_bani, -20104);
    PRAGMA EXCEPTION_INIT(ambiguitate, -20105);

    TYPE info_locatie IS RECORD(
        cod_postal LOCATIE.cod_postal%TYPE,
        adresa LOCATIE.adresa%TYPE,
        oras LOCATIE.oras%TYPE,
        nume_tara TARA.nume_tara%TYPE
    );

    TYPE info_personal IS RECORD(
        nume PERSOANA.nume%TYPE,
        prenume PERSOANA.prenume%TYPE,
        email PERSOANA.email%TYPE,
        gen PERSOANA.gen%TYPE,
        locatie info_locatie
    );
    
    TYPE info_card IS RECORD(
        card_number CARD.card_number%TYPE,
        tip CARD.tip%TYPE
    );
    
    TYPE lista_carduri IS TABLE OF info_card;

    TYPE info_cont IS RECORD(
        iban CONT.iban%TYPE,
        sold CONT.sold%TYPE,
        carduri lista_carduri
    );
    
    TYPE lista_conturi IS TABLE OF info_cont;
    
    TYPE info_client IS RECORD(
        tag_utilizator CLIENT.tag_utilizator%TYPE,
        personal_data info_personal,
        conturi lista_conturi
    );
    
    TYPE info_contract IS RECORD(
        titlu_contract TIP_CONTRACT.titlu_contract%TYPE,
        client_data info_personal,
        angajat_data info_personal,
        locatie_semnat info_locatie
    );
    
    TYPE lista_contracte IS TABLE OF info_contract;
    
    TYPE info_angajat IS RECORD(
        job_titlu JOB.denumire_job%TYPE,
        personal_data info_personal,
        salariu ANGAJAT.salariu%TYPE,
        contracte_semnate lista_contracte
    );
    
    PROCEDURE depozit_bani(
        p_iban CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE,
        p_cod_bancomat DEPOZIT.cod_bancomat%TYPE,
        p_card_number CARD.card_number%TYPE
    );
    
    PROCEDURE retragere_bani(
        p_iban CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE,
        p_cod_bancomat DEPOZIT.cod_bancomat%TYPE,
        p_card_number CARD.card_number%TYPE
    );
    
    PROCEDURE transfer_bani(
        p_iban_sursa CONT.iban%TYPE,
        p_iban_destinatie CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE
    );
    
    FUNCTION get_client_info(tag_utilizator CLIENT.tag_utilizator%TYPE) RETURN info_client;
    
    FUNCTION get_angajat_info(p_nume PERSOANA.nume%TYPE, p_prenume PERSOANA.prenume%TYPE) RETURN info_angajat;
END utilitati_bancare;
/



CREATE OR REPLACE PACKAGE BODY utilitati_bancare
AS
    FUNCTION get_cod_persoana(p_nume PERSOANA.nume%TYPE, p_prenume PERSOANA.prenume%TYPE) RETURN PERSOANA.cod_persoana%TYPE
    AS
        v_cod PERSOANA.cod_persoana%TYPE;
    BEGIN
        SELECT cod_persoana INTO v_cod FROM PERSOANA WHERE nume = p_nume AND p_prenume = prenume;
        RETURN v_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20103, 'Persoana cautata nu a fost gasita.');
        WHEN TOO_MANY_ROWS THEN
            RAISE_APPLICATION_ERROR(-20105, 'Ambiguitate, sunt mai multe persoane cu numele si prenumele ' || p_nume || ' ' || p_prenume);
    END;
    
    FUNCTION get_cod_client(p_tag_utilizator CLIENT.tag_utilizator%TYPE) RETURN CLIENT.cod_persoana%TYPE
    AS
        v_cod CLIENT.cod_persoana%TYPE;
    BEGIN
        SELECT cod_persoana INTO v_cod FROM CLIENT WHERE tag_utilizator = p_tag_utilizator;
        RETURN v_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20103, 'Clientul cautat nu a fost gasit');
    END;
    
    FUNCTION get_cod_card(p_card_number CARD.card_number%TYPE) RETURN CARD.cod_card%TYPE
    AS
        v_cod CARD.cod_card%TYPE;
    BEGIN
        SELECT cod_card INTO v_cod FROM CARD WHERE card_number = p_card_number;
        RETURN v_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20101, 'Cardul cautat nu a fost gasit');
    END;
    
    FUNCTION get_cod_cont(p_iban CONT.iban%TYPE) RETURN CONT.cod_cont%TYPE
    AS
        v_cod CONT.cod_cont%TYPE;
    BEGIN
        SELECT cod_cont INTO v_cod FROM CONT WHERE iban = p_iban;
        RETURN v_cod;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20102, 'Contul cautat nu a fost gasit');
    END;
    
    
    PROCEDURE depozit_bani(
        p_iban CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE,
        p_cod_bancomat DEPOZIT.cod_bancomat%TYPE,
        p_card_number CARD.card_number%TYPE
    )
    AS
        tranzactie_id TRANZACTIE.cod_tranzactie%TYPE;
        v_cod_cont CONT.cod_cont%TYPE;
        v_cod_card CARD.cod_card%TYPE;
    BEGIN
        v_cod_cont := get_cod_cont(p_iban);
        v_cod_card := get_cod_card(p_card_number);
        SELECT tranzactii_contor+1 INTO tranzactie_id FROM ISTORIC i WHERE i.cod_cont = v_cod_cont;
        
        INSERT INTO TRANZACTIE VALUES(tranzactie_id, v_cod_cont, valoare, SYSDATE, 'depozit');
        INSERT INTO DEPOZIT VALUES(tranzactie_id, v_cod_cont, p_cod_bancomat, v_cod_card);
        UPDATE CONT c SET sold = sold + valoare WHERE c.cod_cont = v_cod_cont;
        dbms_output.put_line('Depozit realizat cu succes!');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20056, 'Contul exista dar nu are un istoric asociat.');
        --nu poate da too_many_rows, verificam dupa cheia primara
    END;
    
    
    PROCEDURE retragere_bani(
        p_iban CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE,
        p_cod_bancomat DEPOZIT.cod_bancomat%TYPE,
        p_card_number CARD.card_number%TYPE
    )
    AS
        tranzactie_id TRANZACTIE.cod_tranzactie%TYPE;
        v_sold CONT.sold%TYPE;
        v_cod_cont CONT.cod_cont%TYPE;
        v_cod_card CARD.cod_cont%TYPE;
    BEGIN
        v_cod_cont := get_cod_cont(p_iban);
        v_cod_card := get_cod_card(p_card_number);
        SELECT tranzactii_contor+1 INTO tranzactie_id FROM ISTORIC i WHERE i.cod_cont = v_cod_cont;
        --daca trece de select-ul anterior, sigur exista si contul fiind conectate prin foreign key
        SELECT sold INTO v_sold FROM CONT c WHERE c.cod_cont = v_cod_cont;
        IF v_sold < valoare THEN
            RAISE_APPLICATION_ERROR(-20104, 'Contul nu are suficienti bani pentru a efectua retragerea: ' || v_sold || ' < ' || valoare);
        END IF;
        
        INSERT INTO TRANZACTIE VALUES(tranzactie_id, v_cod_cont, valoare, SYSDATE, 'retragere');
        INSERT INTO RETRAGERE VALUES(tranzactie_id, v_cod_cont, p_cod_bancomat, v_cod_card);
        UPDATE CONT c SET sold = sold - valoare WHERE c.cod_cont = v_cod_cont;
        dbms_output.put_line('Retragere realizata cu succes!');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20056, 'Contul exista dar nu are un istoric asociat.');
        --nu poate da too_many_rows, verificam dupa cheia primara
    END;
    
    
    PROCEDURE transfer_bani(
        p_iban_sursa CONT.iban%TYPE,
        p_iban_destinatie CONT.iban%TYPE,
        valoare TRANZACTIE.valoare%TYPE
    )
    AS
        tranzactie_id TRANZACTIE.cod_tranzactie%TYPE;
        v_sold CONT.sold%TYPE;
        v_data DATE := SYSDATE;
        v_cod_cont_sursa CONT.cod_cont%TYPE;
        v_cod_cont_destinatie CONT.cod_cont%TYPE;
    BEGIN
        IF p_iban_sursa = p_iban_destinatie THEN
            RAISE_APPLICATION_ERROR(-20057, 'Nu se pot trimite bani dintr-un cont in acelasi cont.');
        END IF;
        
        BEGIN
            v_cod_cont_sursa := get_cod_cont(p_iban_sursa);
        EXCEPTION
            WHEN cont_negasit THEN
                RAISE_APPLICATION_ERROR(-20102, 'Contul sursa nu a fost gasit.');
        END;
        
        BEGIN
            v_cod_cont_destinatie := get_cod_cont(p_iban_destinatie);
        EXCEPTION
            WHEN cont_negasit THEN
                RAISE_APPLICATION_ERROR(-20102, 'Contul destinatie nu a fost gasit.');
        END;
        
        SAVEPOINT inceput_transfer;
        
        --inserare transfer trimis
        BEGIN
            SELECT tranzactii_contor+1 INTO tranzactie_id FROM ISTORIC i WHERE i.cod_cont = v_cod_cont_sursa;
            --daca trece de select-ul anterior, sigur exista si contul fiind conectate prin foreign key
            SELECT sold INTO v_sold FROM CONT c WHERE c.cod_cont = v_cod_cont_sursa;
            IF v_sold < valoare THEN
                RAISE_APPLICATION_ERROR(-20005, 'Contul nu are suficienti bani pentru a efectua transferul: ' || v_sold || ' < ' || valoare);
            END IF;
            
            INSERT INTO TRANZACTIE VALUES(tranzactie_id, v_cod_cont_sursa, valoare, v_data, 'transfer_trimis');
            INSERT INTO TRANSFER_TRIMIS VALUES(tranzactie_id, v_cod_cont_sursa, v_cod_cont_destinatie);
            UPDATE CONT c SET sold = sold - valoare WHERE c.cod_cont = v_cod_cont_sursa;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20005, 'Nu se poate efectua un transfer pentru un cont cu istoric inexistent. (1)');
        END;
        
        --inserare transfer primit
        BEGIN
            SELECT tranzactii_contor+1 INTO tranzactie_id FROM ISTORIC i WHERE i.cod_cont = v_cod_cont_destinatie;
            
            INSERT INTO TRANZACTIE VALUES(tranzactie_id, v_cod_cont_destinatie, valoare, v_data, 'transfer_primit');
            INSERT INTO TRANSFER_PRIMIT VALUES(tranzactie_id, v_cod_cont_destinatie, v_cod_cont_sursa);
            UPDATE CONT c SET sold = sold + valoare WHERE c.cod_cont = v_cod_cont_destinatie;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20006, 'Nu se poate efectua un transfer pentru un cont cu istoric inexistent. (2)');
        END;
        dbms_output.put_line('Transfer realizat cu succes!');
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO inceput_transfer; --daca orice parte a transferului esueaza, nu vrem sa ramana fragmente de transfer in baza de date
            RAISE;
    END;
    
    FUNCTION get_client_info(tag_utilizator CLIENT.tag_utilizator%TYPE) RETURN info_client
    AS
        deReturnat info_client;
        v_cod_client CLIENT.cod_persoana%TYPE;
        v_i PLS_INTEGER;
    BEGIN
        v_cod_client := get_cod_client(tag_utilizator);
        FOR v_record IN (
            SELECT cod_postal, adresa, oras, nume_tara, nume, prenume, tag_utilizator, email, gen
            FROM TARA t, LOCATIE l, PERSOANA p, CLIENT c WHERE
            t.cod_tara = l.cod_tara AND l.cod_locatie = p.cod_locatie AND
            p.cod_persoana = c.cod_persoana AND c.cod_persoana = v_cod_client
        )
        LOOP
            deReturnat.tag_utilizator := v_record.tag_utilizator;
            deReturnat.personal_data.nume := v_record.nume;
            deReturnat.personal_data.prenume := v_record.prenume;
            deReturnat.personal_data.email := v_record.email;
            deReturnat.personal_data.gen := v_record.gen;
            deReturnat.personal_data.locatie.cod_postal := v_record.cod_postal;
            deReturnat.personal_data.locatie.adresa := v_record.adresa;
            deReturnat.personal_data.locatie.oras := v_record.oras;
            deReturnat.personal_data.locatie.nume_tara := v_record.nume_tara;
            deReturnat.conturi := lista_conturi();
            
            v_i := 0;
            FOR v_record_conturi IN (SELECT cod_cont, sold, iban FROM CONT WHERE cod_persoana = v_cod_client) LOOP
                deReturnat.conturi.extend;
                v_i := v_i + 1;
                deReturnat.conturi(v_i).sold := v_record_conturi.sold;
                deReturnat.conturi(v_i).iban := v_record_conturi.iban;
                
                SELECT card_number, tip BULK COLLECT INTO deReturnat.conturi(v_i).carduri FROM CARD WHERE cod_cont = v_record_conturi.cod_cont;
                
            END LOOP;
            
        END LOOP;
        
        return deReturnat;
    END;
    
    FUNCTION get_angajat_info(p_nume PERSOANA.nume%TYPE, p_prenume PERSOANA.prenume%TYPE) RETURN info_angajat
    AS
        deReturnat info_angajat;
        v_cod PERSOANA.cod_persoana%TYPE;
        v_i PLS_INTEGER;
    BEGIN
        v_cod := get_cod_persoana(p_nume, p_prenume);
        deReturnat.personal_data.nume := p_nume;
        deReturnat.personal_data.prenume := p_prenume;
        FOR v_record IN (
            SELECT email, gen, cod_postal, adresa, oras, nume_tara, denumire_job, salariu
            FROM PERSOANA p, LOCATIE l, TARA t, ANGAJAT a, JOB j
            WHERE p.cod_persoana = a.cod_persoana AND l.cod_locatie = p.cod_locatie
            AND t.cod_tara = l.cod_tara AND a.cod_job = j.cod_job AND p.cod_persoana = v_cod
        )
        LOOP
            deReturnat.job_titlu := v_record.denumire_job;
            deReturnat.salariu := v_record.salariu;
            deReturnat.personal_data.email := v_record.email;
            deReturnat.personal_data.gen := v_record.gen;
            deReturnat.personal_data.locatie.cod_postal := v_record.cod_postal;
            deReturnat.personal_data.locatie.adresa := v_record.adresa;
            deReturnat.personal_data.locatie.oras := v_record.oras;
            deReturnat.personal_data.locatie.nume_tara := v_record.nume_tara;
            
            deReturnat.contracte_semnate := lista_contracte();
            
            v_i := 0;
            
            FOR v_record_contract_cu_sediu IN(
                SELECT nume, prenume, email, gen, l.cod_postal, l.adresa, l.oras, t.nume_tara, titlu_contract,
                ls.cod_postal sediu_cod_postal, ls.adresa sediu_adresa, ls.oras sediu_oras, ts.nume_tara sediu_nume_tara
                FROM PERSOANA p, CLIENT c, LOCATIE l, SEMNEAZA_UN_CONTRACT sc, TIP_CONTRACT tc, SEDIU s, LOCATIE ls, TARA t, TARA ts
                WHERE p.cod_persoana = c.cod_persoana AND l.cod_locatie = p.cod_locatie AND sc.cod_client = p.cod_persoana
                AND t.cod_tara = l.cod_tara AND ls.cod_tara = ts.cod_tara
                AND tc.tip_contract = sc.tip_contract
                AND s.cod_sediu = sc.cod_sediu AND ls.cod_locatie = s.cod_locatie AND sc.cod_angajat = v_cod
            )
            LOOP
                deReturnat.contracte_semnate.extend;
                v_i := v_i + 1;
                deReturnat.contracte_semnate(v_i).titlu_contract := v_record_contract_cu_sediu.titlu_contract;
                deReturnat.contracte_semnate(v_i).angajat_data := deReturnat.personal_data;
                deReturnat.contracte_semnate(v_i).client_data.nume := v_record_contract_cu_sediu.nume;
                deReturnat.contracte_semnate(v_i).client_data.prenume := v_record_contract_cu_sediu.prenume;
                deReturnat.contracte_semnate(v_i).client_data.email := v_record_contract_cu_sediu.email;
                deReturnat.contracte_semnate(v_i).client_data.gen := v_record_contract_cu_sediu.gen;
                deReturnat.contracte_semnate(v_i).client_data.locatie.cod_postal := v_record_contract_cu_sediu.cod_postal;
                deReturnat.contracte_semnate(v_i).client_data.locatie.adresa := v_record_contract_cu_sediu.adresa;
                deReturnat.contracte_semnate(v_i).client_data.locatie.oras := v_record_contract_cu_sediu.oras;
                deReturnat.contracte_semnate(v_i).client_data.locatie.nume_tara := v_record_contract_cu_sediu.nume_tara;
                
                deReturnat.contracte_semnate(v_i).locatie_semnat.cod_postal := v_record_contract_cu_sediu.sediu_cod_postal;
                deReturnat.contracte_semnate(v_i).locatie_semnat.adresa := v_record_contract_cu_sediu.sediu_adresa;
                deReturnat.contracte_semnate(v_i).locatie_semnat.oras := v_record_contract_cu_sediu.sediu_oras;
                deReturnat.contracte_semnate(v_i).locatie_semnat.nume_tara := v_record_contract_cu_sediu.sediu_nume_tara;
            END LOOP;
            
            FOR v_record_contract IN(
                SELECT nume, prenume, email, gen, l.cod_postal, l.adresa, l.oras, t.nume_tara, titlu_contract
                FROM PERSOANA p, CLIENT c, LOCATIE l, SEMNEAZA_UN_CONTRACT sc, TIP_CONTRACT tc, TARA t
                WHERE p.cod_persoana = c.cod_persoana AND l.cod_locatie = p.cod_locatie AND sc.cod_client = p.cod_persoana
                AND t.cod_tara = l.cod_tara
                AND tc.tip_contract = sc.tip_contract
                AND sc.cod_sediu IS NULL AND sc.cod_angajat = v_cod
            )
            LOOP
                deReturnat.contracte_semnate.extend;
                v_i := v_i + 1;
                deReturnat.contracte_semnate(v_i).titlu_contract := v_record_contract.titlu_contract;
                deReturnat.contracte_semnate(v_i).angajat_data := deReturnat.personal_data;
                deReturnat.contracte_semnate(v_i).client_data.nume := v_record_contract.nume;
                deReturnat.contracte_semnate(v_i).client_data.prenume := v_record_contract.prenume;
                deReturnat.contracte_semnate(v_i).client_data.email := v_record_contract.email;
                deReturnat.contracte_semnate(v_i).client_data.gen := v_record_contract.gen;
                deReturnat.contracte_semnate(v_i).client_data.locatie.cod_postal := v_record_contract.cod_postal;
                deReturnat.contracte_semnate(v_i).client_data.locatie.adresa := v_record_contract.adresa;
                deReturnat.contracte_semnate(v_i).client_data.locatie.oras := v_record_contract.oras;
                deReturnat.contracte_semnate(v_i).client_data.locatie.nume_tara := v_record_contract.nume_tara;
            END LOOP;
        END LOOP;
        return deReturnat;
    END;
END utilitati_bancare;
/

SELECT * FROM CONT;
EXECUTE utilitati_bancare.depozit_bani('RO43PORL9543945186522245', 122, 1, '4539763856109249');
EXECUTE utilitati_bancare.retragere_bani('RO43PORL9543945186522245', 1122, 1, '4539763856109249');
EXECUTE utilitati_bancare.retragere_bani('RO43PORL9543945186522245', 122, 1, '4539763856109249');
EXECUTE utilitati_bancare.transfer_bani('RO80RZBR8845968383338826', 'RO93PORL7529645415765354', 1000);

DECLARE
    v_client utilitati_bancare.info_client;
BEGIN
    v_client := utilitati_bancare.get_client_info('UserInexistent');
EXCEPTION
    WHEN utilitati_bancare.persoana_negasita THEN
        dbms_output.put_line('A intrat aici.');
END;
/


DECLARE
    v_client utilitati_bancare.info_client;
BEGIN
    v_client := utilitati_bancare.get_client_info('melis2_');
    dbms_output.put_line('==== Client Info ====');
    dbms_output.put_line('> Nume: ' || v_client.personal_data.nume);
    dbms_output.put_line('> Prenume: ' || v_client.personal_data.prenume);
    dbms_output.put_line('> Email: ' || v_client.personal_data.email);
    dbms_output.put_line('> Gen: ' || UPPER(v_client.personal_data.gen));
    dbms_output.put_line('> Locatie: ');
    dbms_output.put_line('>> Cod Postal: ' || v_client.personal_data.locatie.cod_postal);
    dbms_output.put_line('>> Adresa: ' || v_client.personal_data.locatie.adresa);
    dbms_output.put_line('>> Oras: ' || v_client.personal_data.locatie.oras);
    dbms_output.put_line('>> Tara: ' || v_client.personal_data.locatie.nume_tara);
    
    IF v_client.conturi.count = 0 THEN
        dbms_output.put_line('> Clientul nu are conturi');
        RETURN;
    END IF;
    
    FOR i IN 1..v_client.conturi.count LOOP
        dbms_output.put_line('--- Cont Info ---');
        dbms_output.put_line('> IBAN: ' || v_client.conturi(i).iban);
        dbms_output.put_line('> Sold: ' || v_client.conturi(i).sold);
        
        IF v_client.conturi(i).carduri.count = 0 THEN
            dbms_output.put_line('> Contul nu are carduri asociate.');
            CONTINUE;
        END IF;
        
        dbms_output.put_line('> Carduri:');
        FOR j IN 1..v_client.conturi(i).carduri.count LOOP
            dbms_output.put_line(' - ' || v_client.conturi(i).carduri(j).card_number || ' (' || v_client.conturi(i).carduri(j).tip || ')');
        END LOOP;
    END LOOP;
EXCEPTION
    WHEN utilitati_bancare.persoana_negasita THEN
        dbms_output.put_line('A intrat aici.');
END;
/


DECLARE
    v_angajat utilitati_bancare.info_angajat;
BEGIN
    v_angajat := utilitati_bancare.get_angajat_info('Adam', 'Ioan');
    
    dbms_output.put_line('==== Angajat Info ====');
    dbms_output.put_line('> Nume: ' || v_angajat.personal_data.nume);
    dbms_output.put_line('> Prenume: ' || v_angajat.personal_data.prenume);
    dbms_output.put_line('> Email: ' || v_angajat.personal_data.email);
    dbms_output.put_line('> Gen: ' || UPPER(v_angajat.personal_data.gen));
    dbms_output.put_line('> Locatie: ');
    dbms_output.put_line('>> Cod Postal: ' || v_angajat.personal_data.locatie.cod_postal);
    dbms_output.put_line('>> Adresa: ' || v_angajat.personal_data.locatie.adresa);
    dbms_output.put_line('>> Oras: ' || v_angajat.personal_data.locatie.oras);
    dbms_output.put_line('>> Tara: ' || v_angajat.personal_data.locatie.nume_tara);
    dbms_output.put_line('> Job: ' || v_angajat.job_titlu);
    dbms_output.put_line('> Salariu: ' || v_angajat.salariu);
    
    IF v_angajat.contracte_semnate.count = 0 THEN
        dbms_output.put_line('> Angajatul nu a semnat niciun contract.');
        RETURN;
    END IF;
    
    FOR i IN 1..v_angajat.contracte_semnate.count LOOP
        dbms_output.put_line('--- Contract ' || v_angajat.contracte_semnate(i).titlu_contract || ' ---');
        dbms_output.put_line('> Client: ' || v_angajat.contracte_semnate(i).client_data.nume || ' ' || v_angajat.contracte_semnate(i).client_data.prenume);
        dbms_output.put('> A fost semnat ');
        IF v_angajat.contracte_semnate(i).locatie_semnat.adresa IS NULL THEN
            dbms_output.put('REMOTE');
        ELSE
            dbms_output.put('la ' || v_angajat.contracte_semnate(i).locatie_semnat.adresa || ' ' || v_angajat.contracte_semnate(i).locatie_semnat.oras || ' ' ||
                    v_angajat.contracte_semnate(i).locatie_semnat.nume_tara);
        END IF;
        dbms_output.new_line;
    END LOOP;
END;
/
