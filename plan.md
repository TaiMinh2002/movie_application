# Movie App – Kế hoạch phát triển

> Hai mục tiêu nối tiếp: **(1) Portfolio/CV** (2–3 tuần), **(2) Bản thương mại** (sau đó). Quy tắc code xem [rule.md](rule.md).

## Mục lục

1. [Định vị và lưu ý pháp lý](#1-định-vị-và-lưu-ý-pháp-lý)
2. [Tính năng](#2-tính-năng)
3. [Màn hình](#3-màn-hình)
4. [Công nghệ](#4-công-nghệ)
5. [TMDB API](#5-tmdb-api)
6. [Database Supabase](#6-database-supabase)
7. [Kiến trúc thư mục](#7-kiến-trúc-thư-mục)
8. [Lộ trình](#8-lộ-trình)
9. [Kiếm tiền](#9-kiếm-tiền)
10. [Checklist CV và checklist prod](#10-checklist-cv-và-checklist-prod)

---

## 1. Định vị và lưu ý pháp lý

**Đây là app khám phá + theo dõi phim, KHÔNG phát phim.** Không có nguồn phim hợp pháp miễn phí; nhúng link phim lậu sẽ bị gỡ khỏi Store và làm hỏng CV. TMDB chỉ trả metadata (poster, mô tả, điểm, trailer YouTube), nên đúng hướng.

**Điểm khác biệt (để không giống hàng trăm app TMDB khác):** *"Tối nay xem gì cùng nhau?"* — phòng vote phim realtime cho nhóm bạn/cặp đôi, kèm watchlist chung và gợi ý theo nơi xem (Netflix, Disney+...). Đây cũng là phần thể hiện kỹ năng backend/realtime trên CV.

**Rủi ro phải xử lý trước khi kiếm tiền:**

| Vấn đề | Thực tế | Cách xử lý |
|---|---|---|
| TMDB API miễn phí | Chỉ cho dùng **phi thương mại**. App có quảng cáo/thu phí cần **giấy phép thương mại** từ TMDB | Giai đoạn CV dùng free. Trước khi bật monetization: liên hệ TMDB hỏi giá/điều khoản, hoặc đổi nguồn dữ liệu. Kiểm tra lại điều khoản mới nhất trên trang TMDB |
| Dữ liệu "xem ở đâu" | TMDB lấy từ JustWatch, bắt buộc ghi credit | Hiện logo/credit JustWatch ở màn chi tiết |
| Logo/credit TMDB | Bắt buộc có | Đã có trong README, thêm vào màn Cài đặt → Giới thiệu |
| Apple/Google | Có đăng nhập tài khoản thì phải có **xóa tài khoản trong app** và privacy policy | Làm ngay từ MVP, đỡ sửa sau |

> Vì vậy kiến trúc phải **tách TMDB sau `MovieRepository`** để đổi nguồn dữ liệu mà không đụng UI.

---

## 2. Tính năng

### 2.1. MVP cho CV (bắt buộc)

| # | Tính năng | Ghi chú kỹ thuật |
|---|---|---|
| 1 | Trang chủ theo mục | Đang chiếu, Phổ biến, Đánh giá cao, Sắp chiếu; list ngang, "Xem tất cả" phân trang vô hạn |
| 2 | Tìm kiếm phim | Debounce, phân trang, lưu lịch sử tìm gần đây |
| 3 | Lọc theo thể loại | Genre chips, sắp xếp (phổ biến/điểm/ngày) qua `/discover/movie` |
| 4 | Chi tiết phim | Poster, backdrop, điểm, thời lượng, thể loại, mô tả, diễn viên, trailer, phim tương tự, nơi xem |
| 5 | Đăng nhập | Supabase Auth: email + Google (Apple bắt buộc nếu có Google trên iOS) |
| 6 | Watchlist | 2 trạng thái: *Muốn xem* / *Đã xem* (kèm chấm điểm cá nhân 1–10); lưu database, đồng bộ nhiều máy |
| 7 | Phòng vote phim | Tạo phòng → mã mời 6 ký tự → thành viên thêm phim đề cử → vote → chốt phim thắng. **Realtime** (Supabase Realtime) |
| 8 | Cài đặt | Sáng/tối/hệ thống, Việt/Anh, xóa tài khoản, đăng xuất, giới thiệu + credit |
| 9 | Xử lý trạng thái | Skeleton, lỗi mạng + thử lại, rỗng, chưa đăng nhập (guest xem được, lưu watchlist thì yêu cầu đăng nhập) |
| 10 | Offline cơ bản | Cache trang chủ và watchlist gần nhất |

### 2.2. Sau MVP (chọn theo giá trị thương mại)

| Tính năng | Giá trị | Độ khó |
|---|---|---|
| Thông báo: phim sắp chiếu trong watchlist, phòng có người vote/chốt | Giữ chân người dùng (retention) | Trung bình (FCM + Supabase Edge Function) |
| Thống kê cá nhân: số phim, giờ xem, thể loại yêu thích | Thích chia sẻ, là tính năng Premium | Dễ |
| Danh sách tùy chỉnh (collection) công khai/riêng tư, chia sẻ link | Lan truyền | Trung bình |
| Gợi ý "hợp cả nhóm" trong phòng (giao các thể loại/điểm của thành viên) | Khác biệt lớn, dễ kể trên CV | Trung bình |
| Lọc theo dịch vụ đang dùng (Netflix, ...) và khu vực | Rất hữu ích, cần credit JustWatch | Dễ |
| Deep link mở phòng từ tin nhắn (`app_links`) | Mời bạn dễ | Trung bình |
| Review/bình luận công khai | **Cần kiểm duyệt nội dung** (Store yêu cầu report/block); chỉ làm khi có đủ sức | Khó |
| Widget màn hình chính, Apple Watch | Nice-to-have | Khó |

**Không làm:** phát phim, tải phim, chat tự do (kéo theo kiểm duyệt), mạng xã hội đầy đủ.

---

## 3. Màn hình

**MVP: 11 màn + 4 bottom sheet.** Bottom nav 4 tab: *Khám phá · Tìm kiếm · Watchlist · Phòng*, Cài đặt vào từ avatar ở Khám phá.

| # | Màn hình | Nội dung chính | Route |
|---|---|---|---|
| 1 | Onboarding | 3 trang giới thiệu, hiện một lần | `/onboarding` |
| 2 | Đăng nhập / Đăng ký | Một màn, đổi chế độ; email, Google, Apple; "Tiếp tục với tư cách khách"; quên mật khẩu là sheet | `/auth` |
| 3 | Khám phá (Home) | Banner phim nổi bật, các list ngang theo mục, genre chips | `/` |
| 4 | Xem tất cả | Lưới phim phân trang vô hạn theo mục/thể loại, bộ lọc + sắp xếp | `/movies?kind=` |
| 5 | Tìm kiếm | Ô tìm, lịch sử, kết quả lưới phân trang | `/search` |
| 6 | Chi tiết phim | Backdrop, nút Watchlist, Trailer, Thêm vào phòng, diễn viên, tương tự, nơi xem | `/movie/:id` |
| 7 | Chi tiết diễn viên | Tiểu sử, phim đã đóng | `/person/:id` |
| 8 | Watchlist | Tab *Muốn xem* / *Đã xem*, sắp xếp, vuốt để xóa (có hoàn tác) | `/watchlist` |
| 9 | Danh sách phòng | Phòng của tôi, nút Tạo / Nhập mã | `/rooms` |
| 10 | Chi tiết phòng | Thành viên, danh sách đề cử + số vote realtime, chốt phim, mã mời/chia sẻ | `/rooms/:id` |
| 11 | Cài đặt | Theme, ngôn ngữ, tài khoản, xóa tài khoản, về app + credit | `/settings` |

**Bottom sheet / dialog:** Trailer player (YouTube), Tạo phòng, Nhập mã phòng, Chấm điểm phim đã xem.

**Thêm khi lên prod:** Paywall (Premium), Chính sách/Điều khoản (webview), Thống kê cá nhân. → khoảng 13–14 màn.

Mỗi màn phải có đủ 3 trạng thái loading/error/empty (xem rule.md mục 6).

---

## 4. Công nghệ

Kế thừa bộ khung weather; cái **mới** in đậm.

| Hạng mục | Lựa chọn |
|---|---|
| State / Router / Network / Model | Riverpod codegen · go_router · dio · freezed + json_serializable |
| Backend | **supabase_flutter** (Auth, Postgres + RLS, Realtime, Edge Functions) |
| Ảnh | **cached_network_image** (qua một widget chung) |
| Trailer | **youtube_player_iframe** hoặc mở app YouTube qua `url_launcher` (đơn giản hơn, ưu tiên nếu ngại lỗi nền tảng) |
| Đăng nhập Google/Apple | **google_sign_in**, **sign_in_with_apple** |
| Phân trang | Tự viết trong notifier (không thêm package) |
| Thanh toán (prod) | **purchases_flutter (RevenueCat)** – miễn phí tới ngưỡng doanh thu nhất định |
| Quảng cáo (prod, tùy chọn) | **google_mobile_ads** |
| Theo dõi (prod) | **firebase_crashlytics**, **firebase_analytics** |
| Thông báo (sau MVP) | **firebase_messaging** |
| Test / CI | flutter_test + mocktail · GitHub Actions (analyze, test, build APK) |

---

## 5. TMDB API

Base `https://api.themoviedb.org/3`, ảnh `https://image.tmdb.org/t/p/{size}/{path}`. Dùng `language=vi-VN` (fallback en nếu thiếu mô tả).

| Mục đích | Endpoint |
|---|---|
| Đang chiếu / Phổ biến / Đánh giá cao / Sắp chiếu | `/movie/now_playing`, `/movie/popular`, `/movie/top_rated`, `/movie/upcoming` (`page`) |
| Danh sách thể loại | `/genre/movie/list` |
| Lọc + sắp xếp | `/discover/movie?with_genres=&sort_by=&page=` |
| Tìm kiếm | `/search/movie?query=&page=` |
| Chi tiết gộp một lần gọi | `/movie/{id}?append_to_response=credits,videos,similar,watch/providers` |
| Diễn viên | `/person/{id}?append_to_response=movie_credits` |

Lưu ý: dùng **API Read Access Token** (header `Authorization: Bearer`), không để key trong query; truyền bằng `--dart-define-from-file`. Khi lên prod, **không để token TMDB lộ trong app** – cho gọi qua Supabase Edge Function làm proxy + cache (cũng giúp giảm rate limit).

---

## 6. Database Supabase

Mọi bảng bật RLS. Chỉ lưu `tmdb_id` và vài trường cần hiển thị, không sao chép cả dữ liệu TMDB.

| Bảng | Cột chính | Policy |
|---|---|---|
| `profiles` | `id` (= auth.uid), `display_name`, `avatar_url`, `created_at` | đọc: thành viên cùng phòng; ghi: chính chủ |
| `watchlist_items` | `user_id`, `tmdb_id`, `status` (`want`/`watched`), `rating` (1–10, null), `title`, `poster_path`, `added_at`; unique (`user_id`,`tmdb_id`) | chỉ chính chủ |
| `rooms` | `id`, `name`, `invite_code` (unique), `owner_id`, `status` (`open`/`closed`), `winner_tmdb_id`, `created_at` | đọc: thành viên; tạo: user đăng nhập; sửa: owner |
| `room_members` | `room_id`, `user_id`, `joined_at` | đọc: thành viên; vào phòng qua RPC `join_room(code)` |
| `room_movies` | `id`, `room_id`, `tmdb_id`, `title`, `poster_path`, `added_by` | đọc/ghi: thành viên phòng `open` |
| `room_votes` | `room_movie_id`, `user_id`, unique (`room_movie_id`,`user_id`) | thành viên; mỗi người 1 phiếu/phim, có thể rút |

Realtime: subscribe `room_movies` + `room_votes` theo `room_id`. Đếm vote bằng view hoặc tính ở client từ danh sách phiếu.
Xóa tài khoản: RPC/Edge Function xóa `auth.users` → cascade các bảng trên.
Lưu schema vào `supabase/schema.sql` (idempotent, chạy lại không lỗi).

---

## 7. Kiến trúc thư mục

```
lib/
├── core/          # network (dio), error (Result/Failure), router, theme, storage,
│                  # widgets chung (AppErrorView, PosterImage, MovieCard, skeleton)
├── features/
│   ├── movies/    # TMDB: home, list phân trang, detail, person, search
│   ├── auth/      # đăng nhập, phiên, xóa tài khoản
│   ├── watchlist/
│   ├── rooms/     # phòng, đề cử, vote realtime
│   ├── settings/
│   └── onboarding/
└── l10n/
supabase/schema.sql
```

- `MovieRepository` (abstract, `domain/`) là ranh giới để đổi nguồn dữ liệu (TMDB → khác/proxy).
- Phân trang: `PagedMovies` notifier giữ `items`, `nextPage`, `hasMore`, `isLoadingMore`; UI chỉ gọi `loadMore()` khi cuộn gần cuối.
- Guest: provider `currentUserProvider` null → nút Watchlist mở màn đăng nhập rồi quay lại.

---

## 8. Lộ trình

Mỗi giai đoạn là một PR vào `dev` (`feature/<tên>`), chạy được độc lập.

| Tuần | Nội dung | Kết quả |
|---|---|---|
| 0 (½ ngày) | Copy bộ khung từ weather: core, theme, l10n, router, CI. Thêm TMDB key vào `--dart-define` | App trống chạy được, CI xanh |
| 1 | `movies`: Home + Xem tất cả + Chi tiết + Tìm kiếm + lọc thể loại, phân trang, skeleton, cache | Duyệt phim hoàn chỉnh (chưa cần backend) |
| 2 | Supabase: Auth + `watchlist` + đồng bộ + Settings + xóa tài khoản + Onboarding | Có tài khoản và watchlist thật |
| 3 | `rooms`: tạo/nhập mã, đề cử, vote realtime, chốt phim | Tính năng "đinh" |
| 3+ | Test (repository, phân trang, vote), ảnh chụp màn hình, README, APK trên Releases | Sẵn sàng đưa lên CV |

**Sau đó, lên prod** (mỗi mục là một PR):

1. Proxy TMDB qua Edge Function + giải quyết giấy phép thương mại
2. Crashlytics + Analytics
3. Thông báo đẩy (phim sắp chiếu, hoạt động phòng)
4. Premium (RevenueCat) + Paywall; quảng cáo nếu cần
5. Privacy policy, điều khoản, store listing, ảnh/video giới thiệu, TestFlight/closed testing rồi phát hành

---

## 9. Kiếm tiền

Đề xuất **freemium**, đặt giới hạn hợp lý, không chặn tính năng cốt lõi:

| Gói | Nội dung |
|---|---|
| Miễn phí | Duyệt/tìm phim, watchlist không giới hạn, tối đa 2 phòng đang mở, có banner quảng cáo nhẹ (nếu dùng ads) |
| Premium (tháng/năm) | Không quảng cáo, không giới hạn phòng, thống kê cá nhân, gợi ý "hợp cả nhóm", danh sách tùy chỉnh, xuất watchlist |

Lý do: giới hạn theo **phòng** nhắm vào nhóm người dùng hay chia sẻ (tính năng khác biệt), không làm khó người chỉ tra cứu. Ước lượng doanh thu thực tế cần dữ liệu sau khi ra mắt; đừng hứa trước. Cần tính tới phí Store (15–30%) và chi phí Supabase/TMDB khi vượt gói free.

---

## 10. Checklist CV và checklist prod

**Checklist CV (GitHub):**

- [ ] README: mô tả, ảnh chụp, GIF phòng vote realtime, sơ đồ kiến trúc, hướng dẫn chạy, credit TMDB
- [ ] CI xanh (analyze + test + build APK), APK ở Releases
- [ ] Test cho repository, mapper, phân trang, logic vote
- [ ] `supabase/schema.sql` có RLS, giải thích trong README vì sao (bảo mật dữ liệu người dùng)
- [ ] Không lộ key trong repo/lịch sử git
- [ ] Commit theo Conventional Commits, PR nhỏ có mô tả

**Checklist prod:**

- [ ] Giấy phép thương mại TMDB (hoặc nguồn dữ liệu khác)
- [ ] Token TMDB chỉ nằm ở server (Edge Function)
- [ ] Xóa tài khoản trong app, privacy policy, điều khoản
- [ ] Crashlytics + Analytics, kiểm tra Consent theo khu vực (GDPR) nếu phát hành quốc tế
- [ ] Ký app release (không dùng debug key), Sign in with Apple nếu có Google trên iOS
- [ ] Giới hạn tốc độ / chống lạm dụng tạo phòng (rate limit ở Edge Function hoặc RPC)
- [ ] Đã test thanh toán sandbox (Premium) và khôi phục giao dịch
