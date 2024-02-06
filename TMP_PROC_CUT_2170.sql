CREATE OR REPLACE PROCEDURE CUADRA.TMP_PROC_CUT_2170
IS
    CNT_REGS                NUMBER:= 0;
    NUM_CORR                NUMBER:= 1;
    GLS_ERROR               VARCHAR2(3000);
    CUR_EXTERNALOBJECTID    VARCHAR2(100);
    CUR_COD_SERIE           VARCHAR2(100);
    CUR_CHAROWNER_RFS       NUMBER(20);
    CUR_CHAROWNER_PHD       NUMBER(20);
    CNT_LIM_REGS            NUMBER:= 2001;
    IND_ERROR               NUMBER:= 0;
    CUR_CONTROL             VARCHAR2(10);
    VAR_RETVAL              NUMBER:= 0;
    CUR_OU_NUM_1            VARCHAR2(50);
    CNT_ERROR               NUMBER:= 0;

    CURSOR CUR_SERIES_DELETE IS
        SELECT  UNIQUE AA.*
        FROM    (
                    SELECT  UNIQUE A.EXTERNALOBJECTID, I.COD_SERIE, A.CHAROWNER, I.CONTROL
                    FROM    TMP_SER1 I, CUT_UIM_RFS A, XVTR_SIEBEL_INFO_SERIES_T S
                    WHERE   I.EXTERNALOBJECTID = A.EXTERNALOBJECTID
                    AND     A.CARACTERISTICA = 'CPESerialNumber'
                    AND     I.COD_SERIE = A.VALUE 
                    AND     I.COD_SERIE = S.COD_SERIE 
                    AND     REGEXP_REPLACE(S.TECNOLOGIA, '[^a-z_A-Z]', '') <> 'IPTV'
                    AND     NOT EXISTS  (
                            SELECT  1
                            FROM    CUT_2170 A
                            WHERE   A.C_EXTERNALOBJECTID = I.EXTERNALOBJECTID
                                        )
                ) AA, TMP_SER1 BB
        WHERE   AA.EXTERNALOBJECTID = BB.EXTERNALOBJECTID
        AND     NOT EXISTS  (
                SELECT  1
                FROM 	UIMUSER.BUSINESSINTERACTION@UIMPRD.WORLD BB
                WHERE 	BB.EXTERNALOBJECTID = AA.EXTERNALOBJECTID
                AND 	BB.ADMINSTATE IN ('IN_PROGRESS', 'CREATED')
                            )
        AND     NOT EXISTS  (
                SELECT	1
                FROM	SIEBEL.S_ORDER@SBLPRD.WORLD AA, SIEBEL.S_ORG_EXT@SBLPRD.WORLD EE
                WHERE	EE.OU_NUM_1 = BB.RUT
                AND		EE.ROW_ID = AA.ACCNT_ID
                AND		AA.STATUS_CD NOT IN ('Completada','Cancelado','Revisado')
                AND		AA.X_OCS_TIPO_ORDEN <> 'Temporal' 
                            )
        ORDER BY AA.EXTERNALOBJECTID;

    CURSOR CUR_SERIES_ADD IS
        SELECT  B.INT_PP,
                B.COD_SERIE,
                B.RUT
        FROM    TMP_SER2 B
        WHERE   NOT EXISTS  (
                SELECT  1
                FROM 	UIMUSER.BUSINESSINTERACTION@UIMPRD.WORLD BB
                WHERE 	BB.EXTERNALOBJECTID = B.INT_PP
                AND 	BB.ADMINSTATE IN ('IN_PROGRESS', 'CREATED')
                            )
        AND     NOT EXISTS  (
                SELECT	1
                FROM	SIEBEL.S_ORDER@SBLPRD.WORLD AA, SIEBEL.S_ORG_EXT@SBLPRD.WORLD EE
                WHERE	EE.OU_NUM_1 = B.RUT
                AND		EE.ROW_ID = AA.ACCNT_ID
                AND		AA.STATUS_CD NOT IN ('Completada','Cancelado','Revisado')
                AND		AA.X_OCS_TIPO_ORDEN <> 'Temporal' 
                            );

    CUR_INTEGRATION_ID      VARCHAR2(100);
    CUR_CHAROWNER           VARCHAR2(50);
    CURSOR CUR_SN_US2166_US2170 IS 
        SELECT  A.EXTERNALOBJECTID, C.CHAROWNER, C.VALUE||'_US2166'
        FROM    TMP_UIMSINCRM_DBOX A, XVTR_SIEBEL_INFO_SERIES_T B, CUT_UIM_RFS C
        WHERE   A.COD_SERIE = B.COD_SERIE 
        AND     B.TECNOLOGIA <> 'IPTV' 
        AND     NVL(TRIM(FLG_PDTE_SIEBEL),'X')='X'
        AND     NVL(TRIM(FLG_UIM_BLANCOPROD),'X')='X' 
        AND     NVL(TRIM(FLG_BI_PDTE),'X')='X' 
        AND     NVL(TRIM(FLG_SIEBEL),'X')='X' 
        AND     A.LASTMODIFIEDDATE < TRUNC(SYSDATE)-10
        AND     A.EXTERNALOBJECTID = C.EXTERNALOBJECTID
        AND     C.CARACTERISTICA = 'CPESerialNumber'
        AND     A.COD_SERIE = C.VALUE
        AND     A.COD_SERIE NOT IN (
                SELECT C_CPESERIALNUMBER FROM CUT_2170 )
        UNION
        SELECT  A.EXTERNALOBJECTID, C.CHAROWNER, C.VALUE||'_US2170'
        FROM    TMP_UIMSINCRM_DBOX A, XVTR_SIEBEL_INFO_SERIES_T B , CUT_UIM_RFS C
        WHERE   A.COD_SERIE = B.COD_SERIE AND B.TECNOLOGIA <> 'IPTV' 
        AND     NVL(TRIM(FLG_PDTE_SIEBEL),'X')='X' 
        AND     NVL(TRIM(FLG_UIM_BLANCOPROD),'X')='X' 
        AND     NVL(TRIM(FLG_BI_PDTE),'X')='X' 
        AND     NVL(TRIM(FLG_SIEBEL),'X')='SI' 
        AND     c.LASTMODIFIEDDATE < TRUNC(SYSDATE)-10
        AND     A.EXTERNALOBJECTID = C.EXTERNALOBJECTID
        AND     C.CARACTERISTICA = 'CPESerialNumber'
        AND     A.COD_SERIE = C.VALUE
        AND     A.COD_SERIE NOT IN (
                SELECT C_CPESERIALNUMBER FROM CUT_2170 );
BEGIN
-- PROCESO QUE PERMITE ELIMINAR D-BOX CON TECNOLOGÍA HFC EN UIM
    SELECT CRTPROC.NEXTVAL INTO NUM_CORR FROM DUAL;
      
    SELECT  COUNT(1)
    INTO    CNT_REGS
    FROM    TMP_CONTROLPROCESOS
    WHERE   FEC_INICIAL > TRUNC(SYSDATE)
    AND     ID_JOBS = '430'
    AND     EST_PROC LIKE 'OK%';
	
    IF CNT_REGS = 0 THEN
        INSERT  INTO TMP_CONTROLPROCESOS
        VALUES  ( NUM_CORR, '469', SYSDATE, SYSDATE, 'ERROR EN PROCESO TMP_PROC_EQUIPOS_MTA', NULL, 'TMP_PROC_CUT_2170');
        COMMIT;
        
        IND_ERROR:= 1;
    ELSE
        INSERT  INTO TMP_CONTROLPROCESOS
        VALUES  ( NUM_CORR, '469', SYSDATE, NULL, 'EN PROCESO', NULL, 'TMP_PROC_CUT_2170');
        COMMIT;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('CNT_LIM_REGS='||CNT_LIM_REGS);
    
    EXECUTE IMMEDIATE 'TRUNCATE TABLE CUT_2170';
    
    IF IND_ERROR = 0 THEN
        CNT_REGS:= 0;
        OPEN CUR_SERIES_DELETE;
        LOOP
            FETCH CUR_SERIES_DELETE
            INTO CUR_EXTERNALOBJECTID, CUR_COD_SERIE, CUR_CHAROWNER_RFS, CUR_CONTROL;
            EXIT WHEN CUR_SERIES_DELETE%NOTFOUND;
            BEGIN
                CNT_REGS:= CNT_REGS+1;
                IF IND_ERROR = 0 AND CNT_REGS < CNT_LIM_REGS THEN
                    BEGIN
                        BEGIN
                            SELECT  PD2.CHAROWNER
                            INTO    CUR_CHAROWNER_PHD
                            FROM    UIMUSER.PHYSICALDEVICE_CHAR@UIMPRD.WORLD PD2,
                                    UIMUSER.PHYSICALDEVICE@UIMPRD.WORLD LD,
                                    UIMUSER.PHYSICALDEVICECONSUMER@UIMPRD.WORLD LDC,
                                    UIMUSER.PHYSICALDEVICEASSIGNMENT@UIMPRD.WORLD LDA
                            WHERE   PD2.CHAROWNER = LD.ENTITYID
                            AND 	LD.ENTITYID = LDC.PHYSICALDEVICE 
                            AND 	LDC.ADMINSTATE = 'ASSIGNED'
                            AND     LDC.ENTITYID = LDA.ENTITYID
                            AND     PD2.VALUE = CUR_COD_SERIE
                            AND     NVL(PD2.NAME, 'X') = 'CPESerialNumber';

                            IND_ERROR:= 0;

                            EXCEPTION WHEN OTHERS THEN
                                IND_ERROR:= 1;
                        END;

                        IF IND_ERROR = 0 THEN                        
                            INSERT INTO CUT_2170
                            SELECT	CNT_REGS C_ROW, EXTERNALOBJECTID, EXTERNALOBJECTID, COD_MARCA, COD_MODELO, COD_MACADDR, COD_SERIE, COD_UNITAD, COD_TECNO, COD_TYPE, 
                                    EXTERNALOBJECTID, 'delete', SYSDATE
                            FROM 	(
                                        SELECT  UNIQUE A.EXTERNALOBJECTID, TMP_SEARCH_PHYSDEV(CUR_COD_SERIE, 'CPEBrand') COD_MARCA, 
                                                TMP_SEARCH_PHYSDEV(CUR_COD_SERIE, 'CPEModel') COD_MODELO, TMP_SEARCH_PHYSDEV(CUR_COD_SERIE, 'CPEMACAddress') COD_MACADDR, 
                                                I.COD_SERIE, TMP_SEARCH_PHYSDEV(CUR_COD_SERIE, 'CPEUNITMACAddress') COD_UNITAD,
                                                TMP_SEARCH_PHYSDEV(CUR_COD_SERIE, 'CPETechnology') COD_TECNO, TMP_SEARCH_PHYSDEV(CUR_COD_SERIE, 'CPEType') COD_TYPE
                                        FROM    TMP_UIMSINCRM_DBOX I, CUT_UIM_RFS A
                                        WHERE   I.EXTERNALOBJECTID = CUR_EXTERNALOBJECTID
                                        AND     I.COD_SERIE = CUR_COD_SERIE
                                        AND     A.EXTERNALOBJECTID = CUR_EXTERNALOBJECTID
                                        AND     A.VALUE = CUR_COD_SERIE
                                        AND     I.EXTERNALOBJECTID = A.EXTERNALOBJECTID
                                        AND     I.COD_SERIE = A.VALUE
                                        AND     A.CHAROWNER = CUR_CHAROWNER_RFS
                                        AND     A.CARACTERISTICA = 'CPESerialNumber'
                                    )
                            WHERE	ROWNUM < CNT_LIM_REGS;
                            COMMIT;
                        END IF;

                        EXCEPTION WHEN OTHERS THEN
                            GLS_ERROR:= SQLERRM;
                            DBMS_OUTPUT.PUT_LINE('CUR_EXTERNALOBJECTID='||CUR_EXTERNALOBJECTID||' *** GLS_ERROR='||GLS_ERROR);
                            ROLLBACK;
                    END;
                END IF;
            END;
        END LOOP;
        CLOSE CUR_SERIES_DELETE;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('CNT_REGS='||CNT_REGS);

        DELETE  FROM CUT_2170
        WHERE   C_ROW > 2000;

        DBMS_OUTPUT.PUT_LINE('CNT_ERROR='||CNT_ERROR);
        
DBMS_OUTPUT.PUT_LINE('PROCESO CUR_SERIES_ADD');
        IND_ERROR:= 0;
        CNT_REGS:= 0;
        OPEN CUR_SERIES_ADD;
        LOOP
            FETCH CUR_SERIES_ADD
            INTO CUR_EXTERNALOBJECTID, CUR_COD_SERIE, CUR_OU_NUM_1;
            EXIT WHEN CUR_SERIES_ADD%NOTFOUND;
            BEGIN
                CNT_REGS:= CNT_REGS+1;
                IF IND_ERROR = 0 AND CNT_REGS < CNT_LIM_REGS THEN
                    BEGIN
                        BEGIN
                            SELECT  COUNT(1)
                            INTO    IND_ERROR
                            FROM    UIMUSER.PHYSICALDEVICE_CHAR@UIMPRD.WORLD PD2,
                                    UIMUSER.PHYSICALDEVICE@UIMPRD.WORLD LD,
                                    UIMUSER.PHYSICALDEVICECONSUMER@UIMPRD.WORLD LDC,
                                    UIMUSER.PHYSICALDEVICEASSIGNMENT@UIMPRD.WORLD LDA
                            WHERE   PD2.CHAROWNER = LD.ENTITYID
                            AND 	LD.ENTITYID = LDC.PHYSICALDEVICE 
                            AND 	LDC.ADMINSTATE = 'ASSIGNED'
                            AND     LDC.ENTITYID = LDA.ENTITYID
                            AND     PD2.VALUE = CUR_COD_SERIE
                            AND     NVL(PD2.NAME, 'X') = 'CPESerialNumber';
                        END;
                        
                        IF IND_ERROR = 0 THEN
                            INSERT INTO CUT_2170
                            SELECT	CNT_REGS C_ROW, INT_PP, INT_PP, COD_MARCA, COD_MODELO, COD_MACADDR, COD_SERIE, COD_UNITAD, COD_TECNO, COD_TYPE, 
                                    INT_PP, 'add', SYSDATE
                            FROM 	(
                                        SELECT  UNIQUE I.INT_PP, 
                                                TMP_SEARCH_PHYSDEV_UNASSIGNED(CUR_COD_SERIE, 'CPEBrand') COD_MARCA, 
                                                TMP_SEARCH_PHYSDEV_UNASSIGNED(CUR_COD_SERIE, 'CPEModel') COD_MODELO, 
                                                TMP_SEARCH_PHYSDEV_UNASSIGNED(CUR_COD_SERIE, 'CPEMACAddress') COD_MACADDR, 
                                                I.COD_SERIE, 
                                                TMP_SEARCH_PHYSDEV_UNASSIGNED(CUR_COD_SERIE, 'CPEUNITMACAddress') COD_UNITAD,
                                                TMP_SEARCH_PHYSDEV_UNASSIGNED(CUR_COD_SERIE, 'CPETechnology') COD_TECNO, 
                                                TMP_SEARCH_PHYSDEV_UNASSIGNED(CUR_COD_SERIE, 'CPEType') COD_TYPE
                                        FROM    TMP_SER2 I
                                        WHERE   I.INT_PP = CUR_EXTERNALOBJECTID
                                        AND     I.COD_SERIE = CUR_COD_SERIE
                                    )
                            WHERE	ROWNUM < CNT_LIM_REGS;
                            COMMIT;
                        ELSE
                            IND_ERROR:= 0;
                            DBMS_OUTPUT.PUT_LINE('ASSIGNED CUR_EXTERNALOBJECTID='||CUR_EXTERNALOBJECTID||' *** CUR_COD_SERIE='||CUR_COD_SERIE);                            
                            CNT_ERROR:= CNT_ERROR+1;
                        END IF;

                        EXCEPTION WHEN OTHERS THEN
                            GLS_ERROR:= SQLERRM;
                            DBMS_OUTPUT.PUT_LINE('CUR_EXTERNALOBJECTID='||CUR_EXTERNALOBJECTID||' *** GLS_ERROR='||GLS_ERROR);
                            ROLLBACK;
                    END;
                END IF;
            END;
        END LOOP;
        CLOSE CUR_SERIES_ADD;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('CNT_REGS='||CNT_REGS);
        DBMS_OUTPUT.PUT_LINE('CNT_ERROR='||CNT_ERROR);

        --PROCESO QUE PERMITE ACTUALIZAR SERIES EN UIM ASOCIADAS A LOS CONTROLES US-2166 Y US-2170
        BEGIN
            OPEN CUR_SN_US2166_US2170;
            LOOP
                FETCH	CUR_SN_US2166_US2170
                INTO	CUR_INTEGRATION_ID,
                        CUR_CHAROWNER,
                        CUR_COD_SERIE;
                EXIT WHEN CUR_SN_US2166_US2170%NOTFOUND;
                BEGIN
                    VAR_RETVAL:= 
                        CUF_INSERT_RFSLD 
                        (
                            CUR_INTEGRATION_ID,
                            'CPESerialNumber',
                            CUR_CHAROWNER,
                            CUR_COD_SERIE
                        );
                    COMMIT;
                    CNT_REGS:= CNT_REGS+1;
                    EXCEPTION WHEN OTHERS THEN
                        ROLLBACK;
                END;
            END LOOP;
            CLOSE CUR_SN_US2166_US2170;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('CNT_REGS='||CNT_REGS);
        END;

        IF IND_ERROR = 0 THEN
            UPDATE  TMP_CONTROLPROCESOS
            SET     EST_PROC = 'OK', FEC_FINAL = SYSDATE
            WHERE   ID_CORRELATIVO = NUM_CORR;
        END IF;
        
        COMMIT;
    END IF;

    EXCEPTION WHEN OTHERS THEN
        GLS_ERROR:= SQLERRM;
        ROLLBACK;
        UPDATE  TMP_CONTROLPROCESOS
        SET     EST_PROC = 'ERROR', FEC_FINAL = SYSDATE, DES_PROC = GLS_ERROR||'  ***** TMP_PROC_CUT_2170 *****'
        WHERE   ID_CORRELATIVO = NUM_CORR;
        COMMIT;
END;
