package com.thunderdarkness.cajaviva;

import android.app.Activity;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.view.WindowManager;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

/**
 * La caja viva en Android: una sola pantalla con la página del juego, la misma de la página privada (la técnica B,
 * Three.js). Todo va dentro del APK, en assets/web/, y se sirve desde https://appassets.androidplatform.net/web/ para
 * que los módulos de JavaScript, los fetch y la partida guardada (localStorage) funcionen igual que en la web, sin
 * conexión. Nada sale a la red: las peticiones a otros sitios se quedan sin respuesta.
 */
public class ActividadCaja extends Activity {
    private static final String DOMINIO = "appassets.androidplatform.net";
    private static final String INICIO = "https://" + DOMINIO + "/web/index.html";

    private WebView pagina;

    @Override
    protected void onCreate(Bundle estadoGuardado) {
        super.onCreate(estadoGuardado);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);

        pagina = new WebView(this);
        pagina.setBackgroundColor(Color.rgb(12, 9, 7));      // la penumbra de la sala mientras carga
        pagina.setOverScrollMode(View.OVER_SCROLL_NEVER);
        pagina.setVerticalScrollBarEnabled(false);
        pagina.setHorizontalScrollBarEnabled(false);

        WebSettings ajustes = pagina.getSettings();
        ajustes.setJavaScriptEnabled(true);
        ajustes.setDomStorageEnabled(true);                  // la partida guardada
        ajustes.setMediaPlaybackRequiresUserGesture(false);  // el sonido arranca con el primer toque, como en la web
        ajustes.setTextZoom(100);                            // el tamaño de letra del sistema no descoloca la interfaz
        ajustes.setSupportZoom(false);
        ajustes.setBuiltInZoomControls(false);
        ajustes.setDisplayZoomControls(false);
        ajustes.setAllowFileAccess(false);
        ajustes.setAllowContentAccess(false);
        ajustes.setCacheMode(WebSettings.LOAD_NO_CACHE);

        pagina.setWebViewClient(new ClienteLocal());
        // el menú del juego («Salir del juego», con confirmación) cierra la app con window.CajaViva.salir()
        pagina.addJavascriptInterface(new Puente(), "CajaViva");
        setContentView(pagina);
        pantallaCompleta();
        pagina.loadUrl(INICIO);
    }

    // Sin barras del sistema; reaparecen un momento al deslizar desde el borde
    private void pantallaCompleta() {
        if (Build.VERSION.SDK_INT >= 30) {
            getWindow().setDecorFitsSystemWindows(false);
            WindowInsetsController control = getWindow().getInsetsController();
            if (control != null) {
                control.hide(WindowInsets.Type.statusBars() | WindowInsets.Type.navigationBars());
                control.setSystemBarsBehavior(WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
            }
        } else {
            getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                    | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    | View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
        }
    }

    @Override
    public void onWindowFocusChanged(boolean conFoco) {
        super.onWindowFocusChanged(conFoco);
        if (conFoco) pantallaCompleta();
    }

    // El botón «atrás»: el juego cierra lo que esté abierto, vuelve a la sala o abre su menú de pausa; solo en el menú
    // de inicio la app pasa a segundo plano (sin perder la partida)
    @Override
    public void onBackPressed() {
        pagina.evaluateJavascript("(window.__atras ? window.__atras() : false)", new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String hecho) {
                if (!"true".equals(hecho)) moveTaskToBack(true);
            }
        });
    }

    // Al salir de la app, el juego se calla y se para; al volver, sigue
    @Override
    protected void onPause() {
        pagina.evaluateJavascript("window.__pausa && window.__pausa(true)", null);
        pagina.onPause();
        pagina.pauseTimers();
        super.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        pagina.resumeTimers();
        pagina.onResume();
        pagina.evaluateJavascript("window.__pausa && window.__pausa(false)", null);
        pantallaCompleta();
    }

    @Override
    protected void onDestroy() {
        if (pagina != null) {
            pagina.destroy();
            pagina = null;
        }
        super.onDestroy();
    }

    // Lo único que la página puede pedirle a Android: cerrar el juego (desde su menú, después de confirmarlo)
    private class Puente {
        @JavascriptInterface
        public void salir() {
            runOnUiThread(new Runnable() {
                @Override
                public void run() { finish(); }
            });
        }
    }

    // Sirve la página desde assets/web/ (la ruta de la dirección es la ruta dentro de assets)
    private class ClienteLocal extends WebViewClient {
        @Override
        public WebResourceResponse shouldInterceptRequest(WebView vista, WebResourceRequest peticion) {
            Uri direccion = peticion.getUrl();
            if (!DOMINIO.equals(direccion.getHost())) return respuestaVacia(404, "Fuera de la app");
            return servirRecurso(direccion.getPath());
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView vista, WebResourceRequest peticion) {
            // nada abre otras páginas: el juego entero está aquí
            return !DOMINIO.equals(peticion.getUrl().getHost());
        }
    }

    private WebResourceResponse servirRecurso(String ruta) {
        if (ruta == null || ruta.contains("..")) return respuestaVacia(404, "No encontrado");
        String archivo = ruta.startsWith("/") ? ruta.substring(1) : ruta;
        try {
            InputStream datos = getAssets().open(archivo);
            String tipo = tipoMime(archivo);
            WebResourceResponse respuesta = new WebResourceResponse(tipo, tipo.startsWith("text/") || tipo.endsWith("json") ? "utf-8" : null, datos);
            Map<String, String> cabeceras = new HashMap<>();
            cabeceras.put("Cache-Control", "no-store");
            cabeceras.put("Access-Control-Allow-Origin", "*");
            respuesta.setResponseHeaders(cabeceras);
            return respuesta;
        } catch (IOException e) {
            return respuestaVacia(404, "No encontrado");
        }
    }

    private static WebResourceResponse respuestaVacia(int codigo, String motivo) {
        return new WebResourceResponse("text/plain", "utf-8", codigo, motivo, new HashMap<String, String>(),
                new ByteArrayInputStream(new byte[0]));
    }

    private static String tipoMime(String archivo) {
        String extension = archivo.substring(archivo.lastIndexOf('.') + 1).toLowerCase();
        switch (extension) {
            case "html": return "text/html";
            case "js": case "mjs": return "text/javascript";
            case "json": return "application/json";
            case "css": return "text/css";
            case "webp": return "image/webp";
            case "png": return "image/png";
            case "jpg": case "jpeg": return "image/jpeg";
            case "svg": return "image/svg+xml";
            case "wav": return "audio/wav";
            case "woff2": return "font/woff2";
            case "txt": return "text/plain";
            default: return "application/octet-stream";
        }
    }
}
