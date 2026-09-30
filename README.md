# Movie Application 🎬

![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart)

Ứng dụng xem phim viết bằng Flutter: duyệt phim từ [TMDB](https://www.themoviedb.org), đăng nhập, lưu watchlist lên cloud và vote phim cùng bạn bè theo thời gian thực. **0 đồng chi phí phát triển** (TMDB và Supabase đều có gói miễn phí).

Quy tắc code: [rule.md](rule.md) · Bộ khung tham khảo: [weather_application](../weather_application)

> **Trạng thái:** mới khởi tạo project, chưa có tính năng nào. Mục dưới là kế hoạch.

## Tính năng dự kiến

- **Duyệt phim**: đang chiếu, phổ biến, đánh giá cao, phân trang vô hạn
- **Tìm kiếm** (debounce) và **chi tiết phim**: poster, điểm, thể loại, diễn viên, trailer
- **Đăng nhập** (Supabase Auth)
- **Watchlist**: lưu lên database, đồng bộ giữa các máy
- **Phòng vote phim**: tạo phòng, mời bạn, vote realtime để chọn phim xem chung
- Dark mode, Tiếng Việt/English, xử lý đủ trạng thái loading / lỗi / rỗng

## Công nghệ

Giữ nguyên bộ khung của weather app để tái sử dụng.

| Hạng mục | Lựa chọn |
|---|---|
| State management | Riverpod (codegen `@riverpod`) |
| Router | go_router |
| Network | dio, không tự viết interceptor |
| Model | freezed + json_serializable |
| Dữ liệu phim | TMDB API v3 |
| Backend | Supabase (Auth, Postgres + RLS, Realtime) |
| UI | Material 3 |
| Đa ngôn ngữ | `flutter_localizations` + `.arb` (vi, en) |
| Test | flutter_test + mocktail |

## Kiến trúc

Clean Architecture theo feature (`data` / `domain` / `presentation`), **không có lớp usecase**: provider gọi thẳng repository. Lỗi đi theo luồng datasource → exception → repository `guard()` → `Result<T>` → UI `.when(...)`. Chi tiết trong [rule.md](rule.md).

```
lib/
├── core/          # network, error, router, theme, widgets dùng chung
└── features/      # movies, auth, watchlist, rooms ...
```

## Chạy project

Cần Flutter 3.47+ (Dart 3.13+). File sinh ra (`*.g.dart`, `*.freezed.dart`, l10n) không commit, nên phải generate sau khi clone:

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter run
```

Khi đã có tích hợp TMDB/Supabase, key sẽ truyền qua `--dart-define-from-file` (file thật đã gitignore, chỉ commit `*.example.json`).

Chạy test:

```bash
flutter test
```

## Credits

- Dữ liệu phim và poster: [TMDB](https://www.themoviedb.org). *This product uses the TMDB API but is not endorsed or certified by TMDB.*
