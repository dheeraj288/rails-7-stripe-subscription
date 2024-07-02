json.extract! post, :id, :title, :premium, :created_at, :updated_at
json.url post_url(post, format: :json)
