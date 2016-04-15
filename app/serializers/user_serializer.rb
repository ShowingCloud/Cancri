class UserSerializer < BaseSerializer
  attributes :id, :nickname, :sign_in_count, :current_sign_in_at, :last_sign_in_at

end