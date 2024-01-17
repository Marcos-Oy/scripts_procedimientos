CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_INCOGNITO_CRM
Is
--
Var_NoExistMateIncog_CRM            Number(1);
Var_NoExistMateRutIncog_CRM         Number(1);
Var_Existe                          Char(1);
--
Cur_MAC                             VarChar2(50);
Cur_Rut_Persona                     VarChar2(50);
--
Cursor Cur_Incognito_Inet
Is
    Select MAC
          ,RUT
      From Cuadra.Sut_Internet
     Where Clusters Not In (146)
       And Plan2 Not In ('TSSI','BLOCK');
--
--
Begin
    Open Cur_Incognito_Inet;
    Loop
    Fetch Cur_Incognito_Inet
     Into Cur_MAC
         ,Cur_Rut_Persona;
    Exit When Cur_Incognito_Inet%NotFound;
    Begin
        Var_Existe               := 'N';
        Var_NoExistMateIncog_CRM := 0;
        Begin
            Select /*+ INDEX(Cuadra.Cut_Siebel_ProductoP CUI_SIEBEL_PRODUCTOP_09) */
                   'S'
              Into Var_Existe
              From Cuadra.Cut_Siebel_ProductoP
             Where x_Ocs_Attrib_59 = Cur_MAC
               And Status_CD       = 'Activo'
               And Permitted_Type  = '/service/broadband'
               And RowNum          = 1;
          If Sql%Found Then
              Var_NoExistMateIncog_CRM := 0;
          End If;
            Exception When Others Then
                Var_NoExistMateIncog_CRM := 1;
        End;
        Begin
            Var_NoExistMateRutIncog_CRM := 0;
            Select /*+ INDEX(Cuadra.Cut_Siebel_ProductoP CUI_SIEBEL_PRODUCTOP_09) */
                  'S'
              Into Var_Existe
              From Cuadra.Cut_Siebel_ProductoP
             Where x_Ocs_Attrib_59 = Cur_MAC
               And Status_CD       = 'Activo'
               And Permitted_Type  = '/service/broadband'
               And Ou_Num_1        = Ltrim(Cur_Rut_Persona,'0')
               And RowNum          = 1;
            If Sql%Found Then
                Var_NoExistMateRutIncog_CRM := 0;
            End If;
            Exception When Others Then
                Var_NoExistMateRutIncog_CRM := 1;
        End;
        Begin
            Update Cuadra.Cut_Siebel_ResultInet
               Set NoExistMateIncog_CRM    = Var_NoExistMateIncog_CRM
                  ,NoExistMateRutIncog_CRM = Var_NoExistMateRutIncog_CRM
             Where CPE         = Cur_MAC
         And Rut_Persona = Cur_Rut_Persona;
            If Sql%RowCount > 0 Then
                Commit;
            Else
                Rollback;
            End If;
            Exception When Others Then
                Rollback;
        End;
        Exception When Others Then
            Null;
    End;
    End Loop;
    Close Cur_Incognito_Inet;
    Exception When Others Then
        Null;
End;
