unit UnitTestBlingRequest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm1 = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}



procedure TSg_0000.sButton1Click(Sender: TObject);
const
  SourceFile = 'http://200.98.203.197:8081/BVX-rest/v1/public_html/api/callbackblings/token=eyJ1c3VhcmlvIjoiYmFsY2FvIiwic2VuaGEiOiJBIiwidGlwbyI6InNnbW9iIn0=';
  DestFile = 'C:\bvx\Vendas Processadas\xml.xml';
  DestSrc = '';
var
i, j : Integer;
Result : Boolean;
a,SrcFl : String;
Node : IXMLNode;

sData,sCodigo,sCodCli,sToken,sVlrTot,
sParcela,sVlrParcela,sDesconto,sFormRec,
sCpf,sNomeCli,sCodProd,sQuantUn,sQuant,
sVlrUn,sDataVenc,sNomeProd, sEndCli, sCodMov : String;

PropList : IXMLRetornosType;

begin
    Result := UrlDownloadToFile(nil, PChar(SourceFile), PChar(DestFile), 0, nil) = 0;

  if not DownloadFile(SourceFile, DestFile) then
    begin
      // A mensagem será exibida após a conclusão do Download. (SÓ PARA TESTES)
      ShowMessage('Erro: 1'+#13+'Não foi possível receber o callback'+#13+'Contate a Equipe de Suporte: (14)99706-2094');
    end;

  PropList := Xml.Getretornos(XMLDocument1);
  //Xml.Getretornos(XMLDocument1);
  for i := 0 to PropList.Count - 1 do
    begin
      sData     := PropList.Retorno[i].Pedidos.Pedido.Data;
      sData     := StringReplace(sData,'-','/',[rfReplaceAll,rfIgnoreCase]);
      sData     := Copy(sData,9,3)+Copy(sData,5,4)+Copy(sData,1,4);
      sNomeCli  := PropList.Retorno[i].Pedidos.Pedido.Cliente.Nome;
      sCodCli   := '0';
      sVlrTot   := PropList.Retorno[i].Pedidos.Pedido.Totalvenda;
      sToken    := PropList.Retorno[i].Arquivo;
      sDesconto := PropList.Retorno[i].Pedidos.Pedido.Desconto;
      sCodProd  := PropList.Retorno[i].Pedidos.Pedido.Itens.Item.Codigo;
      sQuant    := PropList.Retorno[i].Pedidos.Pedido.Itens.Item.Quantidade;
      sVlrUn    := PropList.Retorno[i].Pedidos.Pedido.Itens.Item.Valorunidade;

    //Busca o EndCli
      With dm.IBQ_Pesquisa, SQL do
        begin
          Close;
          Clear;
          Add('select codigo from end_cli where cod_cli = :cod');
          ParamByName('cod').AsString := sCodCli;
          Open;
        end;
      sEndCli := dm.IBQ_Pesquisa.FieldByName('CODIGO').AsString;

    //Inserção dos dados no DB
      With dm.IBQ_Pesquisa, SQL do
        begin
          Close;
          Clear;
          Add('INSERT INTO MOVTO (CODIGO, FLG_CODMOV, DATA, DATA_SAIDA, COD_CLI, COD_TRIB, SERIE,');
          Add('COD_END_CLI, VLR_DESC, VLR_ACRES, VLR_FRETE, VLR_TOTAL, TOTAL_NF, TIPO_RECEB,COD_CAIXA, FLG_CANCEL,');
          Add('FLG_ABERTO, VLR_DINH, VLR_CHVISTA, VLR_CHPRE, VLR_CARTAO,');
          Add('DT_CADASTRO, NF_NOME, TOKEN, VLR_DEBITO, VLR_PRAZO, VLR_OUTROS, COD_EMPRESA)');
          Add('VALUES');
          Add('(:CODIGO, :FLG_CODMOV, :DATA, :DATA_SAIDA, :COD_CLI, :COD_TRIB, :SERIE,');
          Add(':COD_END_CLI, :VLR_DESC, :VLR_ACRES, :VLR_FRETE, :VLR_TOTAL, :TOTAL_NF, :TIPO_RECEB,:COD_CAIXA, :FLG_CANCEL,');
          Add(':FLG_ABERTO, :VLR_DINH, :VLR_CHVISTA, :VLR_CHPRE, :VLR_CARTAO,');
          Add(':DT_CADASTRO, :NF_NOME, :TOKEN, :VLR_DEBITO, :VLR_PRAZO, :VLR_OUTROS, :COD_EMPRESA)');
          ParamByName('CODIGO').AsInteger           := 0;
          ParamByName('FLG_CODMOV').AsInteger       := 1;
          ParamByName('DATA').AsDateTime            := Date;
          ParamByName('DATA_SAIDA').AsDateTime      := StrToDate(sData);
          ParamByName('COD_CLI').AsInteger          := StrToInt(sCodCli);
          ParamByName('COD_EMPRESA').AsInteger      := 1;
          ParamByName('COD_TRIB').AsInteger         := 7;
          ParamByName('SERIE').AsInteger            := 52;
          ParamByName('COD_END_CLI').AsString       := sEndCli;
          ParamByName('VLR_DESC').AsInteger         := 0;
          ParamByName('VLR_ACRES').AsInteger        := 0;
          ParamByName('VLR_FRETE').AsInteger        := 0;
          ParamByName('VLR_TOTAL').AsString         := sVlrTot;
          ParamByName('TOTAL_NF').AsString          := sVlrTot;
          ParamByName('TIPO_RECEB').AsInteger       := 1;
          ParamByName('COD_CAIXA').AsInteger        := dm.cod_caixa;
          ParamByName('FLG_CANCEL').AsString        := 'N';
          ParamByName('FLG_ABERTO').AsString        := 'N';
          ParamByName('VLR_DINH').AsString          := sVlrTot;
          ParamByName('VLR_CHVISTA').AsFloat        := 0;
          ParamByName('VLR_CHPRE').AsFloat          := 0;
          ParamByName('VLR_CARTAO').AsFloat         := 0;
          ParamByName('VLR_DEBITO').AsFloat         := 0;
          ParamByName('VLR_PRAZO').AsFloat          := 0;
          ParamByName('VLR_OUTROS').AsFloat         := 0;
          ParamByName('DT_CADASTRO').AsDateTime     := Date;
          ParamByName('NF_NOME').AsString           := sNomeCli;
          ParamByName('TOKEN').AsString             := sToken;
          Open;
        end;

    //Seleciona o CodMov
      With IBQ_PesqAux, SQL do
        begin
          Close;
          Clear;
          Add('select max(cast(codigo as integer)) codmov from movto');
          Open;
        end;
      sCodMov := IBQ_PesqAux.FieldByName('CODMOV').AsString;

    //Inserção dos itens no movit
          With Dm.IBQ_PesqAux, SQL do
            begin
              Close;
              Clear;
              Add('INSERT INTO MOVIT (CODMOV, ITEM, COD_PROD, QUANT, QUANT_NF, VLR_UNIT, VLR_TOTAL,');
              Add('PORC_QUANT, PORC_PRECO, UNIDADE, COD_TRIB, COD_CFOP, COD_VENDEDOR, COD_INSTALADOR)');
              Add('VALUES');
              Add('(:CODMOV, :ITEM, :COD_PROD, :QUANT, :QUANT_NF, :VLR_UNIT, :VLR_TOTAL,');
              Add(':PORC_QUANT, :PORC_PRECO, :UNIDADE, :COD_TRIB, :COD_CFOP, :COD_VENDEDOR, :COD_INSTALADOR)');
              ParamByName('CODMOV').AsString           := sCodMov;
              ParamByName('ITEM').AsInteger            := 1;
              ParamByName('COD_PROD').AsInteger        := StrToInt(sCodProd);
              ParamByName('QUANT').AsString            := sQuant;
              ParamByName('QUANT_NF').AsString         := sQuant;
              ParamByName('VLR_UNIT').AsString         := sVlrUn;
              ParamByName('VLR_TOTAL').AsString        := sVlrTot;
              ParamByName('PORC_QUANT').AsFloat        := 100;
              ParamByName('PORC_PRECO').AsFloat        := 100;
              ParamByName('UNIDADE').AsString          := 'UN';
              ParamByName('COD_TRIB').AsInteger        := 7;
              ParamByName('COD_CFOP').AsString         := '5.102';
              ParamByName('COD_VENDEDOR').AsInteger    := dm.cod_func;
              ParamByName('COD_INSTALADOR').AsInteger  := dm.cod_func;
              Open;
            end;
    Application.ProcessMessages;
    end;
sToken := 'C:\bvx\Vendas\'+sToken+'.xml';
MoveDir(DestFile,sToken);

IdHTTP1.Delete(SourceFile);

ShowMessage('FINALIZADO');
end;

end.
