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


unit Nidus;

interface

uses
  Rtti,
  Types,
  Classes,
  SysUtils,
  StrUtils,
  Generics.Collections,
  Inject.Service,
  ModernSyntax.ResultPair,
  Nidus.Module,
  Nidus.Route.Parse,
  Nidus.Module.Service,
  Nidus.Bind.Service,
  Nidus.Validation.Interfaces,
  Nidus.Route.Handler,
  Nidus.RPC.Interfaces,
  Nidus.RPC.Resource,
  Nidus.Injector,
  Nidus.Exception,
  Nidus.Register,
  Nidus.Request,
  Nidus.Listener;

type
  TNidus = class sealed
  strict private
    class var FListener: TAppListener;
  private
    FAppInjector: PAppInjector;
    FInitialRoutePath: String;
    FAppModule: TModule;
    FRouteParse: TRouteParse;
    FModuleService: TModuleService;
    FBindService: TBindService;
    FModuleStarted: Boolean;
    FRequest: IRouteRequest;
    FGuardCallback: TGuardCallback;
    FRegister: TRegister;
    FRPCProviderServer: IRPCProviderServer;
    procedure _ResolveDisposeRouteModule(const APath: String);
  public
    constructor Create;
    destructor Destroy; override;
    procedure IncludeModuleService(const AService: TModuleService);
    procedure IncludeBindService(const AService: TBindService);
    procedure IncludeRouteParser(const ARouteParse: TRouteParse);
    function Start(const AModule: TModule;
      const AInitialRoutePath: String = '/'): TNidus;
    procedure Finalize;
    procedure DisposeRouteModule(const APath: String);
    procedure RegisterRouteHandler(const ARouteHandler: TRouteHandlerClass);
    procedure Listener(const AMessage: String);
    function UseGuard(const AGuardCallback: TGuardCallback): TNidus;
    function UsePipes(const AValidationPipe: IValidationPipe): TNidus;
    function UseRPC(const ARPCProviderServer: IRPCProviderServer): TNidus;
    class function UseListener(const AListener: TListener): TNidus;
    function PublishRPC(const ARPCName: String; const ARPCClass: TRPCResourceClass): TNidus;
    function LoadRouteModule(const APath: String;
      const AReq: IRouteRequest = nil): TReturnPair;
    function Get<T: class, constructor>(ATag: String = ''): T;
    function GetInterface<I: IInterface>(ATag: String = ''): I;
    function Request: IRouteRequest;
  end;

function GetNidus: TNidus;

implementation

{ TNest4D }

function GetNidus: TNidus;
begin
  Result := GAppInjector^.Get<TNidus>;
end;

constructor TNidus.Create;
begin
  FAppInjector := GAppInjector;
  if not Assigned(FAppInjector) then
    raise EAppInjector.Create;
  FModuleStarted := False;
  FRegister := FAppInjector^.Get<TRegister>;
end;

destructor TNidus.Destroy;
begin
  FAppInjector := nil;
  if Assigned(FBindService) then
    FBindService.Free;
  if Assigned(FModuleService) then
    FModuleService.Free;
  if Assigned(FRouteParse) then
    FRouteParse.Free;
  FModuleStarted := False;
  if Assigned(FRPCProviderServer) then
    FRPCProviderServer.Stop;
  FRegister := nil;
  inherited;
end;

function TNidus.GetInterface<I>(ATag: String = ''): I;
var
  LResult: TResultPair<I, Exception>;
begin
  LResult := FBindService.GetBindInterface<I>(ATag);
  LResult.When(
    procedure (AValue: I)
    begin

    end,
    procedure (AValue: Exception)
    begin
      raise AValue;
    end);
  Result := LResult.ValueSuccess;
end;

function TNidus.Get<T>(ATag: String): T;
var
  LResult: TResultPair<T, Exception>;
begin
  LResult := FBindService.GetBind<T>(ATag);
  LResult.When(
    procedure (AValue: T)
    begin

    end,
    procedure (AValue: Exception)
    begin
      raise AValue;
    end);
  Result := LResult.ValueSuccess;
end;

procedure TNidus.IncludeBindService(const AService: TBindService);
begin
  FBindService := AService;
end;

procedure TNidus.IncludeModuleService(const AService: TModuleService);
begin
  FModuleService := AService;
end;

procedure TNidus.IncludeRouteParser(const ARouteParse: TRouteParse);
begin
  FRouteParse := ARouteParse;
end;

function TNidus.Start(const AModule: TModule;
  const AInitialRoutePath: String): TNidus;
var
  LModule: TClass;
begin
  if FModuleStarted then
    raise EModuleStartedException.CreateFmt('', [AModule.ClassName]);

  FInitialRoutePath := AInitialRoutePath;
  FAppModule := AModule;
  FModuleService.Start(AModule, AInitialRoutePath);
  FModuleStarted := True;
  Result := Self;
  if Assigned(FListener) then
  begin
    FListener.Execute(FormatListenerMessage('[Nest4dStart] Starting Nest4D application...'));
    FListener.Execute(FormatListenerMessage('[InstanceLoader] AppModule dependencies initialized'));
    for LModule in AModule.Imports do
      FListener.Execute(FormatListenerMessage(Format('[InstanceImported] %s dependencies imported', [LModule.ClassName])));
  end;
end;

function TNidus.UseGuard(const AGuardCallback: TGuardCallback): TNidus;
begin
  FGuardCallback := AGuardCallback;
  Result := Self;
end;

class function TNidus.UseListener(const AListener: TListener): TNidus;
begin
  if not Assigned(AListener) then
    Exit;
  GAppInjector^.AddInstance<TAppListener>(TAppListener.Create(AListener));
  FListener := GAppInjector^.Get<TAppListener>;
end;

function TNidus.UsePipes(const AValidationPipe: IValidationPipe): TNidus;
begin
  FRegister.UsePipes(AValidationPipe);
  Result := Self;
end;

function TNidus.UseRPC(const ARPCProviderServer: IRPCProviderServer): TNidus;
begin
  FRPCProviderServer := ARPCProviderServer;
  FRPCProviderServer.Start;
  Result := Self;
end;

function TNidus.LoadRouteModule(const APath: String;
  const AReq: IRouteRequest): TReturnPair;
var
  LRouteHandle: TClass;
  LIsAccessGranted: Boolean;
begin
  FRequest := AReq;
  if Assigned(FGuardCallback) then
  begin
    LIsAccessGranted := FGuardCallback;
    if not LIsAccessGranted then
      raise EUnauthorizedException.Create('');
  end;
  if FRegister.IsValidationPipe then
  begin
    LRouteHandle := FRegister.FindRecord(APath);
    if LRouteHandle <> nil then
    begin
      FRegister.Pipe.Validate(LRouteHandle, FRequest);
      if FRegister.Pipe.IsMessages then
      begin
        Result.Failure(EBadRequestException.Create(FRegister.Pipe.BuildMessages));
        Exit;
      end;
//      Result.Failure(EBadRequestException.Create('Use the "UsePipes" command followed by "TValidationPipe.Create" to enable global validation pipes.'));
//      exit;
    end;
  end;
  Result := FRouteParse.SelectRoute(APath, AReq);
end;

procedure TNidus.Listener(const AMessage: String);
begin
  if Assigned(FListener) then
    FListener.Execute(AMessage);
end;

function TNidus.PublishRPC(const ARPCName: String;
  const ARPCClass: TRPCResourceClass): TNidus;
begin
  if not Assigned(FRPCProviderServer) then
    raise ERPCProviderNotSetException.Create;
  FRPCProviderServer.PublishRPC(ARPCName, ARPCClass);
  Result := Self;
end;

procedure TNidus.RegisterRouteHandler(const ARouteHandler: TRouteHandlerClass);
begin
  FRegister.Add(ARouteHandler);
end;

function TNidus.Request: IRouteRequest;
begin
  Result := FRequest;
end;

procedure TNidus.DisposeRouteModule(const APath: String);
begin
  _ResolveDisposeRouteModule(APath);
end;

procedure TNidus.Finalize;
begin
  // Do not change the order.
  FAppModule.Free;
  FAppInjector^.ExtractInjector<TAppInjector>(C_NEST4D);
end;

procedure TNidus._ResolveDisposeRouteModule(const APath: String);
var
  LRoutes: TStringDynArray;
  LRoute: String;
  LRouteParts: String;
begin
  LRouteParts := '';
  LRoutes := SplitString(APath, '/');
  for LRoute in LRoutes do
  begin
    if (LRoute = '') or (LRoute = '/') then
      Continue;
    LRouteParts := LRouteParts + '/' + LRoute;
    FModuleService.DisposeModule(LRouteParts);
  end;
end;

end.






