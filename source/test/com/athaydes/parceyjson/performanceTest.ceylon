import ceylon.test {
	test,
	fail,
	assertEquals
}

import com.athaydes.parceyjson {
	json,
	JsonObject
}

native test void performanceTest();

native("js") test void performanceTest() {
	
}

native("jvm") test void performanceTest() {
	value apacheBuildsJson = `module`.resourceByPath("apache_builds.json");
	if (exists apacheBuildsJson) {
		value text = apacheBuildsJson.textContent();
		value t = system.nanoseconds;
		value result = json.parse(text);
		assert(is JsonObject result);
		print("Parsed JSON in ``(system.nanoseconds- t) / 1M``ms");
		//print("Got ``result``");
		assertEquals(result["assignedLabels"], [JsonObject({})]);
	} else {
		fail("JSON File does not exist");
	}
}