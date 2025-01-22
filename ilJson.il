/* MIT License

Copyright (c) 2025 Hong <hejnhong@foxmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


(load "ilJsonInner.il")

/*
    create a json object
*/
(defun ilJson_createObj ()
    (makeTable "jsonObj")
)

/*
    add a key-value pair to json object
*/
(defun ilJson_addValue (json key value)
    json[key] = value
)

/*
    get a value from a json object by the key
*/
(defun ilJson_getValue (json key)
    (get json key)
)

/*
    convert a json object to string
*/
(defun ilJson_toString (json)
    (let (port)
        (if !(tablep json) then
            (error "Provided parameter is not a json object")
        else
            (setq port (outstring))
            (_ilJson_writeToPort json port)
            (getOutstring port)
        )
    )
)

/*
    convert a json object to a formatted string
*/
(defun ilJson_toPrettyString (json)
    (let (port)
        (if !(tablep json) then
            (error "Provided parameter is not a json object")
        else
            (setq port (outstring))
            (_ilJson__writePrettyToPort json port 1)
            (getOutstring port)
        )
    )
)

/*
    Parse a json string into a json object
*/
(defun ilJson_fromString (str)
    (let (port)
        (setq port (instring str))
        (_ilJson_readFromPort port)
    )
)

/*
    Writes a json object to a file
*/
(defun ilJson_save (json fileName)
    (let (port str)
        (if !(tablep json) then
            (error "Provided parameter is not a json object")
        else
            (setq port (outfile fileName "w"))
            (_ilJson_writeToPort json port)
            (close port)
        )
    )
)

/*
    Writes json object to a file in a human readable format
*/
(defun ilJson_savePretty (json fileName)
    (let (port str)
        (if !(tablep json) then
            (error "Provided parameter is not a json object")
        else
            (setq port (outfile fileName "w"))
            (_ilJson__writePrettyToPort json port 1)
            (close port)
        )
    )
)

/*
    Read json from file
*/
(defun ilJson_read (fileName)
    (let (port json)
        (setq port (infile fileName))
        (if (null port) then
            (error "Could not open file")
        else
            json = (_ilJson_readFromPort port)
            (close port)
            json
        )
    )
)
