//===-- TestInterfaces.td - Test dialect interfaces --------*- tablegen -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_TEST_DIALECT_TEST_INTERFACES
#define MLIR_TEST_DIALECT_TEST_INTERFACES

include "mlir/IR/OpBase.td"
include "mlir/Interfaces/SideEffectInterfaceBase.td"

// A type interface used to test the ODS generation of type interfaces.
def TestTypeInterface : TypeInterface<"TestTypeInterface"> {
  let cppNamespace = "::mlir::test";
  let methods = [
    InterfaceMethod<"Prints the type name.",
      "void", "printTypeA", (ins "Location":$loc), [{
        emitRemark(loc) << $_type << " - TestA";
      }]
    >,
    InterfaceMethod<"Prints the type name.",
      "void", "printTypeB", (ins "Location":$loc),
      [{}], /*defaultImplementation=*/[{
        emitRemark(loc) << $_type << " - TestB";
      }]
    >,
    InterfaceMethod<"Prints the type name.",
      "void", "printTypeC", (ins "Location":$loc)
    >,
    // It should be possible to use the interface type name as result type
    // as well as in the implementation.
    InterfaceMethod<"Prints the type name and returns the type as interface.",
      "TestTypeInterface", "printTypeRet", (ins "Location":$loc),
      [{}], /*defaultImplementation=*/[{
        emitRemark(loc) << $_type << " - TestRet";
        return $_type;
      }]
    >,
  ];
  let extraClassDeclaration = [{
    /// Prints the type name.
    void printTypeD(Location loc) const {
      emitRemark(loc) << *this << " - TestD";
    }
  }];
  let extraTraitClassDeclaration = [{
    /// Prints the type name.
    void printTypeE(Location loc) const {
      emitRemark(loc) << $_type << " - TestE";
    }
  }];
}

def TestExternalTypeInterface : TypeInterface<"TestExternalTypeInterface"> {
  let cppNamespace = "::mlir";
  let methods = [
    InterfaceMethod<"Returns the bitwidth of the type plus 'arg'.",
      "unsigned", "getBitwidthPlusArg", (ins "unsigned":$arg)>,
    StaticInterfaceMethod<"Returns some value plus 'arg'.",
      "unsigned", "staticGetSomeValuePlusArg", (ins "unsigned":$arg)>,
    InterfaceMethod<"Returns the argument doubled.",
      "unsigned", "getBitwidthPlusDoubleArgument", (ins "unsigned":$arg), "",
      "return $_type.getIntOrFloatBitWidth() + 2 * arg;">,
    StaticInterfaceMethod<"Returns the argument.",
      "unsigned", "staticGetArgument", (ins "unsigned":$arg), "",
      "return arg;">,
  ];
}

def TestExternalFallbackTypeInterface
    : TypeInterface<"TestExternalFallbackTypeInterface"> {
  let cppNamespace = "::mlir";
  let methods = [
    InterfaceMethod<"Returns the bitwidth of the given integer type.",
      "unsigned", "getBitwidth", (ins), "", "return $_type.getWidth();">,
  ];
}

def TestExternalAttrInterface : AttrInterface<"TestExternalAttrInterface"> {
  let cppNamespace = "::mlir";
  let methods = [
    InterfaceMethod<"Gets the dialect pointer.", "const ::mlir::Dialect *",
      "getDialectPtr">,
    StaticInterfaceMethod<"Returns some number.", "int", "getSomeNumber">,
  ];
}

def TestEffectOpInterface
    : EffectOpInterfaceBase<"TestEffectOpInterface",
                            "::mlir::TestEffects::Effect"> {
  let cppNamespace = "::mlir";
}

class TestEffect<string effectName>
    : SideEffect<TestEffectOpInterface, effectName, DefaultResource>;

class TestEffects<list<TestEffect> effects = []>
   : SideEffectsTraitBase<TestEffectOpInterface, effects>;

def TestConcreteEffect : TestEffect<"TestEffects::Concrete">;

#endif // MLIR_TEST_DIALECT_TEST_INTERFACES
