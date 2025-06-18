# 🐾 CuteAgent

**Computer Use Task Execution Agent**  
*A Python library for building, orchestrating, and integrating computer-use AI agents in agentic workflows.*

---
[![PyPI](https://img.shields.io/pypi/v/cuteagent?color=blue)](https://pypi.org/project/cuteagent/)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

# CuteAgent - Complete Agent Suite for LangGraph Workflows

**CuteAgent** provides three powerful agents for building comprehensive LangGraph workflows:

- **🤖 StationAgent**: Shared state management and workflow coordination
- **🖥️ WindowsAgent**: Computer use automation on Windows servers  
- **👥 HumanAgent**: Human-in-the-loop (HITL) task management

Together, these agents enable complete automation workflows where AI performs computer tasks, humans provide oversight and decisions, and shared state coordinates everything seamlessly.

## 📦 Installation

```bash
pip install cuteagent
```

---

# 🤖 StationAgent - Shared State Management

**StationAgent** provides shared state management and server coordination for LangGraph workflows. It integrates with a SharedState API to enable multiple workflow instances to coordinate, share data, and manage server resources efficiently.

## 🚀 Key Features

- **Shared State Management**: Sync variables between multiple LangGraph workflow instances
- **Server Coordination**: Prevent conflicts with "busy"/"idle" server status management  
- **Workflow Resumption**: Handle interrupted workflows with thread ID tracking
- **Reserved Variable Protection**: Secure server management variables from user modification
- **LangGraph Integration**: Seamless integration with LangGraph state objects
- **Error Handling**: Robust retry logic and comprehensive error handling

## 🔧 Quick Start

### 1. Add Shared State to Your LangGraph State Class

```python
from dataclasses import dataclass, field
from typing import Dict, Any, Optional

@dataclass
class State:
    # Your existing fields...
    current_node: float = 0
    user_input: str = ""
    stationThreadId: str = ""
    
    # Add this field for SharedState integration
    sharedState: Optional[Dict[str, Any]] = field(default_factory=dict)
```

### 2. Initialize StationAgent in Your LangGraph Nodes

```python
from cuteagent import StationAgent

async def your_langgraph_node(state: State, config: RunnableConfig) -> State:
    # Initialize StationAgent - automatically pulls existing shared state
    agent = StationAgent(
        station_thread_id=state.stationThreadId,
        graph_thread_id=config.get("thread_id"),
        token=config.get("shared_state_token", "your-api-token")
    )
    # 🔄 Agent now has agent.initial_state with any existing variables
    
    # Sync shared state variables to LangGraph state
    state = agent.state.sync_all(state)
    
    # Check what initial state was loaded (optional)
    if agent.initial_state:
        print(f"Loaded {len(agent.initial_state)} existing variables")
    
    # Your node logic here...
    
    # Update shared state
    agent.state.set("currentNode", "processing")
    agent.state.set("timestamp", "2024-01-01T12:00:00Z")
    
    return state
```

## 📊 Sync Patterns

StationAgent provides three sync patterns that update your LangGraph state and return the updated state object:

### Pattern 1: Sync Single Variable
```python
state = agent.state.sync("variableName", state)
```

### Pattern 2: Sync Multiple Variables  
```python
state = agent.state.sync_multiple(["var1", "var2", "var3"], state)
```

### Pattern 3: Sync All Variables
```python
state = agent.state.sync_all(state)
```

---

# 🖥️ WindowsAgent - Computer Use Automation

**WindowsAgent** enables computer use automation on Windows servers maintained by Fintor. It provides methods for clicking, taking screenshots, and performing other computer tasks remotely.

## 🚀 Key Features

- **Remote Computer Control**: Click, pause, and interact with Windows servers
- **Screenshot Capabilities**: Full and cropped screenshots with URL responses
- **Async Integration**: Thread-safe operations for LangGraph workflows
- **Error Resilience**: Graceful handling of server issues
- **Coordinate-based Actions**: Precise control with x,y coordinates

## 🔧 Quick Start

### 1. Initialize WindowsAgent

```python
from cuteagent import WindowsAgent
import asyncio

async def windows_automation_node(state: State, config: RunnableConfig) -> State:
    configuration = config["configurable"]
    
    # Initialize WindowsAgent with server URL
    os_url = configuration.get("os_url", "https://your-windows-server.ngrok.app")
    agent = WindowsAgent(os_url=os_url)
    
    try:
        # Click at specific coordinates
        await asyncio.to_thread(agent.click_element, 100, 200)
        
        # Wait/pause
        await asyncio.to_thread(agent.pause, 3)
        
        # Take a full screenshot
        screenshot_result = await asyncio.to_thread(agent.screenshot)
        if isinstance(screenshot_result, dict) and "url" in screenshot_result:
            state.screenshot_url = screenshot_result["url"]
        else:
            state.screenshot_url = screenshot_result
        
        # Take a cropped screenshot [x, y, width, height]
        cropped_result = await asyncio.to_thread(
            agent.screenshot_cropped, 
            [10, 200, 1000, 450]
        )
        
        print(f"Screenshot URL: {state.screenshot_url}")
        
    except Exception as e:
        print(f"Windows automation error: {e}")
        # Continue workflow even on errors
        
    state.current_node = 8
    return state
```

## 📖 WindowsAgent API Reference

### Constructor

```python
WindowsAgent(os_url: str)
```

**Parameters:**
- `os_url` (str): URL of the Windows server (e.g., "https://server.ngrok.app")

### Methods

#### `agent.click_element(x: int, y: int)`
Click at specific screen coordinates.

```python
await asyncio.to_thread(agent.click_element, 150, 300)
```

#### `agent.pause(seconds: int)`
Pause execution for specified seconds.

```python
await asyncio.to_thread(agent.pause, 5)
```

#### `agent.screenshot()`
Take a full screenshot of the desktop.

```python
result = await asyncio.to_thread(agent.screenshot)
# Returns: {"url": "https://..."} or URL string
```

#### `agent.screenshot_cropped(coordinates: List[int])`
Take a cropped screenshot with [x, y, width, height] coordinates.

```python
result = await asyncio.to_thread(agent.screenshot_cropped, [10, 50, 800, 600])
# Returns: {"url": "https://..."} or URL string
```

---

# 👥 HumanAgent - Human-in-the-Loop Task Management

**HumanAgent** integrates with Fintor's HITL service to bring humans into LangGraph workflows for approvals, decisions, and oversight. Responses are processed manually outside of CuteAgent and update shared state via StationAgent.

## 🚀 Key Features

- **Task Submission**: Send tasks with questions and images to humans
- **Choice-based Responses**: Multiple choice questions with predefined options
- **Image Support**: Include screenshots and visual content for human review
- **External State Updates**: Human responses processed outside the system
- **Task Type Management**: Categorize tasks with custom task types
- **Reporting**: Report workflow results back to human operators

## 🔧 Quick Start

### 1. Send Task for Human Review

```python
from cuteagent import HumanAgent
import asyncio

async def send_human_task_node(state: State, config: RunnableConfig) -> State:
    """Send a task to humans for review with image and questions."""
    configuration = config["configurable"]
    
    hitl_token = configuration.get("hitl_token", os.getenv("HITL_TOKEN"))
    agent = HumanAgent(
        HITL_token=hitl_token, 
        HITL_url="https://d5x1qrpuf7.execute-api.us-west-1.amazonaws.com/prod/"
    )
    
    # Prepare the human review task
    image_urls = [state.screenshot_url] if state.screenshot_url else []
    
    question_text = f"Agent found {len(state.borrower_names)} borrowers with Document Date.\n"
    question_text += "Please review and approve:\n"
    for borrower in state.borrower_names:
        question_text += f"- {borrower}\n"
    question_text += "\nDo you approve this decision?"
    
    questions = [{
        "Question": question_text, 
        "Choices": ["TRUE", "FALSE"]
    }]
    
    thread_id = configuration.get("thread_id", str(uuid.uuid4()))
    
    # Create state data for HITL system
    state_dict = {
        "user_input": state.user_input,
        "current_node": state.current_node,
        "borrower_names": state.borrower_names,
        "stationThreadId": state.stationThreadId
    }
    
    try:
        # Send task to human agent
        result = await asyncio.to_thread(
            agent.task,
            image_urls=image_urls,
            thread_id=thread_id,
            questions=questions,
            task_type="S1-T1",  # Your task type
            thread_state=state_dict
        )
        
        print(f"Human task sent successfully for thread: {thread_id}")
        
        # Store pending review info for interrupt
        state.pending_review_info = {
            "screenshot_url": state.screenshot_url,
            "borrower_names": state.borrower_names,
            "instructions": "Review extracted borrower names and respond via HITL system",
            "thread_id_of_task": thread_id
        }
        
    except Exception as e:
        print(f"Error sending human task: {e}")
        # Continue workflow or handle error appropriately
        
    state.current_node = 10.5
    return state
```

### 2. Report Results to Humans

```python
async def report_to_human_node(state: State, config: RunnableConfig) -> State:
    """Report final workflow results to human operators."""
    configuration = config["configurable"]
    
    hitl_token = configuration.get("hitl_token", os.getenv("HITL_TOKEN"))
    agent = HumanAgent(
        HITL_token=hitl_token, 
        HITL_url="https://d5x1qrpuf7.execute-api.us-west-1.amazonaws.com/prod/"
    )
    
    thread_id = configuration.get("thread_id")
    
    # Prepare final state report
    state_dict = {
        "user_input": state.user_input,
        "current_node": state.current_node,
        "screenshot_url": state.screenshot_url,
        "borrower_names": state.borrower_names,
        "human_review_decision": state.human_review_decision,
        "status": state.status,
        "stationThreadId": state.stationThreadId
    }
    
    try:
        # Report final results
        result = await asyncio.to_thread(
            agent.reporting,
            thread_id=thread_id,
            report_type="S1-R1",  # Your report type
            thread_state=state_dict
        )
        
        print(f"Results reported to human agent: {result}")
        
    except Exception as e:
        print(f"Error reporting to human agent: {e}")
    
    state.current_node = 12
    return state
```

## 📖 HumanAgent API Reference

### Constructor

```python
HumanAgent(HITL_token: str, HITL_url: str)
```

**Parameters:**
- `HITL_token` (str): Authentication token for HITL service
- `HITL_url` (str): URL of the HITL service API

### Methods

#### `agent.task(image_urls, thread_id, questions, task_type, thread_state)`
Send a task to humans for review and decision.

**Parameters:**
- `image_urls` (List[str]): URLs of images (e.g., screenshots) for human review
- `thread_id` (str): Unique thread identifier for the task
- `questions` (List[Dict]): Questions with choices for humans to answer
- `task_type` (str): Category/type of the task (e.g., "S1-T1", "S2-T3")
- `thread_state` (Dict): Current workflow state data

**Questions Format:**
```python
questions = [{
    "Question": "Do you approve these borrower names?",
    "Choices": ["TRUE", "FALSE"]
}]
```

#### `agent.reporting(thread_id, report_type, thread_state)`
Report workflow results and final state to human operators.

**Parameters:**
- `thread_id` (str): Thread identifier for the report
- `report_type` (str): Type of report (e.g., "S1-R1", "FINAL")
- `thread_state` (Dict): Final workflow state and results

---

# 🔄 Complete Multi-Agent Workflow Example

Here's a complete example showing all three agents working together:

```python
from dataclasses import dataclass, field
from typing import Any, Dict, Optional, List
import asyncio
import uuid
from cuteagent import StationAgent, WindowsAgent, HumanAgent

@dataclass
class WorkflowState:
    current_node: float = 0
    user_input: str = ""
    stationThreadId: str = ""
    borrower_names: List[str] = field(default_factory=list)
    screenshot_url: str | None = None
    status: str = "Ongoing"
    human_review_decision: str | None = None
    pending_review_info: Optional[Dict[str, Any]] = None
    
    # Required for StationAgent integration
    sharedState: Optional[Dict[str, Any]] = field(default_factory=dict)

async def complete_workflow_node(state: WorkflowState, config) -> WorkflowState:
    """Complete workflow using all three agents."""
    configuration = config["configurable"]
    
    # 1. Initialize StationAgent for coordination
    station_agent = StationAgent(
        station_thread_id=state.stationThreadId or "main-workflow",
        graph_thread_id=configuration.get("thread_id"),
        token=configuration.get("shared_state_token")
    )
    
    # 2. Sync shared state to get latest workflow data
    state = station_agent.state.sync_all(state)
    
    # 3. Check server availability and load for computer use
    server_status = station_agent.server.avail()
    if server_status.get("server") == "idle":
        load_result = station_agent.server.load("screenshot_task")
        if load_result["status"] == "loaded":
            
            # 4. Use WindowsAgent for computer automation
            os_url = configuration.get("os_url")
            windows_agent = WindowsAgent(os_url=os_url)
            
            try:
                # Perform computer tasks
                await asyncio.to_thread(windows_agent.click_element, 294, 98)
                await asyncio.to_thread(windows_agent.pause, 2)
                
                # Take screenshot for human review
                screenshot_result = await asyncio.to_thread(
                    windows_agent.screenshot_cropped, 
                    [10, 200, 1000, 450]
                )
                
                if isinstance(screenshot_result, dict):
                    state.screenshot_url = screenshot_result["url"]
                else:
                    state.screenshot_url = screenshot_result
                    
            except Exception as e:
                print(f"Windows automation error: {e}")
            
            # 5. Send task to HumanAgent for review
            hitl_token = configuration.get("hitl_token")
            human_agent = HumanAgent(
                HITL_token=hitl_token,
                HITL_url="https://d5x1qrpuf7.execute-api.us-west-1.amazonaws.com/prod/"
            )
            
            questions = [{
                "Question": f"Screenshot taken successfully. Proceed with processing?",
                "Choices": ["APPROVE", "REJECT"]
            }]
            
            thread_id = configuration.get("thread_id")
            state_dict = {
                "screenshot_url": state.screenshot_url,
                "current_node": state.current_node,
                "stationThreadId": state.stationThreadId
            }
            
            try:
                await asyncio.to_thread(
                    human_agent.task,
                    image_urls=[state.screenshot_url] if state.screenshot_url else [],
                    thread_id=thread_id,
                    questions=questions,
                    task_type="S1-T1",
                    thread_state=state_dict
                )
                
                print("Human review task sent successfully")
                
            except Exception as e:
                print(f"Human task error: {e}")
            
            # 6. Update shared state with workflow progress
            station_agent.state.push({
                "lastCompletedNode": state.current_node,
                "screenshotTaken": True,
                "humanTaskSent": True,
                "workflowStatus": "awaiting_human_review"
            })
            
            # 7. Unload server when done
            station_agent.server.unload()
            
    else:
        print("Server is busy, waiting...")
        
    # 8. Sync final state back to LangGraph
    state = station_agent.state.sync_all(state)
    
    state.current_node += 1
    return state
```

This example demonstrates how all three agents work together:
- **StationAgent** coordinates shared state and server access
- **WindowsAgent** performs computer automation tasks
- **HumanAgent** provides human oversight and decision-making

---

# 📋 StationAgent Detailed API Reference

## Constructor and Initialization

### `StationAgent(station_thread_id, graph_thread_id, token, shared_state_url=None)`

Create a new StationAgent instance with automatic state initialization.

**Parameters:**
- `station_thread_id` (str): Identifier for the station/workflow instance
- `graph_thread_id` (str): LangGraph thread identifier  
- `token` (str): Authentication token for SharedState API
- `shared_state_url` (str, optional): Custom API URL (defaults to global URL)

**Automatic Initialization:**
- Automatically pulls existing shared state from API during initialization
- Stores result in `agent.initial_state` attribute for easy access
- Provides console feedback about loaded variables

**Attributes:**
- `agent.initial_state` (dict): Dictionary of all variables loaded during initialization

**Example:**
```python
# Initialize agent - automatically loads existing state
agent = StationAgent("workflow-123", "thread-456", "token")

# Check what was loaded
print(f"Loaded variables: {list(agent.initial_state.keys())}")
if "workflowStatus" in agent.initial_state:
    print(f"Existing status: {agent.initial_state['workflowStatus']}")
```

## State Management Methods

### `agent.state.sync(variable_name, langgraph_state=None)`
Sync single variable from SharedState API to LangGraph state.

```python
# Returns updated state object
state = agent.state.sync("currentStep", state)

# Returns just the variable value (backward compatibility)
value = agent.state.sync("currentStep")
```

### `agent.state.sync_multiple(variable_names, langgraph_state=None)`
Sync multiple variables from SharedState API to LangGraph state.

```python
state = agent.state.sync_multiple(["var1", "var2", "var3"], state)
```

### `agent.state.sync_all(langgraph_state)`
Sync all variables from SharedState API to LangGraph state.

```python
state = agent.state.sync_all(state)
```

### `agent.state.set(variable_name, value)`
Create or update a single variable in SharedState API.

```python
agent.state.set("currentStep", "processing")
agent.state.set("userPrefs", {"theme": "dark"})
```

### `agent.state.get(variable_name)`
Get a single variable from SharedState API.

```python
current_step = agent.state.get("currentStep")  # Returns value or None
```

### `agent.state.push(variables_dict)`
Bulk create/update multiple variables in SharedState API.

```python
agent.state.push({
    "workflowId": "wf-123",
    "status": "processing", 
    "data": {"key": "value"}
})
```

### `agent.state.pull()`
Get all variables from SharedState API.

```python
all_vars = agent.state.pull()  # Returns dict of all variables
```

### `agent.state.delete(variable_name)`
Delete a variable from SharedState API.

```python
agent.state.delete("temporary_data")
```

### `agent.state.exists(variable_name)`
Check if a variable exists in SharedState API.

```python
if agent.state.exists("userPreferences"):
    prefs = agent.state.get("userPreferences")
```

### `agent.state.list_variables()`
Get list of all variable names.

```python
var_names = agent.state.list_variables()  # Returns list of strings
```

## Server Management Methods

### `agent.server.load(task_type)`
Load server for a specific task type.

```python
result = agent.server.load("data_processing")
# Returns: {"status": "loaded", "serverThread": "data_processing"} 
#       or {"status": "busy", "error": "Server is busy"}
```

### `agent.server.unload()`
Unload server and set to idle.

```python
result = agent.server.unload()
# Returns: {"status": "unloaded"}
#       or {"status": "idle", "error": "Server is already idle"}
```

### `agent.server.avail()`
Get current server availability status.

```python
status = agent.server.avail()
# Returns: {"server": "busy|idle", "serverThread": "task_type|idle"}
```

## Task Management Methods

### `agent.uninterrupt(task_type)`
Get task thread ID for resuming interrupted tasks.

```python
resume_info = agent.uninterrupt("main_workflow")
# Returns: {"resumeFrom": "thread-id"} or {"error": "Thread ID not found"}
```

## 🔒 Reserved Variables

StationAgent protects these variables from user modification:

- **`server`**: Server status ("busy" or "idle" only)
- **`serverThread`**: Current task type when server is busy

These can only be modified through server management methods:
- `agent.server.load(task_type)` - Sets server to "busy"
- `agent.server.unload()` - Sets server to "idle"

```python
# ❌ This will raise ValueError
agent.state.set("server", "custom_status")  

# ✅ This is the correct way
agent.server.load("my_task")  # Sets server to "busy", serverThread to "my_task"
```

---

## ⚙️ Configuration

### Environment Variables
```bash
# StationAgent
export SHARED_STATE_URL="https://your-api.amazonaws.com/prod"
export SHARED_STATE_TOKEN="your-api-token"

# HumanAgent
export HITL_TOKEN="your-hitl-token"

# WindowsAgent (configured per workflow)
# os_url provided in LangGraph configuration
```

### LangGraph Configuration
```python
config = {
    "configurable": {
        "shared_state_token": "your-api-token",
        "hitl_token": "your-hitl-token", 
        "os_url": "https://your-windows-server.ngrok.app",
        "thread_id": "your-langgraph-thread-id"
    }
}
```

## 🚨 Error Handling

### StationAgent
- **Network Retries**: 3 attempts with exponential backoff
- **Authentication Errors**: Clear messages for invalid tokens
- **Reserved Variable Protection**: ValueError for protected variables

### WindowsAgent  
- **Connection Issues**: Graceful failure with workflow continuation
- **Server Errors**: Exception handling with logging
- **Timeout Handling**: Async operations with proper error propagation

### HumanAgent
- **Service Issues**: Contact support_eng@fintor.com
- **Task Failures**: Manual processing required outside the system
- **Response Processing**: Done manually outside CuteAgent

```python
try:
    state = agent.state.sync_all(state)
except ValueError as e:
    # Handle reserved variable violations
    print(f"Configuration error: {e}")
except Exception as e:
    # Handle network/API errors
    print(f"Network error: {e}")
    # Continue with workflow using existing state
```

## 📚 Best Practices for Multi-Agent Workflows

1. **Initialize StationAgent first** in each node for state coordination
2. **Check server availability** before WindowsAgent operations
3. **Use HumanAgent for critical decisions** and quality assurance
4. **Include screenshots** in human tasks for better context
5. **Handle errors gracefully** - workflows should be resilient
6. **Update shared state regularly** for workflow coordination
7. **Use meaningful task types** for HumanAgent categorization
8. **Clean up resources** - unload servers when done

## 📖 Additional Documentation

- **[API Reference](docs/api_reference.md)** - Complete API documentation
- **[LangGraph Integration](docs/langgraph_integration.md)** - Detailed integration guide
- **[Deployment Guide](DEPLOYMENT.md)** - Automated deployment instructions

## 🤝 Contributing

CuteAgent is part of a comprehensive agent suite. For issues, feature requests, or contributions, please contact the development team.

## 📄 License

This project is licensed under the MIT License.

---

**Ready to build complete AI workflows with computer use, human oversight, and shared coordination? Start using CuteAgent today!** 🚀



