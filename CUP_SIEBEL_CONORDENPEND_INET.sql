CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_CONORDENPEND_INET
Is
--
Var_Con_OrdenPend01                 Number(6);
Var_Con_OrdenPend03                 Number(6);
Var_Nmro_RegInet                    Number(10):=0;
--
Cur_CPE                             VarChar2(100);
Cur_Rut_Persona                     VarChar2(30);
--
Cursor Cur_Siebel_Inet
Is
    Select CPE
          ,Rut_Persona
      From Cuadra.Cut_Siebel_ResultInet
     Where Nvl(Cpe_Vacia,0)                 = 1
        or Nvl(Cpe_Duplicada_Siebel,0)      = 1
        or Nvl(Nmro_Duplicadas,0)           = 1
        or Nvl(Cpe_Duplicada_Mismorut,0)    = 1
        or Nvl(Cpe_Duplicada_Otrorut,0)     = 1
        or Nvl(Cpe_Duplicada_Ctaserv,0)     = 1
        or Nvl(Cpe_Noexist_Uim,0)           = 1
        or Nvl(Cpe_Distinta_Marca,0)        = 1
        or Nvl(Cpe_Distinto_Modelo,0)       = 1
        or Nvl(Cpe_Servicio_Distestd,0)     = 1
        or Nvl(Cpe_Noexist_Brm,0)           = 1
        or Nvl(Cpe_Enotro_Rut,0)            = 1
        or Nvl(Cpe_Sinprodprin,0)           = 1
        or Nvl(Cpe_Otrorutserv_Uim,0)       = 1
        or Nvl(Cpe_Distestado_Siebuim,0)    = 1
        or Nvl(Cpe_Noexiste_Siebuim,0)      = 1
        or Nvl(Cpe_Distinta_Tecnologia,0)   = 1
        or Nvl(Cpe_Distinto_Routingmode,0)  = 1
        or Nvl(Cpe_Distinto_Tipomaterial,0) = 1
        or Nvl(Cpe_Noexisteincognito,0)     = 1
        or Nvl(Cpe_Duplicadaincognito,0)    = 1
        or Nvl(Cpe_Rutdistinincognito,0)    = 1
        or Nvl(Cpe_Estadodistinincognito,0) = 1
        or Nvl(Cpe_Locadistinincognito,0)   = 1
        or Nvl(Cpe_Marcadistinincognito,0)  = 1
        or Nvl(Cpe_Modelodistinincognito,0) = 1
        or Nvl(Cpe_Routingmodeincognito,0)  = 1
        or Nvl(Cpe_Distinvelosiebuim,0)     = 1
        or Nvl(Cpe_Con_Error,0)             = 1
        or Nvl(Cpe_Distinvelosiebinc,0)     = 1
        or Nvl(Cpe_Errordocsis,0)           = 1
        or Nvl(Cpe_Errormodelodocsis,0)     = 1
        or Nvl(Noexistmateincog_Crm,0)      = 1
        or Nvl(Noexistmaterutincog_Crm,0)   = 1
        or Nvl(Cpe_Errordocsisuim,0)        = 1
        or Nvl(Cpe_Errorflagretorno,0)      = 1
        or Nvl(Cpe_Errorequipromo,0)        = 1
        or Nvl(MAC_Mate_Act_TangoAndes,0)   = 1
        or Nvl(PromoInetEquInact,0)         = 1
        or Nvl(PromoInetSinEquipo,0)        = 1
        or Nvl(PromoInetIgualEquInact,0)    = 1
        or Nvl(DosPromoUnEq,0)              = 1
        or Nvl(CPE_ErrorNodo,0)             = 1
        or Nvl(CPE_ErrorSubNodo,0)          = 1
        or Nvl(CPE_ErrorMacAddress,0)       = 1
        or Nvl(Ciclo_Inicio,0)              = 1
        or Nvl(Rut_Distinto,0)              = 1
        or Nvl(CPE_ExistEBS,0)              = 1
        or Nvl(CPE_MACVaciaEquipo,0)        = 1
        or Nvl(CPE_MACVaciaPromo,0)         = 1
        or Nvl(CPE_Vacio_RoutingMode,0)     = 1;
--
--
Begin
    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set Con_Orden_Pend = 0;
        If Sql%RowCount > 0 Then
            Commit;
        End If;
        Exception When Others Then
            Rollback;
    End;
    Begin
        Select Count(1)
          Into Var_Nmro_RegInet
          From Cuadra.Cut_Siebel_ResultInet
         Where Nvl(Cpe_Vacia,0)                 = 1
            or Nvl(Cpe_Duplicada_Siebel,0)      = 1
            or Nvl(Nmro_Duplicadas,0)           = 1
            or Nvl(Cpe_Duplicada_Mismorut,0)    = 1
            or Nvl(Cpe_Duplicada_Otrorut,0)     = 1
            or Nvl(Cpe_Duplicada_Ctaserv,0)     = 1
            or Nvl(Cpe_Noexist_Uim,0)           = 1
            or Nvl(Cpe_Distinta_Marca,0)        = 1
            or Nvl(Cpe_Distinto_Modelo,0)       = 1
            or Nvl(Cpe_Servicio_Distestd,0)     = 1
            or Nvl(Cpe_Noexist_Brm,0)           = 1
            or Nvl(Cpe_Enotro_Rut,0)            = 1
            or Nvl(Cpe_Sinprodprin,0)           = 1
            or Nvl(Cpe_Otrorutserv_Uim,0)       = 1
            or Nvl(Cpe_Distestado_Siebuim,0)    = 1
            or Nvl(Cpe_Noexiste_Siebuim,0)      = 1
            or Nvl(Cpe_Distinta_Tecnologia,0)   = 1
            or Nvl(Cpe_Distinto_Routingmode,0)  = 1
            or Nvl(Cpe_Distinto_Tipomaterial,0) = 1
            or Nvl(Cpe_Noexisteincognito,0)     = 1
            or Nvl(Cpe_Duplicadaincognito,0)    = 1
            or Nvl(Cpe_Rutdistinincognito,0)    = 1
            or Nvl(Cpe_Estadodistinincognito,0) = 1
            or Nvl(Cpe_Locadistinincognito,0)   = 1
            or Nvl(Cpe_Marcadistinincognito,0)  = 1
            or Nvl(Cpe_Modelodistinincognito,0) = 1
            or Nvl(Cpe_Routingmodeincognito,0)  = 1
            or Nvl(Cpe_Distinvelosiebuim,0)     = 1
            or Nvl(Cpe_Con_Error,0)             = 1
            or Nvl(Cpe_Distinvelosiebinc,0)     = 1
            or Nvl(Cpe_Errordocsis,0)           = 1
            or Nvl(Cpe_Errormodelodocsis,0)     = 1
            or Nvl(Noexistmateincog_Crm,0)      = 1
            or Nvl(Noexistmaterutincog_Crm,0)   = 1
            or Nvl(Cpe_Errordocsisuim,0)        = 1
            or Nvl(Cpe_Errorflagretorno,0)      = 1
            or Nvl(Cpe_Errorequipromo,0)        = 1
            or Nvl(MAC_Mate_Act_TangoAndes,0)   = 1
            or Nvl(PromoInetEquInact,0)         = 1
            or Nvl(PromoInetSinEquipo,0)        = 1
            or Nvl(PromoInetIgualEquInact,0)    = 1
            or Nvl(DosPromoUnEq,0)              = 1
            or Nvl(CPE_ErrorNodo,0)             = 1
            or Nvl(CPE_ErrorSubNodo,0)          = 1
            or Nvl(CPE_ErrorMacAddress,0)       = 1
            or Nvl(Ciclo_Inicio,0)              = 1
            or Nvl(Rut_Distinto,0)              = 1
            or Nvl(CPE_ExistEBS,0)              = 1
            or Nvl(CPE_MACVaciaEquipo,0)        = 1
            or Nvl(CPE_MACVaciaPromo,0)         = 1
            or Nvl(CPE_Vacio_RoutingMode,0)     = 1;
        Exception When Others Then
           Null;
    End;
    Begin
        Update Cuadra.Cut_Siebel_ResultInet
           Set Con_Orden_Pend = 0;
        If Sql%RowCount > 0 Then
            Commit;
        End If;
        Exception When Others Then
            Rollback;
    End;
--  If Var_Nmro_RegInet > 10 Then
        Open Cur_Siebel_Inet;
        Loop
        Fetch Cur_Siebel_Inet
         Into Cur_CPE
             ,Cur_Rut_Persona;
        Exit When Cur_Siebel_Inet%NotFound;
        Begin
            Var_Con_OrdenPend01 := 0;
            Var_Con_OrdenPend03 := 0;
            Begin
                Select Nvl(Count(1),0)
                  Into Var_Con_OrdenPend01
                  From Cuadra.S_Order a ,
                       Cuadra.s_org_ext e
                 Where e.ou_num_1          = Cur_Rut_Persona
                   And e.row_id            = a.accnt_id
                   And a.status_cd Not In ('Completada','Cancelado','Revisado')
                   And a.X_Ocs_Tipo_Orden != 'Temporal';
                If Var_Con_OrdenPend01 > 0 Then
                    Var_Con_OrdenPend03 := 1;
                Else
                    Var_Con_OrdenPend03 := 0;
                End If;
                Exception When Others Then
                    Var_Con_OrdenPend03 := 0;
            End;
            If Var_Con_OrdenPend03 = 1 Then
                Begin
                    Update Cuadra.Cut_Siebel_ResultInet
                       Set Con_Orden_Pend = Var_Con_OrdenPend03
                     Where CPE            = Cur_CPE
                       And Rut_Persona    = Cur_Rut_Persona;
                    If Sql%RowCount > 0 Then
                        Commit;
                    End If;
                    Exception When Others Then
                        Rollback;
                End;
            End If;
            Exception When Others Then
                Null;
        End;
        End Loop;
        Close Cur_Siebel_Inet;
--  Else
--      Open Cur_Siebel_Inet;
--      Loop
--      Fetch Cur_Siebel_Inet
--       Into Cur_CPE
--           ,Cur_Rut_Persona;
--      Exit When Cur_Siebel_Inet%NotFound;
--      Begin
--          Var_Con_OrdenPend01 := 0;
--          Var_Con_OrdenPend03 := 0;
--          Begin
--              Select Nvl(Count(1),0)
--                Into Var_Con_OrdenPend01
--                From siebel.s_order@sblprd.world a ,
--                     siebel.s_org_ext@sblprd.world e
--               Where e.ou_num_1 = Cur_Rut_Persona
--                 And e.row_id = a.accnt_id
--                 And a.status_cd Not In ('Completada','Cancelado','Revisado')
--                 And a.X_Ocs_Tipo_Orden != 'Temporal';
--              If Var_Con_OrdenPend01 > 0 Then
--                  Var_Con_OrdenPend03 := 1;
--              Else
--                  Var_Con_OrdenPend03 := 0;
--              End If;
--              Exception When Others Then
--                  Var_Con_OrdenPend03 := 0;
--          End;
--          If Var_Con_OrdenPend03 = 1 Then
--              Begin
--                  Update Cuadra.Cut_Siebel_ResultInet
--                     Set Con_Orden_Pend = Var_Con_OrdenPend03
--                   Where CPE            = Cur_CPE
--                     And Rut_Persona    = Cur_Rut_Persona;
--                  If Sql%RowCount > 0 Then
--                      Commit;
--                  End If;
--                  Exception When Others Then
--                      Rollback;
--              End;
--          End If;
--          Exception When Others Then
--              Null;
--      End;
--      End Loop;
--      Close Cur_Siebel_Inet;
--  End If;
    Exception When Others Then
        Null;
End;
