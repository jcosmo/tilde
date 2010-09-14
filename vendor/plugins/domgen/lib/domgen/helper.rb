def pluralize(string)
  "#{string}s"
end

def underscore(camel_cased_word)
  camel_cased_word.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
          gsub(/([a-z\d])([A-Z])/, '\1_\2').
          tr("-", "_").
          downcase
end

def uppercase_constantize(word)
  underscore(word).upcase
end
