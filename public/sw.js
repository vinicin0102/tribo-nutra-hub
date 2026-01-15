// Service Worker para PWA - Cache Inteligente
const CACHE_NAME = 'nutra-elite-v3';
const RUNTIME_CACHE = 'nutra-elite-runtime-v3';
const IMAGE_CACHE = 'nutra-elite-images-v3';
const API_CACHE = 'nutra-elite-api-v3';

// Arquivos estáticos críticos para cache imediato
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/icons/icon-192x192.png',
  '/icons/icon-512x512.png',
  '/favicon.svg',
];

// Estratégias de cache
const CACHE_STRATEGIES = {
  // Cache First: Para assets estáticos que raramente mudam
  CACHE_FIRST: ['/icons/', '/favicon', '/manifest.json'],
  // Network First: Para HTML e recursos dinâmicos
  NETWORK_FIRST: ['/', '/index.html'],
  // Stale While Revalidate: Para imagens
  STALE_WHILE_REVALIDATE: ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg'],
  // Network Only: Para APIs
  NETWORK_ONLY: ['supabase.co', '/api/'],
};

// Instalação do Service Worker
self.addEventListener('install', (event) => {
  console.log('[SW] Installing service worker v3...');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('[SW] Caching static assets');
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
        return self.skipWaiting(); // Ativar imediatamente
      })
      .catch((error) => {
        console.error('[SW] Installation failed:', error);
      })
  );
});

// Ativação do Service Worker
self.addEventListener('activate', (event) => {
  console.log('[SW] Activating service worker v3...');
  
  event.waitUntil(
    Promise.all([
      // Limpar caches antigos
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames
            .filter((name) => 
              name !== CACHE_NAME && 
              name !== RUNTIME_CACHE && 
              name !== IMAGE_CACHE &&
              name !== API_CACHE
            )
            .map((name) => {
              console.log('[SW] Deleting old cache:', name);
              return caches.delete(name);
            })
        );
      }),
      // Assumir controle de todas as páginas
      self.clients.claim()
    ])
  );
});

// Função auxiliar: Cache First
async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) {
    return cached;
  }
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(CACHE_NAME);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    console.error('[SW] Cache First failed:', error);
    return new Response('Offline', { status: 503 });
  }
}

// Função auxiliar: Network First
async function networkFirst(request) {
  try {
    const response = await fetch(request);
    if (response.ok) {
      const cache = await caches.open(RUNTIME_CACHE);
      cache.put(request, response.clone());
    }
    return response;
  } catch (error) {
    console.log('[SW] Network failed, trying cache:', request.url);
    const cached = await caches.match(request);
    if (cached) {
      return cached;
    }
    // Fallback para index.html se for navegação
    if (request.mode === 'navigate') {
      const indexCache = await caches.match('/index.html');
      if (indexCache) return indexCache;
    }
    return new Response('Offline', { status: 503 });
  }
}

// Função auxiliar: Stale While Revalidate
async function staleWhileRevalidate(request) {
  const cache = await caches.open(IMAGE_CACHE);
  const cached = await cache.match(request);
  
  const fetchPromise = fetch(request).then((response) => {
    if (response.ok) {
      cache.put(request, response.clone());
    }
    return response;
  }).catch(() => cached);
  
  return cached || fetchPromise;
}

// Interceptar requisições
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Ignorar requisições não-GET
  if (request.method !== 'GET') {
    return;
  }

  // Ignorar requisições para APIs externas (deixar passar direto)
  if (url.hostname.includes('supabase.co')) {
    return;
  }

  // Ignorar requisições para outros domínios
  if (url.origin !== location.origin) {
    return;
  }

  // Aplicar estratégia baseada no tipo de recurso
  const pathname = url.pathname;
  const isImage = /\.(jpg|jpeg|png|gif|webp|svg)$/i.test(pathname);
  const isStatic = CACHE_STRATEGIES.CACHE_FIRST.some(pattern => pathname.includes(pattern));
  const isHTML = pathname === '/' || pathname.endsWith('.html');

  if (isImage) {
    // Stale While Revalidate para imagens
    event.respondWith(staleWhileRevalidate(request));
  } else if (isStatic) {
    // Cache First para assets estáticos
    event.respondWith(cacheFirst(request));
  } else {
    // Network First para HTML e outros recursos
    event.respondWith(networkFirst(request));
  }
});

// Notificações push
self.addEventListener('push', (event) => {
  console.log('[SW] Push notification received');
  
  const data = event.data ? event.data.json() : {};
  const title = data.title || 'Comunidade dos Sócios';
  const options = {
    body: data.body || 'Nova notificação',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-72x72.png',
    image: data.image,
    vibrate: [200, 100, 200],
    tag: data.tag || 'notification',
    requireInteraction: data.requireInteraction || false,
    actions: data.actions || [],
    data: data.data || {},
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});

// Clique em notificação
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  const urlToOpen = event.notification.data?.url || '/';
  
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((clientList) => {
        // Se já existe uma janela aberta, focar nela
        for (const client of clientList) {
          if (client.url === urlToOpen && 'focus' in client) {
            return client.focus();
          }
        }
        // Caso contrário, abrir nova janela
        if (clients.openWindow) {
          return clients.openWindow(urlToOpen);
        }
      })
  );
});

// Sincronização em background (quando online novamente)
self.addEventListener('sync', (event) => {
  console.log('[SW] Background sync:', event.tag);
  
  if (event.tag === 'sync-posts') {
    event.waitUntil(
      // Implementar lógica de sincronização
      Promise.resolve()
    );
  }
});

// Mensagens do cliente
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'CACHE_URLS') {
    event.waitUntil(
      caches.open(RUNTIME_CACHE).then((cache) => {
        return cache.addAll(event.data.urls);
      })
    );
  }
});
