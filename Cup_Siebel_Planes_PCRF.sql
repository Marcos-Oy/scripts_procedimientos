CREATE OR REPLACE PROCEDURE CUADRA.Cup_siebel_planes_pcrf
IS
--
   Cur_row_id_prodprin           VARCHAR2 ( 15 );
   Cur_integration_id            VARCHAR2 ( 30 );
   Cur_row_id_asset              VARCHAR2 ( 15 );
   Cur_rut_persona               VARCHAR2 ( 30 );
   Cur_ou_num_1                  VARCHAR2 ( 30 );
   Cur_integration               VARCHAR2 ( 30 );
   Cur_dataplan                  VARCHAR2 ( 100 );
   Cur_root_asset_id             VARCHAR2 ( 15 );
--
   Var_modalidad_siebel          VARCHAR2 ( 100 );
   Var_caracteristica_giap       VARCHAR2 ( 100 );
   Var_value_giap                VARCHAR2 ( 100 );
   Var_attr_name                 VARCHAR2 ( 100 );
   Var_char_val                  VARCHAR2 ( 255 );
   Var_error_noexiste_siebel     NUMBER ( 1 );
   Var_error_vacio_siebel        NUMBER ( 1 );
   Var_error_noexiste_uim        NUMBER ( 1 );
   Var_error_distinto            NUMBER ( 1 );
   Var_con_ordenpend01           NUMBER ( 10 );
   Var_con_orden_pend            NUMBER ( 1 );
   Var_con_bipend01              NUMBER ( 10 );
   Var_con_bi_pend               NUMBER ( 1 );

--
   CURSOR Cur_registros
   IS
      SELECT DISTINCT A.Ou_num_1,
                      A.Row_id,
                      A.Integration_id,
                      B.Row_id,
                      B.Sp_num,
                      B.Root_asset_id
                 FROM Cut_siebel_productop A,
                      Cut_siebel_productop B,
                      S_asset_xa C
                WHERE (     ( A.Ou_num_1 = B.Ou_num_1 )
                        AND ( A.Root_asset_id = B.Root_asset_id )
                        AND ( B.Row_id = C.Asset_id )
                        AND ( ( A.Permitted_type = '/service/telco/gsm' ))
                        AND ( ( B.Permitted_type = '/service/telco/gsm/data' ))
                        AND ( ( A.X_ocs_categoria_detallada = 'Producto Customizable' ))
                        AND ( ( B.X_ocs_categoria_detallada = 'Producto Principal' ))
                        AND ( ( C.Attr_name = 'Maxima Velocidad' ))
                        AND A.Ou_num_1 IN ( SELECT DISTINCT Rut_excluidos.Rut_persona
                                                      FROM Rut_excluidos )
                      );

--
   CURSOR Cur_errores
   IS
      SELECT Rut_persona,
             Integration_id
        FROM Cuadra.Cut_siebel_pcrf;
--
BEGIN
   BEGIN
      DELETE      Cuadra.Cut_siebel_pcrf;

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   OPEN Cur_registros;

   LOOP
      FETCH Cur_registros
       INTO Cur_rut_persona,
            Cur_row_id_prodprin,
            Cur_integration_id,
            Cur_row_id_asset,
            Cur_dataplan,
            Cur_root_asset_id;

      EXIT WHEN Cur_registros%NOTFOUND;

      BEGIN
         Var_error_noexiste_siebel  := 0;
         Var_error_vacio_siebel     := 0;
         Var_error_noexiste_uim     := 0;
         Var_error_distinto         := 0;

         BEGIN
            SELECT Attr_name,
                   Char_val
              INTO Var_attr_name,
                   Var_char_val
              FROM Cuadra.S_asset_xa
             WHERE Asset_id = Cur_row_id_asset
               AND Attr_name = 'Maxima Velocidad';

            IF SQL%FOUND
            THEN
               IF NVL ( TRIM ( Var_char_val ), '*' ) = '*'
               THEN
                  Var_error_vacio_siebel     := 1;
               ELSIF NVL ( TRIM ( Var_char_val ), '*' ) != '*'
               THEN
                  NULL;
               END IF;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               Var_error_noexiste_siebel  := 0;
         END;

         BEGIN
            Var_modalidad_siebel       := NULL;

            SELECT Char_val
              INTO Var_modalidad_siebel
              FROM Cuadra.S_asset_xa
             WHERE Attr_name = 'Tipo Plan'
               AND Asset_id IN ( SELECT Row_id
                                  FROM Cuadra.Cut_siebel_productop
                                 WHERE Root_asset_id = Cur_root_asset_id );

            IF SQL%FOUND
            THEN
               NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               BEGIN
                  SELECT VALUE
                    INTO Var_modalidad_siebel
                    FROM Cuadra.Cut_uim_rfs
                   WHERE Externalobjectid = Cur_integration_id
                     AND Caracteristica = 'Modalidad';

                  IF SQL%FOUND
                  THEN
                     NULL;
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     Var_modalidad_siebel       := 'No lo tiene';
               END;
         END;

         --
         BEGIN
            Var_caracteristica_giap    := 'MAXSPEED';
            Var_value_giap             := NULL;

            SELECT DISTINCT UPPER ( Velocidad )
                       INTO Var_value_giap
                       FROM Cuadra.Giap_voiceplan_movil
                      WHERE Plataforma = 'PCRF'
                        AND Idproducto = 'PL'
                        AND Voiceplan = Cur_dataplan
                        AND Modalidad = Var_modalidad_siebel
                        AND UPPER ( Tipovelo ) = Var_caracteristica_giap;

            IF SQL%FOUND
            THEN
               NULL;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               Var_value_giap             := 'No lo tiene';
         END;

         --
         IF Var_error_noexiste_siebel = 0
         THEN
            IF UPPER ( NVL ( TRIM ( Var_value_giap ), 'a' )) != UPPER ( NVL ( TRIM ( Var_char_val ), 'b' ))
            THEN
               Var_error_distinto         := 1;
            ELSE
               Var_error_distinto         := 0;
            END IF;
         ELSE
            Var_error_distinto         := 0;
         END IF;

         BEGIN
            INSERT INTO Cuadra.Cut_siebel_pcrf
                        ( Row_id_prodprin,
                          Integration_id,
                          Row_id_asset,
                          Error_noexiste_siebel,
                          Error_vacio_siebel,
                          Error_noexiste_uim,
                          Error_distinto,
                          Rut_persona
                        )
                 VALUES ( Cur_row_id_prodprin,
                          Cur_integration_id,
                          Cur_row_id_asset,
                          Var_error_noexiste_siebel,
                          Var_error_vacio_siebel,
                          Var_error_noexiste_uim,
                          Var_error_distinto,
                          Cur_rut_persona
                        );

            IF SQL%ROWCOUNT > 0
            THEN
               COMMIT;
            ELSE
               ROLLBACK;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END LOOP;

   CLOSE Cur_registros;

   --
   OPEN Cur_errores;

   LOOP
      FETCH Cur_errores
       INTO Cur_ou_num_1,
            Cur_integration;

      EXIT WHEN Cur_errores%NOTFOUND;

      BEGIN
         BEGIN
            Var_con_ordenpend01        := 0;

            SELECT /*+ INDEX(Cuadra.S_Org_Ext cui_org_ext_02) */
                   NVL ( COUNT ( 1 ), 0 )
              INTO Var_con_ordenpend01
              FROM Cuadra.S_order A,
                   Cuadra.S_org_ext E
             WHERE E.Ou_num_1 = Cur_ou_num_1
               AND E.Row_id = A.Accnt_id
               AND A.Status_cd NOT IN ( 'Completada', 'Cancelado', 'Revisado' )
               AND A.X_ocs_tipo_orden != 'Temporal';

            IF Var_con_ordenpend01 > 0
            THEN
               Var_con_orden_pend         := 1;
            ELSE
               Var_con_orden_pend         := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               Var_con_orden_pend         := 0;
         END;

         BEGIN
            Var_con_bipend01           := 0;

            SELECT /*+ INDEX(Cuadra.Businessiinteraction Cui_Businessiinteraction_01) */
                   NVL ( COUNT ( 1 ), 0 )
              INTO Var_con_bipend01
              FROM Cuadra.Businessiinteraction
             WHERE Externalobjectid = Cur_integration
               AND Adminstate NOT IN ( 'CANCELLED', 'COMPLETED' );

            IF Var_con_bipend01 > 0
            THEN
               Var_con_bi_pend            := 1;
            ELSE
               Var_con_bi_pend            := 0;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               Var_con_bi_pend            := 0;
         END;

         BEGIN
            UPDATE /*+ INDEX(Cuadra.CUT_SIEBEL_PCRF CUI_SIEBEL_PCRF_01) */Cuadra.Cut_siebel_pcrf
               SET Con_orden_pend = Var_con_orden_pend,
                   Con_bi_pend = Var_con_bi_pend
             WHERE Rut_persona = Cur_ou_num_1
               AND Integration_id = Cur_integration;

            IF SQL%ROWCOUNT > 0
            THEN
               COMMIT;
            ELSE
               ROLLBACK;
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN
               ROLLBACK;
         END;
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END LOOP;

   CLOSE Cur_errores;

   BEGIN
      UPDATE Cuadra.Cut_siebel_pcrf
         SET Error_vacio_siebel = 0
       WHERE Rut_persona IN
                ( '7009977-2', '10317048-6', '11166056-5', '7197169-4', '19422504-0', '13443079-6', '13502639-5',
                  '13479110-1', '15170793-9', '14581824-9', '7398935-3', '17167158-2', '14581824-9' );

      IF SQL%ROWCOUNT > 0
      THEN
         COMMIT;
      ELSE
         ROLLBACK;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;
EXCEPTION
   WHEN OTHERS
   THEN
      NULL;
END; 