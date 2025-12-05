// Registrar Service Worker
export function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker
        .register('/sw.js')
        .then((registration) => {
          console.log('[SW] Service Worker registrado com sucesso:', registration.scope);

          // Verificar atualizações periodicamente
          registration.addEventListener('updatefound', () => {
            const newWorker = registration.installing;
            if (newWorker) {
              newWorker.addEventListener('statechange', () => {
                if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                  // Nova versão disponível
                  console.log('[SW] Nova versão disponível!');
                  // Opcional: mostrar notificação para o usuário atualizar
                  if (confirm('Nova versão disponível! Deseja atualizar agora?')) {
                    newWorker.postMessage({ type: 'SKIP_WAITING' });
                    window.location.reload();
                  }
                }
              });
            }
          });
        })
        .catch((error) => {
          console.error('[SW] Erro ao registrar Service Worker:', error);
        });

      // Listener para mensagens do Service Worker
      navigator.serviceWorker.addEventListener('message', (event) => {
        if (event.data && event.data.type === 'SKIP_WAITING') {
          window.location.reload();
        }
      });

      // Verificar atualizações a cada hora
      setInterval(() => {
        navigator.serviceWorker.getRegistration().then((registration) => {
          if (registration) {
            registration.update();
          }
        });
      }, 60 * 60 * 1000); // 1 hora
    });
  }
}

