"""Main module."""
from gradio_client import Client
# https://working-tuna-massive.ngrok-free.app
# https://upright-mantis-intensely.ngrok-free.app/
# https://working-tuna-massive.ngrok-free.app/

OS_URL = "https://fintor-cute-test-1.ngrok.app"


class WindowsAgent:
    def __init__(self, variable_name="friend" , os_url=OS_URL):
        """
        Initializes the WindowsAgent with a configurable variable name.

        Args:
            variable_name (str): The name to be used by hello_old_friend.
                                 Defaults to "friend".
        """
        self.config_variable_name = variable_name
        self.os_url = os_url

    def hello_world(self):
        """Prints a hello world message."""
        print("Hello World from WindowsAgent!")

    def hello_old_friend(self):
        """Prints a greeting to the configured variable name."""
        print(f"Hello, my old {self.config_variable_name}!")

    def add(self, a, b):
        """Adds two numbers and returns the result."""
        return a + b

    def act(self, input_data):
        try:
            client = Client(self.os_url) 
            result = client.predict(
                user_input=str(input_data),
                api_name="/process_input1"
            )
            print(result)
        except Exception as e:
            print(f"Error in act operation: {e}")
            return None
        

    def screenshot(self):
        try:
            client = Client(self.os_url) 
            result = client.predict(
                api_name="/get_screenshot_url"
            )
            print(result)
        except Exception as e:
            print(f"Error in act operation: {e}")
            return result
        

    def screenshot_cropped(self, arr_input):
        try:
            client = Client(self.os_url) 
            result = client.predict(
                array_input=arr_input,
                api_name="/get_cropped_screenshot"
            )
            print(result)
        except Exception as e:
            print(f"Error in act operation: {e}")
            return result
