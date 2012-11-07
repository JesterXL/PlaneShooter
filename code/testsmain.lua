function showProps(o)
	print("-- showProps --")
	print("o: ", o)
	for key,value in pairs(o) do
		print("key: ", key, ", value: ", value);
	end
	print("-- end showProps --")
end

pcall(require, "luacov")    --measure code coverage, if luacov is present
require "lunatest"


lunatest.suite("tests.com.jessewarden.planeshooter.models.PlayerModelSuite")
lunatest.suite("tests.com.jessewarden.planeshooter.utils.CollectionSuite")
lunatest.suite("tests.com.jessewarden.planeshooter.models.ScoreModelSuite")
lunatest.suite("tests.StringFormattingTests")

print("-------------------------------")
lunatest.run()