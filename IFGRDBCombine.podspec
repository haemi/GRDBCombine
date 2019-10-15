Pod::Spec.new do |s|
  s.source_files          = ['Sources/GRDBCombine/**/*.swift']
  s.exclude_files         = [ 'Package.swift' ]
  s.dependency "GRDB.swift/SQLCipher", "~> 4.4.0"
  s.swift_version         = '5.1'
  s.name                  = "IFGRDBCombine"
  s.author                = { "Stefan Walkner" => "stefan@arkulpa.at" }
  s.summary               = "A fork of GRDBCombine with the only difference: Cocoapod support."
  s.version               = "0.4.0"
  s.homepage              = "https://github.com/groue/GRDBCombine"
  s.source                = { :git => "git@github.com:haemi/GRDBCombine.git" }
  s.ios.deployment_target = '13.0'
end
