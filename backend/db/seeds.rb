# frozen_string_literal: true

# ============================================================
# 開発環境用シードデータ
# PostgreSQL から移行した既存データをベースに作成
#
# ログイン情報（パスワードはseed時に再設定）:
#   email: test@example.com  / password: password  (Postresでは「password123」)
#   email: test2@example.com / password: password
#   email: test6@example.com / password: password
# ============================================================

# Departments
departments_data = [
  { name: '営業',     address: '1階', status: 'active' },
  { name: '技術',     address: '2階', status: 'active' },
  { name: '総務',     address: '3階', status: 'active' },
  { name: 'サポート', address: '4階', status: 'active' },
  { name: 'その他', address: '5階', status: 'active' }
]

departments_data.each do |attrs|
  Department.find_or_create_by!(name: attrs[:name]) do |d|
    d.address = attrs[:address]
    d.status  = attrs[:status]
  end
end

puts "departments: #{Department.count}"

# Users
users_data = [
  { email: 'test@example.com',  role: 'staff' },
  { email: 'test2@example.com', role: 'staff' },
  { email: 'test6@example.com', role: 'staff' }
]

users_data.each do |attrs|
  User.find_or_create_by!(email: attrs[:email]) do |u|
    u.password              = 'password'
    u.password_confirmation = 'password'
    u.role                  = attrs[:role]
  end
end

puts "users: #{User.count}"

# Customers
eigyo   = Department.find_by!(name: '営業')
gijutsu = Department.find_by!(name: '技術')
soumu   = Department.find_by!(name: '総務')
support = Department.find_by!(name: 'サポート')
sonota  = Department.find_by!(name: 'その他')

customers_data = [
  # 営業
  { name: '田中太郎',   customer_type: 'regular',   status: 'active',   department: eigyo },
  { name: '佐藤花子',   customer_type: 'premium',   status: 'active',   department: eigyo },
  { name: '鈴木次郎',   customer_type: 'corporate', status: 'active',   department: eigyo },
  { name: '高橋美咲',   customer_type: 'regular',   status: 'inactive', department: eigyo },
  { name: '伊藤健', customer_type: 'premium', status: 'pending', department: eigyo },
  { name: '渡辺由美',   customer_type: 'regular',   status: 'active',   department: eigyo },
  # 技術
  { name: '山田真一',   customer_type: 'corporate', status: 'active',   department: gijutsu },
  { name: '中村大介',   customer_type: 'premium',   status: 'active',   department: gijutsu },
  { name: '小林香織',   customer_type: 'regular',   status: 'inactive', department: gijutsu },
  { name: '加藤雄太',   customer_type: 'corporate', status: 'pending',  department: gijutsu },
  { name: '斉藤智也',   customer_type: 'regular',   status: 'active',   department: gijutsu },
  { name: '松井恵子',   customer_type: 'premium',   status: 'active',   department: gijutsu },
  # 総務
  { name: '吉田みどり', customer_type: 'regular', status: 'active', department: soumu },
  { name: '松本圭介',   customer_type: 'premium',   status: 'active',   department: soumu },
  { name: '井上愛子',   customer_type: 'corporate', status: 'active',   department: soumu },
  { name: '木村拓也',   customer_type: 'regular',   status: 'inactive', department: soumu },
  { name: '清水美穂',   customer_type: 'premium',   status: 'pending',  department: soumu },
  # サポート
  { name: '山口智子',   customer_type: 'corporate', status: 'active',   department: support },
  { name: '竹内翔太',   customer_type: 'regular',   status: 'active',   department: support },
  { name: '福田理恵',   customer_type: 'premium',   status: 'active',   department: support },
  { name: '橋本直樹',   customer_type: 'regular',   status: 'inactive', department: support },
  # その他
  { name: '岡田修平',   customer_type: 'regular',   status: 'active',   department: sonota },
  { name: '森田純子',   customer_type: 'premium',   status: 'active',   department: sonota },
  { name: '長谷川優',   customer_type: 'corporate', status: 'active',   department: sonota },
  { name: '石川和也',   customer_type: 'regular',   status: 'pending',  department: sonota }
]

customers_data.each do |attrs|
  Customer.find_or_create_by!(name: attrs[:name], department: attrs[:department]) do |c|
    c.customer_type = attrs[:customer_type]
    c.status        = attrs[:status]
  end
end

puts "customers: #{Customer.count}"
