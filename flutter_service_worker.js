'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "/assets/packages/digital_clock/third_party/PressStart2P-Regular.ttf": "2c404fd06cd67770807d242b2d2e5a16",
"/assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"/assets/AssetManifest.json": "38c983a41c23cd08aebb6c150a9edddc",
"/assets/LICENSE": "96efc529953c125ec2c51c0b6c51de74",
"/assets/FontManifest.json": "cc7081b529eadc01a941a103504d0e7a",
"/assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"/icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"/icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"/digital_clock/third_party/PressStart2P-Regular.ttf": "2c404fd06cd67770807d242b2d2e5a16",
"/manifest.json": "3c61d67d24f483bf936f7712859c4a1c",
"/index.html": "8ef33077bd01dd793a70389c6960cb52",
"/main.dart.js": "fb39b81a4ec0a962ee0f1e0166416e7f"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request, {
          credentials: 'include'
        });
      })
  );
});
