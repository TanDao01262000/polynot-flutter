import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/user_provider.dart';

/// Global reference to UserProvider for handling token expiration
/// This is set during app initialization
UserProvider? _globalUserProvider;

/// Flag to prevent recursive logout calls
bool _isHandlingLogout = false;

/// Set the global UserProvider reference
void setGlobalUserProvider(UserProvider provider) {
  _globalUserProvider = provider;
}

/// Public function to handle 401 errors (for use with multipart requests)
Future<void> handle401Error() async {
  if (_isHandlingLogout) {
    print('🔐 HTTP Client: Already handling logout, skipping duplicate call');
    return;
  }
  
  if (_globalUserProvider != null) {
    _isHandlingLogout = true;
    try {
      print('🔐 HTTP Client: Detected 401 error, logging out user');
      await _globalUserProvider!.handleTokenExpiration();
    } finally {
      _isHandlingLogout = false;
    }
  } else {
    print('🔐 HTTP Client: Warning - 401 detected but no UserProvider set');
  }
}

/// Wrapper for HTTP GET that automatically handles 401 errors
Future<http.Response> httpGet(
  Uri url, {
  Map<String, String>? headers,
}) async {
  final response = await http.get(url, headers: headers);
  
  if (response.statusCode == 401) {
    await handle401Error();
  }
  
  return response;
}

/// Wrapper for HTTP POST that automatically handles 401 errors
Future<http.Response> httpPost(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final response = await http.post(
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
  
  if (response.statusCode == 401) {
    await handle401Error();
  }
  
  return response;
}

/// Wrapper for HTTP PUT that automatically handles 401 errors
Future<http.Response> httpPut(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final response = await http.put(
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
  
  if (response.statusCode == 401) {
    await handle401Error();
  }
  
  return response;
}

/// Wrapper for HTTP PATCH that automatically handles 401 errors
Future<http.Response> httpPatch(
  Uri url, {
  Map<String, String>? headers,
  Object? body,
  Encoding? encoding,
}) async {
  final response = await http.patch(
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
  
  if (response.statusCode == 401) {
    await handle401Error();
  }
  
  return response;
}

/// Wrapper for HTTP DELETE that automatically handles 401 errors
Future<http.Response> httpDelete(
  Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
}) async {
  final response = await http.delete(
    url,
    headers: headers,
    body: body,
    encoding: encoding,
  );
  
  if (response.statusCode == 401) {
    await handle401Error();
  }
  
  return response;
}

/// Wrapper for HTTP StreamRequest that automatically handles 401 errors
Future<http.StreamedResponse> httpStream(
  http.StreamedRequest request,
) async {
  final response = await request.send();
  
  // For streamed responses, we need to read the response first
  final httpResponse = await http.Response.fromStream(response);
  
  if (httpResponse.statusCode == 401) {
    await handle401Error();
  }
  
  // Return a new StreamedResponse with the same data
  // Note: This is a simplified version, may need adjustment based on usage
  return response;
}
