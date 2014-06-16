Pod::Spec.new do |s|
  s.name         = 'RBPopoverSelectControl'
  s.version      = '1.0.5'
  s.summary      = 'Simple popover combo box (select control)'
  s.author = {
    'Ryhor Burakou' => 'ahsirg@gmail.com'
  }
  s.source = {
    :git => 'https://github.com/ryhor/RBPopoverSelectControl.git'
  }
  s.source_files = '*.{h,m}'
  s.homepage = 'https://ryhor.com'
  s.requires_arc = true
  s.resources = '*.{png}'
end
