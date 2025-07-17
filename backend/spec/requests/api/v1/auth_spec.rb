# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auths', type: :request do
  describe 'POST /api/v1/auth/signup' do
    let(:valid_params) do
      {
        user: {
          email: 'signup@example.com',
          password: 'password123',
          password_confirmation: 'password123'
        }
      }
    end

    it 'creates a new user and returns JWT token' do
      post '/api/v1/auth/signup', params: valid_params, as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body).to have_key('token')
      expect(response.parsed_body).to have_key('user')
      expect(response.parsed_body['user']['email']).to eq('signup@example.com')
    end

    it 'returns error for invalid params' do
      post '/api/v1/auth/signup', params: {
        user: { email: 'invalid-email', password: '123' }
      }, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body).to have_key('errors')
    end
  end

  describe 'POST /api/v1/auth/login' do
    let!(:user) { create(:user) }

    context '正常系' do
      it 'returns JWT token for valid credentials' do
        post '/api/v1/auth/login', params: {
          email: user.email,
          password: 'password123'
        }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to have_key('token')
        expect(response.parsed_body).to have_key('user')

        # JWTトークンの検証
        token = response.parsed_body['token']
        decoded = JsonWebToken.decode(token)
        expect(decoded[:user_id]).to eq(user.id)
      end
    end

    context '異常系' do
      it 'returns error for invalid email' do
        post '/api/v1/auth/login', params: {
          email: 'wrong@example.com',
          password: 'password123'
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_key('error')
      end

      it 'returns error for invalid password' do
        post '/api/v1/auth/login', params: {
          email: user.email,
          password: 'wrongpassword'
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_key('error')
      end

      it 'returns error for missing params' do
        post '/api/v1/auth/login', params: {}, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body).to have_key('error')
      end
    end
  end

  describe 'GET /api/v1/auth/me' do
    let!(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    it 'returns current user info with valid token' do
      get '/api/v1/auth/me', headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to have_key('user')
      expect(response.parsed_body['user']['id']).to eq(user.id)
      expect(response.parsed_body['user']['email']).to eq(user.email)
    end

    it 'returns error without token' do
      get '/api/v1/auth/me'

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to have_key('error')
    end

    it 'returns error with invalid token' do
      get '/api/v1/auth/me', headers: { 'Authorization' => 'Bearer invalid_token' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to have_key('error')
    end
  end
  describe 'POST /api/v1/auth/logout' do
    let!(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    it 'logs and return valid status' do
      allow(Rails.logger).to receive(:info)

      post '/api/v1/auth/logout', headers: headers

      expect(Rails.logger).to have_received(:info).with("User #{user.id} logged out")
      expect(response).to have_http_status(:no_content)
    end
  end
  describe 'POST /api/v1/auth/refresh' do
    let!(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let!(:headers) { { 'Authorization' => "Bearer #{token}" } }

    it 'return valid status' do
      travel_to(1.second.from_now) do
        post '/api/v1/auth/refresh', headers: headers
      end
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['token']).to_not eq(token)
    end
  end

  describe 'POST /api/v1/auth/profile' do
    let!(:user) { create(:user) }
    let(:token) { JsonWebToken.encode(user_id: user.id) }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    it 'returns current user info with valid token' do
      get '/api/v1/auth/profile', headers: headers

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to have_key('user')
      expect(response.parsed_body['user']['id']).to eq(user.id)
      expect(response.parsed_body['user']['email']).to eq(user.email)
    end

    it 'returns error without token' do
      get '/api/v1/auth/profile'

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to have_key('error')
    end

    it 'returns error with invalid token' do
      get '/api/v1/auth/profile', headers: { 'Authorization' => 'Bearer invalid_token' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body).to have_key('error')
    end
  end
end
