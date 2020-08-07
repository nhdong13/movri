
module ColorHelper
  def to_rgb(hex:, avg: 1)
    "rgba(#{Color::RGB.from_html(hex).red},#{Color::RGB.from_html(hex).green},#{Color::RGB.from_html(hex).blue}, #{avg})"
  end
end