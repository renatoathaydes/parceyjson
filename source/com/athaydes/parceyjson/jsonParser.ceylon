import com.athaydes.parcey {
    spaces,
    noneOf,
    mapParsers,
    strParser,
    integer,
    mapValueParser,
    Parser,
    chainParser,
    character,
    first,
    ParseError,
    endOfInput,
    text,
    coalescedParser,
    mapParser,
    digit,
    oneOf
}
import com.athaydes.parcey.combinator {
    around,
    many,
    either,
    separatedBy,
    skip,
    sequenceOf,
    nonEmptySequenceOf,
    option
}

shared class ErrorMessage(shared String message) {
    string = message;
}

shared abstract class Value<Type>(shared Type val)
        given Type satisfies Object {
    equals(Object that)
            => if (is Value<Type> that) then
        this.val == that.val else false;
    shared actual default String string = val.string;
}

shared alias JsonEntry => Entry<String, JsonElement>;

shared class JsonObject({JsonEntry*} entries)
		extends Value<Map<String, JsonElement>>(map(entries))
		satisfies Correspondence<String, JsonElement> {	
    string => val.string;
    
    shared actual Boolean defines(String key) => val.defines(key);
    
    shared actual JsonElement? get(String key) => val.get(key);
}

shared interface JsonNull of jsonNull {}

shared object jsonNull satisfies JsonNull {
    string = "null";
}

shared alias JsonNumber => Integer|Float;
shared alias JsonValue => String|JsonNumber|Boolean|JsonNull;
shared alias JsonArray => Object[];
shared alias JsonElement => JsonValue|JsonArray|JsonObject;

"Json Parser."
shared object json {
    
    value quote = skip(character('"'));
    function jsonNull_()
            => mapParser(text("null", "jsonNull"), (Anything _) => jsonNull);
    function jsonString() {
        value hexDigit = either { digit(), oneOf('A'..'F') };
        value hexCode = sequenceOf { character('u'), hexDigit, hexDigit, hexDigit, hexDigit };
        value escChar = oneOf { '"', '\\', '/', 'b', 'f', 'n', 'r', 't' };
        value escaped = sequenceOf {
            character('\\'), either { escChar, hexCode }
        };
        return strParser(sequenceOf({
            quote, many(either { escaped, noneOf { '"', '\\' } }), quote
        }, "jsonString"));
    }
    function jsonNumber() {
        value decimals = option(sequenceOf { skip(character('.')), strParser(many(digit(), 1)) });
        value exponent = option(sequenceOf { skip(oneOf { 'e', 'E' }), integer() });
        return mapParsers({
            option(oneOf { '+', '-' }),
            integer(),
            decimals,
            exponent
        }, ({Character|Integer|String*} results) {
            value args = results.sequence();
            Boolean negative;
            variable Integer index = 0;
            if (is Character first = args[index]) {
                negative = (first == '-');
                index++;
            } else {
                negative = false;
            }
            assert (is Integer whole = args[index++]);
            variable Float? decimalPart = null;
            if (is String decimal = args[index]) {
                decimalPart = parseFloat("0.``decimal``");
                index++;
            }
            value power = if (is Integer e = args[index]) then e else 0;
            if (power < 0, is Null d = decimalPart) {
                decimalPart = 0.0; // when power is negative, we must get a Float
            }
            if (exists d = decimalPart) {
                return (negative then -1 else 1) * (whole.float + d) * (10.0^power);
            } else {
                return (negative then -1 else 1) * whole * (10^power);
            }
        }, "jsonNumber");
    }
    function jsonBoolean()
            => nonEmptySequenceOf({ coalescedParser(mapParser(
                    either { text("false"), text("true") }, parseBoolean)) }, "jsonBoolean");
    function jsonValue()
            => either({ jsonString(), jsonNumber(), jsonBoolean(), jsonNull_() }, "jsonValue");
    
    // a recursive definition needs explicit type
    Parser<{JsonArray*}> jsonArray() => sequenceOf({
            skip(around(spaces(), character('['))),
            chainParser(
                mapValueParser(
                    separatedBy(character(','), jsonElement()),
                    ({JsonElement*} result) => result.sequence())
            ),
            spaces(),
            skip(character(']'))
        }, "jsonArray");
    
    Parser<{JsonElement*}> jsonElement()
            => around(spaces(),
        either({ jsonValue(), jsonObject(), jsonArray() }, "jsonElement"));
    
    Parser<{JsonEntry*}> jsonEntry() => mapParsers({
            jsonString(),
            skip(around(spaces(), character(':'))),
            jsonElement()
        }, ({JsonElement*} elements) {
            assert (is String key = elements.first);
            assert (is JsonElement element = elements.last);
            return key->element;
        }, "jsonEntry");
    
    Parser<{JsonObject*}> jsonObject() => mapParsers({
            skip(around(spaces(), character('{'))),
            separatedBy(around(spaces(), character(',')), jsonEntry()),
            spaces(),
            skip(character('}'))
        }, JsonObject, "jsonObject");
    
    Parser<JsonElement> parser => first(sequenceOf {
            jsonElement(), spaces(), endOfInput()
        });
    
    "Parse the given stream of characters."
    shared JsonElement|ErrorMessage parse({Character*} text) {
        switch (result = parser.parse(text))
        case (is ParseError) {
            print(result);
            return ErrorMessage(result.message);
        }
        else {
            return result.result;
        }
    }
    
}
