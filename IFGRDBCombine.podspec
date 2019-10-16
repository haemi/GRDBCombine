Pod::Spec.new do |s|
  s.source_files          = ['Sources/GRDBCombine/**/*.swift']
  s.exclude_files         = [ 'Package.swift' ]
  s.dependency "GRDB.swift/SQLCipher", "~> 4.4.0"
  s.swift_version         = '5.1'
  s.name                  = "GRDBCombine"
  s.author                = "Gwendal Roué"
  s.summary               = "A set of extensions for SQLite, GRDB.swift, and Combine."
  s.version               = "0.4.0"
  s.homepage              = "https://github.com/groue/GRDBCombine"
  s.source                = { :git => "https://github.com/groue/GRDBCombine" }
  s.ios.deployment_target = '13.0'
end
