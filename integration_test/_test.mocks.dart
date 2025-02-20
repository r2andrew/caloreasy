// Mocks generated by Mockito 5.4.5 from annotations
// in caloreasy/test/_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:convert' as _i6;
import 'dart:typed_data' as _i8;

import 'package:caloreasy/helpers/customFoodAPIClient.dart' as _i4;
import 'package:http/http.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i7;
import 'package:openfoodfacts/openfoodfacts.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeSearchResult_0 extends _i1.SmartFake implements _i2.SearchResult {
  _FakeSearchResult_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeResponse_1 extends _i1.SmartFake implements _i3.Response {
  _FakeResponse_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeStreamedResponse_2 extends _i1.SmartFake
    implements _i3.StreamedResponse {
  _FakeStreamedResponse_2(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [customFoodAPIClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockcustomFoodAPIClient extends _i1.Mock
    implements _i4.customFoodAPIClient {
  MockcustomFoodAPIClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.SearchResult> searchProducts(String? searchTerm) =>
      (super.noSuchMethod(
            Invocation.method(#searchProducts, [searchTerm]),
            returnValue: _i5.Future<_i2.SearchResult>.value(
              _FakeSearchResult_0(
                this,
                Invocation.method(#searchProducts, [searchTerm]),
              ),
            ),
          )
          as _i5.Future<_i2.SearchResult>);
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i3.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i3.Response> head(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#head, [url], {#headers: headers}),
            returnValue: _i5.Future<_i3.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(#head, [url], {#headers: headers}),
              ),
            ),
          )
          as _i5.Future<_i3.Response>);

  @override
  _i5.Future<_i3.Response> get(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#get, [url], {#headers: headers}),
            returnValue: _i5.Future<_i3.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(#get, [url], {#headers: headers}),
              ),
            ),
          )
          as _i5.Future<_i3.Response>);

  @override
  _i5.Future<_i3.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i6.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #post,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i5.Future<_i3.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #post,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i5.Future<_i3.Response>);

  @override
  _i5.Future<_i3.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i6.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #put,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i5.Future<_i3.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #put,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i5.Future<_i3.Response>);

  @override
  _i5.Future<_i3.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i6.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #patch,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i5.Future<_i3.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #patch,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i5.Future<_i3.Response>);

  @override
  _i5.Future<_i3.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i6.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #delete,
              [url],
              {#headers: headers, #body: body, #encoding: encoding},
            ),
            returnValue: _i5.Future<_i3.Response>.value(
              _FakeResponse_1(
                this,
                Invocation.method(
                  #delete,
                  [url],
                  {#headers: headers, #body: body, #encoding: encoding},
                ),
              ),
            ),
          )
          as _i5.Future<_i3.Response>);

  @override
  _i5.Future<String> read(Uri? url, {Map<String, String>? headers}) =>
      (super.noSuchMethod(
            Invocation.method(#read, [url], {#headers: headers}),
            returnValue: _i5.Future<String>.value(
              _i7.dummyValue<String>(
                this,
                Invocation.method(#read, [url], {#headers: headers}),
              ),
            ),
          )
          as _i5.Future<String>);

  @override
  _i5.Future<_i8.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#readBytes, [url], {#headers: headers}),
            returnValue: _i5.Future<_i8.Uint8List>.value(_i8.Uint8List(0)),
          )
          as _i5.Future<_i8.Uint8List>);

  @override
  _i5.Future<_i3.StreamedResponse> send(_i3.BaseRequest? request) =>
      (super.noSuchMethod(
            Invocation.method(#send, [request]),
            returnValue: _i5.Future<_i3.StreamedResponse>.value(
              _FakeStreamedResponse_2(
                this,
                Invocation.method(#send, [request]),
              ),
            ),
          )
          as _i5.Future<_i3.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
    Invocation.method(#close, []),
    returnValueForMissingStub: null,
  );
}
