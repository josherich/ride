module ApplicationHelper

  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
    HTML
    html.html_safe
  end

  def seats_bar(seat_stat)
    if !seat_stat.to_s.include? '.'
      return 50
    end
    a = seat_stat.to_s.split('.')
    percentage = a[0].to_f / a[1].to_f * 100
    return percentage
  end

  def seats_text(seat_stat)
    if !seat_stat.to_s.include? '.'
      return '0/0'
    end
    a = seat_stat.to_s.split('.')
    return a[0] + '/' + a[1]
  end

end
