CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_CORRECCION_TIVO 
IS

Cur_CustomerId_tivo         VarChar2(20);
Cur_Customer_Id             VarChar2(30);
Cur_Row_Id                  VarChar2(15);
Cur_Cpe                     VarChar2(100);
--
Cur_Codi_Paquete            VarChar2(30);
--
Var_Localidad               VarChar2(30);
Var_Estado                  VarChar2(30);
Var_CustomTag               VarChar2(100);
Var_EtiquetaCliente         VarChar2(1000);
Var_Canales                 VarChar2(1000);
Var_Datos                   VarChar2(4000);
Var_cant                    Number(1):= 0;
Var_ExisteCustomerId        Number(1):= 0;        
--
l_File                    Utl_File.File_Type;
l_File_Name               VarChar2 (2000);
--
VarArchivo                VarChar2(50);
--
Cur_Info                  VarChar2(2000); 

Cursor Cur_Registros
Is
    Select Distinct
         Pcid,
         Lpad(trim(rut_persona),12,0)||'_'||trim(vivienda) as customer_id,
         Cpe,
         Row_Id
    From 
         Cut_Siebel_Tivo 
    Where Existecanaldac ='N' 
      and Existesiebel='S' 
    --  and TecnologiaIPTV='D'; 
      and TecnologiaIPTV in ('N','S');
      
Cursor Cur_Packages
Is      
      Select Distinct 
            Codigo_Canal 
      From Cuadra.Cut_Siebel_CanalesTivo_aux 
      Where Rut_Tivo= Cur_CustomerId_Tivo
           and Cpe = Cur_Cpe; 
            
Cursor Cur_Formato
Is 
select distinct datos from( 
select * from cut_formato_tivo_histo where to_char(fecha)=Trunc(Sysdate) 
order by estado asc);
--order by datos;
  /*select distinct a.datos  from cut_formato_tivo a
  inner join Cut_Siebel_Tivo b on b.pcid=a.customertivo and b.existecanaldac ='N' and b.existesiebel='S' and b.TecnologiaIPTV in ('S','N')
  Where rownum < 3500;*/ 
        
--
Begin
/*
  Begin
        Delete Cuadra.Cut_formato_Tivo;
        Commit;
        Exception When Others Then
            Rollback;
    End;
     Begin
        Delete From Cuadra.Cut_formato_Tivo_histo  Where Fecha = Trunc(Sysdate);
        Commit;
        Exception When Others Then
            Rollback;
    End;
  Begin
    Open Cur_Registros;
    Loop
     Fetch Cur_Registros
      Into Cur_CustomerId_Tivo, 
           Cur_Customer_Id,
           Cur_Cpe,
           Cur_Row_Id;
    Exit When Cur_Registros%NotFound;
    Begin
        Var_Estado          := Null;
        Var_Localidad       := Null;
        Var_CustomTag       := Null;
        Var_Canales         := Null;
        Var_EtiquetaCliente := Null;
        Var_cant :=0;

        --
        Begin
            Select X_Ocs_Codigo_Localidad,
                   Status_Cd
              Into Var_Localidad,
                   Var_Estado
              From Cuadra.Cut_Siebel_ProductoP
             Where Row_Id=Cur_Row_Id;
            If Sql%Found Then
                Null;
            End If;
            Exception When Others Then
                Var_Localidad := Null;
                Var_Estado    := Null;
        End;
        --
        Begin             
              Select Rec_Codigo
              Into Var_CustomTag
              From Cuadra.GIAP_TRADUCTOR
              Where Prd_Tag_Value=Var_Localidad
                And Pla_Codigo   = 'TIVO'
                And Trd_Tag_Name = 'CustomTag'
                And Rec_Codigo is not null; 
              If Sql%Found Then
                    Null;
              End If;
              Exception When Others Then
                  Var_CustomTag := Null;
        End;
        --
        Begin
            Select Distinct 
                 Etiqueta_cliente 
            Into Var_EtiquetaCliente
            From
               Sut_adrenalin_aux 
            Where Rut_Vivienda=Cur_Customer_Id
              and RowNum =1;
            If Sql%Found Then
                    Null;
            End If;
            Exception When Others Then
                  Var_EtiquetaCliente := Null;
        End;
        
        Begin
            Select count(1)
            Into Var_ExisteCustomerId
            From Cuadra.Cut_formato_Tivo
            Where customerid=Cur_Customer_Id;
            If Sql%Found Then
                Null;
            End If;
            Exception When Others Then
                Null;
        End;
        
        Begin
             Open Cur_Packages;
             Loop
             Fetch Cur_Packages
             Into Cur_Codi_Paquete;
              Exit When Cur_Packages%NotFound;
                Begin       
                        Var_Canales:=Var_Canales||';'||Cur_Codi_Paquete;                     
                End;
              End Loop;
              Close Cur_Packages;
         End;
        -------
         Var_EtiquetaCliente :=replace(Var_EtiquetaCliente,';','');
         Var_Datos := replace(Trim(Cur_Customer_Id)||','||Trim(Var_Canales)||','||Trim(Var_CustomTag)||','||'0'||','||'0'||','||Var_Estado,',;',',');
                 
        If Var_ExisteCustomerId=0 Then    
             Begin
                Insert Into Cuadra.Cut_formato_Tivo               
                ( CustomerID,
                  Packages,
                  CustomTag,
                  Npvr,
                  Credit_Vod,
                  Estado,
                  CustomerTivo,
                  Row_Id,
                  Localidad_Siebel,
                  CustomTag_Giap,
                  CustomTag_Adrenalin,
                  Datos)
                Values
                ( Cur_Customer_Id,
                  Var_Canales,
                  Var_CustomTag,
                  0,
                  0,
                  Var_Estado,
                  Cur_CustomerId_Tivo,
                  Cur_Row_Id,
                  Var_Localidad,
                  Var_CustomTag,
                  Var_EtiquetaCliente,
                  Var_Datos );
                If SQL%RowCount > 0 Then
                    Commit;
                Else
                    Rollback;
                End If;
                Exception When Others Then
                    Rollback;
             End;
          End If;
        Exception When Others Then
            Null;
    End;
    End Loop;
    Close Cur_Registros;
    Exception When Others Then
       Null;
  End;     

  Begin
    Insert into Cuadra.Cut_formato_Tivo_histo
    select distinct b.*,sysdate from(
    select distinct a.* from cut_formato_tivo a
    inner join Cut_Siebel_Tivo b on b.pcid=a.customertivo and b.existecanaldac ='N' and b.existesiebel='S' and b.TecnologiaIPTV='S'          
    where customerid not in (select distinct customerid from cut_formato_tivo_histo where to_char(fecha)=Trunc(Sysdate-1))
    and packages is not null
    Union
    select distinct a.* from cut_formato_tivo a
    inner join Cut_Siebel_Tivo b on b.pcid=a.customertivo and b.existecanaldac ='N' and b.existesiebel='S' and b.TecnologiaIPTV='N'          
    where pcid not in (select distinct a.customertivo from cut_formato_tivo a
    inner join Cut_Siebel_Tivo b on b.pcid=a.customertivo and b.existecanaldac ='N' and b.existesiebel='S' and b.TecnologiaIPTV='S')              
    and customerid not in (select distinct customerid from cut_formato_tivo_histo where to_char(fecha)=Trunc(Sysdate-1))
    and packages is not null


    and rownum < 3800) b
    order by datos; 
  commit;  
  End; 
*/  
--/*
  
  Begin
     VarArchivo :='ArchivoCorreccion.txt';
    l_file := UTL_FILE.FOPEN ('INFORME_ADRE',VarArchivo, 'w');
    UTL_FILE.PUT_LINE ( l_file ,'CUSTOMERID,PACKAGES,CUSTOMTAG,NPVR,CREDIT_VOD,ESTADO');

    Open Cur_Formato;
    Loop
    Fetch Cur_Formato
     Into Cur_Info;
    Exit When Cur_Formato%NotFound;
    Begin
        l_File_Name := Cur_Info;
        Utl_File.Put_Line(l_File,l_File_Name);
        Exception When Others Then
            Null;
    End;
    End Loop;
    Close Cur_Formato;
    Utl_File.fFlush(l_File);
    Utl_File.fClose(l_File);
  End;
 -- */   
End;