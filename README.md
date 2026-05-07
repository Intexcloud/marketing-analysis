# 📊 Global Ads Performance — End-to-End Analysis

> **Analisis komprehensif performa iklan digital lintas platform, campaign type, industri, dan negara.**  
> Dataset: `global_ads_performance_dataset.csv` · 1 800 baris · 14 kolom · Periode: 2024

---

## 🗂️ Daftar File

| File | Deskripsi |
|------|-----------|
| `README.md` | Dokumen ini — panduan lengkap proyek |
| `global_ads_analysis.ipynb` | Jupyter Notebook: EDA, visualisasi, A/B testing, insight |
| `global_ads_queries.sql` | Query SQL lengkap: eksplorasi, agregasi, segmentasi |
| `global_ads_performance_dataset.csv` | Dataset mentah |

---

## 🧩 Business Problem yang Diselesaikan

### 1. Alokasi Anggaran Platform
> *"Platform mana — Google Ads, Meta Ads, atau TikTok Ads — yang memberikan Return on Ad Spend (ROAS) dan Cost per Acquisition (CPA) terbaik?"*

Perusahaan sering mengalokasikan anggaran iklan secara merata tanpa dasar statistik. Analisis ini mengidentifikasi platform yang secara signifikan unggul sehingga budget dapat dialihkan ke kanal yang paling menguntungkan.

### 2. Efektivitas Tipe Campaign
> *"Apakah campaign Video, Search, Shopping, atau Display menghasilkan konversi dan pendapatan lebih tinggi?"*

Memilih format iklan yang salah membuang anggaran. A/B testing antar tipe campaign menunjukkan mana yang benar-benar menggerakkan pendapatan vs. sekadar menghasilkan tayangan.

### 3. Optimasi Pasar Geografis
> *"Negara dan industri mana yang harus diprioritaskan untuk ekspansi?"*

Tidak semua pasar sama efisiennya. Analisis CPA dan ROAS per negara membantu memfokuskan investasi pada pasar yang paling responsif.

### 4. Tren Performa Temporal
> *"Apakah ada pola musiman dalam CTR, ad spend, dan revenue?"*

Memahami kapan performa memuncak memungkinkan penjadwalan kampanye yang lebih cerdas dan pengalokasian anggaran harian/bulanan yang optimal.

---

## 📐 Struktur Dataset

| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `date` | string/date | Tanggal kampanye |
| `platform` | kategori | Google Ads / Meta Ads / TikTok Ads |
| `campaign_type` | kategori | Search / Video / Shopping / Display |
| `industry` | kategori | Fintech / EdTech / Healthcare / SaaS / E-commerce |
| `country` | kategori | UAE / UK / USA / Germany / Canada / India / Australia |
| `impressions` | int | Jumlah tayangan iklan |
| `clicks` | int | Jumlah klik |
| `CTR` | float | Click-Through Rate (clicks/impressions) |
| `CPC` | float | Cost per Click (USD) |
| `ad_spend` | float | Total belanja iklan (USD) |
| `conversions` | int | Jumlah konversi |
| `CPA` | float | Cost per Acquisition (USD) |
| `revenue` | float | Pendapatan dari kampanye (USD) |
| `ROAS` | float | Return on Ad Spend (revenue/ad_spend) |

---

## 🔑 Key Metrics Glossary

- **CTR** (Click-Through Rate): Persentase orang yang mengklik iklan setelah melihatnya. Semakin tinggi = semakin relevan iklan.  
- **CPC** (Cost per Click): Biaya per klik. Semakin rendah = efisiensi lebih baik.  
- **CPA** (Cost per Acquisition): Biaya untuk mendapatkan satu konversi. Semakin rendah = lebih efisien.  
- **ROAS** (Return on Ad Spend): Revenue dibagi ad spend. > 1 = profitable. Target industri umumnya ≥ 4.  
- **Conversion Rate**: Konversi / Klik. Mengukur kualitas lalu lintas yang masuk.

---

## 🧪 A/B Testing Methodology

Analisis menggunakan tiga pendekatan statistik:

1. **Mann-Whitney U Test** — Perbandingan dua platform/campaign (non-parametrik, cocok untuk data tidak normal)  
2. **Kruskal-Wallis Test** — Perbandingan simultan >2 grup  
3. **Dunn's Post-hoc Test** — Identifikasi pasangan mana yang berbeda signifikan (dengan koreksi Bonferroni)

Threshold signifikansi: **α = 0.05**

### Hipotesis yang Diuji

| # | Hipotesis Nol (H₀) | Metrik |
|---|-------------------|--------|
| 1 | Semua platform memiliki ROAS yang sama | ROAS |
| 2 | Semua platform memiliki CPA yang sama | CPA |
| 3 | Semua tipe campaign memiliki CTR yang sama | CTR |
| 4 | Semua tipe campaign menghasilkan revenue yang sama | Revenue |
| 5 | Semua platform memiliki CTR yang sama | CTR |
| 6 | Semua campaign type memiliki ROAS yang sama | ROAS |

---

## 🚀 Cara Menjalankan

### Prerequisites
```bash
pip install pandas numpy scipy statsmodels matplotlib seaborn jupyter nbformat
```

### Jupyter Notebook
```bash
jupyter notebook global_ads_analysis.ipynb
```

### SQL (SQLite)
```bash
# Import ke SQLite
sqlite3 ads.db
.mode csv
.import global_ads_performance_dataset.csv ads_performance
# Jalankan query dari global_ads_queries.sql
```

### SQL (PostgreSQL / MySQL)
```sql
-- Buat tabel terlebih dahulu (lihat global_ads_queries.sql bagian DDL)
-- Kemudian import data via COPY atau LOAD DATA
```

---

## 💡 Ringkasan Temuan Utama

> Detail lengkap ada di notebook dan query SQL.

1. **Platform**: Meta Ads unggul dalam ROAS rata-rata; TikTok Ads memiliki CTR tertinggi namun CPA lebih tinggi di beberapa industri.  
2. **Campaign Type**: Video campaign menghasilkan CTR tertinggi; Search campaign memiliki CPA terendah (konversi paling efisien).  
3. **Industri**: E-commerce dan SaaS menunjukkan ROAS tertinggi secara konsisten lintas platform.  
4. **Geografi**: USA dan UK merupakan pasar dengan revenue absolut tertinggi; India memiliki CPC terendah dengan volume konversi yang besar.  
5. **Seasonality**: Terdapat lonjakan performa pada Q4 (Oktober–Desember) yang konsisten dengan pola belanja akhir tahun.

---

## 📬 Rekomendasi Strategis

| Prioritas | Rekomendasi | Dampak Estimasi |
|-----------|-------------|-----------------|
| 🔴 Tinggi | Realokasi 30% budget dari platform dengan ROAS rendah ke platform terbaik | +15–25% overall ROAS |
| 🔴 Tinggi | Perbanyak Video campaign untuk industri EdTech & E-commerce | +20% CTR |
| 🟡 Sedang | Perluas investasi di pasar India (CPC rendah, volume tinggi) | Efisiensi +30% |
| 🟡 Sedang | Tingkatkan budget Q4 sebesar 40% berdasarkan tren musiman | Revenue +18% |
| 🟢 Rendah | Hentikan Display campaign untuk Healthcare (CPA tertinggi) | Penghematan 8% |

---

## 🛠️ Tech Stack

- **Python 3.10+**: pandas, numpy, scipy, statsmodels, matplotlib, seaborn  
- **SQL**: SQLite / PostgreSQL / MySQL compatible  
- **Jupyter**: Notebook interaktif dengan visualisasi inline

---

*Dibuat sebagai bagian dari analisis marketing intelligence — 2024*
