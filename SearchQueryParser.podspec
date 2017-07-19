
Pod::Spec.new do |s|

  s.name         = "SearchQueryParser"
  s.version      = "0.0.1"
  s.summary      = "Parsing search string with logical operators (AND, OR, NOT) and generates predicate from it."

  s.description  = <<-DESC 
                    Current framework allows to use logical operators with search (like SearchKit). But only you don't need to generate Index file for using it.
                    This framework generates NSPredicate or filtering block by default, but you can write another builder yourself.
                   DESC

  s.homepage     = "https://github.com/AlexIzh/SearchQueryParser"

  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "https://github.com/AlexIzh/SearchQueryParser/blob/master/LICENSE" }

  s.author             = { "Alex Severyanov" => "alex.severyanov@gmail.com" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"

  s.source       = { :git => "https://github.com/AlexIzh/SearchQueryParser.git", :tag => "#{s.version}" }

  s.source_files  = 'SearchQueryParser/SearchQueryParser/*'

end
