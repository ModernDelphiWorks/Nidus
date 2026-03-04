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

unit Nidus.Module.Service;

interface

uses
  SysUtils,
  ModernSyntax.ResultPair,
  Nidus.Exception,
  Nidus.Route.Abstract,
  Nidus.Module.Abstract,
  Nidus.Module.Provider;

type
  TModuleService = class
  private
    FProvider: TModuleProvider;
  public
    destructor Destroy; override;
    procedure IncludeProvider(const AProvider: TModuleProvider);
    procedure Start(const AModule: TModuleAbstract;
      const AInitialRoutePath: String);
    procedure DisposeModule(const APath: String);
    procedure AddRoutes(const AModule: TModuleAbstract);
    procedure BindModule(const AModule: TModuleAbstract);
    procedure RemoveRoutes(const AModuleName: String);
    procedure ExtractInjector<T: class>(const ATag: String);
  end;

implementation

{ TModuleService }

procedure TModuleService.DisposeModule(
  const APath: String);
var
  LResult: TResultPair<Boolean, String>;
begin
  LResult := FProvider.DisposeModule(APath);
end;

procedure TModuleService.ExtractInjector<T>(const ATag: String);
begin
  FProvider.ExtractInjector<T>(ATag);
end;

procedure TModuleService.AddRoutes(const AModule: TModuleAbstract);
begin
  FProvider.AddRoutes(AModule);
end;

procedure TModuleService.BindModule(const AModule: TModuleAbstract);
begin
  FProvider.BindModule(AModule);
end;

destructor TModuleService.Destroy;
begin
  if Assigned(FProvider) then
    FProvider.Free;
  inherited;
end;

procedure TModuleService.IncludeProvider(const AProvider: TModuleProvider);
begin
  FProvider := AProvider;
end;

procedure TModuleService.RemoveRoutes(const AModuleName: String);
begin
  FProvider.RemoveRoutes(AModuleName);
end;

procedure TModuleService.Start(const AModule: TModuleAbstract;
  const AInitialRoutePath: String);
var
  LResult: TResultPair<Boolean, String>;
begin
  LResult := FProvider.Start(AModule, AInitialRoutePath);
end;

end.









