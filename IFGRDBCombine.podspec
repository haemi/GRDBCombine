Pod::Spec.new do |s|
  spec.source_files          = '*.swift'
  spec.name                  = "IFGRDBCombine"
  spec.author                = { "Stefan Walkner" => "stefan@arkulpa.at" }
  spec.summary               = "A fork of GRDBCombine with the only difference: Cocoapod support."
  spec.version               = "0.4.0"
  spec.homepage              = "https://github.com/groue/GRDBCombine"
  spec.source                = { :git => "git@github.com:haemi/GRDBCombine.git" }
  spec.ios.deployment_target = '13.0'
end
