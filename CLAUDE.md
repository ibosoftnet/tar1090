# tar1090 — Claude Notları

## Proje Özeti

ADS-B uçak takip arayüzü (atc.ibosoft.net.tr). OpenLayers tabanlı. Upstream: tar1090 v3.14.1801.

Bu repo IBOSOFT tarafından özelleştirilmiş — ais-map SDK'sını entegre eder ve birçok UI değişikliği içerir.

## Dizin Yapısı

- `html/` — Web arayüzü dosyaları (tüm IBOSOFT değişiklikleri burada)
- `html/flags.js` — IBOSOFT tarafından tamamen yeniden yazılmış
- `html/defaults.js` — IBOSOFT değer overrideleri içeriyor
- `html/index.html` — AIS Map SDK entegrasyonu + UI değişiklikleri
- `html/layers.js` — Boş createBaseLayers() — AIS Map SDK tüm katmanları yönetiyor
- `html/script.js` — ol_map_init rewrite (AIS SDK), legend, flagFilter
- `html/formatter.js` — "NM" birimi, nav mode kısaltmaları
- `html/style.css` — z-index ayarlamaları

## IBOSOFT Değişiklik Kuralları

- Yeni eklentilerin başına: `// IBOSOFT CUSTOMIZATION`
- Orijinal kodu silme yerine yorum satırına al: `// IBOSOFT CUSTOMIZATION: REMOVED`
- Türkiye'yi "Türkiye" olarak yaz (Turkey değil)

## AIS Map SDK Entegrasyonu

tar1090, kendi `new ol.Map()` oluşturmak yerine AIS Map SDK haritasını kullanır:

```html
<!-- index.html -->
<script>
  window.AisMapConfigOverrides = {
    disableProjectionSelection: true,
    defaultDim: 30,
    addDefaultLayers: ['Surveillance 1090 MHz Coverage', ...]
  };
  window.AisMapOnReady = function () { AisMap.init({ target: 'map_canvas' }); };
</script>
<script src="https://ais-map.ibosoft.net.tr/ais-map-loader.js"></script>
```

```javascript
// script.js — ol_map_init()
OLMap = window.AisMap.getMap();       // SDK haritasını al
OLMap.addLayer(layers_group);          // tar1090 uçak katmanlarını ekle
```

- `layers.js`: `createBaseLayers()` boş döner — SDK tüm base/overlay katmanları sağlar
- ol-layerswitcher kaldırıldı — SDK'nın kendi katman paneli var

## Önemli Özelleştirmeler

### defaults.js
- `DefaultZoomLvl`: 7 (Türkiye görünümü)
- `DefaultCenterLat/Lon`: 39.0 / 33.0 (Türkiye merkezi)
- `MapType_tar1090`: `"esri_gray"`
- `ColorByAlt`: Monokrom yeşil şema
- `SiteName` / `PageName`: "Ibosoft Surveillance"
- `shareBaseUrl`: `'https://atc.ibosoft.net.tr/surveillance/'`
- `askLocation`: `false` — konum AIS Map SDK tarafından yönetiliyor

### index.html — Bölüm Sırası
ALTITUDE → SPEED → DIRECTION → FMS / MCP MODES → WIND → ADS-B STUFF → SIGNAL → ACCURACY

- `nav_qnh` → FMS / MCP MODES altında "SEL BARO" olarak
- `nav_modes` → FMS / MCP MODES altında "Nav. Modes" olarak
- `pos_epoch` → SIGNAL bölümünde

### script.js
- Legend: Mode S kategorileri (No ADS-B Position / ADS-B Position / Non-transponder)
- Source filter sırası: Mode S → ADS-B → TIS-B → UAT → MLAT → ACARS → Other
- `initFlagFilter`: Military/PIA/LADD filtreleri devre dışı

### formatter.js
- Mesafe birimi: `"nmi"` → `"NM"`
- Nav mode etiketleri: autopilot→AP, vnav→VNAV, alt_hold→ALT HOLD, approach→APP, lnav→LNAV, tcas→TCAS

### style.css
- `#selected_infoblock` z-index: 100
- `#splitter` z-index: 1000
- `.ol-control button` z-index: 200 !important

## Upstream Güncelleme Prosedürü

Yeni tar1090 sürümüne geçerken:
1. `flags.js` — IBOSOFT versiyonu doğrudan kullan (upstream'den alma)
2. `config.js` — atla (geçersiz/kullanılmaz)
3. Diğer dosyalar — `// IBOSOFT CUSTOMIZATION` yorumlarını rehber olarak kullan
4. `referans/` klasörü ile diff alarak değişiklikleri tespit et
