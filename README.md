# Gestiunea unui sistem bancar (SGBD/DBMS)

## Diagram (English)
The diagram entities and relationships are properly explained in romanian inside the PDF.

![DatabaseDiagram](https://github.com/DragosGhinea/BankSystem_SGBD_DBMS/blob/main/ER_Diagram.svg)

## Implementare

- În fișierul PDF găsiți tot proiectul, în special **descrierea bazei de date**, **diagrama ER**, **diagrama conceptuala**.
- Nu există fișiere .sql pentru exercițiile 1,2,3 deoarece acestea sunt doar pentru descrierea bazei de date, și se regăsesc, cum a fost menționat anterior, în Gestiunea_unui_sistem_bancar.pdf.
- Fișierul ToateExercitiile.sql concatenează conținutul tuturor exercițiilor care au propria filă .sql
- Cerințele pentru fiecare exercițiu se găsesc mai jos.
- Problema propusă pentru fiecare cerință se află sub formă de comentariu în cod.

## Cerințe

Proiectul urmărește cerințele propuse în cadrul cursului de _Sisteme de Gestiune a Bazelor de Date_ (2023), susținut de Lect. Dr. Gabriela Mihai în cadrul Universității din București, Facultatea de Matematică și Informatică.

1. Prezentați pe scurt baza de date (utilitatea ei).
2. Realizați diagrama entitate-relație (ERD).
3. Pornind de la diagrama entitate-relație realizați diagrama conceptuală a modelului propus, integrând toate atributele necesare.
4. Implementați în Oracle diagrama conceptuală realizată: definiți toate tabelele,  implementând  toate constrângerile de integritate necesare (chei primare, cheile externe etc).
5. Adăugați informații  coerente  în  tabelele  create  (minim 5  înregistrări  pentru  fiecare  entitate independentă; minim 10 înregistrări pentru tabela asociativă).
6. Formulați în  limbaj  natural o problemă pe care să o rezolvați folosind un subprogram  stocat independent care să utilizeze două tipuri diferite de colecții studiate. Apelați subprogramul.
7. Formulați în  limbaj  natural o problemă pe care să o rezolvați folosind un subprogram  stocat independent care să utilizeze 2 tipuri diferite de cursoare studiate,  unul  dintre  acestea  fiind  cursor parametrizat. Apelați subprogramul.
8. Formulați în limbaj natural o problemă pe care să o rezolvați folosind un subprogram  stocat independent de tip funcție care să utilizeze într-o singură comandă SQL 3 dintre tabelele definite. Definiți minim 2 excepții. Apelați subprogramul astfel încât să evidențiați toate cazurile tratate.
9. Formulați în  limbaj  natural o problemă pe care să o rezolvați folosind un subprogram  stocat independent de tip procedură care să utilizeze într-o singură comandă SQL 5 dintre tabelele definite. Tratați toate excepțiile  care  pot  apărea, incluzând excepțiile NO_DATA_FOUND și TOO_MANY_ROWS. Apelați subprogramulastfel încât să evidențiați toate cazurile tratate.
10. Definiți un trigger de tip LMD la nivel de comandă. Declanșați trigger-ul.
11. Definiți un trigger de tip LMD la nivel de linie. Declanșați trigger-ul.
12. Definiți un trigger de tip LDD. Declanșați trigger-ul.

### Cerințe Extra

13. Definiți un pachet care să conțină toate obiectele definite în cadrul proiectului.
14. Definiți un pachet care să includă tipuri de date complexe și obiecte necesare unui flux de acțiuni integrate, specifice bazei de date definite (minim 2 tipuri de date, minim 2 funcții, minim 2 proceduri).
