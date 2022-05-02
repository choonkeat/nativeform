compile: src/Main.elm ../src/*/*.elm
	elm make src/Main.elm --output build/main.js

netlify:
	npx --package elm@0.19.1-5 elm make src/Main.elm --output build/main.js --debug
