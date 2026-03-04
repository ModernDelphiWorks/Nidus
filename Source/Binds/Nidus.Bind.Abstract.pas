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
unit Nidus.Bind.Abstract;

interface

uses
  SysUtils,
  Inject,
  Inject.Events;

type
  TBindAbstract<T: class, constructor> = class
  protected
    FOnCreate: TProc<T>;
    FOnDestroy: TProc<T>;
    FOnParams: TConstructorCallback;
    FAddInstance: TObject;
  public
    destructor Destroy; override;
    procedure IncludeInjector(const AInjector4d: TInject); virtual; abstract;
  end;

implementation

destructor TBindAbstract<T>.Destroy;
begin
  FOnCreate := nil;
  FOnDestroy := nil;
  FOnParams := nil;
  FAddInstance := nil;
  inherited;
end;

end.





