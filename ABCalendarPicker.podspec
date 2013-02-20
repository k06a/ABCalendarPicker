Pod::Spec.new do |s|
  s.name         = "ABCalendarPicker"
  s.version      = "0.1.0"
  s.summary      = "Fully configurable iOS calendar UI component with multiple layouts and smooth animations."
  s.homepage     = "https://github.com/a2/ABCalendarPicker"
  s.license      = 'MIT'
  s.author       = { "Anton Bukov" => "k06aaa@gmail.com",
                     "Alexsander Akers" => "a2@pandamonia.us" }
  s.source       = { :git => "https://github.com/a2/ABCalendarPicker.git", :branch => "master" }
  s.platform     = :ios, '5.0'
  s.source_files = 'ABCalendarPicker/*.{h,m}'
  s.resource     = "ABCalendarPicker/ABCalendarPicker.bundle"
  s.requires_arc = true
end
