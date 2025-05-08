#!/usr/bin/env python

"""Tests for `cuteagent` package."""


import unittest
from io import StringIO
import sys
from cuteagent import WindowsAgent


class TestWindowsAgent(unittest.TestCase):
    """Tests for `cuteagent` package."""

    def setUp(self):
        """Capture stdout before each test."""
        self.held_stdout = sys.stdout
        sys.stdout = self.captured_output = StringIO()

    def tearDown(self):
        """Restore stdout after each test."""
        sys.stdout = self.held_stdout

    def test_hello_old_friend_default_config(self):
        """Test hello_old_friend with default variable_name."""
        agent = WindowsAgent()
        agent.hello_old_friend()
        self.assertEqual(self.captured_output.getvalue().strip(), "Hello, my old friend!")

    def test_hello_old_friend_custom_config(self):
        """Test hello_old_friend with a custom variable_name."""
        custom_name = "companion"
        agent = WindowsAgent(variable_name=custom_name)
        agent.hello_old_friend()
        self.assertEqual(self.captured_output.getvalue().strip(), f"Hello, my old {custom_name}!")

    def test_hello_world(self):
        """Test the hello_world method."""
        agent = WindowsAgent()
        agent.hello_world()
        self.assertEqual(self.captured_output.getvalue().strip(), "Hello World from WindowsAgent!")

    def test_add_method(self):
        """Test the add method."""
        agent = WindowsAgent()
        result = agent.add(5, 3)
        self.assertEqual(result, 8)
        result_negative = agent.add(-5, 3)
        self.assertEqual(result_negative, -2)


if __name__ == '__main__':
    # Create a TestLoader instance
    loader = unittest.TestLoader()
    # Load tests from the current module
    # Correctly get the current module: sys.modules[__name__] if run as script
    # or for more robustness if imported: unittest.defaultTestLoader.loadTestsFromModule(__import__(__name__))
    # Given the __name__ == '__main__' context, sys.modules[__name__] is fine.
    suite = loader.loadTestsFromModule(sys.modules[__name__])
    
    # Create a TestRunner to run the tests
    runner = unittest.TextTestRunner(verbosity=2) # verbosity=2 for more detailed output
    result = runner.run(suite)

    if result.wasSuccessful():
        print("\nAll Python unit tests passed successfully!")
    else:
        print("\nSome Python unit tests failed.")
        # Exit with a non-zero status code to indicate failure
        sys.exit(1)
