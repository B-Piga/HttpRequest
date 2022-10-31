
{***********************************************************}
{                                                           }
{                     XML Data Binding                      }
{                                                           }
{         Generated on: 27/10/2022 09:09:10                 }
{       Generated from: C:\bvx\Vendas Processadas\xml.xml   }
{   Settings stored in: C:\bvx\Vendas Processadas\xml.xdb   }
{                                                           }
{***********************************************************}

unit xml;

interface

uses xmldom, XMLDoc, XMLIntf;

type

{ Forward Decls }

  IXMLRetornosType = interface;
  IXMLRetornoType = interface;
  IXMLPedidosType = interface;
  IXMLPedidoType = interface;
  IXMLClienteType = interface;
  IXMLItensType = interface;
  IXMLItemType = interface;
  IXMLParcelasType = interface;
  IXMLParcelaType = interface;
  IXMLForma_pagamentoType = interface;

{ IXMLRetornosType }

  IXMLRetornosType = interface(IXMLNodeCollection)
    ['{A15555FE-8C93-4847-BD40-825B3CEDA064}']
    { Property Accessors }
    function Get_Retorno(Index: Integer): IXMLRetornoType;
    { Methods & Properties }
    function Add: IXMLRetornoType;
    function Insert(const Index: Integer): IXMLRetornoType;
    property Retorno[Index: Integer]: IXMLRetornoType read Get_Retorno; default;
  end;

{ IXMLRetornoType }

  IXMLRetornoType = interface(IXMLNode)
    ['{0DEE356C-1895-467E-B20A-49E87D8BDD75}']
    { Property Accessors }
    function Get_Pedidos: IXMLPedidosType;
    function Get_Arquivo: UnicodeString;
    procedure Set_Arquivo(Value: UnicodeString);
    { Methods & Properties }
    property Pedidos: IXMLPedidosType read Get_Pedidos;
    property Arquivo: UnicodeString read Get_Arquivo write Set_Arquivo;
  end;

{ IXMLPedidosType }

  IXMLPedidosType = interface(IXMLNode)
    ['{AD897C35-7E00-49EB-BB2D-5AA8CA7D4E49}']
    { Property Accessors }
    function Get_Pedido: IXMLPedidoType;
    { Methods & Properties }
    property Pedido: IXMLPedidoType read Get_Pedido;
  end;

{ IXMLPedidoType }

  IXMLPedidoType = interface(IXMLNode)
    ['{93084C03-FD60-46BE-AA4D-9B79D96C2EC2}']
    { Property Accessors }
    function Get_Desconto: UnicodeString;
    function Get_Data: UnicodeString;
    function Get_Valorfrete: Integer;
    function Get_Totalprodutos: UnicodeString;
    function Get_Totalvenda: UnicodeString;
    function Get_Cliente: IXMLClienteType;
    function Get_Itens: IXMLItensType;
    function Get_Parcelas: IXMLParcelasType;
    procedure Set_Desconto(Value: UnicodeString);
    procedure Set_Data(Value: UnicodeString);
    procedure Set_Valorfrete(Value: Integer);
    procedure Set_Totalprodutos(Value: UnicodeString);
    procedure Set_Totalvenda(Value: UnicodeString);
    { Methods & Properties }
    property Desconto: UnicodeString read Get_Desconto write Set_Desconto;
    property Data: UnicodeString read Get_Data write Set_Data;
    property Valorfrete: Integer read Get_Valorfrete write Set_Valorfrete;
    property Totalprodutos: UnicodeString read Get_Totalprodutos write Set_Totalprodutos;
    property Totalvenda: UnicodeString read Get_Totalvenda write Set_Totalvenda;
    property Cliente: IXMLClienteType read Get_Cliente;
    property Itens: IXMLItensType read Get_Itens;
    property Parcelas: IXMLParcelasType read Get_Parcelas;
  end;

{ IXMLClienteType }

  IXMLClienteType = interface(IXMLNode)
    ['{D9E51C75-318C-4E9F-AA65-507978A2D7A3}']
    { Property Accessors }
    function Get_Id: UnicodeString;
    function Get_Nome: UnicodeString;
    function Get_Cnpj: UnicodeString;
    function Get_Codigo: UnicodeString;
    procedure Set_Id(Value: UnicodeString);
    procedure Set_Nome(Value: UnicodeString);
    procedure Set_Cnpj(Value: UnicodeString);
    procedure Set_Codigo(Value: UnicodeString);
    { Methods & Properties }
    property Id: UnicodeString read Get_Id write Set_Id;
    property Nome: UnicodeString read Get_Nome write Set_Nome;
    property Cnpj: UnicodeString read Get_Cnpj write Set_Cnpj;
    property Codigo: UnicodeString read Get_Codigo write Set_Codigo;
  end;

{ IXMLItensType }

  IXMLItensType = interface(IXMLNode)
    ['{7D5C714A-1308-44A4-AA49-8E2E74D61B90}']
    { Property Accessors }
    function Get_Item: IXMLItemType;
    { Methods & Properties }
    property Item: IXMLItemType read Get_Item;
  end;

{ IXMLItemType }

  IXMLItemType = interface(IXMLNode)
    ['{324443A8-DFD7-4D96-A96C-DA77F2647AA9}']
    { Property Accessors }
    function Get_Codigo: UnicodeString;
    function Get_Descricao: UnicodeString;
    function Get_Quantidade: UnicodeString;
    function Get_Valorunidade: UnicodeString;
    function Get_Descontoitem: UnicodeString;
    function Get_Un: UnicodeString;
    procedure Set_Codigo(Value: UnicodeString);
    procedure Set_Descricao(Value: UnicodeString);
    procedure Set_Quantidade(Value: UnicodeString);
    procedure Set_Valorunidade(Value: UnicodeString);
    procedure Set_Descontoitem(Value: UnicodeString);
    procedure Set_Un(Value: UnicodeString);
    { Methods & Properties }
    property Codigo: UnicodeString read Get_Codigo write Set_Codigo;
    property Descricao: UnicodeString read Get_Descricao write Set_Descricao;
    property Quantidade: UnicodeString read Get_Quantidade write Set_Quantidade;
    property Valorunidade: UnicodeString read Get_Valorunidade write Set_Valorunidade;
    property Descontoitem: UnicodeString read Get_Descontoitem write Set_Descontoitem;
    property Un: UnicodeString read Get_Un write Set_Un;
  end;

{ IXMLParcelasType }

  IXMLParcelasType = interface(IXMLNode)
    ['{5644EA14-A019-48D9-A084-E0CC93D1BCEA}']
    { Property Accessors }
    function Get_Parcela: IXMLParcelaType;
    { Methods & Properties }
    property Parcela: IXMLParcelaType read Get_Parcela;
  end;

{ IXMLParcelaType }

  IXMLParcelaType = interface(IXMLNode)
    ['{E4564993-E669-45C4-9BBF-D98BEF8026DE}']
    { Property Accessors }
    function Get_Idlancamento: Integer;
    function Get_Valor: Integer;
    function Get_Datavencimento: UnicodeString;
    function Get_Obs: UnicodeString;
    function Get_Forma_pagamento: IXMLForma_pagamentoType;
    procedure Set_Idlancamento(Value: Integer);
    procedure Set_Valor(Value: Integer);
    procedure Set_Datavencimento(Value: UnicodeString);
    procedure Set_Obs(Value: UnicodeString);
    { Methods & Properties }
    property Idlancamento: Integer read Get_Idlancamento write Set_Idlancamento;
    property Valor: Integer read Get_Valor write Set_Valor;
    property Datavencimento: UnicodeString read Get_Datavencimento write Set_Datavencimento;
    property Obs: UnicodeString read Get_Obs write Set_Obs;
    property Forma_pagamento: IXMLForma_pagamentoType read Get_Forma_pagamento;
  end;

{ IXMLForma_pagamentoType }

  IXMLForma_pagamentoType = interface(IXMLNode)
    ['{CEAECBBB-5FA6-40D1-8584-E748B000DA8C}']
    { Property Accessors }
    function Get_Id: UnicodeString;
    function Get_Descricao: UnicodeString;
    function Get_Codigofiscal: UnicodeString;
    procedure Set_Id(Value: UnicodeString);
    procedure Set_Descricao(Value: UnicodeString);
    procedure Set_Codigofiscal(Value: UnicodeString);
    { Methods & Properties }
    property Id: UnicodeString read Get_Id write Set_Id;
    property Descricao: UnicodeString read Get_Descricao write Set_Descricao;
    property Codigofiscal: UnicodeString read Get_Codigofiscal write Set_Codigofiscal;
  end;

{ Forward Decls }

  TXMLRetornosType = class;
  TXMLRetornoType = class;
  TXMLPedidosType = class;
  TXMLPedidoType = class;
  TXMLClienteType = class;
  TXMLItensType = class;
  TXMLItemType = class;
  TXMLParcelasType = class;
  TXMLParcelaType = class;
  TXMLForma_pagamentoType = class;

{ TXMLRetornosType }

  TXMLRetornosType = class(TXMLNodeCollection, IXMLRetornosType)
  protected
    { IXMLRetornosType }
    function Get_Retorno(Index: Integer): IXMLRetornoType;
    function Add: IXMLRetornoType;
    function Insert(const Index: Integer): IXMLRetornoType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLRetornoType }

  TXMLRetornoType = class(TXMLNode, IXMLRetornoType)
  protected
    { IXMLRetornoType }
    function Get_Pedidos: IXMLPedidosType;
    function Get_Arquivo: UnicodeString;
    procedure Set_Arquivo(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLPedidosType }

  TXMLPedidosType = class(TXMLNode, IXMLPedidosType)
  protected
    { IXMLPedidosType }
    function Get_Pedido: IXMLPedidoType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLPedidoType }

  TXMLPedidoType = class(TXMLNode, IXMLPedidoType)
  protected
    { IXMLPedidoType }
    function Get_Desconto: UnicodeString;
    function Get_Data: UnicodeString;
    function Get_Valorfrete: Integer;
    function Get_Totalprodutos: UnicodeString;
    function Get_Totalvenda: UnicodeString;
    function Get_Cliente: IXMLClienteType;
    function Get_Itens: IXMLItensType;
    function Get_Parcelas: IXMLParcelasType;
    procedure Set_Desconto(Value: UnicodeString);
    procedure Set_Data(Value: UnicodeString);
    procedure Set_Valorfrete(Value: Integer);
    procedure Set_Totalprodutos(Value: UnicodeString);
    procedure Set_Totalvenda(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLClienteType }

  TXMLClienteType = class(TXMLNode, IXMLClienteType)
  protected
    { IXMLClienteType }
    function Get_Id: UnicodeString;
    function Get_Nome: UnicodeString;
    function Get_Cnpj: UnicodeString;
    function Get_Codigo: UnicodeString;
    procedure Set_Id(Value: UnicodeString);
    procedure Set_Nome(Value: UnicodeString);
    procedure Set_Cnpj(Value: UnicodeString);
    procedure Set_Codigo(Value: UnicodeString);
  end;

{ TXMLItensType }

  TXMLItensType = class(TXMLNode, IXMLItensType)
  protected
    { IXMLItensType }
    function Get_Item: IXMLItemType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLItemType }

  TXMLItemType = class(TXMLNode, IXMLItemType)
  protected
    { IXMLItemType }
    function Get_Codigo: UnicodeString;
    function Get_Descricao: UnicodeString;
    function Get_Quantidade: UnicodeString;
    function Get_Valorunidade: UnicodeString;
    function Get_Descontoitem: UnicodeString;
    function Get_Un: UnicodeString;
    procedure Set_Codigo(Value: UnicodeString);
    procedure Set_Descricao(Value: UnicodeString);
    procedure Set_Quantidade(Value: UnicodeString);
    procedure Set_Valorunidade(Value: UnicodeString);
    procedure Set_Descontoitem(Value: UnicodeString);
    procedure Set_Un(Value: UnicodeString);
  end;

{ TXMLParcelasType }

  TXMLParcelasType = class(TXMLNode, IXMLParcelasType)
  protected
    { IXMLParcelasType }
    function Get_Parcela: IXMLParcelaType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLParcelaType }

  TXMLParcelaType = class(TXMLNode, IXMLParcelaType)
  protected
    { IXMLParcelaType }
    function Get_Idlancamento: Integer;
    function Get_Valor: Integer;
    function Get_Datavencimento: UnicodeString;
    function Get_Obs: UnicodeString;
    function Get_Forma_pagamento: IXMLForma_pagamentoType;
    procedure Set_Idlancamento(Value: Integer);
    procedure Set_Valor(Value: Integer);
    procedure Set_Datavencimento(Value: UnicodeString);
    procedure Set_Obs(Value: UnicodeString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLForma_pagamentoType }

  TXMLForma_pagamentoType = class(TXMLNode, IXMLForma_pagamentoType)
  protected
    { IXMLForma_pagamentoType }
    function Get_Id: UnicodeString;
    function Get_Descricao: UnicodeString;
    function Get_Codigofiscal: UnicodeString;
    procedure Set_Id(Value: UnicodeString);
    procedure Set_Descricao(Value: UnicodeString);
    procedure Set_Codigofiscal(Value: UnicodeString);
  end;

{ Global Functions }

function Getretornos(Doc: IXMLDocument): IXMLRetornosType;
function Loadretornos(const FileName: string): IXMLRetornosType;
function Newretornos: IXMLRetornosType;

const
  TargetNamespace = '';

implementation

{ Global Functions }

function Getretornos(Doc: IXMLDocument): IXMLRetornosType;
begin
  Result := Doc.GetDocBinding('retornos', TXMLRetornosType, TargetNamespace) as IXMLRetornosType;
end;

function Loadretornos(const FileName: string): IXMLRetornosType;
begin
  Result := LoadXMLDocument(FileName).GetDocBinding('retornos', TXMLRetornosType, TargetNamespace) as IXMLRetornosType;
end;

function Newretornos: IXMLRetornosType;
begin
  Result := NewXMLDocument.GetDocBinding('retornos', TXMLRetornosType, TargetNamespace) as IXMLRetornosType;
end;

{ TXMLRetornosType }

procedure TXMLRetornosType.AfterConstruction;
begin
  RegisterChildNode('retorno', TXMLRetornoType);
  ItemTag := 'retorno';
  ItemInterface := IXMLRetornoType;
  inherited;
end;

function TXMLRetornosType.Get_Retorno(Index: Integer): IXMLRetornoType;
begin
  Result := List[Index] as IXMLRetornoType;
end;

function TXMLRetornosType.Add: IXMLRetornoType;
begin
  Result := AddItem(-1) as IXMLRetornoType;
end;

function TXMLRetornosType.Insert(const Index: Integer): IXMLRetornoType;
begin
  Result := AddItem(Index) as IXMLRetornoType;
end;

{ TXMLRetornoType }

procedure TXMLRetornoType.AfterConstruction;
begin
  RegisterChildNode('pedidos', TXMLPedidosType);
  inherited;
end;

function TXMLRetornoType.Get_Pedidos: IXMLPedidosType;
begin
  Result := ChildNodes['pedidos'] as IXMLPedidosType;
end;

function TXMLRetornoType.Get_Arquivo: UnicodeString;
begin
  Result := ChildNodes['arquivo'].Text;
end;

procedure TXMLRetornoType.Set_Arquivo(Value: UnicodeString);
begin
  ChildNodes['arquivo'].NodeValue := Value;
end;

{ TXMLPedidosType }

procedure TXMLPedidosType.AfterConstruction;
begin
  RegisterChildNode('pedido', TXMLPedidoType);
  inherited;
end;

function TXMLPedidosType.Get_Pedido: IXMLPedidoType;
begin
  Result := ChildNodes['pedido'] as IXMLPedidoType;
end;

{ TXMLPedidoType }

procedure TXMLPedidoType.AfterConstruction;
begin
  RegisterChildNode('cliente', TXMLClienteType);
  RegisterChildNode('itens', TXMLItensType);
  RegisterChildNode('parcelas', TXMLParcelasType);
  inherited;
end;

function TXMLPedidoType.Get_Desconto: UnicodeString;
begin
  Result := ChildNodes['desconto'].Text;
end;

procedure TXMLPedidoType.Set_Desconto(Value: UnicodeString);
begin
  ChildNodes['desconto'].NodeValue := Value;
end;

function TXMLPedidoType.Get_Data: UnicodeString;
begin
  Result := ChildNodes['data'].Text;
end;

procedure TXMLPedidoType.Set_Data(Value: UnicodeString);
begin
  ChildNodes['data'].NodeValue := Value;
end;

function TXMLPedidoType.Get_Valorfrete: Integer;
begin
  Result := ChildNodes['valorfrete'].NodeValue;
end;

procedure TXMLPedidoType.Set_Valorfrete(Value: Integer);
begin
  ChildNodes['valorfrete'].NodeValue := Value;
end;

function TXMLPedidoType.Get_Totalprodutos: UnicodeString;
begin
  Result := ChildNodes['totalprodutos'].Text;
end;

procedure TXMLPedidoType.Set_Totalprodutos(Value: UnicodeString);
begin
  ChildNodes['totalprodutos'].NodeValue := Value;
end;

function TXMLPedidoType.Get_Totalvenda: UnicodeString;
begin
  Result := ChildNodes['totalvenda'].Text;
end;

procedure TXMLPedidoType.Set_Totalvenda(Value: UnicodeString);
begin
  ChildNodes['totalvenda'].NodeValue := Value;
end;

function TXMLPedidoType.Get_Cliente: IXMLClienteType;
begin
  Result := ChildNodes['cliente'] as IXMLClienteType;
end;

function TXMLPedidoType.Get_Itens: IXMLItensType;
begin
  Result := ChildNodes['itens'] as IXMLItensType;
end;

function TXMLPedidoType.Get_Parcelas: IXMLParcelasType;
begin
  Result := ChildNodes['parcelas'] as IXMLParcelasType;
end;

{ TXMLClienteType }

function TXMLClienteType.Get_Id: UnicodeString;
begin
  Result := ChildNodes['id'].Text;
end;

procedure TXMLClienteType.Set_Id(Value: UnicodeString);
begin
  ChildNodes['id'].NodeValue := Value;
end;

function TXMLClienteType.Get_Nome: UnicodeString;
begin
  Result := ChildNodes['nome'].Text;
end;

procedure TXMLClienteType.Set_Nome(Value: UnicodeString);
begin
  ChildNodes['nome'].NodeValue := Value;
end;

function TXMLClienteType.Get_Cnpj: UnicodeString;
begin
  Result := ChildNodes['cnpj'].Text;
end;

procedure TXMLClienteType.Set_Cnpj(Value: UnicodeString);
begin
  ChildNodes['cnpj'].NodeValue := Value;
end;

function TXMLClienteType.Get_Codigo: UnicodeString;
begin
  Result := ChildNodes['codigo'].Text;
end;

procedure TXMLClienteType.Set_Codigo(Value: UnicodeString);
begin
  ChildNodes['codigo'].NodeValue := Value;
end;

{ TXMLItensType }

procedure TXMLItensType.AfterConstruction;
begin
  RegisterChildNode('item', TXMLItemType);
  inherited;
end;

function TXMLItensType.Get_Item: IXMLItemType;
begin
  Result := ChildNodes['item'] as IXMLItemType;
end;

{ TXMLItemType }

function TXMLItemType.Get_Codigo: UnicodeString;
begin
  Result := ChildNodes['codigo'].Text;
end;

procedure TXMLItemType.Set_Codigo(Value: UnicodeString);
begin
  ChildNodes['codigo'].NodeValue := Value;
end;

function TXMLItemType.Get_Descricao: UnicodeString;
begin
  Result := ChildNodes['descricao'].Text;
end;

procedure TXMLItemType.Set_Descricao(Value: UnicodeString);
begin
  ChildNodes['descricao'].NodeValue := Value;
end;

function TXMLItemType.Get_Quantidade: UnicodeString;
begin
  Result := ChildNodes['quantidade'].Text;
end;

procedure TXMLItemType.Set_Quantidade(Value: UnicodeString);
begin
  ChildNodes['quantidade'].NodeValue := Value;
end;

function TXMLItemType.Get_Valorunidade: UnicodeString;
begin
  Result := ChildNodes['valorunidade'].Text;
end;

procedure TXMLItemType.Set_Valorunidade(Value: UnicodeString);
begin
  ChildNodes['valorunidade'].NodeValue := Value;
end;

function TXMLItemType.Get_Descontoitem: UnicodeString;
begin
  Result := ChildNodes['descontoitem'].Text;
end;

procedure TXMLItemType.Set_Descontoitem(Value: UnicodeString);
begin
  ChildNodes['descontoitem'].NodeValue := Value;
end;

function TXMLItemType.Get_Un: UnicodeString;
begin
  Result := ChildNodes['un'].Text;
end;

procedure TXMLItemType.Set_Un(Value: UnicodeString);
begin
  ChildNodes['un'].NodeValue := Value;
end;

{ TXMLParcelasType }

procedure TXMLParcelasType.AfterConstruction;
begin
  RegisterChildNode('parcela', TXMLParcelaType);
  inherited;
end;

function TXMLParcelasType.Get_Parcela: IXMLParcelaType;
begin
  Result := ChildNodes['parcela'] as IXMLParcelaType;
end;

{ TXMLParcelaType }

procedure TXMLParcelaType.AfterConstruction;
begin
  RegisterChildNode('forma_pagamento', TXMLForma_pagamentoType);
  inherited;
end;

function TXMLParcelaType.Get_Idlancamento: Integer;
begin
  Result := ChildNodes['idlancamento'].NodeValue;
end;

procedure TXMLParcelaType.Set_Idlancamento(Value: Integer);
begin
  ChildNodes['idlancamento'].NodeValue := Value;
end;

function TXMLParcelaType.Get_Valor: Integer;
begin
  Result := ChildNodes['valor'].NodeValue;
end;

procedure TXMLParcelaType.Set_Valor(Value: Integer);
begin
  ChildNodes['valor'].NodeValue := Value;
end;

function TXMLParcelaType.Get_Datavencimento: UnicodeString;
begin
  Result := ChildNodes['datavencimento'].Text;
end;

procedure TXMLParcelaType.Set_Datavencimento(Value: UnicodeString);
begin
  ChildNodes['datavencimento'].NodeValue := Value;
end;

function TXMLParcelaType.Get_Obs: UnicodeString;
begin
  Result := ChildNodes['obs'].Text;
end;

procedure TXMLParcelaType.Set_Obs(Value: UnicodeString);
begin
  ChildNodes['obs'].NodeValue := Value;
end;

function TXMLParcelaType.Get_Forma_pagamento: IXMLForma_pagamentoType;
begin
  Result := ChildNodes['forma_pagamento'] as IXMLForma_pagamentoType;
end;

{ TXMLForma_pagamentoType }

function TXMLForma_pagamentoType.Get_Id: UnicodeString;
begin
  Result := ChildNodes['id'].Text;
end;

procedure TXMLForma_pagamentoType.Set_Id(Value: UnicodeString);
begin
  ChildNodes['id'].NodeValue := Value;
end;

function TXMLForma_pagamentoType.Get_Descricao: UnicodeString;
begin
  Result := ChildNodes['descricao'].Text;
end;

procedure TXMLForma_pagamentoType.Set_Descricao(Value: UnicodeString);
begin
  ChildNodes['descricao'].NodeValue := Value;
end;

function TXMLForma_pagamentoType.Get_Codigofiscal: UnicodeString;
begin
  Result := ChildNodes['codigofiscal'].Text;
end;

procedure TXMLForma_pagamentoType.Set_Codigofiscal(Value: UnicodeString);
begin
  ChildNodes['codigofiscal'].NodeValue := Value;
end;

end.