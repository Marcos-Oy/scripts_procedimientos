CREATE OR REPLACE PROCEDURE CUADRA.CUP_Cable_GridType
IS
--
Cur_Rut                     VarChar2(30);
Cur_Integration_ID          VarChar2(30);
Cur_Serie                   VarChar2(100);
Cur_Row_id                  VarChar2(15);
Cur_Tipo_Red                VarChar2(50);
--
Var_GridType_Siebel         VarChar2(255):=Null;
Var_CPEGrilla_UIM           VarChar2(255):=Null;
Var_ErrorGridTypeUIM        Number(1);
Var_Con_BIPend01            Number(6);
Var_Flag_ConBIPend          Number(1);
Var_Con_OrdenPend01         Number(6);
Var_Flag_ConOrdenPend       Number(1);
--
Cursor Cur_Registros
Is
    Select Ou_Num_1
          ,Integration_ID
          ,'000000000000'
          ,Row_id
          ,x_Ocs_Modo_Red
     From Cuadra.Cut_Siebel_ProductoP b
    Where b.Permitted_Type = '/service/cable'
      And b.Status_Cd      = 'Activo'
      And b.x_ocs_categoria_detallada   = 'Producto Principal'
      And b.Integration_ID Not In (Select Nvl(Trim(Integration_Id),'*')
                                     From Cuadra.Cut_Siebel_ResultdBox);
Begin
    Open Cur_Registros;
    Loop
     Fetch Cur_Registros
     Into  Cur_Rut
          ,Cur_Integration_ID
          ,Cur_Serie
          ,Cur_Row_id
          ,Cur_Tipo_Red;
    Exit When Cur_Registros%NotFound;
    Begin
        Begin
            Select /*+ INDEX(Cuadra.S_Asset_XA S_ASSET_XA_01) */
                   Char_val
              Into Var_GridType_Siebel
              From Cuadra.S_Asset_XA
             Where Attr_Name = 'GridType'
               And Asset_ID  = Cur_Row_id;
            If Sql%Found Then
                Null;
            End If;
            Exception When Others Then
                Var_GridType_Siebel := '*';
        End;
        Begin
            Select /*+ INDEX(Cuadra.Cut_UIM_RFS CUI_UIM_RFS_01) */
                   Value
              Into Var_CPEGrilla_UIM
              From Cuadra.Cut_UIM_RFS
             Where ExternalObjectID = Cur_Integration_ID
               And Caracteristica   = 'GridType';
            If  Upper(Trim(Var_CPEGrilla_UIM)) != Upper(Trim(Var_GridType_Siebel))
            And Trim(Var_GridType_Siebel) != '*' And Cur_Tipo_Red In ('FUDIG','ANDIG') Then
                Var_ErrorGridTypeUIM := 1;
            Else
                Var_ErrorGridTypeUIM := 0;
            End If;
            Exception When Others Then
                Var_ErrorGridTypeUIM := 0;
        End;
        --
        Var_Con_BIPend01   := 0;
        Var_Flag_ConBIPend := 0;
        Begin
            Select /*+ INDEX(Cuadra.Businessiinteraction Cui_Businessiinteraction_01) */
                   Nvl(Count(1),0)
              Into Var_Con_BIPend01
              From Businessiinteraction
             Where Externalobjectid = Cur_Integration_ID
               And Adminstate Not In ('CANCELLED','COMPLETED');
            If Var_Con_BIPend01 > 0 Then
                Var_Flag_ConBIPend := 1;
            Else
                Var_Flag_ConBIPend := 0;
            End If;
            Exception When Others Then
                Var_Flag_ConBIPend := 0;
        End;
        --
        Var_Con_OrdenPend01   := 0;
        Var_Flag_ConOrdenPend := 0;
        Begin
            Select Nvl(Count(1),0)
              Into Var_Con_OrdenPend01
              From Cuadra.S_Order a ,
                   Cuadra.s_org_ext e
             Where e.ou_num_1          = Cur_Rut
               And e.row_id            = a.accnt_id
               And a.status_cd Not In ('Completada','Cancelado','Revisado')
               And a.X_Ocs_Tipo_Orden != 'Temporal';
            If Var_Con_OrdenPend01 > 0 Then
                Var_Flag_ConOrdenPend := 1;
            Else
                Var_Flag_ConOrdenPend := 0;
            End If;
            Exception When Others Then
                Var_Flag_ConOrdenPend := 0;
        End;
        --
        Begin
            Insert Into Cut_Siebel_ResultdBox
            (Rut_Persona,
             Integration_ID,
             CPE,
             ErrorGridTypeUIM,
             Con_Orden_Pend,
             Con_BI_Pend)
            Values
            (Cur_Rut,
             Cur_Integration_ID,
             Cur_Serie,
             Var_ErrorGridTypeUIM,
             Var_Flag_ConOrdenPend,
             Var_Flag_ConBIPend);
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
    Close Cur_Registros;
    Exception When Others Then
        Null;
End;
