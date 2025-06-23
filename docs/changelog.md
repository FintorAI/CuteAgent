# Changelog

## v0.2.11 - 2024-01-XX

**New Features**:

-   **WindowsAgent.click_cached_element()**: New method for clicking elements using cached coordinates from API
    - Fetches element coordinates based on element name and task type
    - Requires cache_token parameter during WindowsAgent initialization
    - Provides improved reliability over direct coordinate clicking
    - Supports comprehensive error handling for missing tokens, API failures, and invalid responses

**Improvements**:

-   **WindowsAgent constructor**: Enhanced with optional cache_token parameter for element-based operations
-   **API Documentation**: Added comprehensive WindowsAgent documentation to API reference
-   **Usage Guide**: Completely updated usage.md with practical examples, workflow patterns, and best practices
-   **Documentation Structure**: Reorganized API reference to cover all three agent types (WindowsAgent, StationAgent, HumanAgent)

**Technical Details**:

-   Element search API endpoint: `https://cega6bexzc.execute-api.us-west-1.amazonaws.com/prod/elements/search`
-   API authentication via x-api-key header with cache_token
-   Automatic coordinate conversion and validation
-   Method name changed from `click_element_name` to `click_cached_element` for clarity

## v0.0.1 - Date

**Improvement**:

-   TBD

**New Features**:

-   TBD
