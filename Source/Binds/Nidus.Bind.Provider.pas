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

unit Nidus.Bind.Provider;

interface

uses
  SysUtils,
  ModernSyntax.ResultPair,
  Nidus.Tracker;

type
  TBindProvider = class
  private
    FTracker: TTracker;
  public
    constructor Create(const ATracker: TTracker);
    destructor Destroy; override;
    function GetBind<T: class, constructor>(const ATag: String): TResultPair<T, Exception>;
    function GetBindInterface<I: IInterface>(const ATag: String): TResultPair<I, Exception>;
  end;

implementation

constructor TBindProvider.Create(const ATracker: TTracker);
begin
  FTracker := ATracker;
end;

destructor TBindProvider.Destroy;
begin
  FTracker := nil;
  inherited;
end;

function TBindProvider.GetBindInterface<I>(const ATag: String): TResultPair<I, Exception>;
begin
  Result.Success(FTracker.GetBindInterface<I>(ATag));
end;

function TBindProvider.GetBind<T>(const ATag: String): TResultPair<T, Exception>;
begin
  Result.Success(FTracker.GetBind<T>(ATag));
end;

end.









