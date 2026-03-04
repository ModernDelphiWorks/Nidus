{
  ------------------------------------------------------------------------------
  Nidus
  Modular and scalable application framework for Delphi,
  inspired by the architectural patterns of NestJS.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

unit Nidus.Bind.Service;

interface

uses
  SysUtils,
  ModernSyntax.ResultPair,
  Nidus.Bind.Provider;

type
  TBindService = class
  private
    FProvider: TBindProvider;
  public
    destructor Destroy; override;
    procedure IncludeBindProvider(const AProvider: TBindProvider);
    function GetBind<T: class, constructor>(const ATag: String): TResultPair<T, Exception>;
    function GetBindInterface<I: IInterface>(const ATag: String): TResultPair<I, Exception>;
  end;

implementation

uses
  Nidus.Exception;

{ TBindService }

destructor TBindService.Destroy;
begin
  if Assigned(FProvider) then
    FProvider.Free;
  inherited;
end;

function TBindService.GetBindInterface<I>(const ATag: String): TResultPair<I, Exception>;
begin
  try
    Result := FProvider.GetBindInterface<I>(ATag);
    if Result.ValueSuccess = nil then
      Result.Failure(EBindNotFoundException.Create(''));
  except
    on E: Exception do
      Result.Failure(EBindException.Create(E.Message));
  end;
end;

function TBindService.GetBind<T>(const ATag: String): TResultPair<T, Exception>;
begin
  try
    Result := FProvider.GetBind<T>(ATag);
    if Result.ValueSuccess = nil then
      Result.Failure(EBindNotFoundException.Create(''));
  except
    on E: Exception do
      Result.Failure(EBindException.Create(E.Message));
  end;
end;

procedure TBindService.IncludeBindProvider(const AProvider: TBindProvider);
begin
  FProvider := AProvider;
end;

end.













