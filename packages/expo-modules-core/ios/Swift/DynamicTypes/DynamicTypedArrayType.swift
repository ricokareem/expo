// Copyright 2022-present 650 Industries. All rights reserved.

internal struct DynamicTypedArrayType: AnyDynamicType {
  let innerType: AnyTypedArray.Type

  func wraps<InnerType>(_ type: InnerType.Type) -> Bool {
    return innerType == InnerType.self
  }

  func equals(_ type: AnyDynamicType) -> Bool {
    if let typedArrayType = type as? Self {
      return typedArrayType.innerType == innerType
    }
    return false
  }

  func cast<ValueType>(_ value: ValueType) throws -> Any {
    if let jsTypedArray = (value as? JavaScriptValue)?.getTypedArray() {
      return innerType.init(jsTypedArray)
    }
    throw NonTypedArrayException((value: value, type: innerType))
  }

  var description: String {
    return String(describing: innerType)
  }
}

internal final class NonTypedArrayException: GenericException<(value: Any, type: AnyTypedArray.Type)> {
  override var reason: String {
    "Given argument '\(param.value)' is not an instance of '\(param.type)'"
  }
}
