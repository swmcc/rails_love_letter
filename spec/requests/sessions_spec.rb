# frozen_string_literal: true

RSpec.describe 'Sessions', type: :request do
  it 'creates a session name' do
    post session_path, params: { name: 'Alice' }
    follow_redirect!
    expect(response.body).to include('Welcome, Alice')
  end
end
