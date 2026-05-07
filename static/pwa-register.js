// OpenMentor PWA 注册 + 安装提示
(function () {
    if (!('serviceWorker' in navigator)) return;

    // 注册 Service Worker（路径来自根，scope = /）
    window.addEventListener('load', function () {
        navigator.serviceWorker.register('/sw.js', {scope: '/'}).catch(function (err) {
            console.warn('[OpenMentor PWA] sw 注册失败：', err);
        });
    });

    // 捕获 beforeinstallprompt，给页面提供"添加到主屏幕"按钮（如果模板有 #om-install-btn）
    var deferredPrompt = null;
    window.addEventListener('beforeinstallprompt', function (e) {
        e.preventDefault();
        deferredPrompt = e;
        var btn = document.getElementById('om-install-btn');
        if (btn) {
            btn.classList.remove('d-none');
            btn.addEventListener('click', function () {
                if (!deferredPrompt) return;
                deferredPrompt.prompt();
                deferredPrompt.userChoice.finally(function () {
                    deferredPrompt = null;
                    btn.classList.add('d-none');
                });
            }, {once: true});
        }
    });

    window.addEventListener('appinstalled', function () {
        var btn = document.getElementById('om-install-btn');
        if (btn) btn.classList.add('d-none');
    });
})();
