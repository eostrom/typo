ActiveSupport::Inflector.inflections do |i|
  i.uncountable %w(feedback)
  i.singular /(cache)s$/i, '\1'
end
