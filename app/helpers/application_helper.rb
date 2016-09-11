module ApplicationHelper
  def flash_notification_class(name)
    case name
      when :error
        'is-danger'
      when :alert
        'is-warning'
      when :notice
        'is-info'
      when :success
        'is-success'
    end
  end

  def is_active(active_path)
    'is-active' if request.fullpath.start_with?(active_path)
  end
end
