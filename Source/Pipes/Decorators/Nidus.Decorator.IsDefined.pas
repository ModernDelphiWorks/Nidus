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

unit Nidus.Decorator.IsDefined;

interface

uses
  SysUtils,
  Nidus.Decorator.IsBase,
  Nidus.Validation.Types;

type
  IsDefinedAttribute = class(IsAttribute)
  public
    constructor Create(const AMessage: String = ''); override;
    function Validation: TValidation; override;
  end;

implementation

{ IsDefinedAttribute }

constructor IsDefinedAttribute.Create(const AMessage: String);
begin
  inherited Create(AMessage);
  FTagName := 'IsDefined';
end;

function IsDefinedAttribute.Validation: TValidation;
begin
  // TODO: Implementar validação IsDefined quando disponível
  Result := nil;
end;

end.



