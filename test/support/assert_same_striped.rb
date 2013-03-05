def assert_same_stripped(expect, test, *equivalencies)
  equivalencies.each{|look, ok| test.gsub! look, ok }
  expect, test = [expect, test].map{|s| s.split("\n").map(&:strip)}
  same = expect & test
  delta_expect, delta_test = [expect, test].map{|a| a-same}
  STDOUT << "\n\n---- Actual result: ----\n" << test.join("\n") << "\n---------\n" unless delta_expect == delta_test
  assert_equal delta_expect, delta_test
end

