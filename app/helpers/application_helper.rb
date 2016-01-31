module ApplicationHelper

  def flash_icon_class(name)
    case name
      when :error
        'icon-exclamation-sign'
      when :alert
        'icon-warning-sign'
      when :notice
        'icon-info-sign'
      when :success
        'icon-ok'
    end
  end
  
end
