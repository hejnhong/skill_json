# Skill-Json
This lightweight JSON library for the Skill language employs an association table for efficient JSON parsing and serialization. Its implementation is inspired by the skill-JSON project, available at https://github.com/kaustuvsahu/skill-JSON.

# How to use
## 1. Load the file
```lisp
(load "ilJson.il")
```

## 2. create a json object
```lisp
json = (ilJSON_CreateObj)
```

## 3. add key value pairs
```lisp
(ilJSON_SetValue json 'negativeNum -1)
(ilJSON_SetValue json 'positiveNum 2)
(ilJSON_SetValue json 'floatNum 2.54)
(ilJSON_SetValue json 'floatNum -4.3)

(ilJSON_SetValue json 'testTrue t)
(ilJSON_SetValue json 'testFalse nil)
(ilJSON_SetValue json 'teststring "sssshello")
(ilJSON_SetValue json 'testSymbol 'falsefalsetrue)
(ilJSON_SetValue json 'testList '(1 2 3 a b "skill"))
(ilJSON_SetValue json 'testStringList '("skill" "sssss" "skill2" "fajdfjfh"))
```

## 4. print the json object to string
```lisp
str = (ilJson_toString json)
```

## 5. print the json object to file
```lisp
(ilJson_savePretty "json_test.txt")
```

## 6. parse a json string
```lisp
json2 = (ilJson_fromString str)
```

## 7. parse a json file
```lisp
json3 = (ilJson_read "json_test.txt")
```
