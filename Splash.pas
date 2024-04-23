unit Splash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, jpeg, ExtCtrls, Gauges, Buttons, acPNG,
  acProgressBar, sLabel, sGauge, sSkinProvider, URLMON, DB, IBCustomDataSet, IBDatabase, IBQuery,
  ShellAPI,ClipBrd, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.Comp.Client, FireDAC.Phys.IB, FireDAC.Phys.IBDef, FireDAC.DApt, FireDAC.VCLUI.Wait,
  ZipForge, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, IdURI,
  Data.FMTBcd, Data.DBXFirebird, Data.SqlExpr, IBX.IBSQL, System.IniFiles, IdFTP, IdFTPCommon,
  FireDAC.Comp.ScriptCommands, FireDAC.Stan.Util, FireDAC.Comp.Script,
  FireDAC.Phys.IBBase, FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL;

type
  TSplash_Screen = class(TForm)
    Image1: TImage;
    Label1: TsLabel;
    Gauge1: TsGauge;
    Image2: TImage;
    Image3: TImage;
    conexao: TFDConnection;
    archiver: TZipForge;
    IdHTTP1: TIdHTTP;
    IB_SQL: TIBSQL;
    FDScript: TFDScript;
    FDPFBDriverLink1: TFDPhysFBDriverLink;
    conexaoSQL: TFDConnection;
    FDPMSQLDriverLink1: TFDPhysMySQLDriverLink;
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Image3Click(Sender: TObject);
  private
    procedure ChecaVersao;
    procedure ChecaAtualizacao;
    function TabelaExiste(NomeTabela: string; BancoDados: TIBDataBase): Boolean;
    function ColunaExiste(NomeTabela:string; NomeColuna:string; BancoDados: TIBDataBase): Boolean;
    function ConstraintExiste(NomeConstraint: String; BancoDados: TIBDataBase): Boolean;
    function GeneratorExiste(NomeGenerator: String; BancoDados: TIBDataBase): Boolean;
    function ViewsExiste(NomeView: string; BancoDados: TIBDataBase): Boolean;
    function TriggersExiste(NomeTrigger: string; BancoDados: TIBDataBase): Boolean;
    function ProceduresExiste(NomeProcedure: String; BancoDados: TIBDataBase) : Boolean;
    function IndicesExiste(NomeTabela:string; NomeIndice:string; BancoDados: TIBDataBase): Boolean;
    function GetURLAsString(const aURL: string): string;
    function Somente_Numeros(svalor : String) : String;
    procedure CriandoTabelas;
    procedure CriandoColunas;
    procedure CriandoView;
    procedure CriandoTrigger;
    procedure CriandoProcedure;
    procedure CriandoIndice;
    procedure CriandoConstraint;
    procedure CriandoGenerator;
    procedure CriandoScripts;
    procedure ExecuteSQL(SQL: string; BancoDados: TIBDataBase); overload;
    procedure ForceCommit;
    { Private declarations }
  public
    { Public declarations }
    SQL, NomeTabela, NomeColuna, Coluna, NomeView,
    NomeTrigger, NomeProcedure, NomeIndice,
    NomeConstraint, NomeGenerator, VersaoBD : String;
    bAtualiza : Boolean;
    versao, sForca, sLibera, sStatus : String;
  end;

var
  Splash_Screen: TSplash_Screen;

implementation

uses Arquivos, SgSenAx;

{$R *.dfm}

procedure TSplash_Screen.ChecaAtualizacao;
var
  FTP: TIdFTP;
  FTPHost: string;
  FTPUsername: string;
  FTPPassword: string;
  RemoteFile: string;
  LocalFile : string;
  VersaoAtual, link : String;
  sLista : String;
  Query : TFDQuery;
  codNet, codMat, codSg : String;
  sCaminhoBD, sServidor : String;
begin
  {$REGION 'VERIFICA SE VAI ATUALIZAR OU NÃO O BANCO DE DADOS'}
  link := '';
  dm.IBDS_Parametros.Close;
  dm.IBDS_Parametros.Open;

  link        := 'http://forca.bvxtecnologia.com.br/forca_atualizacao.php?query=versao';
  link        := TIdURI.URLEncode(link);
  VersaoAtual := GetURLAsString(link);

  VersaoBD := Dm.IBDS_Parametros.FieldByName('VERSAO_BD').AsString;
  if (VersaoBD <> VersaoAtual) or (sForca = 'S') then
     bAtualiza := True;

  if bAtualiza then
     begin
        FTP := TIdFTP.Create(nil);
        try
           Application.ProcessMessages;

           sCaminhoBD := Dm.IBD_SgMat.DatabaseName;
           if copy(sCaminhoBD,2,1) = ':' then
              sServidor := 'localhost'
           else if copy(sCaminhoBD,1,3) = '200' then
           begin
              sCaminhoBD := copy(sCaminhoBD,17,sCaminhoBD.Length-1);
              sServidor  := '200.150.196.179';
           end
           else if copy(sCaminhoBD,1,9) = 'firebird2' then
           begin
              sCaminhoBD := copy(sCaminhoBD,32,sCaminhoBD.Length-1);
              sServidor  := 'firebird2.bvxtecnologia.com.br';
           end;

           Conexao.Params.Database := sCaminhoBD;
           Conexao.Params.UserName := Dm.IBD_SgMat.Params.Values['user_name'];
           Conexao.Params.Password := Dm.IBD_SgMat.Params.Values['password'];
           Conexao.Params.Add('Port=3050');
           Conexao.Params.Add('Server='+sServidor);
           Conexao.Connected       := True;
           conexaoSQL.Connected    := True;
           Query                   := TFDQuery.Create(nil);
           Query.Connection        := conexaoSQL;

           FTPHost      := 'ftp.bvxtecnologia.com.br'; // Substitua com o seu servidor FTP
           FTPUsername  := 'atualizador@bvxtecnologia.com.br'; // Substitua com o seu nome de usuário
           FTPPassword  := 'UgO!r@eO=Je2'; // Substitua com a sua senha
           FTP.Host     := FTPHost;
           FTP.Username := FTPUsername;
           FTP.Password := FTPPassword;

           FTP.Connect;
           FTP.TransferType := ftBinary;

           if not Dm.IBDS_Parametros.FieldByName('VERSAO_SGNET').AsString.Contains('.') then
             codSg := Dm.IBDS_Parametros.FieldByName('VERSAO_SGNET').AsString
           else
             codSg := '1';

           with Query, SQL do
             begin
               Close;
               Clear;
               Add('select * from tbVerAtualizacao where codigo > :cod');
               ParamByName('COD').AsString := codSg;
               Open;
             end;

           if Query.RecordCount > 0 then
           while not Query.Eof do
             begin
               codNet := Query.FieldByName('CODIGO').AsString;
               codMat := Query.FieldByName('VERSAO').AsString;
               if Query.FieldByName('SCRIPT').AsString = '' then Query.Next;

               Application.ProcessMessages;
               RemoteFile := Query.FieldByName('script').AsString; // Substitua com o caminho do arquivo remoto
               LocalFile  := 'C:\bvx\'+Query.FieldByName('script').AsString; // Substitua com o caminho onde você deseja salvar o arquivo localmente
               FTP.Get(RemoteFile, LocalFile, True, False); // Faz o download do arquivo
               with FDScript do
                 begin
                   SQLScriptFileName := LocalFile;
                   ValidateAll;
                   ExecuteAll;
                 end;
               Query.Next;
             end;
        except on E: Exception do

        end;
        Conexao.Connected    := False;
        conexaoSQL.Connected := False;
        FreeAndNil(Query);
        FTP.Disconnect;

        with Dm.IBQ_Pesquisa, SQL do
           begin
              Close;
              Clear;
              Add('update parametros set versao_bd = '''+VersaoAtual+''', versao_sgnet = :net, versao_sgmat = :mat');
              ParamByName('net').AsString := codNet;
              ParamByName('mat').AsString := codMat;
              ExecSQL;
           end;

        ForceCommit;
     end;

  {$ENDREGION}
end;

procedure TSplash_Screen.ChecaVersao;
var
    sDataHora1,
    sDataHora2,
    sInicio    : String;
    var_atualizacao, link : String;
    F : File of Byte;
    MyFile: TFileStream;
    iTamanho : Integer;
    Informa  : PChar;
    Tam      : UINT;
    wTamanho : DWord;
    inova, iatual : Integer;
    Valor, Lingua : Pointer;
    Arq, Versao1 : String;
    ini : TIniFile;
    FTP: TIdFTP;
    FTPHost: string;
    FTPUsername: string;
    FTPPassword: string;
    RemoteFile: string;
    LocalFile: string;
begin
  {$REGION 'CHECA ATUALIZAÇÃO DO EXE'}
  if (DayOfWeek(Date) in [2,3,4,5]) or (sForca = 'S') then
    begin
       // Verifica se está na mesma versão do 'SERVIDOR DO EXE'
       if not Dm.bServidor then
          try
             if Dm.IBDS_Parametros.FieldByName('CAMINHO_EXE').AsString <> '' then
                begin
                   // Faz a verificação de acordo com a data de modificação dos dois EXE,
                   // Se for diferente, atualiza o EXE do terminal.
                   sDataHora1 := DateTimeToStr(FileDateToDateTime(FileAge('C:\bvx\sgmat\sgmat.exe')));
                   sDataHora2 := DateTimeToStr(FileDateToDateTime(FileAge(Dm.IBDS_Parametros.FieldByName('CAMINHO_EXE').AsString)));
                   if sDataHora1 <> sDataHora2 then
                      begin
                         ShowMessage('Sistema será atualizado e reiniciado!');
                         if FileExists('C:\bvx\sgmat\sgmat2.exe') then DeleteFile('C:\bvx\sgmat\sgmat2.exe');
                         RenameFile('C:\bvx\sgmat\sgmat.exe','C:\bvx\sgmat\sgmat2.exe');
                         CopyFile(PChar(Dm.IBDS_Parametros.FieldByName('CAMINHO_EXE').AsString),PChar('C:\bvx\sgmat\sgmat.exe'), True);
                         ShellExecute(handle,'open','C:\bvx\sgmat\sgmat.exe',nil,nil,SW_ShowNormal);
                         Application.Terminate;
                      end;
                end;
          except
          end
       else
         //Tenta Baixar o Executável atualizado (No servidor).
         try
            link := 'http://forca.bvxtecnologia.com.br/forca_atualizacao.php?query=versaoexe';//'http://verifica.bvxtecnologia.com.br/verifica_atualizacao.php?cnpj='+Somente_Numeros(Dm.IBDS_Empresa.FieldByName('CNPJ').AsString)+'&versao='+versao+'';
            link := TIdURI.URLEncode(link);
            var_atualizacao := GetURLAsString(link);
            Versao1 := Dm.IBDS_Parametros.FieldByName('VERSAO_SGMAT').AsString;

            if ((sLibera = 'S') and (Versao1 <> var_atualizacao)) or (sForca = 'S') then
              begin
                 if Application.MessageBox('Uma nova versão do SgMat está disponível para download. Deseja atualizar agora?', 'Atualização disponível', 4) = mrYes then
                   begin
                      if FileExists('C:\bvx\SgMat\SgMat2.exe') then DeleteFile('C:\bvx\SgMat\SgMat2.exe');
                      if FileExists('C:\bvx\SgMat\SgMat.zip')  then DeleteFile('C:\bvx\SgMat\SgMat.zip');
                      if FileExists('C:\bvx\SgMat\SgMat.exe')  then RenameFile('C:\bvx\SgMat\SgMat.exe','C:\bvx\SgMat\SgMat2.exe');
                      // Fazendo download do arquivo via FTP e setando variáveis
                      FTP         := TIdFTP.Create(nil);
                      FTPHost     := 'ftp.bvxtecnologia.com.br'; // Substitua com o seu servidor FTP
                      FTPUsername := 'atualizador@bvxtecnologia.com.br'; // Substitua com o seu nome de usuário
                      FTPPassword := 'UgO!r@eO=Je2'; // Substitua com a sua senha
                      RemoteFile  := 'SgMat.zip'; // Substitua com o caminho do arquivo remoto
                      LocalFile   := 'C:\bvx\sgmat\SgMat.zip'; // Substitua com o caminho onde você deseja salvar o arquivo localmente

                      // Método novo
                      try
                         FTP.Host     := FTPHost;
                         FTP.Username := FTPUsername;
                         FTP.Password := FTPPassword;

                         FTP.Connect;
                         FTP.TransferType := ftBinary;
                         FTP.Get(RemoteFile, LocalFile, True, False); // Faz o download do arquivo
                      except on E: Exception do
                         ShowMessage('Erro: ' + E.Message);
                      end;
                      FTP.Disconnect;
                      FreeAndNil(FTP);

                      // Fazendo backup e descompactação do arquivo
                      if FileExists('C:\bvx\sgmat\SgMat.zip') then
                        begin
                           AssignFile(F, 'C:\bvx\sgmat\SgMat.zip');
                           Reset(F);
                           iTamanho := FileSize(F);
                           if (iTamanho >= 22436877) then
                             begin
                                CloseFile(F);
                                // Descompactando
                                try
                                   with archiver do
                                     begin
                                        FileName := 'C:\bvx\sgmat\SgMat.zip';
                                        OpenArchive(fmOpenRead);
                                        BaseDir := 'C:\bvx\sgmat';
                                        ExtractFiles('SgMat.exe');
                                        CloseArchive();
                                     end;
                                except
                                  on E: Exception do
                                    begin
                                       Writeln('Exception: ', E.Message);
                                       Readln;
                                    end;
                                end;

                                try
                                   //Muda STATUS do Versao.ini para Atualizando e reinicia o sistema...
                                   arq     := 'C:/bvx/Versao.ini';
                                   ini     := TIniFile.Create(arq);
                                   ini.WriteString('ATUALIZA', 'STATUS', 'ATUALIZANDO');

                                   //Atualiza versao_sgmat
                                   with Dm.IBQ_Pesquisa, SQL do
                                     begin
                                        Close;
                                        Clear;
                                        Add('update parametros set versao_sgmat = :atualiza');
                                        ParamByName('ATUALIZA').AsString := var_atualizacao;
                                        ExecSQL;
                                     end;

                                   Dm.IBT_SgMat.CommitRetaining;

                                   ShellExecute(handle,'open','C:\bvx\SGMAT\SgMat.exe',nil,nil,SW_ShowNormal);
                                   Application.Terminate;
                                except on E: Exception do
                                   ShowMessage(E.Message);
                                end;
                             end
                           else
                             begin
                                ShowMessage('Não foi possível concluir a atualização do sistema. Tente novamente!');
                                Close;
                             end;
                        end
                      else
                        begin
                           ShowMessage('Arquivo não obteve êxito ao baixar. Tente novamente!');
                           Close;
                        end;
                   end;
              end;
         except
         end;
    end;
  {$ENDREGION}
end;

function TSplash_Screen.ColunaExiste(NomeTabela, NomeColuna: string;
  BancoDados: TIBDataBase): Boolean;
var
  Query:TIBQuery;
begin
  {$REGION 'Verifica se Coluna Existe'}
  Result := False;
  Query := TIBQuery.Create(nil);
  try
    try
      Query.DataBase := BancoDados;
      Query.SQL.Clear;
      Query.SQL.Add('select * from ' + NomeTabela + ' where 1=-1');
      Query.Open;
      if Query.FindField(NomeColuna) <> nil then
        begin
          Result := True;
        end;
    except
    end;
    Query.Close;
  finally
    Query.Free;
  end;
  {$ENDREGION}
end;

procedure TSplash_Screen.CriandoColunas;
begin
  {$REGION 'Verifica e Cria as Colunas que não existirem no Banco de dados'}

  {$REGION 'COLUNAS CAIXA_OUTROS'}
  NomeTabela := 'CAIXA_OUTROS';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'VLR_PIX';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' NUMERIC(15,2);';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS CARTAO'}
  NomeTabela := 'CARTAO';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'FLG_ES';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' char(1) not null;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  {########################################################################}

   NomeColuna := 'DIA_FECHA';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' integer not null;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  {########################################################################}

   NomeColuna := 'DIA_VENCE';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' integer not null;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS CLIENTE'}
  NomeTabela := 'CLIENTE';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'FLG_COMISSAO';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' char(1) default ''S'' not null;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  {########################################################################}

   NomeColuna := 'PORC_DESC';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' numeric(15,2) default 0 not null;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS CONTABILISTA'}
  NomeTabela := 'CONTABILISTA';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'COD_EMPRESA';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' integer not null;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  {########################################################################}

   NomeColuna := 'FLG_ATIVO';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' char(1);';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS EMPRESA'}
  NomeTabela := 'EMPRESA';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'FLG_ATIVO';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' CHAR(1) DEFAULT ''S'' NOT NULL;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS END_CLI'}
  NomeTabela := 'END_CLI';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'NRO_END';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' VARCHAR(30);';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS MIT_PRODUCAO'}
  NomeTabela := 'MIT_PRODUCAO';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'NOME_FOR';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' varchar(60);';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  {########################################################################}

   NomeColuna := 'COD_LOTE';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' INTEGER;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS MOV_CARTAO'}
  NomeTabela := 'MOV_CARTAO';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'CODPAG';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' INTEGER;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  {########################################################################}

   NomeColuna := 'ORDPAG';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' INTEGER;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS MOVIT'}
  NomeTabela := 'MOVIT';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'OBS_ADICIONAL';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' BLOB SUB_TYPE 1 SEGMENT SIZE 4096;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS MOVTO'}
  NomeTabela := 'MOVTO';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'VLR_PIX';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' NUMERIC(15,2);';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  {########################################################################}

   NomeColuna := 'NFE_DADOS';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' BLOB SUB_TYPE 1 SEGMENT SIZE 4096;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  {########################################################################}

   NomeColuna := 'FLG_EXC';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' CHAR(1);';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS MOVTO_OS'}
  NomeTabela := 'MOVTO_OS';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'COD_STATUS';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' INTEGER;';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$REGION 'COLUNAS MOVIT_EXP'}
  NomeTabela := 'MOVIT_EXP';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
   NomeColuna := 'STATUS';
    if not ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Criando Colunas...  COLUNA: '+NomeColuna;
      SQL :='ALTER TABLE '+NomeTabela+' ADD '+NomeColuna+' varchar(20);';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;
  end;
  {$ENDREGION}

  {$ENDREGION}
end;

procedure TSplash_Screen.CriandoConstraint;
begin

  {$REGION 'PRIMARY KEYS'}

  {$REGION 'CONSTRAINTS MIT_CONSUMO'}
  NomeTabela := 'MIT_CONSUMO';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    NomeColuna := 'CODIGO';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeConstraint := 'PK_MIT_CONSUMO';
      if not ConstraintExiste(NomeConstraint, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Chaves...  CHAVE: '+NomeConstraint;
        SQL := 'ALTER TABLE '+NomeTabela+' ADD CONSTRAINT '+NomeConstraint+#13;
        SQL := SQL + 'PRIMARY KEY ('+NomeColuna+')';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'CONSTRAINTS STATUS_OS'}
  NomeTabela := 'STATUS_OS';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    NomeColuna := 'CODIGO';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeConstraint := 'PK_STATUS_OS';
      if not ConstraintExiste(NomeConstraint, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Chaves...  CHAVE: '+NomeConstraint+#13;
        SQL := 'ALTER TABLE '+NomeTabela+' ADD CONSTRAINT '+NomeConstraint+#13;
        SQL := SQL + 'PRIMARY KEY ('+NomeColuna+')';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;
  end;
  {$ENDREGION}

  {$ENDREGION}

  {$REGION 'FOREIGN KEYS'}

  {$REGION 'CONSTRAINTS CONTABILISTA'}
  NomeTabela := 'CONTABILISTA';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    NomeColuna := 'COD_EMPRESA';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeConstraint := 'fk_COD_EMPRESA';
      if not ConstraintExiste(NomeConstraint, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Chaves...  CHAVE: '+NomeConstraint;
        SQL := 'ALTER TABLE '+NomeTabela+' ADD CONSTRAINT '+NomeConstraint+#13;
        SQL := SQL + 'FOREIGN KEY ('+NomeColuna+') REFERENCES EMPRESA(CODIGO)';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'CONSTRAINTS MIT_CONSUMO'}
  NomeTabela := 'MIT_CONSUMO';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    NomeColuna := 'COD_PROD';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeConstraint := 'FK_MIT_CONSUMO_1';
      if not ConstraintExiste(NomeConstraint, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Chaves...  CHAVE: '+NomeConstraint;
        SQL := 'ALTER TABLE '+NomeTabela+' ADD CONSTRAINT '+NomeConstraint+#13;
        SQL := SQL + 'FOREIGN KEY ('+NomeColuna+') REFERENCES PRODUTO(CODIGO)'+#13;
        SQL := SQL + 'ON DELETE CASCADE';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;

    {############################################################################}

    NomeColuna := 'COD_FOR';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeConstraint := 'FK_MIT_CONSUMO_2';
      if not ConstraintExiste(NomeConstraint, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Chaves...  CHAVE: '+NomeConstraint+#13;
        SQL := 'ALTER TABLE '+NomeTabela+' ADD CONSTRAINT '+NomeConstraint+#13;
        SQL := SQL + 'FOREIGN KEY ('+NomeColuna+') REFERENCES FORNECEDOR(CODIGO)'+#13;
        SQL := SQL + 'ON DELETE CASCADE';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;

    {############################################################################}

    NomeColuna := 'COD_FUNC';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeConstraint := 'FK_MIT_CONSUMO_3';
      if not ConstraintExiste(NomeConstraint, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Chaves...  CHAVE: '+NomeConstraint+#13;
        SQL := 'ALTER TABLE '+NomeTabela+' ADD CONSTRAINT '+NomeConstraint+#13;
        SQL := SQL + 'FOREIGN KEY ('+NomeColuna+') REFERENCES FUNCIONARIO(CODIGO)'+#13;
        SQL := SQL + 'ON DELETE CASCADE';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;

  end;
  {$ENDREGION}

  {$REGION 'CONSTRAINTS MIT_PRODUCAO'}
  NomeTabela := 'MIT_PRODUCAO';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    NomeColuna := 'COD_LOTE';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeConstraint := 'MIT_PRODUCAO';
      if not ConstraintExiste(NomeConstraint, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Chaves...  CHAVE: '+NomeConstraint+#13;
        SQL := 'ALTER TABLE '+NomeTabela+' ADD CONSTRAINT '+NomeConstraint+#13;
        SQL := SQL + 'FOREIGN KEY ('+NomeColuna+') REFERENCES PROD_LOTE(CODIGO)'+#13;
        SQL := SQL + 'ON DELETE CASCADE';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;
  end;
  {$ENDREGION}

  {$REGION 'CONSTRAINTS MOVTO_OS'}
  NomeTabela := 'MOVTO_OS';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    NomeColuna := 'COD_STATUS';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeConstraint := 'FK_COD_STATUS';
      if not ConstraintExiste(NomeConstraint, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Chaves...  CHAVE: '+NomeConstraint+#13;
        SQL := 'ALTER TABLE '+NomeTabela+' ADD CONSTRAINT '+NomeConstraint+#13;
        SQL := SQL + 'FOREIGN KEY ('+NomeColuna+') REFERENCES STATUS_OS (CODIGO)'+#13;
        SQL := SQL + 'ON DELETE CASCADE';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;
  end;
  {$ENDREGION}

  {$ENDREGION}

end;

procedure TSplash_Screen.CriandoGenerator;
begin
  {$REGION 'GENERATOR LOG'}
  NomeGenerator := 'GEN_LOG';
  if not GeneratorExiste(NomeGenerator, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Geradores...  GERADOR: '+NomeGenerator;
    SQL := 'CREATE SEQUENCE '+NomeGenerator;
    ExecuteSQL(SQL, Dm.IBD_SgMat);

    Label1.Caption := 'Executando bloco de gerador...  GERADOR: '+NomeGenerator;
    SQL := 'EXECUTE BLOCK AS';
    SQL := SQL + 'DECLARE VARIABLE X INTEGER;';
    SQL := SQL + 'BEGIN';
    SQL := SQL + 'SELECT MAX(CODIGO) FROM LOG INTO X;';
    SQL := SQL + 'EXECUTE STATEMENT ''SET GENERATOR'+NomeGenerator+'TO'+' || X;';
    ExecuteSQL(SQL, Dm.IBD_SgMat);

    if TriggersExiste('TRG_LOG', Dm.IBD_SgMat) then
    begin
      Label1.Caption := 'Apagando dependências antigas...';
      SQL := 'DROP TRIGGER TRG_LOG';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    end;

  end;
  {$ENDREGION}
end;

procedure TSplash_Screen.CriandoIndice;
begin
  {$REGION 'ÍNDICE MOVTO'}
  NomeTabela := 'MOVTO';
  if TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    NomeColuna := 'CODIGO';
    if ColunaExiste(NomeTabela, NomeColuna, Dm.IBD_SgMat) then
    begin
      NomeIndice := 'MOVTO_IDX6';
      if not IndicesExiste(NomeTabela, NomeIndice, Dm.IBD_SgMat) then
      begin
        Label1.Caption := 'Criando Índices...  INDICE: '+NomeIndice;
        SQL := 'CREATE DESCENDING INDEX '+NomeIndice;
        SQL := SQL + 'ON '+NomeTabela+ ' (' + NomeColuna + ')';
        ExecuteSQL(SQL, Dm.IBD_SgMat);
      end;
    end;
  end;
  {$ENDREGION}
end;

procedure TSplash_Screen.CriandoProcedure;
begin
  {$REGION 'Verifica e cria as Procedures que não existirem no Banco de dados'}

  {$REGION 'PROCEDURE CAIXA_OUTROS'}
  NomeProcedure:='P_CAIXA_OUTROS';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_CAIXA_OUTROS (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('FLG_E_S char(1),');
        Add('DATA date,');
        Add('DESCRICAO varchar(60),');
        Add('VALOR numeric(15,2),');
        Add('COD_CAIXA integer,');
        Add('COD_FUNC integer,');
        Add('COD_DESP integer,');
        Add('VLR_DINH numeric(15,2),');
        Add('VLR_CHVISTA numeric(15,2),');
        Add('VLR_CHPRE numeric(15,2),');
        Add('DT_COMISSAO date,');
        Add('VLR_CARTAO numeric(15,2),');
        Add('VLR_PIX numeric(15,2))');
        Add('as');
        Add('begin');
        Add('if (operacao = 1) then');
        Add('insert into caixa_outros (codigo,flg_e_s,data,descricao,valor,cod_caixa,cod_func,cod_desp,vlr_dinh,vlr_chvista,vlr_chpre,dt_comissao,vlr_cartao,vlr_pix)');
        Add('values (:codigo,:flg_e_s,:data,:descricao,:valor,:cod_caixa,:cod_func,:cod_desp,:vlr_dinh,:vlr_chvista,:vlr_chpre,:dt_comissao,:vlr_cartao,:vlr_pix);');
        Add('if (operacao = 2) then');
        Add('update caixa_outros set');
        Add('flg_e_s = :flg_e_s,');
        Add('data = :data,');
        Add('descricao = :descricao,');
        Add('valor = :valor,');
        Add('cod_caixa = :cod_caixa,');
        Add('cod_func = :cod_func,');
        Add('cod_desp = :cod_desp,');
        Add('vlr_dinh = :vlr_dinh,');
        Add('vlr_chvista = :vlr_chvista,');
        Add('vlr_chpre = :vlr_chpre,');
        Add('dt_comissao = :dt_comissao,');
        Add('vlr_cartao = :vlr_cartao,');
        Add('vlr_pix = :vlr_pix');
        Add('where (codigo = :codigo);');
        Add('if (operacao = 3) then');
        Add('delete from caixa_outros');
        Add('where (codigo = :codigo);');
        Add('suspend;');
        Add('end;');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE CARTAO'}
  NomeProcedure:='P_CARTAO';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_CARTAO (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('NOME varchar(60),');
        Add('TAXA numeric(15,2),');
        Add('PRAZO integer,');
        Add('ANTECIPA numeric(15,2),');
        Add('FLG_ATIVADO char(1),');
        Add('FLG_ES char(1),');
        Add('DIA_FECHA integer,');
        Add('DIA_VENCE integer)');
        Add('as');
        Add('begin');

        Add('if (operacao = 1) then');
        Add('insert into CARTAO (CODIGO,NOME,TAXA,PRAZO,ANTECIPA,FLG_ATIVADO,FLG_ES,DIA_FECHA,DIA_VENCE)');
        Add('values (:CODIGO,:NOME,:TAXA,:PRAZO,:ANTECIPA,:FLG_ATIVADO,:FLG_ES,:DIA_FECHA,:DIA_VENCE);');

        Add('if (operacao = 2) then');
        Add('update CARTAO set');
        Add('NOME = :NOME,');
        Add('TAXA = :TAXA,');
        Add('PRAZO = :PRAZO,');
        Add('ANTECIPA = :ANTECIPA,');
        Add('FLG_ATIVADO = :FLG_ATIVADO,');
        Add('FLG_ES = :FLG_ES,');
        Add('DIA_FECHA = :DIA_FECHA,');
        Add('DIA_VENCE = :DIA_VENCE');
        Add('where (CODIGO = :CODIGO);');

        Add('if (operacao = 3) then');
        Add('delete from CARTAO');
        Add('where (CODIGO = :CODIGO);');
        Add('suspend;');
        Add('end');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE CLIENTE'}
  NomeProcedure:='P_CLIENTE';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...  PROCEDURE: '+NomeProcedure;
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_CLIENTE (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('NOME varchar(60),');
        Add('FANTASIA varchar(60),');
        Add('COD_END integer,');
        Add('FONE varchar(20),');
        Add('FAX varchar(20),');
        Add('CELULAR varchar(20),');
        Add('CX_POSTAL varchar(10),');
        Add('E_MAIL varchar(60),');
        Add('CONTATO varchar(20),');
        Add('TIPO_PESSOA char(1),');
        Add('CNPJ_CPF varchar(20),');
        Add('IE_RG varchar(20),');
        Add('DT_CADASTRO date,');
        Add('DT_INATIVO date,');
        Add('DT_NASC date,');
        Add('DT_BLOQUEIO date,');
        Add('FLG_BLOQUEIO varchar(20),');
        Add('OBS_BLOQUEIO varchar(200),');
        Add('OBSERVACAO1 varchar(100),');
        Add('OBSERVACAO2 varchar(100),');
        Add('RESP_NOME varchar(60),');
        Add('RESP_BAIRRO varchar(60),');
        Add('RESP_ENDERECO varchar(60),');
        Add('RESP_CODCID integer,');
        Add('RESP_CEP varchar(10),');
        Add('RESP_FONE varchar(20),');
        Add('RESP_RG varchar(20),');
        Add('RESP_CPF varchar(20),');
        Add('RESP_DTNASC date,');
        Add('RESP_OBSERV varchar(100),');
        Add('PROFISSAO varchar(60),');
        Add('LIMITE numeric(15,2),');
        Add('OBS_COBRANCA varchar(200),');
        Add('FLG_RECEBER char(1),');
        Add('COD_EMPRESA integer,');
        Add('FLG_LIGAR char(1),');
        Add('COD_FUNC integer,');
        Add('FOTO varchar(200),');
        Add('FLG_FECHAMENTO integer,');
        Add('DIAS_PAGTO integer,');
        Add('FLG_CLASSIFICA char(1),');
        Add('TIPO_FECHAMENTO char(1),');
        Add('FLG_JUROS char(1),');
        Add('E_MAIL_NFE varchar(60),');
        Add('DATA_COBRANCA date,');
        Add('DATA_VISITA date,');
        Add('COD_CONVENIO integer,');
        Add('SENHA varchar(20),');
        Add('COD_REGIAO integer,');
        Add('FLG_PRAZO varchar(1),');
        Add('FLG_NFP char(1),');
        Add('SITE_SYNC char(1),');
        Add('SITE_COD integer,');
        Add('OBS_ADICIONAL varchar(9999),');
        Add('FLG_COMISSAO char(1),');
        Add('PORC_DESC numeric(15,2))');
        Add('as');
        Add('begin');

        Add('if (operacao = 1) then');
        Add('insert into CLIENTE (CODIGO,NOME,FANTASIA,COD_END,FONE,FAX,CELULAR,CX_POSTAL,E_MAIL,CONTATO,TIPO_PESSOA,CNPJ_CPF,IE_RG,DT_CADASTRO,');
        Add('DT_INATIVO,DT_NASC,DT_BLOQUEIO,FLG_BLOQUEIO,OBS_BLOQUEIO,OBSERVACAO1,OBSERVACAO2,RESP_NOME,RESP_BAIRRO,RESP_ENDERECO,RESP_CODCID,RESP_CEP,RESP_FONE,RESP_RG,RESP_CPF,');
        Add('RESP_DTNASC,RESP_OBSERV,PROFISSAO,LIMITE,OBS_COBRANCA,FLG_RECEBER,COD_EMPRESA,FLG_LIGAR,COD_FUNC,FOTO,FLG_FECHAMENTO,DIAS_PAGTO,FLG_CLASSIFICA,TIPO_FECHAMENTO,FLG_JUROS,E_MAIL_NFE,');
        Add('DATA_COBRANCA,DATA_VISITA,COD_CONVENIO,SENHA,COD_REGIAO,FLG_PRAZO,FLG_NFP,SITE_SYNC,SITE_COD,OBS_ADICIONAL,FLG_COMISSAO,PORC_DESC)');
        Add('values (:CODIGO,:NOME,:FANTASIA,:COD_END,:FONE,:FAX,:CELULAR,:CX_POSTAL,:E_MAIL,:CONTATO,:TIPO_PESSOA,:CNPJ_CPF,:IE_RG,:DT_CADASTRO,:DT_INATIVO,:DT_NASC,:DT_BLOQUEIO,');
        Add(':FLG_BLOQUEIO,:OBS_BLOQUEIO,:OBSERVACAO1,:OBSERVACAO2,:RESP_NOME,:RESP_BAIRRO,:RESP_ENDERECO,:RESP_CODCID,:RESP_CEP,:RESP_FONE,:RESP_RG,:RESP_CPF,:RESP_DTNASC,');
        Add(':RESP_OBSERV,:PROFISSAO,:LIMITE,:OBS_COBRANCA,:FLG_RECEBER,:COD_EMPRESA,:FLG_LIGAR,:COD_FUNC,:FOTO,:FLG_FECHAMENTO,:DIAS_PAGTO,:FLG_CLASSIFICA,:TIPO_FECHAMENTO,:FLG_JUROS,:E_MAIL_NFE,');
        Add(':DATA_COBRANCA,:DATA_VISITA,:COD_CONVENIO,:SENHA,:COD_REGIAO,:FLG_PRAZO,:FLG_NFP,:SITE_SYNC,:SITE_COD,:OBS_ADICIONAL,:FLG_COMISSAO,:PORC_DESC);');

        Add('if (operacao = 2) then');
        Add('update CLIENTE set');
        Add('NOME = :NOME,');
        Add('FANTASIA = :FANTASIA,');
        Add('COD_END = :COD_END,');
        Add('FONE = :FONE,');
        Add('FAX = :FAX,');
        Add('CELULAR = :CELULAR,');
        Add('CX_POSTAL = :CX_POSTAL,');
        Add('E_MAIL = :E_MAIL,');
        Add('CONTATO = :CONTATO,');
        Add('TIPO_PESSOA = :TIPO_PESSOA,');
        Add('CNPJ_CPF = :CNPJ_CPF,');
        Add('IE_RG = :IE_RG,');
        Add('DT_CADASTRO = :DT_CADASTRO,');
        Add('DT_INATIVO = :DT_INATIVO,');
        Add('DT_NASC = :DT_NASC,');
        Add('DT_BLOQUEIO = :DT_BLOQUEIO,');
        Add('FLG_BLOQUEIO = :FLG_BLOQUEIO,');
        Add('OBS_BLOQUEIO = :OBS_BLOQUEIO,');
        Add('OBSERVACAO1 = :OBSERVACAO1,');
        Add('OBSERVACAO2 = :OBSERVACAO2,');
        Add('RESP_NOME = :RESP_NOME,');
        Add('RESP_BAIRRO = :RESP_BAIRRO,');
        Add('RESP_ENDERECO = :RESP_ENDERECO,');
        Add('RESP_CODCID = :RESP_CODCID,');
        Add('RESP_CEP = :RESP_CEP,');
        Add('RESP_FONE = :RESP_FONE,');
        Add('RESP_RG = :RESP_RG,');
        Add('RESP_CPF = :RESP_CPF,');
        Add('RESP_DTNASC = :RESP_DTNASC,');
        Add('RESP_OBSERV = :RESP_OBSERV,');
        Add('PROFISSAO = :PROFISSAO,');
        Add('LIMITE = :LIMITE,');
        Add('OBS_COBRANCA = :OBS_COBRANCA,');
        Add('FLG_RECEBER = :FLG_RECEBER,');
        Add('COD_EMPRESA = :COD_EMPRESA,');
        Add('FLG_LIGAR = :FLG_LIGAR,');
        Add('COD_FUNC = :COD_FUNC,');
        Add('FOTO = :FOTO,');
        Add('FLG_FECHAMENTO =:FLG_FECHAMENTO,');
        Add('DIAS_PAGTO = :DIAS_PAGTO,');
        Add('FLG_CLASSIFICA = :FLG_CLASSIFICA,');
        Add('TIPO_FECHAMENTO = :TIPO_FECHAMENTO,');
        Add('FLG_JUROS = :FLG_JUROS,');
        Add('E_MAIL_NFE = :E_MAIL_NFE,');
        Add('DATA_COBRANCA = :DATA_COBRANCA,');
        Add('DATA_VISITA = :DATA_VISITA,');
        Add('COD_CONVENIO = :COD_CONVENIO,');
        Add('SENHA = :SENHA,');
        Add('COD_REGIAO = :COD_REGIAO,');
        Add('FLG_PRAZO = :FLG_PRAZO,');
        Add('FLG_NFP = :FLG_NFP,');
        Add('SITE_SYNC = :SITE_SYNC,');
        Add('SITE_COD  = :SITE_COD,');
        Add('OBS_ADICIONAL = :OBS_ADICIONAL,');
        Add('FLG_COMISSAO = :FLG_COMISSAO,');
        Add('PORC_DESC = :PORC_DESC');
        Add('where (CODIGO = :CODIGO);');

        Add('if (operacao = 3) then');
        Add('delete from CLIENTE');
        Add('where (CODIGO = :CODIGO);');

        Add('suspend;');
        Add('end;');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE CONTABILISTA'}
  NomeProcedure:='P_CONTABILISTA';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_CONTABILISTA (');
        Add('OPERACAO integer,	');
        Add('CODIGO integer,	');
        Add('NOME varchar(60),	');
        Add('CPF varchar(20),	');
        Add('CRC varchar(20),	');
        Add('CNPJ varchar(20),	');
        Add('ENDERECO varchar(60),	');
        Add('NRO_END integer,	');
        Add('BAIRRO varchar(60),	');
        Add('COD_CIDADE integer,	');
        Add('CEP varchar(10),	');
        Add('TELEFONE varchar(20),	');
        Add('CELULAR varchar(20),	');
        Add('E_MAIL varchar(60),	');
        Add('OBSERVACAO varchar(100),	');
        Add('E_MAIL2 varchar(60),	');
        Add('E_MAIL3 varchar(60),	');
        Add('E_MAIL4 varchar(60),	');
        Add('COD_EMPRESA integer,	');
        Add('FLG_ATIVO char(1))	');
        Add('as	');
        Add('begin	');
        Add('if (operacao = 1) then	');
        Add('insert into CONTABILISTA (CODIGO,NOME,CPF,CRC,CNPJ,ENDERECO,NRO_END,BAIRRO,COD_CIDADE,CEP,TELEFONE,CELULAR,E_MAIL,OBSERVACAO,E_MAIL2,E_MAIL3,E_MAIL4,COD_EMPRESA,FLG_ATIVO)	');
        Add('values (:CODIGO,:NOME,:CPF,:CRC,:CNPJ,:ENDERECO,:NRO_END,:BAIRRO,:COD_CIDADE,:CEP,:TELEFONE,:CELULAR,:E_MAIL,:OBSERVACAO,:E_MAIL2,:E_MAIL3,:E_MAIL4, :COD_EMPRESA, :FLG_ATIVO);	');

        Add('if (operacao = 2) then	');
        Add('update CONTABILISTA set	');
        Add('NOME = :NOME,	');
        Add('CPF = :CPF,	');
        Add('CRC = :CRC,	');
        Add('CNPJ = :CNPJ,	');
        Add('ENDERECO = :ENDERECO,	');
        Add('NRO_END = :NRO_END,	');
        Add('BAIRRO = :BAIRRO,	');
        Add('COD_CIDADE = :COD_CIDADE,	');
        Add('CEP = :CEP,	');
        Add('TELEFONE = :TELEFONE,	');
        Add('CELULAR = :CELULAR,	');
        Add('E_MAIL = :E_MAIL,	');
        Add('OBSERVACAO = :OBSERVACAO,	');
        Add('E_MAIL2 = :E_MAIL2,	');
        Add('E_MAIL3 = :E_MAIL3,	');
        Add('E_MAIL4 = :E_MAIL4,	');
        Add('COD_EMPRESA = :COD_EMPRESA,	');
        Add('FLG_ATIVO = :FLG_ATIVO	');
        Add('where (CODIGO = :CODIGO);	');

        Add('if (operacao = 3) then	');
        Add('delete from CONTABILISTA	');
        Add('where (CODIGO = :CODIGO);	');

        Add('suspend;	');
        Add('end	');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE EMPRESA'}
  NomeProcedure:='P_EMPRESA';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
//    SQL := 'Drop procedure '+NomeProcedure+';';
//    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_EMPRESA (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('RAZAO_SOCIAL varchar(60),');
        Add('FANTASIA varchar(60),');
        Add('ENDERECO varchar(60),');
        Add('BAIRRO varchar(60),');
        Add('COD_CID integer,');
        Add('CEP varchar(10),');
        Add('FONE varchar(20),');
        Add('FAX varchar(20),');
        Add('E_MAIL varchar(60),');
        Add('CONTATO varchar(20),');
        Add('CNPJ varchar(20),');
        Add('INSC_EST varchar(20),');
        Add('INSC_MUN varchar(20),');
        Add('COD_CLIENTE integer,');
        Add('COD_MOTORISTA integer,');
        Add('COD_TRIB_VENDA integer,');
        Add('COD_PRODUTO integer,');
        Add('COD_ENT_ESTOQ integer,');
        Add('COD_SAI_ESTOQ integer,');
        Add('NIVEL integer,');
        Add('FINANCEIRO char(1),');
        Add('ATUALIZA_PRECO char(1),');
        Add('FLG_JUROS char(1),');
        Add('PRAZO_JUROS integer,');
        Add('PORC_JUROS numeric(15,2),');
        Add('FLG_IMPRESSAO char(1),');
        Add('FLG_CAIXA char(1),');
        Add('SENHAX varchar(10),');
        Add('SENHAX2 varchar(10),');
        Add('COMISSAO_VEND numeric(15,3),');
        Add('COMISSAO_INSTAL numeric(15,3),');
        Add('FLG_BOLETO char(1),');
        Add('COD_PRODUTO2 integer,');
        Add('SENHAX3 varchar(10),');
        Add('FLG_NFE char(1),');
        Add('FLG_SIMPLES char(1),');
        Add('CNAE varchar(10),');
        Add('SMS_USUARIO varchar(20),');
        Add('SMS_SENHA varchar(20),');
        Add('CONSULTA_CODIGO varchar(10),');
        Add('CONSULTA_SENHA varchar(10),');
        Add('EMAIL_LOGIN varchar(50),');
        Add('EMAIL_SENHA varchar(30),');
        Add('EMAIL_SMTP varchar(30),');
        Add('EMAIL_PORTA varchar(5),');
        Add('EMAIL_SSL char(1),');
        Add('EMAIL_TLS char(1),');
        Add('FLG_FISCAL char(1),');
        Add('PORC_CHPRE numeric(15,2),');
        Add('OBSERV_PEDIDO varchar(60),');
        Add('PORC_MULTA numeric(15,2),');
        Add('FOTO_TELA blob sub_type 0 segment size 80,');
        Add('CREDITO_ICMS numeric(15,2),');
        Add('LOGOTIPO blob sub_type 0 segment size 80,');
        Add('FLG_ATIVO char(1))');
        Add('as');
        Add('begin');
        Add('if (operacao = 1) then');
        Add('insert into EMPRESA (CODIGO,RAZAO_SOCIAL,FANTASIA,ENDERECO,BAIRRO,COD_CID,CEP,FONE,FAX,E_MAIL,CONTATO,CNPJ,INSC_EST,INSC_MUN,COD_CLIENTE,COD_MOTORISTA,COD_TRIB_VENDA,COD_PRODUTO,');
        Add('COD_ENT_ESTOQ,COD_SAI_ESTOQ,NIVEL,FINANCEIRO,ATUALIZA_PRECO,FLG_JUROS,PRAZO_JUROS,PORC_JUROS,FLG_IMPRESSAO,FLG_CAIXA,SENHAX,SENHAX2,COMISSAO_VEND,COMISSAO_INSTAL,FLG_BOLETO,COD_PRODUTO2,');
        Add('SENHAX3,FLG_NFE,FLG_SIMPLES,CNAE,SMS_USUARIO,SMS_SENHA,CONSULTA_CODIGO,CONSULTA_SENHA,EMAIL_LOGIN,EMAIL_SENHA,EMAIL_SMTP,');
        Add('EMAIL_PORTA,EMAIL_SSL,EMAIL_TLS,FLG_FISCAL,PORC_CHPRE,OBSERV_PEDIDO,PORC_MULTA,FOTO_TELA,CREDITO_ICMS,LOGOTIPO,FLG_ATIVO)');
        Add('values (:CODIGO,:RAZAO_SOCIAL,:FANTASIA,:ENDERECO,:BAIRRO,:COD_CID,:CEP,:FONE,:FAX,:E_MAIL,:CONTATO,:CNPJ,:INSC_EST,:INSC_MUN,:COD_CLIENTE,:COD_MOTORISTA,:COD_TRIB_VENDA,:COD_PRODUTO,');
        Add(':COD_ENT_ESTOQ,:COD_SAI_ESTOQ,:NIVEL,:FINANCEIRO,:ATUALIZA_PRECO,:FLG_JUROS,:PRAZO_JUROS,:PORC_JUROS,:FLG_IMPRESSAO,:FLG_CAIXA,:SENHAX,:SENHAX2,:COMISSAO_VEND,:COMISSAO_INSTAL,:FLG_BOLETO,:COD_PRODUTO2,');
        Add(':SENHAX3,:FLG_NFE,:FLG_SIMPLES,:CNAE,:SMS_USUARIO,:SMS_SENHA,:CONSULTA_CODIGO,:CONSULTA_SENHA,:EMAIL_LOGIN,:EMAIL_SENHA,:EMAIL_SMTP,');
        Add(':EMAIL_PORTA,:EMAIL_SSL,:EMAIL_TLS,:FLG_FISCAL,:PORC_CHPRE,:OBSERV_PEDIDO,:PORC_MULTA,:FOTO_TELA,:CREDITO_ICMS,:LOGOTIPO,:FLG_ATIVO);');
        Add('if (operacao = 2) then');
        Add('update EMPRESA set');
        Add('RAZAO_SOCIAL = :RAZAO_SOCIAL,');
        Add('FANTASIA = :FANTASIA,');
        Add('ENDERECO = :ENDERECO,');
        Add('BAIRRO = :BAIRRO,');
        Add('COD_CID = :COD_CID,');
        Add('CEP = :CEP,');
        Add('FONE = :FONE,');
        Add('FAX = :FAX,');
        Add('E_MAIL = :E_MAIL,');
        Add('CONTATO = :CONTATO,');
        Add('CNPJ = :CNPJ,');
        Add('INSC_EST = :INSC_EST,');
        Add('INSC_MUN = :INSC_MUN,');
        Add('COD_CLIENTE = :COD_CLIENTE,');
        Add('COD_MOTORISTA = :COD_MOTORISTA,');
        Add('COD_TRIB_VENDA = :COD_TRIB_VENDA,');
        Add('COD_PRODUTO = :COD_PRODUTO,');
        Add('COD_ENT_ESTOQ = :COD_ENT_ESTOQ,');
        Add('COD_SAI_ESTOQ = :COD_SAI_ESTOQ,');
        Add('NIVEL = :NIVEL,');
        Add('FINANCEIRO = :FINANCEIRO,');
        Add('ATUALIZA_PRECO = :ATUALIZA_PRECO,');
        Add('FLG_JUROS = :FLG_JUROS,');
        Add('PRAZO_JUROS = :PRAZO_JUROS,');
        Add('PORC_JUROS = :PORC_JUROS,');
        Add('FLG_IMPRESSAO = :FLG_IMPRESSAO,');
        Add('FLG_CAIXA = :FLG_CAIXA,');
        Add('SENHAX = :SENHAX,');
        Add('SENHAX2 = :SENHAX2,');
        Add('COMISSAO_VEND = :COMISSAO_VEND,');
        Add('COMISSAO_INSTAL = :COMISSAO_INSTAL,');
        Add('FLG_BOLETO = :FLG_BOLETO,');
        Add('COD_PRODUTO2 = :COD_PRODUTO2,');
        Add('SENHAX3 = :SENHAX3,');
        Add('FLG_NFE = :FLG_NFE,');
        Add('FLG_SIMPLES = :FLG_SIMPLES,');
        Add('CNAE = :CNAE,');
        Add('SMS_USUARIO = :SMS_USUARIO,');
        Add('SMS_SENHA = :SMS_SENHA,');
        Add('CONSULTA_CODIGO = :CONSULTA_CODIGO,');
        Add('CONSULTA_SENHA = :CONSULTA_SENHA,');
        Add('EMAIL_LOGIN = :EMAIL_LOGIN,');
        Add('EMAIL_SENHA = :EMAIL_SENHA,');
        Add('EMAIL_SMTP = :EMAIL_SMTP,');
        Add('EMAIL_PORTA = :EMAIL_PORTA,');
        Add('EMAIL_SSL = :EMAIL_SSL,');
        Add('EMAIL_TLS = :EMAIL_TLS,');
        Add('FLG_FISCAL = :FLG_FISCAL,');
        Add('PORC_CHPRE = :PORC_CHPRE,');
        Add('OBSERV_PEDIDO = :OBSERV_PEDIDO,');
        Add('PORC_MULTA = :PORC_MULTA,');
        Add('FOTO_TELA = :FOTO_TELA,');
        Add('CREDITO_ICMS = :CREDITO_ICMS,');
        Add('LOGOTIPO = :LOGOTIPO,');
        Add('FLG_ATIVO = :FLG_ATIVO');
        Add('where (CODIGO = :CODIGO);');
        Add('if (operacao = 3) then');
        Add('delete from EMPRESA');
        Add('where (CODIGO = :CODIGO);');
        Add('suspend;');
        Add('end;');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE END_CLI'}
  NomeProcedure:='P_END_CLI';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_END_CLI (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('COD_CLI integer,');
        Add('ENDERECO varchar(60),');
        Add('BAIRRO varchar(60),');
        Add('CEP varchar(10),');
        Add('COD_CID integer,');
        Add('FLG_PADRAO char(1),');
        Add('OBSERVACAO varchar(100),');
        Add('NRO_END varchar(30))');
        Add('as');
        Add('begin');
        Add('if (operacao = 1) then');
        Add('insert into END_CLI (CODIGO, COD_CLI, ENDERECO, BAIRRO, CEP, COD_CID, FLG_PADRAO, OBSERVACAO, NRO_END)');
        Add('values (:CODIGO, :COD_CLI, :ENDERECO, :BAIRRO, :CEP, :COD_CID, :FLG_PADRAO, :OBSERVACAO, :NRO_END);');

        Add('if (operacao = 2) then');
        Add('update END_CLI set');
        Add('COD_CLI = :COD_CLI,');
        Add('ENDERECO = :ENDERECO,');
        Add('BAIRRO = :BAIRRO,');
        Add('CEP = :CEP,');
        Add('COD_CID = :COD_CID,');
        Add('FLG_PADRAO = :FLG_PADRAO,');
        Add('OBSERVACAO = :OBSERVACAO,');
        Add('NRO_END = :NRO_END');
        Add('where (CODIGO = :CODIGO);');

        Add('if (operacao = 3) then');
        Add('delete from END_CLI');
        Add('where (CODIGO = :CODIGO);');

        Add('suspend;');
        Add('end');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE MIT_CONSUMO'}
  NomeProcedure:='P_MIT_CONSUMO';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_MIT_CONSUMO (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('COD_PROD integer,');
        Add('COD_FOR integer,');
        Add('COD_FUNC integer,');
        Add('FLG_E_S char(1),');
        Add('DATA date,');
        Add('DOCUMENTO integer,');
        Add('QUANT numeric(15,3),');
        Add('VLR_UNIT numeric(15,3),');
        Add('VLR_TOTAL numeric(15,2),');
        Add('OBSERVACAO varchar(100))');
        Add('as');
        Add('begin');
        Add('if (operacao = 1) then');
        Add('insert into MIT_CONSUMO (CODIGO,COD_PROD,COD_FOR,COD_FUNC,FLG_E_S,DATA,DOCUMENTO,QUANT,VLR_UNIT,VLR_TOTAL,OBSERVACAO)');
        Add('values (:CODIGO,:COD_PROD,:COD_FOR,:COD_FUNC,:FLG_E_S,:DATA,:DOCUMENTO,:QUANT,:VLR_UNIT,:VLR_TOTAL,:OBSERVACAO);');

        Add('if (operacao = 2) then');
        Add('update MIT_CONSUMO set');
        Add('COD_PROD = :COD_PROD,');
        Add('COD_FOR = :COD_FOR,');
        Add('COD_FUNC = :COD_FUNC,');
        Add('FLG_E_S = :FLG_E_S,');
        Add('DATA = :DATA,');
        Add('DOCUMENTO = :DOCUMENTO,');
        Add('QUANT = :QUANT,');
        Add('VLR_UNIT = :VLR_UNIT,');
        Add('VLR_TOTAL = :VLR_TOTAL,');
        Add('OBSERVACAO = :OBSERVACAO');
        Add('where (CODIGO = :CODIGO);');

        Add('if (operacao = 3) then');
        Add('delete from MIT_CONSUMO');
        Add('where (CODIGO = :CODIGO);');

        Add('suspend;');
        Add('end;');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE MIT_PRODUCAO'}
  NomeProcedure:='P_MIT_PRODUCAO';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_MIT_PRODUCAO (');
        Add('OPERACAO integer,');
        Add('CODMOV integer,');
        Add('ITEM integer,');
        Add('COD_MAT integer,');
        Add('QUANT_AUSAR numeric(15,3),');
        Add('QUANT_USADA numeric(15,3),');
        Add('PR_CUSTO numeric(15,2),');
        Add('NOME_FOR varchar(60),');
        Add('COD_LOTE integer)');
        Add('as begin');
        Add('if (operacao = 1) then');
        Add('insert into MIT_PRODUCAO (CODMOV,ITEM,COD_MAT,QUANT_AUSAR,QUANT_USADA,PR_CUSTO,NOME_FOR,COD_LOTE)');
        Add('values (:CODMOV,:ITEM,:COD_MAT,:QUANT_AUSAR,:QUANT_USADA,:PR_CUSTO,:NOME_FOR,:COD_LOTE);');

        Add('if (operacao = 2) then');
        Add('update MIT_PRODUCAO set');
        Add('COD_MAT = :COD_MAT,');
        Add('QUANT_AUSAR = :QUANT_AUSAR,');
        Add('QUANT_USADA = :QUANT_USADA,');
        Add('PR_CUSTO = :PR_CUSTO,');
        Add('NOME_FOR = :NOME_FOR,');
        Add('COD_LOTE = :COD_LOTE');
        Add('where (CODMOV = :CODMOV)');
        Add('and (ITEM = :ITEM);');

        Add('if (operacao = 3) then');
        Add('delete from MIT_PRODUCAO');
        Add('where (CODMOV = :CODMOV)');
        Add('and (ITEM = :ITEM);');

        Add('suspend;');
        Add('end;');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE MOV_CARTAO'}
  NomeProcedure:='P_MOVCARTAO';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_MOVCARTAO (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('COD_CARTAO integer,');
        Add('CODMOV integer,');
        Add('CODREC integer,');
        Add('ORDREC integer,');
        Add('PARCELA varchar(10),');
        Add('DT_EMISSAO date,');
        Add('DT_VENCTO date,');
        Add('DT_PAGTO date,');
        Add('VLR_PARC numeric(15,2),');
        Add('VLR_DESC numeric(15,2),');
        Add('VLR_LIQUIDO numeric(15,2),');
        Add('OBSERVACAO varchar(60),');
        Add('AGRUPA char(1),');
        Add('VLR_ANTECIPA numeric(15,2),');
        Add('CODPAG integer,');
        Add('ORDPAG integer)');
        Add('as');
        Add('begin');
        Add('if (operacao = 1) then');
        Add('insert into MOV_CARTAO (CODIGO,COD_CARTAO,CODMOV,CODREC,ORDREC,PARCELA,DT_EMISSAO,DT_VENCTO,DT_PAGTO,VLR_PARC,VLR_DESC,VLR_LIQUIDO,OBSERVACAO,AGRUPA,VLR_ANTECIPA,CODPAG,ORDPAG)');
        Add('values (:CODIGO,:COD_CARTAO,:CODMOV,:CODREC,:ORDREC,:PARCELA,:DT_EMISSAO,:DT_VENCTO,:DT_PAGTO,:VLR_PARC,:VLR_DESC,:VLR_LIQUIDO,:OBSERVACAO,:AGRUPA,:VLR_ANTECIPA,:CODPAG,:ORDPAG);');

        Add('if (operacao = 2) then');
        Add('update MOV_CARTAO set');
        Add('COD_CARTAO = :COD_CARTAO,');
        Add('CODMOV = :CODMOV,');
        Add('CODREC = :CODREC,');
        Add('ORDREC = :ORDREC,');
        Add('PARCELA = :PARCELA,');
        Add('DT_EMISSAO = :DT_EMISSAO,');
        Add('DT_VENCTO = :DT_VENCTO,');
        Add('DT_PAGTO = :DT_PAGTO,');
        Add('VLR_PARC = :VLR_PARC,');
        Add('VLR_DESC = :VLR_DESC,');
        Add('VLR_LIQUIDO = :VLR_LIQUIDO,');
        Add('OBSERVACAO = :OBSERVACAO,');
        Add('AGRUPA = :AGRUPA,');
        Add('VLR_ANTECIPA = :VLR_ANTECIPA,');
        Add('CODPAG = :CODPAG,');
        Add('ORDPAG = :ORDPAG');
        Add('where (CODIGO = :CODIGO);');

        Add('if (operacao = 3) then');
        Add('delete from MOV_CARTAO');
        Add('where (CODIGO = :CODIGO);');

        Add('suspend;');
        Add('end');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE MOVTO'}
  NomeProcedure:='P_MOVTO';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('CREATE OR ALTER procedure P_MOVTO (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('FLG_CODMOV integer,');
        Add('DATA date,');
        Add('NOTA_FISCAL integer,');
        Add('SERIE integer,');
        Add('CUPOM_FISCAL integer,');
        Add('NRO_ECF integer,');
        Add('DATA_SAIDA date,');
        Add('COD_CLI integer,');
        Add('COD_FOR integer,');
        Add('COD_FUNC integer,');
        Add('COD_TRIB integer,');
        Add('COD_END_CLI integer,');
        Add('VLR_DESC numeric(15,2),');
        Add('VLR_ACRES numeric(15,2),');
        Add('VLR_FRETE numeric(15,2),');
        Add('PORC_FRETE numeric(15,3),');
        Add('VLR_TOTAL numeric(15,2),');
        Add('TOTAL_NF numeric(15,2),');
        Add('TIPO_RECEB integer,');
        Add('OBSERV1 varchar(400),');
        Add('OBSERV2 varchar(100),');
        Add('OBSERV3 varchar(100),');
        Add('TRANS_NOME varchar(60),');
        Add('TRANS_END varchar(60),');
        Add('TRANS_CIDADE varchar(60),');
        Add('TRANS_CIDADEUF varchar(2),');
        Add('TRANS_PLACA varchar(10),');
        Add('TRANS_PLACAUF varchar(2),');
        Add('TRANS_FRETE integer,');
        Add('TRANS_CNPJ_CPF varchar(20),');
        Add('TRANS_IE_RG varchar(20),');
        Add('CODREC_DEVOLUCAO integer,');
        Add('COD_CAIXA integer,');
        Add('FLG_CANCEL char(1),');
        Add('MOTIVO_CANCEL varchar(60),');
        Add('NF_DATA date,');
        Add('NF_DATA_SAIDA date,');
        Add('NF_HORA time,');
        Add('NF_CPF varchar(20),');
        Add('PLACA varchar(10),');
        Add('DATA_ENTREGA date,');
        Add('FLG_ABERTO char(1),');
        Add('VLR_DINH numeric(15,2),');
        Add('VLR_CHVISTA numeric(15,2),');
        Add('VLR_CHPRE numeric(15,2),');
        Add('VLR_CARTAO numeric(15,2),');
        Add('NFE_NRO integer,');
        Add('NFE_STATUS varchar(60),');
        Add('NFE_CAMINHO varchar(60),');
        Add('NFE_CHAVE varchar(60),');
        Add('NFE_OBSERV varchar(60),');
        Add('VLR_DEBITO numeric(15,2),');
        Add('VLR_PRAZO numeric(15,2),');
        Add('VLR_OUTROS numeric(15,2),');
        Add('COD_EMPRESA integer,');
        Add('NOME_VEICULO varchar(400),');
        Add('VOL_QUANT varchar(20),');
        Add('VOL_ESPECIE varchar(20),');
        Add('VOL_MARCA varchar(20),');
        Add('VOL_NRO varchar(20),');
        Add('VOL_BRUTO varchar(20),');
        Add('VOL_LIQUIDO varchar(20),');
        Add('NFE_REF1 varchar(60),');
        Add('NFE_REF2 varchar(60),');
        Add('NFE_REF3 varchar(60),');
        Add('COD_MAO_OBRA integer,');
        Add('SAT_NRO integer,');
        Add('SAT_STATUS varchar(20),');
        Add('SAT_CAMINHO varchar(60),');
        Add('SAT_CHAVE varchar(60),');
        Add('DT_COMISSAO date,');
        Add('NF_NOME varchar(60),');
        Add('COD_CONVENIO integer,');
        Add('COD_MESA integer,');
        Add('COD_PARCELA integer,');
        Add('FLG_PRECO char(1),');
        Add('LOCAL_DESEMB varchar(200),');
        Add('UF_DESEMB varchar(2),');
        Add('NRO_DI varchar(20),');
        Add('DT_DI date,');
        Add('COD_EXPORT integer,');
        Add('COD_FABRIC integer,');
        Add('TP_TRANS integer,');
        Add('NFE_REF4 varchar(60),');
        Add('VLR_IMPORT numeric(15,2),');
        Add('OBS_ADICIONAL varchar(3000),');
        Add('FLG_PROCEDE char(1),');
        Add('ROMANEIO_NRO integer,');
        Add('ROMANEIO_DATA date,');
        Add('TOKEN varchar(256),');
        Add('CODMARKET integer,');
        Add('VLR_PIX numeric(15,2),');
        Add('NFE_DADOS BLOB,');
        Add('FLG_EXC CHAR(1))');
        Add('as');
        Add('begin');
        Add('if (operacao = 1) then');
        Add('insert into MOVTO (CODIGO,FLG_CODMOV,DATA,NOTA_FISCAL,SERIE,CUPOM_FISCAL,NRO_ECF,DATA_SAIDA,COD_CLI,COD_FOR,COD_FUNC,COD_TRIB,COD_END_CLI,VLR_DESC,VLR_ACRES,VLR_FRETE,PORC_FRETE,');
        Add('VLR_TOTAL,TOTAL_NF,TIPO_RECEB,OBSERV1,OBSERV2,OBSERV3,TRANS_NOME,TRANS_END,TRANS_CIDADE,TRANS_CIDADEUF,TRANS_PLACA,TRANS_PLACAUF,TRANS_FRETE,TRANS_CNPJ_CPF,TRANS_IE_RG,CODREC_DEVOLUCAO,');
        Add('COD_CAIXA,FLG_CANCEL,MOTIVO_CANCEL,NF_DATA,NF_DATA_SAIDA,NF_HORA,NF_CPF,PLACA,DATA_ENTREGA,FLG_ABERTO,VLR_DINH,VLR_CHVISTA,VLR_CHPRE,VLR_CARTAO,NFE_NRO,NFE_STATUS,NFE_CAMINHO,');
        Add('NFE_CHAVE,NFE_OBSERV,VLR_DEBITO,VLR_PRAZO,VLR_OUTROS,COD_EMPRESA,NOME_VEICULO,VOL_QUANT,VOL_ESPECIE,VOL_MARCA,VOL_NRO,VOL_BRUTO,VOL_LIQUIDO,NFE_REF1,NFE_REF2,NFE_REF3,COD_MAO_OBRA,SAT_NRO,SAT_STATUS,SAT_CAMINHO,SAT_CHAVE,');
        Add('DT_COMISSAO,NF_NOME,COD_CONVENIO,COD_MESA,COD_PARCELA,FLG_PRECO,LOCAL_DESEMB,UF_DESEMB,NRO_DI,DT_DI,COD_EXPORT,COD_FABRIC,TP_TRANS,NFE_REF4,VLR_IMPORT,OBS_ADICIONAL,FLG_PROCEDE,ROMANEIO_NRO,ROMANEIO_DATA,TOKEN, CODMARKET, VLR_PIX, NFE_DADOS,FLG_EXC)');
        Add('values (:CODIGO,:FLG_CODMOV,:DATA,:NOTA_FISCAL,:SERIE,:CUPOM_FISCAL,:NRO_ECF,:DATA_SAIDA,:COD_CLI,:COD_FOR,:COD_FUNC,:COD_TRIB,:COD_END_CLI,:VLR_DESC,:VLR_ACRES,:VLR_FRETE,');
        Add(':PORC_FRETE,:VLR_TOTAL,:TOTAL_NF,:TIPO_RECEB,:OBSERV1,:OBSERV2,:OBSERV3,:TRANS_NOME,:TRANS_END,:TRANS_CIDADE,:TRANS_CIDADEUF,:TRANS_PLACA,:TRANS_PLACAUF,:TRANS_FRETE,');
        Add(':TRANS_CNPJ_CPF,:TRANS_IE_RG,:CODREC_DEVOLUCAO,:COD_CAIXA,:FLG_CANCEL,:MOTIVO_CANCEL,:NF_DATA,:NF_DATA_SAIDA,:NF_HORA,:NF_CPF,:PLACA,:DATA_ENTREGA,:FLG_ABERTO,');
        Add(':VLR_DINH,:VLR_CHVISTA,:VLR_CHPRE,:VLR_CARTAO,:NFE_NRO,:NFE_STATUS,:NFE_CAMINHO,:NFE_CHAVE,:NFE_OBSERV,:VLR_DEBITO,:VLR_PRAZO,:VLR_OUTROS,:COD_EMPRESA,:NOME_VEICULO,');
        Add(':VOL_QUANT,:VOL_ESPECIE,:VOL_MARCA,:VOL_NRO,:VOL_BRUTO,:VOL_LIQUIDO,:NFE_REF1,:NFE_REF2,:NFE_REF3,:COD_MAO_OBRA,:SAT_NRO,:SAT_STATUS,:SAT_CAMINHO,:SAT_CHAVE,:DT_COMISSAO,:NF_NOME,:COD_CONVENIO,:COD_MESA,:COD_PARCELA,:FLG_PRECO,');
        Add(':LOCAL_DESEMB,:UF_DESEMB,:NRO_DI,:DT_DI,:COD_EXPORT,:COD_FABRIC,:TP_TRANS,:NFE_REF4,:VLR_IMPORT,:OBS_ADICIONAL,:FLG_PROCEDE,:ROMANEIO_NRO,:ROMANEIO_DATA,:TOKEN,:CODMARKET,:VLR_PIX, :NFE_DADOS, :FLG_EXC);');
        Add('if (operacao = 2) then');
        Add('update MOVTO set');
        Add('FLG_CODMOV = :FLG_CODMOV,');
        Add('DATA = :DATA,');
        Add('NOTA_FISCAL = :NOTA_FISCAL,');
        Add('SERIE = :SERIE,');
        Add('CUPOM_FISCAL = :CUPOM_FISCAL,');
        Add('NRO_ECF = :NRO_ECF,');
        Add('DATA_SAIDA = :DATA_SAIDA,');
        Add('COD_CLI = :COD_CLI,');
        Add('COD_FOR = :COD_FOR,');
        Add('COD_FUNC = :COD_FUNC,');
        Add('COD_TRIB = :COD_TRIB,');
        Add('COD_END_CLI = :COD_END_CLI,');
        Add('VLR_DESC = :VLR_DESC,');
        Add('VLR_ACRES = :VLR_ACRES,');
        Add('VLR_FRETE = :VLR_FRETE,');
        Add('PORC_FRETE = :PORC_FRETE,');
        Add('VLR_TOTAL = :VLR_TOTAL,');
        Add('TOTAL_NF = :TOTAL_NF,');
        Add('TIPO_RECEB = :TIPO_RECEB,');
        Add('OBSERV1 = :OBSERV1,');
        Add('OBSERV2 = :OBSERV2,');
        Add('OBSERV3 = :OBSERV3,');
        Add('TRANS_NOME = :TRANS_NOME,');
        Add('TRANS_END = :TRANS_END,');
        Add('TRANS_CIDADE = :TRANS_CIDADE,');
        Add('TRANS_CIDADEUF = :TRANS_CIDADEUF,');
        Add('TRANS_PLACA = :TRANS_PLACA,');
        Add('TRANS_PLACAUF = :TRANS_PLACAUF,');
        Add('TRANS_FRETE = :TRANS_FRETE,');
        Add('TRANS_CNPJ_CPF = :TRANS_CNPJ_CPF,');
        Add('TRANS_IE_RG = :TRANS_IE_RG,');
        Add('CODREC_DEVOLUCAO = :CODREC_DEVOLUCAO,');
        Add('COD_CAIXA = :COD_CAIXA,');
        Add('FLG_CANCEL = :FLG_CANCEL,');
        Add('MOTIVO_CANCEL = :MOTIVO_CANCEL,');
        Add('NF_DATA = :NF_DATA,');
        Add('NF_DATA_SAIDA = :NF_DATA_SAIDA,');
        Add('NF_HORA = :NF_HORA,');
        Add('NF_CPF = :NF_CPF,');
        Add('PLACA = :PLACA,');
        Add('DATA_ENTREGA = :DATA_ENTREGA,');
        Add('FLG_ABERTO = :FLG_ABERTO,');
        Add('VLR_DINH = :VLR_DINH,');
        Add('VLR_CHVISTA = :VLR_CHVISTA,');
        Add('VLR_CHPRE = :VLR_CHPRE,');
        Add('VLR_CARTAO = :VLR_CARTAO,');
        Add('NFE_NRO = :NFE_NRO,');
        Add('NFE_STATUS = :NFE_STATUS,');
        Add('NFE_CAMINHO = :NFE_CAMINHO,');
        Add('NFE_CHAVE = :NFE_CHAVE,');
        Add('NFE_OBSERV = :NFE_OBSERV,');
        Add('VLR_DEBITO = :VLR_DEBITO,');
        Add('VLR_PRAZO = :VLR_PRAZO,');
        Add('VLR_OUTROS = :VLR_OUTROS,');
        Add('COD_EMPRESA = :COD_EMPRESA,');
        Add('NOME_VEICULO = :NOME_VEICULO,');
        Add('VOL_QUANT = :VOL_QUANT,');
        Add('VOL_ESPECIE = :VOL_ESPECIE,');
        Add('VOL_MARCA = :VOL_MARCA,');
        Add('VOL_NRO = :VOL_NRO,');
        Add('VOL_BRUTO = :VOL_BRUTO,');
        Add('VOL_LIQUIDO = :VOL_LIQUIDO,');
        Add('NFE_REF1 = :NFE_REF1,');
        Add('NFE_REF2 = :NFE_REF2,');
        Add('NFE_REF3 = :NFE_REF3,');
        Add('COD_MAO_OBRA = :COD_MAO_OBRA,');
        Add('SAT_NRO = :SAT_NRO,');
        Add('SAT_STATUS = :SAT_STATUS,');
        Add('SAT_CAMINHO = :SAT_CAMINHO,');
        Add('SAT_CHAVE = :SAT_CHAVE,');
        Add('DT_COMISSAO = :DT_COMISSAO,');
        Add('NF_NOME = :NF_NOME,');
        Add('COD_CONVENIO = :COD_CONVENIO,');
        Add('COD_MESA = :COD_MESA,');
        Add('COD_PARCELA = :COD_PARCELA,');
        Add('FLG_PRECO = :FLG_PRECO,');
        Add('LOCAL_DESEMB  = :LOCAL_DESEMB,');
        Add('UF_DESEMB = :UF_DESEMB,');
        Add('NRO_DI = :NRO_DI,');
        Add('DT_DI = :DT_DI,');
        Add('COD_EXPORT = :COD_EXPORT,');
        Add('COD_FABRIC = :COD_FABRIC,');
        Add('TP_TRANS = :TP_TRANS,');
        Add('NFE_REF4 = :NFE_REF4,');
        Add('VLR_IMPORT = :VLR_IMPORT,');
        Add('OBS_ADICIONAL = :OBS_ADICIONAL,');
        Add('FLG_PROCEDE = :FLG_PROCEDE,');
        Add('ROMANEIO_NRO = :ROMANEIO_NRO,');
        Add('ROMANEIO_DATA = :ROMANEIO_DATA,');
        Add('TOKEN = :TOKEN,');
        Add('CODMARKET = :CODMARKET,');
        Add('VLR_PIX = :VLR_PIX,');
        Add('NFE_DADOS = :NFE_DADOS,');
        Add('FLG_EXC = :FLG_EXC');
        Add('where (CODIGO = :CODIGO);');
        Add('if (operacao = 3) then');
        Add('delete from MOVTO');
        Add('where (CODIGO = :CODIGO);');
        Add('suspend;');
        Add('end');
        ExecQuery;
      end;
  end;
  {$ENDREGION}

  {$REGION 'PROCEDURE MOVTO_OS'}
  NomeProcedure:='P_MOVTO_OS';
  if ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Procedures...  PROCEDURE: '+NomeProcedure;
    SQL := 'Drop procedure '+NomeProcedure+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  if not ProceduresExiste(NomeProcedure, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Procedures...';
    with IB_SQL, SQL do
      begin
        Close;
        Clear;
        Add('create or alter procedure P_MOVTO_OS (');
        Add('OPERACAO integer,');
        Add('CODIGO integer,');
        Add('CODMOV integer,');
        Add('NRO_OS integer,');
        Add('DATA_SAIDA date,');
        Add('MARCA varchar(60),');
        Add('MODELO varchar(60),');
        Add('ESNHEX varchar(60),');
        Add('FLG_BATERIA char(1),');
        Add('FLG_MESA char(1),');
        Add('FLG_CHIP char(1),');
        Add('FLG_CARTAO char(1),');
        Add('FLG_OPERADORA char(1),');
        Add('FLG_ESTADO char(1),');
        Add('GARANTIA integer,');
        Add('OBSERVACAO varchar(100),');
        Add('STATUS varchar(20),');
        Add('COD_PROD1 integer,');
        Add('COD_PROD2 integer,');
        Add('COD_PROD3 integer,');
        Add('FOTO1 varchar(200),');
        Add('FOTO2 varchar(200),');
        Add('FOTO3 varchar(200),');
        Add('FOTO4 varchar(200),');
        Add('FOTO5 varchar(200),');
        Add('COD_TECNICO integer,');
        Add('FOTO6 varchar(200),');
        Add('FOTO7 varchar(200),');
        Add('COD_STATUS integer)');
        Add('as');
        Add('begin');
        Add('if (operacao = 1) then');
        Add('insert into MOVTO_OS (CODIGO,CODMOV,NRO_OS,DATA_SAIDA,MARCA,MODELO,ESNHEX,FLG_BATERIA,FLG_MESA,FLG_CHIP,FLG_CARTAO,FLG_OPERADORA,FLG_ESTADO,GARANTIA,OBSERVACAO,STATUS,COD_PROD1,');
        Add('COD_PROD2,COD_PROD3,FOTO1,FOTO2,FOTO3,FOTO4,FOTO5,COD_TECNICO,FOTO6,FOTO7, COD_STATUS)');
        Add('values (:CODIGO,:CODMOV,:NRO_OS,:DATA_SAIDA,:MARCA,:MODELO,:ESNHEX,:FLG_BATERIA,:FLG_MESA,:FLG_CHIP,:FLG_CARTAO,:FLG_OPERADORA,:FLG_ESTADO,:GARANTIA,:OBSERVACAO,:STATUS,');
        Add(':cod_prod1,:cod_prod2,:COD_PROD3,:FOTO1,:FOTO2,:FOTO3,:FOTO4,:FOTO5,:COD_TECNICO,:FOTO6,:FOTO7, :COD_STATUS);');
        Add('if (operacao = 2) then');
        Add('update MOVTO_OS set');
        Add('CODMOV = :CODMOV,');
        Add('NRO_OS = :NRO_OS,');
        Add('DATA_SAIDA = :DATA_SAIDA,');
        Add('MARCA = :MARCA,');
        Add('MODELO = :MODELO,');
        Add('ESNHEX = :ESNHEX,');
        Add('FLG_BATERIA = :FLG_BATERIA,');
        Add('FLG_MESA = :FLG_MESA,');
        Add('FLG_CHIP = :FLG_CHIP,');
        Add('FLG_CARTAO = :FLG_CARTAO,');
        Add('FLG_OPERADORA = :FLG_OPERADORA,');
        Add('FLG_ESTADO = :FLG_ESTADO,');
        Add('GARANTIA = :GARANTIA,');
        Add('OBSERVACAO = :OBSERVACAO,');
        Add('STATUS = :STATUS,');
        Add('COD_PROD1 = :cod_prod1,');
        Add('COD_PROD2 = :cod_prod2,');
        Add('COD_PROD3 = :cod_prod3,');
        Add('FOTO1 = :FOTO1,');
        Add('FOTO2 = :FOTO2,');
        Add('FOTO3 = :FOTO3,');
        Add('FOTO4 = :FOTO4,');
        Add('FOTO5 = :FOTO5,');
        Add('COD_TECNICO = :COD_TECNICO,');
        Add('FOTO6 = :FOTO6,');
        Add('FOTO7 = :FOTO7,');
        Add('COD_STATUS = :COD_STATUS');
        Add('WHERE (CODIGO = :CODIGO);');
        Add('if (operacao = 3) then');
        Add('delete from MOVTO_OS');
        Add('where (CODIGO = :CODIGO);');
        Add('suspend;');
        Add('end');
        ExecQuery;
      end;
  end;
  {ENDREGION}

  {$ENDREGION}

  {$ENDREGION}
end;

procedure TSplash_Screen.CriandoScripts;
begin
  {$REGION 'Verifica e cria scripts necessários para o BD'}

  Label1.Caption := 'Criando e executando scripts...';
  if (VersaoBD <> '1.0.1.0') then
  begin
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''SG_0115'',''ORDEM PRODUCAO'',''ESTOQUE'',''FLG_LOTE'',''PERMITE CRIACAO DE LOTE'',''NAO'',''SIM;NAO'',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'UPDATE CARTAO SET FLG_ES = ''E'', DIA_FECHA = 0, DIA_VENCE = 0';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''VENDA'',''VENDAS'',''SAIDAS'',''COMPOSICAO'',''CARREGAR ITENS DA COMPOSICAO'',''NAO'',''SIM;NAO'',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''SIM'' ';
      SQL := SQL + 'where (campo = ''COMPOSICAO'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where (cnpj = ''43.462.214/0001-92'') or (cnpj = ''55.862.031/0001-43''))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''VENDA'',''VENDAS'',''SAIDAS'',''PREVIEW'',''MOSTRAR PREVIEW'',''SIM'',''SIM;NAO'',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valido = ''SG_0015;SG_0024;SG_0035;SG_0057;SG_0088;SG_0114;SG_0134'' ';
      SQL := 'where cod_tela = ''VENDA'' and campo = ''FLG_TELA'' ';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''VENDA'',''IMPRESSAO VENDA'',''SAIDAS'',''FLG_CAMPO'',''CAMPO A EXIBIR NA IMPRESSAO'',''CODIGO'',''CODIGO;COD_BARRA'',''S'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''COD_BARRA'' ';
      SQL := SQL + 'where (campo = ''FLG_CAMPO'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where (nivel = 112) or (nivel = 114) or (nivel = 154))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''VENDA'',''IMPRESSAO VENDA'',''SAIDAS'',''EXIBE_SALDO'',''EXIBIR SALDO EM ABERTO NA IMPRESSAO'',''NAO'',''SIM;NAO'',''S'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''SIM'' ';
      SQL := SQL + 'where (campo = ''EXIBE_SALDO'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where (nivel = 45) or (cnpj = ''40.143.403/0001-04''))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''COMPRA'',''LANCAMENTOS'',''ENTRADAS'',''MEIA_NOTA'',''HABILITAR NOTA PARCIAL'',''SIM'',''SIM;NAO'',''S'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''NAO'' ';
      SQL := SQL + 'where (campo = ''MEIA_NOTA'') and (cod_tela = ''COMPRA'')';
      SQL := SQL + 'and exists (select codigo from empresa where (nivel = 20) or (nivel = 139) or (nivel = 154))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update contabilista set FLG_ATIVO = ''S'' ';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update RDB$RELATION_FIELDS set';
      SQL := SQL + 'RDB$NULL_FLAG = NULL';
      SQL := SQL + 'where (RDB$FIELD_NAME = ''COD_EMPRESA'') and';
      SQL := SQL + '(RDB$RELATION_NAME = ''CONTABILISTA'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update RDB$RELATION_FIELDS set';
      SQL := SQL + 'RDB$NULL_FLAG = 1';
      SQL := SQL + 'where (RDB$FIELD_NAME = ''FLG_ATIVO'') and';
      SQL := SQL + '(RDB$RELATION_NAME = ''CONTABILISTA'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''VENDA'',''VENDAS'',''SAIDAS'',''DIAS_ABERTO'',''BLOQUEAR VENDA DE CLIENTE COM MAIS DE (X) DIAS EM ABERTO'',''999999'','''',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''90'' ';
      SQL := SQL + 'where (campo = ''DIAS_ABERTO'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where (nivel = 8))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''10'' ';
      SQL := SQL + 'where (campo = ''DIAS_ABERTO'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where (nivel = 136))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''30'' ';
      SQL := SQL + 'where (campo = ''DIAS_ABERTO'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where (nivel = 129))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''VENDA'',''RELATORIO DE VENDA'',''SAIDAS'',''DRE_CMV'',''CALCULAR CMV'',''NAO'',''SIM;NAO'',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''SIM'' ';
      SQL := SQL + 'where (campo = ''DRE_CMV'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where ((nivel = 58) or (nivel = 89) or cnpj = (''06.000.808/0001-55'') or cnpj = (''41.390.901/0001-14'')))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'UPDATE MIT_PRODUCAO A SET A.NOME_FOR = (SELECT C.NOME FROM PRODUTO B, FORNECEDOR C WHERE B.COD_FORNECEDOR = C.CODIGO and A.COD_MAT = B.CODIGO)';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + ' values (''VENDA'',''RELATORIO DE VENDA'',''SAIDAS'',''FLG_DRE_REC'',''FILTRO A SER USADO NAS RECEITAS'',''VENDA'',''VENDA;FINANCEIRO'',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set campo = ''FLG_DRE_DESP'', descricao = ''FILTRO A SER USADO NAS DESPESAS'' where campo = ''FLG_DRE'' ';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + ' values (''VENDA'',''VENDAS'',''SAIDAS'',''DESCONTO'',''PEDIR SENHA CASO DESCONTO FOR MAIOR QUE'',''0'',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''999999''';
      SQL := SQL + 'where (campo = ''DESCONTO'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where ((nivel = 13) or (nivel = 21) or (nivel = 50) or';
      SQL := SQL + '(nivel = 76) or (nivel = 91) or (nivel = 139) or (nivel = 34) or (nivel = 2) or (nivel = 23)';
      SQL := SQL + 'or (nivel = 25) or (nivel = 30)';
      SQL := SQL + 'or (nivel = 141) or (nivel = 156) or (nivel = 5) or (nivel = 10) or (nivel = 1) or (nivel = 90) or';
      SQL := SQL + 'cnpj = (''09.539.654/0001-62'') or cnpj = (''43.877.063/0001-33'')))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''2'' ';
      SQL := SQL + 'where (campo = ''DESCONTO'') and (cod_tela = ''VENDA'') ';
      SQL := SQL + 'and exists (select codigo from empresa where ((nivel = 89)))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''05'' ';
      SQL := SQL + 'where (campo = ''DESCONTO'') and (cod_tela = ''VENDA'')';
      SQL := SQL + 'and exists (select codigo from empresa where (cnpj =(''15.490.269/0001-70'')))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''10'' ';
      SQL := SQL + 'where (campo = ''DESCONTO'') and (cod_tela = ''VENDA'') ';
      SQL := SQL + 'and exists (select codigo from empresa where ((nivel = 54) or (nivel = 4) or cnpj =(''08.280.511/0001-16'')))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''15'' ';
      SQL := SQL + 'where (campo = ''DESCONTO'') and (cod_tela = ''VENDA'') ';
      SQL := SQL + 'and exists (select codigo from empresa where ((nivel = 25)))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update configuracao set valor = ''12'' ';
      SQL := SQL + 'where (campo = ''DESCONTO'') and (cod_tela = ''VENDA'') ';
      SQL := SQL + 'and exists (select codigo from empresa where (cnpj =(''12.921.232/0001-61'')))';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''SG_0000'',''CONFIGURACOES'',''PRINCIPAL'',''VALIDADE'',''MOSTRAR PRODUTOS A (X) DIAS DO VENCIMENTO AO ABRIR O SISTEMA'',''0'','''',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'Insert INTO STATUS_OS (CODIGO, STATUS, COR)';
      SQL := SQL + 'Values(1,''TODOS'',536870912)';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'Insert INTO STATUS_OS (CODIGO, STATUS, COR)';
      SQL := SQL + 'Values(1,''Em aberto'',536870912)';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'Insert INTO STATUS_OS (CODIGO, STATUS, COR)';
      SQL := SQL + 'Values(1,''Retirado'',536870912)';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'Insert INTO STATUS_OS (CODIGO, STATUS, COR)';
      SQL := SQL + 'Values(1,''Orçamento'',536870912)';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update MOVTO_OS set cod_status = 2 where status = ''Em aberto'' ';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update MOVTO_OS set cod_status = 3 where status = ''Retirado'' ';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update MOVTO_OS set cod_status = 4 where status = ''Orçamento'' ';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update MOVTO_OS set cod_status = 5 where status = ''Pronto'' ';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'update TELAS_ACESSO set nv_func = '';1''';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
    ///
    try
      SQL := 'insert into configuracao (cod_tela,nome_tela,menu,campo,descricao,valor,valido,flg_restrito)';
      SQL := SQL + 'values (''RECEBER'',''JUROS'',''CONTAS A RECEBER'',''FLG_JUROS'',''RECALCULAR JUROS A PARTIR DO'',''PAGAMENTO'',''PAGAMENTO;VENCIMENTO'',''N'')';
      ExecuteSQL(SQL, Dm.IBD_SgMat);
    except
    end;
  end; //BD '1.0.1.0'
  {$ENDREGION}
end;

procedure TSplash_Screen.CriandoTabelas;
begin
  {$REGION 'Verifica e cria as tabelas que não existirem no Banco de dados'}

  {$REGION 'TABELA MIT_CONSUMO'}
  NomeTabela := 'MIT_CONSUMO';
  Label1.Caption := 'Criando Tabelas...  TABELA: '+NomeTabela;
  if not TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    SQL := 'CREATE TABLE '+NomeTabela+' (';
    SQL := SQL + 'CODIGO      INTEGER NOT NULL,';
    SQL := SQL + 'COD_PROD    INTEGER NOT NULL,';
    SQL := SQL + 'COD_FOR     INTEGER NOT NULL,';
    SQL := SQL + 'COD_FUNC    INTEGER NOT NULL,';
    SQL := SQL + 'FLG_E_S     CHAR(1) NOT NULL,';
    SQL := SQL + 'DATA        DATE NOT NULL,';
    SQL := SQL + 'DOCUMENTO   INTEGER,';
    SQL := SQL + 'QUANT       NUMERIC(15,3) NOT NULL,';
    SQL := SQL + 'VLR_UNIT    NUMERIC(15,3) NOT NULL,';
    SQL := SQL + 'VLR_TOTAL   NUMERIC(15,2) NOT NULL,';
    SQL := SQL + 'OBSERVACAO  VARCHAR(100)';
    SQL := SQL + ');';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  {$ENDREGION}

  {$REGION 'TABELA STATUS_OS'}
  NomeTabela := 'STATUS_OS';
  Label1.Caption := 'Criando Tabelas...  TABELA: '+NomeTabela;
  if not TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    SQL := 'CREATE TABLE '+NomeTabela+' (';
    SQL := SQL + 'CODIGO      INTEGER NOT NULL,';
    SQL := SQL + 'STATUS      VARCHAR(30),';
    SQL := SQL + 'COR         INTEGER,';
    SQL := SQL + 'FLG_GRAFICO CHAR(1) DEFAULT ''S'' ';
    SQL := SQL + ');';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  {$ENDREGION}

  {$REGION 'TABELA TELAS_ACESSO'}
  NomeTabela := 'TELAS_ACESSO';
  Label1.Caption := 'Criando Tabelas...  TABELA: '+NomeTabela;
  if not TabelaExiste(NomeTabela, Dm.IBD_SgMat) then
  begin
    SQL := 'CREATE TABLE '+NomeTabela+' (';
    SQL := SQL + '"INDEX"        VARCHAR(10),';
    SQL := SQL + 'MENU           VARCHAR(30),';
    SQL := SQL + 'MENU_PAI       VARCHAR(30),';
    SQL := SQL + 'COD_FUNC       VARCHAR(30),';
    SQL := SQL + 'NV_FUNC        VARCHAR(30),';
    SQL := SQL + 'INCLUIR        VARCHAR(30),';
    SQL := SQL + 'ALTERAR        VARCHAR(30),';
    SQL := SQL + 'EXCLUIR        VARCHAR(30),';
    SQL := SQL + 'CONSULTAR      VARCHAR(30),';
    SQL := SQL + 'IMPRIMIR       VARCHAR(30),';
    SQL := SQL + 'MENU_NOME      VARCHAR(40),';
    SQL := SQL + 'NIVEL_CLIENTE  VARCHAR(30),';
    SQL := SQL + 'ORDEM          INTEGER';
    SQL := SQL + ');';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;
  {$ENDREGION}

  {$ENDREGION}
end;

procedure TSplash_Screen.CriandoTrigger;
var
SqlQuery: TIBQuery;
FDQuery : TFDQuery;
begin
  {$REGION 'Para dropar Trigger'}
  NomeTrigger:='TRG_MIT_CONSUMO';
  if TriggersExiste(NomeTrigger, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Triggers...';
    SQL :='Drop trigger '+NomeTrigger+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;

  {###############################################}

  NomeTrigger:='TRG_STATUS_OS';
  if TriggersExiste(NomeTrigger, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Dropando Triggers...';
    SQL :='Drop trigger '+NomeTrigger+';';
    ExecuteSQL(SQL, Dm.IBD_SgMat);
  end;

  {$ENDREGION}

  {$REGION 'Verifica e cria as trigger que não existirem no Banco de dados'}

  NomeTrigger:='TRG_MIT_CONSUMO';
  NomeTabela:='MIT_CONSUMO';

  if TabelaExiste(NomeTabela,Dm.IBD_SgMat) then
  if not TriggersExiste(NomeTrigger, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Triggers...';
    //SQL := 'CREATE OR ALTER TRIGGER '+NomeTrigger+' FOR '+NomeTabela+' ACTIVE BEFORE INSERT POSITION 0 AS DECLARE VARIABLE ID INTEGER; begin   SELECT MAX(ID) FROM SALARIO   INTO :ID;  IF (ID IS NULL) THEN ID = 0;  NEW.ID = ID + 1; end';
    with IB_SQL, SQL do
    begin
      Close;
      Clear;
      Add('CREATE OR ALTER TRIGGER '+NomeTrigger+' FOR '+NomeTabela);
      Add('ACTIVE BEFORE INSERT POSITION 0');
      Add('AS');
      Add('DECLARE VARIABLE COD INTEGER;');
      Add('begin');
      Add('SELECT MAX(CODIGO) FROM '+NomeTabela);
      Add('INTO :COD;');
      Add('IF(COD IS NULL) THEN COD = 0;');
      Add('NEW.CODIGO = COD + 1;');
      Add('end');
      ExecQuery;
    end;
  end;

  {###################################################}

  NomeTrigger:='TRG_STATUS_OS';
  NomeTabela:='STATUS_OS';

  if TabelaExiste(NomeTabela,Dm.IBD_SgMat) then
  if not TriggersExiste(NomeTrigger, Dm.IBD_SgMat) then
  begin
    Label1.Caption := 'Criando Triggers...';
    with IB_SQL, SQL do
    begin
      Close;
      Clear;
      Add('CREATE OR ALTER TRIGGER '+NomeTrigger+' FOR '+NomeTabela);
      Add('ACTIVE BEFORE INSERT POSITION 0');
      Add('AS');
      Add('DECLARE VARIABLE COD INTEGER;');
      Add('begin');
      Add('SELECT MAX(CODIGO) FROM '+NomeTabela);
      Add('INTO :COD;');
      Add('IF(COD IS NULL) THEN COD = 0;');
      Add('NEW.CODIGO = COD + 1;');
      Add('end');
      ExecQuery;
    end;
  end;

  {$ENDREGION}

end;

procedure TSplash_Screen.CriandoView;
begin
  {$REGION 'Criando View'}
  {$ENDREGION}
end;

procedure TSplash_Screen.ExecuteSQL(SQL: string; BancoDados: TIBDataBase);
var
  SqlQuery: TIBQuery;
begin
  {$REGION 'ExecuteSQL'}
  SqlQuery := TIBQuery.Create(nil);
  try
    SqlQuery.Database := BancoDados;
    SqlQuery.SQL.Clear;
    SqlQuery.SQL.Add(SQL);
    SqlQuery.ExecSQL;
    SqlQuery.Close;
  finally
    //Dm.IBT_SgMat.CommitRetaining;
    SqlQuery.Free;
  end;
  {$ENDREGION}
end;

procedure TSplash_Screen.ForceCommit;
begin
  {$REGION 'Force Commit'}
  Dm.IBT_SgMat.Commit;
  if Dm.IBDS_Empresa.Active = False then Dm.IBDS_Empresa.Open;
  if Dm.IBDS_Parametros.Active = False then Dm.IBDS_Parametros.Open;
  Dm.IBDS_Empresa.First;
  Dm.IBDS_Empresa.Locate('CODIGO',VarArrayOf([Dm.icod_empresa]),[loPartialKey]);
  {$ENDREGION}
end;

procedure TSplash_Screen.FormActivate(Sender: TObject);
var itempo : Integer;
    stempo : String;
    link, arq, atualiza : String;
    ini    : TIniFile;
begin
  {$REGION 'Form Activate'}
   bAtualiza := False;

   sLibera   := '';
   sForca    := '';
   atualiza  := '';
   dm.IBDS_Parametros.Close;
   dm.IBDS_Parametros.Open;
   if dm.IBDS_Parametros.FieldByName('FLG_SISTEMA_BLOQUEADO').AsString = 'S' then
      begin
         Label1.Caption := 'SISTEMA BLOQUEADO! PARA MAIS INFORMAÇÕES, ENTRE EM CONTATO CONOSCO.';
         Gauge1.Visible := False;
         Image2.Visible := True;
         Image3.Visible := True;
         Application.ProcessMessages;

         // Aguarda 15 segundos
         stempo := '15';
         itempo := (StrToInt(Copy(TimeToStr(Time),1,2)) * 3600) + (StrToInt(Copy(TimeToStr(Time),4,2)) * 60) + (StrToInt(Copy(TimeToStr(Time),7,2)));
         Application.ProcessMessages;
         while StrToFloat(stempo) > 0 do
           begin
              stempo := FloatToStrF(15 - ((StrToInt(Copy(TimeToStr(Time),1,2)) * 3600) + (StrToInt(Copy(TimeToStr(Time),4,2)) * 60) + (StrToInt(Copy(TimeToStr(Time),7,2))) - itempo),ffFixed,8,0);
              Application.ProcessMessages;
           end;

         //Sleep(15000);
         Application.Terminate;
      end;

   link   := 'http://forca.bvxtecnologia.com.br/forca_atualizacao.php?cnpj='+Somente_Numeros(Dm.IBDS_Empresa.FieldByName('CNPJ').AsString)+'&query=forca';
   link   := TIdURI.URLEncode(link);
   sForca := GetURLAsString(link);

   link := 'http://forca.bvxtecnologia.com.br/forca_atualizacao.php?cnpj='+Somente_Numeros(Dm.IBDS_Empresa.FieldByName('CNPJ').AsString)+'&query=libera';
   link := TIdURI.URLEncode(link);
   sLibera := GetURLAsString(link);

   arq := 'C:/bvx/Versao.ini';
   ini := TIniFile.Create(arq);
   sStatus := ini.ReadString('ATUALIZA', 'STATUS', '');

   if (sLibera = 'S') or (sForca = 'S') then
      begin
         if sStatus <> 'ATUALIZANDO' then
            ChecaVersao;       // Checa versão do EXE

         if (Dm.bServidor) and (sStatus = 'ATUALIZANDO') then
            ChecaAtualizacao;  // Checa versão do BD

         { ATUALIZAR TUDO }

         //Atualiza Status Versao.ini para ''
         if sStatus = 'ATUALIZANDO' then
            ini.WriteString('ATUALIZA', 'STATUS', '');

         //Atualiza Agenda ['FORCA_ATUALIZA'] = N
         if sForca = 'S' then
            begin
               link     := 'http://forca.bvxtecnologia.com.br/forca_atualizacao.php?cnpj='+Somente_Numeros(Dm.IBDS_Empresa.FieldByName('CNPJ').AsString)+'&att=N&query=forca';
               atualiza := GetURLAsString(link);
            end;
      end;
   ini.Free;
  {$ENDREGION}
end;

procedure TSplash_Screen.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  {$REGION 'Form Key Down'}
   if dm.IBDS_Parametros.FieldByName('FLG_SISTEMA_BLOQUEADO').AsString = 'S' then
     begin
        if key = 13 then
          Application.Terminate;

        if key = vk_F1  then
          begin
             SG_SenAx := TSG_SenAx.Create(Self);

             SG_SenAx.sSenha := 'SENHA_BLOQ';
             SG_SenAx.Label2.Caption := 'BVX: Senha';
             SG_SenAx.ShowModal;
             if SG_SenAx.bCorreto = False then Exit;

             SG_SenAx.sSenha := 'DATA_BLOQ';
             SG_SenAx.Label2.Caption  := 'BVX: Data';
             SG_SenAx.sLabel1.Caption := 'Informe a próxima data.';
             SG_SenAx.ShowModal;
             if SG_SenAx.bCorreto = False then Exit;

             // Atualiza Data de Bloqueio
             with Dm.IBQ_Pesquisa, Sql do
               begin
                  Close;
                  Clear;
                  Add('UPDATE PARAMETROS SET FLG_SISTEMA_BLOQUEADO = ''N'', DT_BLOQUEIO = null, DATA_VALIDADE = :databloqueio ');
                  ParamByName('databloqueio').AsDateTime := StrToDate(SG_SenAx.Edit_Senha.Text);
                 Open;
               end;

             SG_SenAx.Destroy;
          end;
     end;
  {$ENDREGION}
end;

function TSplash_Screen.GeneratorExiste(NomeGenerator: String;
  BancoDados: TIBDataBase): Boolean;
var
  vQuery : TIBQuery;
begin
  {$REGION 'Verifica se Generator Existe'}
  vQuery := TIBQuery.Create(nil);
  try
    vQuery.DataBase := BancoDados;

    vQuery.SQL.Add('select RDB$GENERATOR_NAME from RDB$GENERATORS where RDB$GENERATOR_NAME = Upper(:pGen)');
    vQuery.ParamByName('pGen').AsString := NomeGenerator;
    vQuery.Open;

    Result := (vQuery.RecordCount > 0);
  finally
    vQuery.Free;
  end;
  {$ENDREGION}
end;

function TSplash_Screen.GetURLAsString(const aURL: string): string;
var lHTTP: TIdHTTP;
begin
  {$REGION 'GET Url para Variavel'}
  try
    lHTTP := TIdHTTP.Create(nil);
    try
      lHTTP.HTTPOptions := [hoForceEncodeParams];
      Result := lHTTP.Get(aURL);
    finally
      lHTTP.Free;
    end;
  except
    on e:Exception do
    begin
      Result := e.Message;
    end;
  end;
  {$ENDREGION}
end;

procedure TSplash_Screen.Image3Click(Sender: TObject);
begin
  {$REGION 'Imagem 3 Click'}
  if FileExists('c:\bvx\sgmat\AnyDesk.exe') then
     WinExec('c:\bvx\sgmat\AnyDesk.exe', SW_ShowNormal)
  else
     if Application.MessageBox('O aplicativo AnyDesk não foi encontrado. Deseja baixá-lo agora?','Confirmação de download',mb_yesno + mb_iconquestion) = id_yes then
        HlinkNavigateString(nil,'https://download.anydesk.com/AnyDesk.exe');
  {$ENDREGION}
end;

function TSplash_Screen.IndicesExiste(NomeTabela, NomeIndice: string;
  BancoDados: TIBDataBase): Boolean;
var
vQuery : TIBQuery;
begin
  {$REGION 'Verifica se Indice Existe'}
  vQuery := TIBQuery.Create(nil);
  try
    vQuery.DataBase := BancoDados;

    vQuery.SQL.Add('SELECT RDB$INDEX_NAME FROM RDB$INDICES WHERE RDB$RELATION_NAME = upper(:pTab) AND RDB$INDEX_NAME = upper(:pIndice) ');
    vQuery.ParamByName('pTab').AsString := NomeTabela;
    vQuery.ParamByName('pIndice').AsString := NomeIndice;
    vQuery.Open;

    Result := (vQuery.RecordCount > 0);
  finally
    vQuery.Free;
  end;
  {$ENDREGION}
end;

function TSplash_Screen.ProceduresExiste(NomeProcedure: String;
  BancoDados: TIBDataBase): Boolean;
var
  vQuery : TIBQuery;
begin
  {$REGION 'Verifica se Procedure Existe'}
  vQuery := TIBQuery.Create(nil);
  try
    vQuery.DataBase := BancoDados;

    vQuery.SQL.Add('SELECT RDB$PROCEDURE_NAME FROM RDB$PROCEDURES WHERE RDB$PROCEDURE_NAME = upper(:pProc)');
    vQuery.ParamByName('pProc').AsString := NomeProcedure;
    vQuery.Open;

    Result := (vQuery.RecordCount > 0);
  finally
    vQuery.Free;
  end;
  {$ENDREGION}
end;

function TSplash_Screen.ConstraintExiste(NomeConstraint: String;
  BancoDados: TIBDataBase): Boolean;
var
  vQuery : TIBQuery;
begin
  {$REGION 'Verifica se Constraint Existe'}
  vQuery := TIBQuery.Create(nil);
  try
    vQuery.DataBase := BancoDados;

    vQuery.SQL.Add('SELECT RDB$CONSTRAINT_NAME FROM RDB$RELATION_CONSTRAINTS WHERE RDB$CONSTRAINT_NAME = upper(:pCons)');
    vQuery.ParamByName('pCons').AsString := NomeConstraint;
    vQuery.Open;

    Result := (vQuery.RecordCount > 0);
  finally
    vQuery.Free;
  end;
  {$ENDREGION}
end;

function TSplash_Screen.Somente_Numeros(svalor: String): String;
var
  stexto : String;
  i : Integer;
begin
  {$REGION 'Função Somente Números'}
   stexto := svalor;
   svalor := '';
   for i := 1 to length(stexto) do
     if stexto[i] in ['0'..'9'] then
        svalor := svalor + stexto[i];
   result := svalor;
   {$ENDREGION}
end;

function TSplash_Screen.TabelaExiste(NomeTabela: string;
  BancoDados: TIBDataBase): Boolean;
var
  vQuery : TIBQuery;
begin
  {$REGION 'Verifica se Tabela Existe'}
  vQuery := TIBQuery.Create(nil);
  try
    vQuery.Database := BancoDados;

    vQuery.SQL.Add('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS WHERE RDB$SYSTEM_FLAG=0 AND RDB$RELATION_NAME = upper(:pTab)');
    vQuery.ParamByName('pTab').AsString := NomeTabela;
    vQuery.Open;

    Result := (vQuery.RecordCount > 0);
  finally
    vQuery.Free;
  end;
  {$ENDREGION}
end;

function TSplash_Screen.TriggersExiste(NomeTrigger: string;
  BancoDados: TIBDataBase): Boolean;
var
  vQuery : TIBQuery;
begin
  {$REGION 'Verifica se Trigger Existe'}
  vQuery := TIBQuery.Create(nil);
  try
    vQuery.DataBase := BancoDados;

    vQuery.SQL.Add('SELECT RDB$TRIGGER_NAME FROM RDB$TRIGGERS WHERE RDB$TRIGGER_NAME = upper(:pTrigger)');
    vQuery.ParamByName('pTrigger').AsString := NomeTrigger;
    vQuery.Open;

    Result := (vQuery.RecordCount > 0);
  finally
    vQuery.Free;
  end;
  {$ENDREGION}
end;

function TSplash_Screen.ViewsExiste(NomeView: string;
  BancoDados: TIBDataBase): Boolean;
var
  vQuery : TIBQuery;
begin
  {$REGION 'Verifica se View Existe'}
  vQuery := TIBQuery.Create(nil);
  try
    vQuery.DataBase := BancoDados;

    vQuery.SQL.Add('SELECT RDB$RELATION_NAME FROM RDB$RELATIONS WHERE RDB$SYSTEM_FLAG = 0 AND RDB$VIEW_SOURCE IS NOT NULL AND RDB$RELATION_NAME = upper(:pView)');
    vQuery.ParamByName('pView').AsString := NomeView;
    vQuery.Open;

    Result := (vQuery.RecordCount > 0);
  finally
    vQuery.Free;
  end;
  {$ENDREGION}
end;

end.

