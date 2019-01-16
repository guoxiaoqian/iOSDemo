// Protocol Buffers - Google's data interchange format
// Copyright 2008 Google Inc.  All rights reserved.
// http://code.google.com/p/protobuf/
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
//     * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
// copyright notice, this list of conditions and the following disclaimer
// in the documentation and/or other materials provided with the
// distribution.
//     * Neither the name of Google Inc. nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// Authors: wink@google.com (Wink Saville),
//          kenton@google.com (Kenton Varda)
//  Based on original Protocol Buffers design by
//  Sanjay Ghemawat, Jeff Dean, and others.

#include <google/protobuf/message_lite.h>
#include <string>
#include <google/protobuf/stubs/common.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/io/zero_copy_stream_impl_lite.h>
#include <google/protobuf/stubs/stl_util.h>
#include <google/protobuf/wire_format_lite.h>
#include <google/protobuf/generated_message_util.h>
#include <google/protobuf/wire_format_lite_inl.h>

namespace google {
namespace protobuf {

MessageLite::~MessageLite() {}

string MessageLite::InitializationErrorString() const {
  return "(cannot determine missing fields for lite message)";
}

namespace {

// When serializing, we first compute the byte size, then serialize the message.
// If serialization produces a different number of bytes than expected, we
// call this function, which crashes.  The problem could be due to a bug in the
// protobuf implementation but is more likely caused by concurrent modification
// of the message.  This function attempts to distinguish between the two and
// provide a useful error message.
void ByteSizeConsistencyError(int byte_size_before_serialization,
                              int byte_size_after_serialization,
                              int bytes_produced_by_serialization) {
  GOOGLE_CHECK_EQ(byte_size_before_serialization, byte_size_after_serialization)
      << "Protocol message was modified concurrently during serialization.";
  GOOGLE_CHECK_EQ(bytes_produced_by_serialization, byte_size_before_serialization)
      << "Byte size calculation and serialization were inconsistent.  This "
         "may indicate a bug in protocol buffers or it may be caused by "
         "concurrent modification of the message.";
  GOOGLE_LOG(FATAL) << "This shouldn't be called if all the sizes are equal.";
}

string InitializationErrorMessage(const char* action,
                                  const MessageLite& message) {
  // Note:  We want to avoid depending on strutil in the lite library, otherwise
  //   we'd use:
  //
  // return strings::Substitute(
  //   "Can't $0 message of type \"$1\" because it is missing required "
  //   "fields: $2",
  //   action, message.GetTypeName(),
  //   message.InitializationErrorString());

  string result;
  result += "Can't ";
  result += action;
  result += " message of type \"";
  result += message.GetTypeName();
  result += "\" because it is missing required fields: ";
  result += message.InitializationErrorString();
  return result;
}

// Several of the Parse methods below just do one thing and then call another
// method.  In a naive implementation, we might have ParseFromString() call
// ParseFromArray() which would call ParseFromZeroCopyStream() which would call
// ParseFromCodedStream() which would call MergeFromCodedStream() which would
// call MergePartialFromCodedStream().  However, when parsing very small
// messages, every function call introduces significant overhead.  To avoid
// this without reproducing code, we use these forced-inline helpers.
//
// Note:  GCC only allows GOOGLE_ATTRIBUTE_ALWAYS_INLINE on declarations, not
//   definitions.
inline bool InlineMergeFromCodedStream(io::CodedInputStream* input,
                                       MessageLite* message)
                                       GOOGLE_ATTRIBUTE_ALWAYS_INLINE;
inline bool InlineParseFromCodedStream(io::CodedInputStream* input,
                                       MessageLite* message)
                                       GOOGLE_ATTRIBUTE_ALWAYS_INLINE;
inline bool InlineParsePartialFromCodedStream(io::CodedInputStream* input,
                                              MessageLite* message)
                                              GOOGLE_ATTRIBUTE_ALWAYS_INLINE;
inline bool InlineParseFromArray(const void* data, int size,
                                 MessageLite* message)
                                 GOOGLE_ATTRIBUTE_ALWAYS_INLINE;
inline bool InlineParsePartialFromArray(const void* data, int size,
                                        MessageLite* message)
                                        GOOGLE_ATTRIBUTE_ALWAYS_INLINE;

bool InlineMergeFromCodedStream(io::CodedInputStream* input,
                                MessageLite* message) {
    if (!message->MergePartialFromCodedStream(input)) {
        return false;
    }
  if (!message->IsInitialized()) {
    GOOGLE_LOG(ERROR) << InitializationErrorMessage("parse", *message);
    return false;
  }
  return true;
}

bool InlineParseFromCodedStream(io::CodedInputStream* input,
                                MessageLite* message) {
  message->Clear();
  return InlineMergeFromCodedStream(input, message);
}

bool InlineParsePartialFromCodedStream(io::CodedInputStream* input,
                                       MessageLite* message) {
  message->Clear();
  return message->MergePartialFromCodedStream(input);
}

bool InlineParseFromArray(const void* data, int size, MessageLite* message) {
  io::CodedInputStream input(reinterpret_cast<const uint8*>(data), size);
  return InlineParseFromCodedStream(&input, message) &&
         input.ConsumedEntireMessage();
}

bool InlineParsePartialFromArray(const void* data, int size,
                                 MessageLite* message) {
  io::CodedInputStream input(reinterpret_cast<const uint8*>(data), size);
  return InlineParsePartialFromCodedStream(&input, message) &&
         input.ConsumedEntireMessage();
}

}  // namespace

bool MessageLite::MergeFromCodedStream(io::CodedInputStream* input) {
  return InlineMergeFromCodedStream(input, this);
}

bool MessageLite::ParseFromCodedStream(io::CodedInputStream* input) {
  return InlineParseFromCodedStream(input, this);
}

bool MessageLite::ParsePartialFromCodedStream(io::CodedInputStream* input) {
  return InlineParsePartialFromCodedStream(input, this);
}

bool MessageLite::ParseFromZeroCopyStream(io::ZeroCopyInputStream* input) {
  io::CodedInputStream decoder(input);
  return ParseFromCodedStream(&decoder) && decoder.ConsumedEntireMessage();
}

bool MessageLite::ParsePartialFromZeroCopyStream(
    io::ZeroCopyInputStream* input) {
  io::CodedInputStream decoder(input);
  return ParsePartialFromCodedStream(&decoder) &&
         decoder.ConsumedEntireMessage();
}

bool MessageLite::ParseFromBoundedZeroCopyStream(
    io::ZeroCopyInputStream* input, int size) {
  io::CodedInputStream decoder(input);
  decoder.PushLimit(size);
  return ParseFromCodedStream(&decoder) &&
         decoder.ConsumedEntireMessage() &&
         decoder.BytesUntilLimit() == 0;
}

bool MessageLite::ParsePartialFromBoundedZeroCopyStream(
    io::ZeroCopyInputStream* input, int size) {
  io::CodedInputStream decoder(input);
  decoder.PushLimit(size);
  return ParsePartialFromCodedStream(&decoder) &&
         decoder.ConsumedEntireMessage() &&
         decoder.BytesUntilLimit() == 0;
}

bool MessageLite::ParseFromString(const string& data) {
  return InlineParseFromArray(data.data(), data.size(), this);
}

bool MessageLite::ParsePartialFromString(const string& data) {
  return InlineParsePartialFromArray(data.data(), data.size(), this);
}

bool MessageLite::ParseFromArray(const void* data, int size) {
  return InlineParseFromArray(data, size, this);
}

bool MessageLite::ParsePartialFromArray(const void* data, int size) {
  return InlineParsePartialFromArray(data, size, this);
}


// ===================================================================

uint8* MessageLite::SerializeWithCachedSizesToArray(uint8* target) const {
  // We only optimize this when using optimize_for = SPEED.  In other cases
  // we just use the CodedOutputStream path.
  int size = GetCachedSize();
  io::ArrayOutputStream out(target, size);
  io::CodedOutputStream coded_out(&out);
  SerializeWithCachedSizes(&coded_out);
  GOOGLE_CHECK(!coded_out.HadError());
  return target + size;
}

bool MessageLite::SerializeToCodedStream(io::CodedOutputStream* output) const {
  GOOGLE_DCHECK(IsInitialized()) << InitializationErrorMessage("serialize", *this);
  return SerializePartialToCodedStream(output);
}

bool MessageLite::SerializePartialToCodedStream(
    io::CodedOutputStream* output) const {
  const int size = ByteSize();  // Force size to be cached.
  uint8* buffer = output->GetDirectBufferForNBytesAndAdvance(size);
  if (buffer != NULL) {
    uint8* end = SerializeWithCachedSizesToArray(buffer);
    if (end - buffer != size) {
      ByteSizeConsistencyError(size, ByteSize(), end - buffer);
    }
    return true;
  } else {
    int original_byte_count = output->ByteCount();
    SerializeWithCachedSizes(output);
    if (output->HadError()) {
      return false;
    }
    int final_byte_count = output->ByteCount();

    if (final_byte_count - original_byte_count != size) {
      ByteSizeConsistencyError(size, ByteSize(),
                               final_byte_count - original_byte_count);
    }

    return true;
  }
}

bool MessageLite::SerializeToZeroCopyStream(
    io::ZeroCopyOutputStream* output) const {
  io::CodedOutputStream encoder(output);
  return SerializeToCodedStream(&encoder);
}

bool MessageLite::SerializePartialToZeroCopyStream(
    io::ZeroCopyOutputStream* output) const {
  io::CodedOutputStream encoder(output);
  return SerializePartialToCodedStream(&encoder);
}

bool MessageLite::AppendToString(string* output) const {
  GOOGLE_DCHECK(IsInitialized()) << InitializationErrorMessage("serialize", *this);
  return AppendPartialToString(output);
}

bool MessageLite::AppendPartialToString(string* output) const {
  int old_size = output->size();
  int byte_size = ByteSize();
  STLStringResizeUninitialized(output, old_size + byte_size);
  uint8* start = reinterpret_cast<uint8*>(string_as_array(output) + old_size);
  uint8* end = SerializeWithCachedSizesToArray(start);
  if (end - start != byte_size) {
    ByteSizeConsistencyError(byte_size, ByteSize(), end - start);
  }
  return true;
}

bool MessageLite::SerializeToString(string* output) const {
  output->clear();
  return AppendToString(output);
}

bool MessageLite::SerializePartialToString(string* output) const {
  output->clear();
  return AppendPartialToString(output);
}

bool MessageLite::SerializeToArray(void* data, int size) const {
  GOOGLE_DCHECK(IsInitialized()) << InitializationErrorMessage("serialize", *this);
  return SerializePartialToArray(data, size);
}

bool MessageLite::SerializePartialToArray(void* data, int size) const {
  int byte_size = ByteSize();
  if (size < byte_size) return false;
  uint8* start = reinterpret_cast<uint8*>(data);
  uint8* end = SerializeWithCachedSizesToArray(start);
  if (end - start != byte_size) {
    ByteSizeConsistencyError(byte_size, ByteSize(), end - start);
  }
  return true;
}

string MessageLite::SerializeAsString() const {
  // If the compiler implements the (Named) Return Value Optimization,
  // the local variable 'result' will not actually reside on the stack
  // of this function, but will be overlaid with the object that the
  // caller supplied for the return value to be constructed in.
  string output;
  if (!AppendToString(&output))
    output.clear();
  return output;
}

string MessageLite::SerializePartialAsString() const {
  string output;
  if (!AppendPartialToString(&output))
    output.clear();
  return output;
}

////////////////////////////////////////////////
// Ruifan Yuan PB Optimization
const struct FieldInfo* MessageLite::GetFieldInfoArray(int& count) const{
    count = 0;
    return NULL;
}

void MessageLite::SerializeWithCachedSizes(io::CodedOutputStream* output) const{
    
    int count = 0;
    const google::protobuf::FieldInfo* infoArray = GetFieldInfoArray(count);
    
    
    for (int infoIndex = 0; infoIndex < count; ++infoIndex) {
        const google::protobuf::FieldInfo& info = infoArray[infoIndex];
        
        const void* ptr = reinterpret_cast<const unsigned char*>(this) + info.offset;
        
        switch (info.type) {
            case ::google::protobuf::internal::WireFormatLite::TYPE_DOUBLE:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< double >* repeatedField = (::google::protobuf::RepeatedField< double >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteDouble(
                                                                                  info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteDouble(info.fieldNumber, *(double*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FLOAT:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< float >* repeatedField = (::google::protobuf::RepeatedField< float >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteFloat(
                                                                                  info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteFloat(info.fieldNumber, *(float*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_INT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteInt64(
                                                                                 info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteInt64(info.fieldNumber, *(google::protobuf::int64*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_UINT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint64 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteUInt64(
                                                                                 info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteUInt64(info.fieldNumber, *(google::protobuf::uint64*)ptr, output);
                    }
                }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_INT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteInt32(
                                                                                 info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        google::protobuf::internal::WireFormatLite::WriteInt32(info.fieldNumber, *(google::protobuf::int32*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FIXED64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint64 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteFixed64(
                                                                                 info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        google::protobuf::internal::WireFormatLite::WriteFixed64(info.fieldNumber, *(google::protobuf::uint64*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FIXED32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint32 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteFixed32(
                                                                                   info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        google::protobuf::internal::WireFormatLite::WriteFixed32(info.fieldNumber, *(google::protobuf::uint32*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_BOOL:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< bool >* repeatedField = (::google::protobuf::RepeatedField< bool >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteBool(
                                                                                   info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        google::protobuf::internal::WireFormatLite::WriteBool(info.fieldNumber, *(bool*)ptr, output);
                    }
                }
            }
                break;
                
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_STRING:{
                if(info.repeat){
                    ::google::protobuf::RepeatedPtrField< ::std::string>* repeatedField = (::google::protobuf::RepeatedPtrField< ::std::string>*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteString(
                                                                                   info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteString(info.fieldNumber, **(std::string**)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_MESSAGE:{
                if(info.repeat){
                    internal::RepeatedPtrFieldBase* p = (internal::RepeatedPtrFieldBase*)ptr;
                    
                    for (int i = 0; i < p->size(); ++i) {
                        ::google::protobuf::internal::WireFormatLite::WriteMessage(info.fieldNumber, *(google::protobuf::MessageLite*)p->GetGeneric(i), output);
                    }
                    
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteMessage(info.fieldNumber, **(google::protobuf::MessageLite**)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_BYTES:{
                if(info.repeat){
                    ::google::protobuf::RepeatedPtrField< ::std::string>* repeatedField = (::google::protobuf::RepeatedPtrField< ::std::string>*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteBytes(
                                                                                  info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteBytes(info.fieldNumber, **(std::string**)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_UINT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint32 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteInt32(
                                                                                 info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteUInt32(info.fieldNumber, *(google::protobuf::uint32*)ptr, output);
                    }
                }
            }
                break;
                
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_ENUM:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField<int>* repeatedField = (::google::protobuf::RepeatedField<int>*)ptr;
                    
                    for (int i = 0; i < repeatedField->size(); ++i) {
                        ::google::protobuf::internal::WireFormatLite::WriteEnum(info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteEnum(
                                                                                info.fieldNumber, *(int*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteSFixed32(
                                                                                 info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteSFixed32(info.fieldNumber, *(google::protobuf::int32*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteSFixed64(
                                                                                    info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteSFixed64(info.fieldNumber, *(google::protobuf::int64*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SINT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteSInt32(
                                                                                    info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteSInt32(info.fieldNumber, *(google::protobuf::int32*)ptr, output);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SINT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    for (int i = 0; i < repeatedField->size(); i++) {
                        ::google::protobuf::internal::WireFormatLite::WriteSInt64(
                                                                                    info.fieldNumber, repeatedField->Get(i), output);
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        ::google::protobuf::internal::WireFormatLite::WriteSInt64(info.fieldNumber, *(google::protobuf::int64*)ptr, output);
                    }
                }
            }
                break;
                
            default:
                // TODO: log something here
                assert(0);
                break;
            }
        }
    }
}
int MessageLite::ByteSize() const {
    ////////////////////////////////////////////////////////////////
    int count = 0;
    const google::protobuf::FieldInfo* infoArray = GetFieldInfoArray(count);
    
    int size = 0;
    
    for (int infoIndex = 0; infoIndex < count; ++infoIndex) {
        const google::protobuf::FieldInfo& info = infoArray[infoIndex];
        
        int tag_size = ::google::protobuf::internal::WireFormatLite::TagSize(info.fieldNumber, (::google::protobuf::internal::WireFormatLite::FieldType)info.type);
        const void* ptr = reinterpret_cast<const unsigned char*>(this) + info.offset;
        
        switch (info.type) {
            case ::google::protobuf::internal::WireFormatLite::TYPE_DOUBLE:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< double >* repeatedField = (::google::protobuf::RepeatedField< double >*)ptr;
                    
                    int data_size = 8 * repeatedField->size();
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
        
                        size += tag_size + 8;
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FLOAT:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< float >* repeatedField = (::google::protobuf::RepeatedField< float >*)ptr;
                    
                    int data_size = 4 * repeatedField->size();
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
        
                        size += tag_size + 4;
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_INT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    
                    int data_size = 0;
                    
                    for(int i = 0; i < repeatedField->size(); ++i){
                        data_size += ::google::protobuf::internal::WireFormatLite::
                        Int64Size(repeatedField->Get(i));
                    }
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + ::google::protobuf::internal::WireFormatLite::Int64Size(*(google::protobuf::int64*)ptr);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_UINT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint64 >*)ptr;
                    
                    int data_size = 0;
                    
                    for(int i = 0; i < repeatedField->size(); ++i){
                        data_size += ::google::protobuf::internal::WireFormatLite::
                        UInt64Size(repeatedField->Get(i));
                    }
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + ::google::protobuf::internal::WireFormatLite::UInt64Size(*(google::protobuf::uint64*)ptr);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_INT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    
                    int data_size = 0;
                    
                    for(int i = 0; i < repeatedField->size(); ++i){
                        data_size += ::google::protobuf::internal::WireFormatLite::
                        Int32Size(repeatedField->Get(i));
                    }
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + ::google::protobuf::internal::WireFormatLite::Int32Size(*(google::protobuf::int32*)ptr);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FIXED64:{

                
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint64 >*)ptr;
                    
                    int data_size = 8 * repeatedField->size();
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size +  8;
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FIXED32:{

                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint32 >*)ptr;
                    
                    int data_size = 4 * repeatedField->size();
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size +  4;
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_BOOL:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< bool >* repeatedField = (::google::protobuf::RepeatedField< bool >*)ptr;
                    
                    int data_size = 1 * repeatedField->size();
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + 1;
                    }
                }
            }
                break;
                
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_STRING:{
                if(info.repeat){
                    ::google::protobuf::RepeatedPtrField< ::std::string>* repeatedField = (::google::protobuf::RepeatedPtrField< ::std::string>*)ptr;
                    size += tag_size * repeatedField->size();
                    
                    for (int i = 0; i < repeatedField->size(); i++) {
                        size += ::google::protobuf::internal::WireFormatLite::StringSize(repeatedField->Get(i));
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + ::google::protobuf::internal::WireFormatLite::StringSize(**(google::protobuf::string**)ptr);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_MESSAGE:{
                if(info.repeat){
                    internal::RepeatedPtrFieldBase* p = (internal::RepeatedPtrFieldBase*)ptr;
                    size += tag_size * p->size();
                    for (int i = 0; i < p->size(); ++i) {
                        size += 
                        ::google::protobuf::internal::WireFormatLite::MessageSize(*(google::protobuf::MessageLite*)
                                                                                  p->GetGeneric(i));
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size +
                        ::google::protobuf::internal::WireFormatLite::MessageSize(**(google::protobuf::MessageLite**)ptr);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_BYTES:{
                if(info.repeat){
                    ::google::protobuf::RepeatedPtrField< ::std::string>* repeatedField = (::google::protobuf::RepeatedPtrField< ::std::string>*)ptr;
                    
                    size += tag_size * repeatedField->size();
                    for (int i = 0; i < repeatedField->size(); i++) {
                        size += ::google::protobuf::internal::WireFormatLite::BytesSize(repeatedField->Get(i));
                    }
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size +
                        ::google::protobuf::internal::WireFormatLite::BytesSize(**(google::protobuf::string**)ptr);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_UINT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint32 >*)ptr;
                    
                    int data_size = 0;
                    
                    for(int i = 0; i < repeatedField->size(); ++i){
                        data_size += ::google::protobuf::internal::WireFormatLite::
                        UInt32Size(repeatedField->Get(i));
                    }
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + ::google::protobuf::internal::WireFormatLite::UInt32Size(*(google::protobuf::uint32*)ptr);
                    }
                }
            }
                break;
                
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_ENUM:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< int >* repeatedField = (::google::protobuf::RepeatedField< int >*)ptr;
                    
                    int data_size = 0;
                    
                    for(int i = 0; i < repeatedField->size(); ++i){
                        data_size += ::google::protobuf::internal::WireFormatLite::
                        EnumSize(repeatedField->Get(i));
                    }
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + ::google::protobuf::internal::WireFormatLite::EnumSize(*(int*)ptr);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    
                    int data_size = 4 * repeatedField->size();
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + 4;
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    
                    int data_size = 8 * repeatedField->size();
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + 8;
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SINT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    
                    int data_size = 0;
                    for (int i = 0; i < repeatedField->size(); ++i) {
                        data_size += ::google::protobuf::internal::WireFormatLite::SInt32Size(repeatedField->Get(i));
                    }
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + ::google::protobuf::internal::WireFormatLite::SInt32Size(*(google::protobuf::int32*)ptr);
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SINT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    
                    int data_size = 0;
                    for (int i = 0; i < repeatedField->size(); ++i) {
                        data_size += ::google::protobuf::internal::WireFormatLite::SInt64Size(repeatedField->Get(i));
                    }
                    
                    size += tag_size * repeatedField->size() + data_size;
                }else{
                    if(HasField(info.fieldNumber)){
                        size += tag_size + ::google::protobuf::internal::WireFormatLite::SInt64Size(*(google::protobuf::int64*)ptr);
                    }
                }
            }
                break;
                
            default:
                // TODO: log something here
                break;
        }
    }
    GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
    _cached_size_ = size;
    GOOGLE_SAFE_CONCURRENT_WRITES_END();
    return size;
}
    
static bool is_enum_valid(int){
    return true;
}
bool MessageLite::MergePartialFromCodedStream(
                                                ::google::protobuf::io::CodedInputStream* input) {
    const google::protobuf::FieldInfo* infoArray = NULL;
    const google::protobuf::FieldInfo* entry = NULL;
    int tagFieldNumber;
    
#define DO_(EXPRESSION) if (!(EXPRESSION)) goto FAIL_LOGIC
    ::google::protobuf::uint32 tag;
    while ((tag = input->ReadTag()) != 0) {
        /////////////////////////////////////////////////////////////////////////
        // find an entry of the FieldInfo
        tagFieldNumber = ::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag);
        
        int infoCount = 0;
        infoArray = GetFieldInfoArray(infoCount);
        entry = NULL;
        for (int infoIndex = 0; infoIndex < infoCount; ++infoIndex) {
            if(tagFieldNumber == infoArray[infoIndex].fieldNumber){
                entry = &infoArray[infoIndex];
                break;
            }
        }
        ::google::protobuf::internal::WireFormatLite::WireType parsedWireType = ::google::protobuf::internal::WireFormatLite::GetTagWireType(tag);
        
        if(entry){
            ::google::protobuf::internal::WireFormatLite::WireType entryWireType = ::google::protobuf::internal::WireFormatLite::WireTypeForFieldType((google::protobuf::internal::WireFormatLite::FieldType)entry->type);
            
            if (true || parsedWireType == entryWireType) { // no needed
                void* ptr = reinterpret_cast<unsigned char*>(this) + entry->offset;
                uint theTag = google::protobuf::internal::WireFormatLite::MakeTag(entry->fieldNumber,entryWireType);
                
                switch (entry->type) {
                    case ::google::protobuf::internal::WireFormatLite::TYPE_DOUBLE:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< double >* repeatedField = (::google::protobuf::RepeatedField< double >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_FIXED64) {
                            parse_var_double:
                                
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     double, ::google::protobuf::internal::WireFormatLite::TYPE_DOUBLE>(
                                                                                                        1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     double, ::google::protobuf::internal::WireFormatLite::TYPE_DOUBLE>(
                                                                                                        input, repeatedField)));
                            }else{
                                // TODO: goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 double, ::google::protobuf::internal::WireFormatLite::TYPE_DOUBLE>(input, (double*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_FLOAT:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< float >* repeatedField = (::google::protobuf::RepeatedField< float >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_FIXED32) {
                            parse_var_float:
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     float, ::google::protobuf::internal::WireFormatLite::TYPE_FLOAT>(
                                                                                                      1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     float, ::google::protobuf::internal::WireFormatLite::TYPE_FLOAT>(
                                                                                                      input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 float, ::google::protobuf::internal::WireFormatLite::TYPE_FLOAT>(input, (float*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_INT64:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::int64 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
                            parse_var_int64:
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_INT64>(
                                                                                                                          1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_INT64>(
                                                                                                                          input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_INT64>(input, (::google::protobuf::int64*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_UINT64:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::uint64 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::uint64 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
                            parse_var_uint64:
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::uint64, ::google::protobuf::internal::WireFormatLite::TYPE_UINT64>(
                                                                                                                          1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::uint64, ::google::protobuf::internal::WireFormatLite::TYPE_UINT64>(
                                                                                                                          input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::uint64, ::google::protobuf::internal::WireFormatLite::TYPE_UINT64>(input, (::google::protobuf::uint64*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_INT32:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::int32 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {

                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_INT32>(
                                                                                                                            1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_INT32>(
                                                                                                                            input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_INT32>(input, (::google::protobuf::int32*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_FIXED64:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::uint64 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::uint64 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_FIXED64) {

                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::uint64, ::google::protobuf::internal::WireFormatLite::TYPE_FIXED64>(
                                                                                                                            1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::uint64, ::google::protobuf::internal::WireFormatLite::TYPE_FIXED64>(
                                                                                                                            input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::uint64, ::google::protobuf::internal::WireFormatLite::TYPE_FIXED64>(input, (::google::protobuf::uint64*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_FIXED32:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::uint32 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::uint32 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_FIXED32) {
                                
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::uint32, ::google::protobuf::internal::WireFormatLite::TYPE_FIXED32>(
                                                                                                                             1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::uint32, ::google::protobuf::internal::WireFormatLite::TYPE_FIXED32>(
                                                                                                                             input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::uint32, ::google::protobuf::internal::WireFormatLite::TYPE_FIXED32>(input, (::google::protobuf::uint32*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_BOOL:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< bool >* repeatedField = (::google::protobuf::RepeatedField< bool >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
                                
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     bool, ::google::protobuf::internal::WireFormatLite::TYPE_BOOL>(
                                                                                                                             1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     bool, ::google::protobuf::internal::WireFormatLite::TYPE_BOOL>(
                                                                                                                             input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 bool, ::google::protobuf::internal::WireFormatLite::TYPE_BOOL>(input, (bool*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_STRING:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedPtrField< ::std::string>* repeatedField = (::google::protobuf::RepeatedPtrField< ::std::string>*)ptr;
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
                            parse_var_string:
                                DO_(::google::protobuf::internal::WireFormatLite::ReadString(
                                                                                             input, repeatedField->Add()));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            std::string* str = *(std::string**)ptr;
                            if (str == &::google::protobuf::internal::kEmptyString) {
                                *((std::string**)ptr) = new ::std::string();
                                str = *(std::string**)ptr;
                            }
                            // parse values
                            DO_(::google::protobuf::internal::WireFormatLite::ReadString(
                                                                                         input, str));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_MESSAGE:{
                        if(entry->repeat){
                            internal::RepeatedPtrFieldBase* p = (internal::RepeatedPtrFieldBase*)ptr;
                            DO_(::google::protobuf::internal::WireFormatLite::ReadMessage(
                                                                                          input, (google::protobuf::MessageLite*)p->AddWithCreator()));
                        }else{
                            // TODO: make sure ptr is not null
                            //                      DO_(::google::protobuf::internal::WireFormatLite::ReadMessage(
                            //                                                                                             input, (google::protobuf::MessageLite*)ptr));
                            //
                            
                            DO_(::google::protobuf::internal::WireFormatLite::ReadMessage(
                                                                                          input, *(google::protobuf::MessageLite**)ptr));
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                        
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_BYTES:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedPtrField< ::std::string>* repeatedField = (::google::protobuf::RepeatedPtrField< ::std::string>*)ptr;
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {

                                DO_(::google::protobuf::internal::WireFormatLite::ReadBytes(
                                                                                             input, repeatedField->Add()));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            std::string* str = *(std::string**)ptr;
                            if (str == &::google::protobuf::internal::kEmptyString) {
                                *((std::string**)ptr) = new ::std::string();
                                str = *(std::string**)ptr;
                            }
                            
                            DO_(::google::protobuf::internal::WireFormatLite::ReadBytes(
                                                                                         input, str));
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_UINT32:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::uint32 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::uint32 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
                                
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::uint32, ::google::protobuf::internal::WireFormatLite::TYPE_UINT32>(
                                                                                                                          1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::uint32, ::google::protobuf::internal::WireFormatLite::TYPE_UINT32>(
                                                                                                                           input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::uint32, ::google::protobuf::internal::WireFormatLite::TYPE_UINT32>(input, (::google::protobuf::uint32*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_ENUM:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< int >* repeatedField = (::google::protobuf::RepeatedField< int >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
                            parse_var_enum:
                                int value;
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                     int, ::google::protobuf::internal::WireFormatLite::TYPE_ENUM>(
                                                                                                   input, &value)));
                                //if (::tencent::test::Weekday_IsValid(value)) {
                                    //add_var_enum(static_cast< ::tencent::test::Weekday >(value));
                                //}
                                // TODO: unable to validate enum anymore
                                repeatedField->Add(value);
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedEnumNoInline(
                                                                                                          input,
                                                                                                          &is_enum_valid,
                                                                                                          repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // TODO implement this
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {

                                DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                     int, ::google::protobuf::internal::WireFormatLite::TYPE_ENUM>(
                                                                                                   input, (int*)ptr)));

                                SetHasField(entry->fieldNumber);
                            }
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED32:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::int32 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_FIXED32) {
                                
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED32>(
                                                                                                                             1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED32>(
                                                                                                                             input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED32>(input, (::google::protobuf::int32*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED64:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::int64 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_FIXED64) {
                                
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED64>(
                                                                                                                             1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED64>(
                                                                                                                            input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED64>(input, (::google::protobuf::int64*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_SINT32:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::int32 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
                                
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SINT32>(
                                                                                                                          1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SINT32>(
                                                                                                                           input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::int32, ::google::protobuf::internal::WireFormatLite::TYPE_SINT32>(input, (::google::protobuf::int32*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    case ::google::protobuf::internal::WireFormatLite::TYPE_SINT64:{
                        if(entry->repeat){
                            ::google::protobuf::RepeatedField< ::google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< ::google::protobuf::int64 >*)ptr;
                            
                            if (parsedWireType ==
                                ::google::protobuf::internal::WireFormatLite::WIRETYPE_VARINT) {
                                
                                DO_((::google::protobuf::internal::WireFormatLite::ReadRepeatedPrimitive<
                                     ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_SINT64>(
                                                                                                                           1, theTag, input, repeatedField)));
                            } else if (parsedWireType
                                       == ::google::protobuf::internal::WireFormatLite::
                                       WIRETYPE_LENGTH_DELIMITED) {
                                DO_((::google::protobuf::internal::WireFormatLite::ReadPackedPrimitiveNoInline<
                                     ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_SINT64>(
                                                                                                                            input, repeatedField)));
                            } else {
                                //goto handle_uninterpreted;
                            }
                        }else{
                            // parse values
                            DO_((::google::protobuf::internal::WireFormatLite::ReadPrimitive<
                                 ::google::protobuf::int64, ::google::protobuf::internal::WireFormatLite::TYPE_SINT64>(input, (::google::protobuf::int64*)ptr)));
                            
                            // update has flag
                            SetHasField(entry->fieldNumber);
                        }
                    }
                        break;
                        
                    default:
                        // TODO: log something here
                        break;
                }
            }
        }else{
            // handle uninterpreted
            if (parsedWireType ==
                ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
                return true;
            }
            DO_(::google::protobuf::internal::WireFormatLite::SkipField(input, tag));
        }
    }
    return true;
FAIL_LOGIC:
    return false;
#undef DO_
}

void MessageLite::Clear(){
    ////////////////////////////////////////////////////////////////
    int count = 0;
    const google::protobuf::FieldInfo* infoArray = GetFieldInfoArray(count);
    
    for (int infoIndex = 0; infoIndex < count; ++infoIndex) {
        const google::protobuf::FieldInfo& info = infoArray[infoIndex];
        
        const void* ptr = reinterpret_cast<const unsigned char*>(this) + info.offset;
        
        switch (info.type) {
            case ::google::protobuf::internal::WireFormatLite::TYPE_DOUBLE:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< double >* repeatedField = (::google::protobuf::RepeatedField< double >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(double*)ptr = 0;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FLOAT:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< float >* repeatedField = (::google::protobuf::RepeatedField< float >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(float*)ptr = 0;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_INT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::int64*)ptr = 0;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_UINT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint64 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::uint64*)ptr = GOOGLE_ULONGLONG(0);
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_INT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::int32*)ptr = 0;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FIXED64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint64 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::uint64*)ptr = GOOGLE_ULONGLONG(0);
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_FIXED32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint32 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::uint32*)ptr = 0u;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_BOOL:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< bool >* repeatedField = (::google::protobuf::RepeatedField< bool >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(bool*)ptr = false;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_BYTES:
            case ::google::protobuf::internal::WireFormatLite::TYPE_STRING:{
                if(info.repeat){
                    ::google::protobuf::RepeatedPtrField< ::std::string>* repeatedField = (::google::protobuf::RepeatedPtrField< ::std::string>*)ptr;
                    repeatedField->Clear();
                }else{
                    std::string* v = *(google::protobuf::string**)ptr;
                    v->clear();
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_MESSAGE:{
                if(info.repeat){
                    ::google::protobuf::internal::RepeatedPtrFieldBase* repeatedField = (::google::protobuf::internal::RepeatedPtrFieldBase*)ptr;
                    repeatedField->Clear_Customized();
                }else{
                    google::protobuf::MessageLite* msg = *(google::protobuf::MessageLite**)ptr;
                    if(msg){
                        msg->Clear();
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_UINT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::uint32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::uint32 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::uint32*)ptr = 0u;
                }
            }
                break;
                
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_ENUM:{
                // TODO: double check this
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::int32*)ptr = 0u;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::int32*)ptr = 0;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SFIXED64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::int64*)ptr = 0u;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SINT32:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int32 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int32 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::int32*)ptr = 0;
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_SINT64:{
                if(info.repeat){
                    ::google::protobuf::RepeatedField< google::protobuf::int64 >* repeatedField = (::google::protobuf::RepeatedField< google::protobuf::int64 >*)ptr;
                    repeatedField->Clear();
                }else{
                    *(google::protobuf::int64*)ptr = 0u;
                }
            }
                break;
                
            default:
                // TODO: log something here
                break;
        }
    }


    // TODO: reset has bits
}
    
void MessageLite::SharedDtor() {
    int count = 0;
    const google::protobuf::FieldInfo* infoArray = GetFieldInfoArray(count);
    
    for (int infoIndex = 0; infoIndex < count; ++infoIndex) {
        const google::protobuf::FieldInfo& info = infoArray[infoIndex];
        
        const void* ptr = reinterpret_cast<const unsigned char*>(this) + info.offset;
        
        switch (info.type) {
            case ::google::protobuf::internal::WireFormatLite::TYPE_BYTES:
            case ::google::protobuf::internal::WireFormatLite::TYPE_STRING:{
                if(!info.repeat){
                    std::string* v = *(google::protobuf::string**)ptr;
                    if(v != &::google::protobuf::internal::kEmptyString){
                        delete v;
                    }
                }
            }
                break;
                
            case ::google::protobuf::internal::WireFormatLite::TYPE_MESSAGE:{
                if(!info.repeat){
                    google::protobuf::MessageLite* msg = *(google::protobuf::MessageLite**)ptr;
                    if(msg){
                        delete msg;
                    }
                }
            }
                break;
                
            default:
                // TODO: log something here
                break;
        }
    }

}
////////////////////////////////////////////////

}  // namespace protobuf
}  // namespace google
