// Copyright Joyent, Inc. and other Node contributors.
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to permit
// persons to whom the Software is furnished to do so, subject to the
// following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
// NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.

#ifndef SRC_BASE_OBJECT_INL_H_
#define SRC_BASE_OBJECT_INL_H_

#include "base-object.h"
#include "util.h"
#include "util-inl.h"
#include "v8.h"

#include <assert.h>

namespace node {

inline BaseObject::BaseObject(Environment* env, v8::Local<v8::Object> handle)
    : handle_(env->isolate(), handle),
      env_(env) {
  assert(!handle.IsEmpty());
}


inline BaseObject::~BaseObject() {
  assert(handle_.IsEmpty());
}


inline v8::Persistent<v8::Object>& BaseObject::persistent() {
  return handle_;
}


inline v8::Local<v8::Object> BaseObject::object() {
  return PersistentToLocal(env_->isolate(), handle_);
}


inline Environment* BaseObject::env() const {
  return env_;
}


template <typename Type>
inline void BaseObject::WeakCallback(
    const v8::WeakCallbackData<v8::Object, Type>& data) {
  Type* self = data.GetParameter();
  self->persistent().Reset();
  delete self;
}


template <typename Type>
inline void BaseObject::MakeWeak(Type* ptr) {
  v8::HandleScope scope(env_->isolate());
  v8::Local<v8::Object> handle = object();
  assert(handle->InternalFieldCount() > 0);
  Wrap(handle, ptr);
  handle_.MarkIndependent();
  handle_.SetWeak<Type>(ptr, WeakCallback<Type>);
}


inline void BaseObject::ClearWeak() {
  handle_.ClearWeak();
}

}  // namespace node

#endif  // SRC_BASE_OBJECT_INL_H_
