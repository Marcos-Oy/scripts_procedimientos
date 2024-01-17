CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_ANALIZA_TELEFONIA
IS
--
Cur_MAC                     VarChar2(100);
Cur_Name                    VarCHar2(100);
Cur_Rut                     VarChar2(30);
Cur_Row_Id                  VarChar2(15);
Cur_Integration             VarChar2(30);
Cur_Addr_Name               VarChar2(100);
--
Var_Existe                  Number(1);
Var_NoExist_Fono_UIM        Char(1);
--
Var_Con_OrdenPend01         Number(6);
Var_Con_Orden_Pend          Number(1);
Var_Con_BIPend01            Number(6);
Var_Con_Bi_Pend             Number(1);
Var_NmroRegErrores          Number(6);
--
Cur_Ou_Num_1                VarChar2(30);
Cur_Integration_Id          VarChar2(30);
--
Cursor Cur_Siebel_Fono
Is
    Select b.x_Ocs_Attrib_59
          ,b.Cuenta_Serv
          ,b.Ou_Num_1
          ,b.Row_Id
          ,b.Integration_ID
          ,b.Addr_Name
      From Cuadra.Cut_Siebel_ProductoP b
     Where b.Permitted_Type             = '/service/telephony'
--     And b.x_ocs_attrib_59 Is Not Null
       And b.Status_Cd                  In ('Activo','Suspendido')
       And b.x_ocs_categoria_detallada  = 'Producto Principal'
       And Not Exists (Select * From Rut_Excluidos a Where a.Rut_Persona = b.ou_num_1);

Cursor Cur_Errores
Is 
    Select Rut_Persona
          ,Integration_Id
      From Cut_Existe_UIM_Telefonia 
     Where ExisteFonoUIM = 1; 

Begin
    Begin
        Delete Cuadra.Cut_Existe_UIM_Telefonia;
        Commit;
        Exception When Others Then
            Rollback;
    End;
    Open Cur_Siebel_Fono;
    Loop
     Fetch Cur_Siebel_Fono
     Into  Cur_MAC
          ,Cur_Name
          ,Cur_Rut
          ,Cur_Row_Id
          ,Cur_Integration
          ,Cur_Addr_Name;
    Exit When Cur_Siebel_Fono%NotFound;   
    Begin
        Var_NoExist_Fono_UIM := 0;
        Select /*+ INDEX(Cuadra.Cut_UIM_Servicios Cui_UIM_Servicios_01) */
               0
          Into Var_Existe
          From Cuadra.Cut_UIM_Servicios
         Where ExternalObjectID = Cur_Integration
           And RowNum           = 1;
        If Sql%Found Then
            Null;
        End If;
        Exception When Others Then
            Var_NoExist_Fono_UIM := 1;
    End;   
    Begin
        Insert Into Cuadra.Cut_Existe_UIM_Telefonia
          ( Rut_Persona
            ,CPE
            ,Integration_ID
            ,ExisteFonoUIM
            ,Addr_Name
          )
          Values
          ( Cur_Rut
           ,Cur_MAC
           ,Cur_Integration
           ,Var_NoExist_Fono_UIM
           ,Cur_Addr_Name
          );
          If SQL%RowCount > 0 Then
              Commit;
          Else
              Rollback;
          End If;
          Exception When Others Then
              Rollback;
    End;
    End Loop;
    Close Cur_Siebel_Fono;
--
    Begin
        Update Cuadra.Cut_Existe_UIM_Telefonia
           Set Con_Orden_Pend = 0,
               Con_BI_Pend    = 0;
        If Sql%Rowcount > 0 Then
            Commit;
        Else
            Rollback;
        End If;
        Exception When Others Then
            Rollback;
    End;
    Begin
        Select Count(1)
          Into Var_NmroRegErrores  
          From Cut_Existe_UIM_Telefonia 
         Where ExisteFonoUIM = 1; 
        If Sql%RowCount > 0 Then
            Null;
        End If;
        Exception When Others Then
            Var_NmroRegErrores := 0;
    End;
    Open Cur_Errores;
    Loop
    Fetch Cur_Errores
     Into Cur_Ou_Num_1,
          Cur_Integration_Id;
    Exit When Cur_Errores%NotFound;
    Begin
        If Var_NmroRegErrores > 10000 Then
            Begin
                Var_Con_OrdenPend01 := 0;
                Select Nvl(Count(1),0)
                  Into Var_Con_OrdenPend01
                  From Cuadra.S_Order a ,
                       Cuadra.S_Org_Ext e
                 Where e.ou_num_1          = Cur_Ou_Num_1
                   And e.row_id            = a.accnt_id
                   And a.status_cd Not In ('Completada','Cancelado','Revisado')
                   And a.X_Ocs_Tipo_Orden != 'Temporal';
                If Var_Con_OrdenPend01 > 0 Then
                    Var_Con_Orden_Pend := 1;
                Else
                    Var_Con_Orden_Pend := 0;
                End If;
                Exception When Others Then
                    Var_Con_Orden_Pend := 0;
            End;
        Else
            Begin
                Var_Con_OrdenPend01 := 0;
                Select Nvl(Count(1),0)
                  Into Var_Con_OrdenPend01
                  From siebel.S_Order@sblprd.world a ,
                       siebel.S_Org_Ext@sblprd.world e
                 Where e.ou_num_1          = Cur_Ou_Num_1
                   And e.row_id            = a.accnt_id
                   And a.status_cd Not In ('Completada','Cancelado','Revisado')
                   And a.X_Ocs_Tipo_Orden != 'Temporal';
                If Var_Con_OrdenPend01 > 0 Then
                    Var_Con_Orden_Pend := 1;
                Else
                    Var_Con_Orden_Pend := 0;
                End If;
                Exception When Others Then
                    Var_Con_Orden_Pend := 0;
            End;
        End If;
        Begin
            Var_Con_BIPend01 := 0;
            Select /*+ INDEX(Cuadra.Businessiinteraction Cui_Businessiinteraction_01) */
                   Nvl(Count(1),0)
              Into Var_Con_BIPend01
              From Cuadra.Businessiinteraction
             Where Externalobjectid = Cur_Integration_Id
               And Adminstate Not In ('CANCELLED','COMPLETED');
            If Var_Con_BIPend01 > 0 Then
                Var_Con_BI_Pend := 1;
            Else
                Var_Con_BI_Pend := 0;
            End If;
            Exception When Others Then
                Var_Con_BI_Pend := 0;
        End;  
        Begin
            Update Cuadra.Cut_Existe_UIM_Telefonia
               Set Con_Orden_Pend = Var_Con_Orden_Pend,
                   Con_BI_Pend    = Var_Con_BI_Pend
             Where Rut_Persona    = Cur_Ou_Num_1
               And Integration_Id = Cur_Integration_Id;
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
    Close Cur_Errores;
--    
    Exception When Others Then
        Null;
End;
