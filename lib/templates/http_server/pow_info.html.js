module.exports = function(__obj) {
  var _safe = function(value) {
    if (typeof value === 'undefined' && value == null)
      value = '';
    var result = new String(value);
    result.ecoSafe = true;
    return result;
  };
  return (function() {
    var __out = [], __self = this, _print = function(value) {
      if (typeof value !== 'undefined' && value != null)
        __out.push(value.ecoSafe ? value : __self.escape(value));
    }, _capture = function(callback) {
      var out = __out, result;
      __out = [];
      callback.call(this);
      result = __out.join('');
      __out = out;
      return _safe(result);
    };
    (function() {
      _print(_safe('<!doctype html>\n<html>\n<head>\n  <title>Pow: Up and running</title>\n  <style>\n    body {\n      margin: 0;\n      padding: 0;\n    }\n    h1, h2 {\n      margin: 0;\n      padding: 15px 30px;\n      font-family: Helvetica, sans-serif;\n    }\n    h1 {\n      font-size: 36px;\n      background: #eeedea;\n      color: #000;\n      border-bottom: 1px solid #999090;\n    }\n    h2 {\n      font-size: 18px;\n      font-weight: normal;\n    }\n  </style>\n</head>\n<body>\n  <h1>Alright, you\'re running Pow!</h1>\n  <h2>Dest Port : '));
      _print(this.configuration.dstPort);
      _print(_safe('</h2>\n  <h2>HTTP Port : '));
      _print(this.configuration.httpPort);
      _print(_safe('</h2>\n  <h2>DNS Port : '));
      _print(this.configuration.dnsPort);
      _print(_safe('</h2>\n  <h2>Timeout : '));
      _print(this.configuration.timeout);
      _print(_safe('</h2>\n  <h2>Workers : '));
      _print(this.configuration.workers);
      _print(_safe('</h2>\n  \n  <h2>Domains : '));
      _print(this.configuration.domains.join(", "));
      _print(_safe('</h2>\n  <h2>Host Root : '));
      _print(this.configuration.hostRoot);
      _print(_safe('</h2>\n  <h2>Log Root : '));
      _print(this.configuration.logRoot);
      _print(_safe('</h2>\n  <h2>RVM Path : '));
      _print(this.configuration.rvmPath);
      _print(_safe('</h2>\n</body>\n</html>'));
    }).call(this);
    
    return __out.join('');
  }).call((function() {
    var obj = {
      escape: function(value) {
        return ('' + value)
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
      },
      safe: _safe
    }, key;
    for (key in __obj) obj[key] = __obj[key];
    return obj;
  })());
};