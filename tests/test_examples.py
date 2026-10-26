import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
EXAMPLES = ROOT / "examples"
EXPECTED = {
    "01-cog-tiles",
    "02-rescaling",
    "03-stac-endpoints",
    "04-statistics",
    "05-custom-application",
    "06-full-workflow",
}


class ExampleContractTests(unittest.TestCase):
    def test_example_inventory_is_complete(self):
        actual = {path.name for path in EXAMPLES.iterdir() if path.is_dir()}
        self.assertEqual(actual, EXPECTED)

    def test_each_example_has_documentation_and_an_entrypoint(self):
        for name in sorted(EXPECTED):
            with self.subTest(example=name):
                directory = EXAMPLES / name
                self.assertTrue((directory / "README.md").is_file())
                entrypoints = [directory / "example.sh", directory / "app.py"]
                self.assertTrue(any(path.is_file() for path in entrypoints), f"{name} needs example.sh or app.py")

    def test_shell_examples_fail_fast(self):
        for script in sorted(EXAMPLES.glob("*/example.sh")):
            with self.subTest(script=script.relative_to(ROOT)):
                content = script.read_text(encoding="utf-8")
                self.assertIn("set -euo pipefail", content)


if __name__ == "__main__":
    unittest.main()
