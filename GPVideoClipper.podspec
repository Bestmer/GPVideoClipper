Pod::Spec.new do |spec|

  spec.name         = "GPVideoClipper"
  spec.version      = "1.0.0"
  spec.summary      = "iOS long video clip tool, similar to WeChat moments and tiktok."
  spec.description  = <<-DESC
                   iOS long video clip tool, similar to WeChat moments select and edit videos larger than 15s from albums, 
                   and support saving as a local album.
                   DESC

  spec.homepage      = "https://github.com/Bestmer"
  spec.license       = "MIT"
  spec.platform       = :ios, "9.0"
  spec.author        = { "RocKwok" => "guopengios@163.com" }
  spec.source        = { :git => "https://github.com/Bestmer/GPVideoClipper.git", :tag => "#{spec.version}" }
  spec.source_files  = "GPVideoClipper/**/*.{h,m}"
  spec.exclude_files = "GPVideoClipper/Exclude"

end
