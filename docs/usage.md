# Usage Guide

CuteAgent provides three main agent classes for comprehensive automation workflows:

## Quick Start

```python
# Import the agents you need
from cuteagent import WindowsAgent, StationAgent, HumanAgent

# Basic WindowsAgent usage
agent = WindowsAgent()
agent.screenshot()
agent.click_element(100, 200)
```

## WindowsAgent - Computer Automation

### Basic Screen Automation

```python
from cuteagent import WindowsAgent

# Initialize agent
agent = WindowsAgent()

# Take a screenshot
screenshot_url = agent.screenshot()
print(f"Screenshot: {screenshot_url}")

# Click at coordinates
agent.click_element(100, 200)
agent.pause(2)

# Take cropped screenshot
cropped = agent.screenshot_cropped([10, 50, 800, 600])
```

### Element-Based Automation (Recommended)

```python
from cuteagent import WindowsAgent

# Initialize with cache token for element-based clicking
agent = WindowsAgent(cache_token="your-api-key-here")

try:
    # Click on named elements instead of coordinates
    agent.click_cached_element("loginForm", "username_field")
    agent.pause(0.5)
    
    agent.click_cached_element("loginForm", "password_field")
    agent.pause(0.5)
    
    agent.click_cached_element("loginForm", "login_button")
    
    # Verify login success
    screenshot = agent.screenshot()
    print(f"Login completed: {screenshot}")
    
except ValueError as e:
    print(f"Cache token required: {e}")
except Exception as e:
    print(f"Element interaction failed: {e}")
```

### Workflow Automation Example

```python
from cuteagent import WindowsAgent

def automate_data_entry(agent, data_list):
    """Automate data entry using cached elements."""
    try:
        # Navigate to data entry form
        agent.click_cached_element("dataEntry", "new_record_button")
        agent.pause(1)
        
        for item in data_list:
            # Fill form fields
            agent.click_cached_element("dataEntry", "name_field")
            # Note: typing requires separate implementation
            
            agent.click_cached_element("dataEntry", "save_button")
            agent.pause(1)
            
        return True
    except Exception as e:
        print(f"Data entry automation failed: {e}")
        return False

# Usage
agent = WindowsAgent(cache_token="your-token")
data = ["Item 1", "Item 2", "Item 3"]
success = automate_data_entry(agent, data)
```

## StationAgent - State Management

```python
from cuteagent import StationAgent

# Initialize with authentication
agent = StationAgent(
    station_thread_id="workflow-123",
    graph_thread_id="graph-456", 
    token="your-shared-state-token"
)

# Store and retrieve state
agent.state.set("currentStep", "processing")
agent.state.set("userData", {"name": "John", "status": "active"})

# Get state
current_step = agent.state.get("currentStep")
user_data = agent.state.get("userData")

# Coordinate server usage
load_result = agent.server.load("image_processing")
if load_result["status"] == "loaded":
    # Do processing work
    process_images()
    agent.server.unload()
```

## HumanAgent - Human-in-the-Loop

```python
from cuteagent import HumanAgent

# Initialize with HITL token
agent = HumanAgent(
    HITL_token="your-hitl-token",
    HITL_url="https://your-hitl-endpoint.com/prod/"
)

# Send task for human review
image_urls = ["https://example.com/screenshot1.png"]
questions = [{
    "Question": "Does this look correct?",
    "Choices": ["Yes", "No", "Needs revision"]
}]

result = agent.task(
    image_urls=image_urls,
    thread_id="review-123",
    questions=questions,
    task_type="quality_check"
)

# Get reporting
report = agent.reporting(
    thread_id="review-123",
    report_type="final_status"
)
```

## Complete Workflow Example

```python
from cuteagent import WindowsAgent, StationAgent, HumanAgent

def complete_automation_workflow():
    """Example of using all three agents together."""
    
    # 1. Initialize agents
    windows_agent = WindowsAgent(cache_token="windows-token")
    station_agent = StationAgent(
        station_thread_id="workflow-789",
        graph_thread_id="graph-101",
        token="state-token"
    )
    human_agent = HumanAgent(HITL_token="hitl-token")
    
    try:
        # 2. Computer automation
        screenshot = windows_agent.screenshot()
        windows_agent.click_cached_element("approval", "approve_button")
        
        # 3. Update shared state
        station_agent.state.set("approvalScreenshot", screenshot)
        station_agent.state.set("approvalStatus", "submitted")
        
        # 4. Send for human review
        result = human_agent.task(
            image_urls=[screenshot],
            thread_id="approval-review",
            questions=[{
                "Question": "Approve this automation result?",
                "Choices": ["Approve", "Reject", "Retry"]
            }],
            task_type="approval_check"
        )
        
        # 5. Store final result
        station_agent.state.set("workflowComplete", True)
        station_agent.state.set("humanReviewResult", result)
        
        return True
        
    except Exception as e:
        print(f"Workflow failed: {e}")
        # Log error to shared state
        station_agent.state.set("workflowError", str(e))
        return False

# Run the workflow
success = complete_automation_workflow()
print(f"Workflow completed: {success}")
```

## Configuration

### Environment Variables

```bash
# For element search API
export CACHE_TOKEN="your-element-search-api-key"

# For shared state management  
export SHARED_STATE_TOKEN="your-shared-state-token"

# For human-in-the-loop
export HITL_TOKEN="your-hitl-token"

# For computer automation
export OS_URL="https://your-computer-server.ngrok.app"
```

### Initialization Options

```python
# WindowsAgent with all options
windows_agent = WindowsAgent(
    variable_name="automation_bot",
    os_url="https://custom-server.ngrok.app", 
    cache_token="api-key-123"
)

# StationAgent with initial state
initial_state = {
    "workflowId": "wf-123",
    "startTime": "2024-01-01T12:00:00Z"
}
station_agent = StationAgent(
    station_thread_id="workflow-instance",
    graph_thread_id="graph-thread",
    token="shared-state-token",
    initial_state=initial_state
)
```

## Best Practices

1. **Always use cache tokens** for WindowsAgent element-based operations
2. **Handle errors gracefully** with try-catch blocks
3. **Use descriptive element names** that match your cached elements
4. **Implement retry logic** for network-dependent operations
5. **Clean up resources** by unloading servers when done
6. **Store important state** in StationAgent for workflow coordination
7. **Use human review** for critical decision points
