/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <butter/map.h>
#include <butter/small_vector.h>
#include <ABI45_0_0React/ABI45_0_0renderer/core/Props.h>
#include <ABI45_0_0React/ABI45_0_0renderer/core/PropsParserContext.h>
#include <ABI45_0_0React/ABI45_0_0renderer/core/RawProps.h>
#include <ABI45_0_0React/ABI45_0_0renderer/core/RawPropsKey.h>
#include <ABI45_0_0React/ABI45_0_0renderer/core/RawPropsKeyMap.h>
#include <ABI45_0_0React/ABI45_0_0renderer/core/RawPropsPrimitives.h>
#include <ABI45_0_0React/ABI45_0_0renderer/core/RawValue.h>

namespace ABI45_0_0facebook {
namespace ABI45_0_0React {

/*
 * Specialized (to a particular type of Props) parser that provides the most
 * efficient access to `RawProps` content.
 */
class RawPropsParser final {
 public:
  /*
   * Default constructor.
   * To be used by `ConcreteComponentDescriptor` only.
   */
  RawPropsParser() = default;

  /*
   * To be used by `ConcreteComponentDescriptor` only.
   */
  template <typename PropsT>
  void prepare() noexcept {
    static_assert(
        std::is_base_of<Props, PropsT>::value,
        "PropsT must be a descendant of Props");
    RawProps emptyRawProps{};

    // Create a stub parser context.
    // Since this prepares the parser by passing in
    // empty props, no prop parsers should actually reference the
    // ContextContainer or SurfaceId here.
    ContextContainer contextContainer{};
    PropsParserContext parserContext{-1, contextContainer};

    emptyRawProps.parse(*this, parserContext);
    PropsT(parserContext, {}, emptyRawProps);
    postPrepare();
  }

 private:
  friend class ComponentDescriptor;
  template <class ShadowNodeT>
  friend class ConcreteComponentDescriptor;
  friend class RawProps;

  /*
   * To be used by `RawProps` only.
   */
  void preparse(RawProps const &rawProps) const noexcept;

  /*
   * Non-generic part of `prepare`.
   */
  void postPrepare() noexcept;

  /*
   * To be used by `RawProps` only.
   */
  RawValue const *at(RawProps const &rawProps, RawPropsKey const &key)
      const noexcept;

  mutable butter::small_vector<RawPropsKey, kNumberOfPropsPerComponentSoftCap>
      keys_{};
  mutable RawPropsKeyMap nameToIndex_{};
  mutable int size_{0};
  mutable bool ready_{false};
};

} // namespace ABI45_0_0React
} // namespace ABI45_0_0facebook
