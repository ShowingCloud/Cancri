class BaseSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope, allow_nil: true

  def owner?(obj = nil)
    return false if current_user.blank?

    obj = object if obj.blank?
    if obj.is_a?(User)
      return obj.id == current_user.id
    else
      return obj.user_id == current_user.id
    end
  end

  def cache(keys = [])
    Rails.cache.fetch(['serializer', *keys]) do
      yield
    end
  end
end
