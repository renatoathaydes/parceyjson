import ceylon.test {
    test,
    assertEquals,
    assertTrue,
    fail
}

import com.athaydes.parceyjson {
    json,
    ErrorMessage,
    JsonObject,
    JsonElement,
    jsonNull
}
import ceylon.language.meta {
    type
}

test
shared void emptyStringIsNotValidJson() {
    assertTrue(json.parse("") is ErrorMessage);
}

test
shared void canParseIntegers() {
    assertEquals(json.parse("1"), 1);
    assertEquals(json.parse("9876543210"), 9876543210);
    assertEquals(json.parse("10E6"), 10M);
    assertEquals(json.parse("32e+12"), 32T);
    assertEquals(json.parse(" 46 \n \n "), 46);
    assertEquals(json.parse(" \n\n32 \n \n "), 32);
    
    assertTrue(json.parse("\n \n22 \n \n invalid") is ErrorMessage);
    assertTrue(json.parse("2E") is ErrorMessage);
    assertTrue(json.parse("650e+") is ErrorMessage);
}

test
shared void canParseFloat() {
    assertFloatsEqual(json.parse("1.0"), 1.0);
    assertFloatsEqual(json.parse("-0.2"), -0.2);
    assertFloatsEqual(json.parse("543.210"), 543.21);
    assertFloatsEqual(json.parse(" -12.0E9"), -12.0E9);
    assertFloatsEqual(json.parse(" 12.3e+4"), 12.3E4);
    assertFloatsEqual(json.parse(" +45.3e-6"), 45.3e-6);
    assertFloatsEqual(json.parse("1.2e-12"), 1.2e-12);
    assertFloatsEqual(json.parse("10e-1"), 1.0);
    
    assertTrue(json.parse("43.E1") is ErrorMessage, json.parse("43.E1").string);
    assertTrue(json.parse("4.4E") is ErrorMessage, json.parse("4.4E").string);
    assertTrue(json.parse("4.4E+") is ErrorMessage, json.parse("4.4E+").string);
    assertTrue(json.parse(".5") is ErrorMessage, json.parse(".5").string);
}

test
shared void canParseStrings() {
    assertEquals(json.parse("\"hi\""), "hi");
    assertEquals(json.parse("\"\""), "");
    assertEquals(json.parse(" \"  hello!! \"  \n\n "), "  hello!! ");
    assertEquals(json.parse(" \n\n\"many\nlines\" \n \n "), "many\nlines");
    assertEquals(json.parse("\"a\\nb\\nc\""), "a\\nb\\nc");
    assertEquals(json.parse("\"a \\\"hi\\\"\""), "a \\\"hi\\\"");
    assertEquals(json.parse("\"a\\u18AF\""), "a\\u18AF");
    
    assertTrue(json.parse("invalid") is ErrorMessage);
    assertTrue(json.parse("\"invalid") is ErrorMessage);
    assertTrue(json.parse("invalid\"") is ErrorMessage);
}

test
shared void canParseBoolean() {
    assertEquals(json.parse("true"), true);
    assertEquals(json.parse("false"), false);
}

test shared void canParseNull() {
    assertEquals(json.parse("null"), jsonNull);
}

test shared void canParseArrays() {
    assertEquals(json.parse("[]"), []);
    assertEquals(json.parse("[1]"), [1]);
    assertEquals(json.parse("[0, 10, 100]"),
        [0, 10, 100]);
    assertEquals(json.parse("[ \"hello\",\n\"bye\" \n]"),
        ["hello", "bye"]);
    assertEquals(json.parse("[\"one\", 2, true]"),
        [ "one", 2, true]);
    
    assertTrue(json.parse("[ 2") is ErrorMessage);
    assertTrue(json.parse("[ 2 []") is ErrorMessage);
}

test shared void canParseObjects() {
    String objectJson = """{
                               "name": "Renato",
                               "age": 34,
                               "status": "engaged",  
                               "hobbies": ["programming", "music"],
                               "has_degree": true,
                               "retire_date": null
                           }""";
    assertEquals(json.parse(objectJson), JsonObject({
        "name" -> "Renato",
        "age" -> 34,
        "status" -> "engaged",
        "hobbies" -> [
            "programming", "music"],
        "has_degree" -> true,
        "retire_date" -> jsonNull
    }));
}

test shared void canParseRealWorldExampleJson() {
    value exampleJson =
            //"""{
            //   "web-app": {
            //           "servlet": [
            //               { "hi": true }
            //           ]
            //   }
            //   }
            //            """;
            """{
                "web-app": {
                    "servlet": [
                        {
                            "servlet-name": "cofaxCDS",
                            "servlet-class": "org.cofax.cds.CDSServlet",
                            "init-param": {
                                "configGlossary:installationAt": "Philadelphia, PA",
                                "configGlossary:adminEmail": "ksm@pobox.com",
                                "configGlossary:poweredBy": "Cofax",
                                "configGlossary:poweredByIcon": "/images/cofax.gif",
                                "configGlossary:staticPath": "/content/static",
                                "templateProcessorClass": "org.cofax.WysiwygTemplate",
                                "templateLoaderClass": "org.cofax.FilesTemplateLoader",
                                "templatePath": "templates",
                                "templateOverridePath": "",
                                "defaultListTemplate": "listTemplate.htm",
                                "defaultFileTemplate": "articleTemplate.htm",
                                "useJSP": false,
                                "jspListTemplate": "listTemplate.jsp",
                                "jspFileTemplate": "articleTemplate.jsp",
                                "cachePackageTagsTrack": 200,
                                "cachePackageTagsStore": 200,
                                "cachePackageTagsRefresh": 60,
                                "cacheTemplatesTrack": 100,
                                "cacheTemplatesStore": 50,
                                "cacheTemplatesRefresh": 15,
                                "cachePagesTrack": 200,
                                "cachePagesStore": 100,
                                "cachePagesRefresh": 10,
                                "cachePagesDirtyRead": 10,
                                "searchEngineListTemplate": "forSearchEnginesList.htm",
                                "searchEngineFileTemplate": "forSearchEngines.htm",
                                "searchEngineRobotsDb": "WEB-INF/robots.db",
                                "useDataStore": true,
                                "dataStoreClass": "org.cofax.SqlDataStore",
                                "redirectionClass": "org.cofax.SqlRedirection",
                                "dataStoreName": "cofax",
                                "dataStoreDriver": "com.microsoft.jdbc.sqlserver.SQLServerDriver",
                                "dataStoreUrl": "jdbc:microsoft:sqlserver://LOCALHOST:1433;DatabaseName=goon",
                                "dataStoreUser": "sa",
                                "dataStorePassword": "dataStoreTestQuery",
                                "dataStoreTestQuery": "SET NOCOUNT ON;select test='test';",
                                "dataStoreLogFile": "/usr/local/tomcat/logs/datastore.log",
                                "dataStoreInitConns": 10,
                                "dataStoreMaxConns": 100,
                                "dataStoreConnUsageLimit": 100,
                                "dataStoreLogLevel": "debug",
                                "maxUrlLength": 500
                            }
                        },
                        {
                            "servlet-name": "cofaxEmail",
                            "servlet-class": "org.cofax.cds.EmailServlet",
                            "init-param": {
                                "mailHost": "mail1",
                                "mailHostOverride": "mail2"
                            }
                        },
                        {
                            "servlet-name": "cofaxAdmin",
                            "servlet-class": "org.cofax.cds.AdminServlet"
                        },
                        {
                            "servlet-name": "fileServlet",
                            "servlet-class": "org.cofax.cds.FileServlet"
                        },
                        {
                            "servlet-name": "cofaxTools",
                            "servlet-class": "org.cofax.cms.CofaxToolsServlet",
                            "init-param": {
                                "templatePath": "toolstemplates/",
                                "log": 1,
                                "logLocation": "/usr/local/tomcat/logs/CofaxTools.log",
                                "logMaxSize": "",
                                "dataLog": 1,
                                "dataLogLocation": "/usr/local/tomcat/logs/dataLog.log",
                                "dataLogMaxSize": "",
                                "removePageCache": "/content/admin/remove?cache=pages&id=",
                                "removeTemplateCache": "/content/admin/remove?cache=templates&id=",
                                "fileTransferFolder": "/usr/local/tomcat/webapps/content/fileTransferFolder",
                                "lookInContext": 1,
                                "adminGroupID": 4,
                                "betaServer": true
                            }
                        }
                    ],
                    "servlet-mapping": {
                        "cofaxCDS": "/",
                        "cofaxEmail": "/cofaxutil/aemail/*",
                        "cofaxAdmin": "/admin/*",
                        "fileServlet": "/static/*",
                        "cofaxTools": "/tools/*"
                    },
                    "taglib": {
                        "taglib-uri": "cofax.tld",
                        "taglib-location": "/WEB-INF/tlds/cofax.tld"
                    }
                }
               }""";

    value result = json.parse(exampleJson);
    assertEquals(type(result), `JsonObject`, result.string);
}

void assertFloatsEqual(JsonElement|ErrorMessage first, Float other) {
    if (is Float first) {
        value tolerance = 1.0u;
        assertTrue(first - tolerance < other < first + tolerance,
            "Expected ``other`` but was ``first``");    
    } else {
        fail("Expected Float. Found ``first``");
    }
}
