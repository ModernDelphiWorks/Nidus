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

unit Nidus.Route.Handler;

interface

uses
  Rtti,
  SysUtils,
  Nidus.Inject;

type
  TRouteHandler = class abstract
  private
    FNidusInject: PNidusInject;
    procedure _RegisterRouteHandle(const ARoute: String);
  protected
    procedure RegisterRoutes; virtual; abstract;
  public
    constructor Create; overload; virtual;
    destructor Destroy; override;
    function RouteGet(const ARoute: String): TRouteHandler; virtual;
    function RoutePost(const ARoute: String): TRouteHandler; virtual;
    function RoutePut(const ARoute: String): TRouteHandler; virtual;
    function RouteDelete(const ARoute: String): TRouteHandler; virtual;
    function RoutePatch(const ARoute: String): TRouteHandler; virtual;
  end;

  TRouteHandlerClass = class of TRouteHandler;

implementation

uses
  Nidus.Register,
  Nidus.Exception;

constructor TRouteHandler.Create;
begin
  FNidusInject := GNidusInject;
  if not Assigned(FNidusInject) then
    raise EAppInjector.Create;
  RegisterRoutes;
end;

destructor TRouteHandler.Destroy;
begin
  FNidusInject := nil;
  inherited;
end;

function TRouteHandler.RouteDelete(const ARoute: String): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

function TRouteHandler.RouteGet(const ARoute: String): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

function TRouteHandler.RoutePatch(const ARoute: String): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

function TRouteHandler.RoutePost(const ARoute: String): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

function TRouteHandler.RoutePut(const ARoute: String): TRouteHandler;
begin
  Result := Self;
  _RegisterRouteHandle(ARoute);
end;

procedure TRouteHandler._RegisterRouteHandle(const ARoute: String);
var
  LRegister: TRegister;
begin
  LRegister := FNidusInject^.Get<TRegister>;
  if LRegister = nil then
    Exit;
  if not LRegister.ResgisterContainsKey(Self.ClassName) then
    Exit;
  if LRegister.RouteContainsKey(ARoute) then
    Exit;
  LRegister.Add(ARoute, Self.ClassName);
end;

end.


