<h1 align="center">TestEZ</h1>
<div align="center">
	<a href="https://github.com/Roblox/testez/actions?query=workflow%3ACI">
		<img src="https://github.com/Roblox/testez/workflows/CI/badge.svg" alt="GitHub Actions Build Status" />
	</a>
	<a href="https://roblox.github.io/testez">
		<img src="https://img.shields.io/badge/docs-website-green.svg" alt="Documentation" />
	</a>
</div>

<div align="center">
	BDD-style Roblox Lua testing framework
</div>

<div>&nbsp;</div>

TestEZ can run within Roblox itself, as well as inside [Lemur](https://github.com/LPGhatguy/Lemur) for testing on CI systems.

We use TestEZ at Roblox for testing our apps, in-game core scripts, built-in Roblox Studio plugins, as well as libraries like [Roact](https://github.com/Roblox/roact) and [Rodux](https://github.com/Roblox/rodux).

It provides an API that can run all of your tests with a single method call as well as a more granular API that exposes each step of the pipeline.

## Inspiration and Prior Work
The `describe` and `it` syntax in TestEZ is based on the [Behavior-Driven Development](https://en.wikipedia.org/wiki/Behavior-driven_development) methodology, notably as implemented in RSpec (Ruby), busted (Lua), Mocha (JavaScript), and Ginkgo (Go).

The `expect` syntax is based on Chai, a JavaScript assertion library commonly used with Mocha. Similar expectation systems are also used in RSpec and Ginkgo, with slightly different syntax.

## Contributing
Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for information.

## License
TestEZ is available under the Apache 2.0 license. See [LICENSE](LICENSE) for details.