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