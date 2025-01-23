# Skill-Json
This lightweight JSON library for the Skill language employs an association table for efficient JSON parsing and serialization. Its implementation is inspired by the skill-JSON project, available at https://github.com/kaustuvsahu/skill-JSON.

# How to use
## 1. Load the file
```lisp
(load "ilJson.il")
```

## 2. create a json object
```lisp
json = (ilJson_createObj)
```

## 3. add key value pairs
```lisp
(ilJson_addValue json 'negativeNum -1)
(ilJson_addValue json 'positiveNum 2)
(ilJson_addValue json 'floatNum 2.54)
(ilJson_addValue json 'floatNum -4.3)

(ilJson_addValue json 'testTrue t)
(ilJson_addValue json 'testFalse nil)
(ilJson_addValue json 'teststring "sssshello")
(ilJson_addValue json 'testSymbol 'falsefalsetrue)
(ilJson_addValue json 'testList '(1 2 3 a b "skill"))
(ilJson_addValue json 'testStringList '("skill" "sssss" "skill2" "fajdfjfh"))
```

## 4. print the json object to string
```lisp
str = (ilJson_toString json)
```
the str will be like this:
```
"{\"testTrue\": true, \"testSymbol\": falsefalsetrue, \"floatNum\": -4.3, \"teststring\": \"sssshello\", \"negativeNum\": -1, \"positiveNum\": 2, \"testStringList\": [\"skill\", \"sssss\", \"skill2\", \"fajdfjfh\"], \"testList\": [1, 2, 3, a, b, \"skill\"], \"testFalse\": false}"
```
## 5. print the json object to file
```lisp
(ilJson_savePretty json "json_test.txt")
```
the contents of json_test.txt will be like this:
```
{
    "testTrue": true,
    "testSymbol": falsefalsetrue,
    "floatNum": -4.3,
    "teststring": "sssshello",
    "negativeNum": -1,
    "positiveNum": 2,
    "testStringList": [
        "skill",
        "sssss",
        "skill2",
        "fajdfjfh"
    ],
    "testList": [
        1,
        2,
        3,
        a,
        b,
        "skill"
    ],
    "testFalse": false
}
```

## 6. parse a json string
```lisp
json2 = (ilJson_fromString str)
```

## 7. parse a json file
```lisp
json3 = (ilJson_read "json_test.txt")
```
