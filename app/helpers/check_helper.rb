module CheckHelper
  def require_email
    if current_user.present?
      current_user.email.present?
    else
      require_user
    end
  end

  def require_mobile
    if current_user.present?
      current_user.mobile.present?
    else
      require_user
    end
  end

  def require_email_and_mobile
    if current_user.present?
      current_user.mobile.present? && current_user.mobile.present?
    else
      require_user
    end
  end
end
