CREATE OR REPLACE PROCEDURE CUADRA.CUP_SIEBEL_PROCESA_ADRE AS 
Begin
   --
  Begin
        Delete Cuadra.Cut_Procesos_Log_Adre; 
        Commit;
        Exception When Others Then
            Rollback;
    End;

    --
    Begin
        CUP_SIEBEL_PLATADRENALIN;
        Exception When Others Then
            Null;
    End;
    --
    Begin
        CUP_SIEBEL_VALIDA_PROMOADRE;
        Exception When Others Then
            Null;
    End;
    
    
    Begin
        CUP_SIEBEL_ORDPEN_ADRE;
        Exception When Others Then
            Null;
    End;
    Begin
      Update Cuadra.Cut_Siebel_ResultdBox_1
      Set con_orden_pend=0
      Where con_orden_pend is null;
      commit;
    End;
    --
    Begin    
      Update  Cuadra.Cut_Siebel_ResultdBox_1 
      set cpe_distinretorno_siebuim = 1
      where cpe  in (SELECT cpe FROM Cuadra.Cut_Siebel_ResultdBox WHERE cpe_distinretorno_siebuim= 1);
      commit;
    End;
    --
    Begin 
      Update  Cuadra.Cut_Siebel_ResultdBox_1 
      set cpe_distinretorno_siebuim = 0
      where cpe  not in (SELECT cpe FROM Cuadra.Cut_Siebel_ResultdBox WHERE cpe_distinretorno_siebuim= 1);
      commit;
    End;
    --
    Begin 
      Update  Cuadra.Cut_Siebel_ResultdBox_1 
      set con_bi_pend = 1
      where cpe   in (SELECT cpe FROM Cuadra.Cut_Siebel_ResultdBox WHERE con_bi_pend = 1);
      commit;
    End;
    --
    Begin 
        Update  Cuadra.Cut_Siebel_ResultdBox_1 
        set con_bi_pend = 0
        where cpe not  in (Select cpe FROM Cuadra.Cut_Siebel_ResultdBox WHERE con_bi_pend = 1);
       commit;
    End;
    
END;