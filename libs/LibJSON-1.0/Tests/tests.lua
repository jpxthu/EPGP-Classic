dofile("./base.lua")

local LibJSON = LibStub("LibJSON-1.0")

for key, value in pairs {
    ["Hello"] = '"Hello"',
    ['Hey \" There'] = [=["Hey \" There"]=],
    ['Hey \t There'] = [=["Hey \t There"]=],
    ['Hey \r There'] = [=["Hey \r There"]=],
    ['Hey \n There'] = [=["Hey \n There"]=],
    ['Hey \f There'] = [=["Hey \f There"]=],
    ['Hey / There'] = [=["Hey \/ There"]=],
    ['Überfantastisch'] = [=["\u00DCberfantastisch"]=],
    [1234] = '1234',
    [1234.5678] = '1234.5678',
    [true] = "true",
    [false] = "false",
    [1e+100] = '1e+100',
    [1.5e+100] = '1.5e+100',
    [1e-100] = '1e-100',
    [1.5e-100] = '1.5e-100',
    [{true, false, true, false}] = '[true,false,true,false]',
    [{{{{}}}}] = "[[[[]]]]",
    [{{{{"Alpha"}}}}] = '[[[["Alpha"]]]]',
    [{{alpha="Bravo"}}] = '[{"alpha":"Bravo"}]',
    [{{{{alpha="Bravo"}}}}] = '[[[{"alpha":"Bravo"}]]]',
    [{"Alpha", 1234}] = '["Alpha",1234]',
    [{"Alpha", "Bravo", "Charlie"}] = '["Alpha","Bravo","Charlie"]',
    [{}] = '[]',
    [{1, 2, 3}] = '[1,2,3]',
    [{alpha = "Bravo"}] = '{"alpha":"Bravo"}',
    [{one=1,two=2,three=3}] = '{"one":1,"three":3,"two":2}',
    [{one={alpha="bravo", charlie="delta"}, two={echo="foxtrot", golf="hotel"}}] = '{"one":{"alpha":"bravo","charlie":"delta"},"two":{"echo":"foxtrot","golf":"hotel"}}',
    [{[4] = "Hello"}] = '[null,null,null,"Hello"]',
} do
    assert_equal(LibJSON.Serialize(key), value)
    assert_equal(LibJSON.Deserialize(value), key)
    assert_equal(LibJSON.Deserialize(LibJSON.Serialize(key)), key)
end

assert_equal(LibJSON.Serialize(nil), "null")
assert_equal(LibJSON.Serialize(LibJSON.Null()), "null")
assert_equal(LibJSON.Serialize({1, LibJSON.Null(), 2}), "[1,null,2]")
assert_equal(LibJSON.Serialize({[0]=2}), '{"0":2}')

assert_equal(LibJSON.Deserialize("null"), nil)
assert_equal(LibJSON.Deserialize(LibJSON.Serialize(nil)), nil)

assert_equal(LibJSON.Deserialize('1e0'), 1)
assert_equal(LibJSON.Deserialize('1e1'), 10)
assert_equal(LibJSON.Deserialize('    5    '), 5)
assert_equal(LibJSON.Deserialize([=[
    [1, // hello
     2, /* there */
     3]
]=]), {1,2,3})
assert_equal(LibJSON.Deserialize("5 //"), 5)
assert_equal(LibJSON.Deserialize("5 /* // */"), 5)

assert_error([=[String ended early: "\"hey"]=], LibJSON.Deserialize, '"hey')
assert_error([=[String ended early: "\"hey\\"]=], LibJSON.Deserialize, '"hey\\')
assert_error([=[Invalid list: "[1234", ended early]=], LibJSON.Deserialize, '[1234')
assert_error([=[Number ended early: "-"]=], LibJSON.Deserialize, '-')
assert_error([=[Number ended early: "1234."]=], LibJSON.Deserialize, '1234.')
assert_error([=[Premature end: "["]=], LibJSON.Deserialize, '[')
assert_error([=[Invalid input: "]"]=], LibJSON.Deserialize, ']')
assert_error([=[Error reading true: "tru"]=], LibJSON.Deserialize, 'tru')
assert_error([=[Error reading false: "fals"]=], LibJSON.Deserialize, 'fals')
assert_error([=[Error reading null: "nil"]=], LibJSON.Deserialize, 'nil')
assert_error([=[Found non-string dictionary key: 1]=], LibJSON.Deserialize, '{1:"2"}')
assert_error([=[Invalid comment found: "1/"]=], LibJSON.Deserialize, '1/')
assert_error([=[Invalid comment found: "1/*"]=], LibJSON.Deserialize, '1/*')
assert_error([=[Invalid comment found: "1/* /* */"]=], LibJSON.Deserialize, '1/* /* */')
assert_error([=[Unused trailing characters: "1 2"]=], LibJSON.Deserialize, '1 2')
assert_error([=[Unused trailing characters: "\"Hello\"\""]=], LibJSON.Deserialize, '"Hello""')
assert_error([=[Serializing of type function is unsupported]=], LibJSON.Serialize, function() end)
assert_error([=[Serializing of type userdata is unsupported]=], LibJSON.Serialize, newproxy())

print("Tests complete")
