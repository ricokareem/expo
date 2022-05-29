// Copyright 2022-present 650 Industries. All rights reserved.

import Darwin

public class AnyTypedArray: AnyArgument {
  let jsTypedArray: JavaScriptTypedArray

  /**
   The length in bytes from the start of the underlying ArrayBuffer.
   Fixed at construction time and thus read-only.
   */
  public lazy var byteLength: Int = jsTypedArray.getProperty("byteLength").getInt()

  /**
   The offset in bytes from the start of the underlying ArrayBuffer.
   Fixed at construction time and thus read-only.
   */
  public lazy var byteOffset: Int = jsTypedArray.getProperty("byteOffset").getInt()

  /**
   Returns the number of elements held in the typed array.
   Fixed at construction time and thus read only.
   */
  public lazy var length: Int = jsTypedArray.getProperty("length").getInt()

  public lazy var rawPointer: UnsafeMutableRawPointer = jsTypedArray.getUnsafeMutableRawPointer()

  /**
   Returns the kind of the typed array, such as `Int8Array` or `Float32Array`.
   */
  public var kind: TypedArrayKind {
    return jsTypedArray.kind
  }

  /**
   Initializes the typed array with the given JS typed array.
   */
  required init(_ jsTypedArray: JavaScriptTypedArray) {
    self.jsTypedArray = jsTypedArray
  }
}

public class TypedArray<ContentType>: AnyTypedArray {
  /**
   The unsafe mutable typed buffer that shares the same memory as the underlying JavaScript `ArrayBuffer`.
   */
  lazy var buffer = UnsafeMutableBufferPointer<ContentType>(start: pointer, count: length)

  /**
   The unsafe mutable typed pointer to the start of the array buffer.
   */
  lazy var pointer = rawPointer.bindMemory(to: ContentType.self, capacity: length)

  public subscript(index: Int) -> ContentType {
    get {
      return buffer[index]
    }
    set {
      buffer[index] = newValue
    }
  }

  subscript(range: Range<Int>) -> [ContentType] {
    get {
      return Array(buffer[range])
    }
    set {
      var newValues = newValue
      newValues.withUnsafeMutableBufferPointer { newValuesBuffer in
        buffer[range] = newValuesBuffer[0..<(range.upperBound - range.lowerBound)]
      }
    }
  }

  subscript(range: ClosedRange<Int>) -> [ContentType] {
    get {
      return Array(buffer[range])
    }
    set {
      var newValues = newValue
      newValues.withUnsafeMutableBufferPointer { newValuesBuffer in
        buffer[range] = newValuesBuffer[0...(range.upperBound - range.lowerBound)]
      }
    }
  }
}

// MARK: - Concrete classes

/**
 Native equivalent of `Int8Array` in JavaScript, an array of two's-complement 8-bit signed integers.
 */
public final class Int8Array: TypedArray<Int8> {}

/**
 Native equivalent of `Int16Array` in JavaScript, an array of two's-complement 16-bit signed integers.
 */
public final class Int16Array: TypedArray<Int16> {}

/**
 Native equivalent of `Int32Array` in JavaScript, an array of two's-complement 32-bit signed integers.
 */
public final class Int32Array: TypedArray<Int32> {}

/**
 Native equivalent of `Uint8Array` in JavaScript, an array of 8-bit unsigned integers.
 */
public final class Uint8Array: TypedArray<UInt8> {}

/**
 Native equivalent of `Uint8ClampedArray` in JavaScript, an array of 8-bit unsigned integers clamped to 0-255.
 */
public final class Uint8ClampedArray: TypedArray<UInt8> {}

/**
 Native equivalent of `Uint16Array` in JavaScript, an array of 16-bit unsigned integers.
 */
public final class Uint16Array: TypedArray<UInt16> {}

/**
 Native equivalent of `Uint32Array` in JavaScript, an array of 32-bit unsigned integers.
 */
public final class Uint32Array: TypedArray<UInt32> {}

/**
 Native equivalent of `Float32Array` in JavaScript, an array of 32-bit floating point numbers.
 */
public final class Float32Array: TypedArray<Float32> {}

/**
 Native equivalent of `Float64Array` in JavaScript, an array of 64-bit floating point numbers.
 */
public final class Float64Array: TypedArray<Float64> {}

/**
 Native equivalent of `BigInt64Array` in JavaScript, an array of 64-bit signed integers.
 */
public final class BigInt64Array: TypedArray<Int64> {}

/**
 Native equivalent of `BigUint64Array` in JavaScript, an array of 64-bit unsigned integers.
 */
public final class BigUint64Array: TypedArray<UInt64> {}
