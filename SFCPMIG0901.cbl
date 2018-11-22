        IDENTIFICATION DIVISION.
        PROGRAM-ID. SFCPMIG0901 .
        AUTHOR.     CONNECTIS-GS.
      * Componente que realiza el pareo Archivo Rutero y la 
      * descarga de información desde esquema BOPERS, de las
      * tablas BOPERS_MAE_IDE Y BOPERS_MAE_NAT_BSC para generar
      * archivo de MIGRADOS y FALLECIDOS. 
      * Fecha : 16-11-2018
      * COMPILAR-LINK : cobol.sh SFCPMIG0901
      *---------------------------------------------------------------*
      *             E N V I R O N M E N T   D I V I S I O N           *
      *             =======================================           *
      *---------------------------------------------------------------*

       ENVIRONMENT DIVISION.
      *--------------------.

       CONFIGURATION SECTION.
      *---------------------.

       SPECIAL-NAMES.
               DECIMAL-POINT IS COMMA.

       INPUT-OUTPUT SECTION.
      *--------------------.
       FILE-CONTROL.

                SELECT ENTRADA1 ASSIGN TO EXTERNAL FENTRADA1
                       ORGANIZATION LINE SEQUENTIAL.

                SELECT ENTRADA2 ASSIGN TO EXTERNAL FENTRADA2
                       ORGANIZATION LINE SEQUENTIAL.

                SELECT SALIDA1 ASSIGN TO EXTERNAL FSALIDA1
                       ORGANIZATION LINE SEQUENTIAL.

                SELECT SALIDA2 ASSIGN TO EXTERNAL FSALIDA2
                       ORGANIZATION LINE SEQUENTIAL.

      *---------------------------------------------------------------*
      *                    D A T A   D I V I S I O N                  *
      *                    =========================                  *
      *---------------------------------------------------------------*

       DATA DIVISION.
      *-------------.

       FILE SECTION.
      *------------.


       FD ENTRADA1
           RECORDING MODE IS F
           BLOCK 0
           RECORD CONTAINS   18 CHARACTERS
           LABEL RECORD IS STANDARD.

       01  REG-ENTRADA1 .
           copy COPY_RUTERO_ORD .

       FD ENTRADA2
          RECORDING MODE IS F
          BLOCK 0
          RECORD CONTAINS 46 CHARACTERS
          LABEL RECORDS STANDARD.

       01 REG-ENTRADA2 .
          COPY COPY_MAE_FALLECIDOS .

       FD SALIDA1
          RECORDING MODE IS F
          RECORD CONTAINS 18 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA1 .
           COPY COPY_MIGRADOS.

       FD SALIDA2
          RECORDING MODE IS F
          RECORD CONTAINS 8 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA2 .
           COPY COPY_FALLECIDOS.

       WORKING-STORAGE SECTION.
      *-----------------------.

        01 WS-RARAS.
           05 WS-STATUS                         PIC X(02) .
           05 WS-FIN-1                          PIC 9(01) VALUE ZEROS .
           05 WS-FIN-2                          PIC 9(01) VALUE ZEROS .
           05 WS-C-ENT-1                        PIC 9(12) VALUE ZEROS .
           05 WS-C-ENT-2                        PIC 9(12) VALUE ZEROS .
           05 WS-C-SAL-1                        PIC 9(12) VALUE ZEROS .
           05 WS-C-SAL-2                        PIC 9(12) VALUE ZEROS .
           05 WS-FECHA .
              10 WS-FAA                         PIC X(04) .
              10 WS-FMM                         PIC X(02) .
              10 WS-FDD                         PIC X(02) .
           05 WS-REGCONT                        PIC x(12) .

        PROCEDURE DIVISION .

        MAIN-SEC SECTION.
        PP-MAIN.
                PERFORM 100000-INICIO
                PERFORM 200000-PROCESO 
                   UNTIL WS-FIN-1 = 1 or WS-FIN-2 = 1
                IF WS-FIN-1 = ZEROS
                   PERFORM GRABA-MIGRADOS UNTIL WS-FIN-1 = 1
                END-IF
                PERFORM 300000-FINAL.
                MOVE ZEROS                 TO RETURN-CODE
                STOP RUN .

        100000-INICIO .
                OPEN INPUT ENTRADA1 .
                PERFORM LEE-01
                IF WS-FIN-1 = 1
                   DISPLAY "ARCHIVO RUTERO SIN INFORMACION"
                   DISPLAY "ERROR GRAVE SE DETIENE EJECUCION"
                   DISPLAY "---------------------------------"
                   MOVE 1                      TO RETURN-CODE
                   STOP RUN
                END-IF
                OPEN INPUT ENTRADA2 .
                PERFORM LEE-02
                IF WS-FIN-2 = 1
                   DISPLAY "ARCHIVO MAE_FALLECIDOS SIN INFORMACION"
                   DISPLAY "ERROR GRAVE SE DETIENE EJECUCION"
                   DISPLAY "--------------------------------------"
                   MOVE 1                      TO RETURN-CODE
                   STOP RUN
                END-IF
                OPEN OUTPUT SALIDA1 .
                OPEN OUTPUT SALIDA2 .
 
        200000-PROCESO .
                EVALUATE TRUE
                   WHEN RUTORD-RUT = MAEFALL-RUT
                      display RUTORD-RUT " = " MAEFALL-RUT
                      IF MAEFALL-FCH NOT EQUAL SPACES
                         PERFORM GRABA-FALLECIDOS
                      ELSE
                         PERFORM GRABA-MIGRADOS
                      END-IF                 
                      PERFORM LEE-01
                      PERFORM LEE-02
                   WHEN RUTORD-RUT < MAEFALL-RUT
                      PERFORM GRABA-MIGRADOS
                      PERFORM LEE-01
                   WHEN OTHER
                      PERFORM LEE-02
                END-EVALUATE .

        LEE-01 .
                READ ENTRADA1 AT END MOVE 1     TO WS-FIN-1 .
                IF WS-FIN-1 = ZEROS
                   ADD 1                        TO WS-C-ENT-1
                IF WS-FIN-1 = 1
                   MOVE 99999999                TO RUTORD-RUT
                END-IF .

        LEE-02 .
                READ ENTRADA2 AT END MOVE 1     TO WS-FIN-2 .
                IF WS-FIN-2 = ZEROS
                   ADD 1                        TO WS-C-ENT-2
                END-IF
                IF WS-FIN-2 = 1
                   MOVE 99999999                TO MAEFALL-RUT
                END-IF .

        GRABA-MIGRADOS .
                ADD 1                           TO WS-C-SAL-1
                MOVE RUTORD-RUT                 TO MIGORD-RUT
                MOVE RUTORD-CODPROGR            TO MIGORD-CODPROGR
                WRITE REG-SALIDA1 
                END-WRITE .

        GRABA-FALLECIDOS .
                ADD 1                           TO WS-C-SAL-2
                MOVE RUTORD-RUT                 TO FALLORD-RUT
                WRITE REG-SALIDA2 
                END-WRITE .

        300000-FINAL .
                CLOSE ENTRADA1
                CLOSE ENTRADA2
      *
      *         IF WS-C-SAL-1 > 0
      *            MOVE WS-C-SAL-1              TO WS-REGCONT
      *            MOVE SPACES                  TO REG-SALIDA1
      *            MOVE FUNCTION CURRENT-DATE   TO WS-FECHA
      *            STRING WS-FDD                DELIMITED BY SIZE
      *                   WS-FMM                DELIMITED BY SIZE
      *                   WS-FAA                DELIMITED BY SIZE
      *                   WS-REGCONT            DELIMITED BY SIZE
      *                                         INTO REG-SALIDA1
      *            END-STRING
      *            WRITE REG-SALIDA1 END-WRITE
      *            WRITE REG-SALIDA2 FROM REG-SALIDA1 END-WRITE
      *         END-IF 
      * 
                CLOSE SALIDA1 .
                CLOSE SALIDA2 .
                display "Reg. Leidos RUTERO         = " WS-C-ENT-1.
                display "Reg. Leidos MAE-FALLECIDOS = " WS-C-ENT-2.
                display "Reg. Grabados MIGRADOS     = " WS-C-SAL-1.
                display "Reg. Grabados FALLECIDOS   = " WS-C-SAL-2.