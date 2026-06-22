
class CurlConverter {
  static String export({
    required String url,
    required String method,
    required List<MapEntry<String, String>> headers,
    required String body,
    required String format,
  }) {
    final buffer = StringBuffer();

    // Quote character based on format
    final quote = format == 'Windows (CMD)' ? '"' : "'";
    // Line continuation character based on format
    final continuation = format == 'Linux (Bash)'
        ? '\\'
        : (format == 'Windows (PowerShell)' ? '`' : '^');

    buffer.write("curl -X $method $quote$url$quote");

    for (var header in headers) {
      final key = header.key.trim();
      final val = header.value.trim();
      if (key.isNotEmpty) {
        buffer.write(" $continuation\n  -H $quote$key: $val$quote");
      }
    }

    final trimmedBody = body.trim();
    if (trimmedBody.isNotEmpty && method != 'GET') {
      String escapedBody;
      if (format == 'Windows (CMD)') {
        // CMD requires escaping double quotes: " -> \"
        escapedBody = trimmedBody.replaceAll('"', '\\"');
      } else {
        // Linux and PowerShell use single quotes around the body: escape ' as '\''
        escapedBody = trimmedBody.replaceAll("'", "'\\''");
      }
      buffer.write(" $continuation\n  --data-raw $quote$escapedBody$quote");
    }

    return buffer.toString();
  }

  static Map<String, dynamic> parse(String curl) {
    String method = 'GET';
    String url = '';
    final Map<String, String> headers = {};
    String body = '';

    // Replace line continuations for Linux (\), PowerShell (`), and CMD (^)
    String cleanCurl = curl
        .replaceAll('\\\n', ' ')
        .replaceAll('`\n', ' ')
        .replaceAll('^\n', ' ')
        .replaceAll('\n', ' ')
        .trim();

    final List<String> tokens = [];
    StringBuffer currentToken = StringBuffer();
    bool inSingleQuote = false;
    bool inDoubleQuote = false;
    bool escapeNext = false;

    for (int i = 0; i < cleanCurl.length; i++) {
      final char = cleanCurl[i];

      if (escapeNext) {
        currentToken.write(char);
        escapeNext = false;
        continue;
      }

      if (char == '\\' && !inSingleQuote) {
        escapeNext = true;
        continue;
      }

      if (char == "'" && !inDoubleQuote) {
        inSingleQuote = !inSingleQuote;
        continue;
      }

      if (char == '"' && !inSingleQuote) {
        inDoubleQuote = !inDoubleQuote;
        continue;
      }

      if (char == ' ' && !inSingleQuote && !inDoubleQuote) {
        if (currentToken.isNotEmpty) {
          tokens.add(currentToken.toString());
          currentToken.clear();
        }
      } else {
        currentToken.write(char);
      }
    }
    if (currentToken.isNotEmpty) {
      tokens.add(currentToken.toString());
    }

    int i = 0;
    bool hasData = false;

    while (i < tokens.length) {
      final token = tokens[i];

      if (token == 'curl') {
        i++;
        continue;
      }

      if (token == '-X' || token == '--request') {
        if (i + 1 < tokens.length) {
          method = tokens[i + 1].toUpperCase();
          i += 2;
        } else {
          i++;
        }
      } else if (token == '-H' || token == '--header') {
        if (i + 1 < tokens.length) {
          final headerVal = tokens[i + 1];
          final separatorIndex = headerVal.indexOf(':');
          if (separatorIndex != -1) {
            final key = headerVal.substring(0, separatorIndex).trim();
            final val = headerVal.substring(separatorIndex + 1).trim();
            headers[key] = val;
          }
          i += 2;
        } else {
          i++;
        }
      } else if (token == '-d' ||
          token == '--data' ||
          token == '--data-raw' ||
          token == '--data-binary') {
        if (i + 1 < tokens.length) {
          body = tokens[i + 1];
          hasData = true;
          i += 2;
        } else {
          i++;
        }
      } else if (token == '--url') {
        if (i + 1 < tokens.length) {
          url = tokens[i + 1];
          i += 2;
        } else {
          i++;
        }
      } else if (token.startsWith('-')) {
        i++;
      } else {
        if (token.startsWith('http://') || token.startsWith('https://') || url.isEmpty) {
          url = token;
        }
        i++;
      }
    }

    if (hasData && method == 'GET') {
      method = 'POST';
    }

    // Unescape Windows double quotes
    if (body.contains('\\"')) {
      body = body.replaceAll('\\"', '"');
    }

    return {
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
    };
  }
}
