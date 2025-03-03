# Oto Yedek Parça Yönetim Sistemi

Otomotiv yedek parça stok yönetimi için geliştirilmiş bir web uygulaması.

## Proje Yapısı

Proje, iki ana bölümden oluşur:

- **backend/** - Go ile yazılmış API sunucusu
- **frontend/** - Flutter ile yazılmış web uygulaması

## Geliştirme Ortamı

### Gereksinimler

- Go 1.24 veya üzeri
- Flutter SDK
- Docker ve Docker Compose
- PostgreSQL 14

### Geliştirme Ortamında Çalıştırma

#### Ayrı Ayrı Çalıştırma

1. Go sunucusunu başlatın:
```bash
cd backend && go run cmd/server/main.go
```

2. Flutter uygulamasını başlatın:
```bash
cd frontend && flutter run -d chrome
```

#### Docker ile Çalıştırma

Tüm sistemin Docker ile çalıştırılması:
```bash
# Tüm sistemi başlatmak için
./deploy.sh

# Sadece backend için
cd backend && ./deploy.sh

# Sadece frontend için
cd frontend && ./deploy.sh
```

### Üretim Ortamını Yerelde Test Etme

1. Flutter web uygulamasını derleyin:
```bash
# Web için üretim derlemesi
cd frontend
flutter build web --release \
  --dart-define=API_BASE_URL=http://localhost:8080 \
  --dart-define=API_URL=http://localhost:8080 \
  --dart-define=FLUTTER_DEV=false
```

2. Derlenen web uygulamasını test etmek için:

a) Python ile basit HTTP sunucusu:
```bash
cd frontend/build/web
python3 -m http.server 9090
```

b) Veya Node.js ile serve paketi kullanarak:
```bash
# Eğer serve paketi yüklü değilse
npm install -g serve

# Web uygulamasını çalıştır
cd frontend/build/web
serve -s . -l 9090
```

3. Tarayıcıda http://localhost:9090 adresine giderek uygulamayı test edin

4. Go API sunucusunu başlatın (farklı bir terminal penceresinde):
```bash
cd backend && go run cmd/server/main.go
```

Not: API sunucusu 8080 portunda, web uygulaması 9090 portunda çalışacaktır.

## Canlıya Alma (Production)

### 1. Ortam Değişkenlerini Ayarlama

1. Ortam değişkenlerini düzenleyin (kök dizinde `.env` dosyası oluşturun):
```bash
# Veritabanı ayarları
POSTGRES_USER=postgres
POSTGRES_PASSWORD=securepassword
POSTGRES_DB=autoparts
DB_HOST=db
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=securepassword
DB_NAME=autoparts
DB_SSL_MODE=disable

# Web port ayarları
DEV_PORT=8080
WEB_PORT=80

# API URL ayarları
FLUTTER_APP_BASE_URL=http://localhost:8080
FLUTTER_APP_API_URL=http://localhost:8080/api
```

### 2. Docker ile Dağıtım

1. Docker imajlarını oluşturun ve başlatın:
```bash
./deploy.sh
```

2. Servislerin durumunu kontrol edin:
```bash
docker-compose ps
```

3. Logları kontrol edin:
```bash
docker-compose logs -f
```

### 3. SSL Sertifikaları ile Güvenli Dağıtım

1. SSL sertifikaları için dizin oluşturun:
```bash
mkdir -p ssl
```

2. SSL sertifikalarınızı `ssl/` dizinine yerleştirin.

3. Nginx konfigürasyonunu SSL için güncelleyin (frontend/nginx.conf dosyasında).

### 4. Güvenlik Kontrolleri

- [ ] Güçlü şifreler kullanıldığından emin olun
- [ ] Tüm hassas bilgilerin şifrelendiğini kontrol edin
- [ ] Firewall kurallarını yapılandırın
- [ ] SSL sertifikalarının geçerli olduğunu doğrulayın
- [ ] Veritabanı yedekleme sistemini test edin

## Yardımcı Kaynaklar

- [Flutter Dokümantasyonu](https://docs.flutter.dev/)
- [Go Dokümantasyonu](https://golang.org/doc/)
- [Docker Dokümantasyonu](https://docs.docker.com/)
- [PostgreSQL Dokümantasyonu](https://www.postgresql.org/docs/)
