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

/*
    Write a json value to a port

    Arguments:
    val: the value to write
    port: the port to write to
*/
(defun _ilJson_writeToPort (val port)
    (cond
        ((stringp val) (fprintf port "\"%s\"" val))
        ((numberp val) (fprintf port "%L" val))
        ((symbolp val)
            (if (equal (get_pname val) "t") then
                (fprintf port "true")
            else
                (fprintf port (get_pname val))
            )
        )
        ((listp val)
            (if (length val) == 0 then
                (fprintf port "false")
            else
                (fprintf port "[")
                (let ((first t))
                    (foreach item val
                        (if first then
                            (setq first nil)
                        else
                            (fprintf port ", ")
                        )
                        (_ilJson_writeToPort item port)
                    )
                )
                (fprintf port "]")
            )
        )
        ((tablep val)
            (println "write tablep")
            (fprintf port "{")
            (let ((first t))
                (foreach key val
                    (if first then
                        (setq first nil)
                    else
                        (fprintf port ", ")
                    )
                    (fprintf port "\"%s\": " (get_pname key))
                    (_ilJson_writeToPort val[key] port)
                )
            )
            (fprintf port "}")
        )
        ((null val) (fprintf port "null"))
    )
)

/*
    Write a json value to a port with formatting

    Arguments:
    val - the json value to write
    port - the port to write to
    level - the level of indentation
 */
(defun _ilJson__writePrettyToPort (val port level)
    (cond
        ((stringp val) (fprintf port "\"%s\"" val))
        ((numberp val) (fprintf port "%L" val))
        ((symbolp val)         
            (case val
                ((quote t)
                    (fprintf port "true")
                )
                ((quote unbound)
                    (fprintf port "null")
                )
                (t
                    (fprintf port (get_pname val))
                )           
            )
        )
        ((listp val)
            (if (length val) == 0 then
                (fprintf port "false")
            else
                (fprintf port "[\n")
                (let ((count 0) (len (length val)))
                    (foreach item val
                        count = count + 1
                        (fprintf port (_ilJson_makeWhiteSpace 4*level))
                        (_ilJson__writePrettyToPort item port level+1)
                        (if (equal count len) then
                            (fprintf port "\n")
                        else
                            (fprintf port ",\n")
                        )
                    )
                )
                (fprintf port (_ilJson_makeWhiteSpace 4*(level-1)))
                (fprintf port "]")
            )
        )
        ((tablep val)
            (fprintf port "{\n")
            (let ((count 0) (len (length val)))
                (foreach key val
                    count = count + 1
                    (fprintf port (_ilJson_makeWhiteSpace 4*level))
                    (fprintf port "\"%s\": " (get_pname key))
                    (_ilJson__writePrettyToPort val[key] port level+1)
                    (if (equal count len) then
                        (fprintf port "\n")
                    else
                        (fprintf port ",\n")
                    )
                )
            )
            (fprintf port (_ilJson_makeWhiteSpace 4*(level-1)))
            (fprintf port "}")
        )
    )
)

/*
    Read json from a port

    Arguments:
    port - port to read from
    nextchar - next char read from port

    Returns:
    json object or value
*/
(defun _ilJson_readFromPort (port @key (nextchar nil))
    (let (char)
        (if nextchar then
            (setq char nextchar)
        else
            (setq char (_ilJson_gotoNonWhiteSpace port))
        )
        (case char
            ; string
            (\"
                (_ilJson_extractString port)
            )
            ; false
            (f
                (let (charList char str)
                    (setq charList (tconc nil 'f))
                    (setq char (getc port))
                    (when (equal char (quote a))
                        (tconc charList char)
                        (setq char (getc port))
                        (when (equal char (quote l))
                            (tconc charList char)
                            (setq char (getc port))
                            (when (equal char (quote s))
                                (tconc charList char)
                                (setq char (getc port))
                                (when (equal char (quote e))
                                    (tconc charList char)
                                    (setq char (getc port))
                                )
                            )
                        )
                    )
                    (if (and 
                            (_ilJson_isEndSymbol char)
                            (equal 5 (length (car charList)))
                        ) then
                        nil
                    else
                        (unless (_ilJson_isEndSymbol char)
                            (tconc charList (_ilJson_extractNumOrSymbol port char ?forceSymbol t))
                        )
                        (setq str (buildString (mapcar 'symbolToString (car charList)) ""))
                        (stringToSymbol str)
                    )               
                )
            )
            ; true
            ((quote t)
                (let (charList char str)
                    (setq charList (tconc nil 't))
                    (setq char (getc port))
                    (when (equal char (quote r))
                        (tconc charList char)
                        (setq char (getc port))
                        (when (equal char (quote u))
                            (tconc charList char)
                            (setq char (getc port))
                            (when (equal char (quote e))
                                (tconc charList char)
                                (setq char (getc port))
                            )
                        )
                    )
                    (if (and 
                            (_ilJson_isEndSymbol char)
                            (equal 4 (length (car charList)))
                        ) then
                        (quote t)
                    else
                        (unless (_ilJson_isEndSymbol char)
                            (tconc charList (_ilJson_extractNumOrSymbol port char ?forceSymbol t))
                        )
                        (setq str (buildString (mapcar 'symbolToString (car charList)) ""))
                        (stringToSymbol str)
                    )               
                )
            )
            ; null
            (n
                (let (charList char str)
                    (setq charList (tconc nil 'n))
                    (setq char (getc port))
                    (when (equal char (quote u))
                        (tconc charList char)
                        (setq char (getc port))
                        (when (equal char (quote l))
                            (tconc charList char)
                            (setq char (getc port))
                            (when (equal char (quote l))
                                (tconc charList char)
                                (setq char (getc port))
                            )
                        )
                    )
                    (if (and 
                            (_ilJson_isEndSymbol char)
                            (equal 4 (length (car charList)))
                        ) then
                        (quote unbound)
                    else
                        (unless (_ilJson_isEndSymbol char)
                            (tconc charList (_ilJson_extractNumOrSymbol port char ?forceSymbol t))
                        )
                        (setq str (buildString (mapcar 'symbolToString (car charList)) ""))
                        (stringToSymbol str)
                    )               
                )
            )
            ; list
            (\[
                (let (array nextSymbo)
                    (setq array (tconc nil nil))
                    (setq nextSymbol (_ilJson_gotoNonWhiteSpace port))
                    (while  (nequal nextSymbol (quote \]))
                        (tconc array (_ilJson_readFromPort port ?nextchar nextSymbol))
                        (setq nextSymbol (_ilJson_gotoNonWhiteSpace port))
                        (if (equal nextSymbol (quote \,))
                            (let ((lastelm (cdr array))) 
                                (unless
                                    (or
                                        (numberp lastelm)
                                        (symbolp lastelm)
                                    )
                                    (setq nextSymbol (_ilJson_gotoNonWhiteSpace port))
                                )
                            )
                        )
                    )
                    (cdar array)
                )
            )
            ; json object
            (\{
                (let ((nextSymbol (quote \,)) key json)
                    (setq json (ilJson_CreateObj))
                    (while
                        (or
                            (equal nextSymbol (quote \"))
                            (and
                                (equal nextSymbol (quote \,))
                                (setq nextSymbol (_ilJson_gotoCharInList port '(\" \})))
                                (equal nextSymbol (quote \"))
                            )
                        )
                        (setq key (_ilJson_extractString port))
                        (setq key (stringToSymbol key))
                        (_ilJson_gotoCharInList port '(\:))
                        json[key] = (_ilJson_readFromPort port)
                        (setq nextSymbol (_ilJson_gotoCharInList port '(\, \} \")))
                    )
                    json
                )
            )
            ; number or symbol
            (t
                (_ilJson_extractNumOrSymbol port char)
            )
        )
    )
)

/*
    go to next non-whitespace character

    Arguments:
    port - port to read from

    Returns:
    next non-whitespace character
*/
(defun _ilJson_gotoNonWhiteSpace (port)
    (let (char)
        (while 
            (and
                (setq char (getc port))
                (or
                    (equal char (quote \n))
                    (equal char (quote \t))
                    (equal char (quote \ ))
                )
            )
            nil
        )
        char
    )
)

/*
    go to next character in the given list

    Arguments:
    port - port to read from
    chars - list of characters to find

    Returns:
    character finded in the list or nil
*/
(defun _ilJson_gotoCharInList (port chars)
    (let (char)
        (while
            (and
                (setq char (getc port))
                (not (member char chars))
            )
            nil
        )
        char
    )
)

/*
    Judge if a character is the end of a symbol

    Arguments:
    char - character to be judged

    Returns:
    t if the character is the end of a symbol, otherwise nil
*/
(defun _ilJson_isEndSymbol (char)
    (or
        (equal char (quote \t))
        (equal char (quote \n))
        (equal char (quote \,))
        (equal char (quote \]))
        (equal char (quote \}))
        (equal char (quote \ ))
    )
)

/*
    Extracts a string from the stream

    Arguments:
    port: The stream to read from

    Returns:
    The string read from the stream
*/
(defun _ilJson_extractString (port)
    (let (char charList)
        (setq charList (tconc nil nil))
        (while
            (and
                (setq char (getc port))
                (or
                    (nequal char (quote \"))
                    (equal (cadr charList) (quote \\))
                )
            )
            (tconc charList char)
        )
        (buildString (mapcar 'symbolToString (cdar charList)) "")
    )
)

/*
    Extracts a number or symbol from the stream

    Arguments:
    port - the port to read from
    firstChar - the first character read from the stream
    forceSymbol - if true, the number is returned as a symbol
    
    Returns:
    The number or symbol read from the stream
*/
(defun _ilJson_extractNumOrSymbol (port firstChar @key (forceSymbol nil))
    (let (char charList str isFloat)
        (setq charList (tconc nil firstChar))
        (setq isFloat nil)
        (while
            (and
                (setq char (getc port))
                (not (_ilJson_isEndSymbol char))
            )
            (tconc charList char)
            (if (equal char (quote \.))
                (setq isFloat t)
            )
        )
        (setq str (buildString (mapcar 'symbolToString (car charList)) ""))
        (if (and
                (not forceSymbol)
                (atoi str)
            ) then
            (if isFloat then
                (atof str)
            else
                (atoi str)
            )
        else
            (stringToSymbol str)
        )
    )
)

/*
    Creates a string of whitespace of a given length

    Arguments:
    len - the length of the string to create

    Returns:
    The string of whitespace
*/
(defun _ilJson_makeWhiteSpace (len)
    (let (result)
        (setq result "")
        (for i 1 len
            (setq result (strcat result " "))
        )
        result
    )
)