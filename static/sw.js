/* OpenMentor Service Worker
   策略：
   - /static/* 静态资源：cache-first（首次访问后离线可用）
   - 其他 GET 请求（HTML 页面）：network-first，失败时回退离线兜底
   - SSE 流（/api/chat/.../message）和所有 POST：直接放行，不缓存
*/

const CACHE_VERSION = 'om-v1.1';
const STATIC_CACHE = 'om-static-' + CACHE_VERSION;
const RUNTIME_CACHE = 'om-runtime-' + CACHE_VERSION;

const PRECACHE_URLS = [
    '/static/css/bootstrap.min.css',
    '/static/js/bootstrap.bundle.min.js',
    '/static/vendor/bootstrap-icons/bootstrap-icons.min.css',
    '/static/openmentor_logo.png',
    '/static/icons/icon-192.png',
    '/static/icons/icon-512.png',
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(STATIC_CACHE).then((cache) => cache.addAll(PRECACHE_URLS).catch(() => {}))
            .then(() => self.skipWaiting())
    );
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keys) =>
            Promise.all(keys.map((k) => {
                if (k !== STATIC_CACHE && k !== RUNTIME_CACHE) return caches.delete(k);
            }))
        ).then(() => self.clients.claim())
    );
});

self.addEventListener('fetch', (event) => {
    const req = event.request;
    if (req.method !== 'GET') return;

    const url = new URL(req.url);
    if (url.origin !== self.location.origin) return;

    // SSE / 实时接口：完全放行
    if (url.pathname.startsWith('/api/chat/') ||
        url.pathname.startsWith('/api/analytics/') ||
        url.pathname.startsWith('/api/assistant/')) {
        return;
    }

    // 静态资源：cache-first
    if (url.pathname.startsWith('/static/')) {
        event.respondWith(
            caches.match(req).then((cached) => {
                if (cached) return cached;
                return fetch(req).then((resp) => {
                    if (resp && resp.status === 200 && resp.type === 'basic') {
                        const copy = resp.clone();
                        caches.open(STATIC_CACHE).then((c) => c.put(req, copy));
                    }
                    return resp;
                });
            })
        );
        return;
    }

    // HTML 导航：network-first，失败回退缓存
    if (req.headers.get('accept') && req.headers.get('accept').includes('text/html')) {
        event.respondWith(
            fetch(req).then((resp) => {
                if (resp && resp.status === 200 && resp.type === 'basic') {
                    const copy = resp.clone();
                    caches.open(RUNTIME_CACHE).then((c) => c.put(req, copy));
                }
                return resp;
            }).catch(() => caches.match(req).then((cached) => cached || caches.match('/')))
        );
        return;
    }

    // 其他 GET 请求：网络优先，缓存兜底
    event.respondWith(
        fetch(req).then((resp) => {
            if (resp && resp.status === 200) {
                const copy = resp.clone();
                caches.open(RUNTIME_CACHE).then((c) => c.put(req, copy));
            }
            return resp;
        }).catch(() => caches.match(req))
    );
});
