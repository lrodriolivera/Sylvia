        IDENTIFICATION DIVISION.
        PROGRAM-ID. SFCPMIG0801 .
        AUTHOR.     JUSTO LOYOLA DONOSO.
      * Componente que se utiliza para el pareo tabla T7542350 y Archivo TRANSACTIONS
      * Para el sistema Loyalty
      * Fecha : 29-10-2018
      * COMPILAR-LINK : cobol.sh SFCPMIG0801
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
           RECORD CONTAINS   176 CHARACTERS
           LABEL RECORD IS STANDARD.

       01  REG-ENTRADA1 .
           copy COPY_TRANSACTIONS .

       FD ENTRADA2
          RECORDING MODE IS F
          BLOCK 0
          RECORD CONTAINS 218 CHARACTERS
          LABEL RECORDS STANDARD.

       01 REG-ENTRADA2 .
          COPY COPY_T7542350 .

       FD SALIDA1
          RECORDING MODE IS F
          RECORD CONTAINS 313 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA1 .
           COPY COPY_REDEMPTIONS .

       FD SALIDA2
          RECORDING MODE IS F
          RECORD CONTAINS 176 CHARACTERS
          BLOCK CONTAINS 0 RECORDS
          LABEL RECORDS STANDARD.

       01  REG-SALIDA2                          PIC X(176) .

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

        01 WS-SFCUENT .
           COPY SFCUENT .

        PROCEDURE DIVISION .

        MAIN-SEC SECTION.
        PP-MAIN.
                PERFORM 100000-INICIO
                PERFORM 200000-PROCESO 
                   UNTIL WS-FIN-1 = 1 or WS-FIN-2 = 1
                IF WS-FIN-1 = ZEROS
                   PERFORM GENERA-NOPAREADOS UNTIL WS-FIN-1 = 1
                END-IF
                PERFORM 300000-FINAL.
                MOVE ZEROS                 TO RETURN-CODE
                STOP RUN .

        100000-INICIO .
                OPEN INPUT ENTRADA1 .
                PERFORM LEE-01
                IF WS-FIN-1 = 1
                   DISPLAY "ARCHIVO TRANSACTIONS SIN INFORMACION"
                   DISPLAY "ERROR GRAVE SE DETIENE EJECUCION"
                   DISPLAY "---------------------------------"
                   MOVE 1                      TO RETURN-CODE
                   STOP RUN
                END-IF
                OPEN INPUT ENTRADA2 .
                PERFORM LEE-02
                IF WS-FIN-2 = 1
                   DISPLAY "ARCHIVO T7542350 SIN INFORMACION"
                   DISPLAY "ERROR GRAVE SE DETIENE EJECUCION"
                   DISPLAY "---------------------------------"
                   MOVE 1                      TO RETURN-CODE
                   STOP RUN
                END-IF
                OPEN OUTPUT SALIDA1 .
                OPEN OUTPUT SALIDA2 .

        200000-PROCESO .
                EVALUATE TRUE
                   WHEN RTRA-RUT = R2350-RUT
                      PERFORM GRABA-REG01 UNTIL RTRA-RUT <> R2350-RUT
                                          OR WS-FIN-2 = 1
                      PERFORM LEE-01
                   WHEN RTRA-RUT < R2350-RUT
                      PERFORM GRABA-REG02
                      PERFORM LEE-01
                   WHEN OTHER
                      PERFORM LEE-02
                END-EVALUATE .

        LEE-01 .
                READ ENTRADA1 AT END MOVE 1     TO WS-FIN-1 .
                IF WS-FIN-1 = ZEROS
                   ADD 1                        TO WS-C-ENT-1
                END-IF
                IF WS-FIN-1 = 1 OR 
                ( RTRA-SEP08 = " " AND RTRA-SEP08 = " " )
                   MOVE 99999999                TO RTRA-RUT
                END-IF .

        LEE-02 .
                READ ENTRADA2 AT END MOVE 1     TO WS-FIN-2 .
                IF WS-FIN-2 = ZEROS
                   ADD 1                        TO WS-C-ENT-2
                ELSE
                   MOVE 99999999                TO R2350-RUT
                END-IF .

        GRABA-REG01 .
      *------------ANULACION = 2
      *------------CANJE     = 1
      *------------CADUCIDAD = 5
                IF R2350-INDICADOR = 1
                OR R2350-INDICADOR = 2
                OR R2350-INDICADOR = 5
                   PERFORM GRABA-CANJE-ANULACION
                END-IF .
                PERFORM LEE-02 .

        GRABA-CANJE-ANULACION .
                ADD 1                           TO WS-C-SAL-1
                MOVE ";"                        TO RREDE-SEP01
                                                RREDE-SEP02
                                                RREDE-SEP03
                                                RREDE-SEP04
                                                RREDE-SEP05
                                                RREDE-SEP06
                                                RREDE-SEP07
                                                RREDE-SEP08
                                                RREDE-SEP09
                MOVE SPACES                     TO RREDE-MEM_NUM
                STRING "CL01"                   DELIMITED BY SIZE
                       RTRA-RUT                 DELIMITED BY SIZE
                                                INTO RREDE-MEM_NUM
                END-STRING
                MOVE RREDE-MEM_NUM              TO RREDE-MEMBER_ID
                MOVE SPACES                     TO RREDE-TRX_ID
                STRING "TRX"                    DELIMITED BY SIZE
                       RTRA-RUT                 DELIMITED BY SIZE
                       R2350-NUMMOVIM           DELIMITED BY SIZE
                                                INTO RREDE-TRX_ID
                END-STRING
                MOVE SPACES                     TO RREDE-ITEM_NUM
                STRING "TRX"                    DELIMITED BY SIZE
                       RTRA-RUT                 DELIMITED BY SIZE
                       R2350-NUMMOVIM           DELIMITED BY SIZE
                       R2350-CONCONCE           DELIMITED BY SIZE
                                                INTO RREDE-ITEM_NUM
                END-STRING
                MOVE R2350-PUNOBTEN             TO RREDE-VALUE
                IF R2350-PUNOBTEN-SIGNO = "-"
                   MULTIPLY -1                  BY RREDE-VALUE
                END-IF

                MOVE "RPGCL"                    TO RREDE-PROGRAM_NAME
                MOVE "PointTypeAVal"            TO RREDE-INTERNAL_NAME
                MOVE "Base"                     TO RREDE-NAME
                MOVE "PENDIENTE"                TO RREDE-TYPE_CODE

                WRITE REG-SALIDA1 
                END-WRITE .
                PERFORM LEE-02 .

        GRABA-REG02 .
                ADD 1                           TO WS-C-SAL-2
                WRITE REG-SALIDA2 FROM REG-ENTRADA1
                END-WRITE .

        GENERA-NOPAREADOS .
                PERFORM GRABA-REG02
                PERFORM LEE-01 .

        300000-FINAL .
                CLOSE ENTRADA1
                CLOSE ENTRADA2

                IF WS-C-SAL-1 > 0
                   MOVE WS-C-SAL-1              TO WS-REGCONT
                   MOVE SPACES                  TO REG-SALIDA1
                   MOVE FUNCTION CURRENT-DATE   TO WS-FECHA
                   STRING WS-FDD                DELIMITED BY SIZE
                          WS-FMM                DELIMITED BY SIZE
                          WS-FAA                DELIMITED BY SIZE
                          WS-REGCONT            DELIMITED BY SIZE
                                                INTO REG-SALIDA1
                   END-STRING
                   WRITE REG-SALIDA1 END-WRITE
                END-IF 
                CLOSE SALIDA1 .
                CLOSE SALIDA2 .
                display "Registros Leidos 1=" WS-C-ENT-1
                display "Registros Leidos 2=" WS-C-ENT-2
                display "Registros Grabados 1=" WS-C-SAL-1 .
                display "Registros Grabados 2=" WS-C-SAL-2 .

