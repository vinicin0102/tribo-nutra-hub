// Service Worker para PWA
const CACHE_NAME = 'nutra-elite-v1';
const RUNTIME_CACHE = 'nutra-elite-runtime-v1';

// Arquivos estáticos para cache
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192x192.png',
  '/icons/icon-512x512.png',
];

// Instalação do Service Worker
self.addEventListener('install', (event) => {
  console.log('[SW] Installing service worker...');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Caching static assets');
        // Adicionar arquivos um por um para evitar falhas
        return Promise.allSettled(
          STATIC_ASSETS.map((asset) => 
            cache.add(asset).catch((err) => {
              console.warn(`[SW] Failed to cache ${asset}:`, err);
              return null;
            })
          )
        );
      })
      .then(() => {
        console.log('[SW] Service worker installed');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('[SW] Installation failed:', error);
      })
  );
});

// Ativação do Service Worker
self.addEventListener('activate', (event) => {
  console.log('[SW] Activating service worker...');
  
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME && name !== RUNTIME_CACHE)
          .map((name) => {
            console.log('[SW] Deleting old cache:', name);
            return caches.delete(name);
          })
      );
    })
    .then(() => self.clients.claim())
  );
});

// Estratégia: Network First, fallback para Cache
self.addEventListener('fetch', (event) => {
  // Ignorar requisições não-GET
  if (event.request.method !== 'GET') {
    return;
  }

  const url = new URL(event.request.url);

  // Ignorar requisições para APIs externas (Supabase)
  if (url.hostname.includes('supabase.co')) {
    return;
  }

  // Ignorar requisições para outros domínios
  if (url.origin !== location.origin) {
    return;
  }

  event.respondWith(
    fetch(event.request)
      .then((response) => {
        // Clonar a resposta para cache
        const responseToCache = response.clone();
        
        // Cachear apenas respostas válidas e do mesmo origin
        if (response.status === 200 && response.type === 'basic') {
          caches.open(RUNTIME_CACHE).then((cache) => {
            cache.put(event.request, responseToCache).catch((err) => {
              console.warn('[SW] Failed to cache response:', err);
            });
          });
        }
        
        return response;
      })
      .catch((error) => {
        console.log('[SW] Network request failed, trying cache:', event.request.url);
        // Fallback para cache se a rede falhar
        return caches.match(event.request).then((cachedResponse) => {
          if (cachedResponse) {
            return cachedResponse;
          }
          
          // Se for uma navegação, retornar index.html
          if (event.request.mode === 'navigate') {
            return caches.match('/index.html').then((indexResponse) => {
              if (indexResponse) {
                return indexResponse;
              }
              // Se não encontrar index.html no cache, retornar resposta básica
              return new Response('Offline', { status: 503, statusText: 'Service Unavailable' });
            });
          }
          
          // Para outros recursos, retornar erro
          return new Response('Resource not available offline', { 
            status: 503,
            statusText: 'Service Unavailable'
          });
        });
      })
  );
});

// Notificações push (opcional, para implementação futura)
self.addEventListener('push', (event) => {
  console.log('[SW] Push notification received');
  
  const options = {
    body: event.data ? event.data.text() : 'Nova notificação',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-72x72.png',
    vibrate: [200, 100, 200],
    tag: 'notification',
    requireInteraction: false,
  };

  event.waitUntil(
    self.registration.showNotification('Sociedade Nutra', options)
  );
});

// Clique em notificação
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  event.waitUntil(
    clients.openWindow('/')
  );
});

