# Dockerfile
FROM ruby:3.1.4

WORKDIR /app

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock ./

# bundle install
RUN bundle install

# アプリケーションコードをコピー
COPY . .

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]