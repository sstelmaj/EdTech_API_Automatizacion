function fn() {
  var config = {
    baseUrl: 'http://localhost:8080',
    connectTimeout: 10000,
    readTimeout: 10000
  };
  karate.configure('connectTimeout', config.connectTimeout);
  karate.configure('readTimeout', config.readTimeout);
  return config;
}