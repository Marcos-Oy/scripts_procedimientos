CREATE OR REPLACE Procedure CUADRA.Cup_Voiceplanfonosiebeluim Is
  --
  Cur_Ou_Num_1        Varchar2(30);
  Cur_Addr_Name       Varchar2(100);
  Cur_Row_Id          Varchar2(15);
  Cur_Integration_Id  Varchar2(30);
  Cur_Voiceplansiebel Varchar2(255);
  Cur_Tipocpe         Varchar2(39);
  Cur_Voiceplanuim    Varchar2(255);
  --
  Var_Voiceplanuim    Varchar2(255);
  Var_Con_Ordenpend01 Number(6);
  Var_Con_Orden_Pend  Number(1);
  Var_Con_Bipend01    Number(6);
  Var_Con_Bi_Pend     Number(1);
  --
  Cursor Cur_Registros Is
    Select a.Ou_Num_1,
           a.Addr_Name,
           a.Row_Id,
           a.x_Ocs_Cod_Tipo_Item,
           a.Integration_Id,
           b.Tipocpe
      From Cuadra.Cut_Siebel_Productop a, Cuadra.Xvtr_Siebel_Info_Series_t b
     Where a.Permitted_Type            = '/service/telephony'
       And a.x_Ocs_Categoria_Detallada = 'Producto Principal'
       And a.x_Ocs_Attrib_59           = b.Cod_Serie
       And a.CPE_Type                 != 'ONT';
  --
  Cursor Cur_Voiceplan Is
    Select Ou_Num_1, Integration_Id, Voiceplansiebel, Voiceplanuim
      From Cuadra.Cut_Voiceplanfonosiebeluim
     Where Voiceplansiebel != Voiceplanuim;
  --
  --
Begin
  Begin
    Delete Cuadra.Cut_Voiceplanfonosiebeluim;
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
           Cur_Voiceplansiebel,
           Cur_Integration_Id,
           Cur_Tipocpe;
    Exit When Cur_Registros%Notfound;
    Begin
      Begin
        Select /*+ INDEX(Cuadra.Cut_UIM_RFS Cui_UIM_RFS_01) */
         Trim(Value)
          Into Var_Voiceplanuim
          From Cuadra.Cut_Uim_Rfs
         Where Externalobjectid = Cur_Integration_Id
           And Caracteristica = 'VoicePlan'
           And Rownum = 1;
        If Sql%Found Then
          Null;
        End If;
      Exception
        When Others Then
          Begin
            Select /*+ INDEX(Cuadra.Cut_UIM_CFS Cui_UIM_CFS_01) */
             Trim(Value)
              Into Var_Voiceplanuim
              From Cuadra.Cut_Uim_Cfs
             Where Externalobjectid = Cur_Integration_Id
               And Caracteristica = 'VoicePlan'
               And Rownum = 1;
            If Sql%Found Then
              Null;
            End If;
          Exception
            When Others Then
              Var_Voiceplanuim := '*';
          End;
      End;
      Begin
        Insert Into Cuadra.Cut_Voiceplanfonosiebeluim
          (Ou_Num_1,
           Addr_Name,
           Row_Id,
           Integration_Id,
           Tipocpe,
           Voiceplansiebel,
           Voiceplanuim,
           Con_Orden_Pend,
           Con_Bi_Pend)
        Values
          (Cur_Ou_Num_1,
           Cur_Addr_Name,
           Cur_Row_Id,
           Cur_Integration_Id,
           Cur_Tipocpe,
           Cur_Voiceplansiebel,
           Var_Voiceplanuim,
           0,
           0);
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
  Close Cur_Registros;
  --
  Open Cur_Voiceplan;
  Loop
    Fetch Cur_Voiceplan
      Into Cur_Ou_Num_1, Cur_Integration_Id, Cur_Voiceplansiebel, Cur_Voiceplanuim;
    Exit When Cur_Voiceplan%Notfound;
    Begin
      Begin
        Var_Con_Ordenpend01 := 0;
        Select Nvl(Count(1), 0)
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
      --
      Begin
        Var_Con_Bipend01 := 0;
        Select /*+ INDEX(Cuadra.Businessiinteraction Cui_Businessiinteraction_01) */
         Nvl(Count(1), 0)
          Into Var_Con_Bipend01
          From Businessiinteraction
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
      If Var_Con_Orden_Pend = 1 Or Var_Con_Bi_Pend = 1 Then
        Begin
          Update /*+ INDEX(Cuadra.Cut_VoicePlanFonoSiebelUIM CUI_VoicePlanFonoSiebelUIM_01) */ Cuadra.Cut_Voiceplanfonosiebeluim
             Set Con_Orden_Pend = Var_Con_Orden_Pend, Con_Bi_Pend = Var_Con_Bi_Pend
           Where Ou_Num_1 = Cur_Ou_Num_1
             And Integration_Id = Cur_Integration_Id;
          If Sql%Rowcount > 0 Then
            Commit;
          End If;
        Exception
          When Others Then
            Rollback;
        End;
      End If;
    Exception
      When Others Then
        Null;
    End;
  End Loop;
  Close Cur_Voiceplan;
Exception
  When Others Then
    Raise_Application_Error(-20001, Sqlerrm);
End;
