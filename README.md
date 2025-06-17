# 🐾 CuteAgent

**Computer Use Task Execution Agent**  
*A Python library for building, orchestrating, and integrating computer-use AI agents in agentic workflows.*

---
[![PyPI](https://img.shields.io/pypi/v/cuteagent?color=blue)](https://pypi.org/project/cuteagent/)
[![Python](https://img.shields.io/badge/python-3.8%2B-blue)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🚀 Overview

**CuteAgent** is a modular Python library designed to help developers create, manage, and orchestrate AI agents that perform computer-use tasks. It is built for seamless integration with agentic AI workflow frameworks like [LangGraph](https://github.com/langchain-ai/langgraph), making it simple to automate, extend, and build computer use workflows with human-in-the-loop.

**Key Features:**
- 🧩 **Modular Agent Design**: Compose agents with pluggable tools for web, application, and system automation.
- 🔗 **Agentic Workflow Integration**: Native compatibility with frameworks like LangGraph.
- 🔐 **Secure Configuration**: Manage API keys, URLs, and secrets using Pydantic settings.
- 👩‍💻 **Human-in-the-Loop Support**: (Coming soon) Easily add human validation or intervention steps.
- 📦 **Modern Python Packaging**: PEP8-compliant, type-hinted.

# StationAgent - Shared State Management for LangGraph Workflows

**StationAgent** is a Python class that provides shared state management and server coordination for LangGraph workflows. It integrates with a SharedState API to enable multiple workflow instances to coordinate, share data, and manage server resources efficiently.

## 🚀 Key Features

- **Shared State Management**: Sync variables between multiple LangGraph workflow instances
- **Server Coordination**: Prevent conflicts with "busy"/"idle" server status management  
- **Workflow Resumption**: Handle interrupted workflows with thread ID tracking
- **Reserved Variable Protection**: Secure server management variables from user modification
- **LangGraph Integration**: Seamless integration with LangGraph state objects
- **Error Handling**: Robust retry logic and comprehensive error handling

## 📦 Installation

```bash
pip install cuteagent
```

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
    # Initialize StationAgent
    agent = StationAgent(
        station_thread_id=state.stationThreadId,
        graph_thread_id=config.get("thread_id"),
        token=config.get("shared_state_token", "your-api-token")
    )
    
    # Sync shared state variables
    state = agent.state.sync_all(state)
    
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

## 🖥️ Server Management

Coordinate server access between multiple workflows:

```python
# Check server availability
server_status = agent.server.avail()
print(server_status)  # {"server": "idle", "serverThread": "idle"}

# Load server for your task
load_result = agent.server.load("data_processing")
if load_result["status"] == "loaded":
    # Server is now reserved for your workflow
    # Do your processing...
    
    # Unload server when done
    agent.server.unload()
elif load_result["status"] == "busy":
    # Server is busy, handle accordingly
    print("Server is busy, will retry later")
```

## 📋 Complete LangGraph Integration Example

```python
from dataclasses import dataclass, field
from typing import Any, Dict, Optional, List
import asyncio
from cuteagent import StationAgent, WindowsAgent

@dataclass
class State:
    """LangGraph State with SharedState integration."""
    current_node: float = 0
    user_input: str = ""
    stationThreadId: str = ""
    borrower_names: List[str] = field(default_factory=list)
    screenshot_url: str | None = None
    status: str = "Ongoing"
    
    # Required for StationAgent integration
    sharedState: Optional[Dict[str, Any]] = field(default_factory=dict)

async def workflow_start_node(state: State, config) -> State:
    """Example workflow start node with StationAgent integration."""
    configuration = config["configurable"]
    
    # Initialize StationAgent
    agent = StationAgent(
        station_thread_id=state.stationThreadId or "default-workflow",
        graph_thread_id=configuration.get("thread_id", "default-thread"),
        token=configuration.get("shared_state_token", "dev-token-123")
    )
    
    # Check if this workflow can be resumed
    resume_info = agent.uninterrupt("main_workflow")
    if "resumeFrom" in resume_info:
        print(f"🔄 Resuming workflow from: {resume_info['resumeFrom']}")
        # Sync all shared state to get latest data
        state = agent.state.sync_all(state)
        # Set resume point based on shared state
        state.current_node = state.sharedState.get("lastCompletedNode", 1)
    else:
        print("🆕 Starting new workflow")
        # Set thread ID for potential future resume
        agent.state.set("main_workflow_thread_id", configuration.get("thread_id"))
    
    # Check server availability
    server_status = agent.server.avail()
    if server_status.get("server") == "busy":
        print("⏳ Server is busy, waiting...")
        return state  # Could implement retry logic
    
    # Load server for this workflow
    load_result = agent.server.load("main_workflow")
    if load_result.get("status") != "loaded":
        print(f"❌ Failed to load server: {load_result}")
        return state
    
    # Update shared state with workflow start
    agent.state.set("workflowStatus", "started")
    agent.state.set("startTime", "2024-01-01T12:00:00Z")
    agent.state.set("currentNode", "workflow_start")
    
    # Sync updated state back to LangGraph
    state = agent.state.sync_all(state)
    
    state.current_node = 1
    return state

async def processing_node(state: State, config) -> State:
    """Example processing node with shared state coordination."""
    configuration = config["configurable"]
    
    # Initialize StationAgent
    agent = StationAgent(
        station_thread_id=state.stationThreadId or "default-workflow",
        graph_thread_id=configuration.get("thread_id"),
        token=configuration.get("shared_state_token", "dev-token-123")
    )
    
    # Sync latest shared state
    state = agent.state.sync_all(state)
    
    # Check if another workflow updated shared data we need
    shared_borrowers = state.sharedState.get("sharedBorrowerNames", [])
    if shared_borrowers:
        state.borrower_names.extend(shared_borrowers)
        print(f"📊 Using shared borrower data: {shared_borrowers}")
    
    # Do your processing work...
    # (Your existing WindowsAgent operations, screenshots, etc.)
    
    # Update shared state with processing results
    agent.state.set("currentNode", "processing") 
    agent.state.set("processingResults", {
        "borrowers_found": len(state.borrower_names),
        "screenshot_taken": state.screenshot_url is not None
    })
    agent.state.set("lastCompletedNode", state.current_node)
    
    state.current_node = 5
    return state

async def completion_node(state: State, config) -> State:
    """Example completion node that shares final results."""
    configuration = config["configurable"]
    
    # Initialize StationAgent  
    agent = StationAgent(
        station_thread_id=state.stationThreadId or "default-workflow",
        graph_thread_id=configuration.get("thread_id"),
        token=configuration.get("shared_state_token", "dev-token-123")
    )
    
    # Update shared state with final results
    completion_data = {
        "workflowStatus": "completed",
        "finalStatus": state.status,
        "borrowerNames": state.borrower_names,
        "completionTime": "2024-01-01T12:00:00Z",
        "resultsAvailable": True
    }
    
    # Bulk update shared state
    agent.state.push(completion_data)
    
    # Unload server to make it available for other workflows
    unload_result = agent.server.unload()
    print(f"🖥️ Server unloaded: {unload_result}")
    
    # Sync final state back to LangGraph
    state = agent.state.sync_all(state)
    
    state.current_node = 12
    return state
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

## 📖 API Reference

### StationAgent Class

```python
StationAgent(station_thread_id, graph_thread_id, token, shared_state_url=None)
```

**Parameters:**
- `station_thread_id` (str): Identifier for the station/workflow instance
- `graph_thread_id` (str): LangGraph thread identifier  
- `token` (str): Authentication token for SharedState API
- `shared_state_url` (str, optional): Custom API URL (defaults to global URL)

### State Management Methods

#### `agent.state.sync(variable_name, langgraph_state=None)`
Sync single variable from SharedState API to LangGraph state.

```python
# Returns updated state object
state = agent.state.sync("currentStep", state)

# Returns just the variable value (backward compatibility)
value = agent.state.sync("currentStep")
```

#### `agent.state.sync_multiple(variable_names, langgraph_state=None)`
Sync multiple variables from SharedState API to LangGraph state.

```python
state = agent.state.sync_multiple(["var1", "var2", "var3"], state)
```

#### `agent.state.sync_all(langgraph_state)`
Sync all variables from SharedState API to LangGraph state.

```python
state = agent.state.sync_all(state)
```

#### `agent.state.set(variable_name, value)`
Create or update a single variable in SharedState API.

```python
agent.state.set("currentStep", "processing")
agent.state.set("userPrefs", {"theme": "dark"})
```

#### `agent.state.get(variable_name)`
Get a single variable from SharedState API.

```python
current_step = agent.state.get("currentStep")  # Returns value or None
```

#### `agent.state.push(variables_dict)`
Bulk create/update multiple variables in SharedState API.

```python
agent.state.push({
    "workflowId": "wf-123",
    "status": "processing", 
    "data": {"key": "value"}
})
```

#### `agent.state.pull()`
Get all variables from SharedState API.

```python
all_vars = agent.state.pull()  # Returns dict of all variables
```

#### `agent.state.delete(variable_name)`
Delete a variable from SharedState API.

```python
agent.state.delete("temporary_data")
```

#### `agent.state.exists(variable_name)` 
Check if a variable exists in SharedState API.

```python
if agent.state.exists("userPreferences"):
    prefs = agent.state.get("userPreferences")
```

#### `agent.state.list_variables()`
Get list of all variable names.

```python
var_names = agent.state.list_variables()  # Returns list of strings
```

### Server Management Methods

#### `agent.server.load(task_type)`
Load server for a specific task type.

```python
result = agent.server.load("data_processing")
# Returns: {"status": "loaded", "serverThread": "data_processing"} 
#       or {"status": "busy", "error": "Server is busy"}
```

#### `agent.server.unload()`
Unload server and set to idle.

```python
result = agent.server.unload()
# Returns: {"status": "unloaded"}
#       or {"status": "idle", "error": "Server is already idle"}
```

#### `agent.server.avail()`
Get current server availability status.

```python
status = agent.server.avail()
# Returns: {"server": "busy|idle", "serverThread": "task_type|idle"}
```

### Task Management Methods

#### `agent.uninterrupt(task_type)`
Get task thread ID for resuming interrupted tasks.

```python
resume_info = agent.uninterrupt("main_workflow")
# Returns: {"resumeFrom": "thread-id"} or {"error": "Thread ID not found"}
```

### Utility Methods

#### `agent.validate_connection()`
Test connection to SharedState API.

```python
connection = agent.validate_connection()
# Returns: {"connected": True, "variable_count": 5} or {"connected": False, "error": "..."}
```

#### `agent.validate_server_status(status)`
Validate server status value.

```python
is_valid = agent.validate_server_status("busy")  # Returns True
is_valid = agent.validate_server_status("custom")  # Returns False
```

## ⚙️ Configuration

### Environment Variables
```bash
# Optional: Set default API URL
export SHARED_STATE_URL="https://your-api.amazonaws.com/prod"

# Set your API token
export SHARED_STATE_TOKEN="your-api-token"
```

### LangGraph Configuration
Add to your LangGraph configuration:

```python
config = {
    "configurable": {
        "shared_state_token": "your-api-token",
        "shared_state_url": "https://your-api.amazonaws.com/prod",  # Optional
        "thread_id": "your-langgraph-thread-id"
    }
}
```

## 🚨 Error Handling

StationAgent includes comprehensive error handling:

- **Network Retries**: 3 attempts with exponential backoff
- **Authentication Errors**: Clear messages for invalid tokens
- **Validation Errors**: Helpful messages for reserved variables
- **Connection Issues**: Graceful degradation when API unavailable

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

## 🔄 Workflow Patterns

### Pattern 1: Simple State Sync
```python
async def simple_node(state: State, config) -> State:
    agent = StationAgent(state.stationThreadId, config["thread_id"], config["token"])
    
    # Sync all shared state at start
    state = agent.state.sync_all(state)
    
    # Do work...
    
    # Update specific variables
    agent.state.set("nodeCompleted", True)
    
    return state
```

### Pattern 2: Server Coordination
```python
async def coordinated_node(state: State, config) -> State:
    agent = StationAgent(state.stationThreadId, config["thread_id"], config["token"])
    
    # Check and load server
    load_result = agent.server.load("screenshot_processing")
    if load_result["status"] == "busy":
        # Handle busy server
        return state
    
    # Do server work...
    
    # Unload server
    agent.server.unload()
    return state
```

### Pattern 3: Workflow Resumption
```python
async def resumable_node(state: State, config) -> State:
    agent = StationAgent(state.stationThreadId, config["thread_id"], config["token"])
    
    # Check for interruption
    resume_info = agent.uninterrupt("workflow_type")
    if "resumeFrom" in resume_info:
        # Resume from previous state
        state = agent.state.sync_all(state)
        return state
    
    # New workflow
    agent.state.set("workflow_type_thread_id", config["thread_id"])
    # ... continue
```

## 📚 Best Practices

1. **Always sync state at node start**: Use `sync_all()` to get latest shared data
2. **Use server coordination**: Call `server.load()` before exclusive operations  
3. **Update progress regularly**: Set completion markers for resumption
4. **Handle server busy states**: Implement retry logic or queuing
5. **Clean up on completion**: Call `server.unload()` and update final status
6. **Error handling**: Wrap StationAgent calls in try-catch blocks
7. **Thread ID consistency**: Use the same thread_id throughout the workflow

## 🤝 Contributing

StationAgent is part of the CuteAgent library. For issues, feature requests, or contributions, please contact the development team.

## 📄 License

This project is licensed under the MIT License.

---

**Ready to coordinate your LangGraph workflows? Start using StationAgent today!** 🚀



