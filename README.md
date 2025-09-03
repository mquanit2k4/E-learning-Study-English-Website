# E-learning System

# 1. Phiên bản cài đặt để chạy được dự án:
- Ruby: 3.2.2
- Rails: 7.0.7
- MySQL

# 2. Hướng dẫn cài dự án:
## 2.1 Cài đặt config(chỉ chạy lần đầu)
- Tạo config database cho dự án: cp config/database.yml.example config/database.yml với config như sau:
  <img width="472" height="215" alt="image" src="https://github.com/user-attachments/assets/e2189577-29aa-4d5d-9225-1fdeb615f305" />
- File .env được lưu trong laptop cá nhân
- Chạy lệnh để tạo database: rails db:create
- Bật server: rails s
Truy cập đường dẫn http://localhost:3000/ hiển thị Rails là thành công


