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

unit Nidus.Injector;

interface

uses
  Rtti,
  SysUtils,
  Inject,
  Inject.Service,
  Generics.Collections;

type
  PAppInjector = ^TAppInjector;
  TAppInjector = class(TInject)
  public
    procedure CreateNest4dInjector;
    procedure ExtractInjector<T: class>(const ATag: String = '');
  end;

  TCoreInjector = class(TAppInjector)
  private
    procedure _TrackeInjector; // Singleton
    procedure _ObjectFactoryInjector; // SingletonLazy
    procedure _BindServiceInjector; // Factory
    procedure _RouteServiceInjector; // Factory
    procedure _ModuleServiceInjector; // Factory
    procedure _ModuleProviderInjector; // Factory
    procedure _BindProviderInjector; // Factory
    procedure _RouteProviderInjector; // Factory
    procedure _RouteParseInjector; // Factory
    procedure _Nest4dBrInjector; // SingletonLazy
  public
    constructor Create; override;
  end;

var
  GAppInjector: PAppInjector = nil;

const C_NEST4D = 'Nest4D';

implementation

uses
  ModernSyntax.Objects,
  Nidus.Bind.Provider,
  Nidus.Bind.Service,
  Nidus.Module.Provider,
  Nidus.Module.Service,
  Nidus.Route.Provider,
  Nidus.Route.Parse,
  Nidus.Route.Service,
  Nidus.Route.Manager,
  Nidus.Tracker,
  Nidus.Register,
  Nidus;

{ TCoreInjector }

constructor TCoreInjector.Create;
begin
  inherited;
  // Datasource
  _TrackeInjector;
  _ObjectFactoryInjector;
  // Infra
  _BindServiceInjector;
  _RouteServiceInjector;
  _ModuleServiceInjector;
  // Domain
  _ModuleProviderInjector;
  _BindProviderInjector;
  _RouteProviderInjector;
  _RouteParseInjector;
  _Nest4dBrInjector;
end;

procedure TCoreInjector._BindProviderInjector;
begin
  Self.Factory<TBindProvider>(nil, nil,
    function: TConstructorParams
    begin
      Result := [TValue.From<TTracker>(Self.Get<TTracker>)];
    end);
end;

procedure TCoreInjector._BindServiceInjector;
begin
  Self.Factory<TBindService>(
    procedure(Value: TBindService)
    begin
      Value.IncludeBindProvider(Self.Get<TBindProvider>);
    end);
end;

procedure TCoreInjector._Nest4dBrInjector;
begin
  Self.SingletonLazy<TNidus>(
    procedure(Value: TNidus)
    begin
      Value.IncludeModuleService(Self.Get<TModuleService>);
      Value.IncludeBindService(Self.Get<TBindService>);
      Value.IncludeRouteParser(Self.Get<TRouteParse>);
    end);
end;

procedure TCoreInjector._ModuleProviderInjector;
begin
  Self.Factory<TModuleProvider>(
    procedure(Value: TModuleProvider)
    begin
      Value.IncludeTracker(Self.Get<TTracker>);
    end);
end;

procedure TCoreInjector._ModuleServiceInjector;
begin
  Self.Factory<TModuleService>(
    procedure(Value: TModuleService)
    begin
      Value.IncludeProvider(Self.Get<TModuleProvider>);
    end);
end;

procedure TCoreInjector._RouteParseInjector;
begin
  Self.Factory<TRouteParse>(
    procedure(Value: TRouteParse)
    begin
      Value.IncludeRouteService(Self.Get<TRouteService>);
    end);
end;

procedure TCoreInjector._RouteProviderInjector;
begin
  Self.Factory<TRouteProvider>(
    procedure(Value: TRouteProvider)
    begin
      Value.IncludeTracker(Self.Get<TTracker>);
    end);
end;

procedure TCoreInjector._RouteServiceInjector;
begin
  Self.Factory<TRouteService>(
    procedure(Value: TRouteService)
    begin
      Value.IncludeProvider(Self.Get<TRouteProvider>);
    end);
end;

procedure TCoreInjector._TrackeInjector;
begin
  Self.SingletonLazy<TTracker>;
  Self.SingletonLazy<TRouteManager>;
end;

procedure TCoreInjector._ObjectFactoryInjector;
begin
  Self.Singleton<TModernObject>;
end;

procedure TAppInjector.CreateNest4dInjector;
begin
  GAppInjector^.AddInjector(C_NEST4D, TCoreInjector.Create);
  GAppInjector^.AddInstance<TRegister>(TRegister.Create);
end;

procedure TAppInjector.ExtractInjector<T>(const ATag: String);
var
  LKey: String;
begin
  LKey := ATag;
  if LKey = '' then
    LKey := T.ClassName;
  Self.Remove<T>(LKey);
end;

initialization
  New(GAppInjector);
  GAppInjector^ := TAppInjector.Create;
  GAppInjector^.CreateNest4dInjector;

finalization
  if Assigned(GAppInjector) then
  begin
    GetNidus.Finalize;
    GAppInjector^.Free;
    Dispose(GAppInjector);
  end;

end.









