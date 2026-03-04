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

unit Nidus.Module.Provider;

interface

uses
  SysUtils,
  ModernSyntax.ResultPair,
  Nidus.Exception,
  Nidus.Tracker,
  Nidus.Route.Param,
  Nidus.Module.Abstract,
  Nidus.Route.Abstract,
  Nidus.Listener,
  Nidus.Injector;

type
  TModuleProvider = class
  private
    FAppInjector: PAppInjector;
    FTracker: TTracker;
    FListener: TAppListener;
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeTracker(const ATracker: TTracker);
    function Start(const AModule: TModuleAbstract;
      const AInitialRoutePath: String): TResultPair<Boolean, String>;
    function DisposeModule(const APath: String): TResultPair<Boolean, String>;
    procedure AddRoutes(const AModule: TModuleAbstract);
    procedure BindModule(const AModule: TModuleAbstract);
    procedure RemoveRoutes(const AModuleName: String);
    procedure ExtractInjector<T: class>(const ATag: String);
  end;

implementation

procedure TModuleProvider.AddRoutes(const AModule: TModuleAbstract);
begin
  FTracker.AddRoutes(AModule);
end;

procedure TModuleProvider.BindModule(const AModule: TModuleAbstract);
begin
  FTracker.BindModule(AModule);
end;

constructor TModuleProvider.Create;
begin
  FAppInjector := GAppInjector;
  if not Assigned(FAppInjector) then
    raise EAppInjector.Create;
end;

destructor TModuleProvider.Destroy;
begin
  FAppInjector := nil;
  FTracker := nil;
  inherited;
end;

procedure TModuleProvider.IncludeTracker(
  const ATracker: TTracker);
begin
  FTracker := ATracker;
end;

procedure TModuleProvider.RemoveRoutes(const AModuleName: String);
begin
  FTracker.RemoveRoutes(AModuleName);
end;

function TModuleProvider.Start(const AModule: TModuleAbstract;
  const AInitialRoutePath: String): TResultPair<Boolean, String>;
begin
  try
    FTracker.RunApp(AModule, AInitialRoutePath);
    FListener := FAppInjector^.Get<TAppListener>;
    Result.Success(True);
  except
    on E: Exception do
      Result.Failure(E.Message);
  end;
end;

function TModuleProvider.DisposeModule(
  const APath: String): TResultPair<Boolean, String>;
var
  LRoute: TRouteAbstract;
  LError: String;
  LModuleName: String;
begin
  try
    LRoute := FTracker.DisposeModule(TRouteParam.Create(APath));
    if LRoute = nil then
    begin
      LError := Format('Nest4d route (%s) not found!', [APath]);
      Result.Failure(LError);
      Exit;
    end;
    LModuleName := LRoute.ModuleInstance.ClassName;
    // Shouldn't change to .Free, as it also needs to receive Nil.
    FreeAndNil(LRoute.ModuleInstance);
    if Assigned(FListener) then
      FListener.Execute(FormatListenerMessage(Format('[InstanceLoader] %s dependencies finalized', [LModuleName])));
    Result.Success(True);
  except
    on E: Exception do
      Result.Failure(E.Message);
  end;
end;

procedure TModuleProvider.ExtractInjector<T>(const ATag: String);
begin
  FTracker.ExtractInjector<T>(ATag);
end;

end.







