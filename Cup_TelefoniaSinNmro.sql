CREATE OR REPLACE PROCEDURE CUADRA.Cup_TelefoniaSinNmro
IS
--
Cur_Ou_Num_1                  VarChar2(30);
Cur_Integration_ID            VarChar2(30);
Cur_Addr_Name                 VarChar2(100);
Cur_Serial_Num                VarChar2(100);
Cur_Root_Asset_ID             VarChar2(15);
--
Var_Row_ID                    VarChar2(15);
Var_x_Ocs_Categoria_Detallada VarChar2(50);
Var_Name                      VarChar2(100);
Var_Serial_Num1               VarChar2(100);
Cur_Serial_Num2               VarChar2(100);
Var_Serial_Num3               VarChar2(100);
Var_Integration_ID            VarChar2(30);
--
Cursor Cur_Registros
Is
    Select CLI.Ou_Num_1
          ,A.Integration_ID
          ,ADR.Addr_Name
          ,A.SERIAL_NUM
          ,A.Root_Asset_Id
      From Cuadra.S_ASSET A,
           Cuadra.S_ASSET_X AX,
           Cuadra.S_ORG_EXT CLI,
           Cuadra.S_ORG_EXT CLIF,
           Cuadra.s_prod_int Prod,
           Cuadra.S_ADDR_PER ADR
     WHERE A.Row_Id                        = AX.Row_Id
       And A.Serv_Acct_Id                  = Cli.Row_Id
       And A.bill_Accnt_Id                 = Clif.Row_Id
       And Prod.Row_Id                     = A.Prod_Id
       And Cli.Pr_Addr_Id                  = Adr.Row_Id
       And A.Status_Cd                   In ('Activo','Suspendido')
       And CLI.Cust_Stat_Cd              In ('Activo','Suspendido','Inactivo')
       And CLI.Accnt_Type_Cd               = 'Servicio'
       And Prod.Permitted_Type             = '/service/telephony'
       And A.Status_Cd                  In ('Activo','Suspendido')
       And Prod.x_Ocs_Categoria_Detallada  = 'Producto Customizable'
       And A.Serial_Num Is Not Null
       And CLI.Ou_Num_1 Not In (Select z.Ou_Num_1 From Cut_RutTelefoniSip z);
--
Cursor Cur_Habilita
Is
    Select A.Serial_Num,
           Prod.x_Ocs_Categoria_Detallada,
           Prod.Name,
           Ax.Row_Id
      From Cuadra.S_ASSET A,
           Cuadra.S_ASSET_X AX,
           Cuadra.S_ORG_EXT CLI,
           Cuadra.S_ORG_EXT CLIF,
           Cuadra.s_prod_int Prod,
           Cuadra.S_ADDR_PER ADR
     WHERE A.row_id                        = AX.row_id
       And A.Serv_Acct_Id                  = Cli.Row_Id
       And A.bill_Accnt_Id                 = Clif.Row_Id
       And PROD.ROW_ID                     = a.prod_id
       And cli.pr_addr_id                  = adr.row_id
       And A.Status_Cd                    In ('Activo','Suspendido')
       And CLI.CUST_STAT_CD               In ('Activo','Suspendido','Inactivo')
       And CLI.accnt_type_cd               = 'Servicio'
       And Prod.Permitted_Type             = '/service/telephony'
       And Prod.x_Ocs_Categoria_Detallada  = 'Habilitaciones'
       And A.Root_Asset_ID                 = Cur_Root_Asset_ID;
--
Begin
    Begin
        Delete Cuadra.Cut_TelefoniaSinNmro;
        Commit;
        Exception When Others Then
            Rollback;
    End;
    Open Cur_Registros;
    Loop
    Fetch Cur_Registros
     Into Cur_Ou_Num_1,
          Cur_Integration_ID,
          Cur_Addr_Name,
          Cur_Serial_Num,
          Cur_Root_Asset_ID;
    Exit When Cur_Registros%NotFound;
    Begin
        Begin
            Select A.Serial_Num,
                   Prod.x_Ocs_Categoria_Detallada,
                   Prod.Name,
                   Ax.Row_Id,
                   A.Integration_Id
              Into Var_Serial_Num1,
                   Var_x_Ocs_Categoria_Detallada,
                   Var_Name,
                   Var_Row_Id,
                   Var_Integration_Id
              From Cuadra.S_ASSET A,
                   Cuadra.S_ASSET_X AX,
                   Cuadra.S_ORG_EXT CLI,
                   Cuadra.S_ORG_EXT CLIF,
                   Cuadra.s_prod_int Prod,
                   Cuadra.S_ADDR_PER ADR
             WHERE A.row_id                        = AX.row_id
               And A.Serv_Acct_Id                  = Cli.Row_Id
               And A.bill_Accnt_Id                 = Clif.Row_Id
               And PROD.ROW_ID                     = a.prod_id
               And cli.pr_addr_id                  = adr.row_id
               And A.Status_Cd                    In ('Activo','Suspendido')
               And CLI.CUST_STAT_CD               In ('Activo','Suspendido','Inactivo')
               And CLI.accnt_type_cd               = 'Servicio'
               And Prod.Permitted_Type             = '/service/telephony'
               And Prod.x_Ocs_Categoria_Detallada  = 'Producto Principal'
               And A.Root_Asset_ID                 = Cur_Root_Asset_ID;
            If Sql%Found Then
                Begin
                    Insert Into Cuadra.Cut_TelefoniaSinNmro
                    (x_Ocs_Categoria_Detallada,
                     Name,
                     Ou_Num_1,
                     Integration_ID,
                     Addr_Name,
                     Root_Asset_ID,
                     Row_ID,
                     Serial_Num_ProdCust,
                     Serial_Num)
                    Values
                    (Var_x_Ocs_Categoria_Detallada,
                     Var_Name,
                     Cur_Ou_Num_1,
                     Var_Integration_ID,
                     Cur_Addr_Name,
                     Cur_Root_Asset_ID,
                     Var_Row_ID,
                     Cur_Serial_Num,
                     Var_Serial_Num1);
                    If Sql%RowCount > 0 Then
                        Commit;
                    Else
                        Rollback;
                    End If;
                    Exception When Others Then
                        Rollback;
                End;
            End If;
            Exception When Others Then
                Var_Serial_Num1 := 'No existe Asset Producto Principal';
        End;
        --
        Open Cur_Habilita;
        Loop
        Fetch Cur_Habilita
         Into Cur_Serial_Num2,
              Var_x_Ocs_Categoria_Detallada,
              Var_Name,
              Var_Row_Id;
         Exit When Cur_Habilita%NotFound;  
        Begin
                    Insert Into Cuadra.Cut_TelefoniaSinNmro
                    (x_Ocs_Categoria_Detallada,
                     Name,
                     Ou_Num_1,
                     Integration_ID,
                     Addr_Name,
                     Root_Asset_ID,
                     Row_ID,
                     Serial_Num_ProdCust,
                     Serial_Num)
                    Values
                    (Var_x_Ocs_Categoria_Detallada,
                     Var_Name,
                     Cur_Ou_Num_1,
                     Var_Integration_ID,
                     Cur_Addr_Name,
                     Cur_Root_Asset_ID,
                     Var_Row_ID,
                     Cur_Serial_Num,
                     Cur_Serial_Num2);
            If Sql%RowCount > 0 Then
                Commit;
            Else
                Rollback;
            End If;
            Exception When Others Then
                Rollback;
        End;
        End Loop;
        Close Cur_Habilita;
        --
        Begin
            Select A.Serial_Num,
                   Prod.x_Ocs_Categoria_Detallada,
                   Prod.Name,
                   Ax.Row_Id
              Into Var_Serial_Num3,
                   Var_x_Ocs_Categoria_Detallada,
                   Var_Name,
                   Var_Row_ID
              From Cuadra.S_ASSET A,
                   Cuadra.S_ASSET_X AX,
                   Cuadra.S_ORG_EXT CLI,
                   Cuadra.S_ORG_EXT CLIF,
                   Cuadra.s_prod_int Prod,
                   Cuadra.S_ADDR_PER ADR
             WHERE A.row_id                        = AX.row_id
               And A.Serv_Acct_Id                  = Cli.Row_Id
               And A.bill_Accnt_Id                 = Clif.Row_Id
               And PROD.ROW_ID                     = a.prod_id
               And cli.pr_addr_id                  = adr.row_id
               And A.Status_Cd                    In ('Activo','Suspendido')
               And CLI.CUST_STAT_CD               In ('Activo','Suspendido','Inactivo')
               And CLI.accnt_type_cd               = 'Servicio'
             --And Prod.Permitted_Type             = '/service/telephony'
               And Prod.x_Ocs_Categoria_Detallada  = 'Otros Fijos'
               And Prod.Name                       = 'Numero Comun'
               And A.Root_Asset_ID                 = Cur_Root_Asset_ID;
            If Sql%Found Then
                Begin
                    Insert Into Cuadra.Cut_TelefoniaSinNmro
                    (x_Ocs_Categoria_Detallada,
                     Name,
                     Ou_Num_1,
                     Integration_ID,
                     Addr_Name,
                     Root_Asset_ID,
                     Row_ID,
                     Serial_Num_ProdCust,
                     Serial_Num)
                    Values
                    (Var_x_Ocs_Categoria_Detallada,
                     Var_Name,
                     Cur_Ou_Num_1,
                     Var_Integration_ID,
                     Cur_Addr_Name,
                     Cur_Root_Asset_ID,
                     Var_Row_ID,
                     Cur_Serial_Num,
                     Var_Serial_Num3);
                    If Sql%RowCount > 0 Then
                        Commit;
                    Else
                        Rollback;
                    End If;
                    Exception When Others Then
                        Rollback;
                End;
            End If;
            Exception When Others Then
                Var_Serial_Num3 := 'No existe Asset Otros Fijos';
        End;
        Exception When Others Then
            Null;
    End;
    End Loop;
    Close Cur_Registros;
    Exception When Others Then
        Null;
End;
