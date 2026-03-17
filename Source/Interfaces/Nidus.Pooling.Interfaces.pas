unit Nidus.Pooling.Interfaces;

interface

uses
  SysUtils;

type
  IPool = interface
    ['{D4E4F3F1-1A4E-4C78-9C4D-6DB0D5E3B7D3}']
    function Acquire: TObject;
    procedure Release(const AValue: TObject);
    function Count: Integer;
  end;

  IPoolRegistry = interface
    ['{D02D4F2D-0C4A-4D73-8F1E-8F5C2B7F4C1D}']
    procedure RegisterPool(const AKey: string; const APool: IPool);
    function TryGetPool(const AKey: string; out APool: IPool): Boolean;
  end;

procedure SetGlobalPoolRegistry(const ARegistry: IPoolRegistry);
function GetGlobalPoolRegistry: IPoolRegistry;

implementation

var
  GPoolRegistry: IPoolRegistry;

procedure SetGlobalPoolRegistry(const ARegistry: IPoolRegistry);
begin
  GPoolRegistry := ARegistry;
end;

function GetGlobalPoolRegistry: IPoolRegistry;
begin
  Result := GPoolRegistry;
end;

end.

