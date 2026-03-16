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

unit Nidus.Route.Provider;

interface

uses
  Rtti,
  SysUtils,
  Nidus.Exception,
  Nidus.Tracker,
  Nidus.Module.Abstract,
  Nidus.Inject,
  Nidus.Listener,
  Nidus.Route,
  Nidus.Route.Abstract,
  Nidus.Route.Param,
  ModernSyntax.ResultPair,
  ModernSyntax.Objects;

type
  TRouteProvider = class
  private
    FTracker: TTracker;
    FNidusInject: PNidusInject;
    function _RouteMiddleware(const ARoute: TRouteAbstract): TRouteAbstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeTracker(const ATracker: TTracker);
    function GetRoute(const AArgs: TRouteParam): TResultPair<TRouteAbstract, Exception>;
  end;

implementation

constructor TRouteProvider.Create;
begin
  FNidusInject := GNidusInject;
  if not Assigned(FNidusInject) then
    raise EAppInjector.Create;
end;

destructor TRouteProvider.Destroy;
begin
  FNidusInject := nil;
  if Assigned(FTracker) then
    FTracker := nil;
  inherited;
end;

procedure TRouteProvider.IncludeTracker(
  const ATracker: TTracker);
begin
  FTracker := ATracker;
end;

function TRouteProvider._RouteMiddleware(
  const ARoute: TRouteAbstract): TRouteAbstract;
var
  LMiddleware: IRouteMiddleware;
  LFor: Int16;
begin
  Result := ARoute;
  for LFor := 0 to High(ARoute.Middlewares) do
  begin
    LMiddleware := ARoute.Middlewares[LFor].Create;
    LMiddleware.After(ARoute);
  end;
end;

function TRouteProvider.GetRoute(const AArgs: TRouteParam): TResultPair<TRouteAbstract, Exception>;
var
  LListener: TAppListener;
  LObject: TModernObject;
begin
  Result.Success(FTracker.FindRoute(AArgs));
  if Result.ValueSuccess = nil then
    Exit;
  //
  LObject := FNidusInject^.Get<TModernObject>;
  LListener := FNidusInject^.Get<TAppListener>;
  //
  if not Assigned(Result.ValueSuccess.ModuleInstance) then
  begin
    Result.ValueSuccess.ModuleInstance := LObject.Factory(Result.ValueSuccess.Module);
    if Assigned(LListener) then
      LListener.Execute(FormatListenerMessage(Format('[InstanceLoader] %s dependencies initialized', [Result.ValueSuccess.ModuleInstance.ClassName])));
  end;
  // Go to middleware events if they exist.
  _RouteMiddleware(Result.ValueSuccess);
end;

end.

