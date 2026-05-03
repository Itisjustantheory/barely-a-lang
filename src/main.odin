package main

import "core:fmt"
import "core:os"

main :: proc() {
	file, file_error := os.open("../barely_src/test01.barely")

	if file_error != os.ERROR_NONE {
		fmt.println("cannot find barely-lang src(s) ")
		os.exit(-1)
	}

	defer os.close(file)

	source_code, read_error := os.read_entire_file_from_file(file, context.allocator)

	if read_error != os.ERROR_NONE {
		fmt.println("could not read barely-lang src(s)")
		os.exit(-1)
	}

	fmt.println(string(source_code))


}
