# IPMA — Tempo e Mar

Aplicação Android não-oficial para Portugal, construída sobre os dados abertos do **[IPMA](https://www.ipma.pt/)** (`api.ipma.pt`). Apresenta previsão diária, previsão horária, estado do mar, observações de estações reais, risco de incêndio, índice UV, avisos meteorológicos e uma vista nacional — com uma interface mais limpa do que o site oficial.

> Unofficial Android app surfacing Portuguese weather, sea-state and wildfire data from the public IPMA Open Data API.

---

## Instalar

Vai à [página de releases](https://github.com/ianmooonee/ipma_apk/releases) e descarrega o ficheiro `ipma-vX.Y.Z.apk` mais recente. Abre-o no telemóvel — o Android pedirá permissão para instalar uma app fora da Play Store.

A app verifica novas versões na própria página de Releases sempre que abre. Quando há uma nova, aparece um botão **Atualizar** no topo do ecrã que descarrega e instala o novo APK automaticamente.

---

## Funcionalidades

- **Previsão diária** (5 dias) para qualquer concelho de Portugal continental ou ilhas, com mín./máx., precipitação, UV e ícone do tipo de tempo.
- **Previsão horária** integrada no cartão principal (24 h).
- **Estado do mar** (ondulação, direção, período, temperatura da água) — quando o concelho selecionado não tem estação marítima, usa automaticamente a costa adjacente (ex.: Coimbra ⇒ Figueira da Foz).
- **Observações em tempo real** das estações IPMA mais próximas (temperatura, humidade, vento, pressão, precipitação e radiação). Selecionável entre as estações da zona.
- **Risco de incêndio (RCM)** do dia.
- **Avisos meteorológicos** por área (cor + descrição).
- **Tendência de 20 dias** da temperatura média do concelho.
- **Vista nacional** — previsão de capitais de distrito em três dias.
- Tema claro/escuro automático, totalmente em Português.

---

## Tecnologia

- Flutter 3.x / Dart 3.x
- Estado: `Provider` + `ChangeNotifier`
- Persistência: `shared_preferences` (última cidade, cache de localizações)
- Dados:
  - `api.ipma.pt/open-data/distrits-islands.json` — localizações
  - `api.ipma.pt/public-data/forecast/aggregate/{id}.json` — agregado diário + horário + mar
  - `hp-daily-sea-forecast-day{0,1,2}.json` — fallback de mar
  - `weather-warning-www.json`, `rcm.json`, `uv.json`, `obs-surface.geojson`, `t2m-p1d-…-concelhos-20d.csv`

---

## Atualizações automáticas

A app inclui um verificador que consulta `api.github.com/repos/ianmooonee/ipma_apk/releases/latest`, compara a tag com a versão local e oferece a atualização in-app. Ver [`docs/RELEASING.md`](docs/RELEASING.md) para o fluxo de publicação.

---

## Desenvolvimento

```bash
flutter pub get
flutter run -d chrome      # ou -d <id-do-emulador>
flutter analyze
flutter build apk --release
```

---

## Créditos

- Dados meteorológicos: **Instituto Português do Mar e da Atmosfera (IPMA)**
- Esta aplicação **não** é oficial nem afiliada ao IPMA.
