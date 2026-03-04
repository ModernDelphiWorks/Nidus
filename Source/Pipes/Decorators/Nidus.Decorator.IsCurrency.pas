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

unit Nidus.Decorator.IsCurrency;

interface

uses
  SysUtils,
  Nidus.Decorator.IsBase,
  Nidus.Validation.Types;

type
  IscurrencyAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: String = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IscurrencyAttribute }

constructor IscurrencyAttribute.Create(const AMessage: String);
begin
  inherited Create(AMessage);
  FTagName := 'Iscurrency';
end;

function IscurrencyAttribute.Validation: TValidation;
begin
  // TODO: Implementar validacao Iscurrency quando disponivel
  Result := nil;
end;

end.

