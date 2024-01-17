CREATE OR REPLACE Procedure CUADRA.Cup_Psva_Fonosiebeluim Is
  --
  Cur_Ou_Num_1       Varchar2(30);
  Cur_Addr_Name      Varchar2(100);
  Cur_Row_Id         Varchar2(15);
  Cur_Integration_Id Varchar2(30);
  Cur_Voiceplanuim   Varchar2(255);
  --
  Var_Error_Psva      Number(1);
  Var_Error_Rut       Number(1);
  Var_Nmro_Telefono   Varchar2(50);
  Var_Ctacontrol      Char(1);
  Var_Con_Ordenpend01 Number(6);
  Var_Con_Orden_Pend  Number(1);
  Var_Con_Bipend01    Number(6);
  Var_Con_Bi_Pend     Number(1);
  Var_Nmroregerrores  Number(6);
  Var_Rut_Psva        Char(1);
  --
  Cursor Cur_Registros Is
    Select Ou_Num_1, Addr_Name, Row_Id, Integration_Id, Voiceplanuim
      From Cuadra.Cut_Voiceplanfonosiebeluim
    --Where Tipocpe != 'ONT'
    ;
  Cursor Cur_Errores Is
    Select Ou_Num_1, Integration_Id From Cuadra.Cut_Psva_Fonosiebeluim;
  --   Where Error_PSVA = 1;
  --
  --
Begin
  Begin
    Delete Cuadra.Cut_Psva_Fonosiebeluim;
    Commit;
  Exception
    When Others Then
      Rollback;
  End;
  Open Cur_Registros;
  Loop
    Fetch Cur_Registros
      Into Cur_Ou_Num_1,
           Cur_Addr_Name,
           Cur_Row_Id,
           Cur_Integration_Id,
           Cur_Voiceplanuim;
    Exit When Cur_Registros%Notfound;
    Begin
      Var_Error_Psva := 0;
      Var_Error_Rut  := 0;
      Var_Rut_Psva   := 'N';
      Begin
        /* Select distinct c.attrib_01
        Into Var_Nmro_Telefono
         From Cuadra.Cut_Siebel_ProductoP a ,
              Cuadra.Cut_Siebel_ProductoP d ,
              Cuadra.S_Asset b ,
              Cuadra.S_Asset_X c
        where  a.permitted_type            = '/service/telephony'
          and a.x_Ocs_Categoria_Detallada = 'Producto Principal'
          and a.serv_acct_id              = b.serv_acct_id
          and b.desc_text                in ('Caja MTA / CM' , 'Equipo')
          and b.status_cd                 = 'Activo'
          and b.row_id                    = c.row_id
          and d.serv_acct_id              = b.serv_acct_id
          and d.permitted_type            = '/service/telephony'
          and d.x_Ocs_Categoria_Detallada = 'Producto Principal'
          and a.integration_id=Cur_Integration_Id;*/
        Select /*+ INDEX(Cuadra.Cut_UIM_RFS CUI_UIM_RFS_01) */
         Value
          Into Var_Nmro_Telefono
          From Cuadra.Cut_Uim_Rfs
         Where Externalobjectid = Cur_Integration_Id
           And Caracteristica = 'TN';
        If Sql%Found Then
          Begin
            Select /*+ INDEX(Cuadra.GIAP_VOICEPLAN Cui_GIAP_VOICEPLAN_01) */
             'S'
              Into Var_Ctacontrol
              From Cuadra.Giap_Voiceplan
             Where Pla_Cod_Tipo In ('CONTROL', 'CTRL-TOT', 'PSVA')
               And Pla_Cod_Voice = Trim(Cur_Voiceplanuim)
               And Rownum = 1;
            If Sql%Found Then
              Begin
                Select /*+ INDEX(Cuadra.Sut_PSVA SUI_PSVA_02) */
                 'S'
                  Into Var_Rut_Psva
                  From Cuadra.Sut_Psva
                 Where Rut_Persona = Cur_Ou_Num_1
                   And Rownum = 1;
                If Sql%Found Then
                  Var_Rut_Psva  := 'S';
                  Var_Error_Rut := 1;
                End If;
              Exception
                When Others Then
                  Var_Rut_Psva  := 'N';
                  Var_Error_Rut := 0;
              End;
              Begin
                Select /*+ INDEX(Cuadra.Sut_PSVA SUI_PSVA_01) */
                 0
                  Into Var_Error_Psva
                  From Cuadra.Sut_Psva
                 Where Fono = Var_Nmro_Telefono
                   And Rownum = 1;
                If Sql%Found Then
                  Var_Error_Psva := 0;
                End If;
              Exception
                When Others Then
                  Var_Error_Psva := 1;
              End;
              Begin
                Insert Into Cuadra.Cut_Psva_Fonosiebeluim
                  (Ou_Num_1,
                   Addr_Name,
                   Row_Id,
                   Integration_Id,
                   Fono,
                   Error_Psva,
                   Error_Rut)
                Values
                  (Cur_Ou_Num_1,
                   Cur_Addr_Name,
                   Cur_Row_Id,
                   Cur_Integration_Id,
                   Var_Nmro_Telefono,
                   Var_Error_Psva,
                   Var_Error_Rut);
                If Sql%Rowcount > 0 Then
                  Commit;
                Else
                  Rollback;
                End If;
              Exception
                When Others Then
                  Rollback;
              End;
            End If;
          Exception
            When Others Then
              Var_Nmro_Telefono := 0;
          End;
        End If;
      Exception
        When Others Then
          Var_Nmro_Telefono := 0;
      End;
    Exception
      When Others Then
        Null;
    End;
  End Loop;
  Close Cur_Registros;
  --
  Begin
    Select Count(Ou_Num_1)
      Into Var_Nmroregerrores
      From Cuadra.Cut_Psva_Fonosiebeluim;
  Exception
    When Others Then
      Var_Nmroregerrores := 5001;
  End;
  --
  Open Cur_Errores;
  Loop
    Fetch Cur_Errores
      Into Cur_Ou_Num_1, Cur_Integration_Id;
    Exit When Cur_Errores%Notfound;
    Begin
      If Var_Nmroregerrores > 5000 Then
        Begin
          Var_Con_Ordenpend01 := 0;
          Select /*+ INDEX(Cuadra.S_Org_Ext cui_org_ext_02) */
           Nvl(Count(1), 0)
            Into Var_Con_Ordenpend01
            From Cuadra.s_Order a, Cuadra.s_Org_Ext e
           Where e.Ou_Num_1 = Cur_Ou_Num_1
             And e.Row_Id = a.Accnt_Id
             And a.Status_Cd Not In ('Completada', 'Cancelado', 'Revisado')
             And a.x_Ocs_Tipo_Orden != 'Temporal';
          If Var_Con_Ordenpend01 > 0 Then
            Var_Con_Orden_Pend := 1;
          Else
            Var_Con_Orden_Pend := 0;
          End If;
        Exception
          When Others Then
            Var_Con_Orden_Pend := 0;
        End;
      Else
        Begin
          Var_Con_Ordenpend01 := 0;
          Select Nvl(Count(1), 0)
            Into Var_Con_Ordenpend01
            From Siebel.s_Order@Sblprd.World a, Siebel.s_Org_Ext@Sblprd.World e
           Where e.Ou_Num_1 = Cur_Ou_Num_1
             And e.Row_Id = a.Accnt_Id
             And a.Status_Cd Not In ('Completada', 'Cancelado', 'Revisado')
             And a.x_Ocs_Tipo_Orden != 'Temporal';
          If Var_Con_Ordenpend01 > 0 Then
            Var_Con_Orden_Pend := 1;
          Else
            Var_Con_Orden_Pend := 0;
          End If;
        Exception
          When Others Then
            Var_Con_Orden_Pend := 0;
        End;
      End If;
      Begin
        Var_Con_Bipend01 := 0;
        Select /*+ INDEX(Cuadra.Businessiinteraction Cui_Businessiinteraction_01) */
         Nvl(Count(1), 0)
          Into Var_Con_Bipend01
          From Cuadra.Businessiinteraction
         Where Externalobjectid = Cur_Integration_Id
           And Adminstate Not In ('CANCELLED', 'COMPLETED');
        If Var_Con_Bipend01 > 0 Then
          Var_Con_Bi_Pend := 1;
        Else
          Var_Con_Bi_Pend := 0;
        End If;
      Exception
        When Others Then
          Var_Con_Bi_Pend := 0;
      End;
      Begin
        Update /*+ INDEX(Cuadra.CUT_PSVA_FONOSIEBELUIM CUI_PSVA_FonoSiebelUIM_01) */ Cuadra.Cut_Psva_Fonosiebeluim
           Set Con_Orden_Pend = Var_Con_Orden_Pend, Con_Bi_Pend = Var_Con_Bi_Pend
         Where Ou_Num_1 = Cur_Ou_Num_1
           And Integration_Id = Cur_Integration_Id;
        If Sql%Rowcount > 0 Then
          Commit;
        Else
          Rollback;
        End If;
      Exception
        When Others Then
          Rollback;
      End;
    Exception
      When Others Then
        Null;
    End;
  End Loop;
  Close Cur_Errores;
  --
  Begin
    Update Cuadra.Cut_Psva_Fonosiebeluim
       Set Error_Rut = 0, Error_Psva = 0
     Where (Error_Rut = 1 And Error_Psva = 1)
       And Substr(Trim(Fono), 1, 1) = '9';
    If Sql%Rowcount > 0 Then
      Commit;
    Else
      Rollback;
    End If;
  Exception
    When Others Then
      Rollback;
  End;
  --
Exception
  When Others Then
    Raise_Application_Error(-20001, Sqlerrm);
End;
