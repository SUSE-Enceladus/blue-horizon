/*
 * functions used by other functions
 */

// https://stackoverflow.com/questions/10420352/converting-file-size-in-bytes-to-human-readable-string
// https://creativecommons.org/licenses/by-sa/4.0/
function humanFileSize(bytes, si) {
  var thresh = si ? 1000 : 1024;
  if (Math.abs(bytes) < thresh) {
    return bytes + " B";
  }
  var units = si
    ? ["kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
    : ["KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"];
  var u = -1;
  do {
    bytes /= thresh;
    ++u;
  } while (Math.abs(bytes) >= thresh && u < units.length - 1);
  if (Number.isInteger(bytes)) {
    return bytes.toString() + " " + units[u];
  } else {
    return bytes.toFixed(1) + " " + units[u];
  }
}

// https://stackoverflow.com/questions/4583703/jquery-post-request-not-ajax
jQuery(function($) { $.extend({
  form: function(url, data, method) {
      if (method == null) method = 'POST';
      if (data == null) data = {};

      var form = $('<form>').attr({
          method: method,
          action: url
       }).css({
          display: 'none'
       });

      var addData = function(name, data) {
          if ($.isArray(data)) {
              for (var i = 0; i < data.length; i++) {
                  var value = data[i];
                  addData(name + '[]', value);
              }
          } else if (typeof data === 'object') {
              for (var key in data) {
                  if (data.hasOwnProperty(key)) {
                      addData(name + '[' + key + ']', data[key]);
                  }
              }
          } else if (data != null) {
              form.append($('<input>').attr({
                type: 'hidden',
                name: String(name),
                value: String(data)
              }));
          }
      };

      for (var key in data) {
          if (data.hasOwnProperty(key)) {
              addData(key, data[key]);
          }
      }

      return form.appendTo('body');
  }
}); });
