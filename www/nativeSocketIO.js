var exec = cordova.require("cordova/exec");

/**
 * Constructor.
 *
 * @returns {NativeSocketIO}
 */
function NativeSocketIO() { }

NativeSocketIO.prototype.connect = function (config, successCallback, errorCallback) {
  exec(
    function (result) {
      console.log('NativeSocketIO connect result', result)
      successCallback(result);
    },
    function (error) {
      console.log('NativeSocketIO connect error', error)
      errorCallback && errorCallback(error);
    },
    'NativeSocketIO',
    'connect',
    [config]
  );
};

//-------------------------------------------------------------------
NativeSocketIO.prototype.on = function (event, successCallback, errorCallback) {
  console.log('NativeSocketIO add event', event);
  exec(
    function (result) {
      const res = result.length > 0 ? result[0] : result;
      console.log('NativeSocketIO on result', event, res);
      successCallback(res);
    },
    function (error) {
      console.log('NativeSocketIO on error', error);
      errorCallback && errorCallback(error);
    },
    'NativeSocketIO',
    'on',
    [{event}]
  );
};

//-------------------------------------------------------------------
NativeSocketIO.prototype.emit = function (event, params, successCallback, errorCallback) {
  console.log('NativeSocketIO emitting event', event, params);
  exec(
    function (result) {
      successCallback && successCallback(result);
    },
    function (error) {
      console.log('NativeSocketIO emit error', error);
      errorCallback && errorCallback(error);
    },
    'NativeSocketIO',
    'emit',
    [{event, params}]
  );
};

//-------------------------------------------------------------------
NativeSocketIO.prototype.disconnect = function (successCallback, errorCallback) {
  console.log('NativeSocketIO disconnecting');
  exec(
    function () {
      successCallback && successCallback();
    },
    function (error) {
      console.log('NativeSocketIO disconnect error', error);
      errorCallback && errorCallback(error);
    },
    'NativeSocketIO',
    'disconnect',
    []
  );
};

//-------------------------------------------------------------------
NativeSocketIO.prototype.removeAllListeners = function (successCallback, errorCallback) {
  console.log('NativeSocketIO removing all listeners');
  exec(
    function () {
      successCallback && successCallback();
    },
    function (error) {
      console.log('NativeSocketIO removeAllListeners error', error);
      errorCallback && errorCallback(error);
    },
    'NativeSocketIO',
    'removeAllListeners',
    []
  );
};

var nativeSocketIO = new NativeSocketIO();

module.exports = nativeSocketIO;
